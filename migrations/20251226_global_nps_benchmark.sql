-- Migration: Create global_nps_benchmark table for Q4 2025 Global NPS comparison
-- Created: 2025-12-26
-- Purpose: Store global Altera NPS data for benchmarking against APAC performance

-- Drop table if exists (for re-runs)
DROP TABLE IF EXISTS global_nps_benchmark;

-- Create global NPS benchmark table
CREATE TABLE global_nps_benchmark (
  id SERIAL PRIMARY KEY,
  score INTEGER NOT NULL CHECK (score >= 0 AND score <= 10),
  category TEXT NOT NULL CHECK (category IN ('Promoter', 'Passive', 'Detractor')),
  feedback TEXT,
  period TEXT NOT NULL DEFAULT 'Q4 25',
  region TEXT DEFAULT 'Global (excl. APAC)',
  is_apac_duplicate BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add indexes for common queries
CREATE INDEX idx_global_nps_period ON global_nps_benchmark(period);
CREATE INDEX idx_global_nps_category ON global_nps_benchmark(category);
CREATE INDEX idx_global_nps_region ON global_nps_benchmark(region);
CREATE INDEX idx_global_nps_score ON global_nps_benchmark(score);

-- Enable RLS
ALTER TABLE global_nps_benchmark ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read
CREATE POLICY "Allow authenticated read" ON global_nps_benchmark
  FOR SELECT TO authenticated USING (true);

-- Allow service role full access
CREATE POLICY "Allow service role all" ON global_nps_benchmark
  FOR ALL TO service_role USING (true);

-- Add table comment
COMMENT ON TABLE global_nps_benchmark IS 'Global Altera NPS benchmark data for comparison with APAC performance';
COMMENT ON COLUMN global_nps_benchmark.is_apac_duplicate IS 'True if this response was identified as matching an APAC response (based on verbatim similarity)';
COMMENT ON COLUMN global_nps_benchmark.region IS 'Region identifier - "Global (excl. APAC)" for non-APAC responses, "APAC (duplicate)" for matched APAC responses';
