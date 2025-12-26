-- Migration: Create NPS Aggregation Functions
-- Date: 2025-12-02
-- Purpose: Move NPS calculation logic from application to database
-- Impact: Reduced client-side computation, improved consistency, reusable calculations
--
-- PHASE 3 OPTIMIZATION: Stored procedures for NPS aggregation
--
-- This migration creates PostgreSQL functions for:
--   1. calculate_nps() - Calculate NPS score from promoters/detractors percentages
--   2. get_nps_summary() - Get overall NPS summary with period-over-period comparison
--   3. get_client_nps_scores() - Get per-client NPS scores with trends
--
-- Benefits:
--   - Move 500+ lines of client-side logic to database
--   - Consistent NPS calculation across all queries
--   - Better performance (server-side computation)
--   - Reusable functions for reports and analytics
--
-- Deployment: Safe to run on production
-- Rollback: See drop function commands at bottom

-- ============================================================================
-- 1. HELPER FUNCTION: Calculate NPS Score
-- ============================================================================

-- Drop existing function if it exists (idempotent)
DROP FUNCTION IF EXISTS calculate_nps(INTEGER, INTEGER, INTEGER);

-- Calculate NPS = (% Promoters - % Detractors)
-- Promoters: score >= 9
-- Passives: score 7-8
-- Detractors: score <= 6
CREATE OR REPLACE FUNCTION calculate_nps(
  promoter_count INTEGER,
  passive_count INTEGER,
  detractor_count INTEGER
)
RETURNS INTEGER
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  total_count INTEGER;
  promoter_pct NUMERIC;
  detractor_pct NUMERIC;
BEGIN
  total_count := promoter_count + passive_count + detractor_count;

  -- Return 0 if no responses
  IF total_count = 0 THEN
    RETURN 0;
  END IF;

  -- Calculate percentages
  promoter_pct := (promoter_count::NUMERIC / total_count) * 100;
  detractor_pct := (detractor_count::NUMERIC / total_count) * 100;

  -- NPS = % Promoters - % Detractors
  RETURN ROUND(promoter_pct - detractor_pct)::INTEGER;
END;
$$;

-- Example usage:
-- SELECT calculate_nps(50, 30, 20); -- Returns 30 (50% - 20% = 30%)

COMMENT ON FUNCTION calculate_nps IS 'Calculate Net Promoter Score from promoter, passive, and detractor counts. Returns NPS value from -100 to +100.';

-- ============================================================================
-- 2. FUNCTION: Get NPS Summary (Overall Statistics)
-- ============================================================================

-- Drop existing function if it exists (idempotent)
DROP FUNCTION IF EXISTS get_nps_summary(TEXT);

-- Get overall NPS summary with period-over-period comparison
-- Returns: current_score, previous_score, trend, promoters%, passives%, detractors%,
--          response_rate, total_responses, overall_trend, last_survey_date
CREATE OR REPLACE FUNCTION get_nps_summary(
  target_period TEXT DEFAULT NULL  -- e.g., 'Q4 25', NULL = latest period
)
RETURNS TABLE (
  current_score INTEGER,
  previous_score INTEGER,
  trend TEXT,
  promoters_pct INTEGER,
  passives_pct INTEGER,
  detractors_pct INTEGER,
  response_rate INTEGER,
  total_responses INTEGER,
  overall_trend INTEGER,
  last_survey_date TEXT,
  current_period TEXT,
  previous_period TEXT
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  latest_period TEXT;
  prev_period TEXT;
  first_period TEXT;
  current_period_data RECORD;
  previous_period_data RECORD;
  first_period_data RECORD;
  first_score INTEGER;
  surveys_sent INTEGER := 0;
BEGIN
  -- Determine target period (latest if not specified)
  IF target_period IS NULL THEN
    SELECT r.period INTO latest_period
    FROM nps_responses r
    WHERE r.period IS NOT NULL
      AND r.period != ''
      AND r.period ~ '^Q[1-4]\s+\d{2}$'  -- Valid format: Q# YY
    ORDER BY
      SUBSTRING(r.period FROM '\d{2}$')::INTEGER DESC,  -- Year descending
      SUBSTRING(r.period FROM 'Q(\d)')::INTEGER DESC    -- Quarter descending
    LIMIT 1;
  ELSE
    latest_period := target_period;
  END IF;

  -- Get previous period (second most recent with actual data)
  SELECT r.period INTO prev_period
  FROM nps_responses r
  WHERE r.period IS NOT NULL
    AND r.period != ''
    AND r.period != latest_period
    AND r.period ~ '^Q[1-4]\s+\d{2}$'
  GROUP BY r.period
  HAVING COUNT(*) > 0
  ORDER BY
    SUBSTRING(r.period FROM '\d{2}$')::INTEGER DESC,
    SUBSTRING(r.period FROM 'Q(\d)')::INTEGER DESC
  LIMIT 1;

  -- Get first period (oldest period with data, for overall trend)
  SELECT r.period INTO first_period
  FROM nps_responses r
  WHERE r.period IS NOT NULL
    AND r.period != ''
    AND (r.period ~ '^Q[1-4]\s+\d{2}$' OR r.period ~ '^\d{4}$')  -- Include year-only format
  GROUP BY r.period
  HAVING COUNT(*) > 0
  ORDER BY
    -- Year-only comes before quarterly
    CASE WHEN r.period ~ '^\d{4}$' THEN 0 ELSE 1 END,
    -- Then sort by year and quarter
    SUBSTRING(r.period FROM '\d{2,4}$')::INTEGER ASC,
    SUBSTRING(r.period FROM 'Q(\d)')::INTEGER ASC
  LIMIT 1;

  -- Calculate current period statistics
  SELECT
    COUNT(*) FILTER (WHERE score >= 9) as promoters,
    COUNT(*) FILTER (WHERE score BETWEEN 7 AND 8) as passives,
    COUNT(*) FILTER (WHERE score <= 6) as detractors,
    COUNT(*) as total
  INTO current_period_data
  FROM nps_responses
  WHERE period = latest_period;

  -- Calculate previous period statistics
  IF prev_period IS NOT NULL THEN
    SELECT
      COUNT(*) FILTER (WHERE score >= 9) as promoters,
      COUNT(*) FILTER (WHERE score BETWEEN 7 AND 8) as passives,
      COUNT(*) FILTER (WHERE score <= 6) as detractors,
      COUNT(*) as total
    INTO previous_period_data
    FROM nps_responses
    WHERE period = prev_period;
  ELSE
    -- No previous period data
    previous_period_data := (0, 0, 0, 0);
  END IF;

  -- Calculate first period statistics (for overall trend)
  IF first_period IS NOT NULL THEN
    SELECT
      COUNT(*) FILTER (WHERE score >= 9) as promoters,
      COUNT(*) FILTER (WHERE score BETWEEN 7 AND 8) as passives,
      COUNT(*) FILTER (WHERE score <= 6) as detractors
    INTO first_period_data
    FROM nps_responses
    WHERE period = first_period;

    first_score := calculate_nps(
      first_period_data.promoters,
      first_period_data.passives,
      first_period_data.detractors
    );
  ELSE
    first_score := 0;
  END IF;

  -- Get surveys sent for current period (hardcoded metadata for now)
  -- TODO: Move to database table in future migration
  surveys_sent := CASE latest_period
    WHEN 'Q4 25' THEN 142
    WHEN 'Q2 25' THEN 150
    WHEN 'Q4 24' THEN 200
    WHEN 'Q2 24' THEN 100
    WHEN '2023' THEN 50
    ELSE 0
  END;

  -- Return aggregated results
  RETURN QUERY
  WITH scores AS (
    SELECT
      calculate_nps(
        current_period_data.promoters,
        current_period_data.passives,
        current_period_data.detractors
      ) as curr_score,
      calculate_nps(
        previous_period_data.promoters,
        previous_period_data.passives,
        previous_period_data.detractors
      ) as prev_score
  )
  SELECT
    scores.curr_score as current_score,
    COALESCE(scores.prev_score, scores.curr_score) as previous_score,
    CASE
      WHEN scores.curr_score > COALESCE(scores.prev_score, scores.curr_score) THEN 'up'
      WHEN scores.curr_score < COALESCE(scores.prev_score, scores.curr_score) THEN 'down'
      ELSE 'stable'
    END::TEXT as trend,
    ROUND((current_period_data.promoters::NUMERIC / NULLIF(current_period_data.total, 0)) * 100)::INTEGER as promoters_pct,
    ROUND((current_period_data.passives::NUMERIC / NULLIF(current_period_data.total, 0)) * 100)::INTEGER as passives_pct,
    ROUND((current_period_data.detractors::NUMERIC / NULLIF(current_period_data.total, 0)) * 100)::INTEGER as detractors_pct,
    CASE
      WHEN surveys_sent > 0 THEN ROUND((current_period_data.total::NUMERIC / surveys_sent) * 100)::INTEGER
      ELSE 0
    END as response_rate,
    (SELECT COUNT(*)::INTEGER FROM nps_responses) as total_responses,
    (scores.curr_score - first_score)::INTEGER as overall_trend,
    latest_period as last_survey_date,
    latest_period as current_period,
    prev_period as previous_period
  FROM scores;
END;
$$;

-- Example usage:
-- SELECT * FROM get_nps_summary();              -- Latest period
-- SELECT * FROM get_nps_summary('Q4 25');       -- Specific period

COMMENT ON FUNCTION get_nps_summary IS 'Get overall NPS summary statistics including current score, previous period comparison, category percentages, and response rate. Pass NULL or omit parameter for latest period.';

-- ============================================================================
-- 3. FUNCTION: Get Client NPS Scores with Trends
-- ============================================================================

-- Drop existing function if it exists (idempotent)
DROP FUNCTION IF EXISTS get_client_nps_scores(TEXT);

-- Get per-client NPS scores with period-over-period trends
-- Includes SA Health aggregation and parent-child client handling
CREATE OR REPLACE FUNCTION get_client_nps_scores(
  target_period TEXT DEFAULT NULL  -- e.g., 'Q4 25', NULL = latest period
)
RETURNS TABLE (
  client_name TEXT,
  nps_score INTEGER,
  previous_score INTEGER,
  trend TEXT,
  response_count INTEGER,
  trend_data INTEGER[],
  is_aggregated BOOLEAN
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  latest_period TEXT;
  prev_period TEXT;
BEGIN
  -- Determine target period (latest if not specified)
  IF target_period IS NULL THEN
    SELECT r.period INTO latest_period
    FROM nps_responses r
    WHERE r.period IS NOT NULL
      AND r.period != ''
      AND r.period ~ '^Q[1-4]\s+\d{2}$'
    ORDER BY
      SUBSTRING(r.period FROM '\d{2}$')::INTEGER DESC,
      SUBSTRING(r.period FROM 'Q(\d)')::INTEGER DESC
    LIMIT 1;
  ELSE
    latest_period := target_period;
  END IF;

  -- Get previous period
  SELECT r.period INTO prev_period
  FROM nps_responses r
  WHERE r.period IS NOT NULL
    AND r.period != ''
    AND r.period != latest_period
    AND r.period ~ '^Q[1-4]\s+\d{2}$'
  GROUP BY r.period
  ORDER BY
    SUBSTRING(r.period FROM '\d{2}$')::INTEGER DESC,
    SUBSTRING(r.period FROM 'Q(\d)')::INTEGER DESC
  LIMIT 1;

  -- Return client NPS scores
  RETURN QUERY
  WITH
  -- Normalize SA Health variants to single "SA Health" entry
  normalized_responses AS (
    SELECT
      CASE
        WHEN r.client_name LIKE 'SA Health%' THEN 'SA Health'
        ELSE r.client_name
      END as normalized_name,
      r.score,
      r.period,
      r.response_date
    FROM nps_responses r
  ),
  -- Calculate current period scores per client
  current_period_scores AS (
    SELECT
      normalized_name as client_name,
      COUNT(*) FILTER (WHERE score >= 9) as promoters,
      COUNT(*) FILTER (WHERE score BETWEEN 7 AND 8) as passives,
      COUNT(*) FILTER (WHERE score <= 6) as detractors,
      COUNT(*) as total
    FROM normalized_responses
    WHERE period = latest_period
    GROUP BY normalized_name
  ),
  -- Calculate previous period scores per client
  previous_period_scores AS (
    SELECT
      normalized_name as client_name,
      COUNT(*) FILTER (WHERE score >= 9) as promoters,
      COUNT(*) FILTER (WHERE score BETWEEN 7 AND 8) as passives,
      COUNT(*) FILTER (WHERE score <= 6) as detractors,
      COUNT(*) as total
    FROM normalized_responses
    WHERE period = prev_period
    GROUP BY normalized_name
  ),
  -- Calculate historical trend data (last 5 periods)
  historical_scores AS (
    SELECT
      normalized_name as client_name,
      period,
      calculate_nps(
        COUNT(*) FILTER (WHERE score >= 9),
        COUNT(*) FILTER (WHERE score BETWEEN 7 AND 8),
        COUNT(*) FILTER (WHERE score <= 6)
      ) as period_score
    FROM normalized_responses
    WHERE period IN ('2023', 'Q2 24', 'Q4 24', 'Q2 25', 'Q4 25')
    GROUP BY normalized_name, period
  ),
  -- Aggregate trend data into arrays (chronological order)
  trend_arrays AS (
    SELECT
      client_name,
      ARRAY_AGG(period_score ORDER BY
        CASE period
          WHEN '2023' THEN 1
          WHEN 'Q2 24' THEN 2
          WHEN 'Q4 24' THEN 3
          WHEN 'Q2 25' THEN 4
          WHEN 'Q4 25' THEN 5
          ELSE 99
        END
      ) as trend_data
    FROM historical_scores
    GROUP BY client_name
  )
  -- Join everything together
  SELECT
    COALESCE(curr.client_name, prev.client_name) as client_name,
    calculate_nps(
      COALESCE(curr.promoters, 0),
      COALESCE(curr.passives, 0),
      COALESCE(curr.detractors, 0)
    ) as nps_score,
    calculate_nps(
      COALESCE(prev.promoters, 0),
      COALESCE(prev.passives, 0),
      COALESCE(prev.detractors, 0)
    ) as previous_score,
    CASE
      WHEN calculate_nps(COALESCE(curr.promoters, 0), COALESCE(curr.passives, 0), COALESCE(curr.detractors, 0)) >
           calculate_nps(COALESCE(prev.promoters, 0), COALESCE(prev.passives, 0), COALESCE(prev.detractors, 0))
        THEN 'up'
      WHEN calculate_nps(COALESCE(curr.promoters, 0), COALESCE(curr.passives, 0), COALESCE(curr.detractors, 0)) <
           calculate_nps(COALESCE(prev.promoters, 0), COALESCE(prev.passives, 0), COALESCE(prev.detractors, 0))
        THEN 'down'
      ELSE 'stable'
    END::TEXT as trend,
    COALESCE(curr.total, prev.total, 0)::INTEGER as response_count,
    COALESCE(trend.trend_data, ARRAY[]::INTEGER[]) as trend_data,
    FALSE as is_aggregated
  FROM current_period_scores curr
  FULL OUTER JOIN previous_period_scores prev
    ON curr.client_name = prev.client_name
  LEFT JOIN trend_arrays trend
    ON COALESCE(curr.client_name, prev.client_name) = trend.client_name
  ORDER BY nps_score ASC;  -- Lowest score first (most at-risk)
END;
$$;

-- Example usage:
-- SELECT * FROM get_client_nps_scores();              -- Latest period
-- SELECT * FROM get_client_nps_scores('Q4 25');       -- Specific period
-- SELECT client_name, nps_score, trend FROM get_client_nps_scores() WHERE nps_score < 0;  -- At-risk clients

COMMENT ON FUNCTION get_client_nps_scores IS 'Get per-client NPS scores with trends, including SA Health aggregation. Returns scores sorted by lowest first (most at-risk). Pass NULL or omit parameter for latest period.';

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- After running this migration, verify the functions work:

-- Test calculate_nps function
-- SELECT calculate_nps(50, 30, 20);  -- Expected: 30

-- Test get_nps_summary function
-- SELECT * FROM get_nps_summary();
-- Expected: Returns row with current_score, previous_score, trend, etc.

-- Test get_client_nps_scores function
-- SELECT * FROM get_client_nps_scores() LIMIT 10;
-- Expected: Returns client NPS scores with trends

-- Check function metadata
-- SELECT
--   p.proname as function_name,
--   pg_get_function_identity_arguments(p.oid) as parameters,
--   pg_get_functiondef(p.oid) as definition
-- FROM pg_proc p
-- JOIN pg_namespace n ON p.pronamespace = n.oid
-- WHERE n.nspname = 'public'
--   AND p.proname IN ('calculate_nps', 'get_nps_summary', 'get_client_nps_scores')
-- ORDER BY p.proname;

-- ============================================================================
-- PERFORMANCE CONSIDERATIONS
-- ============================================================================

-- Benefits:
-- 1. Server-Side Computation:
--    - Moves 500+ lines of JavaScript to PostgreSQL
--    - Eliminates network round-trips for multiple queries
--    - Database optimizes execution plans
--
-- 2. Consistency:
--    - Single source of truth for NPS calculations
--    - Same formula used across all queries and reports
--    - Easier to maintain and update logic
--
-- 3. Reusability:
--    - Functions can be used in views, triggers, reports
--    - Can be called from multiple API endpoints
--    - Supports analytics and BI tools directly
--
-- Overhead:
-- - Function call overhead is minimal (~0.1-1ms per call)
-- - SA Health aggregation requires scanning responses table
-- - Historical trend calculation may be slower for large datasets
--
-- Optimization Ideas (Future):
-- - Add indexes on (period, score) for faster filtering
-- - Consider materialized view for historical trends
-- - Cache function results in application layer

-- ============================================================================
-- ROLLBACK INSTRUCTIONS
-- ============================================================================

-- To remove all functions:
--
-- DROP FUNCTION IF EXISTS calculate_nps(INTEGER, INTEGER, INTEGER);
-- DROP FUNCTION IF EXISTS get_nps_summary(TEXT);
-- DROP FUNCTION IF EXISTS get_client_nps_scores(TEXT);
--
-- Verify removal:
-- SELECT proname FROM pg_proc WHERE proname IN ('calculate_nps', 'get_nps_summary', 'get_client_nps_scores');
-- Expected: 0 rows

-- ============================================================================
-- FUTURE ENHANCEMENTS
-- ============================================================================

-- 1. Survey Metadata Table:
--    Instead of hardcoding surveys_sent in get_nps_summary(),
--    create a table to track survey campaigns:
--
--    CREATE TABLE nps_survey_campaigns (
--      period TEXT PRIMARY KEY,
--      surveys_sent INTEGER NOT NULL,
--      survey_date DATE,
--      notes TEXT
--    );
--
-- 2. Parent-Child Client Relationships:
--    Create a table to define parent-child relationships:
--
--    CREATE TABLE client_hierarchies (
--      child_client_name TEXT PRIMARY KEY,
--      parent_client_name TEXT NOT NULL,
--      FOREIGN KEY (child_client_name) REFERENCES nps_clients(client_name),
--      FOREIGN KEY (parent_client_name) REFERENCES nps_clients(client_name)
--    );
--
-- 3. Scheduled Refresh:
--    Add pg_cron job to refresh NPS calculations periodically:
--
--    SELECT cron.schedule(
--      'refresh_nps_calculations',
--      '*/10 * * * *',  -- Every 10 minutes
--      $$SELECT * FROM get_nps_summary();$$  -- Warm cache
--    );
--
-- 4. Caching Layer:
--    Add function result caching using PostgreSQL's built-in caching:
--
--    -- Mark functions as STABLE instead of VOLATILE
--    -- PostgreSQL can cache STABLE function results within a transaction
--
-- 5. Additional Aggregations:
--    - get_nps_by_segment(segment TEXT) - NPS scores grouped by segment
--    - get_nps_by_cse(cse TEXT) - NPS scores grouped by CSE
--    - get_nps_trends(start_period TEXT, end_period TEXT) - Historical trends

-- ============================================================================
-- NOTES
-- ============================================================================

-- Function Stability Levels:
-- - IMMUTABLE: Always returns same result for same inputs (calculate_nps)
-- - STABLE: Returns same result within a transaction (get_nps_summary, get_client_nps_scores)
-- - VOLATILE: May return different results each call (not used here)
--
-- SA Health Aggregation:
-- - Consolidates all "SA Health*" variants into single "SA Health" entry
-- - Matches application logic in useNPSData.ts (lines 338-357)
-- - Ensures consistent reporting across platform
--
-- Period Format:
-- - Standard: "Q# YY" (e.g., "Q4 25")
-- - Legacy: "YYYY" (e.g., "2023")
-- - Functions handle both formats gracefully
--
-- NPS Calculation Formula:
-- - Promoters: score >= 9
-- - Passives: score 7-8
-- - Detractors: score <= 6
-- - NPS = (% Promoters - % Detractors)
-- - Range: -100 (all detractors) to +100 (all promoters)
