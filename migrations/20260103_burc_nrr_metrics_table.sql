-- Migration: Create burc_nrr_metrics table for pre-computed NRR/GRR data
-- Date: 3 January 2026
-- Purpose: Store pre-computed NRR/GRR metrics to avoid 44+ second calculation times

-- Drop existing table if it exists
DROP TABLE IF EXISTS burc_nrr_metrics;

-- Create the NRR metrics table
CREATE TABLE burc_nrr_metrics (
  id SERIAL PRIMARY KEY,
  year INTEGER NOT NULL,
  nrr DECIMAL(5,1) NOT NULL,           -- Net Revenue Retention (e.g., 98.1)
  grr DECIMAL(5,1) NOT NULL,           -- Gross Revenue Retention (e.g., 76.2)
  expansion DECIMAL(15,2) NOT NULL,    -- Expansion revenue in USD
  contraction DECIMAL(15,2) NOT NULL,  -- Contraction revenue in USD
  churn DECIMAL(15,2) NOT NULL,        -- Churned revenue in USD
  new_business DECIMAL(15,2) NOT NULL, -- New business revenue in USD
  starting_revenue DECIMAL(15,2),      -- Starting ARR for the year
  ending_revenue DECIMAL(15,2),        -- Ending ARR for the year
  calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(year)
);

-- Add index for fast lookups
CREATE INDEX idx_burc_nrr_metrics_year ON burc_nrr_metrics(year);

-- Enable RLS
ALTER TABLE burc_nrr_metrics ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read
CREATE POLICY "Allow authenticated read access to burc_nrr_metrics"
  ON burc_nrr_metrics
  FOR SELECT
  TO authenticated
  USING (true);

-- Allow service role full access
CREATE POLICY "Allow service role full access to burc_nrr_metrics"
  ON burc_nrr_metrics
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Grant permissions
GRANT SELECT ON burc_nrr_metrics TO authenticated;
GRANT ALL ON burc_nrr_metrics TO service_role;
GRANT USAGE, SELECT ON SEQUENCE burc_nrr_metrics_id_seq TO service_role;

COMMENT ON TABLE burc_nrr_metrics IS 'Pre-computed NRR/GRR metrics by year to avoid timeout on production';
