-- ===========================================================================
-- Fix Reference Tables RLS for All Roles (Complete Fix)
-- Created: 2024-12-17
-- Purpose: Fix departments, activity_types, and client_health_summary RLS
-- Issue: Dropdowns empty because policies only allow authenticated role
-- Solution: Add policies for anon/public role on all reference tables
-- ===========================================================================

-- Fix departments table
-- First disable RLS to see if that's the issue, then re-enable with proper policies
DO $$
BEGIN
  -- Drop existing restrictive policies
  DROP POLICY IF EXISTS "Allow authenticated users to read departments" ON departments;
  DROP POLICY IF EXISTS "Allow users to read active departments" ON departments;
  DROP POLICY IF EXISTS "Allow public read access to departments" ON departments;
  DROP POLICY IF EXISTS "Allow anon to read departments" ON departments;
EXCEPTION
  WHEN undefined_object THEN NULL;
  WHEN undefined_table THEN NULL;
END $$;

-- Create permissive policy for departments
CREATE POLICY "departments_public_read"
  ON departments
  FOR SELECT
  TO anon, authenticated, public
  USING (true);

-- Fix activity_types table
DO $$
BEGIN
  DROP POLICY IF EXISTS "Allow authenticated users to read activity_types" ON activity_types;
  DROP POLICY IF EXISTS "Allow users to read active activity_types" ON activity_types;
  DROP POLICY IF EXISTS "Allow public read access to activity_types" ON activity_types;
  DROP POLICY IF EXISTS "Allow anon to read activity_types" ON activity_types;
EXCEPTION
  WHEN undefined_object THEN NULL;
  WHEN undefined_table THEN NULL;
END $$;

-- Create permissive policy for activity_types
CREATE POLICY "activity_types_public_read"
  ON activity_types
  FOR SELECT
  TO anon, authenticated, public
  USING (true);

-- Grant SELECT permissions explicitly
GRANT SELECT ON departments TO anon;
GRANT SELECT ON departments TO authenticated;
GRANT SELECT ON activity_types TO anon;
GRANT SELECT ON activity_types TO authenticated;

-- Fix client_health_summary materialized view
-- Materialized views don't have RLS, but we need to grant permissions
DO $$
BEGIN
  GRANT SELECT ON client_health_summary TO anon;
  GRANT SELECT ON client_health_summary TO authenticated;
EXCEPTION
  WHEN undefined_object THEN NULL;
  WHEN undefined_table THEN NULL;
END $$;

-- Also grant on client_impact_links for the ClientImpactSelector
DO $$
BEGIN
  DROP POLICY IF EXISTS "Allow public read access to client_impact_links" ON client_impact_links;
EXCEPTION
  WHEN undefined_object THEN NULL;
  WHEN undefined_table THEN NULL;
END $$;

CREATE POLICY IF NOT EXISTS "client_impact_links_public_read"
  ON client_impact_links
  FOR SELECT
  TO anon, authenticated, public
  USING (true);

GRANT SELECT ON client_impact_links TO anon;
GRANT SELECT ON client_impact_links TO authenticated;

-- Verification queries
SELECT 'RLS Policies for departments:' AS info;
SELECT policyname, roles::text[], cmd
FROM pg_policies
WHERE tablename = 'departments'
ORDER BY policyname;

SELECT 'RLS Policies for activity_types:' AS info;
SELECT policyname, roles::text[], cmd
FROM pg_policies
WHERE tablename = 'activity_types'
ORDER BY policyname;

-- Test queries to verify access
SELECT 'Testing departments access:' AS info, COUNT(*) AS count FROM departments;
SELECT 'Testing activity_types access:' AS info, COUNT(*) AS count FROM activity_types;
SELECT 'Testing client_health_summary access:' AS info, COUNT(*) AS count FROM client_health_summary;
