-- Migration: Set Up Materialized View Refresh Schedule
-- Date: 2025-12-02
-- Purpose: Configure automatic refresh of materialized views using pg_cron
-- Impact: Ensures data freshness without manual intervention
--
-- CRITICAL: This migration sets up scheduled jobs to refresh:
--   1. client_health_summary (every 5 minutes)
--   2. event_compliance_summary (every 5 minutes)
--
-- Deployment: Safe to run on production
-- Rollback: See unschedule commands at bottom
--
-- PREREQUISITES:
-- 1. Both materialized views must be deployed first:
--    - client_health_summary
--    - event_compliance_summary
-- 2. pg_cron extension must be enabled (see Step 1)

-- ============================================================================
-- 1. ENABLE PG_CRON EXTENSION
-- ============================================================================

-- Enable pg_cron extension for scheduled jobs
-- Note: This may require superuser privileges in Supabase
-- If this fails, pg_cron may already be enabled or require dashboard access
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- ============================================================================
-- 2. SCHEDULE CLIENT HEALTH SUMMARY REFRESH
-- ============================================================================

-- Remove existing schedule if it exists (idempotent)
SELECT cron.unschedule('refresh_client_health_summary')
WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'refresh_client_health_summary'
);

-- Schedule refresh every 5 minutes
-- Uses CONCURRENTLY to avoid blocking queries during refresh
SELECT cron.schedule(
  'refresh_client_health_summary',  -- Job name
  '*/5 * * * *',                     -- Cron expression: every 5 minutes
  $$REFRESH MATERIALIZED VIEW CONCURRENTLY client_health_summary;$$
);

-- ============================================================================
-- 3. SCHEDULE EVENT COMPLIANCE SUMMARY REFRESH
-- ============================================================================

-- Remove existing schedule if it exists (idempotent)
SELECT cron.unschedule('refresh_event_compliance_summary')
WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'refresh_event_compliance_summary'
);

-- Schedule refresh every 5 minutes
-- Uses CONCURRENTLY to avoid blocking queries during refresh
SELECT cron.schedule(
  'refresh_event_compliance_summary',  -- Job name
  '*/5 * * * *',                        -- Cron expression: every 5 minutes
  $$REFRESH MATERIALIZED VIEW CONCURRENTLY event_compliance_summary;$$
);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- After running this migration, verify the scheduled jobs:
--
-- List all scheduled jobs:
-- SELECT
--   jobid,
--   jobname,
--   schedule,
--   command,
--   nodename,
--   nodeport,
--   database,
--   username,
--   active
-- FROM cron.job
-- WHERE jobname LIKE 'refresh_%'
-- ORDER BY jobname;
--
-- Expected output: 2 jobs
--   1. refresh_client_health_summary (*/5 * * * *)
--   2. refresh_event_compliance_summary (*/5 * * * *)
--
-- Check job run history (last 10 runs):
-- SELECT
--   jobid,
--   runid,
--   job_pid,
--   database,
--   username,
--   command,
--   status,
--   return_message,
--   start_time,
--   end_time,
--   end_time - start_time as duration
-- FROM cron.job_run_details
-- WHERE jobid IN (
--   SELECT jobid FROM cron.job WHERE jobname LIKE 'refresh_%'
-- )
-- ORDER BY start_time DESC
-- LIMIT 10;
--
-- Check last refresh time for each view:
-- SELECT 'client_health_summary' as view_name, MAX(last_refreshed) as last_refresh
-- FROM client_health_summary
-- UNION ALL
-- SELECT 'event_compliance_summary', MAX(last_updated) as last_refresh
-- FROM event_compliance_summary;

-- ============================================================================
-- CRON EXPRESSION REFERENCE
-- ============================================================================

-- Format: minute hour day_of_month month day_of_week
--
-- Examples:
-- '*/5 * * * *'    = Every 5 minutes
-- '*/10 * * * *'   = Every 10 minutes
-- '*/15 * * * *'   = Every 15 minutes
-- '0 * * * *'      = Every hour at minute 0
-- '0 */2 * * *'    = Every 2 hours
-- '0 0 * * *'      = Daily at midnight
-- '0 0 * * 0'      = Weekly on Sunday at midnight
-- '0 2 * * *'      = Daily at 2 AM
-- '30 3 * * 1'     = Weekly on Monday at 3:30 AM

-- ============================================================================
-- ALTERNATIVE: MANUAL REFRESH
-- ============================================================================

-- If pg_cron is not available or you prefer manual control,
-- you can refresh the views manually when needed:
--
-- Refresh both views (non-blocking):
-- REFRESH MATERIALIZED VIEW CONCURRENTLY client_health_summary;
-- REFRESH MATERIALIZED VIEW CONCURRENTLY event_compliance_summary;
--
-- Or create an API endpoint to trigger refreshes programmatically:
-- See: src/app/api/refresh-materialized-views/route.ts (to be created)

-- ============================================================================
-- ALTERNATIVE: EXTERNAL CRON SCHEDULE
-- ============================================================================

-- If pg_cron is not available in Supabase, you can use external scheduling:
--
-- Option A: Vercel Cron (if deployed on Vercel)
-- 1. Create API route: /api/refresh-views
-- 2. Add to vercel.json:
--    {
--      "crons": [{
--        "path": "/api/refresh-views",
--        "schedule": "*/5 * * * *"
--      }]
--    }
--
-- Option B: GitHub Actions
-- 1. Create .github/workflows/refresh-views.yml
-- 2. Schedule: cron: '*/5 * * * *'
-- 3. Action: curl POST to /api/refresh-views
--
-- Option C: AWS EventBridge / CloudWatch Events
-- Option D: Google Cloud Scheduler
-- Option E: Azure Logic Apps

-- ============================================================================
-- MONITORING & ALERTS
-- ============================================================================

-- To monitor refresh performance, you can create a monitoring query:
--
-- CREATE OR REPLACE VIEW view_refresh_stats AS
-- SELECT
--   jobname,
--   COUNT(*) as total_runs,
--   COUNT(*) FILTER (WHERE status = 'succeeded') as successful_runs,
--   COUNT(*) FILTER (WHERE status = 'failed') as failed_runs,
--   AVG(EXTRACT(EPOCH FROM (end_time - start_time))) as avg_duration_seconds,
--   MAX(end_time) as last_run_time
-- FROM cron.job_run_details jrd
-- JOIN cron.job j ON j.jobid = jrd.jobid
-- WHERE j.jobname LIKE 'refresh_%'
-- GROUP BY jobname;
--
-- Query the view:
-- SELECT * FROM view_refresh_stats;

-- ============================================================================
-- ROLLBACK INSTRUCTIONS
-- ============================================================================

-- To remove the scheduled jobs:
--
-- SELECT cron.unschedule('refresh_client_health_summary');
-- SELECT cron.unschedule('refresh_event_compliance_summary');
--
-- To verify removal:
-- SELECT * FROM cron.job WHERE jobname LIKE 'refresh_%';
-- Expected: 0 rows

-- ============================================================================
-- TROUBLESHOOTING
-- ============================================================================

-- If pg_cron extension is not available:
-- ERROR: extension "pg_cron" is not available
-- SOLUTION: Contact Supabase support or use external scheduling (see above)
--
-- If CONCURRENTLY refresh fails:
-- ERROR: cannot refresh materialized view "X" concurrently
-- REASON: View doesn't have a UNIQUE index
-- SOLUTION: Both views have UNIQUE indexes already created in their migrations
--
-- If jobs are not running:
-- 1. Check if pg_cron is enabled: SELECT * FROM pg_extension WHERE extname = 'pg_cron';
-- 2. Check job status: SELECT * FROM cron.job WHERE jobname LIKE 'refresh_%';
-- 3. Check job run history: SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;
--
-- If refresh takes too long:
-- 1. Check view size: SELECT pg_size_pretty(pg_total_relation_size('client_health_summary'));
-- 2. Check query performance: EXPLAIN ANALYZE SELECT * FROM client_health_summary;
-- 3. Consider increasing refresh interval to 10 or 15 minutes

-- ============================================================================
-- NOTES
-- ============================================================================

-- Refresh Frequency Considerations:
-- - 5 minutes: Good balance between freshness and system load
-- - 10 minutes: Lower load, acceptable staleness for most use cases
-- - 15 minutes: Minimal load, suitable for less frequently changing data
-- - Hourly: Very low load, suitable for reporting/analytics views
--
-- Data Freshness Trade-offs:
-- - More frequent refreshes = fresher data but higher database load
-- - Less frequent refreshes = lower load but staler data
-- - Consider your application's SLA requirements
--
-- CONCURRENTLY vs Regular Refresh:
-- - CONCURRENTLY: Non-blocking, allows queries during refresh (requires UNIQUE index)
-- - Regular: Blocking, faster but locks the view during refresh
-- - We use CONCURRENTLY to maintain application availability

-- ============================================================================
-- PERFORMANCE IMPACT
-- ============================================================================

-- Estimated refresh times (based on view complexity):
-- - client_health_summary: 1-3 seconds (50 clients × 6 table joins)
-- - event_compliance_summary: 2-5 seconds (50 clients × 2 years × 5 CTEs)
--
-- Database load:
-- - Refreshing every 5 minutes = 12 refreshes/hour × 2 views = 24 refreshes/hour
-- - Total refresh time: ~5 seconds × 24 = 2 minutes/hour database time
-- - Database utilization: 2 min / 60 min = 3.3% (acceptable overhead)
--
-- If refresh time exceeds 5 minutes (between scheduled runs):
-- - Jobs will queue and execute sequentially
-- - Consider increasing interval or optimizing view queries
-- - Monitor with: SELECT * FROM cron.job_run_details WHERE status = 'running';
