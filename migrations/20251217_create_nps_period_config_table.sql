-- Migration: Create nps_period_config table
-- Date: 2025-12-17
-- Purpose: Move period configuration from hardcoded SQL to database table
-- Replaces hardcoded period definitions in get_nps_summary() function

-- ============================================================================
-- 1. CREATE PERIOD CONFIGURATION TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS nps_period_config (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  period_code text NOT NULL UNIQUE,  -- e.g., 'Q4 25', 'Q2 25', '2023'
  period_name text NOT NULL,          -- e.g., 'Q4 FY25', 'Q2 FY25', 'FY23'
  fiscal_year text NOT NULL,          -- e.g., 'FY25', 'FY24', 'FY23'
  period_type text NOT NULL DEFAULT 'quarterly' CHECK (period_type IN ('quarterly', 'annual', 'half-yearly')),
  surveys_sent integer NOT NULL DEFAULT 0,
  survey_start_date date,
  survey_end_date date,
  sort_order integer NOT NULL DEFAULT 0,  -- For chronological ordering
  is_active boolean NOT NULL DEFAULT true,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes for common queries
CREATE INDEX IF NOT EXISTS idx_nps_period_config_period_code ON nps_period_config(period_code);
CREATE INDEX IF NOT EXISTS idx_nps_period_config_fiscal_year ON nps_period_config(fiscal_year);
CREATE INDEX IF NOT EXISTS idx_nps_period_config_sort_order ON nps_period_config(sort_order);
CREATE INDEX IF NOT EXISTS idx_nps_period_config_is_active ON nps_period_config(is_active);

-- Enable Row Level Security
ALTER TABLE nps_period_config ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Allow all select on nps_period_config"
  ON nps_period_config FOR SELECT USING (true);

CREATE POLICY "Allow all insert on nps_period_config"
  ON nps_period_config FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow all update on nps_period_config"
  ON nps_period_config FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Allow all delete on nps_period_config"
  ON nps_period_config FOR DELETE USING (true);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_nps_period_config_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_nps_period_config_updated_at
  BEFORE UPDATE ON nps_period_config
  FOR EACH ROW
  EXECUTE FUNCTION update_nps_period_config_updated_at();

-- Add comments
COMMENT ON TABLE nps_period_config IS 'Configuration for NPS survey periods, including surveys sent and fiscal year mappings';
COMMENT ON COLUMN nps_period_config.period_code IS 'Period identifier matching nps_responses.period (e.g., Q4 25, 2023)';
COMMENT ON COLUMN nps_period_config.surveys_sent IS 'Number of surveys sent during this period for response rate calculation';
COMMENT ON COLUMN nps_period_config.sort_order IS 'Chronological sort order (lower = older)';

-- ============================================================================
-- 2. SEED INITIAL PERIOD DATA
-- ============================================================================

-- Insert period configuration data (replaces hardcoded values from get_nps_summary)
INSERT INTO nps_period_config (period_code, period_name, fiscal_year, period_type, surveys_sent, survey_start_date, survey_end_date, sort_order, is_active, notes)
VALUES
  ('2023', 'FY23 Annual', 'FY23', 'annual', 50, '2022-07-01', '2023-06-30', 1, true, 'Legacy annual survey for FY23'),
  ('Q2 24', 'Q2 FY24', 'FY24', 'quarterly', 100, '2023-10-01', '2023-12-31', 2, true, 'Oct-Dec 2023 quarterly survey'),
  ('Q4 24', 'Q4 FY24', 'FY24', 'quarterly', 200, '2024-04-01', '2024-06-30', 3, true, 'Apr-Jun 2024 quarterly survey'),
  ('Q2 25', 'Q2 FY25', 'FY25', 'quarterly', 150, '2024-10-01', '2024-12-31', 4, true, 'Oct-Dec 2024 quarterly survey'),
  ('Q4 25', 'Q4 FY25', 'FY25', 'quarterly', 142, '2025-04-01', '2025-06-30', 5, true, 'Apr-Jun 2025 quarterly survey - current period')
ON CONFLICT (period_code) DO UPDATE SET
  period_name = EXCLUDED.period_name,
  fiscal_year = EXCLUDED.fiscal_year,
  period_type = EXCLUDED.period_type,
  surveys_sent = EXCLUDED.surveys_sent,
  survey_start_date = EXCLUDED.survey_start_date,
  survey_end_date = EXCLUDED.survey_end_date,
  sort_order = EXCLUDED.sort_order,
  is_active = EXCLUDED.is_active,
  notes = EXCLUDED.notes,
  updated_at = now();

-- ============================================================================
-- 3. UPDATE get_nps_summary FUNCTION TO USE TABLE
-- ============================================================================

-- Drop and recreate the function to use the new table
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

  -- Get surveys sent from nps_period_config table
  SELECT pc.surveys_sent INTO surveys_sent
  FROM nps_period_config pc
  WHERE pc.period_code = latest_period
    AND pc.is_active = true;

  -- Default to 0 if not found in config
  IF surveys_sent IS NULL THEN
    surveys_sent := 0;
  END IF;

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

COMMENT ON FUNCTION get_nps_summary IS 'Get overall NPS summary statistics including current score, previous period comparison, category percentages, and response rate. Uses nps_period_config table for surveys_sent. Pass NULL or omit parameter for latest period.';

-- ============================================================================
-- 4. UPDATE get_client_nps_scores FUNCTION TO USE TABLE
-- ============================================================================

-- Update function to use nps_period_config for period ordering
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
  -- Get period order from config table
  period_order AS (
    SELECT period_code, sort_order
    FROM nps_period_config
    WHERE is_active = true
  ),
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
  -- Calculate historical trend data using period_order from config
  historical_scores AS (
    SELECT
      normalized_name as client_name,
      nr.period,
      po.sort_order,
      calculate_nps(
        COUNT(*) FILTER (WHERE score >= 9),
        COUNT(*) FILTER (WHERE score BETWEEN 7 AND 8),
        COUNT(*) FILTER (WHERE score <= 6)
      ) as period_score
    FROM normalized_responses nr
    LEFT JOIN period_order po ON nr.period = po.period_code
    WHERE po.sort_order IS NOT NULL
    GROUP BY normalized_name, nr.period, po.sort_order
  ),
  -- Aggregate trend data into arrays (chronological order using config)
  trend_arrays AS (
    SELECT
      client_name,
      ARRAY_AGG(period_score ORDER BY sort_order ASC) as trend_data
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

COMMENT ON FUNCTION get_client_nps_scores IS 'Get per-client NPS scores with trends using nps_period_config for period ordering. Returns scores sorted by lowest first (most at-risk). Pass NULL or omit parameter for latest period.';

-- ============================================================================
-- 5. VERIFICATION QUERIES
-- ============================================================================

-- Verify the table was created with data:
-- SELECT * FROM nps_period_config ORDER BY sort_order;

-- Verify get_nps_summary still works:
-- SELECT * FROM get_nps_summary();

-- Verify get_client_nps_scores still works:
-- SELECT * FROM get_client_nps_scores() LIMIT 5;

-- ============================================================================
-- ROLLBACK INSTRUCTIONS
-- ============================================================================

-- To rollback:
-- DROP TABLE IF EXISTS nps_period_config CASCADE;
-- Then re-run the original 20251202_create_nps_aggregation_functions.sql migration
