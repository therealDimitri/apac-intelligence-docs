# Bug Report: Health Score Not Using Corrected Compliance Data

**Date:** 2026-01-10
**Severity:** High
**Status:** Fixed

## Summary

The Health Score calculation was using raw compliance data from the materialized view (`client.compliance_percentage`) instead of the corrected compliance that accounts for segment changes. This caused clients with segment changes to have artificially inflated health scores.

**Example - Grampians Health:**
- **Before fix:** Health Score 75/100 (using ~100% compliance from materialized view)
- **After fix:** Health Score 41/100 (using correct 44% compliance)

## Root Cause

The compliance fix applied in `useAllClientsCompliance` (which recalculates compliance for segment-changed clients based on their assessment period) was **NOT flowing into the Health Score calculation**.

**Data Flow Problem:**
1. `useEventCompliance` hook correctly recalculates compliance for segment changes
2. Health Score components were reading `client.compliance_percentage` directly from materialized view
3. Materialized view (`client_health_summary`) pulls from `event_compliance_summary` which has raw/uncorrected data

## Files Changed

1. **`src/app/(dashboard)/clients/[clientId]/components/HealthBreakdown.tsx`**
   - Added `useEventCompliance` hook import
   - Changed compliance calculation to use hook data with fallback:
   ```typescript
   const compliancePct = Math.min(
     100,
     eventCompliance?.overall_compliance_score ?? client.compliance_percentage ?? 50
   )
   ```

2. **`src/app/(dashboard)/clients/[clientId]/components/HealthBreakdownV6.tsx`**
   - Added `useEventCompliance` hook import and call
   - Updated compliance calculation same as above

3. **`src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`**
   - Already had `eventCompliance` hook available
   - Updated compliance calculation to use hook data

4. **`src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`**
   - Already had `compliance` hook available
   - Updated compliance calculation to use hook data

## Impact

All clients with segment changes now show correct health scores:

| Client | Old Health Score | New Health Score | Reason |
|--------|-----------------|------------------|--------|
| Grampians Health | 75 | 41 | Compliance: 100% → 44% |
| GHA | ~75 | ~41 | Compliance: 100% → 44% |
| Epworth Healthcare | Higher | Lower | Compliance: 70% → 30% |

## Testing

1. Navigate to client detail page for segment-changed client (e.g., Grampians Health)
2. Verify Health Score reflects corrected compliance
3. Verify "Compliance" badge shows same percentage as modal
4. Console logs show: `[useEventCompliance] RESULT (segment change): Grampians Health, score=44%`

## Technical Notes

- The hook provides real-time compliance with segment change logic
- Falls back to materialized view value while hook is loading (prevents flash)
- Same fix pattern applied to all 4 affected components

## Related

- `docs/guides/BUG-list-modal-compliance-mismatch.md` - Compliance recalculation fix
- `docs/guides/BUG-segmentation-events-not-displaying.md` - Events display fix
