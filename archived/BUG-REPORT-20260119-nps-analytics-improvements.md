# Bug Report: NPS Analytics UI Improvements

**Date:** 2026-01-19
**Status:** Fixed
**Severity:** Low (UX improvements)
**Component:** NPS Analytics Page

## Summary

Multiple UI/UX improvements to the NPS Analytics page including segment filtering, client logo badges, and AI insights styling.

## Issues Fixed

### 1. Segment Filter Not Applied to Top Topics Section

**Symptom:** When filtering by segment (e.g., "Giant"), the "Client Scores & Trends" section filtered correctly, but "Top Topics by Client Segment" showed all segments.

**Fix:** Filter `segmentTopics` and `clients` props by `selectedSegment` before passing to `TopTopicsBySegment` component.

**File:** `src/app/(dashboard)/nps/page.tsx`

```typescript
<TopTopicsBySegment
  segmentTopics={
    selectedSegment
      ? segmentTopics.filter(st => st.segment === selectedSegment)
      : segmentTopics
  }
  clients={
    selectedSegment
      ? clients.filter(c => c.segment === selectedSegment)
      : clients
  }
/>
```

### 2. Product Suffix Badges Showing for Non-Sibling Clients

**Symptom:** Badges like "(SLMC)" and "(GRMC)" appeared for clients that were not part of a parent-child relationship, just abbreviations in their names.

**Fix:** Only show badges when the parent has multiple children in the displayed list.

**File:** `src/components/TopTopicsBySegment.tsx`

```typescript
// Find parent names that have multiple children
const parentCounts = new Map<string, number>()
segmentClients.forEach(c => {
  const parent = getParentName(c.client_name)
  if (parent) {
    parentCounts.set(parent, (parentCounts.get(parent) || 0) + 1)
  }
})
// Only show badges for parents with multiple children
const parentsWithMultipleChildren = new Set(
  [...parentCounts.entries()].filter(([, count]) => count > 1).map(([parent]) => parent)
)
```

### 3. AI Insights Headings Not Visually Bold

**Symptom:** "Key Factors:" and "Recommended Actions:" headings appeared as regular weight text despite having `font-bold` class.

**Root Cause:** At `text-xs` (12px), the bold weight difference was not visually distinguishable.

**Fix:** Increased size and contrast:
- Changed from `text-xs font-bold text-gray-700` to `text-sm font-bold text-gray-900`

**File:** `src/app/(dashboard)/nps/page.tsx`

### 4. Confidence Badges Not Colour-Coded

**Symptom:** All confidence badges showed as plain grey text regardless of level.

**Fix:** Added colour coding:
- High confidence: green (`bg-green-100 text-green-700`)
- Medium confidence: amber (`bg-amber-100 text-amber-700`)
- Low confidence: grey (`bg-gray-100 text-gray-600`)

**File:** `src/app/(dashboard)/nps/page.tsx`

## Files Modified

| File | Changes |
|------|---------|
| `src/app/(dashboard)/nps/page.tsx` | Segment filtering, confidence badges, heading styling |
| `src/components/TopTopicsBySegment.tsx` | Smart badge logic for sibling clients |

## Verification

1. Select "Giant" segment filter → Only Giant segment appears in Top Topics
2. View Maintain segment → No badges on SLMC, GRMC (single clients)
3. View Giant segment with SA Health variants → Badges show (iPro), (Sunrise), (iQemo)
4. Expand AI insights → "Key Factors:" and "Recommended Actions:" are bold
5. Check confidence badges → Colour-coded by level

## Related Commits

- `Fix NPS segment filter not applying to Top Topics section`
- `Improve NPS AI Insights styling`
- `Fix product suffix badges showing for non-sibling clients`
- `Make Key Factors and Recommended Actions headings more prominent`
