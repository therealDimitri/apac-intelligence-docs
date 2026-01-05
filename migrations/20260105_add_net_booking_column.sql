-- Add Net Booking column to burc_pipeline_detail
-- This stores the "Total Net Booking" value from the Excel (after margin deduction)
-- Values are stored in dollars (source is in $M, converted during sync)

ALTER TABLE burc_pipeline_detail
ADD COLUMN IF NOT EXISTS net_booking DECIMAL(15,2) DEFAULT 0;

-- Update the executive summary view to use net_booking
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
booking_summary AS (
  SELECT
    COALESCE(SUM(net_booking), 0) as total_net_booking,
    COALESCE(SUM(weighted_revenue), 0) as weighted_net_booking
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
  -- Use net booking terminology
  COALESCE(bs.total_net_booking, 0) as total_pipeline,
  COALESCE(bs.total_net_booking, 0) as total_net_booking,
  COALESCE(bs.weighted_net_booking, 0) as weighted_pipeline,
  COALESCE(bs.weighted_net_booking, 0) as weighted_net_booking,
  COALESCE(att.total_at_risk, 0) as total_at_risk,
  COALESCE(att.risk_count, 0) as attrition_risk_count,
  COALESCE(lf.nrr_health, 'Unknown') as nrr_health,
  COALESCE(lf.grr_health, 'Unknown') as grr_health
FROM latest_financials lf
CROSS JOIN total_arr arr
CROSS JOIN total_contracts tc
CROSS JOIN booking_summary bs
CROSS JOIN attrition_summary att;

-- Comment for documentation
COMMENT ON COLUMN burc_pipeline_detail.net_booking IS 'Total Net Booking from Excel column 24 (in dollars, source is $M)';
