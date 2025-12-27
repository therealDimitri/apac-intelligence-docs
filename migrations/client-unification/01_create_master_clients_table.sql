-- ============================================================================
-- PHASE 1: Create Master Clients Table and Unified Aliases
-- ============================================================================
-- Purpose: Establish single source of truth for all client data
-- Date: 2025-12-27
-- Author: Claude Code
-- ============================================================================

-- ============================================================================
-- 1. CREATE MASTER CLIENTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS clients (
    -- Primary key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Canonical name (the "official" name used for matching and storage)
    canonical_name TEXT NOT NULL,

    -- Short display name for UI (e.g., "SingHealth" instead of full legal name)
    display_name TEXT NOT NULL,

    -- Parent client for hierarchies (e.g., SingHealth → multiple hospitals)
    parent_id UUID REFERENCES clients(id) ON DELETE SET NULL,

    -- Segmentation
    segment TEXT, -- Sleeping Giant, Steady State, Rising Star, etc.
    tier TEXT,    -- T1, T2, T3

    -- Location
    country TEXT DEFAULT 'Australia',
    region TEXT DEFAULT 'APAC',

    -- Assigned CSE (denormalised for convenience)
    cse_id UUID,
    cse_name TEXT,

    -- Status
    is_active BOOLEAN DEFAULT true,

    -- Audit timestamps
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),

    -- Constraints
    CONSTRAINT clients_canonical_name_unique UNIQUE (canonical_name)
);

-- Add comment
COMMENT ON TABLE clients IS 'Master table for all clients - single source of truth';
COMMENT ON COLUMN clients.canonical_name IS 'Official name used for data matching and storage';
COMMENT ON COLUMN clients.display_name IS 'Short name for UI display';
COMMENT ON COLUMN clients.parent_id IS 'Parent client for hierarchical relationships';

-- ============================================================================
-- 2. CREATE INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_clients_canonical_name ON clients(canonical_name);
CREATE INDEX IF NOT EXISTS idx_clients_display_name ON clients(display_name);
CREATE INDEX IF NOT EXISTS idx_clients_parent_id ON clients(parent_id);
CREATE INDEX IF NOT EXISTS idx_clients_segment ON clients(segment);
CREATE INDEX IF NOT EXISTS idx_clients_is_active ON clients(is_active);

-- Full-text search index
CREATE INDEX IF NOT EXISTS idx_clients_search ON clients
    USING gin(to_tsvector('english', canonical_name || ' ' || display_name));

-- ============================================================================
-- 3. CREATE UNIFIED CLIENT ALIASES TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS client_aliases_unified (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- The client this alias maps to
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,

    -- The alias string (case-preserved)
    alias TEXT NOT NULL,

    -- Normalised alias for case-insensitive lookups
    alias_normalised TEXT GENERATED ALWAYS AS (LOWER(TRIM(alias))) STORED,

    -- Alias type for categorisation
    alias_type TEXT DEFAULT 'display' CHECK (alias_type IN (
        'display',      -- UI display variation
        'legal',        -- Legal/contract name
        'abbreviation', -- Short form (GHA, RVEEH)
        'historical',   -- Previous name
        'import'        -- Used during data import matching
    )),

    -- Is this the primary display alias?
    is_primary BOOLEAN DEFAULT false,

    -- Source of this alias
    source TEXT DEFAULT 'manual', -- 'manual', 'nps_import', 'invoice_import', etc.

    -- Audit
    created_at TIMESTAMPTZ DEFAULT now(),

    -- Each alias string must be unique (case-insensitive)
    CONSTRAINT client_aliases_unified_alias_unique UNIQUE (alias_normalised)
);

-- Add comments
COMMENT ON TABLE client_aliases_unified IS 'Maps all known client name variations to master clients table';
COMMENT ON COLUMN client_aliases_unified.alias IS 'The alias string (original case preserved)';
COMMENT ON COLUMN client_aliases_unified.alias_normalised IS 'Lowercase trimmed alias for case-insensitive lookups';

-- ============================================================================
-- 4. CREATE INDEXES FOR ALIASES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_client_aliases_unified_client_id ON client_aliases_unified(client_id);
CREATE INDEX IF NOT EXISTS idx_client_aliases_unified_alias ON client_aliases_unified(alias);
CREATE INDEX IF NOT EXISTS idx_client_aliases_unified_alias_normalised ON client_aliases_unified(alias_normalised);
CREATE INDEX IF NOT EXISTS idx_client_aliases_unified_type ON client_aliases_unified(alias_type);

-- ============================================================================
-- 5. CREATE CLIENT RESOLUTION FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION resolve_client_id(input_name TEXT)
RETURNS UUID AS $$
DECLARE
    resolved_id UUID;
    normalised_input TEXT;
BEGIN
    -- Normalise input
    normalised_input := LOWER(TRIM(input_name));

    -- 1. Try exact match on canonical_name (case-insensitive)
    SELECT id INTO resolved_id
    FROM clients
    WHERE LOWER(canonical_name) = normalised_input
    LIMIT 1;

    IF resolved_id IS NOT NULL THEN
        RETURN resolved_id;
    END IF;

    -- 2. Try exact match on display_name (case-insensitive)
    SELECT id INTO resolved_id
    FROM clients
    WHERE LOWER(display_name) = normalised_input
    LIMIT 1;

    IF resolved_id IS NOT NULL THEN
        RETURN resolved_id;
    END IF;

    -- 3. Try alias lookup (uses normalised index)
    SELECT client_id INTO resolved_id
    FROM client_aliases_unified
    WHERE alias_normalised = normalised_input
    LIMIT 1;

    RETURN resolved_id; -- May be NULL if no match
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION resolve_client_id IS 'Resolves any client name/alias to a client UUID';

-- ============================================================================
-- 6. CREATE HELPER FUNCTION TO GET CANONICAL NAME
-- ============================================================================

CREATE OR REPLACE FUNCTION get_canonical_client_name(input_name TEXT)
RETURNS TEXT AS $$
DECLARE
    resolved_id UUID;
    canonical TEXT;
BEGIN
    resolved_id := resolve_client_id(input_name);

    IF resolved_id IS NULL THEN
        RETURN input_name; -- Return original if not found
    END IF;

    SELECT canonical_name INTO canonical
    FROM clients
    WHERE id = resolved_id;

    RETURN COALESCE(canonical, input_name);
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION get_canonical_client_name IS 'Resolves any client name/alias to canonical name';

-- ============================================================================
-- 7. CREATE TRIGGER FOR UPDATED_AT
-- ============================================================================

CREATE OR REPLACE FUNCTION update_clients_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_clients_updated_at ON clients;
CREATE TRIGGER trigger_clients_updated_at
    BEFORE UPDATE ON clients
    FOR EACH ROW
    EXECUTE FUNCTION update_clients_updated_at();

-- ============================================================================
-- 8. ENABLE RLS (but allow authenticated users to read)
-- ============================================================================

ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_aliases_unified ENABLE ROW LEVEL SECURITY;

-- Read access for authenticated users
CREATE POLICY clients_read_policy ON clients
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY client_aliases_read_policy ON client_aliases_unified
    FOR SELECT
    TO authenticated
    USING (true);

-- Service role has full access
CREATE POLICY clients_service_policy ON clients
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

CREATE POLICY client_aliases_service_policy ON client_aliases_unified
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- VERIFICATION
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Phase 1 Complete: Master clients table and aliases created';
    RAISE NOTICE '   - clients table created with indexes';
    RAISE NOTICE '   - client_aliases_unified table created with indexes';
    RAISE NOTICE '   - resolve_client_id() function created';
    RAISE NOTICE '   - get_canonical_client_name() function created';
    RAISE NOTICE '   - RLS policies applied';
END $$;
