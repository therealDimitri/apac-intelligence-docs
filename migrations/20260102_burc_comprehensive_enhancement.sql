-- BURC Comprehensive Enhancement Migration
-- Date: 2 January 2026
-- Purpose: Add tables for full BURC data integration (247 files, 7+ years of data)
-- Enables: NRR, GRR, Rule of 40, Product Profitability, Historical Trending

-- ============================================================
-- 1. HISTORICAL REVENUE TABLE (2019-2024 customer-level data)
-- Source: APAC Revenue 2019 - 2024.xlsx
-- ============================================================
CREATE TABLE IF NOT EXISTS burc_historical_revenue (
  id SERIAL PRIMARY KEY,
  parent_company TEXT,
  customer_name TEXT NOT NULL,
  revenue_type TEXT NOT NULL CHECK (revenue_type IN (
    'License Revenue',
    'Maintenance Revenue',
    'Professional Services Revenue',
    'Hardware & Other Revenue',
    'Hosting Revenue',
    'Support Revenue'
  )),
  year_2019 DECIMAL(14,2) DEFAULT 0,
  year_2020 DECIMAL(14,2) DEFAULT 0,
  year_2021 DECIMAL(14,2) DEFAULT 0,
  year_2022 DECIMAL(14,2) DEFAULT 0,
  year_2023 DECIMAL(14,2) DEFAULT 0,
  year_2024 DECIMAL(14,2) DEFAULT 0,
  year_2025 DECIMAL(14,2) DEFAULT 0,
  year_2026 DECIMAL(14,2) DEFAULT 0,
  currency TEXT DEFAULT 'USD',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_synced TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(customer_name, revenue_type)
);

-- ============================================================
-- 2. MONTHLY REVENUE & COGS DETAIL TABLE
-- Source: 28 Monthly Rev and COGS files (2023-2025)
-- ============================================================
CREATE TABLE IF NOT EXISTS burc_monthly_revenue_detail (
  id SERIAL PRIMARY KEY,
  year INTEGER NOT NULL,
  month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
  month_name TEXT,
  revenue_stream TEXT NOT NULL CHECK (revenue_stream IN (
    'License',
    'Maintenance',
    'Professional Services',
    'Hardware',
    'Hosting',
    'Support',
    'Business Case',
    'Other'
  )),
  customer_name TEXT,
  product_line TEXT,
  gross_revenue DECIMAL(14,2) DEFAULT 0,
  cogs DECIMAL(14,2) DEFAULT 0,
  net_revenue DECIMAL(14,2) GENERATED ALWAYS AS (gross_revenue - cogs) STORED,
  margin_percent DECIMAL(5,2) GENERATED ALWAYS AS (
    CASE WHEN gross_revenue > 0 THEN ((gross_revenue - cogs) / gross_revenue) * 100 ELSE 0 END
  ) STORED,
  currency TEXT DEFAULT 'USD',
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_synced TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(year, month, revenue_stream, COALESCE(customer_name, ''), COALESCE(product_line, ''))
);

-- ============================================================
-- 3. CONTRACT RENEWALS TABLE
-- Source: Opal Maint Contracts and Value sheet
-- ============================================================
CREATE TABLE IF NOT EXISTS burc_contracts (
  id SERIAL PRIMARY KEY,
  client_name TEXT NOT NULL,
  solution TEXT,
  annual_value_aud DECIMAL(14,2),
  annual_value_usd DECIMAL(14,2),
  renewal_date DATE,
  contract_end_date DATE,
  comments TEXT,
  exchange_rate DECIMAL(6,4) DEFAULT 0.64,
  auto_renewal BOOLEAN DEFAULT false,
  cpi_applicable BOOLEAN DEFAULT false,
  cpi_percentage DECIMAL(4,2),
  contract_term_months INTEGER,
  contract_status TEXT DEFAULT 'active' CHECK (contract_status IN ('active', 'expired', 'pending_renewal', 'terminated', 'renewed')),
  days_until_renewal INTEGER GENERATED ALWAYS AS (renewal_date - CURRENT_DATE) STORED,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_synced TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_name, COALESCE(solution, ''), renewal_date)
);

-- ============================================================
-- 4. ATTRITION RISK TABLE
-- Source: Attrition sheet + historical attrition files
-- ============================================================
CREATE TABLE IF NOT EXISTS burc_attrition_risk (
  id SERIAL PRIMARY KEY,
  client_name TEXT NOT NULL,
  risk_type TEXT CHECK (risk_type IN ('Full', 'Partial')),
  forecast_date DATE,
  revenue_2024 DECIMAL(14,2) DEFAULT 0,
  revenue_2025 DECIMAL(14,2) DEFAULT 0,
  revenue_2026 DECIMAL(14,2) DEFAULT 0,
  revenue_2027 DECIMAL(14,2) DEFAULT 0,
  revenue_2028 DECIMAL(14,2) DEFAULT 0,
  total_at_risk DECIMAL(14,2) DEFAULT 0,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'mitigated', 'churned', 'retained', 'partial_churn')),
  mitigation_notes TEXT,
  churn_reason TEXT,
  product_affected TEXT,
  snapshot_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_synced TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_name, forecast_date, COALESCE(product_affected, ''))
);

-- ============================================================
-- 5. BUSINESS CASES / PIPELINE TABLE
-- Source: Dial 2 Risk Profile Summary sheets
-- ============================================================
CREATE TABLE IF NOT EXISTS burc_business_cases (
  id SERIAL PRIMARY KEY,
  opportunity_name TEXT NOT NULL,
  client_name TEXT,
  forecast_category TEXT CHECK (forecast_category IN ('Best Case', 'Pipeline', 'Business Case', 'Committed', 'Backlog')),
  closure_date DATE,
  oracle_agreement_number TEXT,
  sw_revenue_date DATE,
  ps_revenue_date DATE,
  maint_revenue_date DATE,
  hw_revenue_date DATE,
  estimated_sw_value DECIMAL(14,2) DEFAULT 0,
  estimated_ps_value DECIMAL(14,2) DEFAULT 0,
  estimated_maint_value DECIMAL(14,2) DEFAULT 0,
  estimated_hw_value DECIMAL(14,2) DEFAULT 0,
  total_value DECIMAL(14,2) GENERATED ALWAYS AS (
    COALESCE(estimated_sw_value, 0) + COALESCE(estimated_ps_value, 0) +
    COALESCE(estimated_maint_value, 0) + COALESCE(estimated_hw_value, 0)
  ) STORED,
  probability DECIMAL(3,2) DEFAULT 0.5,
  stage TEXT DEFAULT 'active',
  owner TEXT,
  snapshot_month TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_synced TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(opportunity_name, closure_date, COALESCE(snapshot_month, ''))
);

-- ============================================================
-- 6. CROSS-CHARGE ALLOCATION TABLE
-- Source: 11 PS Cross Charges files
-- ============================================================
CREATE TABLE IF NOT EXISTS burc_cross_charges (
  id SERIAL PRIMARY KEY,
  year INTEGER NOT NULL,
  month INTEGER NOT NULL,
  source_bu TEXT NOT NULL,
  target_bu TEXT NOT NULL,
  charge_type TEXT CHECK (charge_type IN ('PS', 'Support', 'R&D', 'G&A', 'Other')),
  amount DECIMAL(14,2) NOT NULL,
  hours DECIMAL(10,2),
  rate DECIMAL(10,2),
  description TEXT,
  currency TEXT DEFAULT 'USD',
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_synced TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(year, month, source_bu, target_bu, charge_type)
);

-- ============================================================
-- 7. FX RATES TABLE
-- Source: Exchange rate files
-- ============================================================
CREATE TABLE IF NOT EXISTS burc_fx_rates (
  id SERIAL PRIMARY KEY,
  rate_date DATE NOT NULL,
  currency_from TEXT NOT NULL,
  currency_to TEXT NOT NULL DEFAULT 'USD',
  rate DECIMAL(10,6) NOT NULL,
  rate_type TEXT DEFAULT 'period_end' CHECK (rate_type IN ('period_end', 'average', 'budget')),
  source TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(rate_date, currency_from, currency_to, rate_type)
);

-- ============================================================
-- 8. ARR TRACKING TABLE
-- Source: ARR Target files
-- ============================================================
CREATE TABLE IF NOT EXISTS burc_arr_tracking (
  id SERIAL PRIMARY KEY,
  client_name TEXT NOT NULL,
  cse_owner TEXT,
  arr_usd DECIMAL(14,2) NOT NULL,
  target_pipeline_percent DECIMAL(5,2) DEFAULT 10,
  target_pipeline_value DECIMAL(14,2),
  actual_bookings DECIMAL(14,2) DEFAULT 0,
  variance DECIMAL(14,2),
  year INTEGER NOT NULL,
  quarter TEXT,
  snapshot_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_synced TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_name, year, COALESCE(quarter, ''))
);

-- ============================================================
-- 9. SYNC AUDIT TRAIL TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS burc_sync_audit (
  id SERIAL PRIMARY KEY,
  sync_id UUID DEFAULT gen_random_uuid(),
  sync_type TEXT NOT NULL,
  table_name TEXT NOT NULL,
  operation TEXT CHECK (operation IN ('insert', 'update', 'delete', 'upsert', 'full_sync')),
  records_processed INTEGER DEFAULT 0,
  records_inserted INTEGER DEFAULT 0,
  records_updated INTEGER DEFAULT 0,
  records_deleted INTEGER DEFAULT 0,
  source_file TEXT,
  error_message TEXT,
  duration_ms INTEGER,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 10. Add notes column to burc_waterfall if not exists
-- ============================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'burc_waterfall' AND column_name = 'notes'
  ) THEN
    ALTER TABLE burc_waterfall ADD COLUMN notes TEXT;
  END IF;
END $$;

-- ============================================================
-- 11. NRR/GRR CALCULATION VIEW
-- Net Revenue Retention = (Starting MRR + Expansion - Contraction - Churn) / Starting MRR
-- Gross Revenue Retention = (Starting MRR - Contraction - Churn) / Starting MRR
-- ============================================================
CREATE OR REPLACE VIEW burc_retention_metrics AS
WITH yearly_revenue AS (
  SELECT
    customer_name,
    SUM(year_2023) as revenue_2023,
    SUM(year_2024) as revenue_2024,
    SUM(year_2025) as revenue_2025
  FROM burc_historical_revenue
  WHERE revenue_type = 'Maintenance Revenue'
  GROUP BY customer_name
),
attrition_impact AS (
  SELECT
    COALESCE(SUM(revenue_2024), 0) as churned_2024,
    COALESCE(SUM(revenue_2025), 0) as churned_2025,
    COALESCE(SUM(revenue_2026), 0) as churned_2026
  FROM burc_attrition_risk
  WHERE status IN ('churned', 'partial_churn')
),
totals_2024_2025 AS (
  SELECT
    SUM(revenue_2024) as total_2024,
    SUM(revenue_2025) as total_2025,
    SUM(CASE WHEN revenue_2025 > revenue_2024 THEN revenue_2025 - revenue_2024 ELSE 0 END) as expansion,
    SUM(CASE WHEN revenue_2025 < revenue_2024 AND revenue_2025 > 0 THEN revenue_2024 - revenue_2025 ELSE 0 END) as contraction
  FROM yearly_revenue
),
totals_2023_2024 AS (
  SELECT
    SUM(revenue_2023) as total_2023,
    SUM(revenue_2024) as total_2024,
    SUM(CASE WHEN revenue_2024 > revenue_2023 THEN revenue_2024 - revenue_2023 ELSE 0 END) as expansion_prior,
    SUM(CASE WHEN revenue_2024 < revenue_2023 AND revenue_2024 > 0 THEN revenue_2023 - revenue_2024 ELSE 0 END) as contraction_prior
  FROM yearly_revenue
)
SELECT
  -- Current Period (2024 → 2025)
  t.total_2024 as starting_arr,
  t.total_2025 as ending_arr,
  t.expansion,
  t.contraction,
  a.churned_2025 as churn,
  -- NRR = (Starting + Expansion - Contraction - Churn) / Starting
  CASE WHEN t.total_2024 > 0 THEN
    ROUND(((t.total_2024 + t.expansion - t.contraction - COALESCE(a.churned_2025, 0)) / t.total_2024) * 100, 2)
  ELSE 0 END as nrr_percent,
  -- GRR = (Starting - Contraction - Churn) / Starting (capped at 100%)
  CASE WHEN t.total_2024 > 0 THEN
    LEAST(100, ROUND(((t.total_2024 - t.contraction - COALESCE(a.churned_2025, 0)) / t.total_2024) * 100, 2))
  ELSE 0 END as grr_percent,
  -- Prior Period (2023 → 2024) for comparison
  tp.total_2023 as prior_starting_arr,
  tp.total_2024 as prior_ending_arr,
  CASE WHEN tp.total_2023 > 0 THEN
    ROUND(((tp.total_2023 + tp.expansion_prior - tp.contraction_prior - COALESCE(a.churned_2024, 0)) / tp.total_2023) * 100, 2)
  ELSE 0 END as prior_nrr_percent,
  CASE WHEN tp.total_2023 > 0 THEN
    LEAST(100, ROUND(((tp.total_2023 - tp.contraction_prior - COALESCE(a.churned_2024, 0)) / tp.total_2023) * 100, 2))
  ELSE 0 END as prior_grr_percent
FROM totals_2024_2025 t
CROSS JOIN totals_2023_2024 tp
CROSS JOIN attrition_impact a;

-- ============================================================
-- 12. KPI SUMMARY VIEW
-- ============================================================
CREATE OR REPLACE VIEW burc_kpi_summary AS
WITH revenue_data AS (
  SELECT
    SUM(CASE WHEN stream = 'Maintenance' THEN annual_total ELSE 0 END) as maintenance_revenue,
    SUM(CASE WHEN stream = 'Gross Revenue' THEN annual_total ELSE 0 END) as gross_revenue,
    SUM(CASE WHEN stream = 'Professional Services' THEN annual_total ELSE 0 END) as ps_revenue,
    SUM(CASE WHEN stream = 'License' THEN annual_total ELSE 0 END) as license_revenue
  FROM burc_revenue_streams
  WHERE category = 'forecast'
),
contract_data AS (
  SELECT
    COUNT(*) as total_contracts,
    COUNT(*) FILTER (WHERE days_until_renewal <= 90 AND days_until_renewal > 0) as contracts_expiring_90days,
    COUNT(*) FILTER (WHERE days_until_renewal <= 30 AND days_until_renewal > 0) as contracts_expiring_30days,
    SUM(annual_value_usd) FILTER (WHERE days_until_renewal <= 90 AND days_until_renewal > 0) as value_at_risk_90days,
    SUM(annual_value_usd) as total_contract_value
  FROM burc_contracts
  WHERE contract_status = 'active'
),
attrition_data AS (
  SELECT
    COALESCE(SUM(total_at_risk), 0) as total_attrition_risk,
    COUNT(*) FILTER (WHERE status = 'open') as open_risks,
    COUNT(*) FILTER (WHERE risk_type = 'Full') as full_churn_risks
  FROM burc_attrition_risk
  WHERE status = 'open'
),
pipeline_data AS (
  SELECT
    SUM(CASE WHEN forecast_category = 'Committed' THEN total_value ELSE 0 END) as committed_pipeline,
    SUM(CASE WHEN forecast_category = 'Best Case' THEN total_value ELSE 0 END) as best_case_pipeline,
    SUM(CASE WHEN forecast_category = 'Pipeline' THEN total_value ELSE 0 END) as pipeline_value,
    COUNT(*) as total_opportunities
  FROM burc_business_cases
  WHERE stage = 'active'
),
retention AS (
  SELECT nrr_percent, grr_percent FROM burc_retention_metrics
)
SELECT
  r.maintenance_revenue,
  r.gross_revenue,
  r.ps_revenue,
  r.license_revenue,
  c.total_contracts,
  c.contracts_expiring_90days,
  c.contracts_expiring_30days,
  c.value_at_risk_90days,
  c.total_contract_value,
  a.total_attrition_risk,
  a.open_risks as attrition_open_risks,
  a.full_churn_risks,
  p.committed_pipeline,
  p.best_case_pipeline,
  p.pipeline_value,
  p.total_opportunities,
  ret.nrr_percent,
  ret.grr_percent,
  -- Rule of 40: Revenue Growth % + EBITA Margin %
  -- (Placeholder - needs actual growth calculation)
  0 as rule_of_40
FROM revenue_data r
CROSS JOIN contract_data c
CROSS JOIN attrition_data a
CROSS JOIN pipeline_data p
CROSS JOIN retention ret;

-- ============================================================
-- 13. INDEXES FOR PERFORMANCE
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_historical_revenue_customer ON burc_historical_revenue(customer_name);
CREATE INDEX IF NOT EXISTS idx_historical_revenue_type ON burc_historical_revenue(revenue_type);

CREATE INDEX IF NOT EXISTS idx_monthly_revenue_year_month ON burc_monthly_revenue_detail(year, month);
CREATE INDEX IF NOT EXISTS idx_monthly_revenue_stream ON burc_monthly_revenue_detail(revenue_stream);
CREATE INDEX IF NOT EXISTS idx_monthly_revenue_customer ON burc_monthly_revenue_detail(customer_name);

CREATE INDEX IF NOT EXISTS idx_contracts_renewal ON burc_contracts(renewal_date);
CREATE INDEX IF NOT EXISTS idx_contracts_status ON burc_contracts(contract_status);
CREATE INDEX IF NOT EXISTS idx_contracts_client ON burc_contracts(client_name);

CREATE INDEX IF NOT EXISTS idx_attrition_status ON burc_attrition_risk(status);
CREATE INDEX IF NOT EXISTS idx_attrition_client ON burc_attrition_risk(client_name);
CREATE INDEX IF NOT EXISTS idx_attrition_date ON burc_attrition_risk(forecast_date);

CREATE INDEX IF NOT EXISTS idx_business_cases_category ON burc_business_cases(forecast_category);
CREATE INDEX IF NOT EXISTS idx_business_cases_client ON burc_business_cases(client_name);
CREATE INDEX IF NOT EXISTS idx_business_cases_closure ON burc_business_cases(closure_date);

CREATE INDEX IF NOT EXISTS idx_cross_charges_year_month ON burc_cross_charges(year, month);
CREATE INDEX IF NOT EXISTS idx_fx_rates_date ON burc_fx_rates(rate_date);
CREATE INDEX IF NOT EXISTS idx_arr_tracking_client ON burc_arr_tracking(client_name);
CREATE INDEX IF NOT EXISTS idx_sync_audit_created ON burc_sync_audit(created_at);
CREATE INDEX IF NOT EXISTS idx_sync_audit_table ON burc_sync_audit(table_name);

-- ============================================================
-- 14. RLS POLICIES
-- ============================================================
ALTER TABLE burc_historical_revenue ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_monthly_revenue_detail ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_attrition_risk ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_business_cases ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_cross_charges ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_fx_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_arr_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_sync_audit ENABLE ROW LEVEL SECURITY;

-- Read policies for authenticated users
CREATE POLICY IF NOT EXISTS "authenticated_read_historical_revenue" ON burc_historical_revenue FOR SELECT TO authenticated USING (true);
CREATE POLICY IF NOT EXISTS "authenticated_read_monthly_revenue" ON burc_monthly_revenue_detail FOR SELECT TO authenticated USING (true);
CREATE POLICY IF NOT EXISTS "authenticated_read_contracts" ON burc_contracts FOR SELECT TO authenticated USING (true);
CREATE POLICY IF NOT EXISTS "authenticated_read_attrition" ON burc_attrition_risk FOR SELECT TO authenticated USING (true);
CREATE POLICY IF NOT EXISTS "authenticated_read_business_cases" ON burc_business_cases FOR SELECT TO authenticated USING (true);
CREATE POLICY IF NOT EXISTS "authenticated_read_cross_charges" ON burc_cross_charges FOR SELECT TO authenticated USING (true);
CREATE POLICY IF NOT EXISTS "authenticated_read_fx_rates" ON burc_fx_rates FOR SELECT TO authenticated USING (true);
CREATE POLICY IF NOT EXISTS "authenticated_read_arr" ON burc_arr_tracking FOR SELECT TO authenticated USING (true);
CREATE POLICY IF NOT EXISTS "authenticated_read_audit" ON burc_sync_audit FOR SELECT TO authenticated USING (true);

-- Service role full access
CREATE POLICY IF NOT EXISTS "service_role_all_historical_revenue" ON burc_historical_revenue FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "service_role_all_monthly_revenue" ON burc_monthly_revenue_detail FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "service_role_all_contracts" ON burc_contracts FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "service_role_all_attrition" ON burc_attrition_risk FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "service_role_all_business_cases" ON burc_business_cases FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "service_role_all_cross_charges" ON burc_cross_charges FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "service_role_all_fx_rates" ON burc_fx_rates FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "service_role_all_arr" ON burc_arr_tracking FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "service_role_all_audit" ON burc_sync_audit FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Anon read access for public dashboards
GRANT SELECT ON burc_historical_revenue TO anon;
GRANT SELECT ON burc_monthly_revenue_detail TO anon;
GRANT SELECT ON burc_contracts TO anon;
GRANT SELECT ON burc_attrition_risk TO anon;
GRANT SELECT ON burc_business_cases TO anon;
GRANT SELECT ON burc_fx_rates TO anon;
GRANT SELECT ON burc_arr_tracking TO anon;
GRANT SELECT ON burc_kpi_summary TO anon;
GRANT SELECT ON burc_retention_metrics TO anon;

GRANT SELECT ON burc_historical_revenue TO authenticated;
GRANT SELECT ON burc_monthly_revenue_detail TO authenticated;
GRANT SELECT ON burc_contracts TO authenticated;
GRANT SELECT ON burc_attrition_risk TO authenticated;
GRANT SELECT ON burc_business_cases TO authenticated;
GRANT SELECT ON burc_cross_charges TO authenticated;
GRANT SELECT ON burc_fx_rates TO authenticated;
GRANT SELECT ON burc_arr_tracking TO authenticated;
GRANT SELECT ON burc_sync_audit TO authenticated;
GRANT SELECT ON burc_kpi_summary TO authenticated;
GRANT SELECT ON burc_retention_metrics TO authenticated;
