-- ============================================================================
-- Event Compliance Summary: Client ID Enhancement
-- ============================================================================
-- Version: 4.0.0
-- Date: 2025-12-23
-- Status: PENDING
--
-- Purpose: Add client_id support to event_compliance_summary view for
--          improved join performance and data integrity
--
-- Changes from v3.0.0:
-- - Added client_id to segmentation_events table
-- - Added client_id to view output for downstream joins
-- - Maintained backward compatibility with client_name
--
-- Prerequisites:
-- - Phase 1-3 of Client ID Normalisation complete
-- - nps_clients table has integer id column
-- - resolve_client_id_int() function exists
-- ============================================================================

-- ============================================================================
-- Step 1: Add client_id to segmentation_events table
-- ============================================================================

ALTER TABLE segmentation_events
ADD COLUMN IF NOT EXISTS client_id INTEGER REFERENCES nps_clients(id);

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_segmentation_events_client_id
ON segmentation_events(client_id);

-- ============================================================================
-- Step 2: Populate client_id for existing records
-- ============================================================================

UPDATE segmentation_events
SET client_id = resolve_client_id_int(client_name)
WHERE client_id IS NULL;

-- ============================================================================
-- Step 3: Drop existing view (CASCADE to drop dependents)
-- ============================================================================

DROP MATERIALIZED VIEW IF EXISTS event_compliance_summary CASCADE;

-- ============================================================================
-- Step 4: Create enhanced view with client_id
-- ============================================================================

CREATE MATERIALIZED VIEW event_compliance_summary AS
WITH
-- CTE 1: Get all client-segment-tier mappings including segment change history
client_segment_periods AS (
  -- Get segments from client_segmentation table (clients with segment history)
  SELECT DISTINCT
    cs.client_name,
    c.id as client_id,  -- Added: client_id from nps_clients
    cs.tier_id,
    COALESCE(t.tier_name, c.segment) as segment,
    c.cse,
    EXTRACT(YEAR FROM cs.effective_from)::INTEGER as year
  FROM client_segmentation cs
  JOIN segmentation_tiers t ON t.id = cs.tier_id
  LEFT JOIN nps_clients c ON c.client_name = cs.client_name
  WHERE cs.effective_from IS NOT NULL
    AND cs.client_name != 'Parkway'

  UNION

  -- Include clients without segment change history (use current segment from nps_clients)
  SELECT DISTINCT
    c.client_name,
    c.id as client_id,  -- Added: client_id
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

-- CTE 2: Get latest segment for display purposes
latest_segment AS (
  SELECT DISTINCT ON (client_name, year)
    client_name,
    client_id,
    segment,
    cse,
    year
  FROM client_segment_periods
  ORDER BY client_name, year, segment DESC
),

-- CTE 3: Get tier requirements with event type details
tier_requirements AS (
  SELECT
    ter.tier_id,
    ter.event_type_id,
    ter.frequency as expected_frequency,
    et.event_name,
    et.event_code
  FROM tier_event_requirements ter
  JOIN segmentation_event_types et ON et.id = ter.event_type_id
  WHERE ter.frequency > 0
),

-- CTE 4: Combine requirements across all segment periods for each client-year
combined_requirements AS (
  SELECT
    csp.client_name,
    csp.client_id,  -- Added: client_id
    csp.year,
    tr.event_type_id,
    tr.event_name,
    tr.event_code,
    MAX(tr.expected_frequency) as expected_count
  FROM client_segment_periods csp
  INNER JOIN tier_requirements tr ON tr.tier_id = csp.tier_id
  GROUP BY
    csp.client_name,
    csp.client_id,
    csp.year,
    tr.event_type_id,
    tr.event_name,
    tr.event_code
),

-- CTE 5: Aggregate completed events by client, year, and event type
-- Now uses client_id where available for better performance
event_counts AS (
  SELECT
    se.client_name,
    se.client_id,  -- Added: uses new column
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
  GROUP BY se.client_name, se.client_id, se.event_year, se.event_type_id
),

-- CTE 6: Calculate per-event-type compliance for each client
event_type_compliance AS (
  SELECT
    cr.client_name,
    cr.client_id,  -- Added: client_id
    cr.year,
    cr.event_type_id,
    cr.event_name,
    cr.event_code,
    cr.expected_count,
    COALESCE(ec.completed_count, 0) as actual_count,
    COALESCE(ec.completed_events, '[]'::json) as events,

    CASE
      WHEN cr.expected_count > 0 THEN
        ROUND((COALESCE(ec.completed_count, 0)::DECIMAL / cr.expected_count) * 100)
      WHEN COALESCE(ec.completed_count, 0) > 0 THEN 100
      ELSE 0
    END as compliance_percentage,

    CASE
      WHEN cr.expected_count > 0 THEN
        CASE
          WHEN ROUND((COALESCE(ec.completed_count, 0)::DECIMAL / cr.expected_count) * 100) < 50 THEN 'critical'
          WHEN ROUND((COALESCE(ec.completed_count, 0)::DECIMAL / cr.expected_count) * 100) < 100 THEN 'at-risk'
          WHEN ROUND((COALESCE(ec.completed_count, 0)::DECIMAL / cr.expected_count) * 100) = 100 THEN 'compliant'
          ELSE 'exceeded'
        END
      WHEN COALESCE(ec.completed_count, 0) > 0 THEN 'exceeded'
      ELSE 'critical'
    END as status,

    'high' as priority_level,
    TRUE as is_mandatory

  FROM combined_requirements cr
  LEFT JOIN event_counts ec
    ON (ec.client_id = cr.client_id OR ec.client_name = cr.client_name)  -- Dual join for compatibility
    AND ec.event_year = cr.year
    AND ec.event_type_id = cr.event_type_id
),

-- CTE 7: Aggregate to client-year level with all event compliance data
client_year_summary AS (
  SELECT
    etc.client_name,
    etc.client_id,  -- Added: client_id in output
    ls.segment,
    ls.cse,
    etc.year,

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
        'is_mandatory', etc.is_mandatory,
        'events', etc.events
      )
      ORDER BY
        etc.is_mandatory DESC,
        etc.compliance_percentage ASC
    ) as event_compliance,

    COUNT(*) as total_event_types_count,
    COUNT(*) FILTER (WHERE etc.compliance_percentage >= 100) as compliant_event_types_count,

    ROUND(
      (COUNT(*) FILTER (WHERE etc.compliance_percentage >= 100)::DECIMAL /
       NULLIF(COUNT(*), 0)) * 100
    ) as overall_compliance_score,

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
  INNER JOIN latest_segment ls
    ON (ls.client_id = etc.client_id OR ls.client_name = etc.client_name)
    AND ls.year = etc.year
  GROUP BY etc.client_name, etc.client_id, ls.segment, ls.cse, etc.year
)

-- Final SELECT: Return client-year compliance summary with client_id
SELECT
  client_name,
  client_id,  -- NEW: Added for downstream FK joins
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
-- Step 5: Create indexes for fast lookups
-- ============================================================================

CREATE INDEX idx_event_compliance_client_year
  ON event_compliance_summary(client_name, year);

CREATE INDEX idx_event_compliance_client_id
  ON event_compliance_summary(client_id);

CREATE INDEX idx_event_compliance_client_id_year
  ON event_compliance_summary(client_id, year DESC);

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

CREATE UNIQUE INDEX idx_event_compliance_unique_client_year
  ON event_compliance_summary(client_name, year);

-- ============================================================================
-- Step 6: Grant permissions
-- ============================================================================

GRANT SELECT ON event_compliance_summary TO anon, authenticated;

-- ============================================================================
-- Step 7: Initial refresh
-- ============================================================================

REFRESH MATERIALIZED VIEW event_compliance_summary;

-- ============================================================================
-- Step 8: Notify PostgREST to reload schema
-- ============================================================================

NOTIFY pgrst, 'reload schema';

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- 1. Check view has client_id populated
-- SELECT client_name, client_id, year FROM event_compliance_summary LIMIT 10;

-- 2. Check segmentation_events has client_id
-- SELECT client_name, client_id FROM segmentation_events LIMIT 10;

-- 3. Verify join performance (should be faster with client_id)
-- EXPLAIN ANALYZE SELECT * FROM event_compliance_summary WHERE client_id = 2;
