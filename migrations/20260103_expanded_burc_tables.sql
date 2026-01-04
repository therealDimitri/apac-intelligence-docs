-- ============================================================================
-- EXPANDED BURC DATA TABLES
-- Created: 3 January 2026
-- Purpose: Capture ALL worksheet data from BURC files (2023-2026)
-- ============================================================================

-- 1. RISKS & OPPORTUNITIES (R&O sheets)
CREATE TABLE IF NOT EXISTS burc_risks_opportunities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  category TEXT NOT NULL, -- 'Risk' or 'Opportunity'
  description TEXT,
  client_name TEXT,
  product TEXT,
  amount DECIMAL(15,2) DEFAULT 0,
  probability DECIMAL(5,2), -- 0-100%
  expected_value DECIMAL(15,2) DEFAULT 0,
  status TEXT,
  owner TEXT,
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. ATTRITION TRACKING
CREATE TABLE IF NOT EXISTS burc_attrition (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  client_name TEXT NOT NULL,
  product TEXT,
  revenue_at_risk DECIMAL(15,2) DEFAULT 0,
  attrition_date DATE,
  reason TEXT,
  status TEXT, -- 'At Risk', 'Lost', 'Retained'
  mitigation_actions TEXT,
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. SUPPORT RENEWALS
CREATE TABLE IF NOT EXISTS burc_support_renewals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  client_name TEXT NOT NULL,
  contract_value DECIMAL(15,2) DEFAULT 0,
  renewal_date DATE,
  renewal_status TEXT, -- 'Renewed', 'Pending', 'At Risk', 'Lost'
  renewal_rate DECIMAL(5,2), -- % of original value
  notes TEXT,
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. HEADCOUNT DATA
CREATE TABLE IF NOT EXISTS burc_headcount (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  month_num INTEGER,
  department TEXT NOT NULL,
  role_category TEXT,
  headcount INTEGER DEFAULT 0,
  fte DECIMAL(10,2) DEFAULT 0,
  cost DECIMAL(15,2) DEFAULT 0,
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(fiscal_year, month_num, department, role_category)
);

-- 5. MONTHLY EBITA BREAKDOWN
CREATE TABLE IF NOT EXISTS burc_monthly_ebita (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  month_num INTEGER NOT NULL CHECK (month_num BETWEEN 1 AND 12),
  month_name TEXT NOT NULL,
  revenue DECIMAL(15,2) DEFAULT 0,
  cogs DECIMAL(15,2) DEFAULT 0,
  gross_margin DECIMAL(15,2) DEFAULT 0,
  opex DECIMAL(15,2) DEFAULT 0,
  ebita DECIMAL(15,2) DEFAULT 0,
  ebita_percent DECIMAL(5,2) DEFAULT 0,
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(fiscal_year, month_num)
);

-- 6. MONTHLY OPEX BREAKDOWN
CREATE TABLE IF NOT EXISTS burc_monthly_opex (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  month_num INTEGER NOT NULL CHECK (month_num BETWEEN 1 AND 12),
  month_name TEXT NOT NULL,
  category TEXT NOT NULL,
  amount DECIMAL(15,2) DEFAULT 0,
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(fiscal_year, month_num, category)
);

-- 7. REVENUE STREAM DETAIL (SW, PS, Maint, HW by client/deal)
CREATE TABLE IF NOT EXISTS burc_revenue_detail (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  revenue_type TEXT NOT NULL, -- 'SW', 'PS', 'Maint', 'HW'
  client_name TEXT,
  deal_name TEXT,
  product TEXT,
  q1_value DECIMAL(15,2) DEFAULT 0,
  q2_value DECIMAL(15,2) DEFAULT 0,
  q3_value DECIMAL(15,2) DEFAULT 0,
  q4_value DECIMAL(15,2) DEFAULT 0,
  fy_total DECIMAL(15,2) DEFAULT 0,
  category TEXT, -- 'Backlog', 'Best Case', 'Pipeline', 'Runrate'
  source_sheet TEXT,
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. BOOKINGS DATA (from 2023)
CREATE TABLE IF NOT EXISTS burc_bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  client_name TEXT,
  deal_name TEXT,
  booking_date DATE,
  sw_amount DECIMAL(15,2) DEFAULT 0,
  ps_amount DECIMAL(15,2) DEFAULT 0,
  maint_amount DECIMAL(15,2) DEFAULT 0,
  total_amount DECIMAL(15,2) DEFAULT 0,
  category TEXT,
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. PS MARGINS
CREATE TABLE IF NOT EXISTS burc_ps_margins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  month_num INTEGER,
  client_name TEXT,
  project_name TEXT,
  revenue DECIMAL(15,2) DEFAULT 0,
  cost DECIMAL(15,2) DEFAULT 0,
  margin DECIMAL(15,2) DEFAULT 0,
  margin_percent DECIMAL(5,2) DEFAULT 0,
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_ro_year ON burc_risks_opportunities(fiscal_year);
CREATE INDEX IF NOT EXISTS idx_attrition_year ON burc_attrition(fiscal_year);
CREATE INDEX IF NOT EXISTS idx_renewals_year ON burc_support_renewals(fiscal_year);
CREATE INDEX IF NOT EXISTS idx_headcount_year ON burc_headcount(fiscal_year);
CREATE INDEX IF NOT EXISTS idx_monthly_ebita_year ON burc_monthly_ebita(fiscal_year);
CREATE INDEX IF NOT EXISTS idx_monthly_opex_year ON burc_monthly_opex(fiscal_year);
CREATE INDEX IF NOT EXISTS idx_revenue_detail_year ON burc_revenue_detail(fiscal_year);
CREATE INDEX IF NOT EXISTS idx_bookings_year ON burc_bookings(fiscal_year);
CREATE INDEX IF NOT EXISTS idx_ps_margins_year ON burc_ps_margins(fiscal_year);

-- Enable RLS on all tables
ALTER TABLE burc_risks_opportunities ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_attrition ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_support_renewals ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_headcount ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_monthly_ebita ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_monthly_opex ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_revenue_detail ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_ps_margins ENABLE ROW LEVEL SECURITY;

-- RLS Policies - Allow authenticated read
DO $$
BEGIN
  -- Risks & Opportunities
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'burc_risks_opportunities' AND policyname = 'Allow authenticated read') THEN
    CREATE POLICY "Allow authenticated read" ON burc_risks_opportunities FOR SELECT TO authenticated USING (true);
  END IF;

  -- Attrition
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'burc_attrition' AND policyname = 'Allow authenticated read') THEN
    CREATE POLICY "Allow authenticated read" ON burc_attrition FOR SELECT TO authenticated USING (true);
  END IF;

  -- Support Renewals
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'burc_support_renewals' AND policyname = 'Allow authenticated read') THEN
    CREATE POLICY "Allow authenticated read" ON burc_support_renewals FOR SELECT TO authenticated USING (true);
  END IF;

  -- Headcount
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'burc_headcount' AND policyname = 'Allow authenticated read') THEN
    CREATE POLICY "Allow authenticated read" ON burc_headcount FOR SELECT TO authenticated USING (true);
  END IF;

  -- Monthly EBITA
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'burc_monthly_ebita' AND policyname = 'Allow authenticated read') THEN
    CREATE POLICY "Allow authenticated read" ON burc_monthly_ebita FOR SELECT TO authenticated USING (true);
  END IF;

  -- Monthly OPEX
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'burc_monthly_opex' AND policyname = 'Allow authenticated read') THEN
    CREATE POLICY "Allow authenticated read" ON burc_monthly_opex FOR SELECT TO authenticated USING (true);
  END IF;

  -- Revenue Detail
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'burc_revenue_detail' AND policyname = 'Allow authenticated read') THEN
    CREATE POLICY "Allow authenticated read" ON burc_revenue_detail FOR SELECT TO authenticated USING (true);
  END IF;

  -- Bookings
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'burc_bookings' AND policyname = 'Allow authenticated read') THEN
    CREATE POLICY "Allow authenticated read" ON burc_bookings FOR SELECT TO authenticated USING (true);
  END IF;

  -- PS Margins
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'burc_ps_margins' AND policyname = 'Allow authenticated read') THEN
    CREATE POLICY "Allow authenticated read" ON burc_ps_margins FOR SELECT TO authenticated USING (true);
  END IF;
END $$;

-- Grant service role full access
GRANT ALL ON burc_risks_opportunities TO service_role;
GRANT ALL ON burc_attrition TO service_role;
GRANT ALL ON burc_support_renewals TO service_role;
GRANT ALL ON burc_headcount TO service_role;
GRANT ALL ON burc_monthly_ebita TO service_role;
GRANT ALL ON burc_monthly_opex TO service_role;
GRANT ALL ON burc_revenue_detail TO service_role;
GRANT ALL ON burc_bookings TO service_role;
GRANT ALL ON burc_ps_margins TO service_role;
