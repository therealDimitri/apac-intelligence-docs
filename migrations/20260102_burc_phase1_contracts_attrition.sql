-- BURC Enhancement Phase 1: Contracts, Attrition, Business Cases
-- Date: 2 January 2026
-- Purpose: Add tables for unused BURC data - Opal Contracts, Attrition, and Business Cases

-- ============================================================
-- 1. Contract Renewals Table (from "Opal Maint Contracts and Value" sheet)
-- ============================================================
CREATE TABLE IF NOT EXISTS burc_contracts (
  id SERIAL PRIMARY KEY,
  client_name TEXT NOT NULL,
  annual_value_aud DECIMAL(12,2),
  annual_value_usd DECIMAL(12,2),
  renewal_date DATE,
  comments TEXT,
  exchange_rate NUMERIC(5,4) DEFAULT 0.64,
  auto_renewal BOOLEAN DEFAULT false,
  cpi_applicable BOOLEAN DEFAULT false,
  contract_status TEXT DEFAULT 'active' CHECK (contract_status IN ('active', 'expired', 'pending_renewal', 'terminated')),
  days_until_renewal INTEGER GENERATED ALWAYS AS (renewal_date - CURRENT_DATE) STORED,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_synced TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_name, renewal_date)
);

-- ============================================================
-- 2. Attrition Risk Table (from "Attrition" sheet)
-- ============================================================
CREATE TABLE IF NOT EXISTS burc_attrition_risk (
  id SERIAL PRIMARY KEY,
  client_name TEXT NOT NULL,
  risk_type TEXT CHECK (risk_type IN ('Full', 'Partial')),
  forecast_date DATE,
  revenue_2025 DECIMAL(12,2) DEFAULT 0,
  revenue_2026 DECIMAL(12,2) DEFAULT 0,
  revenue_2027 DECIMAL(12,2) DEFAULT 0,
  revenue_2028 DECIMAL(12,2) DEFAULT 0,
  total_at_risk DECIMAL(12,2) DEFAULT 0,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'mitigated', 'churned', 'retained')),
  mitigation_notes TEXT,
  snapshot_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_synced TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_name, forecast_date)
);

-- ============================================================
-- 3. Business Cases Pipeline Table (from "Dial 2 Risk Profile Summary" sheet)
-- ============================================================
CREATE TABLE IF NOT EXISTS burc_business_cases (
  id SERIAL PRIMARY KEY,
  opportunity_name TEXT NOT NULL,
  forecast_category TEXT CHECK (forecast_category IN ('Best Case', 'Pipeline', 'Business Case', 'Committed')),
  closure_date DATE,
  oracle_agreement_number TEXT,
  sw_revenue_date DATE,
  ps_revenue_date DATE,
  maint_revenue_date DATE,
  hw_revenue_date DATE,
  estimated_value DECIMAL(12,2),
  probability NUMERIC(3,2) DEFAULT 0.5,
  stage TEXT DEFAULT 'active',
  owner TEXT,
  client_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_synced TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(opportunity_name, closure_date)
);

-- ============================================================
-- 4. Sync Audit Trail Table (for tracking changes)
-- ============================================================
CREATE TABLE IF NOT EXISTS burc_sync_audit (
  id SERIAL PRIMARY KEY,
  sync_id UUID,
  table_name TEXT NOT NULL,
  operation TEXT CHECK (operation IN ('insert', 'update', 'delete', 'sync')),
  record_count INTEGER DEFAULT 0,
  records_inserted INTEGER DEFAULT 0,
  records_updated INTEGER DEFAULT 0,
  records_deleted INTEGER DEFAULT 0,
  error_message TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 5. Add notes column to burc_waterfall if not exists
-- ============================================================
ALTER TABLE burc_waterfall
  ADD COLUMN IF NOT EXISTS notes TEXT;

-- ============================================================
-- 6. Create KPI Calculations View
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
attrition_data AS (
  SELECT
    COALESCE(SUM(revenue_2026), 0) as total_attrition_2026
  FROM burc_attrition_risk
  WHERE status = 'open'
),
contract_data AS (
  SELECT
    COUNT(*) as total_contracts,
    COUNT(*) FILTER (WHERE days_until_renewal <= 90 AND days_until_renewal > 0) as contracts_expiring_90days,
    COUNT(*) FILTER (WHERE days_until_renewal <= 30 AND days_until_renewal > 0) as contracts_expiring_30days,
    SUM(annual_value_usd) FILTER (WHERE days_until_renewal <= 90 AND days_until_renewal > 0) as value_at_risk_90days
  FROM burc_contracts
  WHERE contract_status = 'active'
)
SELECT
  r.maintenance_revenue,
  r.gross_revenue,
  r.ps_revenue,
  r.license_revenue,
  a.total_attrition_2026,
  c.total_contracts,
  c.contracts_expiring_90days,
  c.contracts_expiring_30days,
  c.value_at_risk_90days,
  -- Gross Revenue Retention (GRR) = (Starting - Churn) / Starting
  CASE WHEN r.maintenance_revenue > 0 THEN
    ROUND(((r.maintenance_revenue - COALESCE(a.total_attrition_2026 * 1000, 0)) / r.maintenance_revenue) * 100, 2)
  ELSE 0 END as gross_revenue_retention_pct,
  -- Rule of 40 placeholder (growth rate + EBITA margin)
  0 as rule_of_40
FROM revenue_data r
CROSS JOIN attrition_data a
CROSS JOIN contract_data c;

-- ============================================================
-- 7. Create Indexes for Performance
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_contracts_renewal ON burc_contracts(renewal_date);
CREATE INDEX IF NOT EXISTS idx_contracts_status ON burc_contracts(contract_status);
CREATE INDEX IF NOT EXISTS idx_contracts_days ON burc_contracts(days_until_renewal);
CREATE INDEX IF NOT EXISTS idx_attrition_status ON burc_attrition_risk(status);
CREATE INDEX IF NOT EXISTS idx_attrition_client ON burc_attrition_risk(client_name);
CREATE INDEX IF NOT EXISTS idx_business_cases_category ON burc_business_cases(forecast_category);
CREATE INDEX IF NOT EXISTS idx_business_cases_closure ON burc_business_cases(closure_date);
CREATE INDEX IF NOT EXISTS idx_sync_audit_table ON burc_sync_audit(table_name);
CREATE INDEX IF NOT EXISTS idx_sync_audit_created ON burc_sync_audit(created_at);

-- ============================================================
-- 8. RLS Policies (authenticated users only)
-- ============================================================
ALTER TABLE burc_contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_attrition_risk ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_business_cases ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_sync_audit ENABLE ROW LEVEL SECURITY;

-- Read policies for authenticated users
CREATE POLICY "Allow authenticated read on burc_contracts"
  ON burc_contracts FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated read on burc_attrition_risk"
  ON burc_attrition_risk FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated read on burc_business_cases"
  ON burc_business_cases FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated read on burc_sync_audit"
  ON burc_sync_audit FOR SELECT
  TO authenticated
  USING (true);

-- Service role policies for sync operations
CREATE POLICY "Allow service role all on burc_contracts"
  ON burc_contracts FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow service role all on burc_attrition_risk"
  ON burc_attrition_risk FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow service role all on burc_business_cases"
  ON burc_business_cases FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow service role all on burc_sync_audit"
  ON burc_sync_audit FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Grant access to anon for public dashboards
GRANT SELECT ON burc_contracts TO anon;
GRANT SELECT ON burc_attrition_risk TO anon;
GRANT SELECT ON burc_business_cases TO anon;
GRANT SELECT ON burc_kpi_summary TO anon;
GRANT SELECT ON burc_contracts TO authenticated;
GRANT SELECT ON burc_attrition_risk TO authenticated;
GRANT SELECT ON burc_business_cases TO authenticated;
GRANT SELECT ON burc_kpi_summary TO authenticated;
