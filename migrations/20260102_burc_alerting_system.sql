-- ============================================================
-- BURC Dynamic Alerting System
-- Phase 3: Configurable thresholds and automated alerts
-- ============================================================

-- ============================================================
-- 1. ALERT CONFIGURATION TABLE
-- Stores customisable threshold values for different metrics
-- ============================================================
CREATE TABLE IF NOT EXISTS burc_alert_config (
  id SERIAL PRIMARY KEY,
  metric_name TEXT NOT NULL UNIQUE,
  metric_category TEXT NOT NULL,
  description TEXT,
  -- Threshold values
  warning_threshold DECIMAL(10,2),
  critical_threshold DECIMAL(10,2),
  -- Direction: 'above' means alert when value goes above threshold
  -- 'below' means alert when value goes below threshold
  threshold_direction TEXT DEFAULT 'below' CHECK (threshold_direction IN ('above', 'below')),
  -- Alert settings
  is_enabled BOOLEAN DEFAULT true,
  notification_email TEXT[],
  notification_slack_channel TEXT,
  -- Metadata
  created_by TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 2. ACTIVE ALERTS TABLE
-- Stores currently triggered alerts
-- ============================================================
CREATE TABLE IF NOT EXISTS burc_alerts (
  id SERIAL PRIMARY KEY,
  alert_config_id INTEGER REFERENCES burc_alert_config(id),
  metric_name TEXT NOT NULL,
  metric_category TEXT NOT NULL,
  current_value DECIMAL(14,2),
  threshold_value DECIMAL(14,2),
  severity TEXT NOT NULL CHECK (severity IN ('warning', 'critical')),
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'acknowledged', 'resolved')),
  message TEXT,
  details JSONB,
  triggered_at TIMESTAMPTZ DEFAULT NOW(),
  acknowledged_at TIMESTAMPTZ,
  acknowledged_by TEXT,
  resolved_at TIMESTAMPTZ,
  resolved_by TEXT
);

-- ============================================================
-- 3. ALERT HISTORY TABLE
-- Audit trail of all alerts
-- ============================================================
CREATE TABLE IF NOT EXISTS burc_alert_history (
  id SERIAL PRIMARY KEY,
  alert_id INTEGER,
  metric_name TEXT NOT NULL,
  metric_category TEXT NOT NULL,
  current_value DECIMAL(14,2),
  threshold_value DECIMAL(14,2),
  severity TEXT NOT NULL,
  action TEXT NOT NULL,
  actor TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 4. DEFAULT ALERT CONFIGURATIONS
-- Pre-populated thresholds based on industry standards
-- ============================================================
INSERT INTO burc_alert_config (metric_name, metric_category, description, warning_threshold, critical_threshold, threshold_direction)
VALUES
  -- Revenue Retention
  ('nrr_percent', 'retention', 'Net Revenue Retention percentage', 100, 90, 'below'),
  ('grr_percent', 'retention', 'Gross Revenue Retention percentage', 92, 85, 'below'),

  -- Rule of 40
  ('rule_of_40_score', 'growth', 'Rule of 40 (Growth + Margin)', 35, 25, 'below'),
  ('revenue_growth_percent', 'growth', 'Year-over-year revenue growth', 5, 0, 'below'),

  -- Attrition Risk
  ('total_at_risk', 'attrition', 'Total revenue at risk of churn', 1000000, 2500000, 'above'),
  ('attrition_risk_count', 'attrition', 'Number of at-risk accounts', 5, 10, 'above'),

  -- Contract Renewals
  ('contracts_expiring_30_days', 'contracts', 'Contracts expiring in 30 days', 2, 5, 'above'),
  ('contracts_expiring_90_days', 'contracts', 'Contracts expiring in 90 days', 5, 10, 'above'),

  -- Pipeline
  ('weighted_pipeline_coverage', 'pipeline', 'Weighted pipeline vs quota coverage ratio', 2.5, 1.5, 'below'),
  ('pipeline_velocity', 'pipeline', 'Average days to close', 90, 120, 'above'),

  -- ARR Performance
  ('arr_achievement_percent', 'arr', 'ARR target achievement percentage', 80, 60, 'below'),
  ('arr_variance', 'arr', 'ARR variance from target (negative = behind)', -50000, -100000, 'below')
ON CONFLICT (metric_name) DO NOTHING;

-- ============================================================
-- 5. ALERT EVALUATION VIEW
-- Calculates current alert status for all metrics
-- ============================================================
CREATE OR REPLACE VIEW burc_alert_evaluation AS
WITH current_metrics AS (
  SELECT
    'nrr_percent' as metric_name,
    'retention' as metric_category,
    COALESCE(nrr_percent, 0) as current_value
  FROM burc_executive_summary

  UNION ALL

  SELECT
    'grr_percent',
    'retention',
    COALESCE(grr_percent, 0)
  FROM burc_executive_summary

  UNION ALL

  SELECT
    'rule_of_40_score',
    'growth',
    COALESCE(rule_of_40_score, 0)
  FROM burc_executive_summary

  UNION ALL

  SELECT
    'total_at_risk',
    'attrition',
    COALESCE(total_at_risk, 0)
  FROM burc_executive_summary

  UNION ALL

  SELECT
    'attrition_risk_count',
    'attrition',
    COALESCE(attrition_risk_count, 0)
  FROM burc_executive_summary

  UNION ALL

  SELECT
    'weighted_pipeline_coverage',
    'pipeline',
    CASE
      WHEN COALESCE((SELECT SUM(arr_usd) FROM burc_arr_tracking WHERE year = 2026), 0) > 0
      THEN COALESCE(weighted_pipeline, 0) / (SELECT SUM(arr_usd) FROM burc_arr_tracking WHERE year = 2026)
      ELSE 0
    END
  FROM burc_executive_summary

  UNION ALL

  SELECT
    'contracts_expiring_30_days',
    'contracts',
    (SELECT COUNT(*) FROM burc_contracts
     WHERE renewal_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days')

  UNION ALL

  SELECT
    'contracts_expiring_90_days',
    'contracts',
    (SELECT COUNT(*) FROM burc_contracts
     WHERE renewal_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '90 days')
)
SELECT
  cm.metric_name,
  cm.metric_category,
  cm.current_value,
  ac.warning_threshold,
  ac.critical_threshold,
  ac.threshold_direction,
  ac.is_enabled,
  ac.description,
  -- Determine severity
  CASE
    WHEN ac.threshold_direction = 'below' AND cm.current_value <= ac.critical_threshold THEN 'critical'
    WHEN ac.threshold_direction = 'below' AND cm.current_value <= ac.warning_threshold THEN 'warning'
    WHEN ac.threshold_direction = 'above' AND cm.current_value >= ac.critical_threshold THEN 'critical'
    WHEN ac.threshold_direction = 'above' AND cm.current_value >= ac.warning_threshold THEN 'warning'
    ELSE 'ok'
  END as severity,
  -- Generate message
  CASE
    WHEN ac.threshold_direction = 'below' AND cm.current_value <= ac.critical_threshold
      THEN ac.description || ' is critically low at ' || cm.current_value || ' (threshold: ' || ac.critical_threshold || ')'
    WHEN ac.threshold_direction = 'below' AND cm.current_value <= ac.warning_threshold
      THEN ac.description || ' is below target at ' || cm.current_value || ' (threshold: ' || ac.warning_threshold || ')'
    WHEN ac.threshold_direction = 'above' AND cm.current_value >= ac.critical_threshold
      THEN ac.description || ' is critically high at ' || cm.current_value || ' (threshold: ' || ac.critical_threshold || ')'
    WHEN ac.threshold_direction = 'above' AND cm.current_value >= ac.warning_threshold
      THEN ac.description || ' is above target at ' || cm.current_value || ' (threshold: ' || ac.warning_threshold || ')'
    ELSE ac.description || ' is within acceptable range at ' || cm.current_value
  END as message
FROM current_metrics cm
JOIN burc_alert_config ac ON cm.metric_name = ac.metric_name
WHERE ac.is_enabled = true;

-- ============================================================
-- 6. ACTIVE ALERTS SUMMARY VIEW
-- Quick view of all triggered alerts
-- ============================================================
CREATE OR REPLACE VIEW burc_active_alerts AS
SELECT
  metric_name,
  metric_category,
  current_value,
  warning_threshold,
  critical_threshold,
  severity,
  message,
  CASE
    WHEN severity = 'critical' THEN 1
    WHEN severity = 'warning' THEN 2
    ELSE 3
  END as priority_order
FROM burc_alert_evaluation
WHERE severity IN ('warning', 'critical')
ORDER BY priority_order, metric_category;

-- ============================================================
-- 7. GRANT PERMISSIONS
-- ============================================================
GRANT SELECT ON burc_alert_config TO authenticated;
GRANT SELECT ON burc_alerts TO authenticated;
GRANT SELECT ON burc_alert_history TO authenticated;
GRANT SELECT ON burc_alert_evaluation TO authenticated;
GRANT SELECT ON burc_active_alerts TO authenticated;

GRANT INSERT, UPDATE ON burc_alert_config TO authenticated;
GRANT INSERT, UPDATE ON burc_alerts TO authenticated;
GRANT INSERT ON burc_alert_history TO authenticated;
