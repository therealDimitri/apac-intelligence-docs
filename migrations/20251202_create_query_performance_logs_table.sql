-- Migration: Create Query Performance Logs Table
-- Date: 2025-12-02
-- Purpose: Enable query performance monitoring and slow query tracking
-- Impact: Foundation for Phase 4 performance monitoring dashboard
--
-- Features:
--   - Track all query execution times
--   - Cache hit/miss metrics
--   - Slow query detection (>500ms)
--   - Error tracking
--   - Per-table and per-user analytics
--
-- Deployment: Safe to run on production (no impact on existing tables)
-- Rollback: DROP TABLE query_performance_logs CASCADE;

-- ============================================================================
-- CREATE TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS query_performance_logs (
  -- Primary key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Timing
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  execution_time_ms INTEGER NOT NULL,
  slow_query BOOLEAN NOT NULL DEFAULT FALSE,

  -- Query metadata
  query_name TEXT NOT NULL,
  query_type TEXT NOT NULL CHECK (query_type IN ('SELECT', 'INSERT', 'UPDATE', 'DELETE', 'RPC')),
  table_name TEXT,
  query_params JSONB,

  -- Performance metrics
  cache_hit BOOLEAN NOT NULL DEFAULT FALSE,

  -- Error tracking
  error_occurred BOOLEAN NOT NULL DEFAULT FALSE,
  error_message TEXT,

  -- User context
  user_id UUID,

  -- Constraints
  CONSTRAINT positive_execution_time CHECK (execution_time_ms >= 0)
);

-- ============================================================================
-- INDEXES FOR QUERY PERFORMANCE
-- ============================================================================

-- Index 1: Time-based queries (most common - dashboard views)
-- Use case: Fetch metrics for specific time ranges
CREATE INDEX idx_performance_logs_timestamp
ON query_performance_logs(timestamp DESC);

-- Index 2: Slow query detection
-- Use case: Alert Centre - find all slow queries
CREATE INDEX idx_performance_logs_slow_queries
ON query_performance_logs(slow_query, timestamp DESC)
WHERE slow_query = TRUE;

-- Index 3: Per-table analytics
-- Use case: Dashboard - breakdown by table
CREATE INDEX idx_performance_logs_table_name
ON query_performance_logs(table_name, timestamp DESC)
WHERE table_name IS NOT NULL;

-- Index 4: Cache performance analysis
-- Use case: Dashboard - cache hit rate visualization
CREATE INDEX idx_performance_logs_cache_hit
ON query_performance_logs(cache_hit, timestamp DESC);

-- Index 5: Error tracking
-- Use case: Alert Centre - failed queries
CREATE INDEX idx_performance_logs_errors
ON query_performance_logs(error_occurred, timestamp DESC)
WHERE error_occurred = TRUE;

-- Index 6: Per-user query analysis
-- Use case: User activity monitoring
CREATE INDEX idx_performance_logs_user_id
ON query_performance_logs(user_id, timestamp DESC)
WHERE user_id IS NOT NULL;

-- Index 7: Query type breakdown
-- Use case: Dashboard - read vs write metrics
CREATE INDEX idx_performance_logs_query_type
ON query_performance_logs(query_type, timestamp DESC);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS
ALTER TABLE query_performance_logs ENABLE ROW LEVEL SECURITY;

-- Policy 1: Admins can view all logs
CREATE POLICY "Admins can view all performance logs"
  ON query_performance_logs
  FOR SELECT
  TO authenticated
  USING (
    -- Allow access if user is an admin
    -- Note: Replace with your actual admin check logic
    current_user IN (
      SELECT email FROM auth.users WHERE email LIKE '%@alteradigitalhealth.com'
    )
  );

-- Policy 2: Service role bypass (for automated logging)
CREATE POLICY "Service role full access"
  ON query_performance_logs
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Policy 3: Users can view their own query logs
CREATE POLICY "Users can view their own query logs"
  ON query_performance_logs
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- ============================================================================
-- AUTOMATIC DATA CLEANUP (OPTIONAL)
-- ============================================================================

-- Function to delete logs older than 30 days
-- Run this periodically via pg_cron or Supabase Edge Functions
CREATE OR REPLACE FUNCTION cleanup_old_performance_logs()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM query_performance_logs
  WHERE timestamp < NOW() - INTERVAL '30 days';

  GET DIAGNOSTICS deleted_count = ROW_COUNT;

  RETURN deleted_count;
END;
$$;

-- Comment explaining the cleanup function
COMMENT ON FUNCTION cleanup_old_performance_logs() IS
'Deletes performance logs older than 30 days to prevent unbounded table growth.
Run via pg_cron: SELECT cron.schedule(''cleanup-perf-logs'', ''0 2 * * *'', ''SELECT cleanup_old_performance_logs()'');';

-- ============================================================================
-- HELPFUL VIEWS
-- ============================================================================

-- View 1: Recent slow queries (last 24 hours)
CREATE OR REPLACE VIEW recent_slow_queries AS
SELECT
  id,
  timestamp,
  query_name,
  table_name,
  execution_time_ms,
  cache_hit,
  error_occurred
FROM query_performance_logs
WHERE
  slow_query = TRUE
  AND timestamp > NOW() - INTERVAL '24 hours'
ORDER BY execution_time_ms DESC;

-- View 2: Hourly performance summary
CREATE OR REPLACE VIEW hourly_performance_summary AS
SELECT
  DATE_TRUNC('hour', timestamp) AS hour,
  COUNT(*) AS total_queries,
  ROUND(AVG(execution_time_ms))::INTEGER AS avg_execution_time_ms,
  ROUND(100.0 * SUM(CASE WHEN cache_hit THEN 1 ELSE 0 END) / COUNT(*))::INTEGER AS cache_hit_rate_pct,
  SUM(CASE WHEN slow_query THEN 1 ELSE 0 END) AS slow_query_count,
  SUM(CASE WHEN error_occurred THEN 1 ELSE 0 END) AS error_count
FROM query_performance_logs
WHERE timestamp > NOW() - INTERVAL '7 days'
GROUP BY DATE_TRUNC('hour', timestamp)
ORDER BY hour DESC;

-- View 3: Per-table performance summary
CREATE OR REPLACE VIEW table_performance_summary AS
SELECT
  table_name,
  COUNT(*) AS total_queries,
  ROUND(AVG(execution_time_ms))::INTEGER AS avg_execution_time_ms,
  MAX(execution_time_ms) AS max_execution_time_ms,
  ROUND(100.0 * SUM(CASE WHEN cache_hit THEN 1 ELSE 0 END) / COUNT(*))::INTEGER AS cache_hit_rate_pct,
  SUM(CASE WHEN slow_query THEN 1 ELSE 0 END) AS slow_query_count
FROM query_performance_logs
WHERE
  table_name IS NOT NULL
  AND timestamp > NOW() - INTERVAL '24 hours'
GROUP BY table_name
ORDER BY total_queries DESC;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- After running this migration, verify with:
--
-- -- Check table created
-- SELECT tablename, tableowner FROM pg_tables WHERE tablename = 'query_performance_logs';
--
-- -- Check indexes created
-- SELECT indexname, indexdef FROM pg_indexes
-- WHERE tablename = 'query_performance_logs'
-- ORDER BY indexname;
--
-- -- Check RLS policies
-- SELECT policyname, cmd, qual FROM pg_policies
-- WHERE tablename = 'query_performance_logs';
--
-- -- Check views created
-- SELECT viewname FROM pg_views
-- WHERE viewname IN ('recent_slow_queries', 'hourly_performance_summary', 'table_performance_summary');
--
-- -- Test insert (should work with service role key)
-- INSERT INTO query_performance_logs (query_name, query_type, execution_time_ms)
-- VALUES ('test_query', 'SELECT', 100);
--
-- -- Test recent_slow_queries view
-- SELECT * FROM recent_slow_queries LIMIT 5;
--
-- -- Test hourly_performance_summary view
-- SELECT * FROM hourly_performance_summary LIMIT 24;
--
-- -- Test table_performance_summary view
-- SELECT * FROM table_performance_summary;

-- ============================================================================
-- EXAMPLE USAGE
-- ============================================================================

-- Example 1: Find slowest queries in the last hour
-- SELECT query_name, table_name, execution_time_ms, timestamp
-- FROM query_performance_logs
-- WHERE timestamp > NOW() - INTERVAL '1 hour'
-- ORDER BY execution_time_ms DESC
-- LIMIT 10;

-- Example 2: Calculate cache hit rate by table (last 24 hours)
-- SELECT
--   table_name,
--   COUNT(*) AS total_queries,
--   SUM(CASE WHEN cache_hit THEN 1 ELSE 0 END) AS cache_hits,
--   ROUND(100.0 * SUM(CASE WHEN cache_hit THEN 1 ELSE 0 END) / COUNT(*), 2) AS cache_hit_rate
-- FROM query_performance_logs
-- WHERE timestamp > NOW() - INTERVAL '24 hours' AND table_name IS NOT NULL
-- GROUP BY table_name
-- ORDER BY total_queries DESC;

-- Example 3: Queries with errors in the last hour
-- SELECT query_name, error_message, timestamp
-- FROM query_performance_logs
-- WHERE error_occurred = TRUE AND timestamp > NOW() - INTERVAL '1 hour'
-- ORDER BY timestamp DESC;

-- Example 4: Average execution time by query type (last 24 hours)
-- SELECT
--   query_type,
--   COUNT(*) AS count,
--   ROUND(AVG(execution_time_ms))::INTEGER AS avg_time_ms,
--   MAX(execution_time_ms) AS max_time_ms
-- FROM query_performance_logs
-- WHERE timestamp > NOW() - INTERVAL '24 hours'
-- GROUP BY query_type
-- ORDER BY count DESC;

-- ============================================================================
-- MONITORING RECOMMENDATIONS
-- ============================================================================

-- 1. Set up alerts for slow queries:
--    - Threshold: execution_time_ms > 1000ms
--    - Frequency: Check every 5 minutes
--    - Action: Notify via Slack/Email

-- 2. Monitor cache hit rate:
--    - Target: >80% cache hit rate
--    - Alert if: cache_hit_rate < 70% for >1 hour

-- 3. Track query errors:
--    - Alert on: ANY error_occurred = TRUE
--    - Immediate notification for production errors

-- 4. Cleanup schedule:
--    - Run cleanup_old_performance_logs() daily at 2am
--    - Keep logs for 30 days (adjust as needed)

-- 5. Dashboard metrics:
--    - Total queries (last hour/day/week)
--    - Average execution time
--    - Cache hit rate
--    - Slow query count
--    - Top 10 slowest queries
--    - Queries by table
--    - Error rate

-- ============================================================================
-- NOTES
-- ============================================================================

-- Storage Considerations:
-- - Each log entry is ~500 bytes
-- - 10,000 queries/day = ~5 MB/day
-- - 30 days retention = ~150 MB
-- - For high-volume applications, consider:
--   1. Shorter retention (7-14 days)
--   2. Sampling (log 10% of fast queries, 100% of slow queries)
--   3. Aggregation (store hourly summaries instead of individual logs)

-- Performance Impact:
-- - Async inserts have minimal impact (<1ms overhead)
-- - Indexes ensure fast dashboard queries
-- - RLS policies are efficient (index-backed)

-- Privacy:
-- - query_params may contain sensitive data
-- - Consider redacting PII before logging
-- - user_id helps track individual performance but may not be needed
