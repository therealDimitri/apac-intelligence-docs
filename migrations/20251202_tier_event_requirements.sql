-- Migration: Create tier_event_requirements table
-- Purpose: Map which events are required for each segmentation tier and their frequencies
-- This enables time-aware compliance calculation based on segment changes

-- Create tier_event_requirements table
CREATE TABLE IF NOT EXISTS tier_event_requirements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tier_id UUID NOT NULL REFERENCES segmentation_tiers(id) ON DELETE CASCADE,
  event_type_id UUID NOT NULL REFERENCES segmentation_event_types(id) ON DELETE CASCADE,
  frequency INTEGER NOT NULL DEFAULT 0, -- How many times per year this event is required
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Ensure one requirement per tier-event combination
  UNIQUE(tier_id, event_type_id)
);

-- Add index for fast lookups
CREATE INDEX IF NOT EXISTS idx_tier_event_requirements_tier
  ON tier_event_requirements(tier_id);
CREATE INDEX IF NOT EXISTS idx_tier_event_requirements_event
  ON tier_event_requirements(event_type_id);

-- Enable RLS
ALTER TABLE tier_event_requirements ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Allow public read access to tier_event_requirements"
  ON tier_event_requirements
  FOR SELECT
  TO anon, authenticated
  USING (true);

-- Add comment
COMMENT ON TABLE tier_event_requirements IS 'Defines which events are required for each segmentation tier and how frequently (per year). Used for time-aware compliance calculation when clients change segments mid-year.';
COMMENT ON COLUMN tier_event_requirements.frequency IS 'Number of times per year this event is required for this tier. 0 means not required.';

-- Example data will be populated from the Activities sheet in the Excel file
