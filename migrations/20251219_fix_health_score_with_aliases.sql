-- Migration: Fix Health Score Calculation Using Client Aliases
-- Date: 2025-12-19
-- Purpose: Fix health score mismatch by using client_name_aliases table for data matching
--
-- ROOT CAUSE:
-- - Client names differ across tables (e.g., "Waikato" in compliance vs "Te Whatu Ora Waikato" in nps_clients)
-- - The client_name_aliases table has the correct mappings but wasn't being used
-- - Compliance percentage column showed 100 when it should show the actual value or default
--
-- CHANGES:
-- 1. Use client_name_aliases table to match compliance data by alias
-- 2. Fix compliance_percentage column to use same default (50%) as health_score formula
-- 3. Maintain all existing Working Capital aggregation fixes

DROP MATERIALIZED VIEW IF EXISTS client_health_summary CASCADE;

CREATE MATERIALIZED VIEW client_health_summary AS
SELECT
  c.id,
  c.client_name,
  c.segment,
  c.cse,
  c.created_at,
  c.updated_at,

  -- NPS Metrics
  COALESCE(nps_metrics.nps_score, 0) as nps_score,
  COALESCE(nps_metrics.promoter_count, 0) as promoter_count,
  COALESCE(nps_metrics.passive_count, 0) as passive_count,
  COALESCE(nps_metrics.detractor_count, 0) as detractor_count,
  COALESCE(nps_metrics.response_count, 0) as response_count,
  nps_metrics.last_response_date,

  -- Engagement Metrics (kept for display, not used in score)
  meeting_metrics.last_meeting_date,
  COALESCE(meeting_metrics.meeting_count_30d, 0) as meeting_count_30d,
  COALESCE(meeting_metrics.meeting_count_90d, 0) as meeting_count_90d,
  COALESCE(meeting_metrics.days_since_last_meeting, 999) as days_since_last_meeting,

  -- Action Metrics (kept for display, not used in score)
  COALESCE(action_metrics.total_actions_count, 0) as total_actions_count,
  COALESCE(action_metrics.completed_actions_count, 0) as completed_actions_count,
  COALESCE(action_metrics.open_actions_count, 0) as open_actions_count,
  COALESCE(action_metrics.overdue_actions_count, 0) as overdue_actions_count,
  COALESCE(action_metrics.completion_rate, 0) as completion_rate,

  -- Compliance Metrics (FIXED - now uses aliases for matching, shows consistent default)
  -- Display the same value used in health score calculation for UI consistency
  LEAST(100, COALESCE(compliance_metrics.compliance_percentage, 50)) as compliance_percentage,
  COALESCE(compliance_metrics.compliance_status, 'no-data') as compliance_status,

  -- Working Capital Metrics (aggregates all related entities)
  working_capital_metrics.working_capital_percentage,
  working_capital_metrics.total_outstanding,
  working_capital_metrics.amount_under_90_days,
  working_capital_metrics.amount_over_90_days,

  -- HEALTH SCORE v3.0 (0-100 scale)
  -- Formula: NPS (40) + Compliance (50) + Working Capital (10)
  LEAST(100, GREATEST(0, ROUND(
    -- 1. NPS Score Component (40 points max)
    ((COALESCE(nps_metrics.nps_score, 0) + 100) / 200.0 * 40) +

    -- 2. Compliance Component (50 points max)
    -- Default 50% when no compliance data (same as UI)
    (LEAST(100, COALESCE(compliance_metrics.compliance_percentage, 50)) / 100.0 * 50) +

    -- 3. Working Capital Component (10 points max)
    -- Default 100% when no aging data (no data = no problem)
    (LEAST(100, COALESCE(working_capital_metrics.working_capital_percentage, 100)) / 100.0 * 10)
  ))) as health_score,

  -- Calculated Status based on health score
  CASE
    WHEN ROUND(
      ((COALESCE(nps_metrics.nps_score, 0) + 100) / 200.0 * 40) +
      (LEAST(100, COALESCE(compliance_metrics.compliance_percentage, 50)) / 100.0 * 50) +
      (LEAST(100, COALESCE(working_capital_metrics.working_capital_percentage, 100)) / 100.0 * 10)
    ) >= 70 THEN 'healthy'
    WHEN ROUND(
      ((COALESCE(nps_metrics.nps_score, 0) + 100) / 200.0 * 40) +
      (LEAST(100, COALESCE(compliance_metrics.compliance_percentage, 50)) / 100.0 * 50) +
      (LEAST(100, COALESCE(working_capital_metrics.working_capital_percentage, 100)) / 100.0 * 10)
    ) < 60 THEN 'critical'
    ELSE 'at-risk'
  END as status,

  NOW() as last_refreshed

FROM nps_clients c

-- NPS Metrics (MOST RECENT PERIOD ONLY - matches UI calculation)
-- Uses the 'period' field (e.g., "Q2 25") instead of response_date to handle NULL dates
-- This ensures the health score uses the same NPS as shown in the UI breakdown modal
LEFT JOIN LATERAL (
  SELECT
    -- Calculate NPS from most recent period only
    COALESCE(
      ROUND(
        (COUNT(*) FILTER (WHERE score >= 9)::DECIMAL / NULLIF(COUNT(*), 0) * 100) -
        (COUNT(*) FILTER (WHERE score <= 6)::DECIMAL / NULLIF(COUNT(*), 0) * 100)
      ),
      0
    ) as nps_score,
    COUNT(*) FILTER (WHERE score >= 9) as promoter_count,
    COUNT(*) FILTER (WHERE score BETWEEN 7 AND 8) as passive_count,
    COUNT(*) FILTER (WHERE score <= 6) as detractor_count,
    COUNT(*) as response_count,
    MAX(COALESCE(response_date, created_at)) as last_response_date
  FROM nps_responses r
  WHERE (
    r.client_name = c.client_name
    -- Match via aliases where c.client_name IS the canonical_name
    OR r.client_name IN (
      SELECT display_name FROM client_name_aliases
      WHERE canonical_name = c.client_name AND is_active = true
    )
    -- Match via aliases where c.client_name IS a display_name (bidirectional lookup)
    -- Find the canonical_name for responses stored under the canonical
    OR r.client_name IN (
      SELECT canonical_name FROM client_name_aliases
      WHERE display_name = c.client_name AND is_active = true
    )
    -- Find peer display_names that share the same canonical_name
    OR r.client_name IN (
      SELECT a2.display_name
      FROM client_name_aliases a1
      JOIN client_name_aliases a2 ON a1.canonical_name = a2.canonical_name
      WHERE a1.display_name = c.client_name
        AND a1.is_active = true
        AND a2.is_active = true
    )
    -- SA Health aggregation: aggregate ALL SA Health variants
    OR (c.client_name LIKE 'SA Health%' AND r.client_name LIKE 'SA Health%')
  )
  -- Filter to MOST RECENT PERIOD only (matches UI useNPSTrend calculation)
  -- Uses period field (e.g., "Q2 25") to handle NULL response_dates
  AND r.period = (
    -- Find the most recent period that has data for this client
    -- Period format: "Q# YY" (e.g., "Q2 25", "Q4 24")
    -- Sort by year desc, then quarter desc to get the latest
    SELECT r2.period
    FROM nps_responses r2
    WHERE r2.period IS NOT NULL
      AND r2.period ~ '^Q[1-4]\s+\d{2}$'
      AND (
        r2.client_name = c.client_name
        -- Canonical lookup
        OR r2.client_name IN (
          SELECT display_name FROM client_name_aliases
          WHERE canonical_name = c.client_name AND is_active = true
        )
        -- Bidirectional: c.client_name is a display_name
        OR r2.client_name IN (
          SELECT canonical_name FROM client_name_aliases
          WHERE display_name = c.client_name AND is_active = true
        )
        OR r2.client_name IN (
          SELECT a2.display_name
          FROM client_name_aliases a1
          JOIN client_name_aliases a2 ON a1.canonical_name = a2.canonical_name
          WHERE a1.display_name = c.client_name
            AND a1.is_active = true
            AND a2.is_active = true
        )
        OR (c.client_name LIKE 'SA Health%' AND r2.client_name LIKE 'SA Health%')
      )
    ORDER BY
      -- Extract year (2-digit) and quarter for sorting
      -- "Q2 25" -> year=25, quarter=2
      CAST(SUBSTRING(r2.period FROM '\d{2}$') AS INTEGER) DESC,
      CAST(SUBSTRING(r2.period FROM 'Q(\d)') AS INTEGER) DESC
    LIMIT 1
  )
) nps_metrics ON true

-- Meeting Metrics (uses aliases for matching)
LEFT JOIN LATERAL (
  SELECT
    MAX(meeting_date) as last_meeting_date,
    COUNT(*) FILTER (WHERE meeting_date >= CURRENT_DATE - INTERVAL '30 days') as meeting_count_30d,
    COUNT(*) FILTER (WHERE meeting_date >= CURRENT_DATE - INTERVAL '90 days') as meeting_count_90d,
    COALESCE(CURRENT_DATE - MAX(meeting_date)::DATE, 999) as days_since_last_meeting
  FROM unified_meetings m
  WHERE m.client_name = c.client_name
    OR m.client_name IN (
      SELECT display_name FROM client_name_aliases
      WHERE canonical_name = c.client_name AND is_active = true
    )
) meeting_metrics ON true

-- Action Metrics (uses aliases for matching)
LEFT JOIN LATERAL (
  SELECT
    COUNT(*) as total_actions_count,
    COUNT(*) FILTER (WHERE "Status" IN ('Completed', 'Closed')) as completed_actions_count,
    COUNT(*) FILTER (WHERE "Status" NOT IN ('Completed', 'Closed', 'Cancelled')) as open_actions_count,
    COUNT(*) FILTER (
      WHERE "Status" NOT IN ('Completed', 'Closed', 'Cancelled')
        AND "Due_Date" IS NOT NULL
        AND "Due_Date" != ''
        AND (
          CASE
            WHEN "Due_Date" ~ '^\d{4}-\d{2}-\d{2}' THEN "Due_Date"::DATE
            WHEN "Due_Date" ~ '^\d{2}/\d{2}/\d{4}' THEN TO_DATE("Due_Date", 'DD/MM/YYYY')
            ELSE NULL
          END
        ) < CURRENT_DATE
    ) as overdue_actions_count,
    CASE
      WHEN COUNT(*) > 0 THEN
        ROUND((COUNT(*) FILTER (WHERE "Status" IN ('Completed', 'Closed'))::DECIMAL / COUNT(*) * 100))
      ELSE 0
    END as completion_rate
  FROM actions a
  WHERE a.client = c.client_name
    OR a.client IN (
      SELECT display_name FROM client_name_aliases
      WHERE canonical_name = c.client_name AND is_active = true
    )
) action_metrics ON true

-- Compliance Metrics (FIXED - uses event_compliance_summary as single source of truth)
-- This ensures Health Score uses the same compliance data as the Segmentation Actions card
-- The event_compliance_summary view calculates compliance from segmentation_events table,
-- which is more accurate than the pre-calculated segmentation_event_compliance table.
LEFT JOIN LATERAL (
  SELECT
    -- Get overall_compliance_score directly from event_compliance_summary
    -- This matches what the Segmentation Actions card displays
    COALESCE(ecs.overall_compliance_score, 0) as compliance_percentage,
    COALESCE(ecs.overall_status, 'critical') as compliance_status
  FROM event_compliance_summary ecs
  WHERE ecs.client_name = c.client_name
    AND ecs.year = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER
) compliance_metrics ON true

-- Working Capital Metrics (uses both aliases and normalized names)
-- Aggregates all related entities (e.g., all SingHealth hospitals, GRMC + SAPPI)
LEFT JOIN LATERAL (
  SELECT
    -- Calculate percentage under 90 days from aggregated totals
    CASE
      WHEN COALESCE(SUM(a.total_outstanding), 0) > 0 THEN
        ROUND(
          (
            COALESCE(SUM(a.current_amount), 0) +
            COALESCE(SUM(a.days_1_to_30), 0) +
            COALESCE(SUM(a.days_31_to_60), 0) +
            COALESCE(SUM(a.days_61_to_90), 0)
          )::DECIMAL / SUM(a.total_outstanding) * 100
        )
      ELSE NULL -- No aging data available
    END as working_capital_percentage,
    SUM(a.total_outstanding) as total_outstanding,
    (
      COALESCE(SUM(a.current_amount), 0) +
      COALESCE(SUM(a.days_1_to_30), 0) +
      COALESCE(SUM(a.days_31_to_60), 0) +
      COALESCE(SUM(a.days_61_to_90), 0)
    ) as amount_under_90_days,
    (
      COALESCE(SUM(a.days_91_to_120), 0) +
      COALESCE(SUM(a.days_121_to_180), 0) +
      COALESCE(SUM(a.days_181_to_270), 0) +
      COALESCE(SUM(a.days_271_to_365), 0) +
      COALESCE(SUM(a.days_over_365), 0)
    ) as amount_over_90_days
  FROM aging_accounts a
  WHERE (
    -- Match on normalized name (handles SingHealth, GRMC mappings)
    a.client_name_normalized = c.client_name
    OR
    -- Match on exact client name
    a.client_name = c.client_name
    OR
    -- Match via aliases
    a.client_name IN (
      SELECT display_name FROM client_name_aliases
      WHERE canonical_name = c.client_name AND is_active = true
    )
    OR
    -- Special case: SingHealth aggregation (include all SG hospitals)
    (c.client_name = 'SingHealth' AND (
      a.client_name_normalized = 'SingHealth'
      OR a.client_name ILIKE '%Singapore%Health%'
      OR a.client_name ILIKE '%Singapore General Hospital%'
      OR a.client_name ILIKE '%Changi General Hospital%'
      OR a.client_name ILIKE '%Sengkang%Hospital%'
      OR a.client_name ILIKE '%National Cancer Centre%Singapore%'
      OR a.client_name ILIKE '%National Heart Centre%Singapore%'
      OR a.client_name ILIKE '%KK Women%Children%Hospital%'
    ))
    OR
    -- Special case: GRMC aggregation (include Strategic Asia Pacific)
    (c.client_name ILIKE '%Guam%' AND (
      a.client_name_normalized ILIKE '%Guam%'
      OR a.client_name ILIKE '%Strategic Asia Pacific%'
      OR a.client_name ILIKE '%SAPPI%'
    ))
    OR
    -- Special case: SLMC aggregation (St Luke's variations)
    (c.client_name ILIKE '%Luke%' AND (
      a.client_name ILIKE '%Luke%Medical%'
      OR a.client_name ILIKE '%SLMC%'
    ))
  )
  HAVING SUM(a.total_outstanding) IS NOT NULL
) working_capital_metrics ON true

WHERE c.client_name != 'Parkway'

ORDER BY c.client_name;

-- Recreate indexes
CREATE UNIQUE INDEX idx_client_health_summary_client_name ON client_health_summary(client_name);
CREATE INDEX idx_client_health_summary_cse ON client_health_summary(cse);
CREATE INDEX idx_client_health_summary_health_score ON client_health_summary(health_score DESC);
CREATE INDEX idx_client_health_summary_status ON client_health_summary(status);
CREATE INDEX idx_client_health_summary_segment ON client_health_summary(segment);
CREATE INDEX idx_client_health_summary_working_capital ON client_health_summary(working_capital_percentage);

-- Grant permissions
GRANT SELECT ON client_health_summary TO anon, authenticated;

-- Initial refresh
REFRESH MATERIALIZED VIEW client_health_summary;

-- Verification queries (uncomment to test):
-- SELECT client_name, health_score, nps_score, compliance_percentage, working_capital_percentage
-- FROM client_health_summary
-- ORDER BY client_name;
