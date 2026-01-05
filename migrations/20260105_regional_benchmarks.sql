-- Migration: Regional Benchmarks Table
-- Created: 2026-01-05
-- Purpose: Store cross-region benchmark data for comparing APAC performance against other global regions
-- Features: Supports multiple regions, time periods, metrics with targets and historical values

-- Create regional_benchmarks table
CREATE TABLE IF NOT EXISTS regional_benchmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  region VARCHAR(20) NOT NULL CHECK (region IN ('APAC', 'EMEA', 'Americas', 'Global')),
  period VARCHAR(20) NOT NULL, -- Format: 2025-Q4, 2025-YTD, 2025-FY
  metric_name VARCHAR(50) NOT NULL CHECK (metric_name IN (
    'NRR', 'GRR', 'Rule of 40', 'DSO', 'Churn Rate', 'ARR Growth',
    'Customer Acquisition Cost', 'Lifetime Value', 'Revenue per Client',
    'Gross Margin', 'Operating Margin', 'EBITDA Margin'
  )),
  metric_value NUMERIC(15,2) NOT NULL,
  target_value NUMERIC(15,2),
  previous_value NUMERIC(15,2),
  unit VARCHAR(10) DEFAULT '%', -- %, $, days, ratio
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Ensure unique combination of region, period, and metric
  CONSTRAINT unique_region_period_metric UNIQUE (region, period, metric_name)
);

-- Create index for faster queries
CREATE INDEX idx_regional_benchmarks_region ON regional_benchmarks(region);
CREATE INDEX idx_regional_benchmarks_period ON regional_benchmarks(period);
CREATE INDEX idx_regional_benchmarks_metric ON regional_benchmarks(metric_name);
CREATE INDEX idx_regional_benchmarks_region_period ON regional_benchmarks(region, period);

-- Enable RLS (Row Level Security)
ALTER TABLE regional_benchmarks ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all authenticated users to read benchmark data
CREATE POLICY "Allow authenticated users to read benchmarks"
  ON regional_benchmarks
  FOR SELECT
  TO authenticated
  USING (true);

-- Create policy to allow service role to insert/update benchmark data
CREATE POLICY "Allow service role to manage benchmarks"
  ON regional_benchmarks
  FOR ALL
  TO service_role
  USING (true);

-- Add comment to table
COMMENT ON TABLE regional_benchmarks IS 'Stores regional benchmark data for cross-region performance comparison';

-- Add comments to key columns
COMMENT ON COLUMN regional_benchmarks.region IS 'Geographic region: APAC, EMEA, Americas, or Global aggregate';
COMMENT ON COLUMN regional_benchmarks.period IS 'Time period in format: YYYY-Q#, YYYY-YTD, or YYYY-FY';
COMMENT ON COLUMN regional_benchmarks.metric_name IS 'Name of the performance metric being tracked';
COMMENT ON COLUMN regional_benchmarks.metric_value IS 'Current value of the metric for this region/period';
COMMENT ON COLUMN regional_benchmarks.target_value IS 'Target or goal value for this metric';
COMMENT ON COLUMN regional_benchmarks.previous_value IS 'Previous period value for trend comparison';
COMMENT ON COLUMN regional_benchmarks.unit IS 'Unit of measurement: %, $, days, ratio, etc.';
