-- BURC AI-Generated Insights Table V2
-- Fix: Removed partial index with NOW() function (not IMMUTABLE)

CREATE TABLE IF NOT EXISTS burc_generated_insights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  insight_type VARCHAR(50) NOT NULL CHECK (insight_type IN (
    'revenue', 'retention', 'risk', 'opportunity', 'trend',
    'anomaly', 'correlation', 'forecast', 'metric'
  )),
  category VARCHAR(30) NOT NULL CHECK (category IN (
    'revenue', 'retention', 'risk', 'opportunity', 'operations',
    'collections', 'ps_margins', 'comprehensive'
  )),
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  data_points JSONB DEFAULT '[]'::jsonb,
  recommendations JSONB DEFAULT '[]'::jsonb,
  severity VARCHAR(20) NOT NULL DEFAULT 'info' CHECK (severity IN (
    'critical', 'high', 'medium', 'low', 'info'
  )),
  client_name VARCHAR(255),
  client_uuid UUID,
  confidence_score DECIMAL(3, 2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
  related_metrics TEXT[],
  tags TEXT[],
  generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  acknowledged BOOLEAN DEFAULT FALSE,
  acknowledged_by VARCHAR(255),
  acknowledged_at TIMESTAMPTZ,
  model_version VARCHAR(50) DEFAULT 'v1.0',
  generation_source VARCHAR(100) DEFAULT 'burc_sync',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes (without partial indexes using NOW())
CREATE INDEX IF NOT EXISTS idx_burc_insights_category_severity
  ON burc_generated_insights(category, severity, generated_at DESC);

CREATE INDEX IF NOT EXISTS idx_burc_insights_type
  ON burc_generated_insights(insight_type, generated_at DESC);

CREATE INDEX IF NOT EXISTS idx_burc_insights_client
  ON burc_generated_insights(client_uuid)
  WHERE client_uuid IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_burc_insights_unacknowledged
  ON burc_generated_insights(acknowledged, severity, generated_at DESC)
  WHERE acknowledged = FALSE;

-- Instead of partial index with NOW(), use a simple index on expires_at
CREATE INDEX IF NOT EXISTS idx_burc_insights_expires
  ON burc_generated_insights(expires_at)
  WHERE expires_at IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_burc_insights_generated
  ON burc_generated_insights(generated_at DESC);

-- Full-text search index
CREATE INDEX IF NOT EXISTS idx_burc_insights_search
  ON burc_generated_insights USING gin(to_tsvector('english', title || ' ' || description));

-- Enable RLS
ALTER TABLE burc_generated_insights ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Service role has full access to insights') THEN
    CREATE POLICY "Service role has full access to insights"
      ON burc_generated_insights FOR ALL TO service_role USING (true) WITH CHECK (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Authenticated users can read insights') THEN
    CREATE POLICY "Authenticated users can read insights"
      ON burc_generated_insights FOR SELECT TO authenticated USING (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Authenticated users can acknowledge insights') THEN
    CREATE POLICY "Authenticated users can acknowledge insights"
      ON burc_generated_insights FOR UPDATE TO authenticated
      USING (true)
      WITH CHECK (acknowledged = true OR acknowledged_by IS NOT NULL OR acknowledged_at IS NOT NULL);
  END IF;
END $$;

-- Views for common queries
CREATE OR REPLACE VIEW burc_insights_active AS
SELECT
  id, insight_type, category, title, description,
  data_points, recommendations, severity,
  client_name, client_uuid, confidence_score,
  related_metrics, tags, generated_at, expires_at
FROM burc_generated_insights
WHERE acknowledged = FALSE
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

CREATE OR REPLACE VIEW burc_insights_summary AS
SELECT
  category, insight_type, severity,
  COUNT(*) as count,
  COUNT(*) FILTER (WHERE acknowledged = FALSE) as unacknowledged_count,
  MAX(generated_at) as latest_generated_at
FROM burc_generated_insights
WHERE expires_at IS NULL OR expires_at > NOW()
GROUP BY category, insight_type, severity
ORDER BY category, severity;

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION update_burc_insights_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_burc_insights_updated_at ON burc_generated_insights;
CREATE TRIGGER trigger_burc_insights_updated_at
  BEFORE UPDATE ON burc_generated_insights
  FOR EACH ROW
  EXECUTE FUNCTION update_burc_insights_timestamp();

-- Insert sample data
INSERT INTO burc_generated_insights (
  insight_type, category, title, description,
  data_points, recommendations, severity, confidence_score, related_metrics, tags
)
SELECT
  'revenue', 'revenue',
  'Revenue grew 12% this quarter, driven by new Maintenance contracts',
  'Total revenue increased from $8.2M to $9.2M in Q4 2025.',
  '[{"metric": "Total Revenue", "current": 9200000, "previous": 8200000, "change_pct": 12.2}]'::jsonb,
  '[{"action": "Analyse maintenance contract terms", "priority": "medium"}]'::jsonb,
  'info', 0.92,
  ARRAY['Revenue', 'Maintenance', 'Growth'],
  ARRAY['Q4_2025', 'maintenance', 'growth']
WHERE NOT EXISTS (
  SELECT 1 FROM burc_generated_insights WHERE title LIKE 'Revenue grew 12%%'
);

SELECT 'BURC insights v2 migration completed' AS status;
