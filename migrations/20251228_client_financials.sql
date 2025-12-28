-- =====================================================
-- Migration: Client Financials Integration
-- Date: 28 December 2025
-- Purpose: Add tables to track client revenue, contract renewals,
--          attrition risk, and business case pipeline
-- =====================================================

-- =====================================================
-- 1. CLIENT FINANCIALS TABLE
-- Stores annual/quarterly revenue breakdown by client
-- =====================================================
CREATE TABLE IF NOT EXISTS client_financials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    client_name TEXT NOT NULL,

    -- Fiscal year and period
    fiscal_year INTEGER NOT NULL,
    fiscal_quarter INTEGER, -- NULL for annual totals, 1-4 for quarterly

    -- Revenue breakdown (USD)
    revenue_maintenance DECIMAL(12, 2) DEFAULT 0,
    revenue_professional_services DECIMAL(12, 2) DEFAULT 0,
    revenue_software_licences DECIMAL(12, 2) DEFAULT 0,
    revenue_hardware DECIMAL(12, 2) DEFAULT 0,
    revenue_business_case DECIMAL(12, 2) DEFAULT 0,
    revenue_total DECIMAL(12, 2) GENERATED ALWAYS AS (
        COALESCE(revenue_maintenance, 0) +
        COALESCE(revenue_professional_services, 0) +
        COALESCE(revenue_software_licences, 0) +
        COALESCE(revenue_hardware, 0) +
        COALESCE(revenue_business_case, 0)
    ) STORED,

    -- COGS breakdown
    cogs_maintenance DECIMAL(12, 2) DEFAULT 0,
    cogs_professional_services DECIMAL(12, 2) DEFAULT 0,
    cogs_software DECIMAL(12, 2) DEFAULT 0,
    cogs_hardware DECIMAL(12, 2) DEFAULT 0,
    cogs_total DECIMAL(12, 2) GENERATED ALWAYS AS (
        COALESCE(cogs_maintenance, 0) +
        COALESCE(cogs_professional_services, 0) +
        COALESCE(cogs_software, 0) +
        COALESCE(cogs_hardware, 0)
    ) STORED,

    -- Net revenue (calculated)
    net_revenue DECIMAL(12, 2) GENERATED ALWAYS AS (
        COALESCE(revenue_maintenance, 0) +
        COALESCE(revenue_professional_services, 0) +
        COALESCE(revenue_software_licences, 0) +
        COALESCE(revenue_hardware, 0) +
        COALESCE(revenue_business_case, 0) -
        COALESCE(cogs_maintenance, 0) -
        COALESCE(cogs_professional_services, 0) -
        COALESCE(cogs_software, 0) -
        COALESCE(cogs_hardware, 0)
    ) STORED,

    -- Revenue category
    revenue_category TEXT CHECK (revenue_category IN ('backlog', 'best_case', 'pipeline', 'business_case')),

    -- Solution/product info
    primary_solution TEXT, -- e.g., 'Sunrise', 'Opal', 'iPro'

    -- Metadata
    source_document TEXT, -- Reference to source Excel/document
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Unique constraint per client/year/quarter
    UNIQUE(client_name, fiscal_year, fiscal_quarter, revenue_category)
);

-- Index for common queries
CREATE INDEX idx_client_financials_client ON client_financials(client_name);
CREATE INDEX idx_client_financials_year ON client_financials(fiscal_year);
CREATE INDEX idx_client_financials_client_year ON client_financials(client_name, fiscal_year);

-- =====================================================
-- 2. CONTRACT RENEWALS TABLE
-- Tracks upcoming contract renewals and their values
-- =====================================================
CREATE TABLE IF NOT EXISTS contract_renewals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    client_name TEXT NOT NULL,

    -- Contract details
    contract_type TEXT NOT NULL CHECK (contract_type IN (
        'maintenance', 'support', 'subscription', 'licence', 'professional_services', 'hosting'
    )),
    solution TEXT, -- e.g., 'Opal', 'Sunrise', 'iPro'
    oracle_agreement_number TEXT,

    -- Dates
    contract_start_date DATE,
    contract_end_date DATE NOT NULL,
    renewal_date DATE NOT NULL,

    -- Financial details (USD)
    annual_value DECIMAL(12, 2) NOT NULL,
    renewal_value DECIMAL(12, 2), -- Expected value after renewal
    cpi_increase_percent DECIMAL(5, 2) DEFAULT 0, -- e.g., 5.0 for 5%

    -- Renewal status
    renewal_status TEXT DEFAULT 'pending' CHECK (renewal_status IN (
        'pending', 'in_discussion', 'proposal_sent', 'negotiating',
        'renewed', 'declined', 'churned'
    )),
    renewal_probability INTEGER DEFAULT 80 CHECK (renewal_probability BETWEEN 0 AND 100),

    -- Terms
    renewal_term_months INTEGER DEFAULT 12,
    auto_renewal BOOLEAN DEFAULT FALSE,

    -- Ownership
    assigned_cse TEXT,
    last_contact_date DATE,
    next_action TEXT,
    next_action_date DATE,

    -- Metadata
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_contract_renewals_client ON contract_renewals(client_name);
CREATE INDEX idx_contract_renewals_date ON contract_renewals(renewal_date);
CREATE INDEX idx_contract_renewals_status ON contract_renewals(renewal_status);
CREATE INDEX idx_contract_renewals_upcoming ON contract_renewals(renewal_date)
    WHERE renewal_status IN ('pending', 'in_discussion', 'proposal_sent', 'negotiating');

-- =====================================================
-- 3. ATTRITION RISK TABLE
-- Tracks clients at risk of churning or reducing spend
-- =====================================================
CREATE TABLE IF NOT EXISTS attrition_risk (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    client_name TEXT NOT NULL,

    -- Attrition type
    attrition_type TEXT NOT NULL CHECK (attrition_type IN ('full', 'partial')),

    -- Timing
    forecast_date DATE NOT NULL,
    forecast_quarter TEXT, -- e.g., 'Q1 2026'
    fiscal_year INTEGER NOT NULL,

    -- Financial impact (USD)
    revenue_at_risk DECIMAL(12, 2) NOT NULL,
    revenue_2025_impact DECIMAL(12, 2) DEFAULT 0,
    revenue_2026_impact DECIMAL(12, 2) DEFAULT 0,
    revenue_2027_impact DECIMAL(12, 2) DEFAULT 0,
    revenue_2028_impact DECIMAL(12, 2) DEFAULT 0,

    -- Risk assessment
    risk_level TEXT DEFAULT 'medium' CHECK (risk_level IN ('low', 'medium', 'high', 'critical')),
    probability INTEGER DEFAULT 50 CHECK (probability BETWEEN 0 AND 100),

    -- Affected solutions/products
    affected_solutions TEXT[], -- Array of solutions, e.g., ['Sunrise', 'iPro']

    -- Reason and mitigation
    attrition_reason TEXT, -- e.g., 'Contract end', 'Competitor', 'Budget cuts'
    mitigation_strategy TEXT,
    mitigation_owner TEXT,

    -- Status tracking
    status TEXT DEFAULT 'identified' CHECK (status IN (
        'identified', 'monitoring', 'mitigating', 'retained', 'lost'
    )),

    -- Metadata
    notes TEXT,
    source_document TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(client_name, attrition_type, forecast_date)
);

-- Indexes
CREATE INDEX idx_attrition_risk_client ON attrition_risk(client_name);
CREATE INDEX idx_attrition_risk_year ON attrition_risk(fiscal_year);
CREATE INDEX idx_attrition_risk_level ON attrition_risk(risk_level);
CREATE INDEX idx_attrition_risk_active ON attrition_risk(status)
    WHERE status IN ('identified', 'monitoring', 'mitigating');

-- =====================================================
-- 4. BUSINESS CASE PIPELINE TABLE
-- Tracks business cases and their gate review status
-- =====================================================
CREATE TABLE IF NOT EXISTS business_case_pipeline (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Business case identification
    business_case_code TEXT NOT NULL UNIQUE, -- e.g., 'BC001', 'BC002'
    business_case_name TEXT NOT NULL,

    -- Client and solution
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    client_name TEXT NOT NULL,
    solution TEXT NOT NULL,

    -- Revenue projections (USD)
    revenue_software DECIMAL(12, 2) DEFAULT 0,
    revenue_professional_services DECIMAL(12, 2) DEFAULT 0,
    revenue_maintenance DECIMAL(12, 2) DEFAULT 0,
    revenue_total DECIMAL(12, 2) GENERATED ALWAYS AS (
        COALESCE(revenue_software, 0) +
        COALESCE(revenue_professional_services, 0) +
        COALESCE(revenue_maintenance, 0)
    ) STORED,

    -- COGS projections
    cogs_total DECIMAL(12, 2) DEFAULT 0,

    -- Gate reviews
    current_gate INTEGER DEFAULT 0 CHECK (current_gate BETWEEN 0 AND 3),
    gate_1_date DATE, -- Startup
    gate_1_status TEXT CHECK (gate_1_status IN ('pending', 'passed', 'failed')),
    gate_1_criteria TEXT,
    gate_2_date DATE, -- Survival
    gate_2_status TEXT CHECK (gate_2_status IN ('pending', 'passed', 'failed')),
    gate_2_criteria TEXT,
    gate_3_date DATE, -- Scale
    gate_3_status TEXT CHECK (gate_3_status IN ('pending', 'passed', 'failed')),
    gate_3_criteria TEXT,

    -- Outcome scenarios (from APAC Initiative sheet)
    scenario TEXT DEFAULT 'base' CHECK (scenario IN ('base', 'winner', 'wounded', 'wipeout')),
    scenario_description TEXT,

    -- Timeline
    start_date DATE,
    target_completion_date DATE,

    -- Status
    status TEXT DEFAULT 'active' CHECK (status IN (
        'proposed', 'active', 'paused', 'completed', 'abandoned'
    )),

    -- Ownership
    business_owner TEXT,
    technical_lead TEXT,

    -- Metadata
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_business_case_client ON business_case_pipeline(client_name);
CREATE INDEX idx_business_case_status ON business_case_pipeline(status);
CREATE INDEX idx_business_case_gate ON business_case_pipeline(current_gate);

-- =====================================================
-- 5. VIEWS FOR DASHBOARD INTEGRATION
-- =====================================================

-- View: Client Revenue Summary (for Command Centre)
CREATE OR REPLACE VIEW client_revenue_summary AS
SELECT
    cf.client_name,
    cf.fiscal_year,
    SUM(cf.revenue_maintenance) as total_maintenance,
    SUM(cf.revenue_professional_services) as total_ps,
    SUM(cf.revenue_software_licences) as total_software,
    SUM(cf.revenue_total) as total_revenue,
    SUM(cf.net_revenue) as total_net_revenue,
    cf.primary_solution
FROM client_financials cf
WHERE cf.fiscal_quarter IS NULL -- Annual totals only
GROUP BY cf.client_name, cf.fiscal_year, cf.primary_solution
ORDER BY total_revenue DESC;

-- View: Upcoming Contract Renewals (next 90 days)
CREATE OR REPLACE VIEW upcoming_renewals AS
SELECT
    cr.client_name,
    cr.contract_type,
    cr.solution,
    cr.renewal_date,
    cr.annual_value,
    cr.renewal_value,
    cr.renewal_status,
    cr.renewal_probability,
    cr.assigned_cse,
    cr.next_action,
    cr.next_action_date,
    (cr.renewal_date - CURRENT_DATE) as days_until_renewal
FROM contract_renewals cr
WHERE cr.renewal_date BETWEEN CURRENT_DATE AND (CURRENT_DATE + INTERVAL '90 days')
  AND cr.renewal_status NOT IN ('renewed', 'declined', 'churned')
ORDER BY cr.renewal_date ASC;

-- View: Revenue at Risk Summary
CREATE OR REPLACE VIEW revenue_at_risk_summary AS
SELECT
    ar.client_name,
    ar.attrition_type,
    ar.risk_level,
    ar.probability,
    ar.revenue_at_risk,
    ar.forecast_date,
    ar.affected_solutions,
    ar.attrition_reason,
    ar.mitigation_strategy,
    ar.status,
    -- Weighted risk value
    (ar.revenue_at_risk * ar.probability / 100) as weighted_risk
FROM attrition_risk ar
WHERE ar.status IN ('identified', 'monitoring', 'mitigating')
ORDER BY ar.revenue_at_risk DESC;

-- View: Business Case Dashboard
CREATE OR REPLACE VIEW business_case_summary AS
SELECT
    bc.business_case_code,
    bc.business_case_name,
    bc.client_name,
    bc.solution,
    bc.revenue_total,
    bc.current_gate,
    bc.scenario,
    bc.status,
    CASE
        WHEN bc.current_gate = 0 THEN bc.gate_1_date
        WHEN bc.current_gate = 1 THEN bc.gate_2_date
        WHEN bc.current_gate = 2 THEN bc.gate_3_date
        ELSE NULL
    END as next_gate_date,
    bc.business_owner
FROM business_case_pipeline bc
WHERE bc.status IN ('proposed', 'active')
ORDER BY bc.revenue_total DESC;

-- =====================================================
-- 6. ROW LEVEL SECURITY
-- =====================================================

-- Enable RLS
ALTER TABLE client_financials ENABLE ROW LEVEL SECURITY;
ALTER TABLE contract_renewals ENABLE ROW LEVEL SECURITY;
ALTER TABLE attrition_risk ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_case_pipeline ENABLE ROW LEVEL SECURITY;

-- Policies for authenticated users (read access)
CREATE POLICY "Allow authenticated read on client_financials"
    ON client_financials FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Allow authenticated read on contract_renewals"
    ON contract_renewals FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Allow authenticated read on attrition_risk"
    ON attrition_risk FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Allow authenticated read on business_case_pipeline"
    ON business_case_pipeline FOR SELECT
    TO authenticated
    USING (true);

-- Policies for service role (full access)
CREATE POLICY "Allow service role full access on client_financials"
    ON client_financials FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow service role full access on contract_renewals"
    ON contract_renewals FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow service role full access on attrition_risk"
    ON attrition_risk FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow service role full access on business_case_pipeline"
    ON business_case_pipeline FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- =====================================================
-- 7. TRIGGERS FOR UPDATED_AT
-- =====================================================

CREATE OR REPLACE FUNCTION update_financials_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_client_financials_timestamp
    BEFORE UPDATE ON client_financials
    FOR EACH ROW
    EXECUTE FUNCTION update_financials_updated_at();

CREATE TRIGGER update_contract_renewals_timestamp
    BEFORE UPDATE ON contract_renewals
    FOR EACH ROW
    EXECUTE FUNCTION update_financials_updated_at();

CREATE TRIGGER update_attrition_risk_timestamp
    BEFORE UPDATE ON attrition_risk
    FOR EACH ROW
    EXECUTE FUNCTION update_financials_updated_at();

CREATE TRIGGER update_business_case_pipeline_timestamp
    BEFORE UPDATE ON business_case_pipeline
    FOR EACH ROW
    EXECUTE FUNCTION update_financials_updated_at();

-- =====================================================
-- 8. COMMENTS FOR DOCUMENTATION
-- =====================================================

COMMENT ON TABLE client_financials IS 'Stores annual and quarterly revenue/COGS breakdown by client from financial forecasts';
COMMENT ON TABLE contract_renewals IS 'Tracks upcoming contract renewals with values and status';
COMMENT ON TABLE attrition_risk IS 'Clients at risk of churning or reducing spend';
COMMENT ON TABLE business_case_pipeline IS 'Business case pipeline with gate review tracking';

COMMENT ON VIEW client_revenue_summary IS 'Aggregated client revenue for dashboard display';
COMMENT ON VIEW upcoming_renewals IS 'Contracts due for renewal in next 90 days';
COMMENT ON VIEW revenue_at_risk_summary IS 'Clients with revenue at risk due to attrition';
COMMENT ON VIEW business_case_summary IS 'Active business cases with gate status';
