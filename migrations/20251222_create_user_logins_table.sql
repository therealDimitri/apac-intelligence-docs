-- Migration: Create user_logins table for tracking Azure AD sign-ins
-- Date: 2025-12-22
-- Purpose: Track when users sign in via Azure AD/NextAuth

-- Create user_logins table
CREATE TABLE IF NOT EXISTS user_logins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_email TEXT NOT NULL,
  user_name TEXT,
  provider TEXT DEFAULT 'azure-ad',
  ip_address TEXT,
  user_agent TEXT,
  signed_in_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster lookups by email
CREATE INDEX IF NOT EXISTS idx_user_logins_email ON user_logins(user_email);

-- Create index for time-based queries (most recent first)
CREATE INDEX IF NOT EXISTS idx_user_logins_signed_in_at ON user_logins(signed_in_at DESC);

-- Enable RLS
ALTER TABLE user_logins ENABLE ROW LEVEL SECURITY;

-- Policy: Service role can do everything (for API inserts)
DROP POLICY IF EXISTS "Service role full access" ON user_logins;
CREATE POLICY "Service role full access" ON user_logins
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Comment on table
COMMENT ON TABLE user_logins IS 'Tracks user sign-ins via Azure AD/NextAuth';
