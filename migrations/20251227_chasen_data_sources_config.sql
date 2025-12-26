-- Migration: ChaSen Data Sources Configuration
-- Date: 2025-12-27
-- Purpose: Auto-discovery and dynamic integration of database tables for ChaSen AI

-- Create the configuration table for ChaSen data sources
CREATE TABLE IF NOT EXISTS chasen_data_sources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL DEFAULT 'general', -- 'client', 'operations', 'analytics', 'system'
  is_enabled BOOLEAN NOT NULL DEFAULT true,
  priority INTEGER NOT NULL DEFAULT 50, -- 1-100, higher = more important

  -- Query configuration
  select_columns TEXT[] NOT NULL, -- columns to select
  order_by TEXT, -- e.g., 'created_at DESC'
  limit_rows INTEGER DEFAULT 10,
  filter_condition TEXT, -- e.g., 'status != ''deleted'''
  time_filter_column TEXT, -- column for time-based filtering
  time_filter_days INTEGER, -- filter to last N days

  -- Context formatting
  context_template TEXT, -- how to format in ChaSen context
  section_emoji TEXT DEFAULT '📊',
  section_title TEXT, -- override display name for section header
  include_link TEXT, -- dashboard link to include

  -- Metadata
  row_count INTEGER, -- cached row count
  last_synced_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index for enabled sources ordered by priority
CREATE INDEX IF NOT EXISTS idx_chasen_data_sources_enabled
ON chasen_data_sources(is_enabled, priority DESC);

-- Enable RLS
ALTER TABLE chasen_data_sources ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read
CREATE POLICY "chasen_data_sources_read" ON chasen_data_sources
  FOR SELECT TO authenticated USING (true);

-- Allow service role full access
CREATE POLICY "chasen_data_sources_service" ON chasen_data_sources
  FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Insert current data sources configuration
INSERT INTO chasen_data_sources (table_name, display_name, description, category, priority, select_columns, order_by, limit_rows, filter_condition, time_filter_column, time_filter_days, section_emoji, section_title, include_link) VALUES

-- Core client data
('client_health_history', 'Client Health History', 'Historical health scores and status changes', 'client', 95,
 ARRAY['client_name', 'health_score', 'compliance_points', 'status', 'snapshot_date'],
 'snapshot_date DESC', 50, NULL, 'snapshot_date', NULL, '🏥', 'Client Health Status', '/client-profiles'),

('nps_responses', 'NPS Responses', 'Individual NPS survey responses with feedback', 'client', 90,
 ARRAY['client_name', 'score', 'feedback', 'response_date', 'period', 'category'],
 'response_date DESC', 10, NULL, 'response_date', 90, '📊', 'Recent NPS Feedback', '/nps'),

('client_segmentation', 'Client Segmentation', 'Client tier assignments and CSE mappings', 'client', 85,
 ARRAY['client_name', 'tier_id', 'cse_name', 'effective_from'],
 'client_name', 30, NULL, NULL, NULL, '🎯', 'CSE Assignments', '/segmentation'),

('unified_meetings', 'Meetings', 'Client meetings with notes and AI summaries', 'operations', 80,
 ARRAY['client_name', 'title', 'meeting_date', 'meeting_type', 'ai_summary', 'meeting_notes'],
 'meeting_date DESC', 10, 'deleted IS NOT TRUE', 'meeting_date', 14, '📅', 'Recent Meetings', '/meetings'),

('actions', 'Actions & Tasks', 'Open and overdue action items', 'operations', 85,
 ARRAY['client', 'Action_Description', 'Due_Date', 'Status', 'Owners', 'Priority'],
 'Due_Date ASC', 15, 'Status != ''Completed''', NULL, NULL, '✅', 'Open Actions', '/actions'),

-- Working capital
('aging_accounts', 'Aging Accounts', 'Current AR and overdue amounts by client', 'analytics', 75,
 ARRAY['client_name', 'total_outstanding', 'total_overdue', 'current_amount', 'days_1_to_30', 'days_31_to_60', 'days_61_to_90', 'days_91_to_120', 'cse_name'],
 'total_outstanding DESC', 15, NULL, NULL, NULL, '💰', 'Working Capital', '/aging-accounts'),

('aged_accounts_history', 'AR History', 'Historical AR compliance snapshots', 'analytics', 70,
 ARRAY['snapshot_date', 'total_ar', 'under_60_compliance', 'under_90_compliance'],
 'snapshot_date DESC', 7, NULL, 'snapshot_date', 30, '📈', 'AR Compliance Trends', '/aging-accounts/compliance'),

-- Health monitoring
('health_status_alerts', 'Health Alerts', 'Client health status change notifications', 'client', 88,
 ARRAY['client_name', 'previous_status', 'new_status', 'previous_score', 'new_score', 'direction', 'alert_date', 'acknowledged'],
 'alert_date DESC', 10, 'acknowledged = false', 'alert_date', 30, '⚡', 'Health Status Changes', NULL),

-- NPS analytics
('nps_period_config', 'NPS Periods', 'NPS survey cycle configuration', 'system', 60,
 ARRAY['period_code', 'period_name', 'fiscal_year', 'surveys_sent', 'survey_start_date', 'survey_end_date', 'is_active'],
 'sort_order DESC', 5, NULL, NULL, NULL, '📊', 'NPS Survey Periods', '/nps'),

('nps_topic_classifications', 'NPS Topics', 'AI-classified NPS feedback topics with sentiment', 'analytics', 65,
 ARRAY['topic_name', 'sentiment', 'confidence_score'],
 'classified_at DESC', 50, 'confidence_score >= 0.7', 'classified_at', 90, '🏷️', 'NPS Topic Sentiment', '/nps'),

-- Compliance
('tier_requirements', 'Tier Requirements', 'Compliance event requirements by tier', 'system', 55,
 ARRAY['tier_id', 'event_type', 'required_count', 'event_description'],
 'tier_id', 50, NULL, NULL, NULL, '📋', 'Compliance Requirements', '/segmentation'),

-- Initiatives & projects
('portfolio_initiatives', 'Portfolio Initiatives', 'Active client initiatives and projects', 'operations', 70,
 ARRAY['name', 'client_name', 'status', 'category', 'year', 'cse_name'],
 'created_at DESC', 10, 'status != ''completed''', NULL, NULL, '🎯', 'Active Initiatives', NULL),

-- Collaboration
('comments', 'Comments', 'Team discussions on clients, meetings, and actions', 'operations', 60,
 ARRAY['entity_type', 'entity_id', 'client_name', 'content', 'user_name', 'created_at'],
 'created_at DESC', 10, NULL, 'created_at', 7, '💬', 'Recent Discussions', NULL),

('notifications', 'Notifications', 'User notifications and alerts', 'system', 50,
 ARRAY['type', 'title', 'message', 'link', 'triggered_by', 'created_at', 'read'],
 'created_at DESC', 10, 'read = false', 'created_at', 7, '🔔', 'Unread Notifications', NULL),

-- System integrations
('email_logs', 'Email Tracking', 'Email activity logs', 'system', 40,
 ARRAY['email_type', 'recipient_email', 'status', 'sent_at', 'client_name'],
 'sent_at DESC', 20, NULL, 'sent_at', 30, '📧', 'Email Activity', NULL),

('webhook_logs', 'Webhook Logs', 'Integration webhook activity', 'system', 35,
 ARRAY['webhook_name', 'event_type', 'status', 'response_code', 'created_at'],
 'created_at DESC', 10, NULL, 'created_at', 7, '🔗', 'Integration Status', NULL),

-- User preferences
('saved_views', 'Saved Views', 'User-saved dashboard views', 'system', 30,
 ARRAY['name', 'view_type', 'filters', 'is_default'],
 'created_at DESC', 10, NULL, NULL, NULL, '📁', 'Saved Views', NULL),

-- ChaSen learning
('chasen_knowledge', 'ChaSen Knowledge', 'ChaSen knowledge base entries', 'system', 45,
 ARRAY['category', 'title', 'content', 'priority', 'is_active'],
 'priority DESC', 20, 'is_active = true', NULL, NULL, '🧠', 'Knowledge Base', NULL)

ON CONFLICT (table_name) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- Function to discover new tables not in config
CREATE OR REPLACE FUNCTION discover_new_tables()
RETURNS TABLE(
  table_name TEXT,
  row_count BIGINT,
  column_count INTEGER,
  suggested_category TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    t.tablename::TEXT,
    (SELECT reltuples::BIGINT FROM pg_class WHERE relname = t.tablename),
    (SELECT COUNT(*)::INTEGER FROM information_schema.columns c WHERE c.table_name = t.tablename),
    CASE
      WHEN t.tablename LIKE 'client%' OR t.tablename LIKE 'nps%' THEN 'client'
      WHEN t.tablename LIKE 'action%' OR t.tablename LIKE 'meeting%' OR t.tablename LIKE 'unified%' THEN 'operations'
      WHEN t.tablename LIKE 'aging%' OR t.tablename LIKE '%history%' OR t.tablename LIKE '%analytics%' THEN 'analytics'
      ELSE 'system'
    END
  FROM pg_tables t
  WHERE t.schemaname = 'public'
    AND t.tablename NOT IN (SELECT cds.table_name FROM chasen_data_sources cds)
    AND t.tablename NOT LIKE 'pg_%'
    AND t.tablename NOT LIKE '__%'
  ORDER BY 2 DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get table columns for auto-config
CREATE OR REPLACE FUNCTION get_table_columns(p_table_name TEXT)
RETURNS TABLE(
  column_name TEXT,
  data_type TEXT,
  is_nullable BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.column_name::TEXT,
    c.data_type::TEXT,
    (c.is_nullable = 'YES')::BOOLEAN
  FROM information_schema.columns c
  WHERE c.table_name = p_table_name
    AND c.table_schema = 'public'
  ORDER BY c.ordinal_position;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to update updated_at
CREATE OR REPLACE FUNCTION update_chasen_data_sources_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS chasen_data_sources_updated ON chasen_data_sources;
CREATE TRIGGER chasen_data_sources_updated
  BEFORE UPDATE ON chasen_data_sources
  FOR EACH ROW
  EXECUTE FUNCTION update_chasen_data_sources_timestamp();
