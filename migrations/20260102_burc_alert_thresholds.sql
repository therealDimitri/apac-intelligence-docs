-- ============================================================
-- BURC Alert Thresholds Table
-- Stores configurable thresholds for BURC KPI alerts
-- ============================================================

CREATE TABLE IF NOT EXISTS burc_alert_thresholds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  metric_name VARCHAR(100) NOT NULL UNIQUE,
  metric_category VARCHAR(100) NOT NULL,
  warning_threshold NUMERIC,
  critical_threshold NUMERIC,
  comparison_operator VARCHAR(10) NOT NULL DEFAULT 'lt' CHECK (comparison_operator IN ('gt', 'lt', 'gte', 'lte', 'eq')),
  enabled BOOLEAN NOT NULL DEFAULT true,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Insert default thresholds
INSERT INTO burc_alert_thresholds (metric_name, metric_category, warning_threshold, critical_threshold, comparison_operator, enabled, description)
VALUES
  ('nrr_percent', 'Revenue Retention', 95, 90, 'lt', true, 'Net Revenue Retention percentage'),
  ('grr_percent', 'Revenue Retention', 90, 85, 'lt', true, 'Gross Revenue Retention percentage'),
  ('rule_of_40', 'Growth Efficiency', 35, 30, 'lt', true, 'Rule of 40 score (Growth + EBITA Margin)'),
  ('pipeline_coverage', 'Pipeline', 2.5, 2.0, 'lt', true, 'Pipeline coverage ratio (Pipeline / Target)'),
  ('attrition_risk', 'Attrition', 1000000, 2000000, 'gt', true, 'Total revenue at risk from attrition'),
  ('ebita_margin', 'Profitability', 12, 10, 'lt', true, 'EBITA margin percentage')
ON CONFLICT (metric_name) DO NOTHING;

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON burc_alert_thresholds TO authenticated;

-- ============================================================
-- BURC Active Alerts Table (if not exists)
-- Stores currently active alerts based on threshold breaches
-- ============================================================

CREATE TABLE IF NOT EXISTS burc_active_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  metric_name VARCHAR(100) NOT NULL,
  metric_category VARCHAR(100) NOT NULL,
  severity VARCHAR(20) NOT NULL CHECK (severity IN ('critical', 'warning', 'info')),
  current_value NUMERIC,
  threshold_value NUMERIC,
  message TEXT NOT NULL,
  priority_order INTEGER NOT NULL DEFAULT 10,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  resolved_at TIMESTAMPTZ
);

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON burc_active_alerts TO authenticated;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_burc_active_alerts_severity ON burc_active_alerts(severity);
CREATE INDEX IF NOT EXISTS idx_burc_active_alerts_metric ON burc_active_alerts(metric_name);
