-- Migration: Create sync_history table for Data Sync Status page
-- Date: 2026-01-24
-- Purpose: Track data synchronisation jobs, view sync history, and trigger manual refreshes

-- Create sync_history table
CREATE TABLE IF NOT EXISTS sync_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source TEXT NOT NULL,  -- 'outlook_meetings', 'outlook_actions', 'aged_accounts', 'health_snapshots', 'nps_responses', 'burc'
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  status TEXT DEFAULT 'running' CHECK (status IN ('running', 'success', 'partial', 'failed')),
  records_processed INTEGER DEFAULT 0,
  records_created INTEGER DEFAULT 0,
  records_updated INTEGER DEFAULT 0,
  records_failed INTEGER DEFAULT 0,
  error_message TEXT,
  triggered_by TEXT NOT NULL CHECK (triggered_by IN ('cron', 'manual', 'api', 'system')),
  triggered_by_user TEXT,  -- Email of user who triggered manual sync
  metadata JSONB DEFAULT '{}'::jsonb,
  duration_ms INTEGER,  -- Calculated duration in milliseconds
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for efficient querying
CREATE INDEX idx_sync_history_source ON sync_history(source);
CREATE INDEX idx_sync_history_status ON sync_history(status);
CREATE INDEX idx_sync_history_started_at ON sync_history(started_at DESC);
CREATE INDEX idx_sync_history_source_started ON sync_history(source, started_at DESC);

-- Enable RLS
ALTER TABLE sync_history ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read sync history
CREATE POLICY "Allow authenticated users to read sync_history"
  ON sync_history FOR SELECT
  TO authenticated
  USING (true);

-- Allow service role to insert/update sync history
CREATE POLICY "Allow service role to manage sync_history"
  ON sync_history FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Also allow anon for API routes
CREATE POLICY "Allow anon to read sync_history"
  ON sync_history FOR SELECT
  TO anon
  USING (true);

CREATE POLICY "Allow anon to insert sync_history"
  ON sync_history FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Allow anon to update sync_history"
  ON sync_history FOR UPDATE
  TO anon
  USING (true)
  WITH CHECK (true);

-- Comment on table
COMMENT ON TABLE sync_history IS 'Tracks all data synchronisation operations for audit and monitoring';
COMMENT ON COLUMN sync_history.source IS 'Data source identifier: outlook_meetings, outlook_actions, aged_accounts, health_snapshots, nps_responses, burc';
COMMENT ON COLUMN sync_history.triggered_by IS 'How the sync was initiated: cron (scheduled), manual (user-triggered), api (external), system (automatic)';
