-- Migration: Working Capital Dual-Goal Scoring
-- Date: 2025-12-28
-- Purpose: Update health score to use dual-goal Working Capital calculation
--
-- NEW LOGIC:
-- Goal 1: % of AR under 60 days >= 90%
-- Goal 2: % of AR under 90 days = 100%
-- If BOTH goals met -> 10 points (full Working Capital score)
-- Otherwise -> proportional scoring based on progress toward each goal
--
-- NEW COLUMNS:
-- - percent_under_60_days: % of AR that is under 60 days old
-- - percent_under_90_days: % of AR that is under 90 days old
--
-- FORMULA CHANGE:
-- Old: (percent_under_90 / 100) * 10
-- New: If (under_60 >= 90 AND under_90 >= 100) then 10
--      Else: (under_60/90 * 5) + (under_90/100 * 5), capped at 10 max
--
-- To Execute: Run this SQL in Supabase Dashboard > SQL Editor

-- Drop and recreate client_health_summary with dual-goal Working Capital
DROP MATERIALIZED VIEW IF EXISTS client_health_summary CASCADE;

CREATE MATERIALIZED VIEW client_health_summary AS
SELECT
  c.id,
  c.client_name,
  c.segment,
  c.cse,
  c.created_at,
  c.updated_at,

  -- NPS metrics from LATEST QUARTER/PERIOD only
  nps.calculated_nps as nps_score,
  nps.promoter_count,
  nps.passive_count,
  nps.detractor_count,
  nps.response_count,
  nps.last_response_date,
  nps.latest_period as nps_period,

  -- Meeting metrics
  meeting_metrics.last_meeting_date,
  meeting_metrics.meeting_count_30d,
  meeting_metrics.meeting_count_90d,
  meeting_metrics.days_since_last_meeting,

  -- Action metrics
  action_metrics.total_actions_count,
  action_metrics.completed_actions_count,
  action_metrics.open_actions_count,
  action_metrics.overdue_actions_count,
  action_metrics.completion_rate,

  -- Compliance metrics (capped at 0-100)
  LEAST(100, GREATEST(0, COALESCE(compliance_metrics.compliance_percentage, 50)))::INTEGER as compliance_percentage,
  COALESCE(compliance_metrics.compliance_status, 'Unknown') as compliance_status,

  -- Working Capital metrics (raw values for display)
  -- Legacy field (for backward compatibility)
  working_capital.working_capital_percentage,
  working_capital.total_outstanding,
  working_capital.amount_under_90_days,
  working_capital.amount_over_90_days,

  -- NEW: Dual-goal percentages
  working_capital.percent_under_60_days,
  working_capital.percent_under_90_days,

  -- Health Score v3.1: NPS (40pts) + Compliance (50pts) + Working Capital (10pts with dual goals)
  (
    -- NPS: normalise from -100 to +100 -> 0 to 100, then apply 0.4 weight
    LEAST(100, GREATEST(0, ((COALESCE(nps.calculated_nps, 0) + 100) / 2.0))) * 0.4 +
    -- Compliance: 50% weight (capped at 0-100)
    LEAST(100, GREATEST(0, COALESCE(compliance_metrics.compliance_percentage, 50))) * 0.5 +
    -- Working Capital: 10% weight with DUAL-GOAL scoring
    -- If both goals met (under_60 >= 90 AND under_90 >= 100), award full 10 points
    -- Otherwise, proportional scoring: (under_60/90 * 5) + (under_90/100 * 5)
    CASE
      -- No aging data = full points
      WHEN working_capital.percent_under_60_days IS NULL AND working_capital.percent_under_90_days IS NULL THEN 10
      -- Both goals met = full points
      WHEN COALESCE(working_capital.percent_under_60_days, 0) >= 90
       AND COALESCE(working_capital.percent_under_90_days, 0) >= 100 THEN 10
      -- Otherwise, proportional scoring (each goal worth 5 points)
      ELSE LEAST(10,
        -- Goal 1: % under 60 days / 90% target * 5 points
        LEAST(5, (COALESCE(working_capital.percent_under_60_days, 0) / 90.0) * 5) +
        -- Goal 2: % under 90 days / 100% target * 5 points
        LEAST(5, (COALESCE(working_capital.percent_under_90_days, 0) / 100.0) * 5)
      )
    END
  )::INTEGER as health_score,

  -- Status based on health score
  CASE
    WHEN (
      LEAST(100, GREATEST(0, ((COALESCE(nps.calculated_nps, 0) + 100) / 2.0))) * 0.4 +
      LEAST(100, GREATEST(0, COALESCE(compliance_metrics.compliance_percentage, 50))) * 0.5 +
      CASE
        WHEN working_capital.percent_under_60_days IS NULL AND working_capital.percent_under_90_days IS NULL THEN 10
        WHEN COALESCE(working_capital.percent_under_60_days, 0) >= 90
         AND COALESCE(working_capital.percent_under_90_days, 0) >= 100 THEN 10
        ELSE LEAST(10,
          LEAST(5, (COALESCE(working_capital.percent_under_60_days, 0) / 90.0) * 5) +
          LEAST(5, (COALESCE(working_capital.percent_under_90_days, 0) / 100.0) * 5)
        )
      END
    ) >= 70 THEN 'Healthy'
    WHEN (
      LEAST(100, GREATEST(0, ((COALESCE(nps.calculated_nps, 0) + 100) / 2.0))) * 0.4 +
      LEAST(100, GREATEST(0, COALESCE(compliance_metrics.compliance_percentage, 50))) * 0.5 +
      CASE
        WHEN working_capital.percent_under_60_days IS NULL AND working_capital.percent_under_90_days IS NULL THEN 10
        WHEN COALESCE(working_capital.percent_under_60_days, 0) >= 90
         AND COALESCE(working_capital.percent_under_90_days, 0) >= 100 THEN 10
        ELSE LEAST(10,
          LEAST(5, (COALESCE(working_capital.percent_under_60_days, 0) / 90.0) * 5) +
          LEAST(5, (COALESCE(working_capital.percent_under_90_days, 0) / 100.0) * 5)
        )
      END
    ) >= 50 THEN 'At Risk'
    ELSE 'Critical'
  END as status,

  NOW() as last_refreshed

FROM nps_clients c

-- NPS from LATEST period only
LEFT JOIN LATERAL (
  SELECT
    latest.period as latest_period,
    ROUND(
      (COUNT(*) FILTER (WHERE nr.score >= 9)::DECIMAL / NULLIF(COUNT(*), 0) * 100) -
      (COUNT(*) FILTER (WHERE nr.score <= 6)::DECIMAL / NULLIF(COUNT(*), 0) * 100)
    )::INTEGER as calculated_nps,
    COUNT(*) FILTER (WHERE nr.score >= 9) as promoter_count,
    COUNT(*) FILTER (WHERE nr.score >= 7 AND nr.score <= 8) as passive_count,
    COUNT(*) FILTER (WHERE nr.score <= 6) as detractor_count,
    COUNT(*) as response_count,
    MAX(nr.response_date) as last_response_date
  FROM nps_responses nr
  INNER JOIN (
    SELECT period
    FROM nps_responses
    WHERE client_name = c.client_name
       OR client_name IN (
         SELECT display_name FROM client_name_aliases
         WHERE canonical_name = c.client_name AND is_active = true
       )
       OR client_name IN (
         SELECT canonical_name FROM client_name_aliases
         WHERE display_name = c.client_name AND is_active = true
       )
    ORDER BY
      CASE
        WHEN period LIKE 'Q% 25' THEN 2025
        WHEN period LIKE 'Q% 24' THEN 2024
        WHEN period = '2023' THEN 2023
        ELSE 2000
      END DESC,
      CASE
        WHEN period LIKE 'Q4%' THEN 4
        WHEN period LIKE 'Q3%' THEN 3
        WHEN period LIKE 'Q2%' THEN 2
        WHEN period LIKE 'Q1%' THEN 1
        ELSE 0
      END DESC
    LIMIT 1
  ) latest ON nr.period = latest.period
  WHERE nr.client_name = c.client_name
     OR nr.client_name IN (
       SELECT display_name FROM client_name_aliases
       WHERE canonical_name = c.client_name AND is_active = true
     )
     OR nr.client_name IN (
       SELECT canonical_name FROM client_name_aliases
       WHERE display_name = c.client_name AND is_active = true
     )
  GROUP BY latest.period
) nps ON true

-- Meeting metrics
LEFT JOIN LATERAL (
  SELECT
    MAX(m.meeting_date) as last_meeting_date,
    COUNT(*) FILTER (WHERE m.meeting_date::date >= CURRENT_DATE - INTERVAL '30 days') as meeting_count_30d,
    COUNT(*) FILTER (WHERE m.meeting_date::date >= CURRENT_DATE - INTERVAL '90 days') as meeting_count_90d,
    EXTRACT(DAY FROM CURRENT_TIMESTAMP - MAX(m.meeting_date::timestamp))::INTEGER as days_since_last_meeting
  FROM unified_meetings m
  WHERE m.client_name = c.client_name
     OR m.client_name IN (
       SELECT display_name FROM client_name_aliases
       WHERE canonical_name = c.client_name AND is_active = true
     )
     OR m.client_name IN (
       SELECT canonical_name FROM client_name_aliases
       WHERE display_name = c.client_name AND is_active = true
     )
) meeting_metrics ON true

-- Action metrics
LEFT JOIN LATERAL (
  SELECT
    COUNT(*) as total_actions_count,
    COUNT(*) FILTER (WHERE a."Status" = 'Completed') as completed_actions_count,
    COUNT(*) FILTER (WHERE a."Status" IN ('Open', 'In Progress', 'Pending')) as open_actions_count,
    COUNT(*) FILTER (WHERE a."Status" IN ('Open', 'In Progress', 'Pending') AND a."Due_Date"::date < CURRENT_DATE) as overdue_actions_count,
    CASE
      WHEN COUNT(*) = 0 THEN 100
      ELSE ROUND((COUNT(*) FILTER (WHERE a."Status" = 'Completed')::DECIMAL / COUNT(*)) * 100)
    END as completion_rate
  FROM actions a
  WHERE a.client = c.client_name
     OR a.client IN (
       SELECT display_name FROM client_name_aliases
       WHERE canonical_name = c.client_name AND is_active = true
     )
     OR a.client IN (
       SELECT canonical_name FROM client_name_aliases
       WHERE display_name = c.client_name AND is_active = true
     )
) action_metrics ON true

-- Compliance metrics from event_compliance_summary
-- Uses overall_compliance_score directly from the view
LEFT JOIN LATERAL (
  SELECT
    ecs.overall_compliance_score as compliance_percentage,
    ecs.overall_status as compliance_status
  FROM event_compliance_summary ecs
  WHERE (ecs.client_name = c.client_name
     OR ecs.client_name IN (
       SELECT display_name FROM client_name_aliases
       WHERE canonical_name = c.client_name AND is_active = true
     )
     OR ecs.client_name IN (
       SELECT canonical_name FROM client_name_aliases
       WHERE display_name = c.client_name AND is_active = true
     ))
    AND ecs.year = EXTRACT(YEAR FROM CURRENT_DATE)
  LIMIT 1
) compliance_metrics ON true

-- Working Capital metrics from aging_accounts
-- UPDATED: Now calculates both percent_under_60_days and percent_under_90_days
LEFT JOIN LATERAL (
  SELECT
    -- Legacy field (% under 90 days)
    CASE
      WHEN COALESCE(SUM(aa.total_outstanding), 0) = 0 THEN NULL
      ELSE ROUND(
        (1.0 - (
          COALESCE(SUM(
            COALESCE(aa.days_91_to_120, 0) +
            COALESCE(aa.days_121_to_180, 0) +
            COALESCE(aa.days_181_to_270, 0) +
            COALESCE(aa.days_271_to_365, 0) +
            COALESCE(aa.days_over_365, 0)
          ), 0)::DECIMAL / NULLIF(SUM(aa.total_outstanding), 0)
        )) * 100
      )
    END as working_capital_percentage,

    SUM(aa.total_outstanding) as total_outstanding,

    SUM(
      COALESCE(aa.current_amount, 0) +
      COALESCE(aa.days_1_to_30, 0) +
      COALESCE(aa.days_31_to_60, 0) +
      COALESCE(aa.days_61_to_90, 0)
    ) as amount_under_90_days,

    SUM(
      COALESCE(aa.days_91_to_120, 0) +
      COALESCE(aa.days_121_to_180, 0) +
      COALESCE(aa.days_181_to_270, 0) +
      COALESCE(aa.days_271_to_365, 0) +
      COALESCE(aa.days_over_365, 0)
    ) as amount_over_90_days,

    -- NEW: Percent under 60 days (Goal 1 target: >= 90%)
    -- Formula: (current + 1-30 + 31-60) / total * 100
    CASE
      WHEN COALESCE(SUM(aa.total_outstanding), 0) = 0 THEN NULL
      ELSE ROUND(
        (
          COALESCE(SUM(
            COALESCE(aa.current_amount, 0) +
            COALESCE(aa.days_1_to_30, 0) +
            COALESCE(aa.days_31_to_60, 0)
          ), 0)::DECIMAL / NULLIF(SUM(aa.total_outstanding), 0)
        ) * 100
      )
    END as percent_under_60_days,

    -- NEW: Percent under 90 days (Goal 2 target: 100%)
    -- Formula: (current + 1-30 + 31-60 + 61-90) / total * 100
    CASE
      WHEN COALESCE(SUM(aa.total_outstanding), 0) = 0 THEN NULL
      ELSE ROUND(
        (
          COALESCE(SUM(
            COALESCE(aa.current_amount, 0) +
            COALESCE(aa.days_1_to_30, 0) +
            COALESCE(aa.days_31_to_60, 0) +
            COALESCE(aa.days_61_to_90, 0)
          ), 0)::DECIMAL / NULLIF(SUM(aa.total_outstanding), 0)
        ) * 100
      )
    END as percent_under_90_days

  FROM aging_accounts aa
  WHERE aa.is_inactive = false
    AND (
      aa.client_name = c.client_name
      OR aa.client_name IN (
        SELECT display_name FROM client_name_aliases
        WHERE canonical_name = c.client_name AND is_active = true
      )
      OR aa.client_name IN (
        SELECT canonical_name FROM client_name_aliases
        WHERE display_name = c.client_name AND is_active = true
      )
    )
) working_capital ON true

;

-- Create indexes for performance
CREATE UNIQUE INDEX idx_client_health_summary_id ON client_health_summary(id);
CREATE INDEX idx_client_health_summary_name ON client_health_summary(client_name);
CREATE INDEX idx_client_health_summary_health ON client_health_summary(health_score);
CREATE INDEX idx_client_health_summary_status ON client_health_summary(status);

-- Grant access
GRANT SELECT ON client_health_summary TO anon, authenticated;

-- Notify PostgREST to reload schema
NOTIFY pgrst, 'reload schema';

-- Verification queries (run after migration)
-- SELECT client_name, nps_score, compliance_percentage,
--        percent_under_60_days, percent_under_90_days,
--        working_capital_percentage, health_score, status
-- FROM client_health_summary
-- ORDER BY client_name;
