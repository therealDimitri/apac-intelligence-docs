-- BURC Alert Types Migration V2
-- Fix: Add missing columns to existing burc_alert_thresholds table

-- Add missing columns if they don't exist
DO $$
BEGIN
  -- NRR Thresholds
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_thresholds' AND column_name = 'nrr_decline_threshold') THEN
    ALTER TABLE burc_alert_thresholds ADD COLUMN nrr_decline_threshold DECIMAL(5,2) DEFAULT 5.0;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_thresholds' AND column_name = 'nrr_critical_level') THEN
    ALTER TABLE burc_alert_thresholds ADD COLUMN nrr_critical_level DECIMAL(5,2) DEFAULT 90.0;
  END IF;

  -- Renewal Risk Thresholds
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_thresholds' AND column_name = 'renewal_days_warning') THEN
    ALTER TABLE burc_alert_thresholds ADD COLUMN renewal_days_warning INTEGER DEFAULT 90;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_thresholds' AND column_name = 'renewal_days_critical') THEN
    ALTER TABLE burc_alert_thresholds ADD COLUMN renewal_days_critical INTEGER DEFAULT 60;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_thresholds' AND column_name = 'renewal_low_engagement_meetings') THEN
    ALTER TABLE burc_alert_thresholds ADD COLUMN renewal_low_engagement_meetings INTEGER DEFAULT 2;
  END IF;

  -- Pipeline Thresholds
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_thresholds' AND column_name = 'pipeline_coverage_minimum') THEN
    ALTER TABLE burc_alert_thresholds ADD COLUMN pipeline_coverage_minimum DECIMAL(5,2) DEFAULT 3.0;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_thresholds' AND column_name = 'pipeline_coverage_warning') THEN
    ALTER TABLE burc_alert_thresholds ADD COLUMN pipeline_coverage_warning DECIMAL(5,2) DEFAULT 2.0;
  END IF;

  -- Revenue Concentration Thresholds
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_thresholds' AND column_name = 'top_clients_count') THEN
    ALTER TABLE burc_alert_thresholds ADD COLUMN top_clients_count INTEGER DEFAULT 3;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_thresholds' AND column_name = 'concentration_critical') THEN
    ALTER TABLE burc_alert_thresholds ADD COLUMN concentration_critical DECIMAL(5,2) DEFAULT 40.0;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_thresholds' AND column_name = 'concentration_warning') THEN
    ALTER TABLE burc_alert_thresholds ADD COLUMN concentration_warning DECIMAL(5,2) DEFAULT 30.0;
  END IF;

  -- Collections Thresholds
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_thresholds' AND column_name = 'aging_amount_critical') THEN
    ALTER TABLE burc_alert_thresholds ADD COLUMN aging_amount_critical DECIMAL(12,2) DEFAULT 100000.00;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_thresholds' AND column_name = 'aging_days_critical') THEN
    ALTER TABLE burc_alert_thresholds ADD COLUMN aging_days_critical INTEGER DEFAULT 90;
  END IF;

  -- Churn Prediction Thresholds
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_thresholds' AND column_name = 'churn_score_critical') THEN
    ALTER TABLE burc_alert_thresholds ADD COLUMN churn_score_critical DECIMAL(5,2) DEFAULT 70.0;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_thresholds' AND column_name = 'churn_score_warning') THEN
    ALTER TABLE burc_alert_thresholds ADD COLUMN churn_score_warning DECIMAL(5,2) DEFAULT 50.0;
  END IF;

  -- PS Margin Thresholds
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_thresholds' AND column_name = 'ps_margin_critical') THEN
    ALTER TABLE burc_alert_thresholds ADD COLUMN ps_margin_critical DECIMAL(5,2) DEFAULT 15.0;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_thresholds' AND column_name = 'ps_margin_warning') THEN
    ALTER TABLE burc_alert_thresholds ADD COLUMN ps_margin_warning DECIMAL(5,2) DEFAULT 20.0;
  END IF;

  RAISE NOTICE 'Added missing columns to burc_alert_thresholds';
END $$;

-- Add missing columns to burc_alert_history if table exists with old schema
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'burc_alert_history') THEN
    -- Add detection_date if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_history' AND column_name = 'detection_date') THEN
      ALTER TABLE burc_alert_history ADD COLUMN detection_date DATE;
    END IF;
    -- Add count columns if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_history' AND column_name = 'nrr_decline_count') THEN
      ALTER TABLE burc_alert_history ADD COLUMN nrr_decline_count INTEGER DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_history' AND column_name = 'renewal_risk_count') THEN
      ALTER TABLE burc_alert_history ADD COLUMN renewal_risk_count INTEGER DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_history' AND column_name = 'pipeline_gap_count') THEN
      ALTER TABLE burc_alert_history ADD COLUMN pipeline_gap_count INTEGER DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_history' AND column_name = 'total_alerts') THEN
      ALTER TABLE burc_alert_history ADD COLUMN total_alerts INTEGER DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'burc_alert_history' AND column_name = 'alerts_acknowledged') THEN
      ALTER TABLE burc_alert_history ADD COLUMN alerts_acknowledged INTEGER DEFAULT 0;
    END IF;
    RAISE NOTICE 'Added columns to existing burc_alert_history table';
  ELSE
    CREATE TABLE burc_alert_history (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      detection_date DATE,
      nrr_decline_count INTEGER DEFAULT 0,
      renewal_risk_count INTEGER DEFAULT 0,
      pipeline_gap_count INTEGER DEFAULT 0,
      revenue_concentration_count INTEGER DEFAULT 0,
      collections_aging_count INTEGER DEFAULT 0,
      churn_prediction_count INTEGER DEFAULT 0,
      ps_margin_erosion_count INTEGER DEFAULT 0,
      critical_count INTEGER DEFAULT 0,
      high_count INTEGER DEFAULT 0,
      medium_count INTEGER DEFAULT 0,
      low_count INTEGER DEFAULT 0,
      total_alerts INTEGER DEFAULT 0,
      alerts_acknowledged INTEGER DEFAULT 0,
      alerts_dismissed INTEGER DEFAULT 0,
      alerts_resolved INTEGER DEFAULT 0,
      actions_created INTEGER DEFAULT 0,
      created_at TIMESTAMPTZ DEFAULT NOW()
    );
    RAISE NOTICE 'Created new burc_alert_history table';
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_burc_alert_history_date ON burc_alert_history(detection_date DESC);

-- Create user_alert_preferences if not exists
CREATE TABLE IF NOT EXISTS user_alert_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    user_email TEXT NOT NULL,
    receive_burc_alerts BOOLEAN DEFAULT true,
    receive_nrr_alerts BOOLEAN DEFAULT true,
    receive_renewal_alerts BOOLEAN DEFAULT true,
    receive_pipeline_alerts BOOLEAN DEFAULT true,
    receive_concentration_alerts BOOLEAN DEFAULT true,
    receive_collections_alerts BOOLEAN DEFAULT true,
    receive_ps_margin_alerts BOOLEAN DEFAULT true,
    email_notifications BOOLEAN DEFAULT true,
    in_app_notifications BOOLEAN DEFAULT true,
    severity_threshold TEXT DEFAULT 'high',
    daily_digest BOOLEAN DEFAULT false,
    weekly_digest BOOLEAN DEFAULT true,
    digest_day TEXT DEFAULT 'monday',
    digest_time TIME DEFAULT '08:00:00',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

CREATE INDEX IF NOT EXISTS idx_user_alert_prefs_email ON user_alert_preferences(user_email);

-- Create alert_acknowledgments if not exists
CREATE TABLE IF NOT EXISTS alert_acknowledgments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_id UUID NOT NULL,
    acknowledged_by TEXT NOT NULL,
    acknowledged_by_email TEXT,
    acknowledged_at TIMESTAMPTZ DEFAULT NOW(),
    action_taken TEXT,
    notes TEXT,
    follow_up_required BOOLEAN DEFAULT false,
    follow_up_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_alert_ack_alert_id ON alert_acknowledgments(alert_id);
CREATE INDEX IF NOT EXISTS idx_alert_ack_date ON alert_acknowledgments(acknowledged_at DESC);

SELECT 'BURC alert types v2 migration completed' AS status;
