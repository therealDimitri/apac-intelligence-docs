-- Migration: Add Predictive Alert Categories
-- Date: 2026-01-26
-- Purpose: Add churn_prediction and other predictive categories to alerts table

-- ============================================================================
-- 1. DROP AND RECREATE THE CATEGORY CHECK CONSTRAINT
-- ============================================================================

-- Drop the existing constraint
ALTER TABLE alerts DROP CONSTRAINT IF EXISTS alerts_category_check;

-- Add new constraint with all categories (existing + predictive)
ALTER TABLE alerts ADD CONSTRAINT alerts_category_check CHECK (category IN (
    -- Original categories
    'health_decline', 'health_status_change', 'nps_risk',
    'compliance_risk', 'compliance_trending_down', 'compliance_perfect',
    'compliance_deadline_approaching', 'renewal_approaching', 'action_overdue',
    'attrition_risk', 'engagement_gap', 'servicing_issue',
    -- BURC-specific categories
    'nrr_decline', 'renewal_risk', 'pipeline_gap',
    'revenue_concentration', 'collections_aging', 'ps_margin_erosion',
    -- Predictive alert categories (NEW)
    'churn_prediction',
    -- Support-specific categories
    'support_sla_breach', 'support_critical_case', 'support_satisfaction_low',
    'support_aging_cases', 'support_health_decline'
));

-- ============================================================================
-- 2. CREATE PREDICTIVE ALERT HISTORY TABLE (if not exists)
-- ============================================================================

CREATE TABLE IF NOT EXISTS predictive_alert_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    run_date DATE NOT NULL,
    clients_analysed INTEGER DEFAULT 0,
    total_alerts INTEGER DEFAULT 0,
    new_alerts INTEGER DEFAULT 0,
    critical_alerts INTEGER DEFAULT 0,
    high_alerts INTEGER DEFAULT 0,
    medium_alerts INTEGER DEFAULT 0,
    low_alerts INTEGER DEFAULT 0,
    health_trajectory_alerts INTEGER DEFAULT 0,
    churn_risk_alerts INTEGER DEFAULT 0,
    engagement_alerts INTEGER DEFAULT 0,
    peer_alerts INTEGER DEFAULT 0,
    expansion_alerts INTEGER DEFAULT 0,
    processing_time_ms INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_predictive_alert_history_date ON predictive_alert_history(run_date DESC);

-- ============================================================================
-- 3. CREATE PREDICTIVE ALERT THRESHOLDS TABLE (if not exists)
-- ============================================================================

CREATE TABLE IF NOT EXISTS predictive_alert_thresholds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    is_active BOOLEAN DEFAULT true,
    health_decline_critical INTEGER DEFAULT 15,
    health_decline_warning INTEGER DEFAULT 10,
    health_minimum_data_points INTEGER DEFAULT 3,
    churn_risk_critical INTEGER DEFAULT 70,
    churn_risk_high INTEGER DEFAULT 55,
    churn_risk_medium INTEGER DEFAULT 40,
    engagement_velocity_critical INTEGER DEFAULT 30,
    engagement_velocity_warning INTEGER DEFAULT 40,
    peer_percentile_critical INTEGER DEFAULT 10,
    peer_percentile_warning INTEGER DEFAULT 25,
    expansion_probability_high INTEGER DEFAULT 70,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default thresholds if table is empty
INSERT INTO predictive_alert_thresholds (is_active)
SELECT true
WHERE NOT EXISTS (SELECT 1 FROM predictive_alert_thresholds);

-- ============================================================================
-- 4. RLS POLICIES
-- ============================================================================

ALTER TABLE predictive_alert_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE predictive_alert_thresholds ENABLE ROW LEVEL SECURITY;

-- Policies for authenticated users
CREATE POLICY IF NOT EXISTS "predictive_alert_history_select" ON predictive_alert_history FOR SELECT TO authenticated USING (true);
CREATE POLICY IF NOT EXISTS "predictive_alert_history_insert" ON predictive_alert_history FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY IF NOT EXISTS "predictive_alert_thresholds_select" ON predictive_alert_thresholds FOR SELECT TO authenticated USING (true);
CREATE POLICY IF NOT EXISTS "predictive_alert_thresholds_update" ON predictive_alert_thresholds FOR UPDATE TO authenticated USING (true);

-- Service role bypass
CREATE POLICY IF NOT EXISTS "predictive_alert_history_service" ON predictive_alert_history FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "predictive_alert_thresholds_service" ON predictive_alert_thresholds FOR ALL TO service_role USING (true) WITH CHECK (true);

-- ============================================================================
-- 5. GRANT PERMISSIONS
-- ============================================================================

GRANT ALL ON predictive_alert_history TO authenticated;
GRANT ALL ON predictive_alert_thresholds TO authenticated;
GRANT ALL ON predictive_alert_history TO service_role;
GRANT ALL ON predictive_alert_thresholds TO service_role;

-- ============================================================================
-- Migration Complete
-- ============================================================================

SELECT 'Predictive alert categories migration completed' AS status;
