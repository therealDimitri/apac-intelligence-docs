-- Grant schema usage and all permissions on segmentation_events
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON TABLE public.segmentation_events TO anon, authenticated;
ALTER TABLE public.segmentation_events OWNER TO postgres;
