-- Migration: Email Tracking System
-- Created: 2025-12-24
-- Purpose: Create tables for tracking email opens, clicks, and analytics
--
-- This migration creates:
-- 1. email_sends - Records of each email sent
-- 2. email_events - Tracks opens, clicks, and other email events
--
-- Includes proper indexes, RLS policies, and constraints

-- ============================================================================
-- TABLE: email_sends
-- ============================================================================
-- Stores a record for each email sent, including recipient details and metadata

CREATE TABLE IF NOT EXISTS email_sends (
  -- Primary identification
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,

  -- Email details
  email_type TEXT NOT NULL,  -- e.g., 'weekly_digest', 'action_reminder', 'health_alert'
  subject TEXT NOT NULL,

  -- Recipient information
  recipient_email TEXT NOT NULL,
  recipient_name TEXT,
  recipient_role TEXT,  -- e.g., 'cse', 'client', 'admin'

  -- Related entities
  client_name TEXT,  -- For client-specific emails
  cse_name TEXT,     -- For CSE-specific emails

  -- Tracking metadata
  tracking_id TEXT UNIQUE NOT NULL,  -- Unique ID for tracking pixel/links

  -- Email content reference
  email_content_hash TEXT,  -- Hash of email content for deduplication
  template_version TEXT,     -- Version of email template used

  -- Delivery status
  sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  delivery_status TEXT DEFAULT 'sent',  -- 'sent', 'delivered', 'bounced', 'failed'
  delivery_error TEXT,

  -- Provider metadata
  provider TEXT DEFAULT 'sendgrid',  -- Email provider used
  provider_message_id TEXT,          -- Provider's message ID

  -- Additional metadata (flexible storage)
  metadata JSONB DEFAULT '{}',

  -- Audit timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for common queries
CREATE INDEX idx_email_sends_tracking_id ON email_sends(tracking_id);
CREATE INDEX idx_email_sends_recipient_email ON email_sends(recipient_email);
CREATE INDEX idx_email_sends_email_type ON email_sends(email_type);
CREATE INDEX idx_email_sends_sent_at ON email_sends(sent_at DESC);
CREATE INDEX idx_email_sends_client_name ON email_sends(client_name) WHERE client_name IS NOT NULL;
CREATE INDEX idx_email_sends_cse_name ON email_sends(cse_name) WHERE cse_name IS NOT NULL;
CREATE INDEX idx_email_sends_delivery_status ON email_sends(delivery_status);

-- Composite index for analytics queries
CREATE INDEX idx_email_sends_analytics ON email_sends(email_type, sent_at DESC, delivery_status);

-- Add comment to table
COMMENT ON TABLE email_sends IS 'Tracks all emails sent through the system with delivery status and metadata';

-- ============================================================================
-- TABLE: email_events
-- ============================================================================
-- Tracks all events related to emails (opens, clicks, bounces, etc.)

CREATE TABLE IF NOT EXISTS email_events (
  -- Primary identification
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,

  -- Link to email send
  email_send_id TEXT NOT NULL REFERENCES email_sends(id) ON DELETE CASCADE,
  tracking_id TEXT NOT NULL,  -- Denormalised for faster queries

  -- Event details
  event_type TEXT NOT NULL,  -- 'open', 'click', 'bounce', 'spam_report', 'unsubscribe'
  event_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Click-specific data
  clicked_url TEXT,          -- Original URL that was clicked
  link_identifier TEXT,      -- Identifier for the link (e.g., 'cta_button', 'view_actions')

  -- Device and location information
  user_agent TEXT,
  ip_address TEXT,
  device_type TEXT,          -- 'desktop', 'mobile', 'tablet', 'unknown'
  browser TEXT,              -- 'Chrome', 'Safari', 'Firefox', etc.
  operating_system TEXT,     -- 'Windows', 'macOS', 'iOS', 'Android', etc.

  -- Geographic data
  country TEXT,
  region TEXT,
  city TEXT,

  -- Additional event metadata
  metadata JSONB DEFAULT '{}',

  -- Audit timestamp
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for common queries
CREATE INDEX idx_email_events_email_send_id ON email_events(email_send_id);
CREATE INDEX idx_email_events_tracking_id ON email_events(tracking_id);
CREATE INDEX idx_email_events_event_type ON email_events(event_type);
CREATE INDEX idx_email_events_event_timestamp ON email_events(event_timestamp DESC);
CREATE INDEX idx_email_events_clicked_url ON email_events(clicked_url) WHERE clicked_url IS NOT NULL;

-- Composite index for analytics
CREATE INDEX idx_email_events_analytics ON email_events(event_type, event_timestamp DESC);
CREATE INDEX idx_email_events_device_analytics ON email_events(device_type, event_type) WHERE device_type IS NOT NULL;

-- Add comment to table
COMMENT ON TABLE email_events IS 'Tracks all email interaction events including opens, clicks, and bounces';

-- ============================================================================
-- MATERIALIZED VIEW: email_analytics_summary
-- ============================================================================
-- Pre-aggregated analytics for faster dashboard queries

CREATE MATERIALIZED VIEW email_analytics_summary AS
SELECT
  es.email_type,
  es.recipient_role,
  DATE_TRUNC('day', es.sent_at) as send_date,

  -- Send metrics
  COUNT(DISTINCT es.id) as total_sent,
  COUNT(DISTINCT CASE WHEN es.delivery_status = 'delivered' THEN es.id END) as total_delivered,
  COUNT(DISTINCT CASE WHEN es.delivery_status = 'bounced' THEN es.id END) as total_bounced,

  -- Engagement metrics
  COUNT(DISTINCT CASE WHEN ee_open.email_send_id IS NOT NULL THEN es.id END) as total_opened,
  COUNT(DISTINCT CASE WHEN ee_click.email_send_id IS NOT NULL THEN es.id END) as total_clicked,

  -- Rates (as decimals, multiply by 100 for percentage)
  CASE
    WHEN COUNT(DISTINCT es.id) > 0
    THEN COUNT(DISTINCT CASE WHEN ee_open.email_send_id IS NOT NULL THEN es.id END)::DECIMAL / COUNT(DISTINCT es.id)
    ELSE 0
  END as open_rate,

  CASE
    WHEN COUNT(DISTINCT es.id) > 0
    THEN COUNT(DISTINCT CASE WHEN ee_click.email_send_id IS NOT NULL THEN es.id END)::DECIMAL / COUNT(DISTINCT es.id)
    ELSE 0
  END as click_rate,

  CASE
    WHEN COUNT(DISTINCT CASE WHEN ee_open.email_send_id IS NOT NULL THEN es.id END) > 0
    THEN COUNT(DISTINCT CASE WHEN ee_click.email_send_id IS NOT NULL THEN es.id END)::DECIMAL /
         COUNT(DISTINCT CASE WHEN ee_open.email_send_id IS NOT NULL THEN es.id END)
    ELSE 0
  END as click_to_open_rate,

  -- Time to first open (average in seconds)
  AVG(EXTRACT(EPOCH FROM (ee_open.first_open - es.sent_at)))::INTEGER as avg_time_to_open_seconds

FROM email_sends es
LEFT JOIN (
  SELECT DISTINCT ON (email_send_id)
    email_send_id,
    event_timestamp as first_open
  FROM email_events
  WHERE event_type = 'open'
  ORDER BY email_send_id, event_timestamp ASC
) ee_open ON es.id = ee_open.email_send_id
LEFT JOIN (
  SELECT DISTINCT email_send_id
  FROM email_events
  WHERE event_type = 'click'
) ee_click ON es.id = ee_click.email_send_id
WHERE es.sent_at >= NOW() - INTERVAL '90 days'  -- Only last 90 days for performance
GROUP BY es.email_type, es.recipient_role, DATE_TRUNC('day', es.sent_at);

-- Create index on materialized view
CREATE UNIQUE INDEX idx_email_analytics_summary_unique
  ON email_analytics_summary(email_type, COALESCE(recipient_role, ''), send_date);
CREATE INDEX idx_email_analytics_summary_date ON email_analytics_summary(send_date DESC);

-- Add comment
COMMENT ON MATERIALIZED VIEW email_analytics_summary IS 'Pre-aggregated email analytics for dashboard performance';

-- ============================================================================
-- FUNCTION: Refresh materialized view
-- ============================================================================

CREATE OR REPLACE FUNCTION refresh_email_analytics_summary()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY email_analytics_summary;
END;
$$;

COMMENT ON FUNCTION refresh_email_analytics_summary IS 'Refreshes the email analytics materialized view';

-- ============================================================================
-- TRIGGER: Update updated_at timestamp
-- ============================================================================

CREATE OR REPLACE FUNCTION update_email_sends_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_email_sends_updated_at
  BEFORE UPDATE ON email_sends
  FOR EACH ROW
  EXECUTE FUNCTION update_email_sends_updated_at();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on both tables
ALTER TABLE email_sends ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_events ENABLE ROW LEVEL SECURITY;

-- Policy: Allow service role full access
CREATE POLICY "Service role has full access to email_sends"
  ON email_sends
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Service role has full access to email_events"
  ON email_events
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Policy: Authenticated users can read all email analytics (for dashboard)
CREATE POLICY "Authenticated users can read email_sends"
  ON email_sends
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can read email_events"
  ON email_events
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy: Allow anonymous access for tracking pixel (read tracking_id only)
-- This is required for the tracking pixel to work
CREATE POLICY "Anonymous can read tracking for events"
  ON email_sends
  FOR SELECT
  TO anon
  USING (tracking_id IS NOT NULL);

-- Policy: Anonymous can insert events (for tracking)
CREATE POLICY "Anonymous can insert email events"
  ON email_events
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- ============================================================================
-- GRANT PERMISSIONS
-- ============================================================================

-- Grant necessary permissions
GRANT SELECT ON email_sends TO authenticated;
GRANT SELECT ON email_events TO authenticated;
GRANT SELECT ON email_sends TO anon;
GRANT INSERT ON email_events TO anon;

GRANT SELECT ON email_analytics_summary TO authenticated;

-- ============================================================================
-- INITIAL DATA / HELPER FUNCTIONS
-- ============================================================================

-- Function to generate tracking ID
CREATE OR REPLACE FUNCTION generate_email_tracking_id()
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  tracking_id TEXT;
BEGIN
  -- Generate a URL-safe random tracking ID
  tracking_id := encode(gen_random_bytes(16), 'base64');
  tracking_id := replace(tracking_id, '+', '-');
  tracking_id := replace(tracking_id, '/', '_');
  tracking_id := replace(tracking_id, '=', '');
  RETURN tracking_id;
END;
$$;

COMMENT ON FUNCTION generate_email_tracking_id IS 'Generates a unique URL-safe tracking ID for emails';

-- ============================================================================
-- VALIDATION & CONSTRAINTS
-- ============================================================================

-- Add check constraints
ALTER TABLE email_sends
  ADD CONSTRAINT check_email_sends_delivery_status
  CHECK (delivery_status IN ('sent', 'delivered', 'bounced', 'failed', 'deferred'));

ALTER TABLE email_events
  ADD CONSTRAINT check_email_events_event_type
  CHECK (event_type IN ('open', 'click', 'bounce', 'spam_report', 'unsubscribe', 'delivered'));

ALTER TABLE email_events
  ADD CONSTRAINT check_email_events_device_type
  CHECK (device_type IS NULL OR device_type IN ('desktop', 'mobile', 'tablet', 'unknown'));

-- Add email validation (basic check)
ALTER TABLE email_sends
  ADD CONSTRAINT check_email_sends_recipient_email
  CHECK (recipient_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$');

-- ============================================================================
-- CLEANUP FUNCTION
-- ============================================================================

-- Function to clean up old tracking data (for GDPR compliance)
CREATE OR REPLACE FUNCTION cleanup_old_email_tracking_data(days_to_keep INTEGER DEFAULT 365)
RETURNS TABLE (
  deleted_sends INTEGER,
  deleted_events INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_deleted_sends INTEGER;
  v_deleted_events INTEGER;
  v_cutoff_date TIMESTAMPTZ;
BEGIN
  v_cutoff_date := NOW() - (days_to_keep || ' days')::INTERVAL;

  -- Delete old events first (due to foreign key)
  DELETE FROM email_events
  WHERE created_at < v_cutoff_date;
  GET DIAGNOSTICS v_deleted_events = ROW_COUNT;

  -- Delete old sends
  DELETE FROM email_sends
  WHERE sent_at < v_cutoff_date;
  GET DIAGNOSTICS v_deleted_sends = ROW_COUNT;

  RETURN QUERY SELECT v_deleted_sends, v_deleted_events;
END;
$$;

COMMENT ON FUNCTION cleanup_old_email_tracking_data IS 'Deletes email tracking data older than specified days (default 365)';

-- ============================================================================
-- ANALYTICS HELPER FUNCTIONS
-- ============================================================================

-- Function to get email performance by type
CREATE OR REPLACE FUNCTION get_email_performance_by_type(
  p_email_type TEXT DEFAULT NULL,
  p_days_back INTEGER DEFAULT 30
)
RETURNS TABLE (
  email_type TEXT,
  total_sent BIGINT,
  total_opened BIGINT,
  total_clicked BIGINT,
  open_rate DECIMAL,
  click_rate DECIMAL,
  click_to_open_rate DECIMAL
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
  RETURN QUERY
  SELECT
    es.email_type,
    COUNT(DISTINCT es.id) as total_sent,
    COUNT(DISTINCT CASE WHEN ee_open.email_send_id IS NOT NULL THEN es.id END) as total_opened,
    COUNT(DISTINCT CASE WHEN ee_click.email_send_id IS NOT NULL THEN es.id END) as total_clicked,

    CASE
      WHEN COUNT(DISTINCT es.id) > 0
      THEN ROUND(COUNT(DISTINCT CASE WHEN ee_open.email_send_id IS NOT NULL THEN es.id END)::DECIMAL / COUNT(DISTINCT es.id) * 100, 2)
      ELSE 0
    END as open_rate,

    CASE
      WHEN COUNT(DISTINCT es.id) > 0
      THEN ROUND(COUNT(DISTINCT CASE WHEN ee_click.email_send_id IS NOT NULL THEN es.id END)::DECIMAL / COUNT(DISTINCT es.id) * 100, 2)
      ELSE 0
    END as click_rate,

    CASE
      WHEN COUNT(DISTINCT CASE WHEN ee_open.email_send_id IS NOT NULL THEN es.id END) > 0
      THEN ROUND(COUNT(DISTINCT CASE WHEN ee_click.email_send_id IS NOT NULL THEN es.id END)::DECIMAL /
           COUNT(DISTINCT CASE WHEN ee_open.email_send_id IS NOT NULL THEN es.id END) * 100, 2)
      ELSE 0
    END as click_to_open_rate

  FROM email_sends es
  LEFT JOIN (
    SELECT DISTINCT email_send_id
    FROM email_events
    WHERE event_type = 'open'
  ) ee_open ON es.id = ee_open.email_send_id
  LEFT JOIN (
    SELECT DISTINCT email_send_id
    FROM email_events
    WHERE event_type = 'click'
  ) ee_click ON es.id = ee_click.email_send_id

  WHERE
    es.sent_at >= NOW() - (p_days_back || ' days')::INTERVAL
    AND (p_email_type IS NULL OR es.email_type = p_email_type)

  GROUP BY es.email_type;
END;
$$;

COMMENT ON FUNCTION get_email_performance_by_type IS 'Returns email performance metrics grouped by email type';

-- ============================================================================
-- COMPLETION
-- ============================================================================

-- Add a record to track migration
DO $$
BEGIN
  RAISE NOTICE 'Email tracking system migration completed successfully';
  RAISE NOTICE 'Tables created: email_sends, email_events';
  RAISE NOTICE 'Materialized view created: email_analytics_summary';
  RAISE NOTICE 'Remember to schedule periodic refresh of email_analytics_summary';
END;
$$;
