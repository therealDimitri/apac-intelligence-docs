-- BURC Historical Analytics Cache Tables
-- Purpose: Pre-aggregate 85k+ records into fast-loading cache tables
-- Created: 3 January 2026

-- ============================================
-- Cache for yearly revenue trends
-- ============================================
CREATE TABLE IF NOT EXISTS burc_cache_revenue_trend (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  sw_revenue NUMERIC DEFAULT 0,
  ps_revenue NUMERIC DEFAULT 0,
  maint_revenue NUMERIC DEFAULT 0,
  hw_revenue NUMERIC DEFAULT 0,
  total_revenue NUMERIC DEFAULT 0,
  yoy_growth NUMERIC DEFAULT 0,
  cached_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(fiscal_year)
);

-- ============================================
-- Cache for client lifetime values
-- ============================================
CREATE TABLE IF NOT EXISTS burc_cache_client_lifetime (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  parent_company TEXT,
  years_active INTEGER DEFAULT 0,
  lifetime_revenue NUMERIC DEFAULT 0,
  revenue_2019 NUMERIC DEFAULT 0,
  revenue_2020 NUMERIC DEFAULT 0,
  revenue_2021 NUMERIC DEFAULT 0,
  revenue_2022 NUMERIC DEFAULT 0,
  revenue_2023 NUMERIC DEFAULT 0,
  revenue_2024 NUMERIC DEFAULT 0,
  revenue_2025 NUMERIC DEFAULT 0,
  yoy_growth NUMERIC DEFAULT 0,
  cached_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(client_name)
);

-- ============================================
-- Cache for concentration metrics
-- ============================================
CREATE TABLE IF NOT EXISTS burc_cache_concentration (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  total_clients INTEGER DEFAULT 0,
  total_revenue NUMERIC DEFAULT 0,
  top5_percent NUMERIC DEFAULT 0,
  top10_percent NUMERIC DEFAULT 0,
  top20_percent NUMERIC DEFAULT 0,
  hhi NUMERIC DEFAULT 0,
  risk_level TEXT DEFAULT 'Low',
  cached_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(fiscal_year)
);

-- ============================================
-- Cache for NRR/GRR metrics
-- ============================================
CREATE TABLE IF NOT EXISTS burc_cache_nrr (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  nrr NUMERIC DEFAULT 0,
  grr NUMERIC DEFAULT 0,
  expansion NUMERIC DEFAULT 0,
  contraction NUMERIC DEFAULT 0,
  churn NUMERIC DEFAULT 0,
  new_business NUMERIC DEFAULT 0,
  cached_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(fiscal_year)
);

-- ============================================
-- Cache metadata table
-- ============================================
CREATE TABLE IF NOT EXISTS burc_cache_metadata (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cache_key TEXT NOT NULL UNIQUE,
  last_refreshed TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  record_count INTEGER DEFAULT 0,
  total_revenue NUMERIC DEFAULT 0,
  notes TEXT
);

-- ============================================
-- Indexes for fast lookups
-- ============================================
CREATE INDEX IF NOT EXISTS idx_burc_cache_trend_year ON burc_cache_revenue_trend(fiscal_year);
CREATE INDEX IF NOT EXISTS idx_burc_cache_client_revenue ON burc_cache_client_lifetime(lifetime_revenue DESC);
CREATE INDEX IF NOT EXISTS idx_burc_cache_concentration_year ON burc_cache_concentration(fiscal_year);
CREATE INDEX IF NOT EXISTS idx_burc_cache_nrr_year ON burc_cache_nrr(fiscal_year);

-- ============================================
-- RLS Policies (read-only for authenticated users)
-- ============================================
ALTER TABLE burc_cache_revenue_trend ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_cache_client_lifetime ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_cache_concentration ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_cache_nrr ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_cache_metadata ENABLE ROW LEVEL SECURITY;

-- Allow all authenticated users to read cache
CREATE POLICY "Allow authenticated read on burc_cache_revenue_trend"
  ON burc_cache_revenue_trend FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated read on burc_cache_client_lifetime"
  ON burc_cache_client_lifetime FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated read on burc_cache_concentration"
  ON burc_cache_concentration FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated read on burc_cache_nrr"
  ON burc_cache_nrr FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated read on burc_cache_metadata"
  ON burc_cache_metadata FOR SELECT TO authenticated USING (true);

-- Allow service role to write (for cache refresh)
CREATE POLICY "Allow service role write on burc_cache_revenue_trend"
  ON burc_cache_revenue_trend FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Allow service role write on burc_cache_client_lifetime"
  ON burc_cache_client_lifetime FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Allow service role write on burc_cache_concentration"
  ON burc_cache_concentration FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Allow service role write on burc_cache_nrr"
  ON burc_cache_nrr FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE POLICY "Allow service role write on burc_cache_metadata"
  ON burc_cache_metadata FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Grant anon read access for unauthenticated API calls
CREATE POLICY "Allow anon read on burc_cache_revenue_trend"
  ON burc_cache_revenue_trend FOR SELECT TO anon USING (true);

CREATE POLICY "Allow anon read on burc_cache_client_lifetime"
  ON burc_cache_client_lifetime FOR SELECT TO anon USING (true);

CREATE POLICY "Allow anon read on burc_cache_concentration"
  ON burc_cache_concentration FOR SELECT TO anon USING (true);

CREATE POLICY "Allow anon read on burc_cache_nrr"
  ON burc_cache_nrr FOR SELECT TO anon USING (true);

CREATE POLICY "Allow anon read on burc_cache_metadata"
  ON burc_cache_metadata FOR SELECT TO anon USING (true);
