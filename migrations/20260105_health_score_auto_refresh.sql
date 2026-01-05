-- Migration: Auto-Refresh Triggers for client_health_summary Materialized View
-- Date: 2026-01-05
-- Issue: Materialized view becomes stale when underlying data changes
--
-- This migration creates:
-- 1. A refresh function that refreshes the materialized view with rate limiting
-- 2. Triggers on underlying tables (actions, nps_responses, aging_accounts, event_compliance_summary)
--    that call the refresh function when data changes
--
-- To Execute: Run this SQL in Supabase Dashboard > SQL Editor
-- Or use: node scripts/apply-health-refresh-triggers.mjs

-- ============================================================================
-- Step 1: Create the refresh function with rate limiting
-- ============================================================================

CREATE OR REPLACE FUNCTION refresh_client_health_summary()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  last_refresh_time timestamptz;
  time_since_last_refresh interval;
BEGIN
  -- Get the last refresh time from the materialized view
  SELECT MAX(last_refreshed) INTO last_refresh_time
  FROM client_health_summary;

  -- Calculate time since last refresh
  time_since_last_refresh := NOW() - COALESCE(last_refresh_time, '1970-01-01'::timestamptz);

  -- Only refresh if more than 1 minute has passed since last refresh
  -- This prevents too-frequent refreshes from multiple rapid changes
  IF time_since_last_refresh > INTERVAL '1 minute' THEN
    -- Use CONCURRENTLY since we have a unique index (idx_client_health_summary_id)
    -- This allows SELECT queries to continue while the view is being refreshed
    REFRESH MATERIALIZED VIEW CONCURRENTLY client_health_summary;

    RAISE NOTICE 'client_health_summary refreshed at %', NOW();
  ELSE
    RAISE NOTICE 'Skipping refresh - last refresh was % ago (< 1 minute)', time_since_last_refresh;
  END IF;
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION refresh_client_health_summary() TO anon, authenticated;

-- ============================================================================
-- Step 2: Create triggers on underlying tables
-- ============================================================================

-- Trigger for actions table
-- Fires when actions are inserted, updated, or deleted
DROP TRIGGER IF EXISTS trigger_refresh_health_on_actions ON actions;
CREATE TRIGGER trigger_refresh_health_on_actions
  AFTER INSERT OR UPDATE OR DELETE ON actions
  FOR EACH STATEMENT
  EXECUTE FUNCTION refresh_client_health_summary();

-- Trigger for nps_responses table
-- Fires when NPS responses are inserted, updated, or deleted
DROP TRIGGER IF EXISTS trigger_refresh_health_on_nps ON nps_responses;
CREATE TRIGGER trigger_refresh_health_on_nps
  AFTER INSERT OR UPDATE OR DELETE ON nps_responses
  FOR EACH STATEMENT
  EXECUTE FUNCTION refresh_client_health_summary();

-- Trigger for aging_accounts table
-- Fires when aging accounts data is inserted, updated, or deleted
DROP TRIGGER IF EXISTS trigger_refresh_health_on_aging ON aging_accounts;
CREATE TRIGGER trigger_refresh_health_on_aging
  AFTER INSERT OR UPDATE OR DELETE ON aging_accounts
  FOR EACH STATEMENT
  EXECUTE FUNCTION refresh_client_health_summary();

-- Trigger for event_compliance_summary materialized view
-- Note: Materialized views don't support triggers directly, so we need to create
-- a wrapper function that can be called manually or via a scheduled job
-- For now, we'll document that event_compliance_summary should be refreshed
-- before refreshing client_health_summary if it has changed

-- ============================================================================
-- Step 3: Comments and documentation
-- ============================================================================

COMMENT ON FUNCTION refresh_client_health_summary() IS
'Refreshes the client_health_summary materialized view with rate limiting (max once per minute).
Uses CONCURRENTLY to allow concurrent SELECT queries during refresh.
Called automatically by triggers on actions, nps_responses, and aging_accounts tables.';

COMMENT ON TRIGGER trigger_refresh_health_on_actions ON actions IS
'Automatically refreshes client_health_summary when actions are modified (rate limited to once per minute)';

COMMENT ON TRIGGER trigger_refresh_health_on_nps ON nps_responses IS
'Automatically refreshes client_health_summary when NPS responses are modified (rate limited to once per minute)';

COMMENT ON TRIGGER trigger_refresh_health_on_aging ON aging_accounts IS
'Automatically refreshes client_health_summary when aging accounts data is modified (rate limited to once per minute)';

-- ============================================================================
-- Verification queries
-- ============================================================================

-- Verify triggers were created
-- SELECT
--   trigger_name,
--   event_manipulation,
--   event_object_table,
--   action_statement
-- FROM information_schema.triggers
-- WHERE trigger_name LIKE 'trigger_refresh_health_%'
-- ORDER BY event_object_table;

-- Verify function exists
-- SELECT
--   routine_name,
--   routine_type,
--   routine_definition
-- FROM information_schema.routines
-- WHERE routine_name = 'refresh_client_health_summary';

-- Test the refresh function manually
-- SELECT refresh_client_health_summary();

-- Check last refresh time
-- SELECT
--   client_name,
--   health_score,
--   status,
--   last_refreshed
-- FROM client_health_summary
-- ORDER BY last_refreshed DESC
-- LIMIT 5;

-- ============================================================================
-- Rollback script (if needed)
-- ============================================================================

-- DROP TRIGGER IF EXISTS trigger_refresh_health_on_actions ON actions;
-- DROP TRIGGER IF EXISTS trigger_refresh_health_on_nps ON nps_responses;
-- DROP TRIGGER IF EXISTS trigger_refresh_health_on_aging ON aging_accounts;
-- DROP FUNCTION IF EXISTS refresh_client_health_summary();
