-- Migration: Add skipped_outlook_events table
-- Purpose: Track Outlook events that users have explicitly skipped to prevent them from appearing in future syncs
-- Date: 2025-12-07

-- Create table to track skipped Outlook events
CREATE TABLE IF NOT EXISTS public.skipped_outlook_events (
  id BIGSERIAL PRIMARY KEY,
  outlook_event_id TEXT NOT NULL,
  user_email TEXT NOT NULL,
  skipped_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  reason TEXT,

  -- Constraints
  UNIQUE(outlook_event_id, user_email)
);

-- Add index for fast lookups by user
CREATE INDEX IF NOT EXISTS idx_skipped_outlook_events_user_email
ON public.skipped_outlook_events(user_email);

-- Add index for fast lookups by outlook_event_id
CREATE INDEX IF NOT EXISTS idx_skipped_outlook_events_outlook_id
ON public.skipped_outlook_events(outlook_event_id);

-- Add index for combined lookup (most common query pattern)
CREATE INDEX IF NOT EXISTS idx_skipped_outlook_events_user_event
ON public.skipped_outlook_events(user_email, outlook_event_id);

-- Enable RLS
ALTER TABLE public.skipped_outlook_events ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only see/manage their own skipped events
CREATE POLICY "Users can view their own skipped events"
ON public.skipped_outlook_events
FOR SELECT
USING (user_email = current_setting('request.jwt.claims', true)::json->>'email');

CREATE POLICY "Users can insert their own skipped events"
ON public.skipped_outlook_events
FOR INSERT
WITH CHECK (user_email = current_setting('request.jwt.claims', true)::json->>'email');

CREATE POLICY "Users can delete their own skipped events"
ON public.skipped_outlook_events
FOR DELETE
USING (user_email = current_setting('request.jwt.claims', true)::json->>'email');

-- Add helpful comment
COMMENT ON TABLE public.skipped_outlook_events IS 'Tracks Outlook calendar events that users have explicitly chosen to skip during import. These events will be filtered out of future sync operations.';
COMMENT ON COLUMN public.skipped_outlook_events.outlook_event_id IS 'The Outlook/Microsoft Graph API event ID';
COMMENT ON COLUMN public.skipped_outlook_events.user_email IS 'Email of the user who skipped this event';
COMMENT ON COLUMN public.skipped_outlook_events.skipped_at IS 'Timestamp when the event was skipped';
COMMENT ON COLUMN public.skipped_outlook_events.reason IS 'Optional reason for skipping (e.g., "Not a client meeting", "Internal only")';
