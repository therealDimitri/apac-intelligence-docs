-- Migration: Email Personalisation Preferences System
-- Created: 2025-12-24
-- Purpose: Create tables for behaviour-based email personalisation
--
-- This migration creates:
-- 1. email_user_preferences - User-configured email preferences
-- 2. email_engagement_patterns - Analysed engagement behaviour patterns
-- 3. email_content_preferences - Content and tone preferences
--
-- Includes proper indexes, RLS policies, and constraints

-- ============================================================================
-- TABLE: email_user_preferences
-- ============================================================================
-- Stores explicit user preferences for email delivery and format

CREATE TABLE IF NOT EXISTS email_user_preferences (
  -- Primary identification
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,

  -- User identification
  user_id TEXT NOT NULL,
  user_email TEXT NOT NULL,

  -- Send time preferences
  preferred_send_time TIME,  -- e.g., '09:00:00' for 9 AM
  preferred_send_day TEXT,   -- e.g., 'monday', 'tuesday', etc.
  timezone TEXT DEFAULT 'Australia/Sydney',

  -- Format preferences
  preferred_format TEXT DEFAULT 'detailed' CHECK (preferred_format IN ('detailed', 'summary', 'auto')),

  -- Section expansion preferences (JSONB for flexibility)
  -- Example: {"actions": true, "nps": false, "health": true}
  sections_expanded JSONB DEFAULT '{}',

  -- Sections to collapse by default
  -- Example: {"metrics": true, "compliance": false}
  sections_collapsed JSONB DEFAULT '{}',

  -- Sections to completely exclude from emails
  -- Example: ["team_comparison", "industry_benchmarks"]
  opt_out_sections TEXT[] DEFAULT '{}',

  -- Frequency preferences
  email_frequency TEXT DEFAULT 'weekly' CHECK (email_frequency IN ('daily', 'weekly', 'fortnightly', 'monthly', 'never')),

  -- Digest preferences
  include_action_digest BOOLEAN DEFAULT true,
  include_nps_digest BOOLEAN DEFAULT true,
  include_health_digest BOOLEAN DEFAULT true,
  include_meeting_digest BOOLEAN DEFAULT true,

  -- Metadata
  last_updated_by TEXT,  -- Who made the last change
  preference_source TEXT DEFAULT 'user' CHECK (preference_source IN ('user', 'auto_detected', 'admin')),

  -- Audit timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Unique constraint on user
  CONSTRAINT unique_email_user_preferences UNIQUE (user_email)
);

-- Create indexes
CREATE INDEX idx_email_user_prefs_user_id ON email_user_preferences(user_id);
CREATE INDEX idx_email_user_prefs_user_email ON email_user_preferences(user_email);
CREATE INDEX idx_email_user_prefs_frequency ON email_user_preferences(email_frequency);

-- Add comment
COMMENT ON TABLE email_user_preferences IS 'Stores user-configured email delivery and format preferences';

-- ============================================================================
-- TABLE: email_engagement_patterns
-- ============================================================================
-- Stores analysed engagement behaviour patterns for intelligent personalisation

CREATE TABLE IF NOT EXISTS email_engagement_patterns (
  -- Primary identification
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,

  -- User identification
  user_id TEXT NOT NULL,
  user_email TEXT NOT NULL,

  -- Engagement timing patterns
  avg_open_time TIME,  -- Average time of day user opens emails
  optimal_send_hour INTEGER CHECK (optimal_send_hour >= 0 AND optimal_send_hour <= 23),
  optimal_send_day TEXT,  -- Most engaged day of week

  -- Section engagement (JSONB with engagement scores)
  -- Example: {"actions": 0.85, "nps": 0.45, "health": 0.92}
  most_clicked_sections JSONB DEFAULT '{}',

  -- Least engaged sections (to potentially hide/summarise)
  -- Example: {"compliance": 0.12, "benchmarks": 0.08}
  least_engaged_sections JSONB DEFAULT '{}',

  -- Device and reading preferences
  device_preference TEXT CHECK (device_preference IN ('desktop', 'mobile', 'tablet', 'mixed', 'unknown')),
  average_read_duration_seconds INTEGER,  -- How long they typically read emails

  -- Email type preferences (which types get most engagement)
  preferred_email_types JSONB DEFAULT '{}',  -- {"weekly_digest": 0.78, "action_reminder": 0.92}

  -- Link click patterns
  most_clicked_links JSONB DEFAULT '{}',  -- Which CTAs work best
  click_through_rate DECIMAL(5, 4),  -- Overall CTR for this user

  -- Reading patterns
  reads_full_email BOOLEAN DEFAULT true,  -- Based on scroll depth/time
  prefers_executive_summary BOOLEAN DEFAULT false,

  -- Statistical data for confidence
  total_emails_sent INTEGER DEFAULT 0,
  total_emails_opened INTEGER DEFAULT 0,
  total_clicks INTEGER DEFAULT 0,
  engagement_score DECIMAL(5, 4),  -- Overall engagement 0-1

  -- Calculation metadata
  last_analysed_at TIMESTAMPTZ,
  analysis_period_days INTEGER DEFAULT 90,  -- How many days of data used
  confidence_level TEXT DEFAULT 'low' CHECK (confidence_level IN ('low', 'medium', 'high')),

  -- Audit timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Unique constraint on user
  CONSTRAINT unique_email_engagement_patterns UNIQUE (user_email)
);

-- Create indexes
CREATE INDEX idx_email_engagement_user_id ON email_engagement_patterns(user_id);
CREATE INDEX idx_email_engagement_user_email ON email_engagement_patterns(user_email);
CREATE INDEX idx_email_engagement_score ON email_engagement_patterns(engagement_score DESC);
CREATE INDEX idx_email_engagement_confidence ON email_engagement_patterns(confidence_level);

-- Add comment
COMMENT ON TABLE email_engagement_patterns IS 'Machine-learnt engagement patterns for intelligent email personalisation';

-- ============================================================================
-- TABLE: email_content_preferences
-- ============================================================================
-- Stores content style and tone preferences

CREATE TABLE IF NOT EXISTS email_content_preferences (
  -- Primary identification
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,

  -- User identification
  user_id TEXT NOT NULL,
  user_email TEXT NOT NULL,

  -- Tone and style preferences
  tone_preference TEXT DEFAULT 'supportive' CHECK (tone_preference IN ('supportive', 'formal', 'concise', 'detailed', 'casual')),
  language_style TEXT DEFAULT 'australian_english' CHECK (language_style IN ('australian_english', 'british_english', 'american_english')),

  -- Detail level
  detail_level_preference TEXT DEFAULT 'auto' CHECK (detail_level_preference IN ('high', 'medium', 'low', 'auto')),

  -- Content inclusion flags
  include_wellbeing_tips BOOLEAN DEFAULT true,
  include_professional_development BOOLEAN DEFAULT true,
  include_industry_insights BOOLEAN DEFAULT false,
  include_team_comparison BOOLEAN DEFAULT true,
  include_client_quotes BOOLEAN DEFAULT true,
  include_actionable_insights BOOLEAN DEFAULT true,

  -- Visualisation preferences
  include_charts BOOLEAN DEFAULT true,
  include_sparklines BOOLEAN DEFAULT true,
  chart_style TEXT DEFAULT 'modern' CHECK (chart_style IN ('modern', 'classic', 'minimal')),

  -- Data presentation
  show_absolute_numbers BOOLEAN DEFAULT true,
  show_percentages BOOLEAN DEFAULT true,
  show_trends BOOLEAN DEFAULT true,
  show_comparisons BOOLEAN DEFAULT true,

  -- Call-to-action preferences
  cta_style TEXT DEFAULT 'prominent' CHECK (cta_style IN ('prominent', 'subtle', 'minimal')),
  max_ctas_per_email INTEGER DEFAULT 3 CHECK (max_ctas_per_email >= 1 AND max_ctas_per_email <= 10),

  -- Notification preferences
  alert_on_critical_only BOOLEAN DEFAULT false,
  include_good_news BOOLEAN DEFAULT true,
  include_neutral_updates BOOLEAN DEFAULT true,

  -- Personalisation level
  personalisation_level TEXT DEFAULT 'high' CHECK (personalisation_level IN ('none', 'low', 'medium', 'high')),
  use_first_name BOOLEAN DEFAULT true,
  include_personal_stats BOOLEAN DEFAULT true,

  -- Metadata
  last_updated_by TEXT,
  preference_source TEXT DEFAULT 'inferred' CHECK (preference_source IN ('user', 'inferred', 'admin', 'ab_test')),

  -- Audit timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Unique constraint on user
  CONSTRAINT unique_email_content_prefs UNIQUE (user_email)
);

-- Create indexes
CREATE INDEX idx_email_content_prefs_user_id ON email_content_preferences(user_id);
CREATE INDEX idx_email_content_prefs_user_email ON email_content_preferences(user_email);
CREATE INDEX idx_email_content_prefs_tone ON email_content_preferences(tone_preference);
CREATE INDEX idx_email_content_prefs_detail ON email_content_preferences(detail_level_preference);

-- Add comment
COMMENT ON TABLE email_content_preferences IS 'Content style, tone, and presentation preferences for emails';

-- ============================================================================
-- TRIGGERS: Update updated_at timestamp
-- ============================================================================

CREATE OR REPLACE FUNCTION update_email_preferences_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_email_user_prefs_updated_at
  BEFORE UPDATE ON email_user_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_email_preferences_updated_at();

CREATE TRIGGER trigger_update_email_engagement_updated_at
  BEFORE UPDATE ON email_engagement_patterns
  FOR EACH ROW
  EXECUTE FUNCTION update_email_preferences_updated_at();

CREATE TRIGGER trigger_update_email_content_prefs_updated_at
  BEFORE UPDATE ON email_content_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_email_preferences_updated_at();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE email_user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_engagement_patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_content_preferences ENABLE ROW LEVEL SECURITY;

-- Service role has full access
CREATE POLICY "Service role has full access to email_user_preferences"
  ON email_user_preferences
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Service role has full access to email_engagement_patterns"
  ON email_engagement_patterns
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Service role has full access to email_content_preferences"
  ON email_content_preferences
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Authenticated users can read and update their own preferences
CREATE POLICY "Users can read their own email_user_preferences"
  ON email_user_preferences
  FOR SELECT
  TO authenticated
  USING (user_email = auth.jwt()->>'email');

CREATE POLICY "Users can update their own email_user_preferences"
  ON email_user_preferences
  FOR UPDATE
  TO authenticated
  USING (user_email = auth.jwt()->>'email')
  WITH CHECK (user_email = auth.jwt()->>'email');

CREATE POLICY "Users can insert their own email_user_preferences"
  ON email_user_preferences
  FOR INSERT
  TO authenticated
  WITH CHECK (user_email = auth.jwt()->>'email');

-- Similar policies for engagement patterns (read-only for users)
CREATE POLICY "Users can read their own email_engagement_patterns"
  ON email_engagement_patterns
  FOR SELECT
  TO authenticated
  USING (user_email = auth.jwt()->>'email');

-- Similar policies for content preferences
CREATE POLICY "Users can read their own email_content_preferences"
  ON email_content_preferences
  FOR SELECT
  TO authenticated
  USING (user_email = auth.jwt()->>'email');

CREATE POLICY "Users can update their own email_content_preferences"
  ON email_content_preferences
  FOR UPDATE
  TO authenticated
  USING (user_email = auth.jwt()->>'email')
  WITH CHECK (user_email = auth.jwt()->>'email');

CREATE POLICY "Users can insert their own email_content_preferences"
  ON email_content_preferences
  FOR INSERT
  TO authenticated
  WITH CHECK (user_email = auth.jwt()->>'email');

-- ============================================================================
-- GRANT PERMISSIONS
-- ============================================================================

GRANT SELECT, INSERT, UPDATE ON email_user_preferences TO authenticated;
GRANT SELECT ON email_engagement_patterns TO authenticated;
GRANT SELECT, INSERT, UPDATE ON email_content_preferences TO authenticated;

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Function to get or create user preferences with sensible defaults
CREATE OR REPLACE FUNCTION get_or_create_user_email_preferences(
  p_user_email TEXT,
  p_user_id TEXT DEFAULT NULL
)
RETURNS SETOF email_user_preferences
LANGUAGE plpgsql
AS $$
BEGIN
  -- Try to get existing preferences
  RETURN QUERY
  SELECT * FROM email_user_preferences
  WHERE user_email = p_user_email;

  -- If none exist, create with defaults
  IF NOT FOUND THEN
    INSERT INTO email_user_preferences (user_id, user_email)
    VALUES (COALESCE(p_user_id, p_user_email), p_user_email)
    RETURNING *;

    RETURN QUERY
    SELECT * FROM email_user_preferences
    WHERE user_email = p_user_email;
  END IF;
END;
$$;

COMMENT ON FUNCTION get_or_create_user_email_preferences IS 'Gets user email preferences or creates defaults if none exist';

-- Function to calculate engagement score
CREATE OR REPLACE FUNCTION calculate_user_engagement_score(
  p_user_email TEXT,
  p_days_back INTEGER DEFAULT 90
)
RETURNS DECIMAL
LANGUAGE plpgsql
AS $$
DECLARE
  v_total_sent INTEGER;
  v_total_opened INTEGER;
  v_total_clicked INTEGER;
  v_open_rate DECIMAL;
  v_click_rate DECIMAL;
  v_engagement_score DECIMAL;
BEGIN
  -- Get email stats for user
  SELECT
    COUNT(*),
    COUNT(*) FILTER (WHERE opened = true),
    COUNT(*) FILTER (WHERE clicked = true)
  INTO v_total_sent, v_total_opened, v_total_clicked
  FROM email_sends
  WHERE recipient_email = p_user_email
    AND sent_at >= NOW() - (p_days_back || ' days')::INTERVAL;

  -- Handle no emails sent
  IF v_total_sent = 0 THEN
    RETURN 0;
  END IF;

  -- Calculate rates
  v_open_rate := v_total_opened::DECIMAL / v_total_sent;
  v_click_rate := v_total_clicked::DECIMAL / v_total_sent;

  -- Weighted engagement score (opens 40%, clicks 60%)
  v_engagement_score := (v_open_rate * 0.4) + (v_click_rate * 0.6);

  RETURN ROUND(v_engagement_score, 4);
END;
$$;

COMMENT ON FUNCTION calculate_user_engagement_score IS 'Calculates overall engagement score for a user based on email interactions';

-- Function to update engagement patterns from email events
CREATE OR REPLACE FUNCTION update_user_engagement_patterns(
  p_user_email TEXT,
  p_analysis_days INTEGER DEFAULT 90
)
RETURNS SETOF email_engagement_patterns
LANGUAGE plpgsql
AS $$
DECLARE
  v_total_sent INTEGER;
  v_total_opened INTEGER;
  v_confidence TEXT;
BEGIN
  -- Calculate statistics
  SELECT
    COUNT(*),
    COUNT(*) FILTER (WHERE opened = true)
  INTO v_total_sent, v_total_opened
  FROM email_sends
  WHERE recipient_email = p_user_email
    AND sent_at >= NOW() - (p_analysis_days || ' days')::INTERVAL;

  -- Determine confidence level
  IF v_total_sent >= 20 THEN
    v_confidence := 'high';
  ELSIF v_total_sent >= 10 THEN
    v_confidence := 'medium';
  ELSE
    v_confidence := 'low';
  END IF;

  -- Upsert engagement patterns
  INSERT INTO email_engagement_patterns (
    user_email,
    user_id,
    total_emails_sent,
    total_emails_opened,
    engagement_score,
    confidence_level,
    last_analysed_at,
    analysis_period_days
  )
  VALUES (
    p_user_email,
    p_user_email,  -- Use email as user_id if not available
    v_total_sent,
    v_total_opened,
    calculate_user_engagement_score(p_user_email, p_analysis_days),
    v_confidence,
    NOW(),
    p_analysis_days
  )
  ON CONFLICT (user_email)
  DO UPDATE SET
    total_emails_sent = v_total_sent,
    total_emails_opened = v_total_opened,
    engagement_score = calculate_user_engagement_score(p_user_email, p_analysis_days),
    confidence_level = v_confidence,
    last_analysed_at = NOW(),
    updated_at = NOW();

  RETURN QUERY
  SELECT * FROM email_engagement_patterns
  WHERE user_email = p_user_email;
END;
$$;

COMMENT ON FUNCTION update_user_engagement_patterns IS 'Analyses email events and updates engagement patterns for a user';

-- ============================================================================
-- VALIDATION & CONSTRAINTS
-- ============================================================================

-- Email validation
ALTER TABLE email_user_preferences
  ADD CONSTRAINT check_email_user_prefs_email
  CHECK (user_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$');

ALTER TABLE email_engagement_patterns
  ADD CONSTRAINT check_email_engagement_email
  CHECK (user_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$');

ALTER TABLE email_content_preferences
  ADD CONSTRAINT check_email_content_prefs_email
  CHECK (user_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$');

-- ============================================================================
-- INITIAL DATA
-- ============================================================================

-- Insert default content preferences template
INSERT INTO email_content_preferences (
  user_id,
  user_email,
  tone_preference,
  detail_level_preference,
  preference_source
)
VALUES (
  'system_default',
  'system@default.local',
  'supportive',
  'auto',
  'admin'
)
ON CONFLICT (user_email) DO NOTHING;

COMMENT ON TABLE email_content_preferences IS 'The row with user_email = system@default.local serves as default template';

-- ============================================================================
-- COMPLETION
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE 'Email personalisation preferences system migration completed successfully';
  RAISE NOTICE 'Tables created: email_user_preferences, email_engagement_patterns, email_content_preferences';
  RAISE NOTICE 'Helper functions created for engagement analysis and preference management';
END;
$$;
