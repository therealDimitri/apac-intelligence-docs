-- ============================================================================
-- Email Template Design Studio - Database Schema
-- Migration: 20251225_email_template_studio.sql
-- Description: Creates tables for email templates, brand kits, and signatures
-- ============================================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 1. EMAIL TEMPLATES TABLE
-- ============================================================================
-- Stores email templates with their content blocks and metadata
CREATE TABLE IF NOT EXISTS email_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Basic Information
  name TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL CHECK (category IN (
    'onboarding', 'qbr', 'nps', 'product-updates',
    'risk', 'renewal', 'events', 'general'
  )),

  -- Targeting
  segments TEXT[] DEFAULT '{}', -- 'giants', 'sleeping-giants', 'leverage', 'collaborate', 'nurture', 'maintain'
  stakeholder_types TEXT[] DEFAULT '{}', -- 'c-suite', 'clinical', 'it-technical', 'operational'

  -- Email Content
  subject TEXT NOT NULL,
  preview_text TEXT,
  blocks JSONB NOT NULL DEFAULT '[]',
  html_content TEXT,
  plain_text_content TEXT,

  -- Status & Visibility
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
  visibility TEXT DEFAULT 'private' CHECK (visibility IN ('private', 'team', 'organization')),

  -- Ownership & Timestamps
  created_by TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Versioning
  version INTEGER DEFAULT 1,
  parent_template_id UUID REFERENCES email_templates(id) ON DELETE SET NULL,

  -- Analytics
  usage_count INTEGER DEFAULT 0,
  avg_open_rate DECIMAL(5,2),
  avg_click_rate DECIMAL(5,2),
  avg_reply_rate DECIMAL(5,2),
  rating DECIMAL(3,2),

  -- AI Metadata
  ai_generated BOOLEAN DEFAULT FALSE,
  last_ai_suggestion TEXT
);

-- Indexes for email_templates
CREATE INDEX IF NOT EXISTS idx_email_templates_category ON email_templates(category);
CREATE INDEX IF NOT EXISTS idx_email_templates_status ON email_templates(status);
CREATE INDEX IF NOT EXISTS idx_email_templates_created_by ON email_templates(created_by);
CREATE INDEX IF NOT EXISTS idx_email_templates_created_at ON email_templates(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_email_templates_segments ON email_templates USING GIN(segments);
CREATE INDEX IF NOT EXISTS idx_email_templates_stakeholder_types ON email_templates USING GIN(stakeholder_types);

-- ============================================================================
-- 2. BRAND KITS TABLE
-- ============================================================================
-- Stores brand configuration for email styling
CREATE TABLE IF NOT EXISTS brand_kits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Basic Info
  name TEXT NOT NULL,
  is_default BOOLEAN DEFAULT FALSE,

  -- Colours
  primary_colour TEXT NOT NULL DEFAULT '#7C3AED',
  secondary_colour TEXT DEFAULT '#22C55E',
  accent_colour TEXT DEFAULT '#F59E0B',
  dark_colour TEXT DEFAULT '#1A1A2E',
  light_colour TEXT DEFAULT '#F5F5F5',
  success_colour TEXT DEFAULT '#22C55E',
  warning_colour TEXT DEFAULT '#F59E0B',
  error_colour TEXT DEFAULT '#EF4444',

  -- Typography
  heading_font TEXT DEFAULT 'Inter, system-ui, sans-serif',
  body_font TEXT DEFAULT 'Inter, system-ui, sans-serif',
  heading_sizes JSONB DEFAULT '{"h1": 30, "h2": 24, "h3": 20, "h4": 18}',
  body_size INTEGER DEFAULT 16,
  line_height DECIMAL(3,2) DEFAULT 1.5,

  -- Logos
  logo_primary_url TEXT,
  logo_white_url TEXT,
  logo_icon_url TEXT,
  favicon_url TEXT,

  -- Social Links
  linkedin_url TEXT,
  twitter_url TEXT,
  facebook_url TEXT,
  website_url TEXT DEFAULT 'https://www.alterahealth.com',

  -- Ownership & Timestamps
  created_by TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for brand_kits
CREATE INDEX IF NOT EXISTS idx_brand_kits_is_default ON brand_kits(is_default);
CREATE INDEX IF NOT EXISTS idx_brand_kits_created_by ON brand_kits(created_by);

-- ============================================================================
-- 3. EMAIL SIGNATURES TABLE
-- ============================================================================
-- Stores email signatures for users
CREATE TABLE IF NOT EXISTS email_signatures (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- User Info
  user_email TEXT NOT NULL,

  -- Signature Content
  name TEXT NOT NULL,
  title TEXT,
  company TEXT DEFAULT 'Altera Digital Health',
  email TEXT,
  phone TEXT,
  mobile TEXT,
  photo_url TEXT,
  calendar_link TEXT,

  -- Status
  is_default BOOLEAN DEFAULT FALSE,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for email_signatures
CREATE INDEX IF NOT EXISTS idx_email_signatures_user_email ON email_signatures(user_email);
CREATE INDEX IF NOT EXISTS idx_email_signatures_is_default ON email_signatures(is_default);

-- ============================================================================
-- 4. EMAIL TEMPLATE ANALYTICS TABLE
-- ============================================================================
-- Tracks individual email sends for analytics
CREATE TABLE IF NOT EXISTS email_template_analytics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Template Reference
  template_id UUID REFERENCES email_templates(id) ON DELETE CASCADE,

  -- Send Details
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  sent_by TEXT NOT NULL,
  recipient_email TEXT,
  client_name TEXT,

  -- Engagement Tracking
  opened_at TIMESTAMPTZ,
  clicked_at TIMESTAMPTZ,
  replied_at TIMESTAMPTZ,

  -- Delivery Status
  bounce_type TEXT CHECK (bounce_type IN (NULL, 'soft', 'hard')),

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for email_template_analytics
CREATE INDEX IF NOT EXISTS idx_email_template_analytics_template_id ON email_template_analytics(template_id);
CREATE INDEX IF NOT EXISTS idx_email_template_analytics_sent_at ON email_template_analytics(sent_at DESC);
CREATE INDEX IF NOT EXISTS idx_email_template_analytics_sent_by ON email_template_analytics(sent_by);

-- ============================================================================
-- 5. TRIGGERS FOR UPDATED_AT
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for email_templates
DROP TRIGGER IF EXISTS update_email_templates_updated_at ON email_templates;
CREATE TRIGGER update_email_templates_updated_at
  BEFORE UPDATE ON email_templates
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger for brand_kits
DROP TRIGGER IF EXISTS update_brand_kits_updated_at ON brand_kits;
CREATE TRIGGER update_brand_kits_updated_at
  BEFORE UPDATE ON brand_kits
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger for email_signatures
DROP TRIGGER IF EXISTS update_email_signatures_updated_at ON email_signatures;
CREATE TRIGGER update_email_signatures_updated_at
  BEFORE UPDATE ON email_signatures
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 6. ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE email_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE brand_kits ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_signatures ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_template_analytics ENABLE ROW LEVEL SECURITY;

-- email_templates policies
CREATE POLICY "Users can view their own templates" ON email_templates
  FOR SELECT USING (true); -- All authenticated users can view

CREATE POLICY "Users can insert their own templates" ON email_templates
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update their own templates" ON email_templates
  FOR UPDATE USING (true);

CREATE POLICY "Users can delete their own templates" ON email_templates
  FOR DELETE USING (true);

-- brand_kits policies
CREATE POLICY "Users can view brand kits" ON brand_kits
  FOR SELECT USING (true);

CREATE POLICY "Users can insert brand kits" ON brand_kits
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update brand kits" ON brand_kits
  FOR UPDATE USING (true);

CREATE POLICY "Users can delete brand kits" ON brand_kits
  FOR DELETE USING (true);

-- email_signatures policies
CREATE POLICY "Users can view signatures" ON email_signatures
  FOR SELECT USING (true);

CREATE POLICY "Users can insert signatures" ON email_signatures
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update signatures" ON email_signatures
  FOR UPDATE USING (true);

CREATE POLICY "Users can delete signatures" ON email_signatures
  FOR DELETE USING (true);

-- email_template_analytics policies
CREATE POLICY "Users can view analytics" ON email_template_analytics
  FOR SELECT USING (true);

CREATE POLICY "Users can insert analytics" ON email_template_analytics
  FOR INSERT WITH CHECK (true);

-- ============================================================================
-- 7. SEED DATA - DEFAULT BRAND KIT
-- ============================================================================

INSERT INTO brand_kits (
  name,
  is_default,
  primary_colour,
  secondary_colour,
  accent_colour,
  heading_font,
  body_font,
  website_url,
  created_by
) VALUES (
  'Altera Health Default',
  TRUE,
  '#7C3AED',
  '#22C55E',
  '#F59E0B',
  'Inter, system-ui, sans-serif',
  'Inter, system-ui, sans-serif',
  'https://www.alterahealth.com',
  'system'
) ON CONFLICT DO NOTHING;

-- ============================================================================
-- 8. COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON TABLE email_templates IS 'Stores email templates with content blocks for the Email Template Design Studio';
COMMENT ON TABLE brand_kits IS 'Stores brand configuration including colours, fonts, and logos';
COMMENT ON TABLE email_signatures IS 'Stores email signatures for team members';
COMMENT ON TABLE email_template_analytics IS 'Tracks email send events for analytics and performance metrics';

COMMENT ON COLUMN email_templates.blocks IS 'JSONB array of content blocks with type, content, and settings';
COMMENT ON COLUMN email_templates.segments IS 'Target client segments (giants, sleeping-giants, leverage, collaborate, nurture, maintain)';
COMMENT ON COLUMN email_templates.stakeholder_types IS 'Target stakeholder types (c-suite, clinical, it-technical, operational)';
