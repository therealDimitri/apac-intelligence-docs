-- ============================================================================
-- COMPREHENSIVE BURC DATA SCHEMA
-- Created: 3 January 2026
-- Purpose: Store complete financial data from all BURC source files
-- ============================================================================

-- 1. CLIENT REVENUE DETAIL (Historical revenue by client/year/type)
-- Source: APAC Revenue 2019 - 2024.xlsx (Sheet1)
CREATE TABLE IF NOT EXISTS burc_client_revenue_detail (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  parent_company TEXT DEFAULT 'ADHI',
  revenue_type TEXT NOT NULL, -- License, Maintenance, Professional Services, Hardware & Other
  year_2019 DECIMAL(15,2) DEFAULT 0,
  year_2020 DECIMAL(15,2) DEFAULT 0,
  year_2021 DECIMAL(15,2) DEFAULT 0,
  year_2022 DECIMAL(15,2) DEFAULT 0,
  year_2023 DECIMAL(15,2) DEFAULT 0,
  year_2024 DECIMAL(15,2) DEFAULT 0,
  year_2025 DECIMAL(15,2) DEFAULT 0,
  year_2026 DECIMAL(15,2) DEFAULT 0,
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_name, revenue_type)
);

-- 2. PIPELINE DEALS (Individual deals from Dial 2 sheets)
-- Source: 2026/2025/2024 APAC Performance.xlsx (Dial 2 Risk Profile Summary sheets)
CREATE TABLE IF NOT EXISTS burc_pipeline_deals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  deal_name TEXT NOT NULL,
  client_name TEXT,
  forecast_category TEXT, -- Best Case, Pipeline, Business Case, Lost
  closure_date DATE,
  oracle_agreement_id TEXT,
  sw_revenue DECIMAL(15,2) DEFAULT 0,
  ps_revenue DECIMAL(15,2) DEFAULT 0,
  maint_revenue DECIMAL(15,2) DEFAULT 0,
  hw_revenue DECIMAL(15,2) DEFAULT 0,
  total_revenue DECIMAL(15,2) GENERATED ALWAYS AS (sw_revenue + ps_revenue + maint_revenue + hw_revenue) STORED,
  sw_date DATE,
  ps_date DATE,
  maint_date DATE,
  hw_date DATE,
  deal_type TEXT, -- Green, Yellow, Red, Rats and Mice
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(fiscal_year, deal_name)
);

-- 3. MONTHLY FORECAST DATA (APAC BURC sheet monthly breakdown)
-- Source: 2026/2025/2024 APAC Performance.xlsx (APAC BURC sheets)
CREATE TABLE IF NOT EXISTS burc_monthly_forecast (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  month_num INTEGER NOT NULL CHECK (month_num BETWEEN 1 AND 12),
  month_name TEXT NOT NULL,
  is_actual BOOLEAN DEFAULT FALSE, -- True if actual, False if forecast

  -- Revenue lines
  license_revenue DECIMAL(15,2) DEFAULT 0,
  ps_backlog DECIMAL(15,2) DEFAULT 0,
  ps_best_case DECIMAL(15,2) DEFAULT 0,
  ps_pipeline DECIMAL(15,2) DEFAULT 0,
  ps_total DECIMAL(15,2) DEFAULT 0,
  maint_runrate DECIMAL(15,2) DEFAULT 0,
  maint_best_case DECIMAL(15,2) DEFAULT 0,
  maint_pipeline DECIMAL(15,2) DEFAULT 0,
  maint_total DECIMAL(15,2) DEFAULT 0,
  hw_revenue DECIMAL(15,2) DEFAULT 0,
  business_case_revenue DECIMAL(15,2) DEFAULT 0,
  gross_revenue DECIMAL(15,2) DEFAULT 0,

  -- COGS lines
  license_cogs DECIMAL(15,2) DEFAULT 0,
  ps_cogs DECIMAL(15,2) DEFAULT 0,
  maint_cogs DECIMAL(15,2) DEFAULT 0,
  hw_cogs DECIMAL(15,2) DEFAULT 0,
  total_cogs DECIMAL(15,2) DEFAULT 0,

  -- Net Revenue
  license_nr DECIMAL(15,2) DEFAULT 0,
  ps_nr DECIMAL(15,2) DEFAULT 0,
  maint_nr DECIMAL(15,2) DEFAULT 0,
  hw_nr DECIMAL(15,2) DEFAULT 0,
  net_revenue DECIMAL(15,2) DEFAULT 0,

  -- OPEX and EBITA
  opex DECIMAL(15,2) DEFAULT 0,
  ebita DECIMAL(15,2) DEFAULT 0,

  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(fiscal_year, month_num)
);

-- 4. QUARTERLY COMPARISON (Year-over-year quarterly data)
-- Source: "26 vs 25 Q Comparison", "25 vs 24 Q Comparison" sheets
CREATE TABLE IF NOT EXISTS burc_quarterly_comparison (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  quarter INTEGER NOT NULL CHECK (quarter BETWEEN 1 AND 4),

  -- Revenue
  license_revenue DECIMAL(15,2) DEFAULT 0,
  ps_revenue DECIMAL(15,2) DEFAULT 0,
  maint_revenue DECIMAL(15,2) DEFAULT 0,
  hw_revenue DECIMAL(15,2) DEFAULT 0,
  business_case_revenue DECIMAL(15,2) DEFAULT 0,
  gross_revenue DECIMAL(15,2) DEFAULT 0,

  -- COGS
  license_cogs DECIMAL(15,2) DEFAULT 0,
  ps_cogs DECIMAL(15,2) DEFAULT 0,
  maint_cogs DECIMAL(15,2) DEFAULT 0,
  total_cogs DECIMAL(15,2) DEFAULT 0,

  -- Net Revenue
  license_nr DECIMAL(15,2) DEFAULT 0,
  ps_nr DECIMAL(15,2) DEFAULT 0,
  maint_nr DECIMAL(15,2) DEFAULT 0,
  hw_nr DECIMAL(15,2) DEFAULT 0,
  business_case_nr DECIMAL(15,2) DEFAULT 0,
  net_revenue DECIMAL(15,2) DEFAULT 0,

  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(fiscal_year, quarter)
);

-- 5. PRODUCT REVENUE (Revenue by product category)
-- Source: SW Product, PS Product, Maint Product sheets
CREATE TABLE IF NOT EXISTS burc_product_revenue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  product_name TEXT NOT NULL,
  product_category TEXT NOT NULL, -- SW, PS, Maint, HW
  client_name TEXT,

  jan DECIMAL(15,2) DEFAULT 0,
  feb DECIMAL(15,2) DEFAULT 0,
  mar DECIMAL(15,2) DEFAULT 0,
  apr DECIMAL(15,2) DEFAULT 0,
  may DECIMAL(15,2) DEFAULT 0,
  jun DECIMAL(15,2) DEFAULT 0,
  jul DECIMAL(15,2) DEFAULT 0,
  aug DECIMAL(15,2) DEFAULT 0,
  sep DECIMAL(15,2) DEFAULT 0,
  oct DECIMAL(15,2) DEFAULT 0,
  nov DECIMAL(15,2) DEFAULT 0,
  dec DECIMAL(15,2) DEFAULT 0,
  total DECIMAL(15,2) GENERATED ALWAYS AS (jan+feb+mar+apr+may+jun+jul+aug+sep+oct+nov+dec) STORED,

  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(fiscal_year, product_name, product_category, client_name)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_client_revenue_detail_client ON burc_client_revenue_detail(client_name);
CREATE INDEX IF NOT EXISTS idx_pipeline_deals_year ON burc_pipeline_deals(fiscal_year);
CREATE INDEX IF NOT EXISTS idx_pipeline_deals_category ON burc_pipeline_deals(forecast_category);
CREATE INDEX IF NOT EXISTS idx_monthly_forecast_year ON burc_monthly_forecast(fiscal_year);
CREATE INDEX IF NOT EXISTS idx_quarterly_comparison_year ON burc_quarterly_comparison(fiscal_year);

-- Enable RLS
ALTER TABLE burc_client_revenue_detail ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_pipeline_deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_monthly_forecast ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_quarterly_comparison ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_product_revenue ENABLE ROW LEVEL SECURITY;

-- RLS Policies - Allow authenticated users to read
CREATE POLICY IF NOT EXISTS "Allow authenticated read on burc_client_revenue_detail"
  ON burc_client_revenue_detail FOR SELECT TO authenticated USING (true);

CREATE POLICY IF NOT EXISTS "Allow authenticated read on burc_pipeline_deals"
  ON burc_pipeline_deals FOR SELECT TO authenticated USING (true);

CREATE POLICY IF NOT EXISTS "Allow authenticated read on burc_monthly_forecast"
  ON burc_monthly_forecast FOR SELECT TO authenticated USING (true);

CREATE POLICY IF NOT EXISTS "Allow authenticated read on burc_quarterly_comparison"
  ON burc_quarterly_comparison FOR SELECT TO authenticated USING (true);

CREATE POLICY IF NOT EXISTS "Allow authenticated read on burc_product_revenue"
  ON burc_product_revenue FOR SELECT TO authenticated USING (true);

-- ============================================================================
-- VIEWS FOR EXECUTIVE DASHBOARD
-- ============================================================================

-- Total Revenue by Year (combines all sources)
CREATE OR REPLACE VIEW burc_total_revenue_by_year AS
SELECT
  'Historical' as data_source,
  SUM(year_2019) as revenue_2019,
  SUM(year_2020) as revenue_2020,
  SUM(year_2021) as revenue_2021,
  SUM(year_2022) as revenue_2022,
  SUM(year_2023) as revenue_2023,
  SUM(year_2024) as revenue_2024,
  SUM(year_2025) as revenue_2025,
  SUM(year_2026) as revenue_2026
FROM burc_client_revenue_detail;

-- Pipeline Summary by Category
CREATE OR REPLACE VIEW burc_pipeline_summary AS
SELECT
  fiscal_year,
  forecast_category,
  COUNT(*) as deal_count,
  SUM(sw_revenue) as total_sw,
  SUM(ps_revenue) as total_ps,
  SUM(maint_revenue) as total_maint,
  SUM(hw_revenue) as total_hw,
  SUM(total_revenue) as total_pipeline
FROM burc_pipeline_deals
WHERE forecast_category IS NOT NULL
GROUP BY fiscal_year, forecast_category
ORDER BY fiscal_year DESC, total_pipeline DESC;

-- Client Revenue Ranking
CREATE OR REPLACE VIEW burc_client_ranking AS
SELECT
  client_name,
  SUM(year_2024) as revenue_2024,
  SUM(year_2023) as revenue_2023,
  SUM(year_2024) - SUM(year_2023) as yoy_change,
  CASE
    WHEN SUM(year_2023) > 0 THEN
      ROUND(((SUM(year_2024) - SUM(year_2023)) / SUM(year_2023) * 100)::numeric, 1)
    ELSE NULL
  END as yoy_change_pct,
  SUM(year_2019 + year_2020 + year_2021 + year_2022 + year_2023 + year_2024) as lifetime_revenue
FROM burc_client_revenue_detail
GROUP BY client_name
ORDER BY revenue_2024 DESC;
