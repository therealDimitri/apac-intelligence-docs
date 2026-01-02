-- BURC Comprehensive Data Tables
-- Created: 2 January 2026
-- Purpose: Store all untapped BURC data from Excel files

-- ========================================
-- 1. Monthly EBITA Tracking
-- ========================================
CREATE TABLE IF NOT EXISTS burc_monthly_ebita (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  month DATE NOT NULL,
  fiscal_year INTEGER NOT NULL,
  fiscal_month INTEGER NOT NULL,
  net_revenue NUMERIC(15,2) DEFAULT 0,
  cogs NUMERIC(15,2) DEFAULT 0,
  gross_profit NUMERIC(15,2) DEFAULT 0,
  opex NUMERIC(15,2) DEFAULT 0,
  ebita NUMERIC(15,2) DEFAULT 0,
  ebita_margin NUMERIC(5,2) DEFAULT 0,
  budget_ebita NUMERIC(15,2) DEFAULT 0,
  variance_to_budget NUMERIC(15,2) DEFAULT 0,
  prior_year_ebita NUMERIC(15,2) DEFAULT 0,
  yoy_growth NUMERIC(5,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(month)
);

-- ========================================
-- 2. Monthly Revenue Composition
-- ========================================
CREATE TABLE IF NOT EXISTS burc_monthly_revenue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  month DATE NOT NULL,
  fiscal_year INTEGER NOT NULL,
  fiscal_month INTEGER NOT NULL,
  revenue_type VARCHAR(50) NOT NULL, -- SW, PS, Maint, HW
  revenue_category VARCHAR(50), -- Runrate, BC, Pipeline
  net_revenue NUMERIC(15,2) DEFAULT 0,
  cogs NUMERIC(15,2) DEFAULT 0,
  gross_profit NUMERIC(15,2) DEFAULT 0,
  gross_margin NUMERIC(5,2) DEFAULT 0,
  budget NUMERIC(15,2) DEFAULT 0,
  prior_year NUMERIC(15,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(month, revenue_type, revenue_category)
);

-- ========================================
-- 3. Risk Profile Summary (Dial 2)
-- ========================================
CREATE TABLE IF NOT EXISTS burc_risk_profile (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name VARCHAR(255) NOT NULL,
  risk_score NUMERIC(5,2) DEFAULT 0,
  risk_category VARCHAR(50), -- Critical, High, Medium, Low
  financial_health VARCHAR(50),
  engagement_score NUMERIC(5,2) DEFAULT 0,
  satisfaction_score NUMERIC(5,2) DEFAULT 0,
  contract_risk VARCHAR(50),
  revenue_at_risk NUMERIC(15,2) DEFAULT 0,
  risk_factors JSONB DEFAULT '[]',
  mitigation_status VARCHAR(50),
  last_review_date DATE,
  owner VARCHAR(255),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_name)
);

-- ========================================
-- 4. YoY Quarterly Comparison
-- ========================================
CREATE TABLE IF NOT EXISTS burc_quarterly_comparison (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  metric_name VARCHAR(100) NOT NULL,
  metric_category VARCHAR(100),
  q1_cy NUMERIC(15,2) DEFAULT 0,
  q2_cy NUMERIC(15,2) DEFAULT 0,
  q3_cy NUMERIC(15,2) DEFAULT 0,
  q4_cy NUMERIC(15,2) DEFAULT 0,
  total_cy NUMERIC(15,2) DEFAULT 0,
  q1_py NUMERIC(15,2) DEFAULT 0,
  q2_py NUMERIC(15,2) DEFAULT 0,
  q3_py NUMERIC(15,2) DEFAULT 0,
  q4_py NUMERIC(15,2) DEFAULT 0,
  total_py NUMERIC(15,2) DEFAULT 0,
  yoy_variance NUMERIC(15,2) DEFAULT 0,
  yoy_variance_pct NUMERIC(5,2) DEFAULT 0,
  comparison_year INTEGER NOT NULL, -- e.g., 2026
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(metric_name, comparison_year)
);

-- ========================================
-- 5. Operating Expenses Detail
-- ========================================
CREATE TABLE IF NOT EXISTS burc_opex (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expense_category VARCHAR(100) NOT NULL,
  expense_type VARCHAR(100),
  fiscal_year INTEGER NOT NULL,
  fiscal_month INTEGER,
  amount NUMERIC(15,2) DEFAULT 0,
  budget NUMERIC(15,2) DEFAULT 0,
  variance NUMERIC(15,2) DEFAULT 0,
  cost_centre VARCHAR(100),
  department VARCHAR(100),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(expense_category, expense_type, fiscal_year, fiscal_month)
);

-- ========================================
-- 6. Headcount Summary
-- ========================================
CREATE TABLE IF NOT EXISTS burc_headcount (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  department VARCHAR(100) NOT NULL,
  role_category VARCHAR(100),
  fiscal_year INTEGER NOT NULL,
  fiscal_month INTEGER,
  actual_headcount INTEGER DEFAULT 0,
  budgeted_headcount INTEGER DEFAULT 0,
  fte NUMERIC(5,2) DEFAULT 0,
  contractors INTEGER DEFAULT 0,
  open_positions INTEGER DEFAULT 0,
  avg_cost_per_head NUMERIC(15,2) DEFAULT 0,
  total_cost NUMERIC(15,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(department, role_category, fiscal_year, fiscal_month)
);

-- ========================================
-- 7. Small Deals (Rats and Mice)
-- ========================================
CREATE TABLE IF NOT EXISTS burc_small_deals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name VARCHAR(255) NOT NULL,
  deal_name VARCHAR(255),
  deal_type VARCHAR(50), -- SW, PS, Maint, HW
  stage VARCHAR(50),
  probability INTEGER DEFAULT 0,
  value_aud NUMERIC(15,2) DEFAULT 0,
  value_usd NUMERIC(15,2) DEFAULT 0,
  expected_close_date DATE,
  owner VARCHAR(255),
  product VARCHAR(255),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- 8. Strategic Initiatives
-- ========================================
CREATE TABLE IF NOT EXISTS burc_initiatives (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  initiative_name VARCHAR(255) NOT NULL,
  category VARCHAR(100),
  status VARCHAR(50), -- Planning, In Progress, Completed, On Hold
  priority VARCHAR(20), -- Critical, High, Medium, Low
  owner VARCHAR(255),
  start_date DATE,
  target_date DATE,
  completion_date DATE,
  budget NUMERIC(15,2) DEFAULT 0,
  actual_spend NUMERIC(15,2) DEFAULT 0,
  expected_revenue_impact NUMERIC(15,2) DEFAULT 0,
  expected_cost_savings NUMERIC(15,2) DEFAULT 0,
  kpis JSONB DEFAULT '[]',
  milestones JSONB DEFAULT '[]',
  risks JSONB DEFAULT '[]',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- 9. Accounts Receivable Aging
-- ========================================
CREATE TABLE IF NOT EXISTS burc_ar_aging (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name VARCHAR(255) NOT NULL,
  invoice_number VARCHAR(100),
  invoice_date DATE,
  due_date DATE,
  amount NUMERIC(15,2) DEFAULT 0,
  amount_paid NUMERIC(15,2) DEFAULT 0,
  amount_outstanding NUMERIC(15,2) DEFAULT 0,
  days_outstanding INTEGER DEFAULT 0,
  aging_bucket VARCHAR(50), -- Current, 30, 60, 90, 120+
  collection_status VARCHAR(50),
  last_contact_date DATE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- 10. Critical Suppliers
-- ========================================
CREATE TABLE IF NOT EXISTS burc_critical_suppliers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_name VARCHAR(255) NOT NULL,
  vendor_category VARCHAR(100),
  criticality VARCHAR(20), -- Critical, High, Medium, Low
  annual_spend NUMERIC(15,2) DEFAULT 0,
  contract_end_date DATE,
  primary_contact VARCHAR(255),
  payment_terms VARCHAR(100),
  risk_assessment VARCHAR(50),
  alternative_vendors JSONB DEFAULT '[]',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(vendor_name)
);

-- ========================================
-- 11. Revenue by Product
-- ========================================
CREATE TABLE IF NOT EXISTS burc_product_revenue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_name VARCHAR(255) NOT NULL,
  product_category VARCHAR(100), -- SW, PS, Maint, HW
  fiscal_year INTEGER NOT NULL,
  fiscal_month INTEGER,
  revenue NUMERIC(15,2) DEFAULT 0,
  cogs NUMERIC(15,2) DEFAULT 0,
  gross_margin NUMERIC(5,2) DEFAULT 0,
  units_sold INTEGER DEFAULT 0,
  avg_deal_size NUMERIC(15,2) DEFAULT 0,
  customer_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(product_name, fiscal_year, fiscal_month)
);

-- ========================================
-- 12. COGS Detail
-- ========================================
CREATE TABLE IF NOT EXISTS burc_cogs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name VARCHAR(255),
  product_name VARCHAR(255),
  cogs_category VARCHAR(100) NOT NULL, -- SW, PS, Maint, HW
  fiscal_year INTEGER NOT NULL,
  fiscal_month INTEGER,
  amount NUMERIC(15,2) DEFAULT 0,
  cost_type VARCHAR(100), -- Labour, Materials, Third Party, etc.
  vendor VARCHAR(255),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- Enable RLS on all new tables
-- ========================================
ALTER TABLE burc_monthly_ebita ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_monthly_revenue ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_risk_profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_quarterly_comparison ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_opex ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_headcount ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_small_deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_initiatives ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_ar_aging ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_critical_suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_product_revenue ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_cogs ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for authenticated users
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN
    SELECT unnest(ARRAY[
      'burc_monthly_ebita',
      'burc_monthly_revenue',
      'burc_risk_profile',
      'burc_quarterly_comparison',
      'burc_opex',
      'burc_headcount',
      'burc_small_deals',
      'burc_initiatives',
      'burc_ar_aging',
      'burc_critical_suppliers',
      'burc_product_revenue',
      'burc_cogs'
    ])
  LOOP
    EXECUTE format('
      CREATE POLICY IF NOT EXISTS "authenticated_read_%I" ON %I
        FOR SELECT TO authenticated USING (true);

      CREATE POLICY IF NOT EXISTS "service_role_all_%I" ON %I
        FOR ALL TO service_role USING (true);
    ', tbl, tbl, tbl, tbl);
  END LOOP;
END $$;

-- ========================================
-- Create summary views
-- ========================================

-- Monthly Performance Summary View
CREATE OR REPLACE VIEW burc_monthly_performance AS
SELECT
  e.month,
  e.fiscal_year,
  e.fiscal_month,
  e.net_revenue,
  e.cogs,
  e.gross_profit,
  e.opex,
  e.ebita,
  e.ebita_margin,
  e.budget_ebita,
  e.variance_to_budget,
  e.yoy_growth,
  COALESCE(h.total_headcount, 0) as headcount,
  CASE
    WHEN COALESCE(h.total_headcount, 0) > 0
    THEN e.net_revenue / h.total_headcount
    ELSE 0
  END as revenue_per_head
FROM burc_monthly_ebita e
LEFT JOIN (
  SELECT fiscal_year, fiscal_month, SUM(actual_headcount) as total_headcount
  FROM burc_headcount
  GROUP BY fiscal_year, fiscal_month
) h ON e.fiscal_year = h.fiscal_year AND e.fiscal_month = h.fiscal_month
ORDER BY e.month DESC;

-- Risk Summary View
CREATE OR REPLACE VIEW burc_risk_summary AS
SELECT
  risk_category,
  COUNT(*) as client_count,
  SUM(revenue_at_risk) as total_revenue_at_risk,
  AVG(risk_score) as avg_risk_score,
  AVG(engagement_score) as avg_engagement,
  AVG(satisfaction_score) as avg_satisfaction
FROM burc_risk_profile
GROUP BY risk_category
ORDER BY
  CASE risk_category
    WHEN 'Critical' THEN 1
    WHEN 'High' THEN 2
    WHEN 'Medium' THEN 3
    WHEN 'Low' THEN 4
    ELSE 5
  END;

-- AR Aging Summary View
CREATE OR REPLACE VIEW burc_ar_aging_summary AS
SELECT
  aging_bucket,
  COUNT(*) as invoice_count,
  SUM(amount_outstanding) as total_outstanding,
  AVG(days_outstanding) as avg_days,
  COUNT(DISTINCT client_name) as client_count
FROM burc_ar_aging
WHERE amount_outstanding > 0
GROUP BY aging_bucket
ORDER BY
  CASE aging_bucket
    WHEN 'Current' THEN 1
    WHEN '30' THEN 2
    WHEN '60' THEN 3
    WHEN '90' THEN 4
    WHEN '120+' THEN 5
    ELSE 6
  END;

-- Initiative Status Summary
CREATE OR REPLACE VIEW burc_initiative_summary AS
SELECT
  status,
  priority,
  COUNT(*) as initiative_count,
  SUM(budget) as total_budget,
  SUM(actual_spend) as total_spend,
  SUM(expected_revenue_impact) as total_revenue_impact,
  SUM(expected_cost_savings) as total_cost_savings
FROM burc_initiatives
GROUP BY status, priority
ORDER BY
  CASE status
    WHEN 'In Progress' THEN 1
    WHEN 'Planning' THEN 2
    WHEN 'Completed' THEN 3
    WHEN 'On Hold' THEN 4
    ELSE 5
  END,
  CASE priority
    WHEN 'Critical' THEN 1
    WHEN 'High' THEN 2
    WHEN 'Medium' THEN 3
    WHEN 'Low' THEN 4
    ELSE 5
  END;

COMMENT ON TABLE burc_monthly_ebita IS 'Monthly EBITA tracking from APAC BURC - Monthly EBITA sheet';
COMMENT ON TABLE burc_monthly_revenue IS 'Monthly revenue by type from APAC BURC - Monthly NR Comp sheet';
COMMENT ON TABLE burc_risk_profile IS 'Client risk profiles from Dial 2 Risk Profile Summary sheet';
COMMENT ON TABLE burc_quarterly_comparison IS 'YoY quarterly comparison from 26 vs 25 Q Comparison sheet';
COMMENT ON TABLE burc_opex IS 'Operating expenses from OPEX sheet';
COMMENT ON TABLE burc_headcount IS 'Headcount tracking from Headcount Summary sheet';
COMMENT ON TABLE burc_small_deals IS 'Small deals pipeline from Rats and Mice Only sheet';
COMMENT ON TABLE burc_initiatives IS 'Strategic initiatives from APAC Initiative 2025 sheet';
COMMENT ON TABLE burc_ar_aging IS 'Accounts receivable aging from Aged Debt (AR) sheet';
COMMENT ON TABLE burc_critical_suppliers IS 'Critical suppliers from Critical Supplier List APAC.xlsx';
COMMENT ON TABLE burc_product_revenue IS 'Revenue by product from various pivot sheets';
COMMENT ON TABLE burc_cogs IS 'Cost of goods sold detail from COGS sheets';

-- ========================================
-- 13. Historical Revenue Detail (84,901 rows from APAC Revenue 2019-2024.xlsx)
-- ========================================
CREATE TABLE IF NOT EXISTS burc_historical_revenue_detail (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name VARCHAR(255),
  parent_company VARCHAR(255),
  product VARCHAR(255),
  revenue_type VARCHAR(50), -- SW, PS, Maint, HW
  revenue_category VARCHAR(100),
  fiscal_year INTEGER NOT NULL,
  fiscal_month INTEGER,
  calendar_year INTEGER,
  calendar_month INTEGER,
  amount_aud NUMERIC(15,2) DEFAULT 0,
  amount_usd NUMERIC(15,2) DEFAULT 0,
  cogs_aud NUMERIC(15,2) DEFAULT 0,
  cogs_usd NUMERIC(15,2) DEFAULT 0,
  gross_profit NUMERIC(15,2) DEFAULT 0,
  quantity INTEGER DEFAULT 0,
  unit_price NUMERIC(15,2) DEFAULT 0,
  cost_centre VARCHAR(100),
  gl_account VARCHAR(100),
  invoice_number VARCHAR(100),
  transaction_date DATE,
  source_file VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_burc_hist_rev_client ON burc_historical_revenue_detail(client_name);
CREATE INDEX IF NOT EXISTS idx_burc_hist_rev_year ON burc_historical_revenue_detail(fiscal_year);
CREATE INDEX IF NOT EXISTS idx_burc_hist_rev_type ON burc_historical_revenue_detail(revenue_type);

-- ========================================
-- 14. PS Cross Charges
-- ========================================
CREATE TABLE IF NOT EXISTS burc_ps_cross_charges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_region VARCHAR(100) NOT NULL,
  target_region VARCHAR(100) NOT NULL,
  employee_name VARCHAR(255),
  project_name VARCHAR(255),
  client_name VARCHAR(255),
  fiscal_year INTEGER NOT NULL,
  fiscal_month INTEGER NOT NULL,
  hours NUMERIC(10,2) DEFAULT 0,
  rate NUMERIC(15,2) DEFAULT 0,
  amount NUMERIC(15,2) DEFAULT 0,
  charge_type VARCHAR(100),
  approved BOOLEAN DEFAULT false,
  approved_by VARCHAR(255),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(source_region, target_region, employee_name, project_name, fiscal_year, fiscal_month)
);

-- ========================================
-- 15. Support Metrics
-- ========================================
CREATE TABLE IF NOT EXISTS burc_support_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  fiscal_month INTEGER NOT NULL,
  total_tickets INTEGER DEFAULT 0,
  new_tickets INTEGER DEFAULT 0,
  closed_tickets INTEGER DEFAULT 0,
  open_tickets INTEGER DEFAULT 0,
  escalations INTEGER DEFAULT 0,
  p1_tickets INTEGER DEFAULT 0,
  p2_tickets INTEGER DEFAULT 0,
  p3_tickets INTEGER DEFAULT 0,
  p4_tickets INTEGER DEFAULT 0,
  avg_resolution_hours NUMERIC(10,2) DEFAULT 0,
  sla_met_percent NUMERIC(5,2) DEFAULT 0,
  csat_score NUMERIC(5,2) DEFAULT 0,
  support_cost NUMERIC(15,2) DEFAULT 0,
  cost_per_ticket NUMERIC(15,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(fiscal_year, fiscal_month)
);

-- ========================================
-- 16. Budget vs Actuals
-- ========================================
CREATE TABLE IF NOT EXISTS burc_budget_actuals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  metric_name VARCHAR(100) NOT NULL,
  metric_category VARCHAR(100), -- Revenue, COGS, OPEX, EBITA
  revenue_type VARCHAR(50), -- SW, PS, Maint, HW
  fiscal_year INTEGER NOT NULL,
  fiscal_month INTEGER,
  budget NUMERIC(15,2) DEFAULT 0,
  actual NUMERIC(15,2) DEFAULT 0,
  variance NUMERIC(15,2) DEFAULT 0,
  variance_pct NUMERIC(5,2) DEFAULT 0,
  prior_year NUMERIC(15,2) DEFAULT 0,
  yoy_variance NUMERIC(15,2) DEFAULT 0,
  forecast NUMERIC(15,2) DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(metric_name, revenue_type, fiscal_year, fiscal_month)
);

-- ========================================
-- 17. Collections Data
-- ========================================
CREATE TABLE IF NOT EXISTS burc_collections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name VARCHAR(255) NOT NULL,
  invoice_number VARCHAR(100),
  invoice_date DATE,
  invoice_amount NUMERIC(15,2) DEFAULT 0,
  payment_date DATE,
  payment_amount NUMERIC(15,2) DEFAULT 0,
  payment_method VARCHAR(50),
  days_to_pay INTEGER DEFAULT 0,
  fiscal_year INTEGER,
  fiscal_month INTEGER,
  quarter VARCHAR(10),
  collection_status VARCHAR(50),
  collector VARCHAR(255),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- 18. Exchange Rates History
-- ========================================
CREATE TABLE IF NOT EXISTS burc_exchange_rates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  currency_pair VARCHAR(10) NOT NULL, -- e.g., AUD/USD
  rate_type VARCHAR(50) NOT NULL, -- Period End, Average, Budget
  fiscal_year INTEGER NOT NULL,
  fiscal_month INTEGER,
  rate NUMERIC(10,6) NOT NULL,
  effective_date DATE,
  source VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(currency_pair, rate_type, fiscal_year, fiscal_month)
);

-- ========================================
-- 19. Sales Forecast History
-- ========================================
CREATE TABLE IF NOT EXISTS burc_sales_forecast (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  forecast_date DATE NOT NULL,
  client_name VARCHAR(255),
  opportunity_name VARCHAR(255),
  revenue_type VARCHAR(50), -- SW, PS, Maint, HW
  stage VARCHAR(100),
  probability INTEGER DEFAULT 0,
  amount NUMERIC(15,2) DEFAULT 0,
  weighted_amount NUMERIC(15,2) DEFAULT 0,
  expected_close_date DATE,
  actual_close_date DATE,
  won BOOLEAN,
  owner VARCHAR(255),
  product VARCHAR(255),
  forecast_category VARCHAR(50), -- Commit, Best Case, Pipeline
  fiscal_quarter VARCHAR(10),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_burc_forecast_date ON burc_sales_forecast(forecast_date);
CREATE INDEX IF NOT EXISTS idx_burc_forecast_client ON burc_sales_forecast(client_name);

-- ========================================
-- 20. Monthly BURC Snapshots
-- ========================================
CREATE TABLE IF NOT EXISTS burc_monthly_snapshots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  snapshot_month DATE NOT NULL,
  fiscal_year INTEGER NOT NULL,
  fiscal_month INTEGER NOT NULL,

  -- Revenue
  sw_revenue NUMERIC(15,2) DEFAULT 0,
  ps_revenue NUMERIC(15,2) DEFAULT 0,
  maint_revenue NUMERIC(15,2) DEFAULT 0,
  hw_revenue NUMERIC(15,2) DEFAULT 0,
  total_revenue NUMERIC(15,2) DEFAULT 0,

  -- COGS
  sw_cogs NUMERIC(15,2) DEFAULT 0,
  ps_cogs NUMERIC(15,2) DEFAULT 0,
  maint_cogs NUMERIC(15,2) DEFAULT 0,
  hw_cogs NUMERIC(15,2) DEFAULT 0,
  total_cogs NUMERIC(15,2) DEFAULT 0,

  -- Gross Profit
  sw_gp NUMERIC(15,2) DEFAULT 0,
  ps_gp NUMERIC(15,2) DEFAULT 0,
  maint_gp NUMERIC(15,2) DEFAULT 0,
  hw_gp NUMERIC(15,2) DEFAULT 0,
  total_gp NUMERIC(15,2) DEFAULT 0,

  -- OPEX & EBITA
  total_opex NUMERIC(15,2) DEFAULT 0,
  ebita NUMERIC(15,2) DEFAULT 0,
  ebita_margin NUMERIC(5,2) DEFAULT 0,

  -- Metrics
  nrr_percent NUMERIC(5,2) DEFAULT 0,
  grr_percent NUMERIC(5,2) DEFAULT 0,
  rule_of_40 NUMERIC(5,2) DEFAULT 0,
  headcount INTEGER DEFAULT 0,
  revenue_per_head NUMERIC(15,2) DEFAULT 0,

  -- Pipeline
  total_pipeline NUMERIC(15,2) DEFAULT 0,
  weighted_pipeline NUMERIC(15,2) DEFAULT 0,

  -- Risk
  attrition_risk_count INTEGER DEFAULT 0,
  revenue_at_risk NUMERIC(15,2) DEFAULT 0,

  source_file VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(snapshot_month)
);

-- Enable RLS on new tables
ALTER TABLE burc_historical_revenue_detail ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_ps_cross_charges ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_support_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_budget_actuals ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_exchange_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_sales_forecast ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_monthly_snapshots ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for new tables
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN
    SELECT unnest(ARRAY[
      'burc_historical_revenue_detail',
      'burc_ps_cross_charges',
      'burc_support_metrics',
      'burc_budget_actuals',
      'burc_collections',
      'burc_exchange_rates',
      'burc_sales_forecast',
      'burc_monthly_snapshots'
    ])
  LOOP
    EXECUTE format('
      DROP POLICY IF EXISTS "authenticated_read_%I" ON %I;
      CREATE POLICY "authenticated_read_%I" ON %I
        FOR SELECT TO authenticated USING (true);

      DROP POLICY IF EXISTS "service_role_all_%I" ON %I;
      CREATE POLICY "service_role_all_%I" ON %I
        FOR ALL TO service_role USING (true);
    ', tbl, tbl, tbl, tbl, tbl, tbl, tbl, tbl);
  END LOOP;
END $$;

-- ========================================
-- Summary Views for Historical Data
-- ========================================

-- Revenue Trend by Year
CREATE OR REPLACE VIEW burc_revenue_trend AS
SELECT
  fiscal_year,
  SUM(CASE WHEN revenue_type = 'SW' THEN amount_usd ELSE 0 END) as sw_revenue,
  SUM(CASE WHEN revenue_type = 'PS' THEN amount_usd ELSE 0 END) as ps_revenue,
  SUM(CASE WHEN revenue_type = 'Maint' THEN amount_usd ELSE 0 END) as maint_revenue,
  SUM(CASE WHEN revenue_type = 'HW' THEN amount_usd ELSE 0 END) as hw_revenue,
  SUM(amount_usd) as total_revenue,
  COUNT(DISTINCT client_name) as client_count
FROM burc_historical_revenue_detail
GROUP BY fiscal_year
ORDER BY fiscal_year;

-- Client Revenue Summary
CREATE OR REPLACE VIEW burc_client_revenue_summary AS
SELECT
  client_name,
  parent_company,
  COUNT(DISTINCT fiscal_year) as years_active,
  SUM(amount_usd) as lifetime_revenue,
  AVG(amount_usd) as avg_annual_revenue,
  MAX(fiscal_year) as last_revenue_year,
  SUM(CASE WHEN fiscal_year = 2024 THEN amount_usd ELSE 0 END) as revenue_2024,
  SUM(CASE WHEN fiscal_year = 2023 THEN amount_usd ELSE 0 END) as revenue_2023,
  SUM(CASE WHEN fiscal_year = 2022 THEN amount_usd ELSE 0 END) as revenue_2022
FROM burc_historical_revenue_detail
GROUP BY client_name, parent_company
ORDER BY lifetime_revenue DESC;

-- Support Cost Efficiency
CREATE OR REPLACE VIEW burc_support_efficiency AS
SELECT
  sm.fiscal_year,
  sm.fiscal_month,
  sm.total_tickets,
  sm.cost_per_ticket,
  sm.sla_met_percent,
  sm.csat_score,
  COALESCE(mr.net_revenue, 0) as maint_revenue,
  CASE
    WHEN COALESCE(mr.net_revenue, 0) > 0
    THEN sm.support_cost / mr.net_revenue * 100
    ELSE 0
  END as support_cost_percent_of_maint
FROM burc_support_metrics sm
LEFT JOIN (
  SELECT fiscal_year, fiscal_month, SUM(net_revenue) as net_revenue
  FROM burc_monthly_revenue
  WHERE revenue_type = 'Maint'
  GROUP BY fiscal_year, fiscal_month
) mr ON sm.fiscal_year = mr.fiscal_year AND sm.fiscal_month = mr.fiscal_month
ORDER BY sm.fiscal_year DESC, sm.fiscal_month DESC;

-- Forecast Accuracy
CREATE OR REPLACE VIEW burc_forecast_accuracy AS
SELECT
  forecast_category,
  fiscal_quarter,
  COUNT(*) as opportunity_count,
  SUM(amount) as total_forecast,
  SUM(CASE WHEN won = true THEN amount ELSE 0 END) as total_won,
  SUM(CASE WHEN won = true THEN 1 ELSE 0 END)::NUMERIC / NULLIF(COUNT(*), 0) * 100 as win_rate,
  SUM(CASE WHEN won = true THEN amount ELSE 0 END) / NULLIF(SUM(weighted_amount), 0) * 100 as forecast_accuracy
FROM burc_sales_forecast
WHERE actual_close_date IS NOT NULL
GROUP BY forecast_category, fiscal_quarter
ORDER BY fiscal_quarter DESC, forecast_category;

COMMENT ON TABLE burc_historical_revenue_detail IS 'Detailed historical revenue from APAC Revenue 2019-2024.xlsx (84,901 rows)';
COMMENT ON TABLE burc_ps_cross_charges IS 'PS cross-charge allocations between regions';
COMMENT ON TABLE burc_support_metrics IS 'Monthly support ticket and cost metrics';
COMMENT ON TABLE burc_budget_actuals IS 'Budget vs actual comparison by metric';
COMMENT ON TABLE burc_collections IS 'Invoice collection and payment history';
COMMENT ON TABLE burc_exchange_rates IS 'Historical exchange rates for currency conversion';
COMMENT ON TABLE burc_sales_forecast IS 'Historical sales forecast snapshots for accuracy tracking';
COMMENT ON TABLE burc_monthly_snapshots IS 'Complete monthly BURC snapshots from all monthly files';
