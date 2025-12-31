-- Migration: Add Priority Matrix Activity Log table
-- Purpose: Persist activity history for Priority Matrix items
-- Date: 2025-12-31

-- Create the activity log table
CREATE TABLE IF NOT EXISTS priority_matrix_activity_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id TEXT NOT NULL,
  activity_type TEXT NOT NULL CHECK (activity_type IN ('created', 'updated', 'moved', 'completed', 'reassigned', 'commented', 'status_changed', 'department_changed')),
  user_name TEXT NOT NULL,
  user_email TEXT,
  description TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for fast lookups by item_id
CREATE INDEX IF NOT EXISTS idx_activity_log_item_id ON priority_matrix_activity_log(item_id);

-- Create index for time-based queries
CREATE INDEX IF NOT EXISTS idx_activity_log_created_at ON priority_matrix_activity_log(created_at DESC);

-- Enable RLS
ALTER TABLE priority_matrix_activity_log ENABLE ROW LEVEL SECURITY;

-- Policy: Allow authenticated users to read all activities
CREATE POLICY "Allow authenticated read access"
  ON priority_matrix_activity_log
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy: Allow authenticated users to insert activities
CREATE POLICY "Allow authenticated insert access"
  ON priority_matrix_activity_log
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Policy: Allow anon users to read (for dev/testing)
CREATE POLICY "Allow anon read access"
  ON priority_matrix_activity_log
  FOR SELECT
  TO anon
  USING (true);

-- Policy: Allow anon users to insert (for dev/testing)
CREATE POLICY "Allow anon insert access"
  ON priority_matrix_activity_log
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Comment on table
COMMENT ON TABLE priority_matrix_activity_log IS 'Stores activity history for Priority Matrix items';
