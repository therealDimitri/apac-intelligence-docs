-- Migration: ChaSen AI Recommendations & Learning System
-- Date: 2025-12-03
-- Purpose: Enable automatic recommendation refresh and continuous learning

-- ============================================================================
-- 1. RECOMMENDATIONS CACHE TABLE
-- ============================================================================
-- Stores AI-generated recommendations with TTL for auto-refresh
CREATE TABLE IF NOT EXISTS chasen_recommendations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  recommendation_type TEXT NOT NULL, -- 'engagement', 'satisfaction', 'compliance', 'financial', 'initiative'
  severity TEXT NOT NULL CHECK (severity IN ('critical', 'warning', 'info')),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  reasoning TEXT NOT NULL, -- Why ChaSen recommended this
  impact_score NUMERIC(3,2) NOT NULL CHECK (impact_score >= 0 AND impact_score <= 1), -- 0-1 scale
  confidence_score NUMERIC(3,2) NOT NULL CHECK (confidence_score >= 0 AND confidence_score <= 1), -- 0-1 scale
  estimated_effort TEXT, -- e.g., "2 hours", "1 day"
  expected_outcome TEXT, -- e.g., "Improve NPS by 15-20 points within 30 days"
  recommended_actions JSONB, -- Array of action objects: [{ type, label, deepLink }]
  context_data JSONB, -- Client context used to generate recommendation
  portfolio_insights JSONB, -- Portfolio-wide insights used
  generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '1 hour'),
  refreshed_count INTEGER DEFAULT 0, -- How many times this has been refreshed
  last_refreshed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for fast client lookup
CREATE INDEX idx_chasen_recommendations_client ON chasen_recommendations(client_name);
-- Index for TTL expiration checks
CREATE INDEX idx_chasen_recommendations_expires ON chasen_recommendations(expires_at);
-- Composite index for active recommendations
CREATE INDEX idx_chasen_recommendations_active ON chasen_recommendations(client_name, expires_at)
  WHERE expires_at > NOW();

-- ============================================================================
-- 2. RECOMMENDATION INTERACTIONS TABLE
-- ============================================================================
-- Tracks when CSEs interact with recommendations (view, click, dismiss, complete)
CREATE TABLE IF NOT EXISTS chasen_recommendation_interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recommendation_id UUID NOT NULL REFERENCES chasen_recommendations(id) ON DELETE CASCADE,
  client_name TEXT NOT NULL,
  cse_email TEXT NOT NULL, -- Who interacted
  interaction_type TEXT NOT NULL CHECK (interaction_type IN ('viewed', 'clicked', 'dismissed', 'snoozed', 'completed', 'action_taken')),
  interaction_data JSONB, -- Additional context (e.g., which action was clicked, dismiss reason)
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for tracking CSE effectiveness
CREATE INDEX idx_recommendation_interactions_cse ON chasen_recommendation_interactions(cse_email, created_at);
-- Index for recommendation analytics
CREATE INDEX idx_recommendation_interactions_rec ON chasen_recommendation_interactions(recommendation_id, interaction_type);

-- ============================================================================
-- 3. SUCCESS PATTERNS TABLE
-- ============================================================================
-- Stores successful intervention patterns to feed back into ChaSen prompts
CREATE TABLE IF NOT EXISTS chasen_success_patterns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pattern_name TEXT NOT NULL,
  client_segment TEXT NOT NULL, -- 'Enterprise', 'Strategic', 'Core'
  client_industry TEXT, -- Optional industry filter
  trigger_conditions JSONB NOT NULL, -- What conditions triggered the recommendation (e.g., { "health_score": "<50", "nps_score": "<-30" })
  recommendation_title TEXT NOT NULL,
  recommendation_description TEXT NOT NULL,
  actions_taken JSONB NOT NULL, -- What the CSE did (e.g., [{ "action": "scheduled_feedback_session", "date": "2025-11-15" }])

  -- Outcome Metrics (Before)
  health_score_before NUMERIC(5,2),
  nps_score_before NUMERIC(5,2),
  compliance_score_before NUMERIC(5,2),
  engagement_score_before NUMERIC(5,2), -- Days since last meeting

  -- Outcome Metrics (After)
  health_score_after NUMERIC(5,2),
  nps_score_after NUMERIC(5,2),
  compliance_score_after NUMERIC(5,2),
  engagement_score_after NUMERIC(5,2),

  -- Success Metrics
  health_improvement NUMERIC(5,2), -- Calculated: after - before
  nps_improvement NUMERIC(5,2),
  compliance_improvement NUMERIC(5,2),
  engagement_improvement NUMERIC(5,2),
  days_to_improvement INTEGER, -- Time from action to measurable improvement

  success_score NUMERIC(3,2) CHECK (success_score >= 0 AND success_score <= 1), -- Overall success rating (0-1)
  confidence_level TEXT CHECK (confidence_level IN ('low', 'medium', 'high')), -- How confident in this pattern

  times_applied INTEGER DEFAULT 1, -- How many times this pattern has been used
  success_rate NUMERIC(3,2), -- % of times this pattern led to improvement

  cse_email TEXT NOT NULL, -- Who executed this successfully
  client_name TEXT NOT NULL,
  applied_at TIMESTAMPTZ NOT NULL,
  measured_at TIMESTAMPTZ NOT NULL,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for pattern matching during recommendation generation
CREATE INDEX idx_success_patterns_segment ON chasen_success_patterns(client_segment, success_score DESC);
CREATE INDEX idx_success_patterns_conditions ON chasen_success_patterns USING GIN (trigger_conditions);
-- Index for learning analytics
CREATE INDEX idx_success_patterns_success ON chasen_success_patterns(success_score DESC, times_applied DESC);

-- ============================================================================
-- 4. RECOMMENDATION GENERATION LOG
-- ============================================================================
-- Tracks every time ChaSen generates recommendations (for debugging/analytics)
CREATE TABLE IF NOT EXISTS chasen_generation_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  generation_type TEXT NOT NULL CHECK (generation_type IN ('scheduled', 'manual', 'triggered')),
  trigger_reason TEXT, -- e.g., "data_change", "user_request", "cache_expired"

  context_snapshot JSONB NOT NULL, -- Full client + portfolio context used
  prompt_used TEXT NOT NULL, -- The actual prompt sent to ChaSen
  recommendations_generated INTEGER NOT NULL, -- How many recommendations were generated

  api_latency_ms INTEGER, -- How long the API call took
  tokens_used INTEGER, -- Claude API token usage
  cost_usd NUMERIC(10,4), -- Estimated cost

  success BOOLEAN NOT NULL DEFAULT true,
  error_message TEXT,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for cost tracking
CREATE INDEX idx_generation_log_cost ON chasen_generation_log(created_at, cost_usd);
-- Index for performance monitoring
CREATE INDEX idx_generation_log_latency ON chasen_generation_log(api_latency_ms DESC);

-- ============================================================================
-- 5. CLIENT METRIC SNAPSHOTS
-- ============================================================================
-- Stores daily snapshots of client metrics for before/after analysis
CREATE TABLE IF NOT EXISTS client_metric_snapshots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  snapshot_date DATE NOT NULL,

  -- Health Metrics
  health_score NUMERIC(5,2),
  nps_score NUMERIC(5,2),
  compliance_score NUMERIC(5,2),
  event_compliance JSONB, -- Detailed event compliance breakdown

  -- Engagement Metrics
  days_since_last_meeting INTEGER,
  meetings_last_30_days INTEGER,
  open_actions INTEGER,
  overdue_actions INTEGER,

  -- Financial Metrics
  aging_under_60_pct NUMERIC(5,2),
  aging_under_90_pct NUMERIC(5,2),
  days_to_renewal INTEGER,
  revenue_at_risk NUMERIC(12,2),

  -- Initiative Metrics
  portfolio_completion_rate NUMERIC(5,2),
  active_initiatives INTEGER,
  blocked_initiatives INTEGER,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(client_name, snapshot_date)
);

-- Index for time-series analysis
CREATE INDEX idx_metric_snapshots_client_date ON client_metric_snapshots(client_name, snapshot_date DESC);

-- ============================================================================
-- 6. FUNCTIONS & TRIGGERS
-- ============================================================================

-- Function: Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Update chasen_recommendations.updated_at
CREATE TRIGGER update_chasen_recommendations_updated_at
  BEFORE UPDATE ON chasen_recommendations
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger: Update chasen_success_patterns.updated_at
CREATE TRIGGER update_chasen_success_patterns_updated_at
  BEFORE UPDATE ON chasen_success_patterns
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 7. MATERIALIZED VIEW: RECOMMENDATION EFFECTIVENESS
-- ============================================================================
-- Pre-aggregated analytics for recommendation performance
CREATE MATERIALIZED VIEW IF NOT EXISTS chasen_recommendation_effectiveness AS
SELECT
  r.recommendation_type,
  r.severity,
  r.client_name,
  COUNT(DISTINCT r.id) as total_recommendations,
  COUNT(DISTINCT CASE WHEN i.interaction_type = 'completed' THEN r.id END) as completed_count,
  COUNT(DISTINCT CASE WHEN i.interaction_type = 'dismissed' THEN r.id END) as dismissed_count,
  ROUND(
    COUNT(DISTINCT CASE WHEN i.interaction_type = 'completed' THEN r.id END)::NUMERIC /
    NULLIF(COUNT(DISTINCT r.id), 0) * 100,
    2
  ) as completion_rate,
  AVG(r.impact_score) as avg_impact_score,
  AVG(r.confidence_score) as avg_confidence_score,
  AVG(
    EXTRACT(EPOCH FROM (i.created_at - r.generated_at)) / 86400
  ) as avg_days_to_action
FROM chasen_recommendations r
LEFT JOIN chasen_recommendation_interactions i ON r.id = i.recommendation_id
WHERE r.generated_at >= NOW() - INTERVAL '90 days'
GROUP BY r.recommendation_type, r.severity, r.client_name;

-- Index for fast querying
CREATE INDEX idx_rec_effectiveness_type ON chasen_recommendation_effectiveness(recommendation_type);
CREATE INDEX idx_rec_effectiveness_client ON chasen_recommendation_effectiveness(client_name);

-- ============================================================================
-- 8. RLS POLICIES (Security)
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE chasen_recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_recommendation_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_success_patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_generation_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_metric_snapshots ENABLE ROW LEVEL SECURITY;

-- Policy: All authenticated users can read their own client data
CREATE POLICY "Users can read recommendations for their clients"
  ON chasen_recommendations FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Users can insert recommendations"
  ON chasen_recommendations FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update recommendations"
  ON chasen_recommendations FOR UPDATE
  USING (auth.role() = 'authenticated');

-- Policy: Track interactions
CREATE POLICY "Users can track interactions"
  ON chasen_recommendation_interactions FOR ALL
  USING (auth.role() = 'authenticated');

-- Policy: Success patterns (read-only for learning)
CREATE POLICY "Users can read success patterns"
  ON chasen_success_patterns FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Users can insert success patterns"
  ON chasen_success_patterns FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Policy: Generation log (service role only for writes)
CREATE POLICY "Service can write generation logs"
  ON chasen_generation_log FOR INSERT
  WITH CHECK (auth.role() = 'service_role');

CREATE POLICY "Users can read generation logs"
  ON chasen_generation_log FOR SELECT
  USING (auth.role() = 'authenticated');

-- Policy: Metric snapshots
CREATE POLICY "Users can read metric snapshots"
  ON client_metric_snapshots FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Service can write metric snapshots"
  ON client_metric_snapshots FOR INSERT
  WITH CHECK (auth.role() = 'service_role');

-- ============================================================================
-- 9. HELPER FUNCTIONS
-- ============================================================================

-- Function: Get active recommendations for a client
CREATE OR REPLACE FUNCTION get_active_recommendations(p_client_name TEXT)
RETURNS TABLE (
  id UUID,
  recommendation_type TEXT,
  severity TEXT,
  title TEXT,
  description TEXT,
  reasoning TEXT,
  impact_score NUMERIC,
  confidence_score NUMERIC,
  recommended_actions JSONB,
  generated_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.id,
    r.recommendation_type,
    r.severity,
    r.title,
    r.description,
    r.reasoning,
    r.impact_score,
    r.confidence_score,
    r.recommended_actions,
    r.generated_at,
    r.expires_at
  FROM chasen_recommendations r
  WHERE r.client_name = p_client_name
    AND r.expires_at > NOW()
  ORDER BY
    CASE r.severity
      WHEN 'critical' THEN 0
      WHEN 'warning' THEN 1
      WHEN 'info' THEN 2
    END,
    r.impact_score DESC
  LIMIT 10;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Get success patterns for context matching
CREATE OR REPLACE FUNCTION get_relevant_success_patterns(
  p_segment TEXT,
  p_health_score NUMERIC DEFAULT NULL,
  p_nps_score NUMERIC DEFAULT NULL
)
RETURNS TABLE (
  pattern_name TEXT,
  recommendation_title TEXT,
  recommendation_description TEXT,
  actions_taken JSONB,
  success_score NUMERIC,
  success_rate NUMERIC,
  times_applied INTEGER,
  avg_improvement NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    sp.pattern_name,
    sp.recommendation_title,
    sp.recommendation_description,
    sp.actions_taken,
    sp.success_score,
    sp.success_rate,
    sp.times_applied,
    ROUND((sp.health_improvement + sp.nps_improvement + sp.compliance_improvement) / 3, 2) as avg_improvement
  FROM chasen_success_patterns sp
  WHERE sp.client_segment = p_segment
    AND sp.success_score >= 0.6
    AND sp.times_applied >= 1
  ORDER BY sp.success_score DESC, sp.times_applied DESC
  LIMIT 5;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 10. INITIAL DATA SEEDING (Optional)
-- ============================================================================

-- Seed: Example success pattern (can be removed after real data accumulates)
INSERT INTO chasen_success_patterns (
  pattern_name,
  client_segment,
  client_industry,
  trigger_conditions,
  recommendation_title,
  recommendation_description,
  actions_taken,
  health_score_before,
  health_score_after,
  nps_score_before,
  nps_score_after,
  compliance_score_before,
  compliance_score_after,
  health_improvement,
  nps_improvement,
  compliance_improvement,
  days_to_improvement,
  success_score,
  confidence_level,
  times_applied,
  success_rate,
  cse_email,
  client_name,
  applied_at,
  measured_at
) VALUES (
  'urgent_feedback_session_for_low_nps',
  'Enterprise',
  'Healthcare',
  '{"health_score": "<60", "nps_score": "<-30", "days_since_meeting": ">45"}',
  'Schedule urgent feedback session',
  'NPS dropped significantly with detractors citing communication issues. Schedule 1:1s with key stakeholders.',
  '[{"action": "scheduled_feedback_session", "date": "2024-11-15", "attendees": ["CIO", "Clinical Director", "Nurse Manager"]}, {"action": "created_action_plan", "items": 3}]',
  52.0,
  68.0,
  -42.0,
  -8.0,
  67.0,
  78.0,
  16.0,
  34.0,
  11.0,
  30,
  0.85,
  'high',
  3,
  0.67,
  'cse@example.com',
  'Example Healthcare Client',
  NOW() - INTERVAL '90 days',
  NOW() - INTERVAL '60 days'
) ON CONFLICT DO NOTHING;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

COMMENT ON TABLE chasen_recommendations IS 'Caches AI-generated recommendations with auto-expiry for constant refresh';
COMMENT ON TABLE chasen_recommendation_interactions IS 'Tracks CSE interactions with recommendations for learning';
COMMENT ON TABLE chasen_success_patterns IS 'Stores successful intervention patterns to improve future recommendations';
COMMENT ON TABLE chasen_generation_log IS 'Audit log for all ChaSen API calls and performance metrics';
COMMENT ON TABLE client_metric_snapshots IS 'Daily snapshots of client metrics for before/after analysis';
