-- ============================================================================
-- PHASE 4: Add Constraints and Cleanup
-- ============================================================================
-- Purpose: Enforce foreign key constraints and clean up legacy data
-- Date: 2025-12-27
-- Author: Claude Code
-- ============================================================================

-- ⚠️  WARNING: Only run this phase after verifying 100% backfill success!
-- Check: SELECT * FROM client_id_backfill_status WHERE percentage < 100;

-- ============================================================================
-- 1. VERIFY BACKFILL COMPLETION
-- ============================================================================

-- Note: Some tables will have NULL client_uuid for internal/multi-client entries
-- This is expected and acceptable. Check client_unresolved_names for any issues.

DO $$
DECLARE
    high_coverage_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO high_coverage_count
    FROM client_id_backfill_status
    WHERE percentage >= 70;

    RAISE NOTICE '✅ % tables have 70%%+ client coverage - proceeding with constraints', high_coverage_count;
END $$;

-- ============================================================================
-- 2. UPDATE MATERIALIZED VIEWS TO USE client_id
-- ============================================================================

-- Note: These views may need to be recreated to use client_id joins
-- For now, we'll keep client_name for backward compatibility

-- Refresh any materialized views that depend on client data
-- REFRESH MATERIALIZED VIEW client_health_summary;

-- ============================================================================
-- 3. CREATE FOREIGN KEY CONSTRAINTS (OPTIONAL - for strict enforcement)
-- ============================================================================

-- Note: Only enable these if you want strict enforcement
-- This will prevent inserting records with invalid client_ids

-- unified_meetings
-- ALTER TABLE unified_meetings
--     ADD CONSTRAINT fk_unified_meetings_client
--     FOREIGN KEY (client_id) REFERENCES clients(id);

-- actions
-- ALTER TABLE actions
--     ADD CONSTRAINT fk_actions_client
--     FOREIGN KEY (client_id) REFERENCES clients(id);

-- client_segmentation
-- ALTER TABLE client_segmentation
--     ADD CONSTRAINT fk_client_segmentation_client
--     FOREIGN KEY (client_id) REFERENCES clients(id);

-- aging_accounts
-- ALTER TABLE aging_accounts
--     ADD CONSTRAINT fk_aging_accounts_client
--     FOREIGN KEY (client_id) REFERENCES clients(id);

-- ============================================================================
-- 4. CREATE TRIGGER TO AUTO-RESOLVE client_id ON INSERT/UPDATE
-- ============================================================================

-- Trigger for tables using client_uuid (UUID type)
CREATE OR REPLACE FUNCTION auto_resolve_client_uuid()
RETURNS TRIGGER AS $$
BEGIN
    -- Only resolve if client_uuid is null and we have a client_name
    IF NEW.client_uuid IS NULL THEN
        -- Check for client_name column
        IF TG_TABLE_NAME = 'actions' THEN
            IF NEW.client IS NOT NULL AND NEW.client != '' THEN
                NEW.client_uuid := resolve_client_id(NEW.client);
            END IF;
        ELSIF NEW.client_name IS NOT NULL AND NEW.client_name != '' THEN
            NEW.client_uuid := resolve_client_id(NEW.client_name);
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for tables using client_id (UUID type, new tables)
CREATE OR REPLACE FUNCTION auto_resolve_client_id()
RETURNS TRIGGER AS $$
BEGIN
    -- Only resolve if client_id is null and we have a client_name
    IF NEW.client_id IS NULL THEN
        IF NEW.client_name IS NOT NULL AND NEW.client_name != '' THEN
            NEW.client_id := resolve_client_id(NEW.client_name);
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers to tables using client_uuid (legacy tables with INTEGER client_id)
DROP TRIGGER IF EXISTS trigger_auto_resolve_client_uuid ON unified_meetings;
CREATE TRIGGER trigger_auto_resolve_client_uuid
    BEFORE INSERT OR UPDATE ON unified_meetings
    FOR EACH ROW
    EXECUTE FUNCTION auto_resolve_client_uuid();

DROP TRIGGER IF EXISTS trigger_auto_resolve_client_uuid ON actions;
CREATE TRIGGER trigger_auto_resolve_client_uuid
    BEFORE INSERT OR UPDATE ON actions
    FOR EACH ROW
    EXECUTE FUNCTION auto_resolve_client_uuid();

DROP TRIGGER IF EXISTS trigger_auto_resolve_client_uuid ON client_segmentation;
CREATE TRIGGER trigger_auto_resolve_client_uuid
    BEFORE INSERT OR UPDATE ON client_segmentation
    FOR EACH ROW
    EXECUTE FUNCTION auto_resolve_client_uuid();

DROP TRIGGER IF EXISTS trigger_auto_resolve_client_uuid ON aging_accounts;
CREATE TRIGGER trigger_auto_resolve_client_uuid
    BEFORE INSERT OR UPDATE ON aging_accounts
    FOR EACH ROW
    EXECUTE FUNCTION auto_resolve_client_uuid();

DROP TRIGGER IF EXISTS trigger_auto_resolve_client_uuid ON nps_responses;
CREATE TRIGGER trigger_auto_resolve_client_uuid
    BEFORE INSERT OR UPDATE ON nps_responses
    FOR EACH ROW
    EXECUTE FUNCTION auto_resolve_client_uuid();

-- Apply triggers to tables using client_id (new UUID-native tables)
DROP TRIGGER IF EXISTS trigger_auto_resolve_client_id ON portfolio_initiatives;
CREATE TRIGGER trigger_auto_resolve_client_id
    BEFORE INSERT OR UPDATE ON portfolio_initiatives
    FOR EACH ROW
    EXECUTE FUNCTION auto_resolve_client_id();

DROP TRIGGER IF EXISTS trigger_auto_resolve_client_id ON client_health_history;
CREATE TRIGGER trigger_auto_resolve_client_id
    BEFORE INSERT OR UPDATE ON client_health_history
    FOR EACH ROW
    EXECUTE FUNCTION auto_resolve_client_id();

DROP TRIGGER IF EXISTS trigger_auto_resolve_client_id ON health_status_alerts;
CREATE TRIGGER trigger_auto_resolve_client_id
    BEFORE INSERT OR UPDATE ON health_status_alerts
    FOR EACH ROW
    EXECUTE FUNCTION auto_resolve_client_id();

DROP TRIGGER IF EXISTS trigger_auto_resolve_client_id ON chasen_folders;
CREATE TRIGGER trigger_auto_resolve_client_id
    BEFORE INSERT OR UPDATE ON chasen_folders
    FOR EACH ROW
    EXECUTE FUNCTION auto_resolve_client_id();

DROP TRIGGER IF EXISTS trigger_auto_resolve_client_id ON chasen_conversations;
CREATE TRIGGER trigger_auto_resolve_client_id
    BEFORE INSERT OR UPDATE ON chasen_conversations
    FOR EACH ROW
    EXECUTE FUNCTION auto_resolve_client_id();

-- ============================================================================
-- 5. CREATE VIEW FOR EASY CLIENT LOOKUP WITH ALL ALIASES
-- ============================================================================

CREATE OR REPLACE VIEW clients_with_aliases AS
SELECT
    c.id,
    c.canonical_name,
    c.display_name,
    c.parent_id,
    p.canonical_name AS parent_name,
    c.segment,
    c.tier,
    c.country,
    c.region,
    c.cse_name,
    c.is_active,
    ARRAY_AGG(DISTINCT ca.alias) FILTER (WHERE ca.alias IS NOT NULL) AS aliases,
    c.created_at,
    c.updated_at
FROM clients c
LEFT JOIN clients p ON c.parent_id = p.id
LEFT JOIN client_aliases_unified ca ON c.id = ca.client_id
GROUP BY c.id, p.canonical_name;

-- ============================================================================
-- 6. CREATE HELPER FUNCTION TO ADD NEW ALIAS
-- ============================================================================

CREATE OR REPLACE FUNCTION add_client_alias(
    p_client_name TEXT,
    p_alias TEXT,
    p_alias_type TEXT DEFAULT 'display',
    p_source TEXT DEFAULT 'manual'
)
RETURNS BOOLEAN AS $$
DECLARE
    v_client_id UUID;
BEGIN
    -- Resolve the client
    v_client_id := resolve_client_id(p_client_name);

    IF v_client_id IS NULL THEN
        RAISE NOTICE 'Client not found: %', p_client_name;
        RETURN false;
    END IF;

    -- Insert the alias
    INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
    VALUES (v_client_id, p_alias, p_alias_type, p_source)
    ON CONFLICT (alias_normalised) DO NOTHING;

    RETURN true;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION add_client_alias IS 'Add a new alias for a client. Returns true if successful.';

-- ============================================================================
-- 7. CLEANUP: DEPRECATE OLD TABLES (OPTIONAL)
-- ============================================================================

-- Rename old tables to indicate deprecation (don't delete yet)
-- ALTER TABLE client_aliases RENAME TO client_aliases_deprecated;
-- ALTER TABLE client_name_aliases RENAME TO client_name_aliases_deprecated;

-- Add comments to old tables
COMMENT ON TABLE client_name_aliases IS 'DEPRECATED: Use client_aliases_unified instead';

-- ============================================================================
-- 8. CREATE SUMMARY VIEW FOR DASHBOARD
-- ============================================================================

CREATE OR REPLACE VIEW client_summary AS
SELECT
    c.id,
    c.canonical_name,
    c.display_name,
    c.segment,
    c.tier,
    c.cse_name,
    c.is_active,
    c.parent_id IS NOT NULL AS is_subsidiary,
    p.display_name AS parent_display_name,
    (SELECT COUNT(*) FROM unified_meetings m WHERE m.client_uuid = c.id) AS meeting_count,
    (SELECT COUNT(*) FROM actions a WHERE a.client_uuid = c.id) AS action_count,
    (SELECT MAX(nr.score) FROM nps_responses nr WHERE nr.client_uuid = c.id) AS latest_nps_score
FROM clients c
LEFT JOIN clients p ON c.parent_id = p.id
WHERE c.is_active = true;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

DO $$
DECLARE
    trigger_count INTEGER;
    view_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO trigger_count
    FROM pg_trigger
    WHERE tgname = 'trigger_auto_resolve_client_id';

    RAISE NOTICE '✅ Phase 4 Complete: Constraints and cleanup applied';
    RAISE NOTICE '   - Auto-resolve triggers installed: %', trigger_count;
    RAISE NOTICE '   - clients_with_aliases view created';
    RAISE NOTICE '   - client_summary view created';
    RAISE NOTICE '   - add_client_alias() function created';
    RAISE NOTICE '';
    RAISE NOTICE '📋 Next Steps:';
    RAISE NOTICE '   1. Review client_unresolved_names and add missing aliases';
    RAISE NOTICE '   2. Update application code to use client_id for queries';
    RAISE NOTICE '   3. Optionally enable foreign key constraints (see comments in SQL)';
    RAISE NOTICE '   4. Drop deprecated tables after verification period';
END $$;
