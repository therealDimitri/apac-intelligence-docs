-- Add table to realtime publication (if not already added)
ALTER PUBLICATION supabase_realtime ADD TABLE IF NOT EXISTS public.segmentation_events;

-- Ensure the PostgREST schema cache knows about permissions
NOTIFY pgrst, 'reload schema';
