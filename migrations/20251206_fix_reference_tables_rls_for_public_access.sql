-- ===========================================================================
-- Fix Reference Tables RLS for Public Access
-- Created: 2024-12-06
-- Purpose: Fix departments and activity_types RLS policies to allow public/anon access
-- Issue: Edit Meeting Modal dropdowns empty because policies only allow authenticated
-- Solution: Add policies for anon/public role
-- ===========================================================================

-- Fix departments table - add public/anon SELECT policy
DROP POLICY IF EXISTS "Allow public read access to departments" ON departments;
CREATE POLICY "Allow public read access to departments"
  ON departments
  FOR SELECT
  TO anon, public
  USING (true);

-- Fix activity_types table - add public/anon SELECT policy
DROP POLICY IF EXISTS "Allow public read access to activity_types" ON activity_types;
CREATE POLICY "Allow public read access to activity_types"
  ON activity_types
  FOR SELECT
  TO anon, public
  USING (true);

-- Verification query (run after applying):
-- SELECT policyname, tablename, roles::text[], cmd
-- FROM pg_policies
-- WHERE tablename IN ('departments', 'activity_types')
-- ORDER BY tablename, policyname;
