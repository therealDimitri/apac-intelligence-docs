-- Migration: Add DELETE policies for unified_meetings
-- Date: 2025-12-06
-- Issue: Meeting delete buttons don't work - missing DELETE RLS policy
-- Solution: Add two policies - one for CSEs (client-scoped) and one for superusers (unrestricted)

-- Drop old policies if they exist (in case of re-run)
DROP POLICY IF EXISTS "CSE can delete their clients' meetings" ON unified_meetings;
DROP POLICY IF EXISTS "Authenticated users can delete all meetings" ON unified_meetings;
DROP POLICY IF EXISTS "Superuser can delete all meetings" ON unified_meetings;

-- Policy 1: CSEs can delete meetings for their assigned clients only
CREATE POLICY "CSE can delete their clients' meetings"
  ON unified_meetings
  FOR DELETE
  TO authenticated
  USING (
    client_name IN (
      SELECT client_name FROM nps_clients WHERE cse = current_user
    )
  );

-- Policy 2: Superusers can delete all meetings
CREATE POLICY "Superuser can delete all meetings"
  ON unified_meetings
  FOR DELETE
  TO authenticated
  USING (
    current_user IN ('dimitri.leimonitis@alterahealth.com')
  );

-- Verification query (commented out - for manual testing):
-- SELECT policyname, cmd
-- FROM pg_policies
-- WHERE tablename = 'unified_meetings'
-- ORDER BY cmd;
--
-- Expected: Should see 6 policies:
-- - SELECT: "CSE can view their clients' meetings"
-- - INSERT: "CSE can create meetings for their clients"
-- - UPDATE: "CSE can update their clients' meetings"
-- - DELETE: "CSE can delete their clients' meetings" (NEW - client-scoped)
-- - DELETE: "Superuser can delete all meetings" (NEW - unrestricted)
-- - ALL: "Service role full access unified_meetings"
