-- Migration: Add Actions Component to Health Score (v4.0)
-- Date: 2026-01-02
-- Issue: Health score modal shows new 4-component formula but database/profile cards use old 3-component formula
--
-- OLD Formula (v3.0):
--   - NPS: 40%
--   - Compliance: 50%
--   - Working Capital: 10%
--   - Total: 100%
--
-- NEW Formula (v4.0):
--   - NPS: 20%
--   - Compliance: 60%
--   - Working Capital: 10%
--   - Actions: 10% (based on completion_rate)
--   - Total: 100%
--
-- To Execute: Run this SQL in Supabase Dashboard > SQL Editor

-- Drop and recreate client_health_summary with Actions component
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
  working_capital.working_capital_percentage,
  working_capital.total_outstanding,
  working_capital.amount_under_90_days,
  working_capital.amount_over_90_days,

  -- Health Score v4.0: NPS (20pts) + Compliance (60pts) + Working Capital (10pts) + Actions (10pts)
  -- All percentage inputs capped at 0-100 to prevent overflow
  (
    -- NPS: normalise from -100 to +100 → 0 to 100, then apply 0.2 weight (20 points max)
    LEAST(100, GREATEST(0, ((COALESCE(nps.calculated_nps, 0) + 100) / 2.0))) * 0.2 +
    -- Compliance: 60% weight (60 points max)
    LEAST(100, GREATEST(0, COALESCE(compliance_metrics.compliance_percentage, 50))) * 0.6 +
    -- Working Capital: 10% weight (10 points max)
    LEAST(100, GREATEST(0, COALESCE(working_capital.working_capital_percentage, 100))) * 0.1 +
    -- Actions: 10% weight (10 points max) - completion_rate already defaults to 100 if no actions
    LEAST(100, GREATEST(0, COALESCE(action_metrics.completion_rate, 100))) * 0.1
  )::INTEGER as health_score,

  -- Status based on health score
  CASE
    WHEN (
      LEAST(100, GREATEST(0, ((COALESCE(nps.calculated_nps, 0) + 100) / 2.0))) * 0.2 +
      LEAST(100, GREATEST(0, COALESCE(compliance_metrics.compliance_percentage, 50))) * 0.6 +
      LEAST(100, GREATEST(0, COALESCE(working_capital.working_capital_percentage, 100))) * 0.1 +
      LEAST(100, GREATEST(0, COALESCE(action_metrics.completion_rate, 100))) * 0.1
    ) >= 70 THEN 'Healthy'
    WHEN (
      LEAST(100, GREATEST(0, ((COALESCE(nps.calculated_nps, 0) + 100) / 2.0))) * 0.2 +
      LEAST(100, GREATEST(0, COALESCE(compliance_metrics.compliance_percentage, 50))) * 0.6 +
      LEAST(100, GREATEST(0, COALESCE(working_capital.working_capital_percentage, 100))) * 0.1 +
      LEAST(100, GREATEST(0, COALESCE(action_metrics.completion_rate, 100))) * 0.1
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
    COUNT(*) FILTER (WHERE a."Status" IN ('Open', 'In Progress', 'Pending') AND
      CASE
        WHEN a."Due_Date" ~ '^\d{1,2}/\d{1,2}/\d{4}$' THEN TO_DATE(a."Due_Date", 'DD/MM/YYYY')
        WHEN a."Due_Date" ~ '^\d{4}-\d{2}-\d{2}' THEN a."Due_Date"::date
        ELSE NULL
      END < CURRENT_DATE
    ) as overdue_actions_count,
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

-- Compliance metrics from event_compliance_summary (use latest year with data)
LEFT JOIN LATERAL (
  SELECT
    COALESCE(ecs.overall_compliance_score, 50) as compliance_percentage,
    COALESCE(ecs.overall_status, 'Unknown') as compliance_status
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
    AND ecs.year = (SELECT MAX(year) FROM event_compliance_summary WHERE client_name = c.client_name)
  ORDER BY ecs.year DESC
  LIMIT 1
) compliance_metrics ON true

-- Working Capital metrics from aging_accounts
LEFT JOIN LATERAL (
  SELECT
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
    ) as amount_over_90_days
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

-- Verification query (run after migration)
-- SELECT
--   client_name,
--   nps_score,
--   compliance_percentage,
--   working_capital_percentage,
--   completion_rate,
--   health_score,
--   status
-- FROM client_health_summary
-- ORDER BY health_score ASC
-- LIMIT 10;
