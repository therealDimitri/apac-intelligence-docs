-- ============================================================================
-- Migration: Add source tracking columns to actions table
-- Date: 30 December 2025
-- Purpose: Enable provenance tracking for unified actions system
-- ============================================================================

-- Add source column to track where action originated
ALTER TABLE actions
ADD COLUMN IF NOT EXISTS source text DEFAULT 'manual';

-- Add source_metadata column for source-specific context
ALTER TABLE actions
ADD COLUMN IF NOT EXISTS source_metadata jsonb DEFAULT '{}';

-- Add created_by column to track who created the action
ALTER TABLE actions
ADD COLUMN IF NOT EXISTS created_by text;

-- Add index for efficient filtering by source
CREATE INDEX IF NOT EXISTS idx_actions_source ON actions(source);

-- Add index for source_metadata queries (GIN for jsonb)
CREATE INDEX IF NOT EXISTS idx_actions_source_metadata ON actions USING GIN (source_metadata);

-- ============================================================================
-- Backfill existing actions with source based on available metadata
-- ============================================================================

-- Actions with meeting_id are from meetings
UPDATE actions
SET source = 'meeting',
    source_metadata = jsonb_build_object(
      'source', 'meeting',
      'createdAt', COALESCE(created_at, NOW()::text),
      'meetingId', meeting_id
    )
WHERE meeting_id IS NOT NULL
  AND source = 'manual';

-- Actions with outlook_task_id are from Outlook
UPDATE actions
SET source = 'outlook',
    source_metadata = jsonb_build_object(
      'source', 'outlook',
      'createdAt', COALESCE(created_at, NOW()::text),
      'outlookTaskId', outlook_task_id
    )
WHERE outlook_task_id IS NOT NULL
  AND source = 'manual';

-- Actions with ai_context are likely from AI/ML insights
UPDATE actions
SET source = 'insight_ai',
    source_metadata = jsonb_build_object(
      'source', 'insight_ai',
      'createdAt', COALESCE(ai_context_generated_at, created_at, NOW()::text),
      'confidence', COALESCE(ai_context_confidence, 0)
    )
WHERE ai_context IS NOT NULL
  AND source = 'manual';

-- ============================================================================
-- Add comment for documentation
-- ============================================================================

COMMENT ON COLUMN actions.source IS 'Origin of the action: manual, meeting, insight_ai, insight_ml, chasen, outlook, import';
COMMENT ON COLUMN actions.source_metadata IS 'JSON object with source-specific metadata (insightId, meetingId, confidence, etc.)';
COMMENT ON COLUMN actions.created_by IS 'Email of the user who created the action';

-- ============================================================================
-- Verify migration
-- ============================================================================

-- Check that columns were added
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'actions' AND column_name = 'source'
  ) THEN
    RAISE EXCEPTION 'Migration failed: source column not created';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'actions' AND column_name = 'source_metadata'
  ) THEN
    RAISE EXCEPTION 'Migration failed: source_metadata column not created';
  END IF;

  RAISE NOTICE 'Migration successful: source and source_metadata columns added to actions table';
END $$;
