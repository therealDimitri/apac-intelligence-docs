-- Migration: Fix Compliance Join Using Client Aliases
-- Date: 2026-01-10
-- Description: Updates the client_health_summary materialized view to use
--              client_name_aliases table when joining to segmentation_event_compliance
--
-- Problem: The segmentation_event_compliance table uses different client names
--          (e.g., "Albury Wodonga") than the clients table (e.g., "Albury Wodonga Health")
--          This was causing all compliance_percentage values to default to 50%
--
-- Solution: Use the client_name_aliases table to resolve display names to canonical names

-- ============================================================================
-- 1. DROP AND RECREATE THE MATERIALIZED VIEW WITH ALIAS-AWARE COMPLIANCE JOIN
-- ============================================================================

DROP MATERIALIZED VIEW IF EXISTS client_health_summary CASCADE;

CREATE MATERIALIZED VIEW client_health_summary AS
SELECT
  c.id,
  c.client_name,
  s.segment,
  nps_metrics.nps_score,
  nps_metrics.response_count,
  nps_metrics.last_nps_date,

  -- Engagement Metrics (from unified_meetings)
  meeting_metrics.meeting_count_30d,
  meeting_metrics.meeting_count_90d,
  meeting_metrics.last_meeting_date,
  meeting_metrics.days_since_last_meeting,
  meeting_metrics.completion_rate,

  -- Action Metrics (from actions table)
  COALESCE(action_metrics.total_actions_count, 0) as total_actions_count,
  COALESCE(action_metrics.completed_actions_count, 0) as completed_actions_count,
  COALESCE(action_metrics.open_actions_count, 0) as open_actions_count,
  COALESCE(action_metrics.overdue_actions_count, 0) as overdue_actions_count,

  -- Compliance Metrics (from segmentation_event_compliance via aliases)
  LEAST(100, COALESCE(compliance_metrics.compliance_percentage, 0))::INTEGER as compliance_percentage,
  compliance_metrics.compliance_status,

  -- Working Capital Metrics (from aging_accounts)
  aging_metrics.working_capital_percentage,
  aging_metrics.percent_under_60_days,
  aging_metrics.percent_under_90_days,

  -- CSE Assignment
  c.cse,

  -- Calculated Health Score (0-100 scale)
  -- Components: NPS (25%), Engagement (25%), Compliance (30%), Actions (20%)
  LEAST(100, GREATEST(0, ROUND(
    -- NPS Component (25 points max)
    ((COALESCE(nps_metrics.nps_score, 0) + 100) / 200.0 * 25) +

    -- Engagement Component (25 points max)
    (CASE
      WHEN meeting_metrics.days_since_last_meeting <= 14 THEN 15
      WHEN meeting_metrics.days_since_last_meeting <= 30 THEN 12
      WHEN meeting_metrics.days_since_last_meeting <= 60 THEN 8
      WHEN meeting_metrics.days_since_last_meeting <= 90 THEN 5
      ELSE 0
    END +
    CASE
      WHEN COALESCE(nps_metrics.response_count, 0) >= 5 THEN 10
      WHEN COALESCE(nps_metrics.response_count, 0) >= 3 THEN 7.5
      WHEN COALESCE(nps_metrics.response_count, 0) >= 1 THEN 5
      ELSE 0
    END) +

    -- Compliance Component (30 points max) - Now using real data
    (LEAST(100, COALESCE(compliance_metrics.compliance_percentage, 0)) / 100.0 * 30) +

    -- Actions Risk Component (20 points max - penalty based)
    (20 - LEAST(20, COALESCE(action_metrics.open_actions_count, 0) * 2))
  ))) as health_score,

  -- Status based on health score
  CASE
    WHEN ROUND(
      ((COALESCE(nps_metrics.nps_score, 0) + 100) / 200.0 * 25) +
      (CASE
        WHEN meeting_metrics.days_since_last_meeting <= 14 THEN 15
        WHEN meeting_metrics.days_since_last_meeting <= 30 THEN 12
        WHEN meeting_metrics.days_since_last_meeting <= 60 THEN 8
        WHEN meeting_metrics.days_since_last_meeting <= 90 THEN 5
        ELSE 0
      END +
      CASE
        WHEN COALESCE(nps_metrics.response_count, 0) >= 5 THEN 10
        WHEN COALESCE(nps_metrics.response_count, 0) >= 3 THEN 7.5
        WHEN COALESCE(nps_metrics.response_count, 0) >= 1 THEN 5
        ELSE 0
      END) +
      (LEAST(100, COALESCE(compliance_metrics.compliance_percentage, 0)) / 100.0 * 30) +
      (20 - LEAST(20, COALESCE(action_metrics.open_actions_count, 0) * 2))
    ) >= 75 THEN 'healthy'
    WHEN ROUND(
      ((COALESCE(nps_metrics.nps_score, 0) + 100) / 200.0 * 25) +
      (CASE
        WHEN meeting_metrics.days_since_last_meeting <= 14 THEN 15
        WHEN meeting_metrics.days_since_last_meeting <= 30 THEN 12
        WHEN meeting_metrics.days_since_last_meeting <= 60 THEN 8
        WHEN meeting_metrics.days_since_last_meeting <= 90 THEN 5
        ELSE 0
      END +
      CASE
        WHEN COALESCE(nps_metrics.response_count, 0) >= 5 THEN 10
        WHEN COALESCE(nps_metrics.response_count, 0) >= 3 THEN 7.5
        WHEN COALESCE(nps_metrics.response_count, 0) >= 1 THEN 5
        ELSE 0
      END) +
      (LEAST(100, COALESCE(compliance_metrics.compliance_percentage, 0)) / 100.0 * 30) +
      (20 - LEAST(20, COALESCE(action_metrics.open_actions_count, 0) * 2))
    ) < 50 THEN 'critical'
    ELSE 'at-risk'
  END as status,

  -- Metadata
  NOW() as last_refreshed

FROM nps_clients c

-- LEFT JOIN for segmentation
LEFT JOIN segmentation_clients s ON s.client_name = c.client_name

-- LEFT JOIN for NPS metrics
LEFT JOIN LATERAL (
  SELECT
    ROUND(AVG(r.score))::INTEGER as nps_score,
    COUNT(r.id) as response_count,
    MAX(r.submitted_at) as last_nps_date
  FROM nps_responses r
  WHERE r.client_name = c.client_name
) nps_metrics ON true

-- LEFT JOIN for Meeting metrics
LEFT JOIN LATERAL (
  SELECT
    COUNT(*) FILTER (WHERE m.date >= CURRENT_DATE - INTERVAL '30 days') as meeting_count_30d,
    COUNT(*) FILTER (WHERE m.date >= CURRENT_DATE - INTERVAL '90 days') as meeting_count_90d,
    MAX(m.date) as last_meeting_date,
    COALESCE(EXTRACT(DAY FROM (CURRENT_DATE - MAX(m.date))), 999)::INTEGER as days_since_last_meeting,
    CASE
      WHEN COUNT(*) = 0 THEN 0
      ELSE ROUND((COUNT(*) FILTER (WHERE m.status = 'completed') * 100.0 / NULLIF(COUNT(*), 0)))::INTEGER
    END as completion_rate
  FROM unified_meetings m
  WHERE m.client = c.client_name
    AND m.status != 'cancelled'
) meeting_metrics ON true

-- LEFT JOIN for Action metrics
LEFT JOIN LATERAL (
  SELECT
    COUNT(*) as total_actions_count,
    COUNT(*) FILTER (WHERE a."Status" IN ('Completed', 'Closed')) as completed_actions_count,
    COUNT(*) FILTER (WHERE a."Status" NOT IN ('Completed', 'Closed', 'Cancelled')) as open_actions_count,
    COUNT(*) FILTER (
      WHERE a."Status" NOT IN ('Completed', 'Closed', 'Cancelled')
        AND a."Due_Date" IS NOT NULL
        AND TO_DATE(a."Due_Date", 'DD/MM/YYYY') < CURRENT_DATE
    ) as overdue_actions_count
  FROM actions a
  WHERE a.client = c.client_name
) action_metrics ON true

-- LEFT JOIN for Compliance Metrics using client_name_aliases for name resolution
LEFT JOIN LATERAL (
  SELECT
    AVG(ec.compliance_percentage) as compliance_percentage,
    CASE
      WHEN AVG(ec.compliance_percentage) >= 90 THEN 'compliant'
      WHEN AVG(ec.compliance_percentage) >= 70 THEN 'warning'
      ELSE 'non-compliant'
    END as compliance_status
  FROM segmentation_event_compliance ec
  WHERE ec.year = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER
    AND (
      -- Direct match
      ec.client_name = c.client_name
      -- Or match via alias (resolve display_name to canonical_name)
      OR ec.client_name IN (
        SELECT cna.display_name
        FROM client_name_aliases cna
        WHERE cna.canonical_name = c.client_name
          AND cna.is_active = true
      )
    )
) compliance_metrics ON true

-- LEFT JOIN for Aging/Working Capital metrics
LEFT JOIN LATERAL (
  SELECT
    ROUND(
      CASE
        WHEN SUM(COALESCE(aa.total_ar, 0)) > 0
        THEN (SUM(COALESCE(aa.ar_0_30, 0) + COALESCE(aa.ar_31_60, 0) + COALESCE(aa.ar_61_90, 0)) * 100.0 / SUM(aa.total_ar))
        ELSE NULL
      END
    )::INTEGER as working_capital_percentage,
    ROUND(
      CASE
        WHEN SUM(COALESCE(aa.total_ar, 0)) > 0
        THEN (SUM(COALESCE(aa.ar_0_30, 0) + COALESCE(aa.ar_31_60, 0)) * 100.0 / SUM(aa.total_ar))
        ELSE NULL
      END
    )::INTEGER as percent_under_60_days,
    ROUND(
      CASE
        WHEN SUM(COALESCE(aa.total_ar, 0)) > 0
        THEN (SUM(COALESCE(aa.ar_0_30, 0) + COALESCE(aa.ar_31_60, 0) + COALESCE(aa.ar_61_90, 0)) * 100.0 / SUM(aa.total_ar))
        ELSE NULL
      END
    )::INTEGER as percent_under_90_days
  FROM aging_accounts aa
  WHERE aa.client_name = c.client_name
    OR aa.client_name IN (
      SELECT cna.display_name
      FROM client_name_aliases cna
      WHERE cna.canonical_name = c.client_name
        AND cna.is_active = true
    )
) aging_metrics ON true

-- Exclude churned clients
WHERE c.client_name != 'Parkway'

ORDER BY c.client_name;

-- ============================================================================
-- 2. RECREATE INDEXES
-- ============================================================================

CREATE UNIQUE INDEX idx_client_health_summary_client_name
ON client_health_summary(client_name);

CREATE INDEX idx_client_health_summary_cse
ON client_health_summary(cse);

CREATE INDEX idx_client_health_summary_health_score
ON client_health_summary(health_score DESC);

CREATE INDEX idx_client_health_summary_status
ON client_health_summary(status);

-- ============================================================================
-- 3. REFRESH THE VIEW TO POPULATE DATA
-- ============================================================================

REFRESH MATERIALIZED VIEW client_health_summary;

-- ============================================================================
-- 4. VERIFY THE FIX
-- ============================================================================

-- After running this migration, verify compliance values are no longer all 50%:
-- SELECT client_name, compliance_percentage FROM client_health_summary ORDER BY client_name;
