-- Refresh Compliance Materialized Views
-- Run this in Supabase Dashboard SQL Editor after importing new segmentation data
-- Date: 2025-12-15

-- Refresh the event_compliance_summary materialized view
-- This updates all client health scores and compliance calculations
REFRESH MATERIALIZED VIEW event_compliance_summary;

-- Optional: Refresh any other health-related views if they exist
-- REFRESH MATERIALIZED VIEW CONCURRENTLY client_health_summary;

-- Verify the refresh worked by checking last_updated timestamps
SELECT
  client_name,
  overall_compliance_score,
  overall_status,
  last_updated
FROM event_compliance_summary
WHERE year = 2025
ORDER BY client_name
LIMIT 10;
