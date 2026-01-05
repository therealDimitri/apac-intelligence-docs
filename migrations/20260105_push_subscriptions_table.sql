-- Migration: Create push_subscriptions table
-- Date: 2026-01-05
-- Description: Store push notification subscriptions for users

CREATE TABLE IF NOT EXISTS push_subscriptions (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id text NOT NULL,
  user_email text NOT NULL,
  subscription jsonb NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT push_subscriptions_user_id_unique UNIQUE(user_id)
);

-- Create index on user_id for faster lookups
CREATE INDEX IF NOT EXISTS push_subscriptions_user_id_idx ON push_subscriptions(user_id);

-- Create index on user_email for filtering
CREATE INDEX IF NOT EXISTS push_subscriptions_user_email_idx ON push_subscriptions(user_email);

-- Enable Row Level Security
ALTER TABLE push_subscriptions ENABLE ROW LEVEL SECURITY;

-- Create policy: Users can view their own subscriptions
CREATE POLICY "Users can view their own push subscriptions"
  ON push_subscriptions
  FOR SELECT
  USING (auth.uid()::text = user_id);

-- Create policy: Users can insert their own subscriptions
CREATE POLICY "Users can insert their own push subscriptions"
  ON push_subscriptions
  FOR INSERT
  WITH CHECK (auth.uid()::text = user_id);

-- Create policy: Users can update their own subscriptions
CREATE POLICY "Users can update their own push subscriptions"
  ON push_subscriptions
  FOR UPDATE
  USING (auth.uid()::text = user_id)
  WITH CHECK (auth.uid()::text = user_id);

-- Create policy: Users can delete their own subscriptions
CREATE POLICY "Users can delete their own push subscriptions"
  ON push_subscriptions
  FOR DELETE
  USING (auth.uid()::text = user_id);

-- Create policy: Service role can perform all operations
CREATE POLICY "Service role can manage all push subscriptions"
  ON push_subscriptions
  FOR ALL
  USING (current_setting('request.jwt.claims', true)::json->>'role' = 'service_role')
  WITH CHECK (current_setting('request.jwt.claims', true)::json->>'role' = 'service_role');

-- Add trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_push_subscriptions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_push_subscriptions_updated_at
  BEFORE UPDATE ON push_subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION update_push_subscriptions_updated_at();

-- Add comment to table
COMMENT ON TABLE push_subscriptions IS 'Stores push notification subscriptions for users';
COMMENT ON COLUMN push_subscriptions.id IS 'Unique identifier for the subscription';
COMMENT ON COLUMN push_subscriptions.user_id IS 'User ID from authentication system';
COMMENT ON COLUMN push_subscriptions.user_email IS 'User email address';
COMMENT ON COLUMN push_subscriptions.subscription IS 'Web Push API subscription object (JSON)';
COMMENT ON COLUMN push_subscriptions.created_at IS 'Timestamp when subscription was created';
COMMENT ON COLUMN push_subscriptions.updated_at IS 'Timestamp when subscription was last updated';
