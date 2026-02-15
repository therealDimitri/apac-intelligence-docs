-- Fix: Use LATEST segment requirements only (Option A)
-- This matches the Excel client sheets which show current segment requirements

DROP MATERIALIZED VIEW IF EXISTS event_compliance_summary CASCADE;

CREATE MATERIALIZED VIEW event_compliance_summary AS  
WITH
-- CTE 1: Get LATEST segment for each client in 2025
latest_segment_2025 AS (
  SELECT DISTINCT ON (client_name)
    cs.client_name,
    cs.tier_id,
    t.tier_name as segment,
    c.cse,
    2025 as year,
    cs.effective_from
  FROM client_segmentation cs
  JOIN segmentation_tiers t ON t.id = cs.tier_id
  LEFT JOIN nps_clients c ON c.client_name = cs.client_name
  WHERE cs.effective_from >= '2025-01-01'
    AND cs.effective_from < '2026-01-01'
    AND c.client_name != 'Parkway'
  ORDER BY client_name, effective_from DESC  -- Latest segment first
),

-- CTE 2: Get requirements for LATEST segment ONLY
latest_segment_requirements AS (
  SELECT
    ls.client_name,
    ls.segment,
    ls.cse,
    ls.year,
    tr.event_type_id,
    et.event_name,
    et.event_code,
    tr.frequency as required_count
  FROM latest_segment_2025 ls
  JOIN tier_event_requirements tr ON tr.tier_id = ls.tier_id
  JOIN segmentation_event_types et ON et.id = tr.event_type_id
  WHERE tr.frequency > 0  -- Only events required for the LATEST segment
),

-- CTE 3: Get event counts for the full year
event_counts AS (
  SELECT
    client_name,
    event_year,
    event_type_id,
    COUNT(*) FILTER (WHERE completed = true) as completed_count
  FROM segmentation_events
  WHERE event_year = 2025
  GROUP BY client_name, event_year, event_type_id
),

-- CTE 4: Calculate compliance per event
event_compliance_calc AS (
  SELECT
    r.client_name,
    r.year,
    r.segment,
    r.cse,
    r.event_type_id,
    r.event_name,
    r.event_code,
    r.required_count as expected_count,
    COALESCE(ec.completed_count, 0) as actual_count,
    CASE
      WHEN r.required_count > 0 THEN
        ROUND((COALESCE(ec.completed_count, 0)::DECIMAL / r.required_count) * 100)
      ELSE 0
    END as compliance_percentage
  FROM latest_segment_requirements r
  LEFT JOIN event_counts ec ON ec.client_name = r.client_name
    AND ec.event_year = r.year
    AND ec.event_type_id = r.event_type_id
)

-- Final aggregation: ONE row per client-year
SELECT
  client_name,
  MAX(segment) as segment,
  MAX(cse) as cse,
  year,
  json_agg(
    json_build_object(
      'event_type_id', event_type_id,
      'event_type_name', event_name,
      'event_code', event_code,
      'expected_count', expected_count,
      'actual_count', actual_count,
      'compliance_percentage', compliance_percentage,
      'status', CASE
        WHEN compliance_percentage < 50 THEN 'critical'
        WHEN compliance_percentage < 100 THEN 'at-risk'
        WHEN compliance_percentage = 100 THEN 'compliant'
        ELSE 'exceeded'
      END,
      'priority_level', 'medium',
      'events', '[]'::json
    )
    ORDER BY compliance_percentage ASC
  ) as event_compliance,
  COUNT(*) as total_event_types_count,
  COUNT(*) FILTER (WHERE compliance_percentage >= 100) as compliant_event_types_count,
  ROUND((COUNT(*) FILTER (WHERE compliance_percentage >= 100)::DECIMAL / NULLIF(COUNT(*), 0)) * 100) as overall_compliance_score,
  CASE
    WHEN ROUND((COUNT(*) FILTER (WHERE compliance_percentage >= 100)::DECIMAL / NULLIF(COUNT(*), 0)) * 100) < 50 THEN 'critical'
    WHEN ROUND((COUNT(*) FILTER (WHERE compliance_percentage >= 100)::DECIMAL / NULLIF(COUNT(*), 0)) * 100) < 100 THEN 'at-risk'
    ELSE 'compliant'
  END as overall_status,
  NOW() as last_updated
FROM event_compliance_calc
GROUP BY client_name, year;

-- Indexes
CREATE INDEX idx_event_compliance_client_year ON event_compliance_summary(client_name, year);
CREATE INDEX idx_event_compliance_cse ON event_compliance_summary(cse);
CREATE INDEX idx_event_compliance_year ON event_compliance_summary(year DESC);
CREATE INDEX idx_event_compliance_status ON event_compliance_summary(overall_status);
CREATE INDEX idx_event_compliance_segment ON event_compliance_summary(segment);
CREATE INDEX idx_event_compliance_cse_year ON event_compliance_summary(cse, year DESC);

-- Permissions
GRANT SELECT ON event_compliance_summary TO anon, authenticated;

-- Refresh
REFRESH MATERIALIZED VIEW event_compliance_summary;
