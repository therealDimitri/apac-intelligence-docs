-- Migration: Enhanced Health Score v6.0 - 6-Component System
-- Date: 2026-01-05
-- Description: Add support for enhanced health scoring with 6 components across 4 categories
--
-- NEW FORMULA (v6.0):
-- ENGAGEMENT (30 points):
--   - NPS Score: 15%
--   - Compliance Rate: 15%
-- FINANCIAL HEALTH (40 points):
--   - AR Aging: 10%
--   - Revenue Trend: 15%
--   - Contract Status: 15%
-- OPERATIONAL (20 points):
--   - Actions Completion: 10%
--   - Support Health: 10%
-- STRATEGIC (10 points):
--   - Expansion Potential: 10%
--
-- BACKWARD COMPATIBILITY: This migration adds new tables/columns without breaking v4.0 scoring.
-- The existing client_health_summary view continues to use v4.0 formula.
-- New v6.0 scoring will be available through application layer initially.

-- ============================================================================
-- STEP 1: Add new columns to client_health_history for v6.0 component tracking
-- ============================================================================

-- Check if columns already exist before adding
DO $$
BEGIN
  -- Add v6.0 component breakdown columns (nullable for backward compatibility)
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'client_health_history' AND column_name = 'health_score_version') THEN
    ALTER TABLE client_health_history ADD COLUMN health_score_version TEXT DEFAULT '4.0';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'client_health_history' AND column_name = 'actions_points') THEN
    ALTER TABLE client_health_history ADD COLUMN actions_points INTEGER;
  END IF;

  -- v6.0 specific columns (all nullable, only populated when using v6.0 scoring)
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'client_health_history' AND column_name = 'revenue_trend_points') THEN
    ALTER TABLE client_health_history ADD COLUMN revenue_trend_points INTEGER;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'client_health_history' AND column_name = 'contract_status_points') THEN
    ALTER TABLE client_health_history ADD COLUMN contract_status_points INTEGER;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'client_health_history' AND column_name = 'support_health_points') THEN
    ALTER TABLE client_health_history ADD COLUMN support_health_points INTEGER;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'client_health_history' AND column_name = 'expansion_points') THEN
    ALTER TABLE client_health_history ADD COLUMN expansion_points INTEGER;
  END IF;

  -- Add metadata columns for v6.0 insights
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'client_health_history' AND column_name = 'primary_concern_category') THEN
    ALTER TABLE client_health_history ADD COLUMN primary_concern_category TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'client_health_history' AND column_name = 'revenue_growth_percentage') THEN
    ALTER TABLE client_health_history ADD COLUMN revenue_growth_percentage NUMERIC;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'client_health_history' AND column_name = 'renewal_risk_level') THEN
    ALTER TABLE client_health_history ADD COLUMN renewal_risk_level TEXT;
  END IF;
END $$;

COMMENT ON COLUMN client_health_history.health_score_version IS 'Health score formula version (4.0 or 6.0)';
COMMENT ON COLUMN client_health_history.actions_points IS 'Points from actions completion (v4.0: 10pts, v6.0: 10pts)';
COMMENT ON COLUMN client_health_history.revenue_trend_points IS 'v6.0 only: Points from revenue growth trend (0-15)';
COMMENT ON COLUMN client_health_history.contract_status_points IS 'v6.0 only: Points from contract renewal risk (0-15)';
COMMENT ON COLUMN client_health_history.support_health_points IS 'v6.0 only: Points from support ticket health (0-10)';
COMMENT ON COLUMN client_health_history.expansion_points IS 'v6.0 only: Points from expansion potential (0-10)';
COMMENT ON COLUMN client_health_history.primary_concern_category IS 'v6.0 only: Category needing most attention (engagement/financial/operational/strategic)';
COMMENT ON COLUMN client_health_history.revenue_growth_percentage IS 'v6.0 only: Year-over-year revenue growth percentage';
COMMENT ON COLUMN client_health_history.renewal_risk_level IS 'v6.0 only: Contract renewal risk (low/medium/high)';

-- ============================================================================
-- STEP 2: Create supporting tables for v6.0 data sources
-- ============================================================================

-- Table: client_revenue_data
-- Stores revenue information for trend analysis
CREATE TABLE IF NOT EXISTS client_revenue_data (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  client_name TEXT NOT NULL,
  client_id TEXT,
  fiscal_year INTEGER NOT NULL,
  fiscal_quarter TEXT, -- Q1, Q2, Q3, Q4
  revenue_amount NUMERIC NOT NULL,
  currency TEXT DEFAULT 'AUD',
  arr_amount NUMERIC, -- Annual Recurring Revenue
  data_source TEXT, -- e.g., 'salesforce', 'manual', 'finance_system'
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_name, fiscal_year, fiscal_quarter)
);

COMMENT ON TABLE client_revenue_data IS 'Revenue data for calculating revenue trend health scores';
COMMENT ON COLUMN client_revenue_data.arr_amount IS 'Annual Recurring Revenue (if applicable)';

-- Table: client_contract_status
-- Stores contract and renewal information
CREATE TABLE IF NOT EXISTS client_contract_status (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  client_name TEXT NOT NULL,
  client_id TEXT,
  contract_start_date DATE,
  contract_end_date DATE NOT NULL,
  renewal_risk TEXT CHECK (renewal_risk IN ('low', 'medium', 'high')),
  arr_stability TEXT CHECK (arr_stability IN ('stable', 'at-risk', 'declining')),
  contract_value NUMERIC,
  auto_renewal BOOLEAN DEFAULT false,
  notice_period_days INTEGER,
  last_review_date DATE,
  next_review_date DATE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_name, contract_end_date)
);

COMMENT ON TABLE client_contract_status IS 'Contract status and renewal risk for health scoring';
COMMENT ON COLUMN client_contract_status.renewal_risk IS 'Risk of non-renewal: low/medium/high';
COMMENT ON COLUMN client_contract_status.arr_stability IS 'Revenue stability: stable/at-risk/declining';

-- Table: client_support_tickets
-- Stores support ticket information for health tracking
CREATE TABLE IF NOT EXISTS client_support_tickets (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  client_name TEXT NOT NULL,
  client_id TEXT,
  ticket_number TEXT UNIQUE,
  ticket_type TEXT, -- incident, request, change, problem
  priority TEXT, -- low, medium, high, critical
  status TEXT NOT NULL, -- open, in_progress, resolved, closed
  is_escalated BOOLEAN DEFAULT false,
  created_date TIMESTAMPTZ NOT NULL,
  first_response_date TIMESTAMPTZ,
  resolved_date TIMESTAMPTZ,
  closed_date TIMESTAMPTZ,
  response_time_hours NUMERIC,
  resolution_time_hours NUMERIC,
  category TEXT,
  subcategory TEXT,
  summary TEXT,
  data_source TEXT, -- e.g., 'zendesk', 'jira', 'servicenow', 'manual'
  external_id TEXT, -- ID from external system
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE client_support_tickets IS 'Support ticket data for operational health scoring';
COMMENT ON COLUMN client_support_tickets.response_time_hours IS 'Hours from creation to first response';
COMMENT ON COLUMN client_support_tickets.resolution_time_hours IS 'Hours from creation to resolution';

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_support_tickets_client ON client_support_tickets(client_name);
CREATE INDEX IF NOT EXISTS idx_support_tickets_status ON client_support_tickets(status);
CREATE INDEX IF NOT EXISTS idx_support_tickets_created ON client_support_tickets(created_date);

-- Table: client_expansion_opportunities
-- Tracks upsell and cross-sell potential
CREATE TABLE IF NOT EXISTS client_expansion_opportunities (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  client_name TEXT NOT NULL,
  client_id TEXT,
  opportunity_type TEXT, -- upsell, cross-sell, renewal_expansion
  potential_level TEXT CHECK (potential_level IN ('high', 'medium', 'low')),
  estimated_value NUMERIC,
  currency TEXT DEFAULT 'AUD',
  probability_percentage INTEGER CHECK (probability_percentage >= 0 AND probability_percentage <= 100),
  identified_date DATE NOT NULL,
  expected_close_date DATE,
  status TEXT, -- identified, qualified, proposal, negotiation, closed_won, closed_lost
  description TEXT,
  products_services TEXT[],
  champion_contact TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE client_expansion_opportunities IS 'Expansion opportunities for strategic health scoring';
COMMENT ON COLUMN client_expansion_opportunities.potential_level IS 'Overall expansion potential: high/medium/low';

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_revenue_data_client ON client_revenue_data(client_name);
CREATE INDEX IF NOT EXISTS idx_revenue_data_year ON client_revenue_data(fiscal_year DESC);
CREATE INDEX IF NOT EXISTS idx_contract_status_client ON client_contract_status(client_name);
CREATE INDEX IF NOT EXISTS idx_contract_status_end_date ON client_contract_status(contract_end_date);
CREATE INDEX IF NOT EXISTS idx_expansion_client ON client_expansion_opportunities(client_name);
CREATE INDEX IF NOT EXISTS idx_expansion_potential ON client_expansion_opportunities(potential_level);

-- ============================================================================
-- STEP 3: Grant access to new tables
-- ============================================================================

GRANT SELECT, INSERT, UPDATE ON client_revenue_data TO authenticated;
GRANT SELECT, INSERT, UPDATE ON client_contract_status TO authenticated;
GRANT SELECT, INSERT, UPDATE ON client_support_tickets TO authenticated;
GRANT SELECT, INSERT, UPDATE ON client_expansion_opportunities TO authenticated;

GRANT SELECT ON client_revenue_data TO anon;
GRANT SELECT ON client_contract_status TO anon;
GRANT SELECT ON client_support_tickets TO anon;
GRANT SELECT ON client_expansion_opportunities TO anon;

-- ============================================================================
-- STEP 4: Create helper functions for v6.0 calculations
-- ============================================================================

-- Function to calculate revenue trend score
CREATE OR REPLACE FUNCTION calculate_revenue_trend_score(client_name_param TEXT)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  current_year_revenue NUMERIC;
  previous_year_revenue NUMERIC;
  growth_percentage NUMERIC;
BEGIN
  -- Get current fiscal year revenue
  SELECT SUM(revenue_amount) INTO current_year_revenue
  FROM client_revenue_data
  WHERE client_name = client_name_param
    AND fiscal_year = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;

  -- Get previous fiscal year revenue
  SELECT SUM(revenue_amount) INTO previous_year_revenue
  FROM client_revenue_data
  WHERE client_name = client_name_param
    AND fiscal_year = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER - 1;

  -- If no data, return neutral score
  IF current_year_revenue IS NULL OR previous_year_revenue IS NULL OR previous_year_revenue = 0 THEN
    RETURN 10;
  END IF;

  -- Calculate YoY growth percentage
  growth_percentage := ((current_year_revenue - previous_year_revenue) / previous_year_revenue) * 100;

  -- Score based on growth
  IF growth_percentage > 10 THEN
    RETURN 15; -- Strong growth
  ELSIF growth_percentage >= 0 THEN
    RETURN 10; -- Modest growth or flat
  ELSE
    RETURN 5; -- Declining
  END IF;
END;
$$;

COMMENT ON FUNCTION calculate_revenue_trend_score IS 'Calculate revenue trend score (0-15 points) based on YoY growth';

-- Function to calculate contract status score
CREATE OR REPLACE FUNCTION calculate_contract_status_score(client_name_param TEXT)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  risk_level TEXT;
  arr_status TEXT;
BEGIN
  -- Get most recent contract status
  SELECT renewal_risk, arr_stability INTO risk_level, arr_status
  FROM client_contract_status
  WHERE client_name = client_name_param
    AND contract_end_date >= CURRENT_DATE
  ORDER BY contract_end_date ASC
  LIMIT 1;

  -- If no data, return neutral score
  IF risk_level IS NULL THEN
    RETURN 10;
  END IF;

  -- Score based on risk and stability
  IF risk_level = 'low' THEN
    IF arr_status = 'stable' THEN RETURN 15;
    ELSIF arr_status = 'at-risk' THEN RETURN 12;
    ELSE RETURN 13;
    END IF;
  ELSIF risk_level = 'medium' THEN
    IF arr_status = 'stable' THEN RETURN 10;
    ELSIF arr_status = 'at-risk' THEN RETURN 7;
    ELSE RETURN 8;
    END IF;
  ELSE -- high risk
    RETURN 5;
  END IF;
END;
$$;

COMMENT ON FUNCTION calculate_contract_status_score IS 'Calculate contract status score (0-15 points) based on renewal risk';

-- Function to calculate support health score
CREATE OR REPLACE FUNCTION calculate_support_health_score(client_name_param TEXT)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  open_count INTEGER;
  avg_response_hours NUMERIC;
  escalated_count INTEGER;
  score INTEGER := 10;
BEGIN
  -- Get open ticket count
  SELECT COUNT(*) INTO open_count
  FROM client_support_tickets
  WHERE client_name = client_name_param
    AND status IN ('open', 'in_progress');

  -- Get average response time for recent tickets (last 90 days)
  SELECT AVG(response_time_hours) INTO avg_response_hours
  FROM client_support_tickets
  WHERE client_name = client_name_param
    AND created_date >= CURRENT_DATE - INTERVAL '90 days'
    AND response_time_hours IS NOT NULL;

  -- Get escalated ticket count
  SELECT COUNT(*) INTO escalated_count
  FROM client_support_tickets
  WHERE client_name = client_name_param
    AND status IN ('open', 'in_progress')
    AND is_escalated = true;

  -- If no tickets, return full score (healthy)
  IF open_count = 0 THEN
    RETURN 10;
  END IF;

  -- Response time scoring
  IF avg_response_hours IS NOT NULL THEN
    IF avg_response_hours > 48 THEN
      score := LEAST(score, 3);
    ELSIF avg_response_hours > 24 THEN
      score := LEAST(score, 7);
    END IF;
  END IF;

  -- Open ticket volume scoring
  IF open_count > 10 THEN
    score := LEAST(score, 3);
  ELSIF open_count >= 5 THEN
    score := LEAST(score, 7);
  END IF;

  -- Penalty for escalated tickets
  IF escalated_count > 0 THEN
    score := GREATEST(3, score - escalated_count);
  END IF;

  RETURN score;
END;
$$;

COMMENT ON FUNCTION calculate_support_health_score IS 'Calculate support health score (0-10 points) based on ticket metrics';

-- Function to calculate expansion potential score
CREATE OR REPLACE FUNCTION calculate_expansion_score(client_name_param TEXT)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  potential_level TEXT;
  active_opportunities INTEGER;
BEGIN
  -- Get highest potential level from active opportunities
  SELECT
    potential_level,
    COUNT(*) INTO potential_level, active_opportunities
  FROM client_expansion_opportunities
  WHERE client_name = client_name_param
    AND status IN ('identified', 'qualified', 'proposal', 'negotiation')
  GROUP BY potential_level
  ORDER BY
    CASE potential_level
      WHEN 'high' THEN 1
      WHEN 'medium' THEN 2
      WHEN 'low' THEN 3
    END
  LIMIT 1;

  -- If no opportunities, return neutral score
  IF potential_level IS NULL THEN
    RETURN 5;
  END IF;

  -- Score based on potential
  CASE potential_level
    WHEN 'high' THEN RETURN 10;
    WHEN 'medium' THEN RETURN 7;
    WHEN 'low' THEN RETURN 3;
    ELSE RETURN 5;
  END CASE;
END;
$$;

COMMENT ON FUNCTION calculate_expansion_score IS 'Calculate expansion potential score (0-10 points)';

-- ============================================================================
-- STEP 5: Notify PostgREST to reload schema
-- ============================================================================

NOTIFY pgrst, 'reload schema';

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify new columns exist
-- SELECT column_name, data_type, is_nullable
-- FROM information_schema.columns
-- WHERE table_name = 'client_health_history'
--   AND column_name IN ('health_score_version', 'actions_points', 'revenue_trend_points',
--                       'contract_status_points', 'support_health_points', 'expansion_points')
-- ORDER BY column_name;

-- Verify new tables exist
-- SELECT table_name,
--        (SELECT COUNT(*) FROM information_schema.columns c WHERE c.table_name = t.table_name) as column_count
-- FROM information_schema.tables t
-- WHERE table_name IN ('client_revenue_data', 'client_contract_status',
--                      'client_support_tickets', 'client_expansion_opportunities')
--   AND table_schema = 'public';

-- Test helper functions (replace 'Test Client' with actual client name)
-- SELECT
--   'Test Client' as client_name,
--   calculate_revenue_trend_score('Test Client') as revenue_trend_score,
--   calculate_contract_status_score('Test Client') as contract_status_score,
--   calculate_support_health_score('Test Client') as support_health_score,
--   calculate_expansion_score('Test Client') as expansion_score;
