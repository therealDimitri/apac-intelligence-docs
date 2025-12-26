-- Disable RLS on segmentation_events - this is internal data that should be publicly readable
ALTER TABLE segmentation_events DISABLE ROW LEVEL SECURITY;
