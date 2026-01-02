-- ============================================================================
-- Migration: Alerts Table and Action Linking
-- Date: 2025-12-31
-- Purpose: Create persistent alerts table with auto-action creation support
-- ============================================================================

-- ============================================================================
-- 1. CREATE ALERTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_id TEXT UNIQUE NOT NULL,  -- Matches computed alert ID format

    -- Core Alert Data
    category TEXT NOT NULL CHECK (category IN (
        'health_decline', 'health_status_change', 'nps_risk',
        'compliance_risk', 'renewal_approaching', 'action_overdue',
        'attrition_risk', 'engagement_gap', 'servicing_issue'
    )),
    severity TEXT NOT NULL CHECK (severity IN ('critical', 'high', 'medium', 'low')),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'acknowledged', 'resolved', 'dismissed')),

    -- Alert Content
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    recommendation TEXT,

    -- Client & CSE Reference
    client_name TEXT NOT NULL,
    client_id INTEGER REFERENCES clients(id),
    client_uuid TEXT,
    cse_name TEXT,
    cse_email TEXT,

    -- Alert Metrics
    current_value TEXT,
    previous_value TEXT,
    threshold_value TEXT,

    -- Metadata (JSONB for flexible additional data)
    metadata JSONB DEFAULT '{}'::jsonb,

    -- Action Tracking
    auto_action_created BOOLEAN DEFAULT FALSE,
    linked_action_id TEXT,  -- References actions.Action_ID

    -- Audit Fields
    detected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    acknowledged_at TIMESTAMPTZ,
    acknowledged_by TEXT,
    resolved_at TIMESTAMPTZ,
    resolved_by TEXT,
    dismissed_at TIMESTAMPTZ,
    dismissed_by TEXT,
    dismiss_reason TEXT,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for common queries
CREATE INDEX IF NOT EXISTS idx_alerts_status ON alerts(status);
CREATE INDEX IF NOT EXISTS idx_alerts_severity ON alerts(severity);
CREATE INDEX IF NOT EXISTS idx_alerts_category ON alerts(category);
CREATE INDEX IF NOT EXISTS idx_alerts_client_name ON alerts(client_name);
CREATE INDEX IF NOT EXISTS idx_alerts_cse_name ON alerts(cse_name);
CREATE INDEX IF NOT EXISTS idx_alerts_detected_at ON alerts(detected_at DESC);
CREATE INDEX IF NOT EXISTS idx_alerts_alert_id ON alerts(alert_id);

-- Composite index for dashboard queries
CREATE INDEX IF NOT EXISTS idx_alerts_status_severity ON alerts(status, severity);

-- ============================================================================
-- 2. ADD source_alert_id TO ACTIONS TABLE
-- ============================================================================

ALTER TABLE actions
ADD COLUMN IF NOT EXISTS source_alert_id UUID REFERENCES alerts(id);

ALTER TABLE actions
ADD COLUMN IF NOT EXISTS source_alert_text_id TEXT;  -- Stores alert_id string for reference

-- Index for finding actions created from alerts
CREATE INDEX IF NOT EXISTS idx_actions_source_alert ON actions(source_alert_id) WHERE source_alert_id IS NOT NULL;

-- ============================================================================
-- 3. CREATE ALERT DEDUPLICATION TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS alert_fingerprints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fingerprint TEXT UNIQUE NOT NULL,  -- Hash of category + client + key metrics
    alert_id UUID REFERENCES alerts(id),
    first_detected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_detected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    occurrence_count INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_alert_fingerprints_fingerprint ON alert_fingerprints(fingerprint);

-- ============================================================================
-- 4. RLS POLICIES
-- ============================================================================

-- Enable RLS
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE alert_fingerprints ENABLE ROW LEVEL SECURITY;

-- Policies for authenticated users
CREATE POLICY "alerts_select_policy" ON alerts FOR SELECT TO authenticated USING (true);
CREATE POLICY "alerts_insert_policy" ON alerts FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "alerts_update_policy" ON alerts FOR UPDATE TO authenticated USING (true);
CREATE POLICY "alerts_delete_policy" ON alerts FOR DELETE TO authenticated USING (true);

CREATE POLICY "alert_fingerprints_select_policy" ON alert_fingerprints FOR SELECT TO authenticated USING (true);
CREATE POLICY "alert_fingerprints_insert_policy" ON alert_fingerprints FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "alert_fingerprints_update_policy" ON alert_fingerprints FOR UPDATE TO authenticated USING (true);

-- Service role bypass
CREATE POLICY "alerts_service_role_all" ON alerts FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY "alert_fingerprints_service_role_all" ON alert_fingerprints FOR ALL TO service_role USING (true) WITH CHECK (true);

-- ============================================================================
-- 5. UPDATED_AT TRIGGER
-- ============================================================================

CREATE OR REPLACE FUNCTION update_alerts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS alerts_updated_at_trigger ON alerts;
CREATE TRIGGER alerts_updated_at_trigger
    BEFORE UPDATE ON alerts
    FOR EACH ROW
    EXECUTE FUNCTION update_alerts_updated_at();

-- ============================================================================
-- 6. AUTO-ACTION CREATION FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION create_action_from_alert(
    p_alert_id UUID,
    p_owner TEXT DEFAULT NULL
)
RETURNS TEXT AS $$
DECLARE
    v_alert RECORD;
    v_action_id TEXT;
    v_next_id INTEGER;
BEGIN
    -- Get alert data
    SELECT * INTO v_alert FROM alerts WHERE id = p_alert_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Alert not found: %', p_alert_id;
    END IF;

    -- Check if action already created
    IF v_alert.auto_action_created THEN
        RETURN v_alert.linked_action_id;
    END IF;

    -- Generate next action ID
    SELECT COALESCE(MAX(CAST(SUBSTRING(Action_ID FROM 2) AS INTEGER)), 0) + 1
    INTO v_next_id
    FROM actions;

    v_action_id := 'A' || LPAD(v_next_id::TEXT, 2, '0');

    -- Create the action
    INSERT INTO actions (
        Action_ID,
        Action_Description,
        Notes,
        client,
        Owners,
        Due_Date,
        Status,
        Priority,
        Category,
        source_alert_id,
        source_alert_text_id,
        source,
        source_metadata,
        created_at,
        updated_at
    ) VALUES (
        v_action_id,
        CASE v_alert.category
            WHEN 'health_decline' THEN 'Health Recovery: ' || v_alert.client_name
            WHEN 'nps_risk' THEN 'NPS Follow-up: ' || v_alert.client_name
            WHEN 'compliance_risk' THEN 'Compliance Recovery: ' || v_alert.client_name
            WHEN 'renewal_approaching' THEN 'Renewal Preparation: ' || v_alert.client_name
            WHEN 'attrition_risk' THEN 'Attrition Prevention: ' || v_alert.client_name
            ELSE 'Alert Action: ' || v_alert.client_name
        END,
        v_alert.description || E'\n\nRecommendation: ' || COALESCE(v_alert.recommendation, 'Review and take appropriate action.'),
        v_alert.client_name,
        COALESCE(p_owner, v_alert.cse_name, 'Unassigned'),
        TO_CHAR(NOW() + INTERVAL '7 days', 'DD/MM/YYYY'),
        'Open',
        CASE v_alert.severity
            WHEN 'critical' THEN 'Critical'
            WHEN 'high' THEN 'High'
            WHEN 'medium' THEN 'Medium'
            ELSE 'Low'
        END,
        CASE v_alert.category
            WHEN 'health_decline' THEN 'Health'
            WHEN 'nps_risk' THEN 'NPS'
            WHEN 'compliance_risk' THEN 'Compliance'
            WHEN 'renewal_approaching' THEN 'Renewal'
            ELSE 'Alert'
        END,
        p_alert_id,
        v_alert.alert_id,
        'Alert',
        jsonb_build_object(
            'alert_category', v_alert.category,
            'alert_severity', v_alert.severity,
            'current_value', v_alert.current_value,
            'threshold', v_alert.threshold_value
        ),
        NOW(),
        NOW()
    );

    -- Update alert to mark action created
    UPDATE alerts
    SET auto_action_created = TRUE,
        linked_action_id = v_action_id,
        updated_at = NOW()
    WHERE id = p_alert_id;

    RETURN v_action_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 7. ALERT FINGERPRINT GENERATION FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION generate_alert_fingerprint(
    p_category TEXT,
    p_client_name TEXT,
    p_current_value TEXT DEFAULT NULL
)
RETURNS TEXT AS $$
BEGIN
    -- Create a stable fingerprint for deduplication
    -- Alerts with same category + client + value are considered duplicates
    RETURN md5(
        p_category || '|' ||
        LOWER(TRIM(p_client_name)) || '|' ||
        COALESCE(p_current_value, '')
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- 8. UPSERT ALERT FUNCTION (with deduplication)
-- ============================================================================

CREATE OR REPLACE FUNCTION upsert_alert(
    p_alert_id TEXT,
    p_category TEXT,
    p_severity TEXT,
    p_title TEXT,
    p_description TEXT,
    p_client_name TEXT,
    p_cse_name TEXT DEFAULT NULL,
    p_current_value TEXT DEFAULT NULL,
    p_previous_value TEXT DEFAULT NULL,
    p_threshold_value TEXT DEFAULT NULL,
    p_recommendation TEXT DEFAULT NULL,
    p_metadata JSONB DEFAULT '{}'::jsonb,
    p_auto_create_action BOOLEAN DEFAULT FALSE
)
RETURNS TABLE(
    alert_uuid UUID,
    is_new BOOLEAN,
    action_id TEXT
) AS $$
DECLARE
    v_fingerprint TEXT;
    v_existing_fp RECORD;
    v_alert_uuid UUID;
    v_is_new BOOLEAN := FALSE;
    v_action_id TEXT := NULL;
BEGIN
    -- Generate fingerprint for deduplication
    v_fingerprint := generate_alert_fingerprint(p_category, p_client_name, p_current_value);

    -- Check for existing fingerprint
    SELECT * INTO v_existing_fp FROM alert_fingerprints WHERE fingerprint = v_fingerprint;

    IF FOUND THEN
        -- Update existing fingerprint occurrence
        UPDATE alert_fingerprints
        SET last_detected_at = NOW(),
            occurrence_count = occurrence_count + 1
        WHERE fingerprint = v_fingerprint;

        v_alert_uuid := v_existing_fp.alert_id;
        v_is_new := FALSE;

        -- Get linked action if exists
        SELECT linked_action_id INTO v_action_id FROM alerts WHERE id = v_alert_uuid;
    ELSE
        -- Create new alert
        INSERT INTO alerts (
            alert_id, category, severity, title, description,
            client_name, cse_name, current_value, previous_value,
            threshold_value, recommendation, metadata
        ) VALUES (
            p_alert_id, p_category, p_severity, p_title, p_description,
            p_client_name, p_cse_name, p_current_value, p_previous_value,
            p_threshold_value, p_recommendation, p_metadata
        )
        RETURNING id INTO v_alert_uuid;

        -- Create fingerprint record
        INSERT INTO alert_fingerprints (fingerprint, alert_id)
        VALUES (v_fingerprint, v_alert_uuid);

        v_is_new := TRUE;

        -- Auto-create action for critical alerts if requested
        IF p_auto_create_action AND p_severity = 'critical' THEN
            v_action_id := create_action_from_alert(v_alert_uuid, p_cse_name);
        END IF;
    END IF;

    RETURN QUERY SELECT v_alert_uuid, v_is_new, v_action_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 9. GRANT PERMISSIONS
-- ============================================================================

GRANT ALL ON alerts TO authenticated;
GRANT ALL ON alert_fingerprints TO authenticated;
GRANT EXECUTE ON FUNCTION create_action_from_alert TO authenticated;
GRANT EXECUTE ON FUNCTION generate_alert_fingerprint TO authenticated;
GRANT EXECUTE ON FUNCTION upsert_alert TO authenticated;
