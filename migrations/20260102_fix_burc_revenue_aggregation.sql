-- ============================================================
-- Fix BURC Revenue Retention and Rule of 40 Views
-- Issue: Views filtered for 'Total Revenue' type which doesn't exist
-- Fix: Aggregate all revenue types per customer
-- ============================================================

-- ============================================================
-- 1. FIXED REVENUE RETENTION METRICS VIEW
-- Now aggregates all revenue types instead of filtering for 'Total Revenue'
-- ============================================================
DROP VIEW IF EXISTS burc_executive_summary CASCADE;
DROP VIEW IF EXISTS burc_revenue_retention CASCADE;

CREATE OR REPLACE VIEW burc_revenue_retention AS
WITH yearly_revenue AS (
  -- Aggregate all revenue types per customer
  SELECT
    customer_name,
    SUM(COALESCE(year_2023, 0)) as year_2023,
    SUM(COALESCE(year_2024, 0)) as year_2024,
    SUM(COALESCE(year_2025, 0)) as year_2025,
    SUM(COALESCE(year_2026, 0)) as year_2026
  FROM burc_historical_revenue
  GROUP BY customer_name
),
attrition_by_year AS (
  SELECT
    client_name,
    SUM(COALESCE(revenue_2024, 0)) as churn_2024,
    SUM(COALESCE(revenue_2025, 0)) as churn_2025,
    SUM(COALESCE(revenue_2026, 0)) as churn_2026
  FROM burc_attrition_risk
  WHERE status != 'mitigated'
  GROUP BY client_name
)
SELECT
  2024 as year,
  COALESCE(SUM(yr.year_2023), 0) as starting_revenue,
  COALESCE(SUM(yr.year_2024), 0) as ending_revenue,
  COALESCE(SUM(attr.churn_2024), 0) as churn,
  -- GRR: (Starting - Churn) / Starting * 100
  CASE
    WHEN COALESCE(SUM(yr.year_2023), 0) > 0 THEN
      ROUND(((COALESCE(SUM(yr.year_2023), 0) - COALESCE(SUM(attr.churn_2024), 0)) / COALESCE(SUM(yr.year_2023), 0)) * 100, 1)
    ELSE 0
  END as grr_percent,
  -- NRR: Ending / Starting * 100 (includes expansions)
  CASE
    WHEN COALESCE(SUM(yr.year_2023), 0) > 0 THEN
      ROUND((COALESCE(SUM(yr.year_2024), 0) / COALESCE(SUM(yr.year_2023), 0)) * 100, 1)
    ELSE 0
  END as nrr_percent,
  -- Expansion Revenue
  CASE
    WHEN COALESCE(SUM(yr.year_2024), 0) > COALESCE(SUM(yr.year_2023), 0) THEN
      COALESCE(SUM(yr.year_2024), 0) - COALESCE(SUM(yr.year_2023), 0)
    ELSE 0
  END as expansion_revenue
FROM yearly_revenue yr
LEFT JOIN attrition_by_year attr ON yr.customer_name = attr.client_name

UNION ALL

SELECT
  2025 as year,
  COALESCE(SUM(yr.year_2024), 0) as starting_revenue,
  COALESCE(SUM(yr.year_2025), 0) as ending_revenue,
  COALESCE(SUM(attr.churn_2025), 0) as churn,
  CASE
    WHEN COALESCE(SUM(yr.year_2024), 0) > 0 THEN
      ROUND(((COALESCE(SUM(yr.year_2024), 0) - COALESCE(SUM(attr.churn_2025), 0)) / COALESCE(SUM(yr.year_2024), 0)) * 100, 1)
    ELSE 0
  END as grr_percent,
  CASE
    WHEN COALESCE(SUM(yr.year_2024), 0) > 0 THEN
      ROUND((COALESCE(SUM(yr.year_2025), 0) / COALESCE(SUM(yr.year_2024), 0)) * 100, 1)
    ELSE 0
  END as nrr_percent,
  CASE
    WHEN COALESCE(SUM(yr.year_2025), 0) > COALESCE(SUM(yr.year_2024), 0) THEN
      COALESCE(SUM(yr.year_2025), 0) - COALESCE(SUM(yr.year_2024), 0)
    ELSE 0
  END as expansion_revenue
FROM yearly_revenue yr
LEFT JOIN attrition_by_year attr ON yr.customer_name = attr.client_name

UNION ALL

SELECT
  2026 as year,
  COALESCE(SUM(yr.year_2025), 0) as starting_revenue,
  COALESCE(SUM(yr.year_2026), 0) as ending_revenue,
  COALESCE(SUM(attr.churn_2026), 0) as churn,
  CASE
    WHEN COALESCE(SUM(yr.year_2025), 0) > 0 THEN
      ROUND(((COALESCE(SUM(yr.year_2025), 0) - COALESCE(SUM(attr.churn_2026), 0)) / COALESCE(SUM(yr.year_2025), 0)) * 100, 1)
    ELSE 0
  END as grr_percent,
  CASE
    WHEN COALESCE(SUM(yr.year_2025), 0) > 0 THEN
      ROUND((COALESCE(SUM(yr.year_2026), 0) / COALESCE(SUM(yr.year_2025), 0)) * 100, 1)
    ELSE 0
  END as nrr_percent,
  CASE
    WHEN COALESCE(SUM(yr.year_2026), 0) > COALESCE(SUM(yr.year_2025), 0) THEN
      COALESCE(SUM(yr.year_2026), 0) - COALESCE(SUM(yr.year_2025), 0)
    ELSE 0
  END as expansion_revenue
FROM yearly_revenue yr
LEFT JOIN attrition_by_year attr ON yr.customer_name = attr.client_name;

-- ============================================================
-- 2. FIXED RULE OF 40 VIEW
-- Now aggregates all revenue types instead of filtering for 'Total Revenue'
-- ============================================================
DROP VIEW IF EXISTS burc_rule_of_40 CASCADE;

CREATE OR REPLACE VIEW burc_rule_of_40 AS
WITH yearly_totals AS (
  -- Aggregate all revenue types
  SELECT
    SUM(COALESCE(year_2023, 0)) as total_2023,
    SUM(COALESCE(year_2024, 0)) as total_2024,
    SUM(COALESCE(year_2025, 0)) as total_2025,
    SUM(COALESCE(year_2026, 0)) as total_2026
  FROM burc_historical_revenue
),
revenue_growth AS (
  SELECT
    2024 as year,
    total_2023 as prev_revenue,
    total_2024 as curr_revenue,
    CASE
      WHEN total_2023 > 0 THEN
        ROUND(((total_2024 - total_2023) / total_2023) * 100, 1)
      ELSE 0
    END as growth_percent
  FROM yearly_totals

  UNION ALL

  SELECT
    2025 as year,
    total_2024 as prev_revenue,
    total_2025 as curr_revenue,
    CASE
      WHEN total_2024 > 0 THEN
        ROUND(((total_2025 - total_2024) / total_2024) * 100, 1)
      ELSE 0
    END as growth_percent
  FROM yearly_totals

  UNION ALL

  SELECT
    2026 as year,
    total_2025 as prev_revenue,
    total_2026 as curr_revenue,
    CASE
      WHEN total_2025 > 0 THEN
        ROUND(((total_2026 - total_2025) / total_2025) * 100, 1)
      ELSE 0
    END as growth_percent
  FROM yearly_totals
)
SELECT
  rg.year,
  rg.prev_revenue,
  rg.curr_revenue,
  rg.growth_percent as revenue_growth_percent,
  -- EBITA margin estimate (placeholder - will be populated from actual P&L)
  15.0 as ebita_margin_percent,
  rg.growth_percent + 15.0 as rule_of_40_score,
  CASE
    WHEN rg.growth_percent + 15.0 >= 40 THEN 'Passing'
    WHEN rg.growth_percent + 15.0 >= 30 THEN 'At Risk'
    ELSE 'Below Target'
  END as rule_of_40_status
FROM revenue_growth rg;

-- ============================================================
-- 3. RECREATE EXECUTIVE SUMMARY VIEW
-- (Was dropped due to CASCADE from burc_revenue_retention)
-- ============================================================
CREATE OR REPLACE VIEW burc_executive_summary AS
WITH latest_retention AS (
  SELECT * FROM burc_revenue_retention WHERE year = 2025
),
latest_rule40 AS (
  SELECT * FROM burc_rule_of_40 WHERE year = 2025
),
total_arr AS (
  SELECT COALESCE(SUM(arr_usd), 0) as total_arr FROM burc_arr_tracking WHERE year = 2025
),
total_contracts AS (
  SELECT
    COUNT(*) as active_contracts,
    COALESCE(SUM(annual_value_usd), 0) as total_contract_value
  FROM burc_contracts
  WHERE contract_status = 'active'
),
pipeline_summary AS (
  SELECT
    COALESCE(SUM(estimated_sw_value + estimated_ps_value + estimated_maint_value + estimated_hw_value), 0) as total_pipeline,
    COALESCE(SUM((estimated_sw_value + estimated_ps_value + estimated_maint_value + estimated_hw_value) * probability), 0) as weighted_pipeline
  FROM burc_business_cases
  WHERE stage = 'active'
),
attrition_summary AS (
  SELECT
    COALESCE(SUM(total_at_risk), 0) as total_at_risk,
    COUNT(*) as risk_count
  FROM burc_attrition_risk
  WHERE status = 'open'
)
SELECT
  CURRENT_DATE as snapshot_date,
  COALESCE(lr.nrr_percent, 0) as nrr_percent,
  COALESCE(lr.grr_percent, 0) as grr_percent,
  COALESCE(lr.churn, 0) as annual_churn,
  COALESCE(lr.expansion_revenue, 0) as expansion_revenue,
  COALESCE(lrf.revenue_growth_percent, 0) as revenue_growth_percent,
  COALESCE(lrf.ebita_margin_percent, 15.0) as ebita_margin_percent,
  COALESCE(lrf.rule_of_40_score, 15.0) as rule_of_40_score,
  COALESCE(lrf.rule_of_40_status, 'Below Target') as rule_of_40_status,
  COALESCE(ta.total_arr, 0) as total_arr,
  COALESCE(tc.active_contracts, 0) as active_contracts,
  COALESCE(tc.total_contract_value, 0) as total_contract_value,
  COALESCE(ps.total_pipeline, 0) as total_pipeline,
  COALESCE(ps.weighted_pipeline, 0) as weighted_pipeline,
  COALESCE(ats.total_at_risk, 0) as total_at_risk,
  COALESCE(ats.risk_count, 0) as attrition_risk_count,
  -- Health indicators
  CASE
    WHEN COALESCE(lr.nrr_percent, 0) >= 110 THEN 'Excellent'
    WHEN COALESCE(lr.nrr_percent, 0) >= 100 THEN 'Good'
    WHEN COALESCE(lr.nrr_percent, 0) >= 90 THEN 'At Risk'
    ELSE 'Critical'
  END as nrr_health,
  CASE
    WHEN COALESCE(lr.grr_percent, 0) >= 95 THEN 'Excellent'
    WHEN COALESCE(lr.grr_percent, 0) >= 90 THEN 'Good'
    WHEN COALESCE(lr.grr_percent, 0) >= 85 THEN 'At Risk'
    ELSE 'Critical'
  END as grr_health
FROM latest_retention lr
CROSS JOIN latest_rule40 lrf
CROSS JOIN total_arr ta
CROSS JOIN total_contracts tc
CROSS JOIN pipeline_summary ps
CROSS JOIN attrition_summary ats;

-- Grant permissions
GRANT SELECT ON burc_revenue_retention TO authenticated;
GRANT SELECT ON burc_rule_of_40 TO authenticated;
GRANT SELECT ON burc_executive_summary TO authenticated;
