-- Planning Hub Tables Migration
-- Created: 2026-01-08
-- Purpose: Territory Strategy and Account Plan submission system

-- ============================================================================
-- TERRITORY STRATEGIES TABLE
-- Stores CSE territory-wide planning documents
-- ============================================================================

CREATE TABLE IF NOT EXISTS territory_strategies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Ownership
    cse_id UUID REFERENCES cse_profiles(id),
    cse_name TEXT NOT NULL,
    territory TEXT NOT NULL,

    -- Period
    fiscal_year INTEGER NOT NULL DEFAULT 2026,
    quarter TEXT, -- NULL for annual, 'Q1'/'Q2'/'Q3'/'Q4' for quarterly

    -- Status tracking
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'submitted', 'in_review', 'revision_requested', 'approved', 'archived')),
    submitted_at TIMESTAMPTZ,
    approved_at TIMESTAMPTZ,
    approved_by TEXT,

    -- Portfolio Overview (Step 1) - Auto-populated, user confirms
    portfolio_data JSONB DEFAULT '{}',
    -- Structure: { clients: [{ id, name, arr, nps, csi, segment }], totals: { arr, avgNps, atRisk } }

    -- Revenue Targets (Step 2)
    targets_data JSONB DEFAULT '{}',
    -- Structure: { quarterly: [{ q, renewal, growth, total, confidence }], annual: {...}, pipeline: {...} }

    -- Top Opportunities (Step 3) - MEDDPICC scoring
    opportunities_data JSONB DEFAULT '[]',
    -- Structure: [{ name, client, acv, closeDate, meddpicc: { m, e, d1, d2, p, i, c1, c2, total }, nextActions: [] }]

    -- Top Risks (Step 4)
    risks_data JSONB DEFAULT '[]',
    -- Structure: [{ client, description, factors: {...}, revenueAtRisk, churnProbability, mitigation: [], escalationNeeded }]

    -- Action Plan (Step 5)
    action_plan_data JSONB DEFAULT '{}',
    -- Structure: { quarterly: { q1: [...], q2: [...], q3: [...], q4: [...] }, milestones: [] }

    -- Support Needs
    support_needs JSONB DEFAULT '[]',
    -- Structure: [{ need, description, urgency, owner }]

    -- Personal Development
    development_goals JSONB DEFAULT '[]',
    -- Structure: [{ area, goal, actions, targetDate }]

    -- Progress tracking
    completion_percentage INTEGER DEFAULT 0,
    steps_completed JSONB DEFAULT '{"portfolio": false, "targets": false, "opportunities": false, "risks": false, "review": false}',

    -- Revision tracking
    revision_notes TEXT,
    revision_requested_at TIMESTAMPTZ,
    revision_requested_by TEXT,

    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_edited_by TEXT,
    version INTEGER DEFAULT 1
);

-- ============================================================================
-- ACCOUNT PLANS TABLE
-- Stores CAM account-specific planning documents
-- ============================================================================

CREATE TABLE IF NOT EXISTS account_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Ownership
    cam_id UUID REFERENCES cse_profiles(id),
    cam_name TEXT NOT NULL,
    cse_partner TEXT,

    -- Account reference
    client_id UUID,
    client_name TEXT NOT NULL,

    -- Period
    fiscal_year INTEGER NOT NULL DEFAULT 2026,
    quarter TEXT,

    -- Status tracking
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'submitted', 'in_review', 'revision_requested', 'approved', 'archived')),
    submitted_at TIMESTAMPTZ,
    approved_at TIMESTAMPTZ,
    approved_by TEXT,

    -- Account Snapshot (Step 1) - Auto-populated
    snapshot_data JSONB DEFAULT '{}',
    -- Structure: { healthScore, nps, productAdoption, activeUsers, supportTickets, escalations, tier, arr, renewalDate }

    -- Stakeholder Map (Step 2)
    stakeholders_data JSONB DEFAULT '[]',
    -- Structure: [{ name, title, role, relationship, lastContact, frequency, notes }]

    -- Adoption & Engagement (Step 3)
    engagement_data JSONB DEFAULT '{}',
    -- Structure: { products: [...], activities: { last90: {...}, next90: [...] } }

    -- Support & Escalation (Step 4)
    support_data JSONB DEFAULT '{}',
    -- Structure: { openIssues: [...], escalationHistory: {...}, satisfaction: {...}, improvements: [...] }

    -- Opportunities (Step 5)
    opportunities_data JSONB DEFAULT '[]',
    -- Structure: [{ name, value, stage, champion, timeline, meddpicc: {...} }]

    -- Risk Assessment (Step 6)
    risk_data JSONB DEFAULT '{}',
    -- Structure: { factors: [...], overallRisk, intervention: {...} }

    -- Action Plan
    action_plan_data JSONB DEFAULT '{}',
    -- Structure: { actions: [...], milestones: [] }

    -- Value Realisation
    value_data JSONB DEFAULT '{}',
    -- Structure: { outcomes: [...], roi: {...}, advocacy: {...} }

    -- Progress tracking
    completion_percentage INTEGER DEFAULT 0,
    steps_completed JSONB DEFAULT '{"snapshot": false, "stakeholders": false, "engagement": false, "support": false, "opportunities": false, "risks": false}',

    -- Revision tracking
    revision_notes TEXT,
    revision_requested_at TIMESTAMPTZ,
    revision_requested_by TEXT,

    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_edited_by TEXT,
    version INTEGER DEFAULT 1
);

-- ============================================================================
-- PLAN VERSIONS TABLE
-- Stores version history for both territory strategies and account plans
-- ============================================================================

CREATE TABLE IF NOT EXISTS plan_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Reference to parent plan
    plan_type TEXT NOT NULL CHECK (plan_type IN ('territory', 'account')),
    plan_id UUID NOT NULL,

    -- Version info
    version_number INTEGER NOT NULL,

    -- Full snapshot of the plan at this version
    plan_data JSONB NOT NULL,

    -- Change tracking
    changed_by TEXT NOT NULL,
    change_summary TEXT,

    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- PLAN COMMENTS TABLE
-- Stores comments and feedback on plans
-- ============================================================================

CREATE TABLE IF NOT EXISTS plan_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Reference to parent plan
    plan_type TEXT NOT NULL CHECK (plan_type IN ('territory', 'account')),
    plan_id UUID NOT NULL,

    -- Comment details
    section TEXT, -- Which section the comment relates to (NULL for general)
    comment_text TEXT NOT NULL,
    author TEXT NOT NULL,
    author_role TEXT, -- 'owner', 'reviewer', 'manager'

    -- Threading
    parent_comment_id UUID REFERENCES plan_comments(id),

    -- Status
    resolved BOOLEAN DEFAULT FALSE,
    resolved_at TIMESTAMPTZ,
    resolved_by TEXT,

    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- PLAN EXPORTS TABLE
-- Tracks export history
-- ============================================================================

CREATE TABLE IF NOT EXISTS plan_exports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Reference to parent plan
    plan_type TEXT NOT NULL CHECK (plan_type IN ('territory', 'account')),
    plan_id UUID NOT NULL,

    -- Export details
    format TEXT NOT NULL CHECK (format IN ('pdf', 'pptx', 'docx', 'xlsx')),
    sections_included JSONB DEFAULT '[]',
    branded BOOLEAN DEFAULT TRUE,

    -- File reference (if stored)
    file_url TEXT,
    file_name TEXT,

    -- Metadata
    exported_by TEXT NOT NULL,
    exported_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Territory strategies
CREATE INDEX IF NOT EXISTS idx_territory_strategies_cse ON territory_strategies(cse_name);
CREATE INDEX IF NOT EXISTS idx_territory_strategies_status ON territory_strategies(status);
CREATE INDEX IF NOT EXISTS idx_territory_strategies_year ON territory_strategies(fiscal_year);
CREATE INDEX IF NOT EXISTS idx_territory_strategies_updated ON territory_strategies(updated_at DESC);

-- Account plans
CREATE INDEX IF NOT EXISTS idx_account_plans_cam ON account_plans(cam_name);
CREATE INDEX IF NOT EXISTS idx_account_plans_client ON account_plans(client_name);
CREATE INDEX IF NOT EXISTS idx_account_plans_status ON account_plans(status);
CREATE INDEX IF NOT EXISTS idx_account_plans_year ON account_plans(fiscal_year);
CREATE INDEX IF NOT EXISTS idx_account_plans_updated ON account_plans(updated_at DESC);

-- Plan versions
CREATE INDEX IF NOT EXISTS idx_plan_versions_plan ON plan_versions(plan_type, plan_id);
CREATE INDEX IF NOT EXISTS idx_plan_versions_created ON plan_versions(created_at DESC);

-- Plan comments
CREATE INDEX IF NOT EXISTS idx_plan_comments_plan ON plan_comments(plan_type, plan_id);
CREATE INDEX IF NOT EXISTS idx_plan_comments_unresolved ON plan_comments(plan_type, plan_id) WHERE resolved = FALSE;

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE territory_strategies ENABLE ROW LEVEL SECURITY;
ALTER TABLE account_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE plan_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE plan_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE plan_exports ENABLE ROW LEVEL SECURITY;

-- Policies for territory_strategies
CREATE POLICY "Users can view all territory strategies"
    ON territory_strategies FOR SELECT
    USING (true);

CREATE POLICY "Users can insert their own territory strategies"
    ON territory_strategies FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Users can update territory strategies"
    ON territory_strategies FOR UPDATE
    USING (true);

-- Policies for account_plans
CREATE POLICY "Users can view all account plans"
    ON account_plans FOR SELECT
    USING (true);

CREATE POLICY "Users can insert their own account plans"
    ON account_plans FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Users can update account plans"
    ON account_plans FOR UPDATE
    USING (true);

-- Policies for plan_versions
CREATE POLICY "Users can view all plan versions"
    ON plan_versions FOR SELECT
    USING (true);

CREATE POLICY "Users can insert plan versions"
    ON plan_versions FOR INSERT
    WITH CHECK (true);

-- Policies for plan_comments
CREATE POLICY "Users can view all plan comments"
    ON plan_comments FOR SELECT
    USING (true);

CREATE POLICY "Users can insert plan comments"
    ON plan_comments FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Users can update plan comments"
    ON plan_comments FOR UPDATE
    USING (true);

-- Policies for plan_exports
CREATE POLICY "Users can view all plan exports"
    ON plan_exports FOR SELECT
    USING (true);

CREATE POLICY "Users can insert plan exports"
    ON plan_exports FOR INSERT
    WITH CHECK (true);

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_plan_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER territory_strategies_updated_at
    BEFORE UPDATE ON territory_strategies
    FOR EACH ROW
    EXECUTE FUNCTION update_plan_updated_at();

CREATE TRIGGER account_plans_updated_at
    BEFORE UPDATE ON account_plans
    FOR EACH ROW
    EXECUTE FUNCTION update_plan_updated_at();

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE territory_strategies IS 'CSE territory-wide planning documents for Compass submissions';
COMMENT ON TABLE account_plans IS 'CAM account-specific planning documents for Compass submissions';
COMMENT ON TABLE plan_versions IS 'Version history for territory strategies and account plans';
COMMENT ON TABLE plan_comments IS 'Comments and feedback on plans from reviewers';
COMMENT ON TABLE plan_exports IS 'Export history tracking for plans';
