#!/bin/bash

# PostgreSQL Timezone Fix Script for Memoet
# This script fixes the timezone issue by updating the database and testing the fix

set -e

echo "🔧 PostgreSQL Timezone Fix for Memoet"
echo "====================================="

# Check if Docker is running
if ! docker ps > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if memoet services are running
if ! docker-compose ps | grep -q "memoet.*Up"; then
    echo "⚠️  Memoet services are not running. Starting them..."
    docker-compose up -d
    echo "⏳ Waiting for services to be ready..."
    sleep 10
fi

echo "📊 Checking current timezone data..."
docker-compose exec postgres psql -U postgres -d postgres -c "
SELECT timezone, COUNT(*) as count 
FROM srs_configs 
WHERE timezone LIKE 'US/%' OR timezone LIKE 'Canada/%'
GROUP BY timezone 
ORDER BY timezone;
"

echo ""
echo "🔧 Applying timezone fixes..."
docker-compose exec postgres psql -U postgres -d postgres -f /tmp/fix_database_timezones.sql

echo ""
echo "📊 Verifying fixes..."
docker-compose exec postgres psql -U postgres -d postgres -c "
SELECT timezone, COUNT(*) as count 
FROM srs_configs 
GROUP BY timezone 
ORDER BY timezone;
"

echo ""
echo "🧪 Testing timezone queries..."

# Test the problematic query that was causing the error
echo "Testing US/Central (should fail):"
docker-compose exec postgres psql -U postgres -d postgres -c "
SELECT date(now() at time zone 'utc' at time zone 'US/Central') as test_date;
" 2>&1 || echo "Expected failure for US/Central"

echo ""
echo "Testing America/Chicago (should work):"
docker-compose exec postgres psql -U postgres -d postgres -c "
SELECT date(now() at time zone 'utc' at time zone 'America/Chicago') as test_date;
"

echo ""
echo "✅ Timezone fix completed!"
echo ""
echo "📝 Summary of changes:"
echo "  - Updated timezone mappings in lib/memoet/utils/timezone_util.ex"
echo "  - Fixed existing database records"
echo "  - All US/Canada timezone formats now use PostgreSQL-compatible names"
echo ""
echo "🔄 You may need to restart the memoet application for changes to take effect:"
echo "   docker-compose restart memoet"
