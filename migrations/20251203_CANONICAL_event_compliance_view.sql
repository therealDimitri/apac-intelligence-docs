-- ============================================================================
-- CANONICAL Event Compliance Materialized View
-- ============================================================================
-- Version: 3.0.0
-- Date: 2025-12-03
-- Status: PRODUCTION-READY
--
-- Purpose: Single source of truth for client segmentation compliance tracking
--
-- Breaking Changes from Previous Versions:
-- - Uses actual column name 'frequency' (not required_count or is_mandatory)
-- - Aggregates across ALL segment periods using MAX
-- - Single row per client-year (no duplicates)
-- - Added unique constraint to enforce single-record rule
--
-- Consolidates Logic From:
-- - 20251202_create_event_compliance_materialized_view.sql
-- - 20251202_fix_event_compliance_view_segment_changes.sql
-- - 20251202_final_fix_single_record_per_client.sql
-- - 20251202_update_compliance_view_for_tier_requirements.sql
-- - 20251203_compliance_view_latest_segment_only.sql
-- - 20251203_fix_materialized_view_column_name.sql
-- - scripts/apply-final-materialized-view.mjs
-- ============================================================================

-- Step 1: Drop existing view
DROP MATERIALIZED VIEW IF EXISTS event_compliance_summary CASCADE;

-- Step 2: Create canonical view
CREATE MATERIALIZED VIEW event_compliance_summary AS
WITH
-- CTE 1: Get all client-segment-tier mappings including segment change history
client_segment_periods AS (
  -- Get segments from client_segmentation table (clients with segment history)
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
    AND cs.client_name != 'Parkway'

  UNION

  -- Include clients without segment change history (use current segment from nps_clients)
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

-- CTE 2: Get latest segment for display purposes
latest_segment AS (
  SELECT DISTINCT ON (client_name, year)
    client_name,
    segment,
    cse,
    year
  FROM client_segment_periods
  ORDER BY client_name, year, segment DESC
),

-- CTE 3: Get tier requirements with event type details
-- ✅ FIXED: Uses actual column name 'frequency' (not required_count or is_mandatory)
tier_requirements AS (
  SELECT
    ter.tier_id,
    ter.event_type_id,
    ter.frequency as expected_frequency,  -- Actual column name from schema
    et.event_name,
    et.event_code
  FROM tier_event_requirements ter
  JOIN segmentation_event_types et ON et.id = ter.event_type_id
  WHERE ter.frequency > 0
),

-- CTE 4: Combine requirements across all segment periods for each client-year
-- Business Rule: Use MAX requirement across all segments in the year
-- This ensures clients who upgrade mid-year are held to higher standard
-- AND clients who downgrade mid-year still get credit for maintaining higher standard
combined_requirements AS (
  SELECT
    csp.client_name,
    csp.year,
    tr.event_type_id,
    tr.event_name,
    tr.event_code,
    MAX(tr.expected_frequency) as expected_count  -- ✅ FIXED: Use MAX across all segment periods
  FROM client_segment_periods csp
  INNER JOIN tier_requirements tr ON tr.tier_id = csp.tier_id
  GROUP BY
    csp.client_name,
    csp.year,
    tr.event_type_id,
    tr.event_name,
    tr.event_code
),

-- CTE 5: Aggregate completed events by client, year, and event type
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

-- CTE 6: Calculate per-event-type compliance for each client
event_type_compliance AS (
  SELECT
    cr.client_name,
    cr.year,
    cr.event_type_id,
    cr.event_name,
    cr.event_code,
    cr.expected_count,
    COALESCE(ec.completed_count, 0) as actual_count,
    COALESCE(ec.completed_events, '[]'::json) as events,

    -- Calculate compliance percentage
    CASE
      WHEN cr.expected_count > 0 THEN
        ROUND((COALESCE(ec.completed_count, 0)::DECIMAL / cr.expected_count) * 100)
      WHEN COALESCE(ec.completed_count, 0) > 0 THEN 100
      ELSE 0
    END as compliance_percentage,

    -- Determine status based on compliance percentage
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

    -- Priority level: All events considered high priority
    'high' as priority_level,

    -- is_mandatory: Default to true since all tier requirements are mandatory
    TRUE as is_mandatory

  FROM combined_requirements cr
  LEFT JOIN event_counts ec
    ON ec.client_name = cr.client_name
    AND ec.event_year = cr.year
    AND ec.event_type_id = cr.event_type_id
),

-- CTE 7: Aggregate to client-year level with all event compliance data
client_year_summary AS (
  SELECT
    etc.client_name,
    ls.segment,  -- Use latest segment for display
    ls.cse,
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
        'is_mandatory', etc.is_mandatory,
        'events', etc.events
      )
      ORDER BY
        etc.is_mandatory DESC,
        etc.compliance_percentage ASC
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
  INNER JOIN latest_segment ls
    ON ls.client_name = etc.client_name
    AND ls.year = etc.year
  GROUP BY etc.client_name, ls.segment, ls.cse, etc.year
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
-- Step 3: Create indexes for fast lookups
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

-- ✅ NEW: Add unique constraint to prevent duplicates
CREATE UNIQUE INDEX idx_event_compliance_unique_client_year
  ON event_compliance_summary(client_name, year);

-- ============================================================================
-- Step 4: Grant permissions
-- ============================================================================

GRANT SELECT ON event_compliance_summary TO anon, authenticated;

-- ============================================================================
-- Step 5: Initial refresh
-- ============================================================================

REFRESH MATERIALIZED VIEW event_compliance_summary;

-- ============================================================================
-- Step 6: Notify PostgREST to reload schema
-- ============================================================================

NOTIFY pgrst, 'reload schema';

-- ============================================================================
-- VERIFICATION QUERIES (Run after migration)
-- ============================================================================

-- 1. Check view was created and has data
-- SELECT COUNT(*) FROM event_compliance_summary;
-- Expected: ~90 rows (45 clients × 2 years)

-- 2. Check no duplicates (unique constraint should prevent this)
-- SELECT client_name, year, COUNT(*)
-- FROM event_compliance_summary
-- GROUP BY client_name, year
-- HAVING COUNT(*) > 1;
-- Expected: 0 rows

-- 3. Spot check Epworth Healthcare
-- SELECT
--   client_name,
--   year,
--   segment,
--   overall_compliance_score,
--   (SELECT SUM((elem->>'expected_count')::int)
--    FROM json_array_elements(event_compliance) elem) as total_expected,
--   (SELECT SUM((elem->>'actual_count')::int)
--    FROM json_array_elements(event_compliance) elem) as total_completed
-- FROM event_compliance_summary
-- WHERE client_name = 'Epworth Healthcare' AND year = 2025;
-- Expected: 1 row with total_expected = 27, total_completed = 30

-- 4. Check all statuses are valid
-- SELECT DISTINCT overall_status FROM event_compliance_summary;
-- Expected: Only 'critical', 'at-risk', 'compliant'

-- 5. Check view freshness
-- SELECT MAX(last_updated) FROM event_compliance_summary;
-- Expected: Recent timestamp (within last few minutes)

-- ============================================================================
-- ROLLBACK INSTRUCTIONS
-- ============================================================================
-- To rollback this migration:
-- 1. Run: DROP MATERIALIZED VIEW IF EXISTS event_compliance_summary CASCADE;
-- 2. Re-apply previous version if needed
-- 3. Verify data: SELECT COUNT(*) FROM event_compliance_summary;
-- ============================================================================

-- ============================================================================
-- MAINTENANCE INSTRUCTIONS
-- ============================================================================
-- To refresh the view (run daily or after data changes):
-- REFRESH MATERIALIZED VIEW event_compliance_summary;
--
-- To check when view was last refreshed:
-- SELECT MAX(last_updated) FROM event_compliance_summary;
--
-- To see view definition:
-- SELECT pg_get_viewdef('event_compliance_summary', true);
-- ============================================================================
