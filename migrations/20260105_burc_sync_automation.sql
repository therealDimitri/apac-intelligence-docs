-- Migration: BURC Sync Automation System
-- Created: 2026-01-05
-- Description: Creates tables for tracking automated BURC file sync operations

-- ============================================================================
-- BURC Sync Status Table
-- ============================================================================
-- Tracks each sync operation with detailed status and metrics

CREATE TABLE IF NOT EXISTS burc_sync_status (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sync_type VARCHAR(50) NOT NULL, -- 'auto', 'manual', 'scheduled'
  sync_scope VARCHAR(100) NOT NULL, -- 'all', 'monthly', 'historical', 'comprehensive', etc.
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  status VARCHAR(20) DEFAULT 'running' CHECK (status IN ('running', 'completed', 'failed', 'cancelled')),

  -- Metrics
  records_processed INTEGER DEFAULT 0,
  records_inserted INTEGER DEFAULT 0,
  records_updated INTEGER DEFAULT 0,
  records_failed INTEGER DEFAULT 0,

  -- File information
  source_files JSONB, -- Array of file paths that were processed
  file_checksums JSONB, -- MD5/SHA256 checksums of files

  -- Error tracking
  errors JSONB, -- Array of error objects with details
  warnings JSONB, -- Array of warning messages

  -- Performance metrics
  duration_seconds NUMERIC(10, 2),
  tables_affected TEXT[], -- Array of table names that were updated

  -- Audit trail
  triggered_by VARCHAR(100), -- 'file_watcher', 'api', 'cron', user email
  trigger_metadata JSONB, -- Additional context about what triggered the sync

  -- Validation results
  validation_passed BOOLEAN DEFAULT NULL,
  validation_errors JSONB,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_burc_sync_status_started_at ON burc_sync_status(started_at DESC);
CREATE INDEX idx_burc_sync_status_status ON burc_sync_status(status);
CREATE INDEX idx_burc_sync_status_sync_type ON burc_sync_status(sync_type);
CREATE INDEX idx_burc_sync_status_triggered_by ON burc_sync_status(triggered_by);

-- ============================================================================
-- BURC File Audit Table
-- ============================================================================
-- Tracks changes to BURC source files

CREATE TABLE IF NOT EXISTS burc_file_audit (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  file_path TEXT NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  fiscal_year INTEGER NOT NULL,

  -- File metadata
  file_size_bytes BIGINT,
  file_modified_at TIMESTAMPTZ,
  file_checksum VARCHAR(64), -- SHA256 hash

  -- Change detection
  change_type VARCHAR(20) CHECK (change_type IN ('created', 'modified', 'deleted', 'renamed')),
  previous_checksum VARCHAR(64),

  -- Sync relationship
  sync_status_id UUID REFERENCES burc_sync_status(id) ON DELETE SET NULL,
  sync_triggered BOOLEAN DEFAULT FALSE,

  detected_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_burc_file_audit_file_path ON burc_file_audit(file_path);
CREATE INDEX idx_burc_file_audit_fiscal_year ON burc_file_audit(fiscal_year);
CREATE INDEX idx_burc_file_audit_detected_at ON burc_file_audit(detected_at DESC);
CREATE INDEX idx_burc_file_audit_sync_status_id ON burc_file_audit(sync_status_id);

-- ============================================================================
-- BURC Sync Schedule Table
-- ============================================================================
-- Manages scheduled sync operations

CREATE TABLE IF NOT EXISTS burc_sync_schedule (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  schedule_name VARCHAR(100) NOT NULL UNIQUE,
  schedule_type VARCHAR(20) NOT NULL CHECK (schedule_type IN ('cron', 'interval', 'daily', 'weekly')),
  schedule_expression VARCHAR(100), -- Cron expression or interval in minutes

  sync_scope VARCHAR(100) NOT NULL, -- What to sync: 'all', 'monthly', etc.

  enabled BOOLEAN DEFAULT TRUE,
  last_run_at TIMESTAMPTZ,
  last_run_status VARCHAR(20),
  next_run_at TIMESTAMPTZ,

  -- Configuration
  config JSONB, -- Additional settings like notification preferences

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by VARCHAR(100)
);

-- ============================================================================
-- BURC Validation Rules Table
-- ============================================================================
-- Stores validation rules for data quality checks

CREATE TABLE IF NOT EXISTS burc_validation_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rule_name VARCHAR(100) NOT NULL UNIQUE,
  rule_type VARCHAR(50) NOT NULL, -- 'range', 'anomaly', 'required_field', 'consistency'
  table_name VARCHAR(100) NOT NULL,
  column_name VARCHAR(100),

  -- Rule definition
  rule_config JSONB NOT NULL, -- Configuration for the validation rule
  severity VARCHAR(20) DEFAULT 'warning' CHECK (severity IN ('info', 'warning', 'error', 'critical')),

  enabled BOOLEAN DEFAULT TRUE,
  description TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Default validation rules
INSERT INTO burc_validation_rules (rule_name, rule_type, table_name, column_name, rule_config, severity, description)
VALUES
  (
    'revenue_spike_detection',
    'anomaly',
    'burc_monthly_metrics',
    'value',
    '{"threshold_multiplier": 2.0, "lookback_months": 3, "metric_categories": ["Revenue", "License", "PS", "Maint"]}',
    'warning',
    'Detect when monthly revenue is more than 2x the average of previous 3 months'
  ),
  (
    'negative_revenue_check',
    'range',
    'burc_monthly_metrics',
    'value',
    '{"min": 0, "metric_categories": ["Revenue", "License", "PS", "Maint", "HW"]}',
    'error',
    'Revenue values should not be negative'
  ),
  (
    'required_fiscal_year',
    'required_field',
    'burc_monthly_metrics',
    'fiscal_year',
    '{"valid_range": [2020, 2030]}',
    'error',
    'Fiscal year must be present and within reasonable range'
  ),
  (
    'quarterly_total_consistency',
    'consistency',
    'burc_quarterly_data',
    'fy_total',
    '{"tolerance_percent": 1.0, "compare_to": "sum(q1_value, q2_value, q3_value, q4_value)"}',
    'warning',
    'Quarterly totals should match sum of quarters within 1% tolerance'
  ),
  (
    'headcount_reasonable_range',
    'range',
    'burc_headcount',
    'headcount',
    '{"min": 0, "max": 500}',
    'warning',
    'Headcount should be within reasonable range (0-500 per department/month)'
  );

-- ============================================================================
-- BURC Sync Notifications Table
-- ============================================================================
-- Tracks notifications sent about sync operations

CREATE TABLE IF NOT EXISTS burc_sync_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sync_status_id UUID REFERENCES burc_sync_status(id) ON DELETE CASCADE,

  notification_type VARCHAR(50) NOT NULL, -- 'slack', 'email', 'webhook', 'teams'
  notification_channel VARCHAR(255), -- Channel/recipient identifier

  subject VARCHAR(255),
  message TEXT,
  metadata JSONB,

  sent_at TIMESTAMPTZ,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'failed')),
  error_message TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_burc_sync_notifications_sync_status_id ON burc_sync_notifications(sync_status_id);
CREATE INDEX idx_burc_sync_notifications_status ON burc_sync_notifications(status);

-- ============================================================================
-- Helper Functions
-- ============================================================================

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_burc_sync_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers to auto-update updated_at
CREATE TRIGGER update_burc_sync_status_updated_at
  BEFORE UPDATE ON burc_sync_status
  FOR EACH ROW
  EXECUTE FUNCTION update_burc_sync_updated_at();

CREATE TRIGGER update_burc_sync_schedule_updated_at
  BEFORE UPDATE ON burc_sync_schedule
  FOR EACH ROW
  EXECUTE FUNCTION update_burc_sync_updated_at();

-- ============================================================================
-- Views for Monitoring
-- ============================================================================

-- Recent sync operations view
CREATE OR REPLACE VIEW burc_sync_recent AS
SELECT
  id,
  sync_type,
  sync_scope,
  started_at,
  completed_at,
  status,
  records_processed,
  duration_seconds,
  triggered_by,
  CASE
    WHEN status = 'running' AND started_at < NOW() - INTERVAL '30 minutes' THEN 'stuck'
    ELSE status
  END as computed_status,
  COALESCE(
    jsonb_array_length(errors),
    0
  ) as error_count,
  COALESCE(
    jsonb_array_length(warnings),
    0
  ) as warning_count
FROM burc_sync_status
ORDER BY started_at DESC
LIMIT 50;

-- Sync success rate view (last 30 days)
CREATE OR REPLACE VIEW burc_sync_stats AS
SELECT
  sync_type,
  sync_scope,
  COUNT(*) as total_syncs,
  COUNT(*) FILTER (WHERE status = 'completed') as successful_syncs,
  COUNT(*) FILTER (WHERE status = 'failed') as failed_syncs,
  ROUND(
    COUNT(*) FILTER (WHERE status = 'completed')::NUMERIC / NULLIF(COUNT(*), 0) * 100,
    2
  ) as success_rate_percent,
  AVG(duration_seconds) FILTER (WHERE status = 'completed') as avg_duration_seconds,
  SUM(records_processed) as total_records_processed
FROM burc_sync_status
WHERE started_at > NOW() - INTERVAL '30 days'
GROUP BY sync_type, sync_scope;

-- File change summary view
CREATE OR REPLACE VIEW burc_file_changes AS
SELECT
  file_name,
  fiscal_year,
  change_type,
  COUNT(*) as change_count,
  MAX(detected_at) as last_change_at,
  COUNT(*) FILTER (WHERE sync_triggered = TRUE) as syncs_triggered
FROM burc_file_audit
WHERE detected_at > NOW() - INTERVAL '30 days'
GROUP BY file_name, fiscal_year, change_type
ORDER BY last_change_at DESC;

-- ============================================================================
-- Comments
-- ============================================================================

COMMENT ON TABLE burc_sync_status IS 'Tracks all BURC sync operations with detailed metrics and status';
COMMENT ON TABLE burc_file_audit IS 'Audit log of BURC source file changes';
COMMENT ON TABLE burc_sync_schedule IS 'Configuration for scheduled BURC sync operations';
COMMENT ON TABLE burc_validation_rules IS 'Data quality validation rules for BURC imports';
COMMENT ON TABLE burc_sync_notifications IS 'Notifications sent about sync operations';

COMMENT ON VIEW burc_sync_recent IS 'Recent sync operations with computed status';
COMMENT ON VIEW burc_sync_stats IS 'Success rate and performance statistics for syncs (last 30 days)';
COMMENT ON VIEW burc_file_changes IS 'Summary of file changes detected (last 30 days)';

-- ============================================================================
-- Grants (adjust as needed for your RLS policies)
-- ============================================================================

-- Grant access to authenticated users
GRANT SELECT ON burc_sync_status TO authenticated;
GRANT SELECT ON burc_file_audit TO authenticated;
GRANT SELECT ON burc_sync_schedule TO authenticated;
GRANT SELECT ON burc_validation_rules TO authenticated;

GRANT SELECT ON burc_sync_recent TO authenticated;
GRANT SELECT ON burc_sync_stats TO authenticated;
GRANT SELECT ON burc_file_changes TO authenticated;

-- Service role needs full access for sync operations
-- (This is typically handled at the connection level with service_role key)
