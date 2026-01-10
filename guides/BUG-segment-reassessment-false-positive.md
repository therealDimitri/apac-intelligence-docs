# Bug Report: Segment Re-assessment Incorrectly Marked as Segment Change

**Date:** 2026-01-10
**Severity:** High
**Status:** Fixed

## Summary

Clients that were re-assessed in September 2025 but remained in the same segment (e.g., Albury Wodonga Health: Leverage → Leverage) were incorrectly marked as having a "segment change". This caused:

1. Modal showing "Segment Changed: Leverage → Leverage" badge (nonsensical)
2. Extended deadline incorrectly applied (June 30, 2026 instead of Dec 31, 2025)
3. Assessment period incorrectly set to Sep 2025 - Jun 2026
4. Modal showing different compliance data than list view (50% vs 100%)

## Root Cause

The `detectSegmentChange` function in `segment-deadline-utils.ts` and `useSegmentChange` hook only checked if there were **multiple records** in `client_segmentation` table during the year. It did NOT compare the actual segment (tier) names to verify a change actually occurred.

**Example**: Albury Wodonga Health had two records:
- 2025-01-01 → Leverage
- 2025-09-01 → Leverage (re-assessment, same segment)

The old code saw 2 records and assumed the segment changed, triggering extended deadline logic.

**Problem Code (before fix):**
```typescript
// Only checked record count, not actual segment values
if (effectiveFrom >= yearStart && effectiveFrom <= yearEnd) {
  hasChanged = true  // BUG: Didn't verify segments were different!
  changeDate = change.effective_from
  previousSegment = prevRecord.segmentation_tiers?.[0]?.tier_name
  break
}
```

## Fix Applied

Updated both `detectSegmentChange` and `useSegmentChange` to compare the actual segment tier names before marking a change:

```typescript
if (effectiveFrom >= yearStart && effectiveFrom <= yearEnd) {
  const prevTierName = prevRecord.segmentation_tiers?.[0]?.tier_name || null
  const currTierName = change.segmentation_tiers?.[0]?.tier_name || null

  // Only consider it a change if the segment ACTUALLY changed
  if (prevTierName && currTierName && prevTierName !== currTierName) {
    hasChanged = true
    changeDate = change.effective_from
    previousSegment = prevTierName
    break
  }
  // Re-assessments with same segment are ignored
}
```

## Files Changed

1. `src/lib/segment-deadline-utils.ts`
   - Updated `detectSegmentChange` function to compare tier names
   - Added logging for re-assessments vs actual changes

2. `src/hooks/useSegmentChange.ts`
   - Updated segment change detection loop to compare tier names

3. `src/hooks/useEventCompliance.ts`
   - Bumped cache version to `v6_segment_change_fix`

## Affected Clients

Based on `client_segmentation` data, these clients were re-assessed in September 2025 **without** changing segments:
- Albury Wodonga Health (Leverage → Leverage)
- Barwon Health Australia (Maintain → Maintain)
- Royal Victorian Eye and Ear Hospital (Maintain → Maintain)
- Western Health (Maintain → Maintain)
- Te Whatu Ora Waikato (Collaboration → Collaboration)
- Mount Alvernia Hospital (Leverage → Leverage)

These clients should now correctly show:
- Assessment period: Jan 2025 - Dec 2025
- Deadline: Dec 31, 2025
- No "Segment Changed" badge

## Clients with Actual Segment Changes

These clients DID change segments and should correctly show extended deadlines:
- Gippsland Health Alliance (GHA): Collaboration → Leverage
- Grampians Health: Collaboration → Leverage
- SingHealth: Nurture → Sleeping Giant
- WA Health: Nurture → Sleeping Giant
- SA Health (Sunrise): Sleeping Giant → Giant
- Department of Health - Victoria: Collaboration → Nurture
- And others (see FEATURE-compliance-modal-improvements.md)

## Testing

1. Open Albury Wodonga Health client detail page
2. Click compliance score to open Segmentation Event Progress modal
3. Verify:
   - No "Segment Changed" badge appears
   - Assessment period shows Jan 2025 - Dec 2025
   - Compliance score matches list view (100%)
   - Events show 13/13 completed

4. Open SingHealth client detail page
5. Verify:
   - "Segment Changed: Nurture → Sleeping Giant" badge appears
   - Assessment period shows Sep 2025 - Jun 2026
   - Deadline shows June 30, 2026

## Related

- `docs/guides/BUG-calendar-wrong-year-data.md`
- `docs/guides/FEATURE-compliance-modal-improvements.md`
