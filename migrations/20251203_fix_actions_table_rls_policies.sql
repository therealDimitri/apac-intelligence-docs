-- Migration: Fix RLS Policies for actions Table
-- Date: 2025-12-03
-- Purpose: Add RLS policies to allow authenticated users to create/manage actions
-- Issue: RLS enabled but no policies = all access blocked (causing create action errors)

-- Drop existing policies if any
DROP POLICY IF EXISTS "Allow all operations for authenticated users" ON public.actions;
DROP POLICY IF EXISTS "Allow authenticated read actions" ON public.actions;
DROP POLICY IF EXISTS "Allow authenticated insert actions" ON public.actions;
DROP POLICY IF EXISTS "Allow authenticated update actions" ON public.actions;
DROP POLICY IF EXISTS "Allow authenticated delete actions" ON public.actions;
DROP POLICY IF EXISTS "Service role full access actions" ON public.actions;

-- Policy 1: Allow authenticated users to read all actions
CREATE POLICY "Allow authenticated read actions"
  ON public.actions
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy 2: Allow authenticated users to create actions
CREATE POLICY "Allow authenticated insert actions"
  ON public.actions
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Policy 3: Allow authenticated users to update actions
CREATE POLICY "Allow authenticated update actions"
  ON public.actions
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Policy 4: Allow authenticated users to delete actions
CREATE POLICY "Allow authenticated delete actions"
  ON public.actions
  FOR DELETE
  TO authenticated
  USING (true);

-- Policy 5: Service role full access (for migrations and backend operations)
CREATE POLICY "Service role full access actions"
  ON public.actions
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Add table comment
COMMENT ON TABLE public.actions IS
'Client success action items - RLS policies allow authenticated users full CRUD access';

-- Verification query (run after applying migration):
-- SELECT policyname, cmd, roles FROM pg_policies WHERE tablename = 'actions' ORDER BY policyname;
