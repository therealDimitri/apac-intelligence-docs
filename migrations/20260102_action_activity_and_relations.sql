-- Migration: Action Activity Log and Relations Tables
-- Date: 2026-01-02
-- Description: Creates tables for tracking action history and relationships

-- ============================================================================
-- 1. Create action_activity_log table
-- ============================================================================
-- This table stores the activity history for each action

CREATE TABLE IF NOT EXISTS action_activity_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  action_id text NOT NULL,
  activity_type text NOT NULL CHECK (activity_type IN (
    'created', 'updated', 'status_changed', 'priority_changed',
    'owner_changed', 'due_date_changed', 'department_changed',
    'client_changed', 'tags_changed', 'commented', 'completed',
    'cancelled', 'reopened', 'linked', 'unlinked'
  )),
  user_name text NOT NULL,
  user_email text,
  description text NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now()
);

-- Index for fast lookups by action_id
CREATE INDEX IF NOT EXISTS idx_action_activity_log_action_id
  ON action_activity_log(action_id);

-- Index for ordering by date
CREATE INDEX IF NOT EXISTS idx_action_activity_log_created_at
  ON action_activity_log(created_at DESC);

-- ============================================================================
-- 2. Create action_relations table
-- ============================================================================
-- This table stores explicit relationships between actions

CREATE TABLE IF NOT EXISTS action_relations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_action_id text NOT NULL,
  target_action_id text NOT NULL,
  relation_type text NOT NULL CHECK (relation_type IN (
    'related_to', 'blocks', 'blocked_by', 'duplicates', 'parent_of', 'child_of'
  )),
  created_by text NOT NULL,
  created_at timestamptz DEFAULT now(),
  -- Ensure no duplicate relations between the same actions with the same type
  UNIQUE(source_action_id, target_action_id, relation_type)
);

-- Index for finding relations by source action
CREATE INDEX IF NOT EXISTS idx_action_relations_source
  ON action_relations(source_action_id);

-- Index for finding relations by target action
CREATE INDEX IF NOT EXISTS idx_action_relations_target
  ON action_relations(target_action_id);

-- ============================================================================
-- 3. Enable RLS and add policies
-- ============================================================================

-- Enable RLS on action_activity_log
ALTER TABLE action_activity_log ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read activity logs
CREATE POLICY "Allow authenticated read action_activity_log"
  ON action_activity_log FOR SELECT
  TO authenticated
  USING (true);

-- Allow service role full access
CREATE POLICY "Allow service role full access action_activity_log"
  ON action_activity_log FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Enable RLS on action_relations
ALTER TABLE action_relations ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read relations
CREATE POLICY "Allow authenticated read action_relations"
  ON action_relations FOR SELECT
  TO authenticated
  USING (true);

-- Allow service role full access
CREATE POLICY "Allow service role full access action_relations"
  ON action_relations FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ============================================================================
-- 4. Grant permissions
-- ============================================================================

GRANT SELECT ON action_activity_log TO authenticated;
GRANT ALL ON action_activity_log TO service_role;

GRANT SELECT ON action_relations TO authenticated;
GRANT ALL ON action_relations TO service_role;
