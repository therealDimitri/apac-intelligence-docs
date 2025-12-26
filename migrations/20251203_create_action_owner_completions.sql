-- Migration: Create action_owner_completions table
-- Date: 2025-12-03
-- Purpose: Enable individual status tracking for multi-owner actions

-- Create table for individual owner completion tracking
CREATE TABLE IF NOT EXISTS public.action_owner_completions (
  action_id TEXT NOT NULL,
  owner_name TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'open',
  completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (action_id, owner_name)
);

-- Add index for faster queries by action
CREATE INDEX IF NOT EXISTS idx_action_owner_completions_action_id
ON public.action_owner_completions(action_id);

-- Add index for status queries
CREATE INDEX IF NOT EXISTS idx_action_owner_completions_status
ON public.action_owner_completions(status);

-- Enable RLS
ALTER TABLE public.action_owner_completions ENABLE ROW LEVEL SECURITY;

-- Drop existing policy if exists
DROP POLICY IF EXISTS "Allow all operations" ON public.action_owner_completions;

-- Create policy to allow all operations
-- TODO: Adjust this policy based on your authentication requirements
CREATE POLICY "Allow all operations"
ON public.action_owner_completions
FOR ALL
USING (true)
WITH CHECK (true);

-- Add table comment
COMMENT ON TABLE public.action_owner_completions IS
'Tracks individual completion status for each owner in multi-owner actions';

-- Add column comments
COMMENT ON COLUMN public.action_owner_completions.action_id IS
'Reference to Action_ID in the actions table';

COMMENT ON COLUMN public.action_owner_completions.owner_name IS
'Name of the owner from the actions.Owners field';

COMMENT ON COLUMN public.action_owner_completions.status IS
'Current status: open, in-progress, completed, or cancelled';

COMMENT ON COLUMN public.action_owner_completions.completed IS
'Boolean flag for quick filtering of completed items';

COMMENT ON COLUMN public.action_owner_completions.completed_at IS
'Timestamp when the owner marked their portion as completed';
