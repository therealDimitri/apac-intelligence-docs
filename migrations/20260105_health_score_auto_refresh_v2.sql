-- Migration: Auto-Refresh Triggers for client_health_summary Materialized View (V2)
-- Date: 2026-01-05
-- Fix: Changed function to return TRIGGER type for compatibility

-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS trigger_refresh_health_on_actions ON actions;
DROP TRIGGER IF EXISTS trigger_refresh_health_on_nps ON nps_responses;
DROP TRIGGER IF EXISTS trigger_refresh_health_on_aging ON aging_accounts;

-- Drop existing function
DROP FUNCTION IF EXISTS refresh_client_health_summary();

-- Create trigger function that returns TRIGGER
CREATE OR REPLACE FUNCTION refresh_client_health_summary_trigger()
RETURNS TRIGGER
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
  IF time_since_last_refresh > INTERVAL '1 minute' THEN
    REFRESH MATERIALIZED VIEW CONCURRENTLY client_health_summary;
    RAISE NOTICE 'client_health_summary refreshed at %', NOW();
  END IF;

  RETURN NULL; -- For AFTER triggers, return value is ignored
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION refresh_client_health_summary_trigger() TO anon, authenticated;

-- Trigger for actions table
CREATE TRIGGER trigger_refresh_health_on_actions
  AFTER INSERT OR UPDATE OR DELETE ON actions
  FOR EACH STATEMENT
  EXECUTE FUNCTION refresh_client_health_summary_trigger();

-- Trigger for nps_responses table
CREATE TRIGGER trigger_refresh_health_on_nps
  AFTER INSERT OR UPDATE OR DELETE ON nps_responses
  FOR EACH STATEMENT
  EXECUTE FUNCTION refresh_client_health_summary_trigger();

-- Trigger for aging_accounts table
CREATE TRIGGER trigger_refresh_health_on_aging
  AFTER INSERT OR UPDATE OR DELETE ON aging_accounts
  FOR EACH STATEMENT
  EXECUTE FUNCTION refresh_client_health_summary_trigger();

COMMENT ON FUNCTION refresh_client_health_summary_trigger() IS
'Trigger function that refreshes client_health_summary with rate limiting (max once per minute).';
