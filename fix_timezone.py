#!/usr/bin/env python3
"""
PostgreSQL Timezone Fix Tool for Memoet

This tool fixes the timezone issue where PostgreSQL doesn't recognize "US/Central" 
and other US timezone formats. It updates the database to use proper PostgreSQL 
timezone names and provides a mapping for the application.
"""

import psycopg2
import os
import sys
from typing import Dict, List, Tuple

# Database connection parameters
DB_CONFIG = {
    'host': 'localhost',
    'port': os.getenv('DATABASE_PORT', '5432'),
    'database': 'postgres',
    'user': 'postgres',
    'password': 'postgres'
}

# Timezone mapping from US format to PostgreSQL format
TIMEZONE_MAPPING = {
    'US/Central': 'America/Chicago',
    'US/Eastern': 'America/New_York',
    'US/Mountain': 'America/Denver',
    'US/Pacific': 'America/Los_Angeles',
    'US/Alaska': 'America/Anchorage',
    'US/Arizona': 'America/Phoenix',
    'US/East-Indiana': 'America/Indiana/Indianapolis',
    'US/Hawaii': 'Pacific/Honolulu',
    'Canada/Atlantic': 'America/Halifax',
    'Canada/Central': 'America/Winnipeg',
    'Canada/Eastern': 'America/Toronto',
    'Canada/Mountain': 'America/Edmonton',
    'Canada/Newfoundland': 'America/St_Johns',
    'Canada/Pacific': 'America/Vancouver',
    'Canada/Saskatchewan': 'America/Regina',
    'Canada/Yukon': 'America/Whitehorse'
}

class TimezoneFixer:
    def __init__(self, db_config: Dict[str, str]):
        self.db_config = db_config
        self.connection = None
        
    def connect(self):
        """Establish database connection"""
        try:
            self.connection = psycopg2.connect(**self.db_config)
            self.connection.autocommit = False
            print("✓ Connected to PostgreSQL database")
            return True
        except psycopg2.Error as e:
            print(f"✗ Failed to connect to database: {e}")
            return False
    
    def disconnect(self):
        """Close database connection"""
        if self.connection:
            self.connection.close()
            print("✓ Database connection closed")
    
    def get_invalid_timezones(self) -> List[Tuple[str, int]]:
        """Find users with invalid timezone formats"""
        cursor = self.connection.cursor()
        
        query = """
        SELECT id, timezone 
        FROM srs_configs 
        WHERE timezone IN %s
        """
        
        invalid_timezones = list(TIMEZONE_MAPPING.keys())
        cursor.execute(query, (tuple(invalid_timezones),))
        
        results = cursor.fetchall()
        cursor.close()
        
        return results
    
    def fix_timezone(self, user_id: str, old_timezone: str) -> bool:
        """Fix timezone for a specific user"""
        if old_timezone not in TIMEZONE_MAPPING:
            print(f"⚠ No mapping found for timezone: {old_timezone}")
            return False
        
        new_timezone = TIMEZONE_MAPPING[old_timezone]
        cursor = self.connection.cursor()
        
        try:
            # Update the timezone
            update_query = """
            UPDATE srs_configs 
            SET timezone = %s 
            WHERE id = %s
            """
            cursor.execute(update_query, (new_timezone, user_id))
            
            # Verify the update
            verify_query = "SELECT timezone FROM srs_configs WHERE id = %s"
            cursor.execute(verify_query, (user_id,))
            result = cursor.fetchone()
            
            if result and result[0] == new_timezone:
                print(f"✓ Updated user {user_id}: {old_timezone} → {new_timezone}")
                return True
            else:
                print(f"✗ Failed to update user {user_id}")
                return False
                
        except psycopg2.Error as e:
            print(f"✗ Database error updating user {user_id}: {e}")
            return False
        finally:
            cursor.close()
    
    def fix_all_timezones(self) -> Dict[str, int]:
        """Fix all invalid timezones in the database"""
        print("🔍 Scanning for invalid timezones...")
        
        invalid_users = self.get_invalid_timezones()
        
        if not invalid_users:
            print("✓ No invalid timezones found")
            return {"fixed": 0, "failed": 0}
        
        print(f"Found {len(invalid_users)} users with invalid timezones")
        
        fixed_count = 0
        failed_count = 0
        
        for user_id, old_timezone in invalid_users:
            if self.fix_timezone(user_id, old_timezone):
                fixed_count += 1
            else:
                failed_count += 1
        
        return {"fixed": fixed_count, "failed": failed_count}
    
    def test_timezone_query(self, timezone: str) -> bool:
        """Test if a timezone works in PostgreSQL"""
        cursor = self.connection.cursor()
        
        try:
            # Test query similar to the one causing the error
            test_query = """
            SELECT date(now() at time zone 'utc' at time zone %s) as test_date
            """
            cursor.execute(test_query, (timezone,))
            result = cursor.fetchone()
            
            if result:
                print(f"✓ Timezone '{timezone}' works correctly")
                return True
            else:
                print(f"✗ Timezone '{timezone}' failed")
                return False
                
        except psycopg2.Error as e:
            print(f"✗ Timezone '{timezone}' error: {e}")
            return False
        finally:
            cursor.close()
    
    def generate_timezone_mapping_file(self):
        """Generate a timezone mapping file for the Elixir application"""
        mapping_content = '''# Timezone mapping for PostgreSQL compatibility
# This file maps US timezone formats to PostgreSQL-compatible formats

defmodule Memoet.Utils.TimezoneMapping do
  @moduledoc """
  Maps US timezone formats to PostgreSQL-compatible timezone names
  """
  
  @timezone_mapping %{
    "US/Central" => "America/Chicago",
    "US/Eastern" => "America/New_York", 
    "US/Mountain" => "America/Denver",
    "US/Pacific" => "America/Los_Angeles",
    "US/Alaska" => "America/Anchorage",
    "US/Arizona" => "America/Phoenix",
    "US/East-Indiana" => "America/Indiana/Indianapolis",
    "US/Hawaii" => "Pacific/Honolulu",
    "Canada/Atlantic" => "America/Halifax",
    "Canada/Central" => "America/Winnipeg",
    "Canada/Eastern" => "America/Toronto",
    "Canada/Mountain" => "America/Edmonton",
    "Canada/Newfoundland" => "America/St_Johns",
    "Canada/Pacific" => "America/Vancouver",
    "Canada/Saskatchewan" => "America/Regina",
    "Canada/Yukon" => "America/Whitehorse"
  }
  
  def normalize_timezone(timezone) do
    Map.get(@timezone_mapping, timezone, timezone)
  end
  
  def get_mapping() do
    @timezone_mapping
  end
end
'''
        
        with open('/home/hnat/services/memoet/lib/memoet/utils/timezone_mapping.ex', 'w') as f:
            f.write(mapping_content)
        
        print("✓ Generated timezone mapping file: lib/memoet/utils/timezone_mapping.ex")

def main():
    """Main function to run the timezone fix"""
    print("🔧 PostgreSQL Timezone Fix Tool for Memoet")
    print("=" * 50)
    
    fixer = TimezoneFixer(DB_CONFIG)
    
    if not fixer.connect():
        sys.exit(1)
    
    try:
        # Test current problematic timezone
        print("\n🧪 Testing timezone compatibility...")
        fixer.test_timezone_query("US/Central")
        fixer.test_timezone_query("America/Chicago")
        
        # Fix all invalid timezones
        print("\n🔧 Fixing invalid timezones...")
        results = fixer.fix_all_timezones()
        
        print(f"\n📊 Results:")
        print(f"  Fixed: {results['fixed']}")
        print(f"  Failed: {results['failed']}")
        
        # Generate mapping file
        print("\n📝 Generating timezone mapping file...")
        fixer.generate_timezone_mapping_file()
        
        # Test the fix
        print("\n🧪 Testing fixed timezone...")
        fixer.test_timezone_query("America/Chicago")
        
        print("\n✅ Timezone fix completed successfully!")
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        sys.exit(1)
    finally:
        fixer.disconnect()

if __name__ == "__main__":
    main()
