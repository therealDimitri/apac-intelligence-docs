-- Migration: Fix Aging Accounts Client Name Matching
-- Date: 2025-12-19
-- Purpose: Fix the join between client_health_summary and aging_accounts
--
-- ISSUE: The materialized view was joining on client_name but aging_accounts
--        uses different names (e.g., 'Singapore Health Services Pte Ltd' vs 'SingHealth')
--        and stores the normalized name in client_name_normalized
--
-- CHANGES:
-- 1. Join on client_name_normalized instead of client_name
-- 2. Aggregate all related entities (e.g., all SingHealth hospitals)
-- 3. Include subsidiaries that are marked as inactive but have outstanding balances

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

  -- Compliance Metrics (capped at 100%)
  LEAST(100, compliance_metrics.compliance_percentage) as compliance_percentage,
  compliance_metrics.compliance_status,

  -- Working Capital Metrics (FIXED - now aggregates all related entities)
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
    (LEAST(100, COALESCE(compliance_metrics.compliance_percentage, 50)) / 100.0 * 50) +

    -- 3. Working Capital Component (10 points max)
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

-- NPS Metrics
LEFT JOIN LATERAL (
  SELECT
    ROUND(
      (COUNT(*) FILTER (WHERE score >= 9)::DECIMAL / NULLIF(COUNT(*), 0) * 100) -
      (COUNT(*) FILTER (WHERE score <= 6)::DECIMAL / NULLIF(COUNT(*), 0) * 100)
    ) as nps_score,
    COUNT(*) FILTER (WHERE score >= 9) as promoter_count,
    COUNT(*) FILTER (WHERE score BETWEEN 7 AND 8) as passive_count,
    COUNT(*) FILTER (WHERE score <= 6) as detractor_count,
    COUNT(*) as response_count,
    MAX(response_date) as last_response_date
  FROM nps_responses r
  WHERE r.client_name = c.client_name
) nps_metrics ON true

-- Meeting Metrics
LEFT JOIN LATERAL (
  SELECT
    MAX(meeting_date) as last_meeting_date,
    COUNT(*) FILTER (WHERE meeting_date >= CURRENT_DATE - INTERVAL '30 days') as meeting_count_30d,
    COUNT(*) FILTER (WHERE meeting_date >= CURRENT_DATE - INTERVAL '90 days') as meeting_count_90d,
    COALESCE(CURRENT_DATE - MAX(meeting_date)::DATE, 999) as days_since_last_meeting
  FROM unified_meetings m
  WHERE m.client_name = c.client_name
) meeting_metrics ON true

-- Action Metrics
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
) action_metrics ON true

-- Compliance Metrics
LEFT JOIN LATERAL (
  SELECT
    AVG(compliance_percentage) as compliance_percentage,
    CASE
      WHEN AVG(compliance_percentage) >= 90 THEN 'compliant'
      WHEN AVG(compliance_percentage) >= 70 THEN 'warning'
      ELSE 'non-compliant'
    END as compliance_status
  FROM segmentation_event_compliance ec
  WHERE ec.client_name = c.client_name
    AND ec.year = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER
) compliance_metrics ON true

-- Working Capital Metrics (FIXED)
-- Now joins on client_name_normalized and aggregates ALL related entities
-- This ensures SingHealth includes all its hospitals, GRMC includes Strategic Asia Pacific, etc.
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
    -- Also match on exact client name for clients without mappings
    a.client_name = c.client_name
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
  -- Note: We no longer filter by is_inactive to include subsidiary hospitals
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

-- Verify the update
-- SELECT client_name, health_score, working_capital_percentage, total_outstanding
-- FROM client_health_summary
-- WHERE client_name IN ('SingHealth', 'Guam Regional Medical City (GRMC)')
-- ORDER BY client_name;
