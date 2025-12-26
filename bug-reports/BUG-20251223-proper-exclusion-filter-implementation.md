# Bug Report: Proper Event Exclusion Filter Implementation

**Date:** 2025-12-23
**Severity:** Medium
**Status:** Resolved
**Component:** Database / Materialized Views / event_compliance_summary

## Summary

After restoring the canonical `event_compliance_summary` view to fix the global exclusion bug (BUG-20251223-exclusion-logic-applied-globally.md), the Department of Health - Victoria's Health Check (Opal) event was incorrectly appearing in their compliance calculations. This was because the canonical view had no exclusion logic at all.

## Problem

The canonical view restoration removed ALL exclusion logic, which meant:

- DoH Victoria was showing 11 event types instead of 10 (Health Check Opal should be excluded)
- Their compliance score was calculated incorrectly because it included an event type that was explicitly excluded via business decision

## Root Cause

The `client_event_exclusions` table contains two types of exclusion records:

1. **Business Decision Exclusions** - Events explicitly excluded from compliance calculations (e.g., DoH Victoria's Health Check Opal removal)
2. **Informational Exclusions** - Legacy records imported from Excel with reason "Greyed out in Excel" that were NOT meant to affect compliance calculations

The previous fix removed all exclusion logic, which was correct for informational exclusions but incorrect for business decisions.

## Resolution

Updated the `event_compliance_summary` materialized view with a proper exclusion filter that discriminates between exclusion types:

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
  -- ONLY exclude where reason is a business decision (NOT "Greyed out in Excel")
  WHERE NOT EXISTS (
    SELECT 1 FROM client_event_exclusions cee
    WHERE cee.client_name = csp.client_name
      AND cee.event_type_id = tr.event_type_id
      AND cee.reason NOT LIKE '%Greyed out%'
  )
  GROUP BY
    csp.client_name,
    csp.year,
    tr.event_type_id,
    tr.event_name,
    tr.event_code
)
```

Key change: `AND cee.reason NOT LIKE '%Greyed out%'` ensures only business-decision exclusions are applied.

## Verification Results

After the fix:

| Client                          | Event Types | Compliance | Notes                                                     |
| ------------------------------- | ----------- | ---------- | --------------------------------------------------------- |
| Albury Wodonga Health           | 9           | 100%       | ✅ All standard events (informational exclusions ignored) |
| Department of Health - Victoria | 10          | 90%        | ✅ Health Check (Opal) excluded via business decision     |
| SA Health (iPro)                | 11          | 64%        | ✅ Different tier with more event types                   |
| Te Whatu Ora Waikato            | 9           | 100%       | ✅ All standard events                                    |

## Exclusion Records Summary

From `client_event_exclusions` table:

- **Business Decision** (1 record): DoH Victoria's Health Check (Opal) exclusion
- **Informational** (~41 records): Legacy "Greyed out in Excel" records for various clients

## Related Bug Reports

- `BUG-20251223-exclusion-logic-applied-globally.md` - Previous bug where exclusion logic affected all clients
- `BUG-20251223-cascade-drop-client-health-summary.md` - CASCADE drop issue when updating views

## Files Modified

- `event_compliance_summary` materialized view (via Supabase Dashboard)
- `client_health_summary` materialized view (recreated after CASCADE drop)

## Prevention

1. **Discriminate exclusion types** - Always check the `reason` field when applying exclusion logic
2. **Document exclusion purposes** - Clearly mark whether exclusions are informational or functional
3. **Consider adding `is_active` column** - For future implementations, add a boolean flag to explicitly control which exclusions affect compliance

## SQL Executed

The fix was executed via Supabase Dashboard SQL Editor due to database connection issues with the Node.js `postgres` library.
