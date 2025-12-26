-- Migration: Fix Health Score Compliance Calculation Bug
-- Date: 2025-12-16
-- Purpose: Align health score compliance with UI segmentation action progress
--
-- BUG DESCRIPTION:
-- The health score was using AVG(compliance_percentage) which:
--   - Allowed over-servicing to mask under-servicing
--   - Example: SLMC had 4/8 event types on target (50% in UI)
--   - But AVG gave 125% → capped to 100% → health score showed 80
--
-- FIX:
-- Use proportion of on-target event types instead of average:
--   COUNT(on_target) / COUNT(total) * 100
--
-- EXAMPLE (Saint Luke's Medical Centre):
--   Before: AVG of [600, 200, 0, 0, 50, 0, 0, 0, 0, 400, 150, 100] = 125% → 100%
--   After: 5 on-target / 12 total = 41.7%

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

  -- Compliance Metrics (FIXED: now uses proportion of on-target event types)
  COALESCE(compliance_metrics.compliance_percentage, 50) as compliance_percentage,
  compliance_metrics.compliance_status,

  -- SIMPLIFIED Health Score (0-100 scale)
  -- Formula: NPS (40) + Compliance (60)
  LEAST(100, GREATEST(0, ROUND(
    -- 1. NPS Score Component (40 points max)
    -- Convert NPS from -100/+100 scale to 0-40 point contribution
    ((COALESCE(nps_metrics.nps_score, 0) + 100) / 200.0 * 40) +

    -- 2. Compliance Component (60 points max)
    -- Now uses proportion of on-target event types (not average compliance)
    (COALESCE(compliance_metrics.compliance_percentage, 50) / 100.0 * 60)
  ))) as health_score,

  -- Calculated Status based on simplified health score
  CASE
    WHEN ROUND(
      ((COALESCE(nps_metrics.nps_score, 0) + 100) / 200.0 * 40) +
      (COALESCE(compliance_metrics.compliance_percentage, 50) / 100.0 * 60)
    ) >= 75 THEN 'healthy'
    WHEN ROUND(
      ((COALESCE(nps_metrics.nps_score, 0) + 100) / 200.0 * 40) +
      (COALESCE(compliance_metrics.compliance_percentage, 50) / 100.0 * 60)
    ) < 50 THEN 'critical'
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

-- Meeting Metrics (kept for reference/display)
LEFT JOIN LATERAL (
  SELECT
    MAX(meeting_date) as last_meeting_date,
    COUNT(*) FILTER (WHERE meeting_date >= CURRENT_DATE - INTERVAL '30 days') as meeting_count_30d,
    COUNT(*) FILTER (WHERE meeting_date >= CURRENT_DATE - INTERVAL '90 days') as meeting_count_90d,
    COALESCE(CURRENT_DATE - MAX(meeting_date)::DATE, 999) as days_since_last_meeting
  FROM unified_meetings m
  WHERE m.client_name = c.client_name
) meeting_metrics ON true

-- Action Metrics (kept for reference/display)
LEFT JOIN LATERAL (
  SELECT
    COUNT(*) as total_actions_count,
    COUNT(*) FILTER (WHERE "Status" IN ('Completed', 'Closed')) as completed_actions_count,
    COUNT(*) FILTER (WHERE "Status" NOT IN ('Completed', 'Closed', 'Cancelled')) as open_actions_count,
    COUNT(*) FILTER (
      WHERE "Status" NOT IN ('Completed', 'Closed', 'Cancelled')
        AND "Due_Date" IS NOT NULL
        -- Only parse dates that match valid patterns (skip "Per Year" and other text)
        AND "Due_Date" ~ '^[\d/\-]+$'
        AND CASE
          -- Handle ISO format (YYYY-MM-DD)
          WHEN "Due_Date" ~ '^\d{4}-\d{2}-\d{2}$' THEN "Due_Date"::DATE
          -- Handle DD/MM/YYYY or D/M/YYYY format
          WHEN "Due_Date" ~ '^\d{1,2}/\d{1,2}/\d{4}$' THEN TO_DATE("Due_Date", 'DD/MM/YYYY')
          ELSE NULL
        END < CURRENT_DATE
    ) as overdue_actions_count,
    CASE
      WHEN COUNT(*) > 0 THEN
        ROUND((COUNT(*) FILTER (WHERE "Status" IN ('Completed', 'Closed'))::DECIMAL / COUNT(*) * 100))
      ELSE 0
    END as completion_rate
  FROM actions a
  WHERE a.client = c.client_name
) action_metrics ON true

-- FIXED Compliance Metrics
-- Now uses event_compliance_summary view (same source as UI)
-- This ensures health score matches the UI's "Segmentation Action Progress" display
LEFT JOIN LATERAL (
  SELECT
    -- Use overall_compliance_score directly from the UI's source view
    COALESCE(ecs.overall_compliance_score, 50) as compliance_percentage,
    -- Status based on overall compliance score
    CASE
      WHEN ecs.overall_compliance_score IS NULL THEN 'unknown'
      WHEN ecs.overall_compliance_score >= 75 THEN 'compliant'
      WHEN ecs.overall_compliance_score >= 50 THEN 'warning'
      ELSE 'non-compliant'
    END as compliance_status
  FROM event_compliance_summary ecs
  WHERE ecs.client_name = c.client_name
    AND ecs.year = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER
) compliance_metrics ON true

WHERE c.client_name != 'Parkway'

ORDER BY c.client_name;

-- Recreate indexes
CREATE UNIQUE INDEX idx_client_health_summary_client_name ON client_health_summary(client_name);
CREATE INDEX idx_client_health_summary_cse ON client_health_summary(cse);
CREATE INDEX idx_client_health_summary_health_score ON client_health_summary(health_score DESC);
CREATE INDEX idx_client_health_summary_status ON client_health_summary(status);
CREATE INDEX idx_client_health_summary_segment ON client_health_summary(segment);

-- Grant permissions
GRANT SELECT ON client_health_summary TO anon, authenticated;

-- Initial refresh
REFRESH MATERIALIZED VIEW client_health_summary;
