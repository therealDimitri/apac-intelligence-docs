# Bug Fix: GHA Segment Incorrect - Maintain to Leverage

**Date:** 2026-01-10
**Severity:** Low
**Status:** Resolved

## Summary

Gippsland Health Alliance (GHA) was incorrectly listed as "Maintain" segment in Client Portfolios when they should be "Leverage".

## Root Cause Analysis

**Problem:** Data inconsistency between related tables:
- `client_segmentation.tier_id` was correctly pointing to Leverage tier (`9e44cf41-6428-4635-bb02-d2eaa2e31d74`)
- `nps_clients.segment` was incorrectly set to "Maintain"

The `client_health_summary` materialized view uses `nps_clients` as its primary source (via `segmentation_clients` view), which caused GHA to display as "Maintain" despite having the correct tier_id in `client_segmentation`.

## Solution

Updated the `nps_clients` table to set GHA's segment to "Leverage":

```javascript
const { data: npsUpdated, error: npsUpdateError } = await supabase
  .from('nps_clients')
  .update({ segment: 'Leverage' })
  .ilike('client_name', '%Gippsland%')
  .select()
```

## Tables Updated

### 1. `nps_clients`
- **Record:** Gippsland Health Alliance (GHA) (id: 51)
- **Change:** `segment: "Maintain"` → `segment: "Leverage"`

### Verification Performed

| Table | Column | Before | After |
|-------|--------|--------|-------|
| nps_clients | segment | Maintain | Leverage |
| client_segmentation | tier_id | 9e44cf41... (Leverage) | No change needed |
| segmentation_compliance_scores | tier_name | Leverage | No change needed |

## Technical Notes

### Data Flow
The segment display comes from:
1. `nps_clients.segment` → Primary source
2. `client_segmentation.tier_id` → References `segmentation_tiers.id`
3. `client_health_summary` materialized view → Joins these tables

### Why Inconsistency Occurred
The `client_segmentation` table was updated with the correct `tier_id` for Leverage, but the `nps_clients` table wasn't updated simultaneously. This is a manual data entry oversight, not a code bug.

## Impact

- **Data Accuracy:** GHA now correctly shows as "Leverage" segment
- **Portfolio Views:** Both list and card views show correct segment
- **Compliance Tracking:** Segment-based compliance requirements now use correct tier

## Prevention

To prevent future inconsistencies:
1. Consider adding a database trigger to sync segment changes across tables
2. Or use the `client_segmentation.tier_id` as the single source of truth via views

## Related

- BUG-FIX-seg-percent-real-data-and-color-coding.md (Seg% data resolution)
- segmentation_tiers table documentation
