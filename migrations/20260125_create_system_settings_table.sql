-- Create system_settings table for storing global configuration
-- This table stores system-wide settings that affect all users

CREATE TABLE IF NOT EXISTS system_settings (
  id TEXT PRIMARY KEY DEFAULT 'global',

  -- Health Score Configuration
  health_score_version TEXT DEFAULT 'v4',
  healthy_threshold INTEGER DEFAULT 70,
  at_risk_threshold INTEGER DEFAULT 60,

  -- Alert Thresholds
  health_decline_alert_threshold INTEGER DEFAULT 10,
  nps_risk_threshold INTEGER DEFAULT 6,
  compliance_critical_threshold INTEGER DEFAULT 50,
  renewal_warning_days INTEGER DEFAULT 90,
  action_overdue_days INTEGER DEFAULT 7,

  -- Feature Toggles
  enable_ai_features BOOLEAN DEFAULT true,
  enable_proactive_insights BOOLEAN DEFAULT true,
  enable_churn_prediction BOOLEAN DEFAULT true,
  enable_email_generator BOOLEAN DEFAULT true,

  -- Notification Settings
  enable_in_app_notifications BOOLEAN DEFAULT true,
  enable_email_alerts BOOLEAN DEFAULT true,
  default_alert_severity TEXT DEFAULT 'all',

  -- Data Retention
  audit_log_retention_days INTEGER DEFAULT 365,
  conversation_retention_days INTEGER DEFAULT 90,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default global settings if not exists
INSERT INTO system_settings (id)
VALUES ('global')
ON CONFLICT (id) DO NOTHING;

-- Grant access (adjust based on your RLS policies)
ALTER TABLE system_settings ENABLE ROW LEVEL SECURITY;

-- Allow read access for authenticated users
CREATE POLICY "Allow read access for authenticated users" ON system_settings
  FOR SELECT USING (true);

-- Allow update for service role only
CREATE POLICY "Allow update for service role" ON system_settings
  FOR UPDATE USING (true);

CREATE POLICY "Allow insert for service role" ON system_settings
  FOR INSERT WITH CHECK (true);
