-- Migration: Saved Views Table
-- Date: 2025-12-07
-- Purpose: Replace localStorage saved views with Supabase table
-- Affects: Briefing Room view filters and saved searches

-- Create saved_views table
CREATE TABLE IF NOT EXISTS saved_views (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_email TEXT NOT NULL,
  view_name TEXT NOT NULL,
  filters JSONB NOT NULL,
  is_shared BOOLEAN DEFAULT false,
  shared_with TEXT[], -- Array of emails with access
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_saved_views_user ON saved_views(user_email);
CREATE INDEX IF NOT EXISTS idx_saved_views_shared ON saved_views(is_shared) WHERE is_shared = true;
CREATE INDEX IF NOT EXISTS idx_saved_views_created ON saved_views(created_at DESC);

-- Enable Row Level Security
ALTER TABLE saved_views ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can view their own saved views
CREATE POLICY "Users can view their own saved views"
  ON saved_views FOR SELECT
  USING (
    user_email = current_setting('request.jwt.claims', true)::json->>'email'
  );

-- RLS Policy: Users can view shared views
CREATE POLICY "Users can view shared views"
  ON saved_views FOR SELECT
  USING (
    is_shared = true
  );

-- RLS Policy: Users can view views shared with them specifically
CREATE POLICY "Users can view views shared with them"
  ON saved_views FOR SELECT
  USING (
    current_setting('request.jwt.claims', true)::json->>'email' = ANY(shared_with)
  );

-- RLS Policy: Users can create their own saved views
CREATE POLICY "Users can create their own saved views"
  ON saved_views FOR INSERT
  WITH CHECK (
    user_email = current_setting('request.jwt.claims', true)::json->>'email'
  );

-- RLS Policy: Users can update their own saved views
CREATE POLICY "Users can update their own saved views"
  ON saved_views FOR UPDATE
  USING (
    user_email = current_setting('request.jwt.claims', true)::json->>'email'
  );

-- RLS Policy: Users can delete their own saved views
CREATE POLICY "Users can delete their own saved views"
  ON saved_views FOR DELETE
  USING (
    user_email = current_setting('request.jwt.claims', true)::json->>'email'
  );

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_saved_views_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER saved_views_updated_at
  BEFORE UPDATE ON saved_views
  FOR EACH ROW
  EXECUTE FUNCTION update_saved_views_updated_at();

-- Add comment
COMMENT ON TABLE saved_views IS 'Stores user-created saved views and filters for the Briefing Room. Replaces localStorage implementation.';
