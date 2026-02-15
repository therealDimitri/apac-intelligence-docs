-- ============================================================================
-- PHASE 3: Backfill client_id Foreign Keys Across All Tables
-- ============================================================================
-- Purpose: Populate client_id columns using the resolve_client_id() function
-- Date: 2025-12-27
-- Author: Claude Code
-- ============================================================================

-- ============================================================================
-- 1. ADD client_id COLUMNS WHERE MISSING
-- ============================================================================

-- portfolio_initiatives
ALTER TABLE portfolio_initiatives
    ADD COLUMN IF NOT EXISTS client_id UUID REFERENCES clients(id);

-- client_health_history
ALTER TABLE client_health_history
    ADD COLUMN IF NOT EXISTS client_id UUID REFERENCES clients(id);

-- health_status_alerts
ALTER TABLE health_status_alerts
    ADD COLUMN IF NOT EXISTS client_id UUID REFERENCES clients(id);

-- chasen_folders
ALTER TABLE chasen_folders
    ADD COLUMN IF NOT EXISTS client_id UUID REFERENCES clients(id);

-- chasen_conversations
ALTER TABLE chasen_conversations
    ADD COLUMN IF NOT EXISTS client_id UUID REFERENCES clients(id);

-- nps_topic_classifications (via nps_responses)
-- No direct client reference, joins through nps_responses

-- ============================================================================
-- 2. CREATE INDEXES FOR NEW COLUMNS
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_portfolio_initiatives_client_id
    ON portfolio_initiatives(client_id);

CREATE INDEX IF NOT EXISTS idx_client_health_history_client_id
    ON client_health_history(client_id);

CREATE INDEX IF NOT EXISTS idx_health_status_alerts_client_id
    ON health_status_alerts(client_id);

CREATE INDEX IF NOT EXISTS idx_chasen_folders_client_id
    ON chasen_folders(client_id);

CREATE INDEX IF NOT EXISTS idx_chasen_conversations_client_id
    ON chasen_conversations(client_id);

-- ============================================================================
-- 3. BACKFILL EXISTING TABLES
-- ============================================================================

-- 3.1 unified_meetings
-- NOTE: unified_meetings.client_id is INTEGER (legacy), add new UUID column
ALTER TABLE unified_meetings ADD COLUMN IF NOT EXISTS client_uuid UUID;
CREATE INDEX IF NOT EXISTS idx_unified_meetings_client_uuid ON unified_meetings(client_uuid);

UPDATE unified_meetings um
SET client_uuid = resolve_client_id(um.client_name)
WHERE um.client_uuid IS NULL
  AND um.client_name IS NOT NULL
  AND um.client_name != '';

-- 3.2 actions (column is 'client', not 'client_name')
-- NOTE: actions.client_id is INTEGER (legacy), add new UUID column
ALTER TABLE actions ADD COLUMN IF NOT EXISTS client_uuid UUID;
CREATE INDEX IF NOT EXISTS idx_actions_client_uuid ON actions(client_uuid);

UPDATE actions a
SET client_uuid = resolve_client_id(a.client)
WHERE a.client_uuid IS NULL
  AND a.client IS NOT NULL
  AND a.client != '';

-- 3.3 nps_responses
-- NOTE: nps_responses.client_id is INTEGER (legacy), not UUID
-- We need to add a new UUID column for proper foreign key
ALTER TABLE nps_responses ADD COLUMN IF NOT EXISTS client_uuid UUID;

UPDATE nps_responses nr
SET client_uuid = resolve_client_id(nr.client_name)
WHERE nr.client_uuid IS NULL
  AND nr.client_name IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_nps_responses_client_uuid ON nps_responses(client_uuid);

-- 3.4 client_segmentation
-- NOTE: client_segmentation.client_id is VARCHAR (legacy), add new UUID column
ALTER TABLE client_segmentation ADD COLUMN IF NOT EXISTS client_uuid UUID;
CREATE INDEX IF NOT EXISTS idx_client_segmentation_client_uuid ON client_segmentation(client_uuid);

UPDATE client_segmentation cs
SET client_uuid = resolve_client_id(cs.client_name)
WHERE cs.client_uuid IS NULL
  AND cs.client_name IS NOT NULL;

-- 3.5 aging_accounts
-- NOTE: aging_accounts.client_id is INTEGER (legacy), add new UUID column
ALTER TABLE aging_accounts ADD COLUMN IF NOT EXISTS client_uuid UUID;
CREATE INDEX IF NOT EXISTS idx_aging_accounts_client_uuid ON aging_accounts(client_uuid);

UPDATE aging_accounts aa
SET client_uuid = resolve_client_id(COALESCE(aa.client_name_normalized, aa.client_name))
WHERE aa.client_uuid IS NULL
  AND (aa.client_name IS NOT NULL OR aa.client_name_normalized IS NOT NULL);

-- 3.6 portfolio_initiatives
UPDATE portfolio_initiatives pi
SET client_id = resolve_client_id(pi.client_name)
WHERE pi.client_id IS NULL
  AND pi.client_name IS NOT NULL;

-- 3.7 client_health_history
UPDATE client_health_history chh
SET client_id = resolve_client_id(chh.client_name)
WHERE chh.client_id IS NULL
  AND chh.client_name IS NOT NULL;

-- 3.8 health_status_alerts
UPDATE health_status_alerts hsa
SET client_id = resolve_client_id(hsa.client_name)
WHERE hsa.client_id IS NULL
  AND hsa.client_name IS NOT NULL;

-- 3.9 chasen_folders
UPDATE chasen_folders cf
SET client_id = resolve_client_id(cf.client_name)
WHERE cf.client_id IS NULL
  AND cf.client_name IS NOT NULL;

-- 3.10 chasen_conversations
UPDATE chasen_conversations cc
SET client_id = resolve_client_id(cc.client_name)
WHERE cc.client_id IS NULL
  AND cc.client_name IS NOT NULL;

-- ============================================================================
-- 4. CREATE UNRESOLVED NAMES LOG TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS client_unresolved_names (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_table TEXT NOT NULL,
    original_name TEXT NOT NULL,
    record_count INTEGER DEFAULT 1,
    first_seen TIMESTAMPTZ DEFAULT now(),
    resolved BOOLEAN DEFAULT false,
    resolved_to UUID REFERENCES clients(id),
    resolved_at TIMESTAMPTZ,
    notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_client_unresolved_names_name
    ON client_unresolved_names(original_name);

-- ============================================================================
-- 5. LOG UNRESOLVED NAMES
-- ============================================================================

-- unified_meetings unresolved
INSERT INTO client_unresolved_names (source_table, original_name, record_count)
SELECT 'unified_meetings', client_name, COUNT(*)
FROM unified_meetings
WHERE client_uuid IS NULL
  AND client_name IS NOT NULL
  AND client_name != ''
GROUP BY client_name
ON CONFLICT DO NOTHING;

-- actions unresolved
INSERT INTO client_unresolved_names (source_table, original_name, record_count)
SELECT 'actions', client, COUNT(*)
FROM actions
WHERE client_uuid IS NULL
  AND client IS NOT NULL
  AND client != ''
GROUP BY client
ON CONFLICT DO NOTHING;

-- client_segmentation unresolved
INSERT INTO client_unresolved_names (source_table, original_name, record_count)
SELECT 'client_segmentation', client_name, COUNT(*)
FROM client_segmentation
WHERE client_uuid IS NULL
  AND client_name IS NOT NULL
GROUP BY client_name
ON CONFLICT DO NOTHING;

-- aging_accounts unresolved
INSERT INTO client_unresolved_names (source_table, original_name, record_count)
SELECT 'aging_accounts', COALESCE(client_name_normalized, client_name), COUNT(*)
FROM aging_accounts
WHERE client_uuid IS NULL
  AND (client_name IS NOT NULL OR client_name_normalized IS NOT NULL)
GROUP BY COALESCE(client_name_normalized, client_name)
ON CONFLICT DO NOTHING;

-- portfolio_initiatives unresolved
INSERT INTO client_unresolved_names (source_table, original_name, record_count)
SELECT 'portfolio_initiatives', client_name, COUNT(*)
FROM portfolio_initiatives
WHERE client_id IS NULL
  AND client_name IS NOT NULL
GROUP BY client_name
ON CONFLICT DO NOTHING;

-- client_health_history unresolved
INSERT INTO client_unresolved_names (source_table, original_name, record_count)
SELECT 'client_health_history', client_name, COUNT(*)
FROM client_health_history
WHERE client_id IS NULL
  AND client_name IS NOT NULL
GROUP BY client_name
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 6. CREATE HELPER VIEW FOR MONITORING
-- ============================================================================

CREATE OR REPLACE VIEW client_id_backfill_status AS
SELECT
    'unified_meetings' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(client_uuid) AS with_client_id,
    COUNT(*) - COUNT(client_uuid) AS missing_client_id,
    ROUND(100.0 * COUNT(client_uuid) / NULLIF(COUNT(*), 0), 1) AS percentage
FROM unified_meetings
UNION ALL
SELECT
    'actions',
    COUNT(*),
    COUNT(client_uuid),
    COUNT(*) - COUNT(client_uuid),
    ROUND(100.0 * COUNT(client_uuid) / NULLIF(COUNT(*), 0), 1)
FROM actions
UNION ALL
SELECT
    'client_segmentation',
    COUNT(*),
    COUNT(client_uuid),
    COUNT(*) - COUNT(client_uuid),
    ROUND(100.0 * COUNT(client_uuid) / NULLIF(COUNT(*), 0), 1)
FROM client_segmentation
UNION ALL
SELECT
    'aging_accounts',
    COUNT(*),
    COUNT(client_uuid),
    COUNT(*) - COUNT(client_uuid),
    ROUND(100.0 * COUNT(client_uuid) / NULLIF(COUNT(*), 0), 1)
FROM aging_accounts
UNION ALL
SELECT
    'portfolio_initiatives',
    COUNT(*),
    COUNT(client_id),
    COUNT(*) - COUNT(client_id),
    ROUND(100.0 * COUNT(client_id) / NULLIF(COUNT(*), 0), 1)
FROM portfolio_initiatives
UNION ALL
SELECT
    'client_health_history',
    COUNT(*),
    COUNT(client_id),
    COUNT(*) - COUNT(client_id),
    ROUND(100.0 * COUNT(client_id) / NULLIF(COUNT(*), 0), 1)
FROM client_health_history
UNION ALL
SELECT
    'health_status_alerts',
    COUNT(*),
    COUNT(client_id),
    COUNT(*) - COUNT(client_id),
    ROUND(100.0 * COUNT(client_id) / NULLIF(COUNT(*), 0), 1)
FROM health_status_alerts
UNION ALL
SELECT
    'chasen_folders',
    COUNT(*),
    COUNT(client_id),
    COUNT(*) - COUNT(client_id),
    ROUND(100.0 * COUNT(client_id) / NULLIF(COUNT(*), 0), 1)
FROM chasen_folders
UNION ALL
SELECT
    'chasen_conversations',
    COUNT(*),
    COUNT(client_id),
    COUNT(*) - COUNT(client_id),
    ROUND(100.0 * COUNT(client_id) / NULLIF(COUNT(*), 0), 1)
FROM chasen_conversations;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

DO $$
DECLARE
    unresolved_count INTEGER;
    rec RECORD;
BEGIN
    SELECT COUNT(*) INTO unresolved_count FROM client_unresolved_names WHERE NOT resolved;

    RAISE NOTICE '✅ Phase 3 Complete: Client IDs backfilled';
    RAISE NOTICE '';
    RAISE NOTICE '📊 Backfill Status:';

    FOR rec IN SELECT * FROM client_id_backfill_status ORDER BY table_name LOOP
        RAISE NOTICE '   % : %/% (%)',
            rec.table_name,
            rec.with_client_id,
            rec.total_rows,
            rec.percentage || '%';
    END LOOP;

    RAISE NOTICE '';
    RAISE NOTICE '⚠️  Unresolved names: % (see client_unresolved_names table)', unresolved_count;
END $$;
