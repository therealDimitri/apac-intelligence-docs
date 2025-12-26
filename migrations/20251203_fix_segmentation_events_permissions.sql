-- Fix permissions on segmentation_events table
-- Disable RLS entirely for this internal-only table
ALTER TABLE public.segmentation_events DISABLE ROW LEVEL SECURITY;

-- Grant full select access to anon and authenticated roles
GRANT SELECT ON TABLE public.segmentation_events TO anon;
GRANT SELECT ON TABLE public.segmentation_events TO authenticated;
GRANT SELECT ON TABLE public.segmentation_events TO service_role;

-- Verify by querying
SELECT
  tablename,
  rowsecurity AS "RLS Enabled"
FROM pg_tables
WHERE tablename = 'segmentation_events' AND schemaname = 'public';
