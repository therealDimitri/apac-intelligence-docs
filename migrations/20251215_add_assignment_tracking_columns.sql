-- Migration: Add assignment tracking columns to actions table
-- Date: 2025-12-15
-- Purpose: Track when actions were assigned and by whom from Priority Matrix

-- Add assigned_at column (timestamp of assignment)
ALTER TABLE actions
ADD COLUMN IF NOT EXISTS assigned_at timestamptz;

-- Add assigned_by column (name of person who assigned)
ALTER TABLE actions
ADD COLUMN IF NOT EXISTS assigned_by text;

-- Add assigned_by_email column (email of person who assigned)
ALTER TABLE actions
ADD COLUMN IF NOT EXISTS assigned_by_email text;

-- Add source column to track where the action came from
ALTER TABLE actions
ADD COLUMN IF NOT EXISTS source text DEFAULT 'manual';

-- Comment on columns
COMMENT ON COLUMN actions.assigned_at IS 'Timestamp when the action was assigned from Priority Matrix';
COMMENT ON COLUMN actions.assigned_by IS 'Name of the person who assigned this action';
COMMENT ON COLUMN actions.assigned_by_email IS 'Email of the person who assigned this action';
COMMENT ON COLUMN actions.source IS 'Source of the action: manual, priority_matrix, meeting, etc.';

-- Create index for querying by assignment date
CREATE INDEX IF NOT EXISTS idx_actions_assigned_at ON actions(assigned_at);

-- Create index for querying by source
CREATE INDEX IF NOT EXISTS idx_actions_source ON actions(source);
