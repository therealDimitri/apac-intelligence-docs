-- Migration: NPS Insights Cache Table
-- Description: Cache ChaSen-generated NPS insights to avoid regenerating on every page load
-- Date: 2025-12-03

-- Create nps_insights_cache table
CREATE TABLE IF NOT EXISTS nps_insights_cache (
  id SERIAL PRIMARY KEY,
  client_name TEXT NOT NULL,
  nps_score INTEGER NOT NULL,
  previous_score INTEGER,

  -- Insight fields
  trend TEXT NOT NULL CHECK (trend IN ('improving', 'declining', 'stable', 'volatile')),
  confidence TEXT NOT NULL CHECK (confidence IN ('high', 'medium', 'low')),
  summary TEXT NOT NULL,
  key_factors JSONB NOT NULL DEFAULT '[]'::jsonb,
  recommendation TEXT NOT NULL,
  risk_level TEXT NOT NULL CHECK (risk_level IN ('critical', 'high', 'medium', 'low')),

  -- Cache metadata
  nps_period TEXT,
  generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(client_name, nps_period)
);

-- Index for fast lookups
CREATE INDEX IF NOT EXISTS idx_nps_insights_cache_client ON nps_insights_cache(client_name);
CREATE INDEX IF NOT EXISTS idx_nps_insights_cache_expires ON nps_insights_cache(expires_at);

-- RLS Policies (allow all authenticated users to read, service role to write)
ALTER TABLE nps_insights_cache ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated users to read NPS insights cache" ON nps_insights_cache;
CREATE POLICY "Allow authenticated users to read NPS insights cache"
  ON nps_insights_cache
  FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Allow service role to manage NPS insights cache" ON nps_insights_cache;
CREATE POLICY "Allow service role to manage NPS insights cache"
  ON nps_insights_cache
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Function to clean up expired cache entries (run via cron job)
CREATE OR REPLACE FUNCTION clean_expired_nps_insights_cache()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM nps_insights_cache
  WHERE expires_at IS NOT NULL AND expires_at < NOW();
END;
$$;

COMMENT ON TABLE nps_insights_cache IS 'Cached ChaSen AI-generated NPS insights to improve performance';
COMMENT ON COLUMN nps_insights_cache.expires_at IS 'Cache expiry time - set to NULL for indefinite cache (until NPS data changes)';
