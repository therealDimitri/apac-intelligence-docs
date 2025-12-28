-- ============================================================================
-- Financial Monitoring & Actions System
-- ============================================================================
-- This migration creates:
-- 1. financial_alerts - Captures changes to financial data for monitoring
-- 2. financial_actions - Maps financial data to CS/Sales actionable items
-- 3. Triggers to automatically create alerts when data changes
-- 4. Views to surface priority actions based on financial thresholds
-- ============================================================================

-- ============================================================================
-- 1. FINANCIAL ALERTS TABLE
-- Tracks changes to financial data that need attention
-- ============================================================================
CREATE TABLE IF NOT EXISTS financial_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Alert categorisation
  alert_type TEXT NOT NULL CHECK (alert_type IN (
    'attrition_risk',      -- Client at risk of leaving
    'renewal_due',         -- Contract renewal approaching
    'renewal_overdue',     -- Contract renewal past due
    'revenue_decline',     -- Revenue dropping
    'payment_overdue',     -- Aged receivables issue
    'business_case_stale', -- Business case not progressing
    'target_at_risk',      -- Quarterly/annual target at risk
    'cpi_opportunity',     -- CPI increase opportunity
    'upsell_opportunity'   -- Potential upsell identified
  )),

  -- Severity and priority
  severity TEXT NOT NULL DEFAULT 'medium' CHECK (severity IN ('critical', 'high', 'medium', 'low')),
  priority_score INTEGER DEFAULT 50 CHECK (priority_score BETWEEN 0 AND 100),

  -- Context
  client_name TEXT NOT NULL,
  client_id UUID REFERENCES clients(id),
  source_table TEXT NOT NULL,
  source_record_id UUID,

  -- Alert details
  title TEXT NOT NULL,
  description TEXT,
  financial_impact DECIMAL(15,2), -- USD value at risk or opportunity

  -- Thresholds that triggered alert
  threshold_metric TEXT,
  threshold_value DECIMAL(15,2),
  current_value DECIMAL(15,2),

  -- Recommended actions
  recommended_actions JSONB DEFAULT '[]',

  -- Status tracking
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'acknowledged', 'in_progress', 'resolved', 'dismissed')),
  assigned_to TEXT,
  assigned_at TIMESTAMPTZ,
  resolved_at TIMESTAMPTZ,
  resolution_notes TEXT,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ -- Some alerts auto-expire
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_financial_alerts_status ON financial_alerts(status);
CREATE INDEX IF NOT EXISTS idx_financial_alerts_type ON financial_alerts(alert_type);
CREATE INDEX IF NOT EXISTS idx_financial_alerts_client ON financial_alerts(client_name);
CREATE INDEX IF NOT EXISTS idx_financial_alerts_severity ON financial_alerts(severity, priority_score DESC);
CREATE INDEX IF NOT EXISTS idx_financial_alerts_created ON financial_alerts(created_at DESC);

-- ============================================================================
-- 2. FINANCIAL ACTIONS TABLE
-- Specific actions derived from financial data for CS and Sales teams
-- ============================================================================
CREATE TABLE IF NOT EXISTS financial_actions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Action categorisation
  action_type TEXT NOT NULL CHECK (action_type IN (
    'client_retention',     -- Prevent attrition
    'renewal_preparation',  -- Prepare for contract renewal
    'renewal_negotiation',  -- Negotiate renewal terms
    'revenue_recovery',     -- Recover declining revenue
    'collection_follow_up', -- Follow up on aged receivables
    'business_case_advance',-- Move business case forward
    'quarterly_review',     -- Quarterly business review
    'cpi_negotiation',      -- Negotiate CPI increase
    'upsell_pursuit',       -- Pursue upsell opportunity
    'stakeholder_engagement'-- Engage key stakeholders
  )),

  -- Team assignment
  team TEXT NOT NULL CHECK (team IN ('client_success', 'sales', 'finance', 'leadership')),

  -- Context
  client_name TEXT NOT NULL,
  client_id UUID REFERENCES clients(id),
  alert_id UUID REFERENCES financial_alerts(id),

  -- Action details
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  success_criteria TEXT,

  -- Financial context
  revenue_at_stake DECIMAL(15,2),
  revenue_opportunity DECIMAL(15,2),

  -- Timeline
  due_date DATE,
  urgency TEXT NOT NULL DEFAULT 'normal' CHECK (urgency IN ('immediate', 'urgent', 'normal', 'low')),

  -- Dependencies
  dependencies JSONB DEFAULT '[]', -- Other actions that must complete first
  related_meetings UUID[], -- Related meeting IDs
  related_actions UUID[], -- Related action IDs in actions table

  -- Status
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'blocked', 'cancelled')),
  assigned_to TEXT,
  completed_at TIMESTAMPTZ,
  outcome TEXT,

  -- Tracking
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_financial_actions_status ON financial_actions(status);
CREATE INDEX IF NOT EXISTS idx_financial_actions_team ON financial_actions(team);
CREATE INDEX IF NOT EXISTS idx_financial_actions_client ON financial_actions(client_name);
CREATE INDEX IF NOT EXISTS idx_financial_actions_due ON financial_actions(due_date);
CREATE INDEX IF NOT EXISTS idx_financial_actions_urgency ON financial_actions(urgency, due_date);

-- ============================================================================
-- 3. TRIGGER FUNCTIONS
-- Automatically create alerts when financial data changes
-- ============================================================================

-- Function to create renewal alerts
CREATE OR REPLACE FUNCTION fn_check_renewal_alerts()
RETURNS TRIGGER AS $$
DECLARE
  days_until INTEGER;
  alert_severity TEXT;
  alert_title TEXT;
BEGIN
  -- Calculate days until renewal
  days_until := NEW.renewal_date - CURRENT_DATE;

  -- Determine severity based on days until renewal
  IF days_until < 0 THEN
    alert_severity := 'critical';
    alert_title := 'Contract renewal OVERDUE: ' || NEW.client_name;
  ELSIF days_until <= 30 THEN
    alert_severity := 'high';
    alert_title := 'Contract renewal due in ' || days_until || ' days: ' || NEW.client_name;
  ELSIF days_until <= 90 THEN
    alert_severity := 'medium';
    alert_title := 'Contract renewal approaching: ' || NEW.client_name;
  ELSE
    -- No alert needed for renewals > 90 days away
    RETURN NEW;
  END IF;

  -- Check if alert already exists for this renewal
  IF NOT EXISTS (
    SELECT 1 FROM financial_alerts
    WHERE source_table = 'contract_renewals'
    AND source_record_id = NEW.id
    AND status NOT IN ('resolved', 'dismissed')
  ) THEN
    INSERT INTO financial_alerts (
      alert_type,
      severity,
      priority_score,
      client_name,
      source_table,
      source_record_id,
      title,
      description,
      financial_impact,
      threshold_metric,
      threshold_value,
      current_value,
      recommended_actions,
      expires_at
    ) VALUES (
      CASE WHEN days_until < 0 THEN 'renewal_overdue' ELSE 'renewal_due' END,
      alert_severity,
      CASE
        WHEN days_until < 0 THEN 100
        WHEN days_until <= 30 THEN 90
        WHEN days_until <= 60 THEN 70
        ELSE 50
      END,
      NEW.client_name,
      'contract_renewals',
      NEW.id,
      alert_title,
      'Contract for ' || COALESCE(NEW.solution, 'Unknown') || ' solution. Annual value: $' || COALESCE(NEW.annual_value::TEXT, '0'),
      NEW.annual_value,
      'days_until_renewal',
      90, -- Threshold
      days_until,
      jsonb_build_array(
        jsonb_build_object('action', 'Schedule renewal meeting', 'team', 'client_success'),
        jsonb_build_object('action', 'Review contract terms', 'team', 'sales'),
        jsonb_build_object('action', 'Prepare renewal proposal', 'team', 'sales')
      ),
      NEW.renewal_date + INTERVAL '30 days' -- Alert expires 30 days after renewal date
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to create attrition alerts
CREATE OR REPLACE FUNCTION fn_check_attrition_alerts()
RETURNS TRIGGER AS $$
BEGIN
  -- Only create alert for significant attrition risk
  IF NEW.revenue_at_risk_2026 > 50000 OR NEW.total_revenue_at_risk > 100000 THEN
    -- Check if alert already exists
    IF NOT EXISTS (
      SELECT 1 FROM financial_alerts
      WHERE source_table = 'attrition_risk'
      AND source_record_id = NEW.id
      AND status NOT IN ('resolved', 'dismissed')
    ) THEN
      INSERT INTO financial_alerts (
        alert_type,
        severity,
        priority_score,
        client_name,
        source_table,
        source_record_id,
        title,
        description,
        financial_impact,
        recommended_actions
      ) VALUES (
        'attrition_risk',
        CASE
          WHEN NEW.total_revenue_at_risk > 500000 THEN 'critical'
          WHEN NEW.total_revenue_at_risk > 200000 THEN 'high'
          ELSE 'medium'
        END,
        LEAST(100, GREATEST(0, (NEW.total_revenue_at_risk / 10000)::INTEGER)),
        NEW.client_name,
        'attrition_risk',
        NEW.id,
        'Attrition Risk: ' || NEW.client_name || ' ($' || (NEW.total_revenue_at_risk/1000)::INTEGER || 'K)',
        NEW.attrition_type || ' attrition. Reason: ' || COALESCE(NEW.reason, 'Unknown'),
        NEW.total_revenue_at_risk,
        jsonb_build_array(
          jsonb_build_object('action', 'Schedule executive sponsor meeting', 'team', 'leadership'),
          jsonb_build_object('action', 'Conduct relationship health assessment', 'team', 'client_success'),
          jsonb_build_object('action', 'Identify retention opportunities', 'team', 'sales'),
          jsonb_build_object('action', 'Prepare competitive analysis', 'team', 'sales')
        )
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to check business case progress
CREATE OR REPLACE FUNCTION fn_check_business_case_alerts()
RETURNS TRIGGER AS $$
DECLARE
  total_value DECIMAL;
BEGIN
  -- Calculate total business case value
  total_value := COALESCE(NEW.revenue_software, 0) +
                 COALESCE(NEW.revenue_professional_services, 0) +
                 COALESCE(NEW.revenue_maintenance, 0);

  -- Only alert for significant business cases that aren't progressing
  IF total_value > 100000 AND NEW.current_gate IN ('Gate 1', 'Gate 2') THEN
    -- Check if last update was more than 30 days ago
    IF NEW.updated_at < NOW() - INTERVAL '30 days' THEN
      IF NOT EXISTS (
        SELECT 1 FROM financial_alerts
        WHERE source_table = 'business_case_pipeline'
        AND source_record_id = NEW.id
        AND status NOT IN ('resolved', 'dismissed')
        AND created_at > NOW() - INTERVAL '7 days' -- Don't duplicate within 7 days
      ) THEN
        INSERT INTO financial_alerts (
          alert_type,
          severity,
          priority_score,
          client_name,
          source_table,
          source_record_id,
          title,
          description,
          financial_impact,
          recommended_actions
        ) VALUES (
          'business_case_stale',
          CASE WHEN total_value > 300000 THEN 'high' ELSE 'medium' END,
          LEAST(100, GREATEST(0, (total_value / 5000)::INTEGER)),
          NEW.client_name,
          'business_case_pipeline',
          NEW.id,
          'Business Case Stale: ' || NEW.business_case_name,
          'No progress for 30+ days. Current stage: ' || NEW.current_gate || '. Value: $' || (total_value/1000)::INTEGER || 'K',
          total_value,
          jsonb_build_array(
            jsonb_build_object('action', 'Review blockers with client', 'team', 'sales'),
            jsonb_build_object('action', 'Update business case status', 'team', 'sales'),
            jsonb_build_object('action', 'Schedule follow-up meeting', 'team', 'client_success')
          )
        );
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 4. CREATE TRIGGERS
-- ============================================================================

-- Drop existing triggers if they exist
DROP TRIGGER IF EXISTS trg_contract_renewals_alert ON contract_renewals;
DROP TRIGGER IF EXISTS trg_attrition_risk_alert ON attrition_risk;
DROP TRIGGER IF EXISTS trg_business_case_alert ON business_case_pipeline;

-- Create triggers
CREATE TRIGGER trg_contract_renewals_alert
  AFTER INSERT OR UPDATE ON contract_renewals
  FOR EACH ROW
  EXECUTE FUNCTION fn_check_renewal_alerts();

CREATE TRIGGER trg_attrition_risk_alert
  AFTER INSERT OR UPDATE ON attrition_risk
  FOR EACH ROW
  EXECUTE FUNCTION fn_check_attrition_alerts();

CREATE TRIGGER trg_business_case_alert
  AFTER INSERT OR UPDATE ON business_case_pipeline
  FOR EACH ROW
  EXECUTE FUNCTION fn_check_business_case_alerts();

-- ============================================================================
-- 5. VIEWS FOR ACTIONABLE INTELLIGENCE
-- ============================================================================

-- Priority Financial Actions View
CREATE OR REPLACE VIEW v_priority_financial_actions AS
WITH renewal_actions AS (
  SELECT
    cr.client_name,
    'renewal_preparation' AS action_type,
    'client_success' AS team,
    'Prepare for ' || cr.solution || ' renewal' AS title,
    'Contract renewal on ' || cr.renewal_date || '. Current value: $' || (cr.annual_value/1000)::INTEGER || 'K. Status: ' || COALESCE(cr.renewal_status, 'pending') AS description,
    cr.annual_value AS revenue_at_stake,
    cr.renewal_date AS due_date,
    CASE
      WHEN cr.days_until_renewal < 0 THEN 'immediate'
      WHEN cr.days_until_renewal <= 30 THEN 'urgent'
      WHEN cr.days_until_renewal <= 60 THEN 'normal'
      ELSE 'low'
    END AS urgency,
    cr.days_until_renewal,
    CASE
      WHEN cr.days_until_renewal < 0 THEN 100
      WHEN cr.days_until_renewal <= 30 THEN 90 - cr.days_until_renewal
      WHEN cr.days_until_renewal <= 90 THEN 60 - (cr.days_until_renewal / 3)
      ELSE 30
    END AS priority_score
  FROM contract_renewals cr
  WHERE cr.renewal_status NOT IN ('renewed', 'churned', 'declined')
),
attrition_actions AS (
  SELECT
    ar.client_name,
    'client_retention' AS action_type,
    'client_success' AS team,
    'Retention engagement: ' || ar.client_name AS title,
    ar.attrition_type || ' attrition risk. ' || COALESCE(ar.reason, '') || '. Revenue at risk: $' || (ar.total_revenue_at_risk/1000)::INTEGER || 'K' AS description,
    ar.total_revenue_at_risk AS revenue_at_stake,
    ar.forecast_date AS due_date,
    CASE
      WHEN ar.total_revenue_at_risk > 500000 THEN 'immediate'
      WHEN ar.total_revenue_at_risk > 200000 THEN 'urgent'
      ELSE 'normal'
    END AS urgency,
    (ar.forecast_date - CURRENT_DATE) AS days_until,
    LEAST(100, (ar.total_revenue_at_risk / 10000)::INTEGER) AS priority_score
  FROM attrition_risk ar
  WHERE ar.status IS NULL OR ar.status NOT IN ('resolved', 'retained')
),
business_case_actions AS (
  SELECT
    bc.client_name,
    'business_case_advance' AS action_type,
    'sales' AS team,
    'Advance: ' || bc.business_case_name AS title,
    'Current gate: ' || COALESCE(bc.current_gate, 'Unknown') || '. Next action: ' || COALESCE(bc.next_action, 'Review status') AS description,
    (COALESCE(bc.revenue_software, 0) + COALESCE(bc.revenue_professional_services, 0) + COALESCE(bc.revenue_maintenance, 0)) AS revenue_at_stake,
    bc.next_action_date AS due_date,
    CASE
      WHEN bc.next_action_date < CURRENT_DATE THEN 'urgent'
      WHEN bc.next_action_date <= CURRENT_DATE + 7 THEN 'normal'
      ELSE 'low'
    END AS urgency,
    (bc.next_action_date - CURRENT_DATE) AS days_until,
    CASE
      WHEN bc.current_gate = 'Gate 3' THEN 80
      WHEN bc.current_gate = 'Gate 2' THEN 60
      ELSE 40
    END AS priority_score
  FROM business_case_pipeline bc
  WHERE bc.status IS NULL OR bc.status NOT IN ('won', 'lost', 'cancelled')
)
SELECT * FROM renewal_actions
UNION ALL
SELECT * FROM attrition_actions
UNION ALL
SELECT * FROM business_case_actions
ORDER BY priority_score DESC, due_date ASC;

-- Financial Health Dashboard View
CREATE OR REPLACE VIEW v_financial_health_dashboard AS
SELECT
  c.display_name AS client_name,
  c.id AS client_id,
  -- Revenue summary
  COALESCE(cf.revenue_maintenance, 0) AS maintenance_revenue,
  COALESCE(cf.revenue_professional_services, 0) AS ps_revenue,
  COALESCE(cf.revenue_total, 0) AS total_revenue,
  -- Risk indicators
  COALESCE(ar.total_revenue_at_risk, 0) AS attrition_risk_value,
  ar.attrition_type,
  ar.forecast_date AS attrition_forecast,
  -- Renewal status
  cr.renewal_date AS next_renewal,
  cr.days_until_renewal,
  cr.renewal_status,
  cr.annual_value AS renewal_value,
  -- Pipeline
  COALESCE(bp.total_pipeline, 0) AS business_case_pipeline,
  bp.active_cases,
  -- Health score
  CASE
    WHEN ar.total_revenue_at_risk > 200000 THEN 'at_risk'
    WHEN cr.days_until_renewal < 0 THEN 'critical'
    WHEN cr.days_until_renewal < 30 THEN 'attention'
    ELSE 'healthy'
  END AS financial_health
FROM clients c
LEFT JOIN client_financials cf ON cf.client_name = c.canonical_name AND cf.fiscal_year = 2026
LEFT JOIN attrition_risk ar ON ar.client_name = c.canonical_name AND ar.status IS DISTINCT FROM 'resolved'
LEFT JOIN (
  SELECT client_name, MIN(renewal_date) AS renewal_date,
         MIN(days_until_renewal) AS days_until_renewal,
         MAX(renewal_status) AS renewal_status,
         SUM(annual_value) AS annual_value
  FROM contract_renewals
  WHERE renewal_status NOT IN ('renewed', 'churned')
  GROUP BY client_name
) cr ON cr.client_name = c.canonical_name
LEFT JOIN (
  SELECT client_name,
         SUM(COALESCE(revenue_software, 0) + COALESCE(revenue_professional_services, 0) + COALESCE(revenue_maintenance, 0)) AS total_pipeline,
         COUNT(*) AS active_cases
  FROM business_case_pipeline
  WHERE status IS DISTINCT FROM 'won' AND status IS DISTINCT FROM 'lost'
  GROUP BY client_name
) bp ON bp.client_name = c.canonical_name;

-- ============================================================================
-- 6. RLS POLICIES
-- ============================================================================

ALTER TABLE financial_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_actions ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to view all financial data
CREATE POLICY "Allow authenticated read on financial_alerts" ON financial_alerts
  FOR SELECT USING (true);

CREATE POLICY "Allow authenticated read on financial_actions" ON financial_actions
  FOR SELECT USING (true);

-- Allow service role full access
CREATE POLICY "Allow service role all on financial_alerts" ON financial_alerts
  FOR ALL USING (true);

CREATE POLICY "Allow service role all on financial_actions" ON financial_actions
  FOR ALL USING (true);

-- ============================================================================
-- 7. SEED INITIAL ALERTS FROM EXISTING DATA
-- ============================================================================

-- Generate renewal alerts for existing contracts
INSERT INTO financial_alerts (
  alert_type,
  severity,
  priority_score,
  client_name,
  source_table,
  source_record_id,
  title,
  description,
  financial_impact,
  threshold_metric,
  current_value,
  recommended_actions
)
SELECT
  CASE WHEN days_until_renewal < 0 THEN 'renewal_overdue' ELSE 'renewal_due' END,
  CASE
    WHEN days_until_renewal < 0 THEN 'critical'
    WHEN days_until_renewal <= 30 THEN 'high'
    WHEN days_until_renewal <= 90 THEN 'medium'
    ELSE 'low'
  END,
  CASE
    WHEN days_until_renewal < 0 THEN 100
    WHEN days_until_renewal <= 30 THEN 90
    WHEN days_until_renewal <= 60 THEN 70
    ELSE 50
  END,
  client_name,
  'contract_renewals',
  id,
  CASE
    WHEN days_until_renewal < 0 THEN 'Contract renewal OVERDUE: ' || client_name
    ELSE 'Contract renewal in ' || days_until_renewal || ' days: ' || client_name
  END,
  'Contract for ' || COALESCE(solution, 'Unknown') || '. Annual value: $' || COALESCE(annual_value::TEXT, '0'),
  annual_value,
  'days_until_renewal',
  days_until_renewal,
  jsonb_build_array(
    jsonb_build_object('action', 'Schedule renewal meeting', 'team', 'client_success'),
    jsonb_build_object('action', 'Review contract terms', 'team', 'sales'),
    jsonb_build_object('action', 'Prepare renewal proposal', 'team', 'sales')
  )
FROM contract_renewals
WHERE renewal_status NOT IN ('renewed', 'churned', 'declined')
AND days_until_renewal <= 180
ON CONFLICT DO NOTHING;

-- Generate attrition alerts
INSERT INTO financial_alerts (
  alert_type,
  severity,
  priority_score,
  client_name,
  source_table,
  source_record_id,
  title,
  description,
  financial_impact,
  recommended_actions
)
SELECT
  'attrition_risk',
  CASE
    WHEN total_revenue_at_risk > 500000 THEN 'critical'
    WHEN total_revenue_at_risk > 200000 THEN 'high'
    ELSE 'medium'
  END,
  LEAST(100, GREATEST(0, (total_revenue_at_risk / 10000)::INTEGER)),
  client_name,
  'attrition_risk',
  id,
  'Attrition Risk: ' || client_name || ' ($' || (total_revenue_at_risk/1000)::INTEGER || 'K)',
  attrition_type || ' attrition. Reason: ' || COALESCE(reason, 'Unknown'),
  total_revenue_at_risk,
  jsonb_build_array(
    jsonb_build_object('action', 'Schedule executive sponsor meeting', 'team', 'leadership'),
    jsonb_build_object('action', 'Conduct relationship health assessment', 'team', 'client_success'),
    jsonb_build_object('action', 'Identify retention opportunities', 'team', 'sales')
  )
FROM attrition_risk
WHERE (status IS NULL OR status NOT IN ('resolved', 'retained'))
AND total_revenue_at_risk > 50000
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 8. UPDATED_AT TRIGGER
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_financial_alerts_updated
  BEFORE UPDATE ON financial_alerts
  FOR EACH ROW
  EXECUTE FUNCTION fn_update_timestamp();

CREATE TRIGGER trg_financial_actions_updated
  BEFORE UPDATE ON financial_actions
  FOR EACH ROW
  EXECUTE FUNCTION fn_update_timestamp();

-- ============================================================================
-- COMPLETE
-- ============================================================================
