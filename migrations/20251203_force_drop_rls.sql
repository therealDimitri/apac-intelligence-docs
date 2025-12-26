-- Force drop all RLS policies on segmentation_events
DROP POLICY IF EXISTS "Allow public read access to segmentation_events" ON public.segmentation_events;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.segmentation_events;

-- Completely disable RLS
ALTER TABLE public.segmentation_events DISABLE ROW LEVEL SECURITY;

-- Revoke and re-grant to ensure clean state
REVOKE ALL ON public.segmentation_events FROM anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.segmentation_events TO anon, authenticated;
