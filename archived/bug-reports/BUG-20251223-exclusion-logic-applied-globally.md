# Bug Report: Event Exclusion Logic Applied Globally to All Clients

**Date:** 2025-12-23
**Severity:** Critical
**Status:** Resolved
**Component:** Database / Materialized Views / event_compliance_summary

## Summary

When implementing client-specific event exclusions for Department of Health - Victoria, the exclusion logic was applied globally to ALL clients that had pre-existing exclusion records in the `client_event_exclusions` table. This caused multiple clients to display only 2 event types instead of the expected 9+.

## Affected Clients

The following clients were impacted by this bug (all had pre-existing exclusions imported on 2025-12-02 with reason "Greyed out in Excel"):

| Client                          | Exclusions Count | Expected Event Types | Displayed Event Types |
| ------------------------------- | ---------------- | -------------------- | --------------------- |
| SA Health (iPro)                | 3                | 9                    | 6                     |
| Albury Wodonga Health           | 7                | 9                    | 2                     |
| Gippsland Health Alliance       | 8                | 9                    | 1                     |
| Grampians Health Alliance       | 8                | 9                    | 1                     |
| Ministry of Defence Singapore   | 1                | 9                    | 8                     |
| Department of Health - Victoria | 7                | 9                    | 2                     |
| Te Whatu Ora Waikato            | 7                | 9                    | 2                     |

## Root Cause

The updated `event_compliance_summary` materialized view included a `WHERE NOT EXISTS` clause in the `combined_requirements` CTE that filtered out event types based on the `client_event_exclusions` table:

```sql
combined_requirements AS (
  SELECT
    csp.client_name,
    csp.year,
    tr.event_type_id,
    tr.event_name,
    tr.event_code,
    MAX(tr.expected_frequency) as expected_count
  FROM client_segment_periods csp
  INNER JOIN tier_requirements tr ON tr.tier_id = csp.tier_id
  WHERE NOT EXISTS (
    SELECT 1 FROM client_event_exclusions cee
    WHERE cee.client_name = csp.client_name
      AND cee.event_type_id = tr.event_type_id
  )  -- THIS WAS THE PROBLEM
  GROUP BY ...
)
```

The `client_event_exclusions` table already contained legacy exclusion records imported from Excel on 2025-12-02, which were not intended to be used for compliance calculations. These were informational records indicating events that were "greyed out" in the original Excel tracking sheet.

## Resolution

1. **Restored the canonical view** WITHOUT the exclusion logic by dropping and recreating `event_compliance_summary` using the SQL from `docs/migrations/20251203_CANONICAL_event_compliance_view.sql`

2. **Recreated `client_health_summary`** which was dropped by CASCADE when updating `event_compliance_summary`

3. **Fixed case-sensitive column name** issue: The `actions` table uses `"Status"` (with capital S), not `status`

## SQL Executed

### 1. Restored Canonical Event Compliance Summary View

The canonical view was restored via Supabase Dashboard SQL Editor, removing the `WHERE NOT EXISTS (SELECT 1 FROM client_event_exclusions...)` filter.

### 2. Recreated Client Health Summary View

```sql
-- Simplified Client Health Summary (with correct case-sensitive column)
DROP MATERIALIZED VIEW IF EXISTS client_health_summary CASCADE;

CREATE MATERIALIZED VIEW client_health_summary AS
SELECT
  c.client_name,
  c.cse,
  c.segment,
  COALESCE(nps.current_score, 0) as nps_score,
  ...
  COUNT(DISTINCT a.id) FILTER (WHERE a."Status" != 'Completed') as open_action_count
  ...
```

## Verification

After the fix:

- **Te Whatu Ora Waikato**: 9 event types, 100% compliance score
- **Albury Wodonga Health**: 9 event types, 100% compliance score
- **Client Health Summary**: All clients loading correctly with health scores

## Prevention

1. **Do not apply exclusion logic globally** without careful consideration of existing data
2. **Check for existing records** in `client_event_exclusions` before implementing filtering logic
3. **Test with all affected clients** before deploying view changes
4. **Document the intended purpose** of exclusion records (informational vs. functional)

## Future Considerations

If client-specific event exclusions are needed in the future:

1. Create a new column `is_active` or `exclude_from_compliance` to differentiate between informational and functional exclusions
2. Only filter on records where the exclusion is explicitly marked as active
3. Consider using a separate table for compliance-affecting exclusions

## Related Files

- `docs/migrations/20251203_CANONICAL_event_compliance_view.sql` - Source of truth for canonical view
- `scripts/restore-canonical-view-direct.mjs` - Script to restore canonical view
- `scripts/restore-canonical-compliance-view.mjs` - Alternative restore script
- `docs/bug-reports/BUG-20251223-cascade-drop-client-health-summary.md` - Related bug report

## Timeline

1. **2025-12-02**: Legacy exclusion records imported from Excel
2. **2025-12-23 (earlier)**: Exclusion logic added to `event_compliance_summary` for DoH Victoria
3. **2025-12-23 (this fix)**: Bug identified and canonical view restored
