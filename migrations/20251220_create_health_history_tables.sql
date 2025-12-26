-- Migration: Create Health History Tables
-- Date: 2024-12-20
-- Purpose: Enable historical tracking of client health scores with daily snapshots and status change alerts
--
-- Tables Created:
--   1. client_health_history - Daily snapshots of health scores
--   2. health_status_alerts - Alerts when client status changes
--
-- Function Created:
--   capture_health_snapshot() - Daily snapshot function (call via cron or API)

-- ============================================================================
-- TABLE 1: client_health_history
-- Stores daily snapshots of each client's health score and component breakdown
-- ============================================================================

CREATE TABLE IF NOT EXISTS client_health_history (
  id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name                 TEXT NOT NULL,
  snapshot_date               DATE NOT NULL,

  -- Core health score (0-100)
  health_score                INTEGER NOT NULL CHECK (health_score >= 0 AND health_score <= 100),
  status                      TEXT NOT NULL CHECK (status IN ('healthy', 'at-risk', 'critical')),

  -- Component points breakdown (for trend analysis per component)
  nps_points                  INTEGER CHECK (nps_points >= 0 AND nps_points <= 40),
  compliance_points           INTEGER CHECK (compliance_points >= 0 AND compliance_points <= 50),
  working_capital_points      INTEGER CHECK (working_capital_points >= 0 AND working_capital_points <= 10),

  -- Raw component values (for reference/recalculation)
  nps_score                   NUMERIC,
  compliance_percentage       NUMERIC,
  working_capital_percentage  NUMERIC,

  -- Status change tracking
  previous_status             TEXT CHECK (previous_status IN ('healthy', 'at-risk', 'critical') OR previous_status IS NULL),
  status_changed              BOOLEAN DEFAULT FALSE,

  -- Metadata
  created_at                  TIMESTAMPTZ DEFAULT NOW(),

  -- Ensure one snapshot per client per day
  CONSTRAINT unique_client_snapshot_date UNIQUE (client_name, snapshot_date)
);

-- Indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_health_history_client
  ON client_health_history(client_name);

CREATE INDEX IF NOT EXISTS idx_health_history_date
  ON client_health_history(snapshot_date DESC);

CREATE INDEX IF NOT EXISTS idx_health_history_client_date
  ON client_health_history(client_name, snapshot_date DESC);

CREATE INDEX IF NOT EXISTS idx_health_history_status_changed
  ON client_health_history(status_changed)
  WHERE status_changed = TRUE;

-- RLS policies
ALTER TABLE client_health_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access for all users"
  ON client_health_history
  FOR SELECT
  USING (true);

CREATE POLICY "Allow insert for service role"
  ON client_health_history
  FOR INSERT
  WITH CHECK (true);

-- Grant permissions
GRANT SELECT ON client_health_history TO anon, authenticated;
GRANT INSERT, UPDATE ON client_health_history TO service_role;

COMMENT ON TABLE client_health_history IS 'Daily snapshots of client health scores for historical trend analysis';
COMMENT ON COLUMN client_health_history.health_score IS 'Total health score (0-100) calculated from NPS + Compliance + Working Capital';
COMMENT ON COLUMN client_health_history.status IS 'Health status: healthy (>=70), at-risk (60-69), critical (<60)';
COMMENT ON COLUMN client_health_history.status_changed IS 'TRUE if status changed from previous snapshot';

-- ============================================================================
-- TABLE 2: health_status_alerts
-- Tracks alerts when a client's health status changes category
-- ============================================================================

CREATE TABLE IF NOT EXISTS health_status_alerts (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name       TEXT NOT NULL,
  alert_date        DATE NOT NULL,

  -- Status change details
  previous_status   TEXT NOT NULL CHECK (previous_status IN ('healthy', 'at-risk', 'critical')),
  new_status        TEXT NOT NULL CHECK (new_status IN ('healthy', 'at-risk', 'critical')),
  previous_score    INTEGER NOT NULL,
  new_score         INTEGER NOT NULL,

  -- Change direction for filtering
  direction         TEXT NOT NULL CHECK (direction IN ('improved', 'declined')),

  -- Alert handling
  acknowledged      BOOLEAN DEFAULT FALSE,
  acknowledged_by   TEXT,
  acknowledged_at   TIMESTAMPTZ,

  -- Assignment for notification routing
  cse_name          TEXT,

  -- Metadata
  created_at        TIMESTAMPTZ DEFAULT NOW(),

  -- One alert per client per day
  CONSTRAINT unique_alert_client_date UNIQUE (client_name, alert_date)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_health_alerts_unacknowledged
  ON health_status_alerts(acknowledged)
  WHERE acknowledged = FALSE;

CREATE INDEX IF NOT EXISTS idx_health_alerts_cse
  ON health_status_alerts(cse_name);

CREATE INDEX IF NOT EXISTS idx_health_alerts_date
  ON health_status_alerts(alert_date DESC);

CREATE INDEX IF NOT EXISTS idx_health_alerts_direction
  ON health_status_alerts(direction);

-- RLS policies
ALTER TABLE health_status_alerts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access for all users"
  ON health_status_alerts
  FOR SELECT
  USING (true);

CREATE POLICY "Allow modifications for authenticated users"
  ON health_status_alerts
  FOR ALL
  USING (true);

-- Grant permissions
GRANT SELECT, INSERT, UPDATE ON health_status_alerts TO anon, authenticated;
GRANT ALL ON health_status_alerts TO service_role;

COMMENT ON TABLE health_status_alerts IS 'Alerts generated when client health status changes (healthy/at-risk/critical)';
COMMENT ON COLUMN health_status_alerts.direction IS 'improved = score increased, declined = score decreased';

-- ============================================================================
-- FUNCTION: capture_health_snapshot
-- Called daily to snapshot all client health scores
-- ============================================================================

CREATE OR REPLACE FUNCTION capture_health_snapshot()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_today DATE := CURRENT_DATE;
  v_client RECORD;
  v_prev_record RECORD;
  v_status_changed BOOLEAN;
  v_inserted_count INTEGER := 0;
  v_alert_count INTEGER := 0;
  v_nps_points INTEGER;
  v_compliance_points INTEGER;
  v_working_capital_points INTEGER;
  v_health_score INTEGER;
  v_status TEXT;
BEGIN
  -- Refresh the materialized view first to ensure fresh data
  REFRESH MATERIALIZED VIEW CONCURRENTLY client_health_summary;

  -- Process each client from the health summary view
  FOR v_client IN
    SELECT
      client_name,
      nps_score,
      compliance_percentage,
      working_capital_percentage,
      cse
    FROM client_health_summary
  LOOP
    -- Calculate component points using the formula from health-score-config.ts
    -- NPS: ((nps + 100) / 200) * 40
    v_nps_points := ROUND(((COALESCE(v_client.nps_score, 0) + 100) / 200.0) * 40);

    -- Compliance: (compliance / 100) * 50, capped at 100%
    v_compliance_points := ROUND((LEAST(100, COALESCE(v_client.compliance_percentage, 50)) / 100.0) * 50);

    -- Working Capital: (percent_under_90 / 100) * 10
    -- Default to 100% if no data (no aging = no problem)
    v_working_capital_points := ROUND((LEAST(100, COALESCE(v_client.working_capital_percentage, 100)) / 100.0) * 10);

    -- Total health score
    v_health_score := v_nps_points + v_compliance_points + v_working_capital_points;

    -- Determine status based on thresholds
    v_status := CASE
      WHEN v_health_score >= 70 THEN 'healthy'
      WHEN v_health_score >= 60 THEN 'at-risk'
      ELSE 'critical'
    END;

    -- Get previous snapshot for change detection
    SELECT status, health_score
    INTO v_prev_record
    FROM client_health_history
    WHERE client_name = v_client.client_name
      AND snapshot_date < v_today
    ORDER BY snapshot_date DESC
    LIMIT 1;

    -- Determine if status changed
    v_status_changed := (v_prev_record.status IS NOT NULL AND v_prev_record.status != v_status);

    -- Insert the snapshot (upsert to handle re-runs)
    INSERT INTO client_health_history (
      client_name,
      snapshot_date,
      health_score,
      status,
      nps_points,
      compliance_points,
      working_capital_points,
      nps_score,
      compliance_percentage,
      working_capital_percentage,
      previous_status,
      status_changed
    ) VALUES (
      v_client.client_name,
      v_today,
      v_health_score,
      v_status,
      v_nps_points,
      v_compliance_points,
      v_working_capital_points,
      v_client.nps_score,
      v_client.compliance_percentage,
      v_client.working_capital_percentage,
      v_prev_record.status,
      v_status_changed
    )
    ON CONFLICT (client_name, snapshot_date)
    DO UPDATE SET
      health_score = EXCLUDED.health_score,
      status = EXCLUDED.status,
      nps_points = EXCLUDED.nps_points,
      compliance_points = EXCLUDED.compliance_points,
      working_capital_points = EXCLUDED.working_capital_points,
      nps_score = EXCLUDED.nps_score,
      compliance_percentage = EXCLUDED.compliance_percentage,
      working_capital_percentage = EXCLUDED.working_capital_percentage,
      previous_status = EXCLUDED.previous_status,
      status_changed = EXCLUDED.status_changed;

    v_inserted_count := v_inserted_count + 1;

    -- Create alert if status changed
    IF v_status_changed THEN
      INSERT INTO health_status_alerts (
        client_name,
        alert_date,
        previous_status,
        new_status,
        previous_score,
        new_score,
        direction,
        cse_name
      ) VALUES (
        v_client.client_name,
        v_today,
        v_prev_record.status,
        v_status,
        COALESCE(v_prev_record.health_score, 0),
        v_health_score,
        CASE
          WHEN v_health_score > COALESCE(v_prev_record.health_score, 0) THEN 'improved'
          ELSE 'declined'
        END,
        v_client.cse
      )
      ON CONFLICT (client_name, alert_date) DO NOTHING;

      v_alert_count := v_alert_count + 1;
    END IF;
  END LOOP;

  -- Return summary
  RETURN jsonb_build_object(
    'success', true,
    'snapshot_date', v_today,
    'clients_processed', v_inserted_count,
    'alerts_generated', v_alert_count,
    'timestamp', NOW()
  );
END;
$$;

COMMENT ON FUNCTION capture_health_snapshot IS 'Captures daily health score snapshots for all clients and generates alerts on status changes';

-- ============================================================================
-- GRANT EXECUTE permission on function
-- ============================================================================
GRANT EXECUTE ON FUNCTION capture_health_snapshot TO service_role;

-- ============================================================================
-- Initial data seed (optional - run manually to backfill from existing data)
-- ============================================================================
-- To seed initial data, run: SELECT capture_health_snapshot();
