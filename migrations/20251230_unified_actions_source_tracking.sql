-- ============================================================================
-- Unified Actions: Source Tracking Columns
-- ============================================================================
-- Date: 30 December 2025
-- Purpose: Add source tracking columns to actions table for unified action system
-- Related: docs/design/UNIFIED-ACTIONS-SYSTEM-DESIGN.md
-- ============================================================================

-- Add source column (where the action originated)
-- Values: manual, meeting, insight_ai, insight_ml, chasen, outlook, import
ALTER TABLE actions
ADD COLUMN IF NOT EXISTS source TEXT DEFAULT 'manual';

-- Add source_metadata as JSONB for flexible source-specific data
ALTER TABLE actions
ADD COLUMN IF NOT EXISTS source_metadata JSONB DEFAULT NULL;

-- Add comments explaining the columns
COMMENT ON COLUMN actions.source IS 'Origin of the action: manual, meeting, insight_ai, insight_ml, chasen, outlook, import';
COMMENT ON COLUMN actions.source_metadata IS 'Source-specific metadata: insightId, meetingId, confidence scores, original text, etc.';

-- Create index on source for filtering
CREATE INDEX IF NOT EXISTS idx_actions_source ON actions(source);

-- Create index on source_metadata for JSONB queries
CREATE INDEX IF NOT EXISTS idx_actions_source_metadata ON actions USING GIN(source_metadata);

-- ============================================================================
-- Backfill existing actions with source based on existing data
-- ============================================================================

-- Actions with meeting_id are from meeting extractions
UPDATE actions
SET source = 'meeting',
    source_metadata = jsonb_build_object(
      'source', 'meeting',
      'createdAt', created_at,
      'meetingId', meeting_id,
      'meetingTitle', "Content_Topic"
    )
WHERE meeting_id IS NOT NULL
  AND source = 'manual';

-- Actions with ai_context are from ChaSen recommendations
UPDATE actions
SET source = 'chasen',
    source_metadata = jsonb_build_object(
      'source', 'chasen',
      'createdAt', ai_context_generated_at,
      'meetingTitle', ai_context_meeting_title
    )
WHERE ai_context IS NOT NULL
  AND meeting_id IS NULL
  AND source = 'manual';

-- Actions with outlook_task_id are from Outlook sync
UPDATE actions
SET source = 'outlook',
    source_metadata = jsonb_build_object(
      'source', 'outlook',
      'createdAt', created_at,
      'outlookTaskId', outlook_task_id,
      'outlookLastSyncedAt', last_synced_at
    )
WHERE outlook_task_id IS NOT NULL
  AND source = 'manual';

-- ============================================================================
-- Add assigned_by column for tracking who created/assigned the action
-- ============================================================================

ALTER TABLE actions
ADD COLUMN IF NOT EXISTS assigned_by TEXT DEFAULT NULL;

COMMENT ON COLUMN actions.assigned_by IS 'Email or name of the user who created or assigned this action';

-- ============================================================================
-- Add parent_action_id for sub-actions support
-- ============================================================================

ALTER TABLE actions
ADD COLUMN IF NOT EXISTS parent_action_id INTEGER DEFAULT NULL;

-- Add foreign key constraint (self-referential)
ALTER TABLE actions
ADD CONSTRAINT fk_actions_parent
FOREIGN KEY (parent_action_id)
REFERENCES actions(id)
ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_actions_parent ON actions(parent_action_id);

COMMENT ON COLUMN actions.parent_action_id IS 'Parent action ID for sub-actions hierarchy';

-- ============================================================================
-- Verify migration
-- ============================================================================

DO $$
BEGIN
  -- Check source column exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'actions' AND column_name = 'source'
  ) THEN
    RAISE EXCEPTION 'Migration failed: source column not created';
  END IF;

  -- Check source_metadata column exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'actions' AND column_name = 'source_metadata'
  ) THEN
    RAISE EXCEPTION 'Migration failed: source_metadata column not created';
  END IF;

  RAISE NOTICE 'Migration successful: Unified actions source tracking columns added';
END $$;
