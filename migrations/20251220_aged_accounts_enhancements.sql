-- =====================================================
-- Aged Accounts Enhancements Migration
-- Created: 2025-12-20
-- Description: Creates tables for webhook integration,
--              historical tracking, CSE suggestions,
--              and email alerts
-- =====================================================

-- =====================================================
-- 1. AGED ACCOUNTS HISTORY TABLE
-- For tracking historical trend data
-- =====================================================

CREATE TABLE IF NOT EXISTS aged_accounts_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  snapshot_date DATE NOT NULL,

  -- Aging buckets (amounts in dollars)
  bucket_0_30 DECIMAL(12,2) DEFAULT 0,
  bucket_31_60 DECIMAL(12,2) DEFAULT 0,
  bucket_61_90 DECIMAL(12,2) DEFAULT 0,
  bucket_90_plus DECIMAL(12,2) DEFAULT 0,
  total_outstanding DECIMAL(12,2) DEFAULT 0,

  -- Compliance metrics (percentages)
  compliance_under_60 DECIMAL(5,2),
  compliance_under_90 DECIMAL(5,2),

  -- Goals at time of snapshot
  goal_under_60 DECIMAL(5,2) DEFAULT 90.00,
  goal_under_90 DECIMAL(5,2) DEFAULT 100.00,

  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- Prevent duplicate snapshots for same client/date
  UNIQUE(client_name, snapshot_date)
);

-- Indexes for aged_accounts_history
CREATE INDEX IF NOT EXISTS idx_aged_history_client
  ON aged_accounts_history(client_name);
CREATE INDEX IF NOT EXISTS idx_aged_history_date
  ON aged_accounts_history(snapshot_date DESC);
CREATE INDEX IF NOT EXISTS idx_aged_history_client_date
  ON aged_accounts_history(client_name, snapshot_date DESC);

-- Enable RLS
ALTER TABLE aged_accounts_history ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read
CREATE POLICY "Allow authenticated read aged_accounts_history"
  ON aged_accounts_history FOR SELECT
  TO authenticated
  USING (true);

-- Allow service role to insert
CREATE POLICY "Allow service role insert aged_accounts_history"
  ON aged_accounts_history FOR INSERT
  TO service_role
  WITH CHECK (true);


-- =====================================================
-- 2. WEBHOOK SUBSCRIPTIONS TABLE
-- For outbound webhook management
-- =====================================================

CREATE TABLE IF NOT EXISTS webhook_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  url TEXT NOT NULL,

  -- Events to subscribe to
  events TEXT[] NOT NULL DEFAULT ARRAY['threshold.warning', 'threshold.critical'],

  -- Security
  secret TEXT NOT NULL,

  -- Status
  is_active BOOLEAN DEFAULT TRUE,

  -- Metadata
  created_by TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Tracking
  last_triggered_at TIMESTAMPTZ,
  failure_count INTEGER DEFAULT 0,
  last_error TEXT
);

-- Indexes for webhook_subscriptions
CREATE INDEX IF NOT EXISTS idx_webhook_subs_active
  ON webhook_subscriptions(is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_webhook_subs_events
  ON webhook_subscriptions USING GIN(events);

-- Enable RLS
ALTER TABLE webhook_subscriptions ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to manage webhooks
CREATE POLICY "Allow authenticated read webhook_subscriptions"
  ON webhook_subscriptions FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated insert webhook_subscriptions"
  ON webhook_subscriptions FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow authenticated update webhook_subscriptions"
  ON webhook_subscriptions FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated delete webhook_subscriptions"
  ON webhook_subscriptions FOR DELETE
  TO authenticated
  USING (true);


-- =====================================================
-- 3. AGING ALERT CONFIG TABLE
-- For configurable threshold alerts
-- =====================================================

CREATE TABLE IF NOT EXISTS aging_alert_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,

  -- Threshold settings
  threshold_type TEXT NOT NULL CHECK (threshold_type IN ('under_60', 'under_90')),
  threshold_value DECIMAL(5,2) NOT NULL,

  -- Severity
  severity TEXT NOT NULL CHECK (severity IN ('warning', 'critical')),

  -- Recipients (array of email addresses)
  recipients TEXT[] NOT NULL,

  -- Status
  is_active BOOLEAN DEFAULT TRUE,

  -- Cooldown to prevent alert spam (in hours)
  cooldown_hours INTEGER DEFAULT 24,

  -- Tracking
  last_triggered_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE aging_alert_config ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to manage alert configs
CREATE POLICY "Allow authenticated read aging_alert_config"
  ON aging_alert_config FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated insert aging_alert_config"
  ON aging_alert_config FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow authenticated update aging_alert_config"
  ON aging_alert_config FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated delete aging_alert_config"
  ON aging_alert_config FOR DELETE
  TO authenticated
  USING (true);

-- Insert default configurations
INSERT INTO aging_alert_config (name, threshold_type, threshold_value, severity, recipients)
VALUES
  ('Warning - Under 60 Days Below 90%', 'under_60', 90.00, 'warning', ARRAY['cse-team@altera.com']),
  ('Critical - Under 90 Days Below 100%', 'under_90', 100.00, 'critical', ARRAY['cse-leads@altera.com', 'management@altera.com'])
ON CONFLICT DO NOTHING;


-- =====================================================
-- 4. AGING ALERTS LOG TABLE
-- For tracking sent alerts (audit trail)
-- =====================================================

CREATE TABLE IF NOT EXISTS aging_alerts_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Reference to config
  config_id UUID REFERENCES aging_alert_config(id) ON DELETE SET NULL,

  -- Alert details
  client_name TEXT NOT NULL,
  threshold_type TEXT NOT NULL,
  threshold_value DECIMAL(5,2) NOT NULL,
  actual_value DECIMAL(5,2) NOT NULL,
  severity TEXT NOT NULL,

  -- Recipients at time of alert
  recipients TEXT[] NOT NULL,

  -- Delivery status
  email_sent BOOLEAN DEFAULT FALSE,
  webhook_sent BOOLEAN DEFAULT FALSE,

  -- Error tracking
  error_message TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for aging_alerts_log
CREATE INDEX IF NOT EXISTS idx_alerts_log_client
  ON aging_alerts_log(client_name);
CREATE INDEX IF NOT EXISTS idx_alerts_log_created
  ON aging_alerts_log(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_alerts_log_config
  ON aging_alerts_log(config_id);

-- Enable RLS
ALTER TABLE aging_alerts_log ENABLE ROW LEVEL SECURITY;

-- Allow authenticated read
CREATE POLICY "Allow authenticated read aging_alerts_log"
  ON aging_alerts_log FOR SELECT
  TO authenticated
  USING (true);

-- Allow service role to insert
CREATE POLICY "Allow service role insert aging_alerts_log"
  ON aging_alerts_log FOR INSERT
  TO service_role
  WITH CHECK (true);


-- =====================================================
-- 5. CSE ASSIGNMENT SUGGESTIONS TABLE
-- For automated CSE assignment recommendations
-- =====================================================

CREATE TABLE IF NOT EXISTS cse_assignment_suggestions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Client being suggested for
  client_name TEXT NOT NULL,

  -- Suggested CSE
  suggested_cse_email TEXT NOT NULL,
  suggested_cse_name TEXT,

  -- Reasoning
  reason TEXT NOT NULL,

  -- Confidence score (0.00 to 1.00)
  confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),

  -- Factors that contributed to the suggestion
  factors JSONB DEFAULT '{}'::jsonb,

  -- Status workflow
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'expired')),

  -- Review tracking
  reviewed_at TIMESTAMPTZ,
  reviewed_by TEXT,

  -- Action created when accepted
  action_id TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for cse_assignment_suggestions
CREATE INDEX IF NOT EXISTS idx_cse_suggestions_client
  ON cse_assignment_suggestions(client_name);
CREATE INDEX IF NOT EXISTS idx_cse_suggestions_status
  ON cse_assignment_suggestions(status) WHERE status = 'pending';
CREATE INDEX IF NOT EXISTS idx_cse_suggestions_cse
  ON cse_assignment_suggestions(suggested_cse_email);

-- Enable RLS
ALTER TABLE cse_assignment_suggestions ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to manage suggestions
CREATE POLICY "Allow authenticated read cse_assignment_suggestions"
  ON cse_assignment_suggestions FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated insert cse_assignment_suggestions"
  ON cse_assignment_suggestions FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow authenticated update cse_assignment_suggestions"
  ON cse_assignment_suggestions FOR UPDATE
  TO authenticated
  USING (true);


-- =====================================================
-- 6. HELPER FUNCTION: Capture Aged Accounts Snapshot
-- Call this daily via cron job
-- =====================================================

CREATE OR REPLACE FUNCTION capture_aged_accounts_snapshot()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  records_inserted INTEGER := 0;
  today DATE := CURRENT_DATE;
BEGIN
  -- Insert snapshot for all clients from aged_accounts
  INSERT INTO aged_accounts_history (
    client_name,
    snapshot_date,
    bucket_0_30,
    bucket_31_60,
    bucket_61_90,
    bucket_90_plus,
    total_outstanding,
    compliance_under_60,
    compliance_under_90
  )
  SELECT
    aa.client_name,
    today,
    COALESCE(aa.bucket_0_30, 0),
    COALESCE(aa.bucket_31_60, 0),
    COALESCE(aa.bucket_61_90, 0),
    COALESCE(aa.bucket_90_plus, 0),
    COALESCE(aa.total_outstanding, 0),
    -- Calculate compliance percentages
    CASE
      WHEN COALESCE(aa.total_outstanding, 0) > 0
      THEN ROUND(
        (COALESCE(aa.bucket_0_30, 0) + COALESCE(aa.bucket_31_60, 0)) /
        COALESCE(aa.total_outstanding, 1) * 100,
        2
      )
      ELSE 100.00
    END AS compliance_under_60,
    CASE
      WHEN COALESCE(aa.total_outstanding, 0) > 0
      THEN ROUND(
        (COALESCE(aa.bucket_0_30, 0) + COALESCE(aa.bucket_31_60, 0) + COALESCE(aa.bucket_61_90, 0)) /
        COALESCE(aa.total_outstanding, 1) * 100,
        2
      )
      ELSE 100.00
    END AS compliance_under_90
  FROM aged_accounts aa
  WHERE aa.client_name IS NOT NULL
  ON CONFLICT (client_name, snapshot_date)
  DO UPDATE SET
    bucket_0_30 = EXCLUDED.bucket_0_30,
    bucket_31_60 = EXCLUDED.bucket_31_60,
    bucket_61_90 = EXCLUDED.bucket_61_90,
    bucket_90_plus = EXCLUDED.bucket_90_plus,
    total_outstanding = EXCLUDED.total_outstanding,
    compliance_under_60 = EXCLUDED.compliance_under_60,
    compliance_under_90 = EXCLUDED.compliance_under_90;

  GET DIAGNOSTICS records_inserted = ROW_COUNT;

  RETURN records_inserted;
END;
$$;

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION capture_aged_accounts_snapshot() TO authenticated;
GRANT EXECUTE ON FUNCTION capture_aged_accounts_snapshot() TO service_role;


-- =====================================================
-- 7. HELPER FUNCTION: Check Threshold Breaches
-- Returns clients that breach configured thresholds
-- =====================================================

CREATE OR REPLACE FUNCTION check_aging_threshold_breaches()
RETURNS TABLE (
  config_id UUID,
  config_name TEXT,
  threshold_type TEXT,
  threshold_value DECIMAL(5,2),
  severity TEXT,
  recipients TEXT[],
  client_name TEXT,
  actual_value DECIMAL(5,2),
  breached BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    aac.id AS config_id,
    aac.name AS config_name,
    aac.threshold_type,
    aac.threshold_value,
    aac.severity,
    aac.recipients,
    aa.client_name,
    CASE
      WHEN aac.threshold_type = 'under_60' THEN
        CASE
          WHEN COALESCE(aa.total_outstanding, 0) > 0
          THEN ROUND(
            (COALESCE(aa.bucket_0_30, 0) + COALESCE(aa.bucket_31_60, 0)) /
            COALESCE(aa.total_outstanding, 1) * 100,
            2
          )
          ELSE 100.00
        END
      WHEN aac.threshold_type = 'under_90' THEN
        CASE
          WHEN COALESCE(aa.total_outstanding, 0) > 0
          THEN ROUND(
            (COALESCE(aa.bucket_0_30, 0) + COALESCE(aa.bucket_31_60, 0) + COALESCE(aa.bucket_61_90, 0)) /
            COALESCE(aa.total_outstanding, 1) * 100,
            2
          )
          ELSE 100.00
        END
    END AS actual_value,
    CASE
      WHEN aac.threshold_type = 'under_60' THEN
        CASE
          WHEN COALESCE(aa.total_outstanding, 0) > 0
          THEN ROUND(
            (COALESCE(aa.bucket_0_30, 0) + COALESCE(aa.bucket_31_60, 0)) /
            COALESCE(aa.total_outstanding, 1) * 100,
            2
          ) < aac.threshold_value
          ELSE FALSE
        END
      WHEN aac.threshold_type = 'under_90' THEN
        CASE
          WHEN COALESCE(aa.total_outstanding, 0) > 0
          THEN ROUND(
            (COALESCE(aa.bucket_0_30, 0) + COALESCE(aa.bucket_31_60, 0) + COALESCE(aa.bucket_61_90, 0)) /
            COALESCE(aa.total_outstanding, 1) * 100,
            2
          ) < aac.threshold_value
          ELSE FALSE
        END
    END AS breached
  FROM aging_alert_config aac
  CROSS JOIN aged_accounts aa
  WHERE aac.is_active = TRUE
    AND aa.client_name IS NOT NULL
    AND aa.total_outstanding > 0;
END;
$$;

-- Grant execute
GRANT EXECUTE ON FUNCTION check_aging_threshold_breaches() TO authenticated;
GRANT EXECUTE ON FUNCTION check_aging_threshold_breaches() TO service_role;


-- =====================================================
-- VERIFICATION
-- =====================================================

-- Check tables were created
DO $$
BEGIN
  RAISE NOTICE 'Aged Accounts Enhancement Migration Complete!';
  RAISE NOTICE 'Tables created:';
  RAISE NOTICE '  - aged_accounts_history';
  RAISE NOTICE '  - webhook_subscriptions';
  RAISE NOTICE '  - aging_alert_config';
  RAISE NOTICE '  - aging_alerts_log';
  RAISE NOTICE '  - cse_assignment_suggestions';
  RAISE NOTICE 'Functions created:';
  RAISE NOTICE '  - capture_aged_accounts_snapshot()';
  RAISE NOTICE '  - check_aging_threshold_breaches()';
END $$;
