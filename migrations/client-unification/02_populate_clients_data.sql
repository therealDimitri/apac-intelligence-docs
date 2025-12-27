-- ============================================================================
-- PHASE 2: Populate Clients and Aliases from Existing Data
-- ============================================================================
-- Purpose: Populate the master clients table with canonical client data
-- Date: 2025-12-27
-- Author: Claude Code
-- ============================================================================

-- ============================================================================
-- 1. INSERT PARENT CLIENTS (Top-level clients with subsidiaries)
-- ============================================================================

-- SingHealth Group (parent)
INSERT INTO clients (id, canonical_name, display_name, segment, country, region)
VALUES (
    'a1000000-0000-0000-0000-000000000001',
    'Singapore Health Services Pte Ltd',
    'SingHealth',
    'Sleeping Giant',
    'Singapore',
    'APAC'
) ON CONFLICT (canonical_name) DO NOTHING;

-- SA Health (parent)
INSERT INTO clients (id, canonical_name, display_name, segment, country, region)
VALUES (
    'a2000000-0000-0000-0000-000000000001',
    'SA Health',
    'SA Health',
    'Steady State',
    'Australia',
    'APAC'
) ON CONFLICT (canonical_name) DO NOTHING;

-- Ministry of Defence Singapore (parent)
INSERT INTO clients (id, canonical_name, display_name, segment, country, region)
VALUES (
    'a3000000-0000-0000-0000-000000000001',
    'Ministry of Defence, Singapore',
    'MinDef',
    'Sleeping Giant',
    'Singapore',
    'APAC'
) ON CONFLICT (canonical_name) DO NOTHING;

-- ============================================================================
-- 2. INSERT CHILD CLIENTS (Subsidiaries)
-- ============================================================================

-- SingHealth subsidiaries
INSERT INTO clients (canonical_name, display_name, parent_id, segment, country, region)
VALUES
    ('Changi General Hospital', 'Changi General Hospital',
     'a1000000-0000-0000-0000-000000000001', 'Sleeping Giant', 'Singapore', 'APAC'),
    ('Sengkang General Hospital Pte. Ltd.', 'Sengkang General Hospital',
     'a1000000-0000-0000-0000-000000000001', 'Sleeping Giant', 'Singapore', 'APAC'),
    ('Singapore General Hospital Pte Ltd', 'Singapore General Hospital',
     'a1000000-0000-0000-0000-000000000001', 'Sleeping Giant', 'Singapore', 'APAC'),
    ('KK Women''s and Children''s Hospital', 'KK Women''s Hospital',
     'a1000000-0000-0000-0000-000000000001', 'Sleeping Giant', 'Singapore', 'APAC'),
    ('National Cancer Centre Of Singapore Pte Ltd', 'National Cancer Centre',
     'a1000000-0000-0000-0000-000000000001', 'Sleeping Giant', 'Singapore', 'APAC'),
    ('National Heart Centre Of Singapore Pte Ltd', 'National Heart Centre',
     'a1000000-0000-0000-0000-000000000001', 'Sleeping Giant', 'Singapore', 'APAC')
ON CONFLICT (canonical_name) DO NOTHING;

-- SA Health subsidiaries
INSERT INTO clients (canonical_name, display_name, parent_id, segment, country, region)
VALUES
    ('SA Health iPro', 'SA Health (iPro)',
     'a2000000-0000-0000-0000-000000000001', 'Steady State', 'Australia', 'APAC'),
    ('SA Health iQemo', 'SA Health (iQemo)',
     'a2000000-0000-0000-0000-000000000001', 'Steady State', 'Australia', 'APAC'),
    ('SA Health Sunrise', 'SA Health (Sunrise)',
     'a2000000-0000-0000-0000-000000000001', 'Steady State', 'Australia', 'APAC')
ON CONFLICT (canonical_name) DO NOTHING;

-- MinDef subsidiary
INSERT INTO clients (canonical_name, display_name, parent_id, segment, country, region)
VALUES
    ('NCS PTE Ltd', 'NCS',
     'a3000000-0000-0000-0000-000000000001', 'Sleeping Giant', 'Singapore', 'APAC')
ON CONFLICT (canonical_name) DO NOTHING;

-- ============================================================================
-- 3. INSERT STANDALONE CLIENTS (No parent-child relationship)
-- ============================================================================

INSERT INTO clients (canonical_name, display_name, segment, country, region)
VALUES
    -- Australian Clients
    ('Epworth Healthcare', 'Epworth Healthcare', 'Steady State', 'Australia', 'APAC'),
    ('Barwon Health Australia', 'Barwon Health', 'Steady State', 'Australia', 'APAC'),
    ('Albury Wodonga Health', 'Albury Wodonga Health', 'Steady State', 'Australia', 'APAC'),
    ('Western Health', 'Western Health', 'Steady State', 'Australia', 'APAC'),
    ('Grampians Health', 'Grampians Health', 'Steady State', 'Australia', 'APAC'),
    ('Gippsland Health Alliance', 'GHA', 'Steady State', 'Australia', 'APAC'),
    ('The Royal Victorian Eye and Ear Hospital', 'RVEEH', 'Steady State', 'Australia', 'APAC'),
    ('Department of Health - Victoria', 'DoH Victoria', 'Steady State', 'Australia', 'APAC'),
    ('Western Australia Department of Health', 'WA Health', 'Steady State', 'Australia', 'APAC'),

    -- Singapore Clients (standalone)
    ('Mount Alvernia Hospital', 'Mount Alvernia Hospital', 'Steady State', 'Singapore', 'APAC'),

    -- Philippines Clients
    ('St Luke''s Medical Center Global City Inc', 'SLMC', 'Steady State', 'Philippines', 'APAC'),

    -- Guam Clients
    ('Guam Regional Medical City', 'GRMC', 'Steady State', 'Guam', 'APAC'),

    -- New Zealand Clients
    ('Te Whatu Ora Waikato', 'Te Whatu Ora Waikato', 'Steady State', 'New Zealand', 'APAC'),

    -- Internal (for internal meetings/actions)
    ('Internal', 'Internal', NULL, 'Australia', 'APAC')
ON CONFLICT (canonical_name) DO NOTHING;

-- ============================================================================
-- 4. IMPORT ALIASES FROM client_name_aliases TABLE
-- ============================================================================

-- First, import existing aliases with proper client_id resolution
INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT
    c.id,
    cna.display_name,
    'import',
    'client_name_aliases'
FROM client_name_aliases cna
CROSS JOIN LATERAL (
    SELECT id FROM clients
    WHERE LOWER(canonical_name) = LOWER(cna.canonical_name)
       OR LOWER(display_name) = LOWER(cna.canonical_name)
    LIMIT 1
) c
WHERE c.id IS NOT NULL
ON CONFLICT (alias_normalised) DO NOTHING;

-- ============================================================================
-- 5. ADD COMMON ALIASES MANUALLY
-- ============================================================================

-- SingHealth aliases
INSERT INTO client_aliases_unified (client_id, alias, alias_type, is_primary, source)
SELECT id, 'SingHealth', 'abbreviation', true, 'manual'
FROM clients WHERE canonical_name = 'Singapore Health Services Pte Ltd'
ON CONFLICT (alias_normalised) DO NOTHING;

INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'Singapore Health (SingHealth)', 'display', 'manual'
FROM clients WHERE canonical_name = 'Singapore Health Services Pte Ltd'
ON CONFLICT (alias_normalised) DO NOTHING;

-- GHA aliases
INSERT INTO client_aliases_unified (client_id, alias, alias_type, is_primary, source)
SELECT id, 'GHA', 'abbreviation', true, 'manual'
FROM clients WHERE canonical_name = 'Gippsland Health Alliance'
ON CONFLICT (alias_normalised) DO NOTHING;

INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'Gippsland Health Alliance (GHA)', 'display', 'manual'
FROM clients WHERE canonical_name = 'Gippsland Health Alliance'
ON CONFLICT (alias_normalised) DO NOTHING;

-- RVEEH aliases
INSERT INTO client_aliases_unified (client_id, alias, alias_type, is_primary, source)
SELECT id, 'RVEEH', 'abbreviation', true, 'manual'
FROM clients WHERE canonical_name = 'The Royal Victorian Eye and Ear Hospital'
ON CONFLICT (alias_normalised) DO NOTHING;

INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'Royal Victorian Eye and Ear Hospital', 'display', 'manual'
FROM clients WHERE canonical_name = 'The Royal Victorian Eye and Ear Hospital'
ON CONFLICT (alias_normalised) DO NOTHING;

INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'Royal Victorian Eye and Ear Hospital (RVEEH)', 'display', 'manual'
FROM clients WHERE canonical_name = 'The Royal Victorian Eye and Ear Hospital'
ON CONFLICT (alias_normalised) DO NOTHING;

-- WA Health aliases
INSERT INTO client_aliases_unified (client_id, alias, alias_type, is_primary, source)
SELECT id, 'WA Health', 'abbreviation', true, 'manual'
FROM clients WHERE canonical_name = 'Western Australia Department of Health'
ON CONFLICT (alias_normalised) DO NOTHING;

INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'Western Australia Department Of Health', 'display', 'manual'
FROM clients WHERE canonical_name = 'Western Australia Department of Health'
ON CONFLICT (alias_normalised) DO NOTHING;

INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'Western Australia Health', 'display', 'manual'
FROM clients WHERE canonical_name = 'Western Australia Department of Health'
ON CONFLICT (alias_normalised) DO NOTHING;

-- SLMC aliases
INSERT INTO client_aliases_unified (client_id, alias, alias_type, is_primary, source)
SELECT id, 'SLMC', 'abbreviation', true, 'manual'
FROM clients WHERE canonical_name = 'St Luke''s Medical Center Global City Inc'
ON CONFLICT (alias_normalised) DO NOTHING;

INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'St Luke''s Medical Centre', 'display', 'manual'
FROM clients WHERE canonical_name = 'St Luke''s Medical Center Global City Inc'
ON CONFLICT (alias_normalised) DO NOTHING;

INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'Saint Luke''s Medical Centre (SLMC)', 'display', 'manual'
FROM clients WHERE canonical_name = 'St Luke''s Medical Center Global City Inc'
ON CONFLICT (alias_normalised) DO NOTHING;

-- GRMC aliases
INSERT INTO client_aliases_unified (client_id, alias, alias_type, is_primary, source)
SELECT id, 'GRMC', 'abbreviation', true, 'manual'
FROM clients WHERE canonical_name = 'Guam Regional Medical City'
ON CONFLICT (alias_normalised) DO NOTHING;

INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'Guam Regional Medical Centre', 'display', 'manual'
FROM clients WHERE canonical_name = 'Guam Regional Medical City'
ON CONFLICT (alias_normalised) DO NOTHING;

INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'GUAM Regional Medical City', 'display', 'manual'
FROM clients WHERE canonical_name = 'Guam Regional Medical City'
ON CONFLICT (alias_normalised) DO NOTHING;

INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'Guam Regional Medical City (GRMC)', 'display', 'manual'
FROM clients WHERE canonical_name = 'Guam Regional Medical City'
ON CONFLICT (alias_normalised) DO NOTHING;

-- MinDef aliases
INSERT INTO client_aliases_unified (client_id, alias, alias_type, is_primary, source)
SELECT id, 'MinDef', 'abbreviation', true, 'manual'
FROM clients WHERE canonical_name = 'Ministry of Defence, Singapore'
ON CONFLICT (alias_normalised) DO NOTHING;

INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'MINDEF', 'abbreviation', 'manual'
FROM clients WHERE canonical_name = 'Ministry of Defence, Singapore'
ON CONFLICT (alias_normalised) DO NOTHING;

INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'NCS/MinDef', 'display', 'manual'
FROM clients WHERE canonical_name = 'Ministry of Defence, Singapore'
ON CONFLICT (alias_normalised) DO NOTHING;

INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'NCS/MinDef Singapore', 'display', 'manual'
FROM clients WHERE canonical_name = 'Ministry of Defence, Singapore'
ON CONFLICT (alias_normalised) DO NOTHING;

-- SA Health product aliases
INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'SA Health (iPro)', 'display', 'manual'
FROM clients WHERE canonical_name = 'SA Health iPro'
ON CONFLICT (alias_normalised) DO NOTHING;

INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'SA Health (iQemo)', 'display', 'manual'
FROM clients WHERE canonical_name = 'SA Health iQemo'
ON CONFLICT (alias_normalised) DO NOTHING;

INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'SA Health (Sunrise)', 'display', 'manual'
FROM clients WHERE canonical_name = 'SA Health Sunrise'
ON CONFLICT (alias_normalised) DO NOTHING;

-- Epworth case variations
INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'Epworth HealthCare', 'display', 'manual'
FROM clients WHERE canonical_name = 'Epworth Healthcare'
ON CONFLICT (alias_normalised) DO NOTHING;

INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'Epworth', 'abbreviation', 'manual'
FROM clients WHERE canonical_name = 'Epworth Healthcare'
ON CONFLICT (alias_normalised) DO NOTHING;

-- Barwon aliases
INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'Barwon Health', 'display', 'manual'
FROM clients WHERE canonical_name = 'Barwon Health Australia'
ON CONFLICT (alias_normalised) DO NOTHING;

-- Grampians aliases
INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'Grampians Health Alliance', 'display', 'manual'
FROM clients WHERE canonical_name = 'Grampians Health'
ON CONFLICT (alias_normalised) DO NOTHING;

-- DoH Victoria aliases
INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'DoH- Vic', 'abbreviation', 'manual'
FROM clients WHERE canonical_name = 'Department of Health - Victoria'
ON CONFLICT (alias_normalised) DO NOTHING;

INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'Dept of Health, Victoria', 'display', 'manual'
FROM clients WHERE canonical_name = 'Department of Health - Victoria'
ON CONFLICT (alias_normalised) DO NOTHING;

-- Te Whatu Ora aliases
INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'Te Whatu Ora', 'abbreviation', 'manual'
FROM clients WHERE canonical_name = 'Te Whatu Ora Waikato'
ON CONFLICT (alias_normalised) DO NOTHING;

INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'Waikato', 'abbreviation', 'manual'
FROM clients WHERE canonical_name = 'Te Whatu Ora Waikato'
ON CONFLICT (alias_normalised) DO NOTHING;

-- Mount Alvernia aliases
INSERT INTO client_aliases_unified (client_id, alias, alias_type, is_primary, source)
SELECT id, 'MAH', 'abbreviation', true, 'manual'
FROM clients WHERE canonical_name = 'Mount Alvernia Hospital'
ON CONFLICT (alias_normalised) DO NOTHING;

-- Albury Wodonga aliases
INSERT INTO client_aliases_unified (client_id, alias, alias_type, is_primary, source)
SELECT id, 'AWH', 'abbreviation', true, 'manual'
FROM clients WHERE canonical_name = 'Albury Wodonga Health'
ON CONFLICT (alias_normalised) DO NOTHING;

INSERT INTO client_aliases_unified (client_id, alias, alias_type, source)
SELECT id, 'Albury Wodonga', 'display', 'manual'
FROM clients WHERE canonical_name = 'Albury Wodonga Health'
ON CONFLICT (alias_normalised) DO NOTHING;

-- ============================================================================
-- 6. UPDATE CSE ASSIGNMENTS FROM client_segmentation
-- ============================================================================

UPDATE clients c
SET cse_name = cs.cse_name
FROM client_segmentation cs
WHERE LOWER(c.canonical_name) = LOWER(cs.client_name)
   OR LOWER(c.display_name) = LOWER(cs.client_name)
   OR c.id IN (
       SELECT client_id FROM client_aliases_unified
       WHERE LOWER(alias) = LOWER(cs.client_name)
   );

-- ============================================================================
-- 7. UPDATE SEGMENTS FROM client_segmentation
-- ============================================================================

UPDATE clients c
SET segment = cs.tier_id
FROM client_segmentation cs
WHERE (LOWER(c.canonical_name) = LOWER(cs.client_name)
   OR LOWER(c.display_name) = LOWER(cs.client_name))
  AND c.segment IS NULL;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

DO $$
DECLARE
    client_count INTEGER;
    alias_count INTEGER;
    parent_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO client_count FROM clients;
    SELECT COUNT(*) INTO alias_count FROM client_aliases_unified;
    SELECT COUNT(*) INTO parent_count FROM clients WHERE parent_id IS NOT NULL;

    RAISE NOTICE '✅ Phase 2 Complete: Client data populated';
    RAISE NOTICE '   - Total clients: %', client_count;
    RAISE NOTICE '   - Total aliases: %', alias_count;
    RAISE NOTICE '   - Child clients (with parent): %', parent_count;
END $$;
