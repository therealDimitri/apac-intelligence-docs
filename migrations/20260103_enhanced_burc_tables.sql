-- ============================================================================
-- ENHANCED BURC DATA TABLES
-- Created: 3 January 2026
-- Purpose: Store comprehensive multi-year BURC data from all source files
-- ============================================================================

-- 1. MONTHLY METRICS (APAC BURC breakdown by month)
CREATE TABLE IF NOT EXISTS burc_monthly_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  month_num INTEGER NOT NULL CHECK (month_num BETWEEN 1 AND 12),
  month_name TEXT NOT NULL,
  metric_name TEXT NOT NULL,
  metric_category TEXT,
  value DECIMAL(15,2) DEFAULT 0,
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(fiscal_year, month_num, metric_name)
);

-- 2. QUARTERLY DATA (Year-over-year comparison)
CREATE TABLE IF NOT EXISTS burc_quarterly_data (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  comparison_type TEXT,
  metric_name TEXT NOT NULL,
  q1_value DECIMAL(15,2) DEFAULT 0,
  q2_value DECIMAL(15,2) DEFAULT 0,
  q3_value DECIMAL(15,2) DEFAULT 0,
  q4_value DECIMAL(15,2) DEFAULT 0,
  fy_total DECIMAL(15,2) DEFAULT 0,
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(fiscal_year, metric_name)
);

-- 3. PIPELINE DETAIL (Dial 2 Risk Profile deals)
CREATE TABLE IF NOT EXISTS burc_pipeline_detail (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  deal_name TEXT NOT NULL,
  client_name TEXT,
  forecast_category TEXT,
  sw_revenue DECIMAL(15,2) DEFAULT 0,
  ps_revenue DECIMAL(15,2) DEFAULT 0,
  maint_revenue DECIMAL(15,2) DEFAULT 0,
  hw_revenue DECIMAL(15,2) DEFAULT 0,
  total_revenue DECIMAL(15,2) GENERATED ALWAYS AS (sw_revenue + ps_revenue + maint_revenue + hw_revenue) STORED,
  closure_date DATE,
  source_sheet TEXT,
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(fiscal_year, deal_name)
);

-- 4. WATERFALL DATA (Revenue bridge)
CREATE TABLE IF NOT EXISTS burc_waterfall (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  category TEXT NOT NULL,
  description TEXT,
  amount DECIMAL(15,2) DEFAULT 0,
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. PRODUCT REVENUE (by product and category)
-- Drop and recreate to fix schema
DROP TABLE IF EXISTS burc_product_revenue;
CREATE TABLE burc_product_revenue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  product_name TEXT NOT NULL,
  product_category TEXT NOT NULL,
  annual_revenue DECIMAL(15,2) DEFAULT 0,
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(fiscal_year, product_name, product_category)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_monthly_metrics_year ON burc_monthly_metrics(fiscal_year);
CREATE INDEX IF NOT EXISTS idx_quarterly_data_year ON burc_quarterly_data(fiscal_year);
CREATE INDEX IF NOT EXISTS idx_pipeline_detail_year ON burc_pipeline_detail(fiscal_year);
CREATE INDEX IF NOT EXISTS idx_waterfall_year ON burc_waterfall(fiscal_year);
CREATE INDEX IF NOT EXISTS idx_product_revenue_year ON burc_product_revenue(fiscal_year);

-- Enable RLS
ALTER TABLE burc_monthly_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_quarterly_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_pipeline_detail ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_waterfall ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_product_revenue ENABLE ROW LEVEL SECURITY;

-- RLS Policies - Allow authenticated read
DO $$
BEGIN
  -- Monthly metrics
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'burc_monthly_metrics' AND policyname = 'Allow authenticated read') THEN
    CREATE POLICY "Allow authenticated read" ON burc_monthly_metrics FOR SELECT TO authenticated USING (true);
  END IF;

  -- Quarterly data
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'burc_quarterly_data' AND policyname = 'Allow authenticated read') THEN
    CREATE POLICY "Allow authenticated read" ON burc_quarterly_data FOR SELECT TO authenticated USING (true);
  END IF;

  -- Pipeline detail
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'burc_pipeline_detail' AND policyname = 'Allow authenticated read') THEN
    CREATE POLICY "Allow authenticated read" ON burc_pipeline_detail FOR SELECT TO authenticated USING (true);
  END IF;

  -- Waterfall
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'burc_waterfall' AND policyname = 'Allow authenticated read') THEN
    CREATE POLICY "Allow authenticated read" ON burc_waterfall FOR SELECT TO authenticated USING (true);
  END IF;

  -- Product revenue
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'burc_product_revenue' AND policyname = 'Allow authenticated read') THEN
    CREATE POLICY "Allow authenticated read" ON burc_product_revenue FOR SELECT TO authenticated USING (true);
  END IF;
END $$;

-- Grant service role full access for sync operations
GRANT ALL ON burc_monthly_metrics TO service_role;
GRANT ALL ON burc_quarterly_data TO service_role;
GRANT ALL ON burc_pipeline_detail TO service_role;
GRANT ALL ON burc_waterfall TO service_role;
GRANT ALL ON burc_product_revenue TO service_role;

-- ============================================================================
-- SUMMARY VIEW: Combined BURC data overview
-- ============================================================================
CREATE OR REPLACE VIEW burc_yearly_summary AS
SELECT
  fiscal_year,
  'Monthly Metrics' as data_type,
  COUNT(*) as record_count,
  SUM(value) as total_value
FROM burc_monthly_metrics
GROUP BY fiscal_year

UNION ALL

SELECT
  fiscal_year,
  'Pipeline Deals' as data_type,
  COUNT(*) as record_count,
  SUM(total_revenue) as total_value
FROM burc_pipeline_detail
GROUP BY fiscal_year

UNION ALL

SELECT
  fiscal_year,
  'Product Revenue' as data_type,
  COUNT(*) as record_count,
  SUM(annual_revenue) as total_value
FROM burc_product_revenue
GROUP BY fiscal_year

ORDER BY fiscal_year DESC, data_type;
