-- ============================================================================
-- Migration: Support SLA Metrics Table
-- Date: 2026-01-08
-- Description: Store support ticket metrics from SLA reports for dashboard integration
-- ============================================================================

-- Main metrics table
CREATE TABLE IF NOT EXISTS support_sla_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  client_uuid UUID,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  period_type TEXT DEFAULT 'monthly' CHECK (period_type IN ('monthly', 'quarterly')),

  -- Case Volume
  total_incoming INTEGER DEFAULT 0,
  total_closed INTEGER DEFAULT 0,
  backlog INTEGER DEFAULT 0,

  -- Priority Breakdown (Open Cases)
  critical_open INTEGER DEFAULT 0,
  high_open INTEGER DEFAULT 0,
  moderate_open INTEGER DEFAULT 0,
  low_open INTEGER DEFAULT 0,

  -- Aging Distribution
  aging_0_7d INTEGER DEFAULT 0,
  aging_8_30d INTEGER DEFAULT 0,
  aging_31_60d INTEGER DEFAULT 0,
  aging_61_90d INTEGER DEFAULT 0,
  aging_90d_plus INTEGER DEFAULT 0,

  -- SLA Compliance
  response_sla_percent DECIMAL(5,2),
  resolution_sla_percent DECIMAL(5,2),
  breach_count INTEGER DEFAULT 0,

  -- Availability
  availability_percent DECIMAL(5,2),
  outage_count INTEGER DEFAULT 0,
  outage_minutes INTEGER DEFAULT 0,

  -- Satisfaction
  surveys_sent INTEGER DEFAULT 0,
  surveys_completed INTEGER DEFAULT 0,
  satisfaction_score DECIMAL(3,2),

  -- Metadata
  source_file TEXT,
  imported_at TIMESTAMPTZ DEFAULT NOW(),
  imported_by TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(client_name, period_start, period_end)
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_sla_metrics_client ON support_sla_metrics(client_name);
CREATE INDEX IF NOT EXISTS idx_sla_metrics_client_uuid ON support_sla_metrics(client_uuid);
CREATE INDEX IF NOT EXISTS idx_sla_metrics_period ON support_sla_metrics(period_start, period_end);
CREATE INDEX IF NOT EXISTS idx_sla_metrics_imported ON support_sla_metrics(imported_at);

-- Individual case details (for drill-down)
CREATE TABLE IF NOT EXISTS support_case_details (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  metrics_id UUID REFERENCES support_sla_metrics(id) ON DELETE CASCADE,
  client_name TEXT NOT NULL,

  case_number TEXT NOT NULL,
  short_description TEXT,
  priority TEXT,
  state TEXT,
  opened_at TIMESTAMPTZ,
  resolved_at TIMESTAMPTZ,
  assigned_to TEXT,
  contact_name TEXT,
  product TEXT,
  environment TEXT,
  has_breached BOOLEAN DEFAULT FALSE,

  created_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(client_name, case_number)
);

CREATE INDEX IF NOT EXISTS idx_case_details_client ON support_case_details(client_name);
CREATE INDEX IF NOT EXISTS idx_case_details_metrics ON support_case_details(metrics_id);
CREATE INDEX IF NOT EXISTS idx_case_details_priority ON support_case_details(priority);
CREATE INDEX IF NOT EXISTS idx_case_details_state ON support_case_details(state);

-- RLS Policies
ALTER TABLE support_sla_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_case_details ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read
CREATE POLICY "Allow authenticated read on support_sla_metrics"
  ON support_sla_metrics FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated read on support_case_details"
  ON support_case_details FOR SELECT
  TO authenticated
  USING (true);

-- Allow service role full access
CREATE POLICY "Allow service role full access on support_sla_metrics"
  ON support_sla_metrics FOR ALL
  TO service_role
  USING (true);

CREATE POLICY "Allow service role full access on support_case_details"
  ON support_case_details FOR ALL
  TO service_role
  USING (true);

-- View for latest metrics per client
CREATE OR REPLACE VIEW support_sla_latest AS
SELECT DISTINCT ON (client_name)
  id,
  client_name,
  client_uuid,
  period_start,
  period_end,
  period_type,
  total_incoming,
  total_closed,
  backlog,
  critical_open,
  high_open,
  moderate_open,
  low_open,
  (critical_open + high_open + moderate_open + low_open) as total_open,
  aging_0_7d,
  aging_8_30d,
  aging_31_60d,
  aging_61_90d,
  aging_90d_plus,
  (aging_31_60d + aging_61_90d + aging_90d_plus) as aging_30d_plus,
  response_sla_percent,
  resolution_sla_percent,
  breach_count,
  availability_percent,
  outage_count,
  outage_minutes,
  surveys_sent,
  surveys_completed,
  satisfaction_score,
  source_file,
  imported_at
FROM support_sla_metrics
ORDER BY client_name, period_end DESC;

-- Function to calculate support health score (0-100)
CREATE OR REPLACE FUNCTION calculate_support_health_score(
  p_sla_percent DECIMAL,
  p_satisfaction DECIMAL,
  p_aging_30d_plus INTEGER,
  p_critical_open INTEGER
) RETURNS INTEGER AS $$
DECLARE
  sla_score INTEGER;
  satisfaction_score INTEGER;
  aging_score INTEGER;
  critical_score INTEGER;
BEGIN
  -- SLA Compliance (40% weight)
  sla_score := LEAST(100, GREATEST(0, COALESCE(p_sla_percent, 95)::INTEGER));

  -- Satisfaction (30% weight) - convert 1-5 scale to 0-100
  satisfaction_score := LEAST(100, GREATEST(0, (COALESCE(p_satisfaction, 4.0) * 20)::INTEGER));

  -- Aging penalty (20% weight) - deduct for old cases
  aging_score := GREATEST(0, 100 - (COALESCE(p_aging_30d_plus, 0) * 10));

  -- Critical cases penalty (10% weight) - deduct heavily for critical
  critical_score := GREATEST(0, 100 - (COALESCE(p_critical_open, 0) * 25));

  RETURN (sla_score * 0.4 + satisfaction_score * 0.3 + aging_score * 0.2 + critical_score * 0.1)::INTEGER;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- View with health score
CREATE OR REPLACE VIEW support_health_summary AS
SELECT
  client_name,
  client_uuid,
  period_end,
  total_open,
  critical_open,
  aging_30d_plus,
  resolution_sla_percent,
  satisfaction_score,
  calculate_support_health_score(
    resolution_sla_percent,
    satisfaction_score,
    aging_30d_plus,
    critical_open
  ) as support_health_score
FROM support_sla_latest;
