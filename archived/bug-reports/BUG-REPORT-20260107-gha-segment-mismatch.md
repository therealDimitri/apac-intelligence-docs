# Bug Report: GHA Assigned Wrong Segment

**Date**: 7 January 2026
**Status**: Fixed
**Severity**: Medium
**Component**: Client Segmentation

## Issue

Gippsland Health Alliance (GHA) was displaying the wrong segment. The user reported it should be "Leverage" not "Maintain".

## Root Cause

The `clients` table had GHA assigned to segment "Steady State" while the `client_segmentation` table correctly had tier_id pointing to "Leverage". This data inconsistency caused different parts of the UI to show different segment values depending on which table was being queried.

**Before Fix:**
- `clients.segment`: "Steady State"
- `client_segmentation.tier_id`: "9e44cf41-6428-4635-bb02-d2eaa2e31d74" (Leverage)

## Solution

Updated the `clients` table to set GHA's segment to "Leverage" to match the `client_segmentation` table.

```javascript
await supabase
  .from('clients')
  .update({ segment: 'Leverage' })
  .ilike('canonical_name', '%gippsland%')
```

## Verification

**After Fix:**
- `clients.segment`: "Leverage"
- `client_segmentation.tier_id`: "9e44cf41-6428-4635-bb02-d2eaa2e31d74" (Leverage)

Both tables now consistently show GHA as "Leverage" segment.

## Tables Affected

| Table | Column | Old Value | New Value |
|-------|--------|-----------|-----------|
| clients | segment | Steady State | Leverage |
| client_segmentation | tier_id | (unchanged) | 9e44cf41-... (Leverage) |

## Notes

- The `clients` table uses plain text segment names ("Steady State", "Sleeping Giant", etc.)
- The `client_segmentation` table uses `tier_id` foreign keys to `segmentation_tiers`
- Both tables should be kept in sync when updating client segments
- Consider creating a database trigger to keep these tables synchronised automatically
