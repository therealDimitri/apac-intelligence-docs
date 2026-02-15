# Bug Report: Compliance Client Name Alias Matching

**Date:** 2026-01-11
**Severity:** High
**Component:** Segmentation / Compliance Calculation
**Status:** RESOLVED

## Summary

Te Whatu Ora Waikato (and potentially other clients) showed 0% compliance with "No Events Found" for all event types, despite events existing in the database.

## Root Cause

The `event_compliance_summary` materialized view was joining `segmentation_events.client_name` directly with client data from `nps_clients` and other tables **without** using the `client_name_aliases` table for name resolution.

Events stored under variations like "Waikato" would not match the canonical name "Te Whatu Ora Waikato" used in the client reference tables.

## Evidence

- Screenshot showed Te Whatu Ora Waikato with 0% overall compliance
- All event types showed "No Events" despite events existing
- Database query revealed events were stored under "Te Whatu Ora Waikato" but the join logic was not resilient to name variations

## Fix Applied

### 1. Updated Materialized View (`20260111_fix_compliance_view_client_aliases.sql`)

Added a `client_name_mapping` CTE that resolves aliases to canonical names:

```sql
client_name_mapping AS (
  SELECT
    display_name as alias,
    canonical_name
  FROM client_name_aliases

  UNION ALL

  SELECT DISTINCT
    canonical_name as alias,
    canonical_name
  FROM client_name_aliases
),
```

Modified the `event_counts` CTE to normalise event client names before aggregation:

```sql
event_counts AS (
  SELECT
    COALESCE(cnm.canonical_name, se.client_name) as client_name,
    ...
  FROM segmentation_events se
  LEFT JOIN client_name_mapping cnm ON LOWER(cnm.alias) = LOWER(se.client_name)
  GROUP BY COALESCE(cnm.canonical_name, se.client_name), se.event_year, se.event_type_id
),
```

### 2. Added Client Aliases (`20260111_add_waikato_client_aliases.sql`)

Added comprehensive aliases for common client name variations:

- Waikato variants (Te Whatu Ora Waikato, Waikato DHB, etc.)
- Barwon Health variants
- Grampians Health variants
- GHA variants
- Albury Wodonga Health variants
- Department of Health Victoria variants
- WA Health variants
- Epworth variants
- Mount Alvernia Hospital variants
- RVEEH variants

## Verification

After applying the fix:

```
Te Whatu Ora Waikato compliance data:
  2025: 100% (2/2 event types)
```

## Files Changed

1. `supabase/migrations/20260111_fix_compliance_view_client_aliases.sql` - Updated materialized view
2. `supabase/migrations/20260111_add_waikato_client_aliases.sql` - Added client aliases
3. `scripts/apply-compliance-alias-fix.mjs` - Migration application script

## Prevention

- The `client_name_aliases` table should be the single source of truth for client name resolution
- All queries that join on client_name should consider using alias resolution
- New clients should have their common name variations added to the aliases table proactively

## Related Issues

- Similar pattern to `BUG-REPORT-20251226-compliance-calculation-mismatch.md`
