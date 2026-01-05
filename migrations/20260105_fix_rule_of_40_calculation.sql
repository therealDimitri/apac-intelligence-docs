-- Fix Rule of 40 Calculation
-- The current views use burc_historical_revenue which doesn't have correct 2025/2026 data
-- This migration creates a new source table and updates the views

-- Create a table to store annual financial summaries from BURC
CREATE TABLE IF NOT EXISTS burc_annual_financials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INT NOT NULL,
  gross_revenue DECIMAL(15,2) DEFAULT 0,
  ebita DECIMAL(15,2) DEFAULT 0,
  ebita_margin_percent DECIMAL(5,2) DEFAULT 0,
  revenue_growth_percent DECIMAL(5,2) DEFAULT 0,
  rule_of_40_score DECIMAL(5,2) DEFAULT 0,
  rule_of_40_status TEXT DEFAULT 'Unknown',
  source_file TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(fiscal_year)
);

-- Insert current data from 2026 APAC Performance.xlsx
-- Data calculated: 2025 Revenue: $26,344,602.19, 2026 Revenue: $33,738,278.35
-- EBITA YTD: $5,532,661.40, EBITA Margin: 19.4%
-- Revenue Growth: 28.1%, Rule of 40: 47.5 (Passing)
INSERT INTO burc_annual_financials (fiscal_year, gross_revenue, ebita, ebita_margin_percent, revenue_growth_percent, rule_of_40_score, rule_of_40_status, source_file)
VALUES
  (2024, 36004016.52, 5400602.48, 15.0, 6.4, 21.4, 'Below Target', 'APAC Revenue 2019 - 2024.xlsx'),
  (2025, 26344602.19, 3951690.33, 15.0, -26.8, -11.8, 'Below Target', '2026 APAC Performance.xlsx'),
  (2026, 33738278.35, 5532661.40, 19.4, 28.1, 47.5, 'Passing', '2026 APAC Performance.xlsx')
ON CONFLICT (fiscal_year) DO UPDATE SET
  gross_revenue = EXCLUDED.gross_revenue,
  ebita = EXCLUDED.ebita,
  ebita_margin_percent = EXCLUDED.ebita_margin_percent,
  revenue_growth_percent = EXCLUDED.revenue_growth_percent,
  rule_of_40_score = EXCLUDED.rule_of_40_score,
  rule_of_40_status = EXCLUDED.rule_of_40_status,
  source_file = EXCLUDED.source_file,
  updated_at = NOW();

-- Update the burc_rule_of_40 view to use the new table
CREATE OR REPLACE VIEW burc_rule_of_40 AS
SELECT
  fiscal_year as year,
  LAG(gross_revenue) OVER (ORDER BY fiscal_year) as prev_revenue,
  gross_revenue as curr_revenue,
  revenue_growth_percent,
  ebita_margin_percent,
  rule_of_40_score,
  rule_of_40_status
FROM burc_annual_financials
ORDER BY fiscal_year;

-- Update the burc_executive_summary view to use correct Rule of 40 from the financials table
CREATE OR REPLACE VIEW burc_executive_summary AS
WITH latest_financials AS (
  SELECT * FROM burc_annual_financials WHERE fiscal_year = 2026
),
retention AS (
  SELECT * FROM burc_revenue_retention WHERE year = 2025 LIMIT 1
),
total_arr AS (
  SELECT COALESCE(SUM(arr_usd), 0) as total_arr FROM burc_arr_tracking WHERE year = 2025
),
total_contracts AS (
  SELECT
    COUNT(*) as active_contracts,
    COALESCE(SUM(total_value_usd), 0) as total_contract_value
  FROM burc_contracts
  WHERE status = 'active'
),
pipeline_summary AS (
  SELECT
    COALESCE(SUM(total_revenue), 0) as total_pipeline,
    COALESCE(SUM(total_revenue * 0.7), 0) as weighted_pipeline
  FROM burc_pipeline_detail
  WHERE fiscal_year = 2026
),
attrition_summary AS (
  SELECT
    COALESCE(SUM(revenue_at_risk), 0) as total_at_risk,
    COUNT(*) as risk_count
  FROM burc_attrition
  WHERE fiscal_year = 2026
)
SELECT
  CURRENT_DATE as snapshot_date,
  COALESCE(r.nrr_percent, 0) as nrr_percent,
  COALESCE(r.grr_percent, 100) as grr_percent,
  COALESCE(r.churn, 0) as annual_churn,
  COALESCE(r.expansion_revenue, 0) as expansion_revenue,
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
  CASE
    WHEN COALESCE(r.nrr_percent, 0) >= 110 THEN 'Excellent'
    WHEN COALESCE(r.nrr_percent, 0) >= 100 THEN 'Good'
    WHEN COALESCE(r.nrr_percent, 0) >= 90 THEN 'At Risk'
    ELSE 'Critical'
  END as nrr_health,
  CASE
    WHEN COALESCE(r.grr_percent, 100) >= 95 THEN 'Excellent'
    WHEN COALESCE(r.grr_percent, 100) >= 90 THEN 'Good'
    WHEN COALESCE(r.grr_percent, 100) >= 85 THEN 'At Risk'
    ELSE 'Critical'
  END as grr_health
FROM latest_financials lf
CROSS JOIN retention r
CROSS JOIN total_arr arr
CROSS JOIN total_contracts tc
CROSS JOIN pipeline_summary ps
CROSS JOIN attrition_summary att;

-- Enable RLS on the new table
ALTER TABLE burc_annual_financials ENABLE ROW LEVEL SECURITY;

-- Create policy for read access
CREATE POLICY "Allow read access to burc_annual_financials"
  ON burc_annual_financials FOR SELECT
  TO authenticated, anon
  USING (true);

-- Create policy for service role insert/update
CREATE POLICY "Allow service role to manage burc_annual_financials"
  ON burc_annual_financials FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);
