-- Migration: Add Foreign Key Relationships
-- Date: 2025-12-02
-- Purpose: Establish referential integrity and enable query optimizer improvements
-- Impact: Better query performance, data integrity enforcement, cascade operations
--
-- CRITICAL: This migration adds foreign key constraints to enforce relationships:
--   1. nps_responses.client_name → nps_clients.client_name
--   2. unified_meetings.client_name → nps_clients.client_name
--   3. actions.Client → nps_clients.client_name
--   4. segmentation_events.client_name → nps_clients.client_name
--   5. segmentation_event_compliance.client_name → nps_clients.client_name
--
-- Benefits:
--   - PostgreSQL query planner can optimize joins more effectively
--   - Prevents orphaned records (enforces data integrity)
--   - Documents relationships at database level
--   - Enables cascade operations if needed
--
-- Deployment: Safe to run on production (validates existing data first)
-- Rollback: See drop constraint commands at bottom

-- ============================================================================
-- PREREQUISITES: VALIDATE EXISTING DATA
-- ============================================================================

-- Before adding foreign keys, we need to ensure existing data is consistent.
-- These queries check for orphaned records that would violate the constraints.

-- Check for orphaned NPS responses
DO $$
DECLARE
  orphan_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO orphan_count
  FROM nps_responses r
  WHERE NOT EXISTS (
    SELECT 1 FROM nps_clients c WHERE c.client_name = r.client_name
  );

  IF orphan_count > 0 THEN
    RAISE NOTICE 'WARNING: Found % orphaned nps_responses records', orphan_count;
    RAISE NOTICE 'Run: SELECT DISTINCT client_name FROM nps_responses WHERE client_name NOT IN (SELECT client_name FROM nps_clients);';
  ELSE
    RAISE NOTICE 'OK: No orphaned nps_responses records';
  END IF;
END $$;

-- Check for orphaned meetings
DO $$
DECLARE
  orphan_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO orphan_count
  FROM unified_meetings m
  WHERE NOT EXISTS (
    SELECT 1 FROM nps_clients c WHERE c.client_name = m.client_name
  );

  IF orphan_count > 0 THEN
    RAISE NOTICE 'WARNING: Found % orphaned unified_meetings records', orphan_count;
    RAISE NOTICE 'Run: SELECT DISTINCT client_name FROM unified_meetings WHERE client_name NOT IN (SELECT client_name FROM nps_clients);';
  ELSE
    RAISE NOTICE 'OK: No orphaned unified_meetings records';
  END IF;
END $$;

-- Check for orphaned actions
DO $$
DECLARE
  orphan_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO orphan_count
  FROM actions a
  WHERE a."Client" IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM nps_clients c WHERE c.client_name = a."Client"
    );

  IF orphan_count > 0 THEN
    RAISE NOTICE 'WARNING: Found % orphaned actions records', orphan_count;
    RAISE NOTICE 'Run: SELECT DISTINCT "Client" FROM actions WHERE "Client" NOT IN (SELECT client_name FROM nps_clients);';
  ELSE
    RAISE NOTICE 'OK: No orphaned actions records';
  END IF;
END $$;

-- Check for orphaned segmentation events
DO $$
DECLARE
  orphan_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO orphan_count
  FROM segmentation_events se
  WHERE NOT EXISTS (
    SELECT 1 FROM nps_clients c WHERE c.client_name = se.client_name
  );

  IF orphan_count > 0 THEN
    RAISE NOTICE 'WARNING: Found % orphaned segmentation_events records', orphan_count;
    RAISE NOTICE 'Run: SELECT DISTINCT client_name FROM segmentation_events WHERE client_name NOT IN (SELECT client_name FROM nps_clients);';
  ELSE
    RAISE NOTICE 'OK: No orphaned segmentation_events records';
  END IF;
END $$;

-- Check for orphaned event compliance
DO $$
DECLARE
  orphan_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO orphan_count
  FROM segmentation_event_compliance ec
  WHERE NOT EXISTS (
    SELECT 1 FROM nps_clients c WHERE c.client_name = ec.client_name
  );

  IF orphan_count > 0 THEN
    RAISE NOTICE 'WARNING: Found % orphaned segmentation_event_compliance records', orphan_count;
    RAISE NOTICE 'Run: SELECT DISTINCT client_name FROM segmentation_event_compliance WHERE client_name NOT IN (SELECT client_name FROM nps_clients);';
  ELSE
    RAISE NOTICE 'OK: No orphaned segmentation_event_compliance records';
  END IF;
END $$;

-- ============================================================================
-- 1. ADD FOREIGN KEY: nps_responses → nps_clients
-- ============================================================================

-- Drop existing constraint if it exists (idempotent)
ALTER TABLE nps_responses
DROP CONSTRAINT IF EXISTS fk_nps_responses_client CASCADE;

-- Add foreign key constraint
ALTER TABLE nps_responses
ADD CONSTRAINT fk_nps_responses_client
  FOREIGN KEY (client_name)
  REFERENCES nps_clients(client_name)
  ON DELETE RESTRICT  -- Prevent deleting clients with responses
  ON UPDATE CASCADE;  -- Update responses if client name changes

-- ============================================================================
-- 2. ADD FOREIGN KEY: unified_meetings → nps_clients
-- ============================================================================

-- Drop existing constraint if it exists (idempotent)
ALTER TABLE unified_meetings
DROP CONSTRAINT IF EXISTS fk_unified_meetings_client CASCADE;

-- Add foreign key constraint
ALTER TABLE unified_meetings
ADD CONSTRAINT fk_unified_meetings_client
  FOREIGN KEY (client_name)
  REFERENCES nps_clients(client_name)
  ON DELETE RESTRICT  -- Prevent deleting clients with meetings
  ON UPDATE CASCADE;  -- Update meetings if client name changes

-- ============================================================================
-- 3. ADD FOREIGN KEY: actions → nps_clients
-- ============================================================================

-- Drop existing constraint if it exists (idempotent)
ALTER TABLE actions
DROP CONSTRAINT IF EXISTS fk_actions_client CASCADE;

-- Add foreign key constraint
-- Note: actions.Client uses PascalCase while nps_clients.client_name uses snake_case
ALTER TABLE actions
ADD CONSTRAINT fk_actions_client
  FOREIGN KEY ("Client")
  REFERENCES nps_clients(client_name)
  ON DELETE RESTRICT  -- Prevent deleting clients with open actions
  ON UPDATE CASCADE;  -- Update actions if client name changes

-- ============================================================================
-- 4. ADD FOREIGN KEY: segmentation_events → nps_clients
-- ============================================================================

-- Drop existing constraint if it exists (idempotent)
ALTER TABLE segmentation_events
DROP CONSTRAINT IF EXISTS fk_segmentation_events_client CASCADE;

-- Add foreign key constraint
ALTER TABLE segmentation_events
ADD CONSTRAINT fk_segmentation_events_client
  FOREIGN KEY (client_name)
  REFERENCES nps_clients(client_name)
  ON DELETE RESTRICT  -- Prevent deleting clients with events
  ON UPDATE CASCADE;  -- Update events if client name changes

-- ============================================================================
-- 5. ADD FOREIGN KEY: segmentation_event_compliance → nps_clients
-- ============================================================================

-- Drop existing constraint if it exists (idempotent)
ALTER TABLE segmentation_event_compliance
DROP CONSTRAINT IF EXISTS fk_event_compliance_client CASCADE;

-- Add foreign key constraint
ALTER TABLE segmentation_event_compliance
ADD CONSTRAINT fk_event_compliance_client
  FOREIGN KEY (client_name)
  REFERENCES nps_clients(client_name)
  ON DELETE RESTRICT  -- Prevent deleting clients with compliance records
  ON UPDATE CASCADE;  -- Update compliance if client name changes

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- After running this migration, verify all constraints were created:
--
-- List all foreign key constraints:
-- SELECT
--   tc.table_name,
--   tc.constraint_name,
--   tc.constraint_type,
--   kcu.column_name,
--   ccu.table_name AS foreign_table_name,
--   ccu.column_name AS foreign_column_name,
--   rc.update_rule,
--   rc.delete_rule
-- FROM information_schema.table_constraints tc
-- JOIN information_schema.key_column_usage kcu
--   ON tc.constraint_name = kcu.constraint_name
-- JOIN information_schema.constraint_column_usage ccu
--   ON ccu.constraint_name = tc.constraint_name
-- JOIN information_schema.referential_constraints rc
--   ON rc.constraint_name = tc.constraint_name
-- WHERE tc.constraint_type = 'FOREIGN KEY'
--   AND tc.table_schema = 'public'
--   AND ccu.table_name = 'nps_clients'
-- ORDER BY tc.table_name;
--
-- Expected: 5 constraints
--   1. nps_responses → nps_clients (client_name)
--   2. unified_meetings → nps_clients (client_name)
--   3. actions → nps_clients (Client)
--   4. segmentation_events → nps_clients (client_name)
--   5. segmentation_event_compliance → nps_clients (client_name)

-- ============================================================================
-- CONSTRAINT BEHAVIOR REFERENCE
-- ============================================================================

-- ON DELETE options:
-- - RESTRICT: Prevents deletion if child records exist (safest, default)
-- - CASCADE: Automatically deletes child records when parent is deleted
-- - SET NULL: Sets foreign key to NULL when parent is deleted
-- - SET DEFAULT: Sets foreign key to default value when parent is deleted
-- - NO ACTION: Similar to RESTRICT but deferrable
--
-- ON UPDATE options:
-- - CASCADE: Automatically updates child records when parent key changes
-- - RESTRICT: Prevents update if child records exist
-- - SET NULL: Sets foreign key to NULL when parent key changes
-- - SET DEFAULT: Sets foreign key to default value when parent key changes
-- - NO ACTION: Similar to RESTRICT but deferrable
--
-- Our choice: RESTRICT on DELETE, CASCADE on UPDATE
-- Reasoning:
-- - RESTRICT prevents accidental data loss (must explicitly handle child records)
-- - CASCADE on UPDATE maintains consistency if client names are corrected

-- ============================================================================
-- PERFORMANCE CONSIDERATIONS
-- ============================================================================

-- Benefits:
-- 1. Query Optimizer Improvements:
--    - PostgreSQL can use constraint information for better execution plans
--    - Enables merge joins instead of hash joins in some cases
--    - Can eliminate redundant existence checks
--
-- 2. Index Usage:
--    - Foreign keys work with existing indexes on client_name columns
--    - Our composite indexes already cover these columns
--
-- 3. Data Integrity:
--    - Prevents orphaned records at database level
--    - Catches application bugs that violate relationships
--
-- Overhead:
-- - Constraint checking on INSERT/UPDATE (minimal ~1-5ms per operation)
-- - Storage for constraint metadata (negligible)
-- - Worth the trade-off for data integrity and query optimization

-- ============================================================================
-- TROUBLESHOOTING
-- ============================================================================

-- If constraint creation fails with:
-- ERROR: insert or update on table "X" violates foreign key constraint "fk_Y"
-- DETAIL: Key (column)=(value) is not present in table "nps_clients"
--
-- Solution: Fix orphaned records first
-- 1. Identify orphaned records using queries above
-- 2. Either:
--    a) Add missing clients to nps_clients table, OR
--    b) Delete orphaned records, OR
--    c) Update records to reference existing clients
--
-- Example: Find and fix orphaned actions
-- SELECT DISTINCT "Client" FROM actions
-- WHERE "Client" NOT IN (SELECT client_name FROM nps_clients)
--   AND "Client" IS NOT NULL;
--
-- Fix by inserting missing client:
-- INSERT INTO nps_clients (client_name, segment)
-- VALUES ('Missing Client Name', 'Enterprise');
--
-- Or update to existing client:
-- UPDATE actions SET "Client" = 'Correct Client Name'
-- WHERE "Client" = 'Typo Client Name';

-- ============================================================================
-- ROLLBACK INSTRUCTIONS
-- ============================================================================

-- To remove all foreign key constraints:
--
-- ALTER TABLE nps_responses DROP CONSTRAINT IF EXISTS fk_nps_responses_client;
-- ALTER TABLE unified_meetings DROP CONSTRAINT IF EXISTS fk_unified_meetings_client;
-- ALTER TABLE actions DROP CONSTRAINT IF EXISTS fk_actions_client;
-- ALTER TABLE segmentation_events DROP CONSTRAINT IF EXISTS fk_segmentation_events_client;
-- ALTER TABLE segmentation_event_compliance DROP CONSTRAINT IF EXISTS fk_event_compliance_client;
--
-- Verify removal:
-- SELECT constraint_name FROM information_schema.table_constraints
-- WHERE constraint_type = 'FOREIGN KEY'
--   AND table_schema = 'public'
--   AND constraint_name LIKE 'fk_%_client';
-- Expected: 0 rows

-- ============================================================================
-- FUTURE ENHANCEMENTS
-- ============================================================================

-- Additional foreign keys to consider:
--
-- 1. Event Type Relationships:
--    ALTER TABLE segmentation_events
--    ADD CONSTRAINT fk_events_event_type
--      FOREIGN KEY (event_type_id)
--      REFERENCES segmentation_event_types(id);
--
-- 2. Tier Relationships:
--    ALTER TABLE tier_event_requirements
--    ADD CONSTRAINT fk_requirements_tier
--      FOREIGN KEY (tier_id)
--      REFERENCES segmentation_tiers(id);
--
-- 3. CSE Assignment Relationships:
--    -- Requires creating a users/cse table first
--    -- ALTER TABLE nps_clients
--    -- ADD CONSTRAINT fk_clients_cse
--    --   FOREIGN KEY (cse)
--    --   REFERENCES users(email);
--
-- 4. Action Owner Relationships:
--    -- Requires normalizing owners table first
--    -- ALTER TABLE actions
--    -- ADD CONSTRAINT fk_actions_owner
--    --   FOREIGN KEY ("Owner")
--    --   REFERENCES users(email);

-- ============================================================================
-- NOTES
-- ============================================================================

-- Data Integrity vs Flexibility Trade-off:
-- - Foreign keys enforce strict relationships at database level
-- - Prevents invalid data but may complicate migrations
-- - Use RESTRICT carefully to avoid blocking legitimate operations
--
-- Client Name as Foreign Key:
-- - Using client_name (TEXT) instead of integer ID
-- - Works well for small datasets (<10,000 clients)
-- - Consider adding surrogate key (client_id INTEGER) for larger datasets
--
-- Cascade Behavior:
-- - ON UPDATE CASCADE: Safe for name corrections
-- - ON DELETE RESTRICT: Prevents accidental data loss
-- - Review cascade rules before running in production
--
-- Testing:
-- - Test constraint behavior in development first
-- - Verify existing data satisfies constraints
-- - Have rollback plan ready
