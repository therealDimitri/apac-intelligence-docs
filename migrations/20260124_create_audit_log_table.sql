-- Migration: Create audit_log table for Audit Log page
-- Date: 2026-01-24
-- Purpose: Track system activity history, data changes, and user actions

-- Create audit_log table
CREATE TABLE IF NOT EXISTS audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  user_email TEXT,
  user_name TEXT,
  action TEXT NOT NULL CHECK (action IN (
    'create', 'update', 'delete',
    'login', 'logout',
    'sync_started', 'sync_completed', 'sync_failed',
    'preference_changed', 'settings_changed',
    'export', 'import',
    'view', 'search'
  )),
  entity_type TEXT CHECK (entity_type IN (
    'meeting', 'action', 'client', 'user', 'system',
    'nps_response', 'health_score', 'segmentation',
    'alert', 'notification', 'preference', 'knowledge'
  )),
  entity_id TEXT,
  entity_name TEXT,
  changes JSONB,  -- { field: { old: x, new: y } }
  metadata JSONB DEFAULT '{}'::jsonb,
  ip_address TEXT,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for efficient querying
CREATE INDEX idx_audit_log_timestamp ON audit_log(timestamp DESC);
CREATE INDEX idx_audit_log_user ON audit_log(user_email);
CREATE INDEX idx_audit_log_action ON audit_log(action);
CREATE INDEX idx_audit_log_entity_type ON audit_log(entity_type);
CREATE INDEX idx_audit_log_entity_id ON audit_log(entity_id);
CREATE INDEX idx_audit_log_user_timestamp ON audit_log(user_email, timestamp DESC);
CREATE INDEX idx_audit_log_action_timestamp ON audit_log(action, timestamp DESC);

-- Enable RLS
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read audit log
CREATE POLICY "Allow authenticated users to read audit_log"
  ON audit_log FOR SELECT
  TO authenticated
  USING (true);

-- Allow service role full access
CREATE POLICY "Allow service role to manage audit_log"
  ON audit_log FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Allow anon for API routes
CREATE POLICY "Allow anon to read audit_log"
  ON audit_log FOR SELECT
  TO anon
  USING (true);

CREATE POLICY "Allow anon to insert audit_log"
  ON audit_log FOR INSERT
  TO anon
  WITH CHECK (true);

-- Comment on table
COMMENT ON TABLE audit_log IS 'Comprehensive audit trail for all system activities and data changes';
COMMENT ON COLUMN audit_log.action IS 'Type of action performed';
COMMENT ON COLUMN audit_log.entity_type IS 'Type of entity affected by the action';
COMMENT ON COLUMN audit_log.changes IS 'JSON object containing field-level changes with old and new values';

-- Create function to log audit events
CREATE OR REPLACE FUNCTION log_audit_event(
  p_user_email TEXT,
  p_user_name TEXT,
  p_action TEXT,
  p_entity_type TEXT,
  p_entity_id TEXT DEFAULT NULL,
  p_entity_name TEXT DEFAULT NULL,
  p_changes JSONB DEFAULT NULL,
  p_metadata JSONB DEFAULT '{}'::jsonb
) RETURNS UUID AS $$
DECLARE
  v_id UUID;
BEGIN
  INSERT INTO audit_log (
    user_email, user_name, action, entity_type,
    entity_id, entity_name, changes, metadata
  ) VALUES (
    p_user_email, p_user_name, p_action, p_entity_type,
    p_entity_id, p_entity_name, p_changes, p_metadata
  ) RETURNING id INTO v_id;

  RETURN v_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
