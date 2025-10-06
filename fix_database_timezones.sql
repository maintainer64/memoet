-- PostgreSQL Timezone Fix Migration
-- This script updates existing timezone data to use PostgreSQL-compatible timezone names

-- Update US timezone formats to PostgreSQL-compatible formats
UPDATE srs_configs 
SET timezone = 'America/Chicago' 
WHERE timezone = 'US/Central';

UPDATE srs_configs 
SET timezone = 'America/New_York' 
WHERE timezone = 'US/Eastern';

UPDATE srs_configs 
SET timezone = 'America/Denver' 
WHERE timezone = 'US/Mountain';

UPDATE srs_configs 
SET timezone = 'America/Los_Angeles' 
WHERE timezone = 'US/Pacific';

UPDATE srs_configs 
SET timezone = 'America/Anchorage' 
WHERE timezone = 'US/Alaska';

UPDATE srs_configs 
SET timezone = 'America/Phoenix' 
WHERE timezone = 'US/Arizona';

UPDATE srs_configs 
SET timezone = 'America/Indiana/Indianapolis' 
WHERE timezone = 'US/East-Indiana';

UPDATE srs_configs 
SET timezone = 'Pacific/Honolulu' 
WHERE timezone = 'US/Hawaii';

-- Update Canadian timezone formats
UPDATE srs_configs 
SET timezone = 'America/Halifax' 
WHERE timezone = 'Canada/Atlantic';

UPDATE srs_configs 
SET timezone = 'America/Winnipeg' 
WHERE timezone = 'Canada/Central';

UPDATE srs_configs 
SET timezone = 'America/Toronto' 
WHERE timezone = 'Canada/Eastern';

UPDATE srs_configs 
SET timezone = 'America/Edmonton' 
WHERE timezone = 'Canada/Mountain';

UPDATE srs_configs 
SET timezone = 'America/St_Johns' 
WHERE timezone = 'Canada/Newfoundland';

UPDATE srs_configs 
SET timezone = 'America/Vancouver' 
WHERE timezone = 'Canada/Pacific';

UPDATE srs_configs 
SET timezone = 'America/Regina' 
WHERE timezone = 'Canada/Saskatchewan';

UPDATE srs_configs 
SET timezone = 'America/Whitehorse' 
WHERE timezone = 'Canada/Yukon';

-- Verify the updates
SELECT timezone, COUNT(*) as count 
FROM srs_configs 
GROUP BY timezone 
ORDER BY timezone;
