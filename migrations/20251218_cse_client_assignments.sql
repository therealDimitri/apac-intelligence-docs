-- Migration: Create CSE Client Assignments Table
-- Date: 2025-12-18
-- Purpose: Store CSE-to-client mappings for Invoice Tracker integration

-- Create the table
CREATE TABLE IF NOT EXISTS cse_client_assignments (
  id SERIAL PRIMARY KEY,
  cse_name TEXT NOT NULL,
  client_name TEXT NOT NULL,
  client_name_normalized TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_name_normalized)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_cse_assignments_cse ON cse_client_assignments(cse_name);
CREATE INDEX IF NOT EXISTS idx_cse_assignments_client ON cse_client_assignments(client_name_normalized);
CREATE INDEX IF NOT EXISTS idx_cse_assignments_active ON cse_client_assignments(is_active) WHERE is_active = true;

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION update_cse_assignments_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_cse_assignments_updated_at ON cse_client_assignments;
CREATE TRIGGER trigger_cse_assignments_updated_at
  BEFORE UPDATE ON cse_client_assignments
  FOR EACH ROW
  EXECUTE FUNCTION update_cse_assignments_updated_at();

-- Enable RLS
ALTER TABLE cse_client_assignments ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Service role has full access to cse_client_assignments"
  ON cse_client_assignments
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can read cse_client_assignments"
  ON cse_client_assignments
  FOR SELECT
  TO authenticated
  USING (true);

-- Populate from existing aging_accounts data
INSERT INTO cse_client_assignments (cse_name, client_name, client_name_normalized, is_active)
SELECT DISTINCT
  cse_name,
  client_name,
  client_name_normalized,
  true
FROM aging_accounts
ON CONFLICT (client_name_normalized) DO UPDATE SET
  cse_name = EXCLUDED.cse_name,
  updated_at = NOW();

-- Add comment
COMMENT ON TABLE cse_client_assignments IS 'Maps clients to their assigned CSE for Invoice Tracker integration';
