-- Enhanced Financial Analytics Tables
-- Migration: 20251229_enhanced_financial_analytics
-- Description: Adds comprehensive financial data tables for advanced analytics

-- ============================================================================
-- 1. PIPELINE & BOOKINGS DATA
-- ============================================================================

-- Sales Pipeline by Stage
CREATE TABLE IF NOT EXISTS burc_sales_pipeline (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    stage VARCHAR(50) NOT NULL, -- 'prospect', 'qualified', 'proposal', 'negotiation', 'closed_won', 'closed_lost'
    deal_count INTEGER DEFAULT 0,
    total_value DECIMAL(15,2) DEFAULT 0,
    weighted_value DECIMAL(15,2) DEFAULT 0,
    avg_deal_size DECIMAL(15,2) DEFAULT 0,
    avg_days_in_stage INTEGER DEFAULT 0,
    conversion_rate DECIMAL(5,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(year, month, stage)
);

-- New Licence Bookings (ACV)
CREATE TABLE IF NOT EXISTS burc_licence_bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    new_bookings_acv DECIMAL(15,2) DEFAULT 0,
    renewal_bookings_acv DECIMAL(15,2) DEFAULT 0,
    expansion_bookings_acv DECIMAL(15,2) DEFAULT 0,
    total_bookings_acv DECIMAL(15,2) DEFAULT 0,
    deals_closed INTEGER DEFAULT 0,
    avg_deal_size DECIMAL(15,2) DEFAULT 0,
    win_rate DECIMAL(5,2) DEFAULT 0,
    sales_cycle_days INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(year, month)
);

-- Maintenance Churn Tracking
CREATE TABLE IF NOT EXISTS burc_maintenance_churn (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    starting_arr DECIMAL(15,2) DEFAULT 0,
    churned_arr DECIMAL(15,2) DEFAULT 0,
    downgrade_arr DECIMAL(15,2) DEFAULT 0,
    upgrade_arr DECIMAL(15,2) DEFAULT 0,
    new_arr DECIMAL(15,2) DEFAULT 0,
    ending_arr DECIMAL(15,2) DEFAULT 0,
    gross_churn_rate DECIMAL(5,2) DEFAULT 0,
    net_churn_rate DECIMAL(5,2) DEFAULT 0,
    customer_count_start INTEGER DEFAULT 0,
    customer_count_end INTEGER DEFAULT 0,
    customers_churned INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(year, month)
);

-- ============================================================================
-- 2. RESOURCE & HEADCOUNT DATA
-- ============================================================================

-- Headcount by Department
CREATE TABLE IF NOT EXISTS burc_headcount (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    department VARCHAR(50) NOT NULL, -- 'ps', 'sales', 'marketing', 'rd', 'support', 'ga', 'management'
    fte_count DECIMAL(10,2) DEFAULT 0,
    contractor_count DECIMAL(10,2) DEFAULT 0,
    total_headcount DECIMAL(10,2) DEFAULT 0,
    open_positions INTEGER DEFAULT 0,
    attrition_count INTEGER DEFAULT 0,
    new_hires INTEGER DEFAULT 0,
    avg_tenure_months DECIMAL(10,2) DEFAULT 0,
    cost_per_head DECIMAL(15,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(year, month, department)
);

-- PS Utilisation Metrics
CREATE TABLE IF NOT EXISTS burc_ps_utilisation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    total_available_hours DECIMAL(15,2) DEFAULT 0,
    billable_hours DECIMAL(15,2) DEFAULT 0,
    non_billable_hours DECIMAL(15,2) DEFAULT 0,
    utilisation_rate DECIMAL(5,2) DEFAULT 0,
    target_utilisation DECIMAL(5,2) DEFAULT 75,
    billable_headcount DECIMAL(10,2) DEFAULT 0,
    avg_bill_rate DECIMAL(15,2) DEFAULT 0,
    revenue_per_consultant DECIMAL(15,2) DEFAULT 0,
    backlog_hours DECIMAL(15,2) DEFAULT 0,
    backlog_value DECIMAL(15,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(year, month)
);

-- R&D Project Allocation
CREATE TABLE IF NOT EXISTS burc_rd_allocation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    project_name VARCHAR(200) NOT NULL,
    project_type VARCHAR(50) NOT NULL, -- 'new_product', 'enhancement', 'maintenance', 'technical_debt', 'research'
    headcount_allocated DECIMAL(10,2) DEFAULT 0,
    spend_allocated DECIMAL(15,2) DEFAULT 0,
    percent_of_total DECIMAL(5,2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'active', -- 'planning', 'active', 'on_hold', 'completed', 'cancelled'
    expected_revenue_impact DECIMAL(15,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 3. PRODUCT & CUSTOMER METRICS
-- ============================================================================

-- ARR by Product Line
CREATE TABLE IF NOT EXISTS burc_product_arr (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    licence_arr DECIMAL(15,2) DEFAULT 0,
    maintenance_arr DECIMAL(15,2) DEFAULT 0,
    ps_revenue DECIMAL(15,2) DEFAULT 0,
    total_arr DECIMAL(15,2) DEFAULT 0,
    customer_count INTEGER DEFAULT 0,
    avg_arr_per_customer DECIMAL(15,2) DEFAULT 0,
    growth_rate_yoy DECIMAL(5,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(year, month, product_line)
);

-- Customer Retention & Health
CREATE TABLE IF NOT EXISTS burc_customer_health (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    segment VARCHAR(50) NOT NULL, -- 'enterprise', 'mid_market', 'smb'
    total_customers INTEGER DEFAULT 0,
    healthy_customers INTEGER DEFAULT 0,
    at_risk_customers INTEGER DEFAULT 0,
    churned_customers INTEGER DEFAULT 0,
    nps_score DECIMAL(5,2) DEFAULT 0,
    csat_score DECIMAL(5,2) DEFAULT 0,
    avg_health_score DECIMAL(5,2) DEFAULT 0,
    retention_rate DECIMAL(5,2) DEFAULT 0,
    expansion_rate DECIMAL(5,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(year, month, segment)
);

-- Support Ticket Volume
CREATE TABLE IF NOT EXISTS burc_support_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    tickets_opened INTEGER DEFAULT 0,
    tickets_closed INTEGER DEFAULT 0,
    tickets_escalated INTEGER DEFAULT 0,
    avg_resolution_hours DECIMAL(10,2) DEFAULT 0,
    first_response_hours DECIMAL(10,2) DEFAULT 0,
    customer_satisfaction DECIMAL(5,2) DEFAULT 0,
    tickets_per_customer DECIMAL(10,2) DEFAULT 0,
    cost_per_ticket DECIMAL(15,2) DEFAULT 0,
    p1_tickets INTEGER DEFAULT 0,
    p2_tickets INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(year, month)
);

-- ============================================================================
-- 4. COST ALLOCATION DETAIL
-- ============================================================================

-- OPEX by Cost Centre
CREATE TABLE IF NOT EXISTS burc_cost_centre (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    department VARCHAR(50) NOT NULL,
    cost_category VARCHAR(100) NOT NULL, -- 'salaries', 'contractors', 'travel', 'training', 'software', 'cloud', 'facilities', 'marketing', 'other'
    amount DECIMAL(15,2) DEFAULT 0,
    is_discretionary BOOLEAN DEFAULT FALSE,
    is_variable BOOLEAN DEFAULT FALSE,
    budget_amount DECIMAL(15,2) DEFAULT 0,
    variance_amount DECIMAL(15,2) DEFAULT 0,
    variance_percent DECIMAL(5,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(year, month, department, cost_category)
);

-- Cloud & Hosting Costs (Often Hidden)
CREATE TABLE IF NOT EXISTS burc_cloud_costs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    provider VARCHAR(50) NOT NULL, -- 'aws', 'azure', 'gcp', 'other'
    service_type VARCHAR(100) NOT NULL, -- 'compute', 'storage', 'database', 'networking', 'ai_ml', 'other'
    cost DECIMAL(15,2) DEFAULT 0,
    usage_units DECIMAL(15,2) DEFAULT 0,
    cost_per_unit DECIMAL(15,4) DEFAULT 0,
    budget_amount DECIMAL(15,2) DEFAULT 0,
    yoy_growth_percent DECIMAL(5,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(year, month, provider, service_type)
);

-- ============================================================================
-- 5. LEADING INDICATORS
-- ============================================================================

-- Quote/Proposal Activity
CREATE TABLE IF NOT EXISTS burc_proposal_activity (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    proposals_sent INTEGER DEFAULT 0,
    proposals_value DECIMAL(15,2) DEFAULT 0,
    proposals_won INTEGER DEFAULT 0,
    proposals_lost INTEGER DEFAULT 0,
    proposals_pending INTEGER DEFAULT 0,
    avg_proposal_value DECIMAL(15,2) DEFAULT 0,
    win_rate DECIMAL(5,2) DEFAULT 0,
    avg_days_to_decision INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(year, month)
);

-- Contract Renewals Pipeline
CREATE TABLE IF NOT EXISTS burc_renewal_pipeline (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    year INTEGER NOT NULL,
    quarter INTEGER NOT NULL, -- 1, 2, 3, 4
    contracts_due INTEGER DEFAULT 0,
    arr_due DECIMAL(15,2) DEFAULT 0,
    renewed_count INTEGER DEFAULT 0,
    renewed_arr DECIMAL(15,2) DEFAULT 0,
    churned_count INTEGER DEFAULT 0,
    churned_arr DECIMAL(15,2) DEFAULT 0,
    pending_count INTEGER DEFAULT 0,
    pending_arr DECIMAL(15,2) DEFAULT 0,
    early_renewal_count INTEGER DEFAULT 0,
    expansion_arr DECIMAL(15,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(year, quarter)
);

-- Implementation Backlog (PS Revenue Pipeline)
CREATE TABLE IF NOT EXISTS burc_implementation_backlog (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    total_backlog_hours DECIMAL(15,2) DEFAULT 0,
    total_backlog_value DECIMAL(15,2) DEFAULT 0,
    projects_in_backlog INTEGER DEFAULT 0,
    avg_project_size_hours DECIMAL(15,2) DEFAULT 0,
    projects_starting_next_30_days INTEGER DEFAULT 0,
    projects_starting_next_90_days INTEGER DEFAULT 0,
    backlog_months_of_revenue DECIMAL(5,2) DEFAULT 0, -- Backlog value / avg monthly PS revenue
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(year, month)
);

-- DSO & Cash Flow Metrics
CREATE TABLE IF NOT EXISTS burc_cash_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    days_sales_outstanding DECIMAL(10,2) DEFAULT 0,
    days_payable_outstanding DECIMAL(10,2) DEFAULT 0,
    cash_conversion_cycle DECIMAL(10,2) DEFAULT 0,
    accounts_receivable DECIMAL(15,2) DEFAULT 0,
    accounts_receivable_over_90 DECIMAL(15,2) DEFAULT 0,
    bad_debt_expense DECIMAL(15,2) DEFAULT 0,
    collections_rate DECIMAL(5,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(year, month)
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_sales_pipeline_year_month ON burc_sales_pipeline(year, month);
CREATE INDEX IF NOT EXISTS idx_licence_bookings_year_month ON burc_licence_bookings(year, month);
CREATE INDEX IF NOT EXISTS idx_maintenance_churn_year_month ON burc_maintenance_churn(year, month);
CREATE INDEX IF NOT EXISTS idx_headcount_year_month ON burc_headcount(year, month);
CREATE INDEX IF NOT EXISTS idx_ps_utilisation_year_month ON burc_ps_utilisation(year, month);
CREATE INDEX IF NOT EXISTS idx_product_arr_year_month ON burc_product_arr(year, month);
CREATE INDEX IF NOT EXISTS idx_customer_health_year_month ON burc_customer_health(year, month);
CREATE INDEX IF NOT EXISTS idx_support_metrics_year_month ON burc_support_metrics(year, month);
CREATE INDEX IF NOT EXISTS idx_cost_centre_year_month ON burc_cost_centre(year, month);
CREATE INDEX IF NOT EXISTS idx_cloud_costs_year_month ON burc_cloud_costs(year, month);
CREATE INDEX IF NOT EXISTS idx_proposal_activity_year_month ON burc_proposal_activity(year, month);
CREATE INDEX IF NOT EXISTS idx_renewal_pipeline_year_quarter ON burc_renewal_pipeline(year, quarter);
CREATE INDEX IF NOT EXISTS idx_implementation_backlog_year_month ON burc_implementation_backlog(year, month);
CREATE INDEX IF NOT EXISTS idx_cash_metrics_year_month ON burc_cash_metrics(year, month);

-- ============================================================================
-- RLS POLICIES (Restrict to authenticated users)
-- ============================================================================

ALTER TABLE burc_sales_pipeline ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_licence_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_maintenance_churn ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_headcount ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_ps_utilisation ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_rd_allocation ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_product_arr ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_customer_health ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_support_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_cost_centre ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_cloud_costs ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_proposal_activity ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_renewal_pipeline ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_implementation_backlog ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_cash_metrics ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read all financial data
CREATE POLICY "Allow authenticated read" ON burc_sales_pipeline FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON burc_licence_bookings FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON burc_maintenance_churn FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON burc_headcount FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON burc_ps_utilisation FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON burc_rd_allocation FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON burc_product_arr FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON burc_customer_health FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON burc_support_metrics FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON burc_cost_centre FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON burc_cloud_costs FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON burc_proposal_activity FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON burc_renewal_pipeline FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON burc_implementation_backlog FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON burc_cash_metrics FOR SELECT TO authenticated USING (true);

-- Allow service role full access
CREATE POLICY "Allow service role all" ON burc_sales_pipeline FOR ALL TO service_role USING (true);
CREATE POLICY "Allow service role all" ON burc_licence_bookings FOR ALL TO service_role USING (true);
CREATE POLICY "Allow service role all" ON burc_maintenance_churn FOR ALL TO service_role USING (true);
CREATE POLICY "Allow service role all" ON burc_headcount FOR ALL TO service_role USING (true);
CREATE POLICY "Allow service role all" ON burc_ps_utilisation FOR ALL TO service_role USING (true);
CREATE POLICY "Allow service role all" ON burc_rd_allocation FOR ALL TO service_role USING (true);
CREATE POLICY "Allow service role all" ON burc_product_arr FOR ALL TO service_role USING (true);
CREATE POLICY "Allow service role all" ON burc_customer_health FOR ALL TO service_role USING (true);
CREATE POLICY "Allow service role all" ON burc_support_metrics FOR ALL TO service_role USING (true);
CREATE POLICY "Allow service role all" ON burc_cost_centre FOR ALL TO service_role USING (true);
CREATE POLICY "Allow service role all" ON burc_cloud_costs FOR ALL TO service_role USING (true);
CREATE POLICY "Allow service role all" ON burc_proposal_activity FOR ALL TO service_role USING (true);
CREATE POLICY "Allow service role all" ON burc_renewal_pipeline FOR ALL TO service_role USING (true);
CREATE POLICY "Allow service role all" ON burc_implementation_backlog FOR ALL TO service_role USING (true);
CREATE POLICY "Allow service role all" ON burc_cash_metrics FOR ALL TO service_role USING (true);
