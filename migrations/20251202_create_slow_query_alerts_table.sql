-- Migration: Create Slow Query Alerts Table
-- Date: 2025-12-02
-- Purpose: Enable slow query alerting and notification tracking
-- Impact: Foundation for Phase 4 slow query alert system
--
-- Features:
--   - Track all slow query alerts
--   - Notification status tracking
--   - Severity classification (warning/critical)
--   - Integration with query_performance_logs
--
-- Deployment: Safe to run on production (no impact on existing tables)
-- Rollback: DROP TABLE slow_query_alerts CASCADE;

-- ============================================================================
-- CREATE TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS slow_query_alerts (
  -- Primary key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Timing
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Query information
  query_name TEXT NOT NULL,
  execution_time_ms INTEGER NOT NULL,
  table_name TEXT,

  -- Alert severity
  severity TEXT NOT NULL CHECK (severity IN ('warning', 'critical')),

  -- Notification tracking
  notified BOOLEAN NOT NULL DEFAULT FALSE,
  notification_sent_at TIMESTAMPTZ,
  notification_channels TEXT[], -- e.g., ['console', 'slack', 'email']

  -- User context
  user_id UUID,

  -- Foreign key to performance logs (optional reference)
  performance_log_id UUID,

  -- Constraints
  CONSTRAINT positive_execution_time CHECK (execution_time_ms >= 0)
);

-- ============================================================================
-- INDEXES FOR ALERT QUERIES
-- ============================================================================

-- Index 1: Time-based queries (most recent alerts first)
CREATE INDEX idx_slow_query_alerts_timestamp
ON slow_query_alerts(timestamp DESC);

-- Index 2: Severity-based queries (find critical alerts)
CREATE INDEX idx_slow_query_alerts_severity
ON slow_query_alerts(severity, timestamp DESC)
WHERE severity = 'critical';

-- Index 3: Unnotified alerts (for processing)
CREATE INDEX idx_slow_query_alerts_unnotified
ON slow_query_alerts(notified, timestamp DESC)
WHERE notified = FALSE;

-- Index 4: Per-table alert tracking
CREATE INDEX idx_slow_query_alerts_table_name
ON slow_query_alerts(table_name, timestamp DESC)
WHERE table_name IS NOT NULL;

-- Index 5: Per-user alert tracking
CREATE INDEX idx_slow_query_alerts_user_id
ON slow_query_alerts(user_id, timestamp DESC)
WHERE user_id IS NOT NULL;

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS
ALTER TABLE slow_query_alerts ENABLE ROW LEVEL SECURITY;

-- Policy 1: Admins can view all alerts
CREATE POLICY "Admins can view all slow query alerts"
  ON slow_query_alerts
  FOR SELECT
  TO authenticated
  USING (
    -- Allow access if user is an admin
    current_user IN (
      SELECT email FROM auth.users WHERE email LIKE '%@alteradigitalhealth.com'
    )
  );

-- Policy 2: Service role bypass (for automated logging)
CREATE POLICY "Service role full access slow_query_alerts"
  ON slow_query_alerts
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Policy 3: Users can view their own query alerts
CREATE POLICY "Users can view their own slow query alerts"
  ON slow_query_alerts
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- ============================================================================
-- HELPFUL VIEWS
-- ============================================================================

-- View 1: Recent critical alerts (last 24 hours)
CREATE OR REPLACE VIEW recent_critical_alerts AS
SELECT
  id,
  timestamp,
  query_name,
  table_name,
  execution_time_ms,
  notified,
  notification_sent_at
FROM slow_query_alerts
WHERE
  severity = 'critical'
  AND timestamp > NOW() - INTERVAL '24 hours'
ORDER BY execution_time_ms DESC;

-- View 2: Alert summary by table (last 7 days)
CREATE OR REPLACE VIEW alert_summary_by_table AS
SELECT
  table_name,
  COUNT(*) AS total_alerts,
  SUM(CASE WHEN severity = 'critical' THEN 1 ELSE 0 END) AS critical_alerts,
  SUM(CASE WHEN severity = 'warning' THEN 1 ELSE 0 END) AS warning_alerts,
  ROUND(AVG(execution_time_ms))::INTEGER AS avg_execution_time_ms,
  MAX(execution_time_ms) AS max_execution_time_ms
FROM slow_query_alerts
WHERE
  table_name IS NOT NULL
  AND timestamp > NOW() - INTERVAL '7 days'
GROUP BY table_name
ORDER BY total_alerts DESC;

-- View 3: Alert summary by day (last 30 days)
CREATE OR REPLACE VIEW daily_alert_summary AS
SELECT
  DATE_TRUNC('day', timestamp)::DATE AS date,
  COUNT(*) AS total_alerts,
  SUM(CASE WHEN severity = 'critical' THEN 1 ELSE 0 END) AS critical_alerts,
  SUM(CASE WHEN severity = 'warning' THEN 1 ELSE 0 END) AS warning_alerts,
  ROUND(AVG(execution_time_ms))::INTEGER AS avg_execution_time_ms,
  SUM(CASE WHEN notified THEN 1 ELSE 0 END) AS notifications_sent
FROM slow_query_alerts
WHERE timestamp > NOW() - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', timestamp)
ORDER BY date DESC;

-- ============================================================================
-- AUTOMATIC DATA CLEANUP (OPTIONAL)
-- ============================================================================

-- Function to delete alerts older than 90 days
CREATE OR REPLACE FUNCTION cleanup_old_slow_query_alerts()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM slow_query_alerts
  WHERE timestamp < NOW() - INTERVAL '90 days';

  GET DIAGNOSTICS deleted_count = ROW_COUNT;

  RETURN deleted_count;
END;
$$;

-- Comment explaining the cleanup function
COMMENT ON FUNCTION cleanup_old_slow_query_alerts() IS
'Deletes slow query alerts older than 90 days to prevent unbounded table growth.
Run via pg_cron: SELECT cron.schedule(''cleanup-alerts'', ''0 3 * * *'', ''SELECT cleanup_old_slow_query_alerts()'');';

-- ============================================================================
-- ALERT NOTIFICATION FUNCTIONS
-- ============================================================================

-- Function to mark alert as notified
CREATE OR REPLACE FUNCTION mark_alert_notified(
  alert_id UUID,
  channels TEXT[]
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE slow_query_alerts
  SET
    notified = TRUE,
    notification_sent_at = NOW(),
    notification_channels = channels
  WHERE id = alert_id;
END;
$$;

COMMENT ON FUNCTION mark_alert_notified(UUID, TEXT[]) IS
'Mark an alert as notified with the notification channels used.
Example: SELECT mark_alert_notified(''uuid-here'', ARRAY[''slack'', ''email'']);';

-- Function to get unnotified alerts
CREATE OR REPLACE FUNCTION get_unnotified_alerts(
  severity_filter TEXT DEFAULT NULL,
  limit_count INTEGER DEFAULT 100
)
RETURNS TABLE (
  id UUID,
  alert_timestamp TIMESTAMPTZ,
  query_name TEXT,
  execution_time_ms INTEGER,
  severity TEXT,
  table_name TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.id,
    a.timestamp,
    a.query_name,
    a.execution_time_ms,
    a.severity,
    a.table_name
  FROM slow_query_alerts a
  WHERE
    a.notified = FALSE
    AND (severity_filter IS NULL OR a.severity = severity_filter)
  ORDER BY a.timestamp DESC
  LIMIT limit_count;
END;
$$;

COMMENT ON FUNCTION get_unnotified_alerts(TEXT, INTEGER) IS
'Get unnotified alerts, optionally filtered by severity.
Example: SELECT * FROM get_unnotified_alerts(''critical'', 50);';

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- After running this migration, verify with:
--
-- -- Check table created
-- SELECT tablename FROM pg_tables WHERE tablename = 'slow_query_alerts';
--
-- -- Check indexes created (should return 5)
-- SELECT COUNT(*) FROM pg_indexes
-- WHERE tablename = 'slow_query_alerts' AND indexname LIKE 'idx_%';
--
-- -- Check RLS policies (should return 3)
-- SELECT COUNT(*) FROM pg_policies WHERE tablename = 'slow_query_alerts';
--
-- -- Check views created (should return 3)
-- SELECT viewname FROM pg_views
-- WHERE viewname IN ('recent_critical_alerts', 'alert_summary_by_table', 'daily_alert_summary');
--
-- -- Test insert (should work with service role key)
-- INSERT INTO slow_query_alerts (query_name, execution_time_ms, severity)
-- VALUES ('test_query', 1500, 'warning');
--
-- -- Test view
-- SELECT * FROM recent_critical_alerts LIMIT 5;
--
-- -- Test function
-- SELECT * FROM get_unnotified_alerts('critical', 10);

-- ============================================================================
-- EXAMPLE USAGE
-- ============================================================================

-- Example 1: Insert a new alert
-- INSERT INTO slow_query_alerts (
--   query_name,
--   execution_time_ms,
--   severity,
--   table_name,
--   user_id
-- ) VALUES (
--   'fetch_client_data',
--   2500,
--   'critical',
--   'nps_clients',
--   auth.uid()
-- );

-- Example 2: Get all critical alerts from today
-- SELECT * FROM slow_query_alerts
-- WHERE severity = 'critical'
-- AND timestamp::DATE = CURRENT_DATE
-- ORDER BY execution_time_ms DESC;

-- Example 3: Mark alerts as notified
-- SELECT mark_alert_notified(
--   'uuid-here',
--   ARRAY['slack', 'email']
-- );

-- Example 4: Get alert statistics by table (last 7 days)
-- SELECT * FROM alert_summary_by_table;

-- Example 5: Daily alert trends
-- SELECT * FROM daily_alert_summary LIMIT 30;

-- ============================================================================
-- INTEGRATION WITH query_performance_logs
-- ============================================================================

-- View: Slow queries with alert status
CREATE OR REPLACE VIEW slow_queries_with_alerts AS
SELECT
  p.id AS performance_log_id,
  p.timestamp,
  p.query_name,
  p.execution_time_ms,
  p.table_name,
  p.slow_query,
  CASE
    WHEN a.id IS NOT NULL THEN TRUE
    ELSE FALSE
  END AS alert_created,
  a.severity AS alert_severity,
  a.notified AS alert_notified
FROM query_performance_logs p
LEFT JOIN slow_query_alerts a
  ON p.query_name = a.query_name
  AND p.timestamp = a.timestamp
WHERE p.slow_query = TRUE
ORDER BY p.timestamp DESC;

-- ============================================================================
-- MONITORING RECOMMENDATIONS
-- ============================================================================

-- 1. Set up automated alert processing:
--    - Run every 5 minutes to check for unnotified alerts
--    - Process critical alerts immediately
--    - Batch warning alerts to reduce noise

-- 2. Configure notification channels:
--    - Slack webhook for real-time alerts
--    - Email for daily summaries
--    - Console logging for development

-- 3. Monitor alert patterns:
--    - Track alerts by table to identify problematic queries
--    - Monitor alert frequency to tune thresholds
--    - Review notification success rate

-- 4. Cleanup schedule:
--    - Run cleanup_old_slow_query_alerts() daily at 3am
--    - Keep alerts for 90 days (adjust as needed)

-- ============================================================================
-- SUMMARY
-- ============================================================================

-- Tables Created: 1 (slow_query_alerts)
-- Indexes Created: 5
-- Views Created: 4 (including integration view)
-- Functions Created: 3
-- RLS Policies: 3
-- Impact: Enables complete slow query alerting system

-- Next Steps:
--   1. Deploy this migration
--   2. Configure notification channels (Slack webhook, email)
--   3. Integrate with performance monitoring system
--   4. Test alert notifications
--   5. Set up automated alert processing (Edge Function or cron)
