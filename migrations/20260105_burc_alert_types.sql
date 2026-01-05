-- =============================================
-- BURC Alert Types Migration
-- Created: 2026-01-05
-- Purpose: Add BURC-specific alert types and configuration tables
-- =============================================

-- Add new alert categories to existing alerts table
-- Note: Assumes alerts table already exists from previous migrations

COMMENT ON TABLE alerts IS 'Stores all detected alerts including health, compliance, and BURC-specific alerts';

-- Create BURC alert thresholds configuration table
CREATE TABLE IF NOT EXISTS burc_alert_thresholds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- NRR Thresholds
    nrr_decline_threshold DECIMAL(5,2) DEFAULT 5.0 CHECK (nrr_decline_threshold >= 0),
    nrr_critical_level DECIMAL(5,2) DEFAULT 90.0 CHECK (nrr_critical_level >= 0 AND nrr_critical_level <= 100),

    -- Renewal Risk Thresholds
    renewal_days_warning INTEGER DEFAULT 90 CHECK (renewal_days_warning > 0),
    renewal_days_critical INTEGER DEFAULT 60 CHECK (renewal_days_critical > 0),
    renewal_low_engagement_meetings INTEGER DEFAULT 2 CHECK (renewal_low_engagement_meetings >= 0),

    -- Pipeline Thresholds
    pipeline_coverage_minimum DECIMAL(5,2) DEFAULT 3.0 CHECK (pipeline_coverage_minimum > 0),
    pipeline_coverage_warning DECIMAL(5,2) DEFAULT 2.0 CHECK (pipeline_coverage_warning > 0),

    -- Revenue Concentration Thresholds
    top_clients_count INTEGER DEFAULT 3 CHECK (top_clients_count > 0),
    concentration_critical DECIMAL(5,2) DEFAULT 40.0 CHECK (concentration_critical >= 0 AND concentration_critical <= 100),
    concentration_warning DECIMAL(5,2) DEFAULT 30.0 CHECK (concentration_warning >= 0 AND concentration_warning <= 100),

    -- Collections Thresholds
    aging_amount_critical DECIMAL(12,2) DEFAULT 100000.00 CHECK (aging_amount_critical >= 0),
    aging_days_critical INTEGER DEFAULT 90 CHECK (aging_days_critical > 0),

    -- Churn Prediction Thresholds
    churn_score_critical DECIMAL(5,2) DEFAULT 70.0 CHECK (churn_score_critical >= 0 AND churn_score_critical <= 100),
    churn_score_warning DECIMAL(5,2) DEFAULT 50.0 CHECK (churn_score_warning >= 0 AND churn_score_warning <= 100),

    -- PS Margin Thresholds
    ps_margin_critical DECIMAL(5,2) DEFAULT 15.0 CHECK (ps_margin_critical >= 0 AND ps_margin_critical <= 100),
    ps_margin_warning DECIMAL(5,2) DEFAULT 20.0 CHECK (ps_margin_warning >= 0 AND ps_margin_warning <= 100),

    -- Configuration metadata
    is_active BOOLEAN DEFAULT true,
    effective_from TIMESTAMPTZ DEFAULT NOW(),
    effective_to TIMESTAMPTZ,
    notes TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by TEXT,
    updated_by TEXT
);

COMMENT ON TABLE burc_alert_thresholds IS 'Configuration thresholds for BURC alert detection';
COMMENT ON COLUMN burc_alert_thresholds.nrr_decline_threshold IS 'Percentage point decline in NRR to trigger alert (default: 5%)';
COMMENT ON COLUMN burc_alert_thresholds.nrr_critical_level IS 'NRR level below which is considered critical (default: 90%)';
COMMENT ON COLUMN burc_alert_thresholds.renewal_days_warning IS 'Days before renewal to trigger warning alert (default: 90)';
COMMENT ON COLUMN burc_alert_thresholds.renewal_days_critical IS 'Days before renewal to trigger critical alert (default: 60)';
COMMENT ON COLUMN burc_alert_thresholds.pipeline_coverage_minimum IS 'Minimum pipeline coverage ratio (default: 3x target)';
COMMENT ON COLUMN burc_alert_thresholds.concentration_critical IS 'Percentage of revenue from top N clients to trigger critical alert (default: 40%)';
COMMENT ON COLUMN burc_alert_thresholds.aging_amount_critical IS 'Amount in 90+ day aging buckets to trigger alert (default: $100,000)';

-- Insert default configuration
INSERT INTO burc_alert_thresholds (
    is_active,
    notes,
    created_by
) VALUES (
    true,
    'Default BURC alert thresholds - configured 2026-01-05',
    'system'
);

-- Create BURC alert history table for tracking alert trends
CREATE TABLE IF NOT EXISTS burc_alert_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    detection_date DATE NOT NULL,

    -- Alert counts by category
    nrr_decline_count INTEGER DEFAULT 0,
    renewal_risk_count INTEGER DEFAULT 0,
    pipeline_gap_count INTEGER DEFAULT 0,
    revenue_concentration_count INTEGER DEFAULT 0,
    collections_aging_count INTEGER DEFAULT 0,
    churn_prediction_count INTEGER DEFAULT 0,
    ps_margin_erosion_count INTEGER DEFAULT 0,

    -- Alert counts by severity
    critical_count INTEGER DEFAULT 0,
    high_count INTEGER DEFAULT 0,
    medium_count INTEGER DEFAULT 0,
    low_count INTEGER DEFAULT 0,

    total_alerts INTEGER DEFAULT 0,
    alerts_acknowledged INTEGER DEFAULT 0,
    alerts_dismissed INTEGER DEFAULT 0,
    alerts_resolved INTEGER DEFAULT 0,
    actions_created INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_burc_alert_history_date ON burc_alert_history(detection_date DESC);

COMMENT ON TABLE burc_alert_history IS 'Historical record of BURC alert detection runs for trend analysis';

-- Create user preferences for BURC alerts
CREATE TABLE IF NOT EXISTS user_alert_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    user_email TEXT NOT NULL,

    -- BURC alert preferences
    receive_burc_alerts BOOLEAN DEFAULT true,
    receive_nrr_alerts BOOLEAN DEFAULT true,
    receive_renewal_alerts BOOLEAN DEFAULT true,
    receive_pipeline_alerts BOOLEAN DEFAULT true,
    receive_concentration_alerts BOOLEAN DEFAULT true,
    receive_collections_alerts BOOLEAN DEFAULT true,
    receive_ps_margin_alerts BOOLEAN DEFAULT true,

    -- Notification preferences
    email_notifications BOOLEAN DEFAULT true,
    in_app_notifications BOOLEAN DEFAULT true,
    severity_threshold TEXT DEFAULT 'high', -- 'critical', 'high', 'medium', 'low'

    -- Digest preferences
    daily_digest BOOLEAN DEFAULT false,
    weekly_digest BOOLEAN DEFAULT true,
    digest_day TEXT DEFAULT 'monday', -- For weekly digest
    digest_time TIME DEFAULT '08:00:00',

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id)
);

CREATE INDEX idx_user_alert_prefs_email ON user_alert_preferences(user_email);
CREATE INDEX idx_user_alert_prefs_receive ON user_alert_preferences(receive_burc_alerts) WHERE receive_burc_alerts = true;

COMMENT ON TABLE user_alert_preferences IS 'User-specific preferences for BURC alert notifications';

-- Create alert acknowledgment log
CREATE TABLE IF NOT EXISTS alert_acknowledgments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_id UUID NOT NULL REFERENCES alerts(id) ON DELETE CASCADE,

    acknowledged_by TEXT NOT NULL,
    acknowledged_by_email TEXT,
    acknowledged_at TIMESTAMPTZ DEFAULT NOW(),

    action_taken TEXT, -- 'acknowledged', 'dismissed', 'resolved', 'escalated'
    notes TEXT,
    follow_up_required BOOLEAN DEFAULT false,
    follow_up_date DATE,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_alert_ack_alert_id ON alert_acknowledgments(alert_id);
CREATE INDEX idx_alert_ack_date ON alert_acknowledgments(acknowledged_at DESC);
CREATE INDEX idx_alert_ack_user ON alert_acknowledgments(acknowledged_by);

COMMENT ON TABLE alert_acknowledgments IS 'Audit trail of alert acknowledgments and actions taken';

-- Create function to update alert history
CREATE OR REPLACE FUNCTION update_burc_alert_history()
RETURNS void AS $$
DECLARE
    today DATE := CURRENT_DATE;
BEGIN
    INSERT INTO burc_alert_history (
        detection_date,
        nrr_decline_count,
        renewal_risk_count,
        pipeline_gap_count,
        revenue_concentration_count,
        collections_aging_count,
        churn_prediction_count,
        ps_margin_erosion_count,
        critical_count,
        high_count,
        medium_count,
        low_count,
        total_alerts,
        alerts_acknowledged,
        alerts_dismissed,
        alerts_resolved,
        actions_created
    )
    SELECT
        today,
        COUNT(*) FILTER (WHERE category = 'nrr_decline'),
        COUNT(*) FILTER (WHERE category = 'renewal_risk'),
        COUNT(*) FILTER (WHERE category = 'pipeline_gap'),
        COUNT(*) FILTER (WHERE category = 'revenue_concentration'),
        COUNT(*) FILTER (WHERE category = 'collections_aging'),
        COUNT(*) FILTER (WHERE category = 'churn_prediction'),
        COUNT(*) FILTER (WHERE category = 'ps_margin_erosion'),
        COUNT(*) FILTER (WHERE severity = 'critical'),
        COUNT(*) FILTER (WHERE severity = 'high'),
        COUNT(*) FILTER (WHERE severity = 'medium'),
        COUNT(*) FILTER (WHERE severity = 'low'),
        COUNT(*),
        COUNT(*) FILTER (WHERE status = 'acknowledged'),
        COUNT(*) FILTER (WHERE status = 'dismissed'),
        COUNT(*) FILTER (WHERE status = 'resolved'),
        COUNT(*) FILTER (WHERE auto_action_created = true)
    FROM alerts
    WHERE category IN (
        'nrr_decline',
        'renewal_risk',
        'pipeline_gap',
        'revenue_concentration',
        'collections_aging',
        'churn_prediction',
        'ps_margin_erosion'
    )
    AND DATE(detected_at) = today
    ON CONFLICT (detection_date) DO UPDATE SET
        nrr_decline_count = EXCLUDED.nrr_decline_count,
        renewal_risk_count = EXCLUDED.renewal_risk_count,
        pipeline_gap_count = EXCLUDED.pipeline_gap_count,
        revenue_concentration_count = EXCLUDED.revenue_concentration_count,
        collections_aging_count = EXCLUDED.collections_aging_count,
        churn_prediction_count = EXCLUDED.churn_prediction_count,
        ps_margin_erosion_count = EXCLUDED.ps_margin_erosion_count,
        critical_count = EXCLUDED.critical_count,
        high_count = EXCLUDED.high_count,
        medium_count = EXCLUDED.medium_count,
        low_count = EXCLUDED.low_count,
        total_alerts = EXCLUDED.total_alerts,
        alerts_acknowledged = EXCLUDED.alerts_acknowledged,
        alerts_dismissed = EXCLUDED.alerts_dismissed,
        alerts_resolved = EXCLUDED.alerts_resolved,
        actions_created = EXCLUDED.actions_created;
END;
$$ LANGUAGE plpgsql;

-- Add unique constraint on detection_date for alert history
ALTER TABLE burc_alert_history ADD CONSTRAINT uq_burc_alert_history_date UNIQUE (detection_date);

COMMENT ON FUNCTION update_burc_alert_history IS 'Updates daily BURC alert statistics';

-- Grant permissions (adjust schema/roles as needed)
-- GRANT SELECT, INSERT, UPDATE ON burc_alert_thresholds TO authenticated;
-- GRANT SELECT, INSERT ON burc_alert_history TO authenticated;
-- GRANT SELECT, INSERT, UPDATE ON user_alert_preferences TO authenticated;
-- GRANT SELECT, INSERT ON alert_acknowledgments TO authenticated;

-- Add helpful views

-- View: Current active BURC alerts summary
CREATE OR REPLACE VIEW v_burc_alerts_summary AS
SELECT
    category,
    severity,
    COUNT(*) as alert_count,
    COUNT(DISTINCT client_name) as affected_clients,
    MIN(detected_at) as oldest_alert,
    MAX(detected_at) as newest_alert
FROM alerts
WHERE category IN (
    'nrr_decline',
    'renewal_risk',
    'pipeline_gap',
    'revenue_concentration',
    'collections_aging',
    'churn_prediction',
    'ps_margin_erosion'
)
AND status = 'active'
GROUP BY category, severity
ORDER BY
    CASE severity
        WHEN 'critical' THEN 1
        WHEN 'high' THEN 2
        WHEN 'medium' THEN 3
        WHEN 'low' THEN 4
    END,
    category;

COMMENT ON VIEW v_burc_alerts_summary IS 'Summary of active BURC alerts by category and severity';

-- View: Alert response metrics
CREATE OR REPLACE VIEW v_alert_response_metrics AS
SELECT
    DATE(detected_at) as alert_date,
    category,
    severity,
    COUNT(*) as total_alerts,
    COUNT(*) FILTER (WHERE status = 'acknowledged') as acknowledged_count,
    COUNT(*) FILTER (WHERE status = 'dismissed') as dismissed_count,
    COUNT(*) FILTER (WHERE status = 'resolved') as resolved_count,
    COUNT(*) FILTER (WHERE auto_action_created = true) as actions_created,
    AVG(
        CASE
            WHEN status != 'active' AND updated_at IS NOT NULL
            THEN EXTRACT(EPOCH FROM (updated_at::timestamp - detected_at::timestamp))/3600
        END
    ) as avg_response_time_hours
FROM alerts
WHERE category IN (
    'nrr_decline',
    'renewal_risk',
    'pipeline_gap',
    'revenue_concentration',
    'collections_aging',
    'churn_prediction',
    'ps_margin_erosion'
)
GROUP BY DATE(detected_at), category, severity
ORDER BY alert_date DESC, category;

COMMENT ON VIEW v_alert_response_metrics IS 'Metrics on how quickly alerts are acknowledged and resolved';

-- Completed migration
SELECT 'BURC alert types migration completed successfully' AS status;
