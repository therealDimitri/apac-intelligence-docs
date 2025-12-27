-- Migration: Add client_uuid to remaining tables
-- Date: 2025-12-27
-- Purpose: Complete client unification by adding client_uuid to all client-related tables

-- =============================================
-- 1. ADD client_uuid COLUMN TO TABLES
-- =============================================

-- nps_clients
ALTER TABLE nps_clients
ADD COLUMN IF NOT EXISTS client_uuid UUID REFERENCES clients(id);

-- client_arr
ALTER TABLE client_arr
ADD COLUMN IF NOT EXISTS client_uuid UUID REFERENCES clients(id);

-- chasen_documents
ALTER TABLE chasen_documents
ADD COLUMN IF NOT EXISTS client_uuid UUID REFERENCES clients(id);

-- segmentation_compliance_scores
ALTER TABLE segmentation_compliance_scores
ADD COLUMN IF NOT EXISTS client_uuid UUID REFERENCES clients(id);

-- =============================================
-- 2. CREATE INDEXES FOR client_uuid
-- =============================================

CREATE INDEX IF NOT EXISTS idx_nps_clients_client_uuid ON nps_clients(client_uuid);
CREATE INDEX IF NOT EXISTS idx_client_arr_client_uuid ON client_arr(client_uuid);
CREATE INDEX IF NOT EXISTS idx_chasen_documents_client_uuid ON chasen_documents(client_uuid);
CREATE INDEX IF NOT EXISTS idx_segmentation_compliance_scores_client_uuid ON segmentation_compliance_scores(client_uuid);

-- =============================================
-- 3. BACKFILL client_uuid FROM clients TABLE
-- =============================================

-- Backfill nps_clients
-- First try direct canonical name match, then try alias lookup
UPDATE nps_clients nc
SET client_uuid = c.id
FROM clients c
WHERE nc.client_uuid IS NULL
  AND nc.client_name IS NOT NULL
  AND (
    LOWER(c.canonical_name) = LOWER(nc.client_name)
    OR EXISTS (
      SELECT 1 FROM client_name_aliases cna
      WHERE LOWER(cna.canonical_name) = LOWER(c.canonical_name)
      AND LOWER(cna.display_name) = LOWER(nc.client_name)
    )
  );

-- Backfill client_arr
UPDATE client_arr ca_table
SET client_uuid = c.id
FROM clients c
WHERE ca_table.client_uuid IS NULL
  AND ca_table.client_name IS NOT NULL
  AND (
    LOWER(c.canonical_name) = LOWER(ca_table.client_name)
    OR EXISTS (
      SELECT 1 FROM client_name_aliases cna
      WHERE LOWER(cna.canonical_name) = LOWER(c.canonical_name)
      AND LOWER(cna.display_name) = LOWER(ca_table.client_name)
    )
  );

-- Backfill chasen_documents
UPDATE chasen_documents cd
SET client_uuid = c.id
FROM clients c
WHERE cd.client_uuid IS NULL
  AND cd.client_name IS NOT NULL
  AND (
    LOWER(c.canonical_name) = LOWER(cd.client_name)
    OR EXISTS (
      SELECT 1 FROM client_name_aliases cna
      WHERE LOWER(cna.canonical_name) = LOWER(c.canonical_name)
      AND LOWER(cna.display_name) = LOWER(cd.client_name)
    )
  );

-- Backfill segmentation_compliance_scores
UPDATE segmentation_compliance_scores scs
SET client_uuid = c.id
FROM clients c
WHERE scs.client_uuid IS NULL
  AND scs.client_name IS NOT NULL
  AND (
    LOWER(c.canonical_name) = LOWER(scs.client_name)
    OR EXISTS (
      SELECT 1 FROM client_name_aliases cna
      WHERE LOWER(cna.canonical_name) = LOWER(c.canonical_name)
      AND LOWER(cna.display_name) = LOWER(scs.client_name)
    )
  );

-- =============================================
-- 4. CREATE TRIGGERS FOR AUTO-POPULATION
-- =============================================

-- Generic function to resolve client_uuid from client_name
CREATE OR REPLACE FUNCTION resolve_client_uuid_from_name()
RETURNS TRIGGER AS $$
DECLARE
  resolved_uuid UUID;
BEGIN
  -- Only resolve if client_uuid is NULL and client_name is provided
  IF NEW.client_uuid IS NULL AND NEW.client_name IS NOT NULL THEN
    -- Try to resolve using the RPC function
    SELECT resolve_client_id(NEW.client_name) INTO resolved_uuid;

    IF resolved_uuid IS NOT NULL THEN
      NEW.client_uuid := resolved_uuid;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for each table
DROP TRIGGER IF EXISTS trigger_nps_clients_resolve_uuid ON nps_clients;
CREATE TRIGGER trigger_nps_clients_resolve_uuid
  BEFORE INSERT OR UPDATE ON nps_clients
  FOR EACH ROW
  EXECUTE FUNCTION resolve_client_uuid_from_name();

DROP TRIGGER IF EXISTS trigger_client_arr_resolve_uuid ON client_arr;
CREATE TRIGGER trigger_client_arr_resolve_uuid
  BEFORE INSERT OR UPDATE ON client_arr
  FOR EACH ROW
  EXECUTE FUNCTION resolve_client_uuid_from_name();

DROP TRIGGER IF EXISTS trigger_chasen_documents_resolve_uuid ON chasen_documents;
CREATE TRIGGER trigger_chasen_documents_resolve_uuid
  BEFORE INSERT OR UPDATE ON chasen_documents
  FOR EACH ROW
  EXECUTE FUNCTION resolve_client_uuid_from_name();

DROP TRIGGER IF EXISTS trigger_compliance_scores_resolve_uuid ON segmentation_compliance_scores;
CREATE TRIGGER trigger_compliance_scores_resolve_uuid
  BEFORE INSERT OR UPDATE ON segmentation_compliance_scores
  FOR EACH ROW
  EXECUTE FUNCTION resolve_client_uuid_from_name();

-- =============================================
-- 5. VERIFY MIGRATION
-- =============================================

-- Show coverage statistics
DO $$
DECLARE
  total_count INTEGER;
  uuid_count INTEGER;
  coverage NUMERIC;
BEGIN
  -- nps_clients
  SELECT COUNT(*), COUNT(client_uuid) INTO total_count, uuid_count FROM nps_clients;
  coverage := CASE WHEN total_count > 0 THEN (uuid_count::NUMERIC / total_count * 100) ELSE 0 END;
  RAISE NOTICE 'nps_clients: % / % rows have client_uuid (%.1f%%)', uuid_count, total_count, coverage;

  -- client_arr
  SELECT COUNT(*), COUNT(client_uuid) INTO total_count, uuid_count FROM client_arr;
  coverage := CASE WHEN total_count > 0 THEN (uuid_count::NUMERIC / total_count * 100) ELSE 0 END;
  RAISE NOTICE 'client_arr: % / % rows have client_uuid (%.1f%%)', uuid_count, total_count, coverage;

  -- chasen_documents
  SELECT COUNT(*), COUNT(client_uuid) INTO total_count, uuid_count FROM chasen_documents;
  coverage := CASE WHEN total_count > 0 THEN (uuid_count::NUMERIC / total_count * 100) ELSE 0 END;
  RAISE NOTICE 'chasen_documents: % / % rows have client_uuid (%.1f%%)', uuid_count, total_count, coverage;

  -- segmentation_compliance_scores
  SELECT COUNT(*), COUNT(client_uuid) INTO total_count, uuid_count FROM segmentation_compliance_scores;
  coverage := CASE WHEN total_count > 0 THEN (uuid_count::NUMERIC / total_count * 100) ELSE 0 END;
  RAISE NOTICE 'segmentation_compliance_scores: % / % rows have client_uuid (%.1f%%)', uuid_count, total_count, coverage;
END;
$$;

-- =============================================
-- 6. GRANT PERMISSIONS
-- =============================================

-- Grant access to authenticated users via RLS
-- (Assuming RLS policies already exist for these tables)

COMMENT ON COLUMN nps_clients.client_uuid IS 'UUID reference to clients table for consistent client identification';
COMMENT ON COLUMN client_arr.client_uuid IS 'UUID reference to clients table for consistent client identification';
COMMENT ON COLUMN chasen_documents.client_uuid IS 'UUID reference to clients table for consistent client identification';
COMMENT ON COLUMN segmentation_compliance_scores.client_uuid IS 'UUID reference to clients table for consistent client identification';
