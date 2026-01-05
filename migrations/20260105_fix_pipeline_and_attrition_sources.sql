-- Fix Pipeline and Attrition Data Sources
--
-- Pipeline: Sourced from "Rats and Mice Only" (<50K) + "Dial 2 Risk Profile Summary" (>=50K)
-- Attrition: Sourced from "Attrition" sheet for confirmed revenue at risk
--
-- Weighted Pipeline Calculation:
-- - Best Case: 90% probability
-- - Business Case: 50% probability
-- - Pipeline: 30% probability

-- Add missing columns to burc_pipeline_detail
ALTER TABLE burc_pipeline_detail
ADD COLUMN IF NOT EXISTS weighted_revenue DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS probability DECIMAL(5,2) DEFAULT 0.5,
ADD COLUMN IF NOT EXISTS oracle_agreement TEXT;

-- Add missing columns to burc_attrition
ALTER TABLE burc_attrition
ADD COLUMN IF NOT EXISTS risk_type TEXT DEFAULT 'Partial',
ADD COLUMN IF NOT EXISTS forecast_date DATE,
ADD COLUMN IF NOT EXISTS revenue_2025 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS revenue_2026 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS revenue_2027 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS revenue_2028 DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_at_risk DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS source TEXT;

-- Update burc_executive_summary view to use correct pipeline and attrition totals
DROP VIEW IF EXISTS burc_executive_summary;
CREATE VIEW burc_executive_summary AS
WITH latest_financials AS (
  SELECT * FROM burc_annual_financials WHERE fiscal_year = 2026
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
    COALESCE(SUM(total_revenue), 0) as total_pipeline,
    COALESCE(SUM(weighted_revenue), 0) as weighted_pipeline
  FROM burc_pipeline_detail
  WHERE fiscal_year = 2026
),
attrition_summary AS (
  SELECT
    COALESCE(SUM(revenue_2026), 0) as total_at_risk,
    COUNT(*) as risk_count
  FROM burc_attrition
  WHERE fiscal_year = 2026
)
SELECT
  CURRENT_DATE as snapshot_date,
  COALESCE(lf.nrr_percent, 0) as nrr_percent,
  COALESCE(lf.grr_percent, 100) as grr_percent,
  COALESCE(lf.churn, 0) as annual_churn,
  COALESCE(lf.expansion, 0) as expansion_revenue,
  COALESCE(lf.revenue_growth_percent, 0) as revenue_growth_percent,
  COALESCE(lf.ebita_margin_percent, 15) as ebita_margin_percent,
  COALESCE(lf.rule_of_40_score, 0) as rule_of_40_score,
  COALESCE(lf.rule_of_40_status, 'Unknown') as rule_of_40_status,
  COALESCE(arr.total_arr, lf.gross_revenue) as total_arr,
  COALESCE(tc.active_contracts, 0) as active_contracts,
  COALESCE(tc.total_contract_value, 0) as total_contract_value,
  COALESCE(ps.total_pipeline, 0) as total_pipeline,
  COALESCE(ps.weighted_pipeline, 0) as weighted_pipeline,
  COALESCE(att.total_at_risk, 0) as total_at_risk,
  COALESCE(att.risk_count, 0) as attrition_risk_count,
  COALESCE(lf.nrr_health, 'Unknown') as nrr_health,
  COALESCE(lf.grr_health, 'Unknown') as grr_health
FROM latest_financials lf
CROSS JOIN total_arr arr
CROSS JOIN total_contracts tc
CROSS JOIN pipeline_summary ps
CROSS JOIN attrition_summary att;

-- Data is populated by scripts/sync-pipeline-and-attrition.mjs
-- Run: node scripts/sync-pipeline-and-attrition.mjs
