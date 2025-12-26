-- Migration: Fix Actions Table RLS Policies for Anon Role
-- Date: 2025-12-15
-- Issue: Delete actions failing because RLS policies only allow 'authenticated' role
--        but app uses anon key without auth session
-- Solution: Add matching policies for 'anon' role

-- Drop existing anon policies if any
DROP POLICY IF EXISTS "Allow anon read actions" ON public.actions;
DROP POLICY IF EXISTS "Allow anon insert actions" ON public.actions;
DROP POLICY IF EXISTS "Allow anon update actions" ON public.actions;
DROP POLICY IF EXISTS "Allow anon delete actions" ON public.actions;

-- Policy 1: Allow anon users to read all actions
CREATE POLICY "Allow anon read actions"
  ON public.actions
  FOR SELECT
  TO anon
  USING (true);

-- Policy 2: Allow anon users to create actions
CREATE POLICY "Allow anon insert actions"
  ON public.actions
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Policy 3: Allow anon users to update actions
CREATE POLICY "Allow anon update actions"
  ON public.actions
  FOR UPDATE
  TO anon
  USING (true)
  WITH CHECK (true);

-- Policy 4: Allow anon users to delete actions
CREATE POLICY "Allow anon delete actions"
  ON public.actions
  FOR DELETE
  TO anon
  USING (true);

-- Verification query:
-- SELECT policyname, cmd, roles FROM pg_policies WHERE tablename = 'actions' ORDER BY policyname;
