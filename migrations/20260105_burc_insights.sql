-- ============================================================================
-- BURC AI-Generated Insights Table
-- Created: 2026-01-05
-- Purpose: Store AI-generated insights from BURC financial data
-- ============================================================================

CREATE TABLE IF NOT EXISTS burc_generated_insights (
  -- Primary identifier
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Insight classification
  insight_type VARCHAR(50) NOT NULL CHECK (insight_type IN (
    'revenue', 'retention', 'risk', 'opportunity', 'trend',
    'anomaly', 'correlation', 'forecast', 'metric'
  )),

  category VARCHAR(30) NOT NULL CHECK (category IN (
    'revenue', 'retention', 'risk', 'opportunity', 'operations',
    'collections', 'ps_margins', 'comprehensive'
  )),

  -- Insight content
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,

  -- Supporting data
  data_points JSONB DEFAULT '[]'::jsonb,
  -- Example: [{"metric": "NRR", "value": 98, "change": -3, "period": "Q4 2025"}]

  recommendations JSONB DEFAULT '[]'::jsonb,
  -- Example: [{"action": "Review client renewals", "priority": "high", "impact": "Prevent churn"}]

  -- Severity/priority
  severity VARCHAR(20) NOT NULL DEFAULT 'info' CHECK (severity IN (
    'critical', 'high', 'medium', 'low', 'info'
  )),

  -- Optional client association
  client_name VARCHAR(255),
  client_uuid UUID,

  -- Metadata
  confidence_score DECIMAL(3, 2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
  -- How confident is the AI in this insight (0.0 - 1.0)

  related_metrics TEXT[], -- e.g., ['NRR', 'ARR', 'Churn Rate']
  tags TEXT[], -- e.g., ['Q4_2025', 'attrition', 'new_contracts']

  -- Lifecycle management
  generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ, -- When this insight becomes stale

  acknowledged BOOLEAN DEFAULT FALSE,
  acknowledged_by VARCHAR(255),
  acknowledged_at TIMESTAMPTZ,

  -- System metadata
  model_version VARCHAR(50) DEFAULT 'v1.0',
  generation_source VARCHAR(100) DEFAULT 'burc_sync', -- 'burc_sync', 'manual', 'scheduled'

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- Indexes for Performance
-- ============================================================================

-- Query insights by category and severity
CREATE INDEX idx_burc_insights_category_severity
  ON burc_generated_insights(category, severity, generated_at DESC);

-- Query insights by type
CREATE INDEX idx_burc_insights_type
  ON burc_generated_insights(insight_type, generated_at DESC);

-- Query by client
CREATE INDEX idx_burc_insights_client
  ON burc_generated_insights(client_uuid)
  WHERE client_uuid IS NOT NULL;

-- Find unacknowledged insights
CREATE INDEX idx_burc_insights_unacknowledged
  ON burc_generated_insights(acknowledged, severity, generated_at DESC)
  WHERE acknowledged = FALSE;

-- Query active (non-expired) insights
CREATE INDEX idx_burc_insights_active
  ON burc_generated_insights(generated_at DESC)
  WHERE expires_at IS NULL OR expires_at > NOW();

-- Full-text search on title and description
CREATE INDEX idx_burc_insights_search
  ON burc_generated_insights USING gin(to_tsvector('english', title || ' ' || description));

-- ============================================================================
-- Row-Level Security (RLS)
-- ============================================================================

ALTER TABLE burc_generated_insights ENABLE ROW LEVEL SECURITY;

-- Allow service role to manage all insights
CREATE POLICY "Service role has full access to insights"
  ON burc_generated_insights
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Allow authenticated users to read insights
CREATE POLICY "Authenticated users can read insights"
  ON burc_generated_insights
  FOR SELECT
  TO authenticated
  USING (true);

-- Allow authenticated users to acknowledge insights
CREATE POLICY "Authenticated users can acknowledge insights"
  ON burc_generated_insights
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (
    -- Only allow updating acknowledged fields
    acknowledged = true OR
    acknowledged_by IS NOT NULL OR
    acknowledged_at IS NOT NULL
  );

-- ============================================================================
-- Views for Common Queries
-- ============================================================================

-- Active insights (not expired, not acknowledged)
CREATE OR REPLACE VIEW burc_insights_active AS
SELECT
  id,
  insight_type,
  category,
  title,
  description,
  data_points,
  recommendations,
  severity,
  client_name,
  client_uuid,
  confidence_score,
  related_metrics,
  tags,
  generated_at,
  expires_at
FROM burc_generated_insights
WHERE
  acknowledged = FALSE
  AND (expires_at IS NULL OR expires_at > NOW())
ORDER BY
  CASE severity
    WHEN 'critical' THEN 1
    WHEN 'high' THEN 2
    WHEN 'medium' THEN 3
    WHEN 'low' THEN 4
    ELSE 5
  END,
  generated_at DESC;

-- Insights summary by category
CREATE OR REPLACE VIEW burc_insights_summary AS
SELECT
  category,
  insight_type,
  severity,
  COUNT(*) as count,
  COUNT(*) FILTER (WHERE acknowledged = FALSE) as unacknowledged_count,
  MAX(generated_at) as latest_generated_at
FROM burc_generated_insights
WHERE
  expires_at IS NULL OR expires_at > NOW()
GROUP BY category, insight_type, severity
ORDER BY category, severity;

-- ============================================================================
-- Triggers
-- ============================================================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_burc_insights_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_burc_insights_updated_at
  BEFORE UPDATE ON burc_generated_insights
  FOR EACH ROW
  EXECUTE FUNCTION update_burc_insights_timestamp();

-- ============================================================================
-- Sample Data (for testing)
-- ============================================================================

-- Example: Revenue growth insight
INSERT INTO burc_generated_insights (
  insight_type, category, title, description,
  data_points, recommendations, severity, confidence_score, related_metrics, tags
) VALUES (
  'revenue',
  'revenue',
  'Revenue grew 12% this quarter, driven by new Maintenance contracts',
  'Total revenue increased from $8.2M to $9.2M in Q4 2025, with Maintenance revenue contributing $600K of the growth. This represents the strongest quarterly performance in 2025.',
  '[
    {"metric": "Total Revenue", "current": 9200000, "previous": 8200000, "change_pct": 12.2, "period": "Q4 2025"},
    {"metric": "Maintenance Revenue", "current": 3100000, "previous": 2500000, "change_pct": 24.0, "period": "Q4 2025"}
  ]'::jsonb,
  '[
    {"action": "Analyse maintenance contract terms to identify best practices", "priority": "medium", "impact": "Replicate success across portfolio"},
    {"action": "Schedule review with sales team on new contract pipeline", "priority": "high", "impact": "Maintain growth momentum"}
  ]'::jsonb,
  'info',
  0.92,
  ARRAY['Revenue', 'Maintenance', 'Growth'],
  ARRAY['Q4_2025', 'maintenance', 'growth']
);

-- Example: Retention risk insight
INSERT INTO burc_generated_insights (
  insight_type, category, title, description,
  data_points, recommendations, severity, confidence_score, related_metrics, tags
) VALUES (
  'risk',
  'retention',
  'NRR declined 3% - 2 clients reduced ARR significantly',
  'Net Revenue Retention dropped from 101% to 98% in December 2025. Two major clients (combined $450K ARR) downgraded their contracts, citing budget constraints.',
  '[
    {"metric": "NRR", "current": 98, "previous": 101, "change_pct": -3.0, "period": "Dec 2025"},
    {"metric": "Clients Downgraded", "value": 2, "total_arr_impact": 450000}
  ]'::jsonb,
  '[
    {"action": "Conduct retention interviews with affected clients", "priority": "critical", "impact": "Prevent further downgrades"},
    {"action": "Review pricing flexibility options for budget-constrained clients", "priority": "high", "impact": "Reduce churn risk"},
    {"action": "Analyse usage patterns to identify at-risk clients early", "priority": "medium", "impact": "Proactive intervention"}
  ]'::jsonb,
  'high',
  0.88,
  ARRAY['NRR', 'Churn', 'ARR'],
  ARRAY['Dec_2025', 'retention', 'downgrade']
);

-- Example: Opportunity insight
INSERT INTO burc_generated_insights (
  insight_type, category, title, description,
  data_points, recommendations, severity, confidence_score, related_metrics, tags, expires_at
) VALUES (
  'opportunity',
  'operations',
  'PS utilisation at 85% - capacity for 2 additional projects',
  'Professional Services utilisation reached 85% in Q4 2025, indicating healthy demand. Based on current team capacity, there is room to onboard 2 additional medium-sized projects without hiring.',
  '[
    {"metric": "PS Utilisation", "current": 85, "target": 90, "period": "Q4 2025"},
    {"metric": "Available Capacity", "hours": 640, "equivalent_projects": 2}
  ]'::jsonb,
  '[
    {"action": "Prioritise existing pipeline to fill capacity gaps", "priority": "high", "impact": "Maximise utilisation"},
    {"action": "Review project profitability to focus on high-margin work", "priority": "medium", "impact": "Improve margins"}
  ]'::jsonb,
  'medium',
  0.85,
  ARRAY['PS Utilisation', 'Capacity Planning'],
  ARRAY['Q4_2025', 'professional_services', 'capacity'],
  NOW() + INTERVAL '30 days' -- Expires in 30 days
);

-- ============================================================================
-- Comments
-- ============================================================================

COMMENT ON TABLE burc_generated_insights IS
  'AI-generated insights from BURC financial data, including revenue trends, retention risks, opportunities, and anomalies';

COMMENT ON COLUMN burc_generated_insights.insight_type IS
  'Type of insight: revenue, retention, risk, opportunity, trend, anomaly, correlation, forecast, metric';

COMMENT ON COLUMN burc_generated_insights.category IS
  'Business category: revenue, retention, risk, opportunity, operations, collections, ps_margins, comprehensive';

COMMENT ON COLUMN burc_generated_insights.data_points IS
  'JSON array of supporting data points with metrics, values, and context';

COMMENT ON COLUMN burc_generated_insights.recommendations IS
  'JSON array of recommended actions with priorities and expected impact';

COMMENT ON COLUMN burc_generated_insights.severity IS
  'Severity level: critical, high, medium, low, info - determines display priority';

COMMENT ON COLUMN burc_generated_insights.confidence_score IS
  'AI confidence in the insight (0.0 - 1.0), higher is more confident';

COMMENT ON COLUMN burc_generated_insights.expires_at IS
  'When this insight becomes stale and should be hidden from active views';
