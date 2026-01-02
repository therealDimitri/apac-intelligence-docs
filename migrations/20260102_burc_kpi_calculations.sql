-- ============================================================
-- BURC KPI Calculations Migration
-- Phase 2: NRR, GRR, Rule of 40, CSI Operating Ratios
-- ============================================================

-- ============================================================
-- 1. REVENUE RETENTION METRICS VIEW
-- Calculates NRR and GRR by year
-- ============================================================
CREATE OR REPLACE VIEW burc_revenue_retention AS
WITH yearly_revenue AS (
  SELECT
    customer_name,
    revenue_type,
    year_2023,
    year_2024,
    year_2025,
    year_2026
  FROM burc_historical_revenue
  WHERE revenue_type IN ('Maintenance', 'Software', 'Total Revenue')
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
),
contract_arr AS (
  SELECT
    SUM(annual_value_usd) as total_arr_usd
  FROM burc_contracts
  WHERE contract_status = 'active'
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
WHERE yr.revenue_type = 'Total Revenue'

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
WHERE yr.revenue_type = 'Total Revenue'

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
LEFT JOIN attrition_by_year attr ON yr.customer_name = attr.client_name
WHERE yr.revenue_type = 'Total Revenue';

-- ============================================================
-- 2. RULE OF 40 VIEW
-- Revenue Growth % + EBITA Margin % >= 40%
-- ============================================================
CREATE OR REPLACE VIEW burc_rule_of_40 AS
WITH revenue_growth AS (
  SELECT
    2024 as year,
    SUM(year_2023) as prev_revenue,
    SUM(year_2024) as curr_revenue,
    CASE
      WHEN SUM(year_2023) > 0 THEN
        ROUND(((SUM(year_2024) - SUM(year_2023)) / SUM(year_2023)) * 100, 1)
      ELSE 0
    END as growth_percent
  FROM burc_historical_revenue
  WHERE revenue_type = 'Total Revenue'

  UNION ALL

  SELECT
    2025 as year,
    SUM(year_2024) as prev_revenue,
    SUM(year_2025) as curr_revenue,
    CASE
      WHEN SUM(year_2024) > 0 THEN
        ROUND(((SUM(year_2025) - SUM(year_2024)) / SUM(year_2024)) * 100, 1)
      ELSE 0
    END as growth_percent
  FROM burc_historical_revenue
  WHERE revenue_type = 'Total Revenue'

  UNION ALL

  SELECT
    2026 as year,
    SUM(year_2025) as prev_revenue,
    SUM(year_2026) as curr_revenue,
    CASE
      WHEN SUM(year_2025) > 0 THEN
        ROUND(((SUM(year_2026) - SUM(year_2025)) / SUM(year_2025)) * 100, 1)
      ELSE 0
    END as growth_percent
  FROM burc_historical_revenue
  WHERE revenue_type = 'Total Revenue'
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
-- 3. ARR PIPELINE PERFORMANCE VIEW
-- Tracks ARR targets vs actuals
-- ============================================================
CREATE OR REPLACE VIEW burc_arr_performance AS
SELECT
  client_name,
  cse_owner,
  arr_usd,
  target_pipeline_percent,
  target_pipeline_value,
  actual_bookings,
  variance,
  year,
  quarter,
  snapshot_date,
  CASE
    WHEN target_pipeline_value > 0 THEN
      ROUND((actual_bookings / target_pipeline_value) * 100, 1)
    ELSE 0
  END as achievement_percent,
  CASE
    WHEN variance >= 0 THEN 'On Track'
    WHEN variance >= -target_pipeline_value * 0.1 THEN 'At Risk'
    ELSE 'Behind'
  END as status
FROM burc_arr_tracking
WHERE year = EXTRACT(YEAR FROM CURRENT_DATE);

-- ============================================================
-- 4. ATTRITION RISK SUMMARY VIEW
-- Aggregated attrition risk by status and year
-- ============================================================
CREATE OR REPLACE VIEW burc_attrition_summary AS
SELECT
  status,
  COUNT(*) as risk_count,
  SUM(revenue_2024) as total_at_risk_2024,
  SUM(revenue_2025) as total_at_risk_2025,
  SUM(revenue_2026) as total_at_risk_2026,
  SUM(total_at_risk) as total_at_risk_all_years,
  STRING_AGG(DISTINCT client_name, ', ') as affected_clients
FROM burc_attrition_risk
GROUP BY status;

-- ============================================================
-- 5. CONTRACT RENEWAL CALENDAR VIEW
-- Contracts by renewal month with values
-- ============================================================
CREATE OR REPLACE VIEW burc_renewal_calendar AS
SELECT
  EXTRACT(YEAR FROM renewal_date) as renewal_year,
  EXTRACT(MONTH FROM renewal_date) as renewal_month,
  TO_CHAR(renewal_date, 'Mon YYYY') as renewal_period,
  COUNT(*) as contract_count,
  SUM(annual_value_usd) as total_value_usd,
  SUM(annual_value_aud) as total_value_aud,
  STRING_AGG(client_name, ', ') as clients
FROM burc_contracts
WHERE renewal_date IS NOT NULL
  AND renewal_date >= CURRENT_DATE
GROUP BY EXTRACT(YEAR FROM renewal_date), EXTRACT(MONTH FROM renewal_date), TO_CHAR(renewal_date, 'Mon YYYY')
ORDER BY renewal_year, renewal_month;

-- ============================================================
-- 6. PIPELINE BY STAGE VIEW
-- Business cases grouped by forecast category
-- ============================================================
CREATE OR REPLACE VIEW burc_pipeline_by_stage AS
SELECT
  forecast_category,
  stage,
  COUNT(*) as opportunity_count,
  SUM(estimated_sw_value + estimated_ps_value + estimated_maint_value + estimated_hw_value) as total_value,
  SUM((estimated_sw_value + estimated_ps_value + estimated_maint_value + estimated_hw_value) * probability) as weighted_value,
  AVG(probability) as avg_probability,
  STRING_AGG(DISTINCT client_name, ', ') as clients
FROM burc_business_cases
WHERE stage = 'active'
GROUP BY forecast_category, stage
ORDER BY weighted_value DESC;

-- ============================================================
-- 7. EXECUTIVE KPI SUMMARY VIEW
-- Single view with all key metrics for dashboards
-- ============================================================
CREATE OR REPLACE VIEW burc_executive_summary AS
WITH latest_retention AS (
  SELECT * FROM burc_revenue_retention WHERE year = 2025
),
latest_rule40 AS (
  SELECT * FROM burc_rule_of_40 WHERE year = 2025
),
total_arr AS (
  SELECT SUM(arr_usd) as total_arr FROM burc_arr_tracking WHERE year = 2025
),
total_contracts AS (
  SELECT
    COUNT(*) as active_contracts,
    SUM(annual_value_usd) as total_contract_value
  FROM burc_contracts
  WHERE contract_status = 'active'
),
pipeline_summary AS (
  SELECT
    SUM(estimated_sw_value + estimated_ps_value + estimated_maint_value + estimated_hw_value) as total_pipeline,
    SUM((estimated_sw_value + estimated_ps_value + estimated_maint_value + estimated_hw_value) * probability) as weighted_pipeline
  FROM burc_business_cases
  WHERE stage = 'active'
),
attrition_summary AS (
  SELECT
    SUM(total_at_risk) as total_at_risk,
    COUNT(*) as risk_count
  FROM burc_attrition_risk
  WHERE status = 'open'
)
SELECT
  CURRENT_DATE as snapshot_date,
  lr.nrr_percent,
  lr.grr_percent,
  lr.churn as annual_churn,
  lr.expansion_revenue,
  lrf.revenue_growth_percent,
  lrf.ebita_margin_percent,
  lrf.rule_of_40_score,
  lrf.rule_of_40_status,
  ta.total_arr,
  tc.active_contracts,
  tc.total_contract_value,
  ps.total_pipeline,
  ps.weighted_pipeline,
  ats.total_at_risk,
  ats.risk_count as attrition_risk_count,
  -- Health indicators
  CASE
    WHEN lr.nrr_percent >= 110 THEN 'Excellent'
    WHEN lr.nrr_percent >= 100 THEN 'Good'
    WHEN lr.nrr_percent >= 90 THEN 'At Risk'
    ELSE 'Critical'
  END as nrr_health,
  CASE
    WHEN lr.grr_percent >= 95 THEN 'Excellent'
    WHEN lr.grr_percent >= 90 THEN 'Good'
    WHEN lr.grr_percent >= 85 THEN 'At Risk'
    ELSE 'Critical'
  END as grr_health
FROM latest_retention lr
CROSS JOIN latest_rule40 lrf
CROSS JOIN total_arr ta
CROSS JOIN total_contracts tc
CROSS JOIN pipeline_summary ps
CROSS JOIN attrition_summary ats;

-- Grant select on all views to authenticated users
GRANT SELECT ON burc_revenue_retention TO authenticated;
GRANT SELECT ON burc_rule_of_40 TO authenticated;
GRANT SELECT ON burc_arr_performance TO authenticated;
GRANT SELECT ON burc_attrition_summary TO authenticated;
GRANT SELECT ON burc_renewal_calendar TO authenticated;
GRANT SELECT ON burc_pipeline_by_stage TO authenticated;
GRANT SELECT ON burc_executive_summary TO authenticated;
