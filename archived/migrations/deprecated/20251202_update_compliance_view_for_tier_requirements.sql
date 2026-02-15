-- Migration: Update Event Compliance View to Use New Tier Requirements Table
-- Date: 2025-12-02
-- Purpose: Update view to use tier_event_requirements.frequency instead of required_count
--          and remove is_mandatory field (not in new schema)
--
-- Changes:
--   - tier_event_requirements.required_count → tier_event_requirements.frequency
--   - Remove is_mandatory references (field doesn't exist in new schema)
--   - Keep all other logic for segment change handling

-- ============================================================================
-- 1. DROP AND RECREATE MATERIALIZED VIEW
-- ============================================================================

DROP MATERIALIZED VIEW IF EXISTS event_compliance_summary CASCADE;

CREATE MATERIALIZED VIEW event_compliance_summary AS
WITH
-- CTE 1: Get all client-segment-tier mappings including segment change history
client_segment_periods AS (
  SELECT DISTINCT
    cs.client_name,
    cs.tier_id,
    COALESCE(t.tier_name, c.segment) as segment,
    c.cse,
    EXTRACT(YEAR FROM cs.effective_from)::INTEGER as year
  FROM client_segmentation cs
  JOIN segmentation_tiers t ON t.id = cs.tier_id
  LEFT JOIN nps_clients c ON c.client_name = cs.client_name
  WHERE cs.effective_from IS NOT NULL
    AND c.client_name != 'Parkway'  -- Exclude churned clients

  UNION

  -- Also include clients without segment change history (use current segment)
  SELECT DISTINCT
    c.client_name,
    t.id as tier_id,
    c.segment,
    c.cse,
    EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER as year
  FROM nps_clients c
  LEFT JOIN segmentation_tiers t ON t.tier_name = c.segment
  WHERE c.segment IS NOT NULL
    AND c.client_name != 'Parkway'
    AND NOT EXISTS (
      SELECT 1 FROM client_segmentation cs2
      WHERE cs2.client_name = c.client_name
    )
),

-- CTE 2: Get tier requirements with event type details
-- UPDATED: Use frequency instead of required_count, remove is_mandatory
tier_requirements AS (
  SELECT
    ter.tier_id,
    ter.event_type_id,
    ter.frequency as required_count,  -- Map frequency to required_count for consistency
    et.event_name,
    et.event_code
  FROM tier_event_requirements ter
  JOIN segmentation_event_types et ON et.id = ter.event_type_id
  WHERE ter.frequency > 0  -- Exclude events with 0 frequency (not required for this tier)
),

-- CTE 3: Combine requirements across ALL segment periods for each client-year
-- Deduplicate event types by taking MAX required_count if event appears in multiple tiers
-- Note: Do NOT group by segment here - we want ONE row per client-year-event
requirements_aggregated AS (
  SELECT
    csp.client_name,
    csp.year,
    tr.event_type_id,
    tr.event_name,
    tr.event_code,
    MAX(tr.required_count) as required_count,  -- Take max frequency across all segments
    MAX(csp.cse) as cse  -- Use any CSE (should be the same)
  FROM client_segment_periods csp
  INNER JOIN tier_requirements tr ON tr.tier_id = csp.tier_id
  GROUP BY
    csp.client_name,
    csp.year,
    tr.event_type_id,
    tr.event_name,
    tr.event_code
),

-- CTE 4: Get the LATEST segment for each client-year (for display purposes only)
latest_segment AS (
  SELECT DISTINCT ON (client_name, year)
    client_name,
    segment,
    year
  FROM client_segment_periods csp
  JOIN client_segmentation cs ON cs.client_name = csp.client_name AND cs.tier_id = csp.tier_id
  ORDER BY client_name, year, cs.effective_from DESC  -- Most recent segment
),

-- CTE 5: Add segment for display (join aggregated requirements with latest segment)
combined_requirements AS (
  SELECT
    ra.client_name,
    ls.segment,  -- Latest segment for display
    ra.cse,
    ra.year,
    ra.event_type_id,
    ra.event_name,
    ra.event_code,
    ra.required_count
  FROM requirements_aggregated ra
  INNER JOIN latest_segment ls ON ls.client_name = ra.client_name AND ls.year = ra.year
),

-- CTE 6: Aggregate completed events by client, year, and event type
event_counts AS (
  SELECT
    se.client_name,
    se.event_year,
    se.event_type_id,
    COUNT(*) FILTER (WHERE se.completed = true) as completed_count,
    COUNT(*) as total_count,
    json_agg(
      json_build_object(
        'id', se.id,
        'event_date', se.event_date,
        'period', se.period,
        'completed', se.completed,
        'completed_date', se.completed_date,
        'notes', se.notes,
        'meeting_link', se.meeting_link
      )
      ORDER BY se.event_date DESC
    ) FILTER (WHERE se.completed = true) as completed_events
  FROM segmentation_events se
  GROUP BY se.client_name, se.event_year, se.event_type_id
),

-- CTE 7: Calculate per-event-type compliance for each client
-- UPDATED: Removed is_mandatory field and logic
event_type_compliance AS (
  SELECT
    cr.client_name,
    cr.segment,
    cr.cse,
    cr.year,
    cr.event_type_id,
    cr.event_name,
    cr.event_code,
    cr.required_count as expected_count,
    COALESCE(ec.completed_count, 0) as actual_count,
    COALESCE(ec.completed_events, '[]'::json) as events,

    -- Calculate compliance percentage
    CASE
      WHEN cr.required_count > 0 THEN
        ROUND((COALESCE(ec.completed_count, 0)::DECIMAL / cr.required_count) * 100)
      WHEN COALESCE(ec.completed_count, 0) > 0 THEN 100
      ELSE 0
    END as compliance_percentage,

    -- Determine status based on compliance percentage
    CASE
      WHEN cr.required_count > 0 THEN
        CASE
          WHEN ROUND((COALESCE(ec.completed_count, 0)::DECIMAL / cr.required_count) * 100) < 50 THEN 'critical'
          WHEN ROUND((COALESCE(ec.completed_count, 0)::DECIMAL / cr.required_count) * 100) < 100 THEN 'at-risk'
          WHEN ROUND((COALESCE(ec.completed_count, 0)::DECIMAL / cr.required_count) * 100) = 100 THEN 'compliant'
          ELSE 'exceeded'
        END
      WHEN COALESCE(ec.completed_count, 0) > 0 THEN 'exceeded'
      ELSE 'critical'
    END as status,

    -- All events have medium priority (no is_mandatory field)
    'medium' as priority_level

  FROM combined_requirements cr
  LEFT JOIN event_counts ec
    ON ec.client_name = cr.client_name
    AND ec.event_year = cr.year
    AND ec.event_type_id = cr.event_type_id
),

-- CTE 8: Aggregate to client-year level with all event compliance data
-- IMPORTANT: Group by client_name and year ONLY (not segment) to get one row per client-year
client_year_summary AS (
  SELECT
    etc.client_name,
    MAX(etc.segment) as segment,  -- Use latest segment (all rows have same segment from combined_requirements)
    MAX(etc.cse) as cse,
    etc.year,

    -- Aggregate event_compliance as JSON array
    json_agg(
      json_build_object(
        'event_type_id', etc.event_type_id,
        'event_type_name', etc.event_name,
        'event_code', etc.event_code,
        'expected_count', etc.expected_count,
        'actual_count', etc.actual_count,
        'compliance_percentage', etc.compliance_percentage,
        'status', etc.status,
        'priority_level', etc.priority_level,
        'events', etc.events
      )
      ORDER BY etc.compliance_percentage ASC  -- Lowest compliance first
    ) as event_compliance,

    -- Calculate overall compliance metrics
    COUNT(*) as total_event_types_count,
    COUNT(*) FILTER (WHERE etc.compliance_percentage >= 100) as compliant_event_types_count,

    -- Overall compliance score: (Compliant Event Types / Total Event Types) × 100
    ROUND(
      (COUNT(*) FILTER (WHERE etc.compliance_percentage >= 100)::DECIMAL /
       NULLIF(COUNT(*), 0)) * 100
    ) as overall_compliance_score,

    -- Overall status based on score
    CASE
      WHEN ROUND(
        (COUNT(*) FILTER (WHERE etc.compliance_percentage >= 100)::DECIMAL /
         NULLIF(COUNT(*), 0)) * 100
      ) < 50 THEN 'critical'
      WHEN ROUND(
        (COUNT(*) FILTER (WHERE etc.compliance_percentage >= 100)::DECIMAL /
         NULLIF(COUNT(*), 0)) * 100
      ) < 100 THEN 'at-risk'
      ELSE 'compliant'
    END as overall_status,

    NOW() as last_updated

  FROM event_type_compliance etc
  GROUP BY etc.client_name, etc.year  -- Remove etc.segment and etc.cse from GROUP BY
)

-- Final SELECT: Return client-year compliance summary
SELECT
  client_name,
  segment,
  cse,
  year,
  event_compliance,
  overall_compliance_score,
  overall_status,
  compliant_event_types_count,
  total_event_types_count,
  last_updated
FROM client_year_summary
ORDER BY year DESC, client_name;

-- ============================================================================
-- 2. RECREATE INDEXES FOR FAST LOOKUPS
-- ============================================================================

CREATE INDEX idx_event_compliance_client_year
ON event_compliance_summary(client_name, year);

CREATE INDEX idx_event_compliance_cse
ON event_compliance_summary(cse);

CREATE INDEX idx_event_compliance_year
ON event_compliance_summary(year DESC);

CREATE INDEX idx_event_compliance_status
ON event_compliance_summary(overall_status);

CREATE INDEX idx_event_compliance_segment
ON event_compliance_summary(segment);

CREATE INDEX idx_event_compliance_cse_year
ON event_compliance_summary(cse, year DESC);

-- ============================================================================
-- 3. GRANT PERMISSIONS
-- ============================================================================

GRANT SELECT ON event_compliance_summary TO anon, authenticated;

-- ============================================================================
-- 4. INITIAL REFRESH
-- ============================================================================

REFRESH MATERIALIZED VIEW event_compliance_summary;

--  ============================================================================
-- NOTES
-- ============================================================================

-- Key Changes:
-- 1. tier_event_requirements.required_count → tier_event_requirements.frequency
-- 2. Removed is_mandatory field and related logic
-- 3. All events now have 'medium' priority
-- 4. Events with frequency=0 are excluded (not required for that tier)
--
-- This enables time-aware compliance:
-- - MinDef Maintain tier (Jan-June): EVP Engagement frequency=0 (excluded)
-- - MinDef Leverage tier (July-Dec): EVP Engagement frequency=1 (required)
-- - View aggregates across segments and takes MAX frequency
