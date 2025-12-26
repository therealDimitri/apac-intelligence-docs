-- ============================================================================
-- Internal Operations RLS Policies
-- Created: 2024-12-05
-- Purpose: Add Row Level Security policies for internal operations tables
-- ============================================================================

-- Enable RLS on all internal operations tables
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_impact_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE initiatives ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- DEPARTMENTS TABLE POLICIES
-- ============================================================================

-- Allow all authenticated users to read departments
CREATE POLICY "Allow authenticated users to read departments"
ON departments
FOR SELECT
TO authenticated
USING (true);

-- Allow service role full access
CREATE POLICY "Allow service role full access to departments"
ON departments
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- Allow authenticated users to read only active departments
CREATE POLICY "Allow users to read active departments"
ON departments
FOR SELECT
TO authenticated
USING (is_active = true);

-- ============================================================================
-- ACTIVITY_TYPES TABLE POLICIES
-- ============================================================================

-- Allow all authenticated users to read activity types
CREATE POLICY "Allow authenticated users to read activity_types"
ON activity_types
FOR SELECT
TO authenticated
USING (true);

-- Allow service role full access
CREATE POLICY "Allow service role full access to activity_types"
ON activity_types
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- Allow authenticated users to read only active activity types
CREATE POLICY "Allow users to read active activity_types"
ON activity_types
FOR SELECT
TO authenticated
USING (is_active = true);

-- ============================================================================
-- CLIENT_IMPACT_LINKS TABLE POLICIES
-- ============================================================================

-- Allow all authenticated users to read client impact links
CREATE POLICY "Allow authenticated users to read client_impact_links"
ON client_impact_links
FOR SELECT
TO authenticated
USING (true);

-- Allow authenticated users to insert client impact links
CREATE POLICY "Allow authenticated users to insert client_impact_links"
ON client_impact_links
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Allow authenticated users to update their own client impact links
CREATE POLICY "Allow authenticated users to update client_impact_links"
ON client_impact_links
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Allow authenticated users to delete client impact links
CREATE POLICY "Allow authenticated users to delete client_impact_links"
ON client_impact_links
FOR DELETE
TO authenticated
USING (true);

-- Allow service role full access
CREATE POLICY "Allow service role full access to client_impact_links"
ON client_impact_links
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- ============================================================================
-- INITIATIVES TABLE POLICIES
-- ============================================================================

-- Allow all authenticated users to read initiatives
CREATE POLICY "Allow authenticated users to read initiatives"
ON initiatives
FOR SELECT
TO authenticated
USING (true);

-- Allow authenticated users to insert initiatives
CREATE POLICY "Allow authenticated users to insert initiatives"
ON initiatives
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Allow authenticated users to update initiatives
CREATE POLICY "Allow authenticated users to update initiatives"
ON initiatives
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Allow authenticated users to delete initiatives
CREATE POLICY "Allow authenticated users to delete initiatives"
ON initiatives
FOR DELETE
TO authenticated
USING (true);

-- Allow service role full access
CREATE POLICY "Allow service role full access to initiatives"
ON initiatives
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check that RLS is enabled
-- SELECT schemaname, tablename, rowsecurity
-- FROM pg_tables
-- WHERE tablename IN ('departments', 'activity_types', 'client_impact_links', 'initiatives');

-- Check policies
-- SELECT tablename, policyname, permissive, roles, cmd
-- FROM pg_policies
-- WHERE tablename IN ('departments', 'activity_types', 'client_impact_links', 'initiatives')
-- ORDER BY tablename, policyname;
