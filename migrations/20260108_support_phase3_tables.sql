-- Support Health Phase 3 Tables
-- Service Credits, Known Problems, and Case Details
-- Created: 8 January 2026

-- =====================================================
-- 1. SUPPORT SERVICE CREDITS TABLE
-- Tracks quarterly SLA performance and any service credits issued
-- =====================================================

CREATE TABLE IF NOT EXISTS support_service_credits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  canonical_name TEXT,
  quarter TEXT NOT NULL, -- Q1-2024, Q2-2024, etc.
  fiscal_year INTEGER NOT NULL,
  metric_type TEXT NOT NULL, -- Resolution Time, Response Time, Availability
  target_performance DECIMAL(5,2), -- e.g., 95.00
  actual_performance DECIMAL(5,2), -- e.g., 94.50
  met BOOLEAN DEFAULT false,
  quarterly_payment DECIMAL(12,2), -- Contract payment amount
  service_credit DECIMAL(12,2) DEFAULT 0, -- Credit issued if SLA breached
  notes TEXT,
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (client_name, quarter, metric_type)
);

-- Indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_service_credits_client ON support_service_credits (client_name);
CREATE INDEX IF NOT EXISTS idx_service_credits_quarter ON support_service_credits (fiscal_year, quarter);
CREATE INDEX IF NOT EXISTS idx_service_credits_met ON support_service_credits (met) WHERE met = false;

-- RLS Policy
ALTER TABLE support_service_credits ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all for support_service_credits" ON support_service_credits;
CREATE POLICY "Allow all for support_service_credits" ON support_service_credits
  FOR ALL USING (true) WITH CHECK (true);

-- =====================================================
-- 2. SUPPORT KNOWN PROBLEMS TABLE
-- Tracks known issues/bugs affecting clients
-- =====================================================

CREATE TABLE IF NOT EXISTS support_known_problems (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  canonical_name TEXT,
  problem_number TEXT NOT NULL,
  priority TEXT CHECK (priority IN ('Critical', 'High', 'Medium', 'Low')),
  status TEXT DEFAULT 'Open', -- Open, In Progress, Pending Fix, Closed, Workaround Provided
  target_release TEXT, -- e.g., 25.2, 26.1
  product TEXT, -- Sunrise Acute Care, Opal, etc.
  description TEXT,
  workaround TEXT,
  year_opened INTEGER,
  opened_date DATE,
  resolved_date DATE,
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (problem_number)
);

-- Indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_known_problems_client ON support_known_problems (client_name);
CREATE INDEX IF NOT EXISTS idx_known_problems_status ON support_known_problems (status);
CREATE INDEX IF NOT EXISTS idx_known_problems_priority ON support_known_problems (priority);
CREATE INDEX IF NOT EXISTS idx_known_problems_product ON support_known_problems (product);

-- RLS Policy
ALTER TABLE support_known_problems ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all for support_known_problems" ON support_known_problems;
CREATE POLICY "Allow all for support_known_problems" ON support_known_problems
  FOR ALL USING (true) WITH CHECK (true);

-- =====================================================
-- 3. SUPPORT CASE DETAILS TABLE
-- Individual case-level data for drill-down analysis
-- =====================================================

CREATE TABLE IF NOT EXISTS support_case_details (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  canonical_name TEXT,
  case_number TEXT NOT NULL,
  priority TEXT CHECK (priority IN ('1 - Critical', '2 - High', '3 - Moderate', '4 - Low')),
  status TEXT, -- Open, Closed, Pending, In Progress
  product TEXT, -- Sunrise Acute Care, Opal, etc.
  category TEXT,
  opened_date DATE,
  closed_date DATE,
  resolution_sla_met BOOLEAN,
  response_sla_met BOOLEAN,
  days_open INTEGER,
  assigned_to TEXT,
  period_end DATE NOT NULL, -- For historical tracking
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (case_number, period_end)
);

-- Indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_case_details_client ON support_case_details (client_name);
CREATE INDEX IF NOT EXISTS idx_case_details_priority ON support_case_details (priority);
CREATE INDEX IF NOT EXISTS idx_case_details_product ON support_case_details (product);
CREATE INDEX IF NOT EXISTS idx_case_details_status ON support_case_details (status);
CREATE INDEX IF NOT EXISTS idx_case_details_period ON support_case_details (period_end DESC);

-- RLS Policy
ALTER TABLE support_case_details ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all for support_case_details" ON support_case_details;
CREATE POLICY "Allow all for support_case_details" ON support_case_details
  FOR ALL USING (true) WITH CHECK (true);

-- =====================================================
-- 4. ADD SEGMENT COLUMN TO SUPPORT_SLA_METRICS
-- For grouping by client segment (Platinum, Gold, Silver)
-- =====================================================

ALTER TABLE support_sla_metrics
ADD COLUMN IF NOT EXISTS client_segment TEXT;

-- Update segment from clients table where available
UPDATE support_sla_metrics ssm
SET client_segment = c.segment
FROM clients c
WHERE LOWER(ssm.canonical_name) = LOWER(c.name)
  AND ssm.client_segment IS NULL;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check tables were created
SELECT
  table_name,
  (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public'
  AND table_name IN ('support_service_credits', 'support_known_problems', 'support_case_details');
