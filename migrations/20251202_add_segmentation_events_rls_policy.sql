-- Migration: Add RLS policy for segmentation_events table
-- Date: 2025-12-02
-- Issue: Client-side queries returning 0 events despite data existing in table
-- Root cause: RLS enabled on table but no policy allowing anonymous read access

-- Enable RLS on segmentation_events table (if not already enabled)
ALTER TABLE segmentation_events ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all users to read segmentation events
-- This is safe because segmentation events are not sensitive data
CREATE POLICY "Allow public read access to segmentation events"
ON segmentation_events
FOR SELECT
TO public
USING (true);

-- Verify the policy was created
SELECT
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE tablename = 'segmentation_events';
