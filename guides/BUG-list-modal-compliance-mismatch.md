# Bug Report: List Page and Modal Compliance Score Mismatch

**Date:** 2026-01-10
**Severity:** High
**Status:** Fixed

## Summary

The Segmentation Event Progress list page showed different compliance scores than the client detail modal for clients with segment changes. For example:

- **GHA List Page:** 57/26 events, 100% compliance
- **GHA Modal:** 17/26 events, 44% compliance

The modal was correct; the list page was wrong.

## Root Cause

The `useAllClientsCompliance` hook (used by the list page) fetched data from the `event_compliance_summary` materialized view but **did not recalculate compliance** when a segment change was detected. It only set the `has_segment_changed` flag without filtering events to the correct assessment period.

The `useEventCompliance` hook (used by the modal) correctly:
1. Detected segment changes in the prior year
2. Filtered events to only count those from the change month onwards
3. Recalculated compliance based on the filtered events

**Example:** GHA had a segment change in September 2025 (Collaboration → Leverage):
- **Old list logic:** Counted all 57 events from Jan-Dec 2025 = 100%
- **Correct logic:** Only count events from Sep-Dec 2025 = 17 events = 44%

## Fix Applied

Updated `useAllClientsCompliance` in `src/hooks/useEventCompliance.ts` to recalculate compliance when a segment change is detected:

```typescript
// CRITICAL: If segment changed during the year, recalculate compliance
// based on events from the change month onwards only (assessment period)
if (deadlineInfo.hasChanged && deadlineInfo.changeDate) {
  const changeDate = new Date(deadlineInfo.changeDate)
  const changeMonth = changeDate.getMonth() + 1 // 1-12

  // Recalculate each event type's compliance based on filtered events
  eventCompliance = eventCompliance.map(ec => {
    // Filter events to only those from change month onwards
    const filteredEvents = (ec.events || []).filter((e) => {
      if (!e.event_date) return false
      const eventDate = new Date(e.event_date)
      return eventDate.getMonth() + 1 >= changeMonth
    })

    const actualCount = filteredEvents.length
    const compliancePercentage =
      ec.expected_count > 0 ? Math.round((actualCount / ec.expected_count) * 100) : 100

    // ... recalculate status
    return { ...ec, actual_count: actualCount, compliance_percentage, status, events: filteredEvents }
  })

  // Recalculate overall compliance
  compliantEventTypesCount = eventCompliance.filter(e => e.compliance_percentage >= 100).length
  totalEventTypesCount = eventCompliance.length
  overallComplianceScore = totalEventTypesCount > 0
    ? Math.round((compliantEventTypesCount / totalEventTypesCount) * 100)
    : 0
}
```

## Files Changed

1. `src/hooks/useEventCompliance.ts`
   - Added segment change recalculation logic to `useAllClientsCompliance`
   - Bumped cache version to `v8_list_segment_recalc`
   - Added console logging for recalculated scores

## Affected Clients

All clients with segment changes in 2025 now show corrected compliance scores:

| Client | Old Score | New Score |
|--------|-----------|-----------|
| GHA | 100% | 44% |
| Grampians Health | 100% | 44% |
| Epworth Healthcare | 70% | 30% |
| SA Health (Sunrise) | 91% | 9% |
| WA Health | 25% | 0% |
| SingHealth | 33% | 0% |
| And others... | | |

## Testing

1. Navigate to /compliance page
2. Click "Segmentation Event Detail" tab
3. Find GHA - should show 17/26 events, 44%
4. Click GHA to open modal - should show 17/26, 44%
5. Verify both values match ✅

## Business Logic Reference

**Assessment Period Rules:**
1. **No segment change:** Jan 1 - Dec 31 of assessment year
2. **Segment changed:** Change month - June 30 of following year

This fix ensures both the list page and modal apply the same business rules.

## Related

- `docs/guides/BUG-segment-reassessment-false-positive.md` - Related segment detection fix
- `docs/guides/BUG-segmentation-events-not-displaying.md` - Related events display fix
