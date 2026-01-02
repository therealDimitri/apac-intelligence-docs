-- Migration: Add Action History, Tags, and Related Actions support
-- Purpose: Bring Actions feature parity with Priority Matrix (History, Tags, Related Actions)
-- Date: 2026-01-01
--
-- Features added:
-- 1. action_activity_log table - tracks all changes to actions (history)
-- 2. tags column on actions table - array of tags for categorisation
-- 3. Bidirectional sync support via activity logging

-- ============================================================================
-- 1. ACTION ACTIVITY LOG TABLE (History Tracking)
-- ============================================================================
-- Similar to priority_matrix_activity_log but for the Actions system

CREATE TABLE IF NOT EXISTS action_activity_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  action_id TEXT NOT NULL,  -- References Action_ID from actions table
  activity_type TEXT NOT NULL CHECK (activity_type IN (
    'created',
    'updated',
    'status_changed',
    'priority_changed',
    'owner_changed',
    'due_date_changed',
    'department_changed',
    'client_changed',
    'tags_changed',
    'commented',
    'completed',
    'cancelled',
    'reopened',
    'linked',
    'unlinked'
  )),
  user_name TEXT NOT NULL,
  user_email TEXT,
  description TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  -- Metadata examples:
  -- status_changed: { "from": "open", "to": "in-progress" }
  -- priority_changed: { "from": "medium", "to": "high" }
  -- owner_changed: { "old_owners": ["John"], "new_owners": ["Jane", "Bob"] }
  -- tags_changed: { "added": ["urgent"], "removed": ["low-priority"] }
  -- linked: { "related_action_id": "ACT-123", "relation_type": "blocks" }
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for fast lookups
CREATE INDEX IF NOT EXISTS idx_action_activity_log_action_id ON action_activity_log(action_id);
CREATE INDEX IF NOT EXISTS idx_action_activity_log_created_at ON action_activity_log(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_action_activity_log_type ON action_activity_log(activity_type);

-- Enable RLS
ALTER TABLE action_activity_log ENABLE ROW LEVEL SECURITY;

-- Policy: Allow authenticated users to read all activities
CREATE POLICY "action_activity_log_select_authenticated"
  ON action_activity_log
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy: Allow authenticated users to insert activities
CREATE POLICY "action_activity_log_insert_authenticated"
  ON action_activity_log
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Policy: Allow anon users to read (for dev/testing)
CREATE POLICY "action_activity_log_select_anon"
  ON action_activity_log
  FOR SELECT
  TO anon
  USING (true);

-- Policy: Allow anon users to insert (for dev/testing)
CREATE POLICY "action_activity_log_insert_anon"
  ON action_activity_log
  FOR INSERT
  TO anon
  WITH CHECK (true);

COMMENT ON TABLE action_activity_log IS 'Stores activity history for Actions - tracks all changes for audit trail and History tab';

-- ============================================================================
-- 2. ADD TAGS COLUMN TO ACTIONS TABLE
-- ============================================================================
-- Tags are stored as a TEXT[] array for flexible categorisation

DO $$
BEGIN
  -- Add tags column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'actions' AND column_name = 'tags'
  ) THEN
    ALTER TABLE actions ADD COLUMN tags TEXT[] DEFAULT '{}';
    RAISE NOTICE 'Added tags column to actions table';
  ELSE
    RAISE NOTICE 'tags column already exists on actions table';
  END IF;
END $$;

-- Create index for tag searches (GIN index for array containment)
CREATE INDEX IF NOT EXISTS idx_actions_tags ON actions USING GIN (tags);

COMMENT ON COLUMN actions.tags IS 'Array of tags for categorisation (e.g., ["urgent", "client-facing", "renewal"])';

-- ============================================================================
-- 3. ACTION RELATIONS TABLE (Explicit Related Actions)
-- ============================================================================
-- While Priority Matrix uses computed relations (same client/owner/tags),
-- Actions also supports explicit linking for dependencies

CREATE TABLE IF NOT EXISTS action_relations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_action_id TEXT NOT NULL,  -- The action that has the relation
  target_action_id TEXT NOT NULL,  -- The related action
  relation_type TEXT NOT NULL CHECK (relation_type IN (
    'related_to',   -- General relation
    'blocks',       -- Source blocks target
    'blocked_by',   -- Source is blocked by target
    'duplicates',   -- Source duplicates target
    'parent_of',    -- Source is parent of target
    'child_of'      -- Source is child of target
  )),
  created_by TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- Prevent duplicate relations
  UNIQUE(source_action_id, target_action_id, relation_type)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_action_relations_source ON action_relations(source_action_id);
CREATE INDEX IF NOT EXISTS idx_action_relations_target ON action_relations(target_action_id);

-- Enable RLS
ALTER TABLE action_relations ENABLE ROW LEVEL SECURITY;

-- Policies for action_relations
CREATE POLICY "action_relations_select_authenticated"
  ON action_relations FOR SELECT TO authenticated USING (true);

CREATE POLICY "action_relations_insert_authenticated"
  ON action_relations FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "action_relations_delete_authenticated"
  ON action_relations FOR DELETE TO authenticated USING (true);

CREATE POLICY "action_relations_select_anon"
  ON action_relations FOR SELECT TO anon USING (true);

CREATE POLICY "action_relations_insert_anon"
  ON action_relations FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "action_relations_delete_anon"
  ON action_relations FOR DELETE TO anon USING (true);

COMMENT ON TABLE action_relations IS 'Explicit bidirectional relations between actions (blocks, duplicates, parent/child)';

-- ============================================================================
-- 4. VERIFICATION
-- ============================================================================

DO $$
BEGIN
  -- Verify action_activity_log was created
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'action_activity_log'
  ) THEN
    RAISE EXCEPTION 'Migration failed: action_activity_log table not created';
  END IF;

  -- Verify tags column exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'actions' AND column_name = 'tags'
  ) THEN
    RAISE EXCEPTION 'Migration failed: tags column not added to actions';
  END IF;

  -- Verify action_relations was created
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'action_relations'
  ) THEN
    RAISE EXCEPTION 'Migration failed: action_relations table not created';
  END IF;

  RAISE NOTICE 'Migration successful: Action History, Tags, and Relations support added';
END $$;
