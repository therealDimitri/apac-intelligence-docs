-- Migration: User Preferences Table
-- Date: 2025-12-07
-- Purpose: Replace localStorage user preferences with Supabase table
-- Affects: Dashboard layout, notification settings, favorite clients

-- Create user_preferences table
CREATE TABLE IF NOT EXISTS user_preferences (
  user_email TEXT PRIMARY KEY,
  default_view TEXT DEFAULT 'intelligence' CHECK (default_view IN ('intelligence', 'traditional')),
  default_segment_filter TEXT DEFAULT 'all',
  favorite_clients TEXT[],
  hidden_clients TEXT[],
  notification_settings JSONB DEFAULT '{
    "criticalAlerts": true,
    "complianceWarnings": true,
    "upcomingEvents": true,
    "npsChanges": true,
    "weeklyDigest": true,
    "actionReminders": true
  }'::jsonb,
  dashboard_layout JSONB DEFAULT '{
    "showCommandCentre": true,
    "showSmartInsights": true,
    "showChaSen": true,
    "compactMode": false,
    "sidebarCollapsed": false
  }'::jsonb,
  theme TEXT DEFAULT 'light' CHECK (theme IN ('light', 'dark', 'auto')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_user_preferences_email ON user_preferences(user_email);

-- Enable Row Level Security
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can view their own preferences
CREATE POLICY "Users can view their own preferences"
  ON user_preferences FOR SELECT
  USING (
    user_email = current_setting('request.jwt.claims', true)::json->>'email'
  );

-- RLS Policy: Users can insert their own preferences
CREATE POLICY "Users can insert their own preferences"
  ON user_preferences FOR INSERT
  WITH CHECK (
    user_email = current_setting('request.jwt.claims', true)::json->>'email'
  );

-- RLS Policy: Users can update their own preferences
CREATE POLICY "Users can update their own preferences"
  ON user_preferences FOR UPDATE
  USING (
    user_email = current_setting('request.jwt.claims', true)::json->>'email'
  );

-- RLS Policy: Users can delete their own preferences
CREATE POLICY "Users can delete their own preferences"
  ON user_preferences FOR DELETE
  USING (
    user_email = current_setting('request.jwt.claims', true)::json->>'email'
  );

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_user_preferences_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_preferences_updated_at
  BEFORE UPDATE ON user_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_user_preferences_updated_at();

-- Add comment
COMMENT ON TABLE user_preferences IS 'Stores user-specific dashboard preferences and settings. Replaces localStorage implementation for cross-device sync.';
