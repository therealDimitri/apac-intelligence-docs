# Bug Report: Operating Rhythm UI Issues

**Date:** 30 January 2026
**Reported By:** User
**Fixed By:** Claude Opus 4.5
**Commits:** 7123e75d, 2b90b67b

## Summary

10 UI bugs were reported and fixed across the Operating Rhythm page affecting responsiveness, styling, data display, and interactivity.

---

## Bug 1: Responsive Layout Issues on 16"/14" Laptops

**Issue:** Orbit visualisation not resizing correctly on laptop displays, causing layout overflow.

**Root Cause:** Fixed `max-w-2xl` constraint limiting responsive scaling.

**Fix:** Changed to percentage-based widths (`lg:w-[55%] xl:w-[60%]`) in both `AnnualOrbitView.tsx` and `CSEOrbitView.tsx`.

**Files Modified:**
- `src/components/operating-rhythm/AnnualOrbitView.tsx`
- `src/components/operating-rhythm/CSEOrbitView.tsx`

---

## Bug 2: By CSE View Centering and Styling Issues

**Issue:**
1. Centre CSE graphic not centred properly
2. Client logos partially cut off
3. Month circles missing white border ring (inconsistent with By Month view)

**Root Cause:** Insufficient sizing and missing stroke styling on month bubbles.

**Fix:**
- Added `stroke="white"` and `strokeWidth="2"` to activity bubble circles
- Increased `clientRingRadius` from 120 to 130
- Increased `bubbleRadius` from 22 to 24
- Increased client logo dimensions (34→38)

**Files Modified:**
- `src/components/operating-rhythm/CSEOrbitView.tsx`

---

## Bug 3: Truncated Segmentation Activity Names

**Issue:** Activity names showing "On-Site" instead of full "On-Site Attendance".

**Root Cause:** The `name` field in segment-activities.ts was set to "CE On-Site Visit" instead of matching the expected terminology.

**Fix:** Changed activity name from `'CE On-Site Visit'` to `'On-Site Attendance'`.

**Files Modified:**
- `src/components/operating-rhythm/segment-activities.ts`

---

## Bug 4: WA Health and Western Health Duplicate Short Codes

**Issue:** Both "WA Health" and "Western Health" clients generated "WH" as their short code.

**Root Cause:** The `generateShortName` function takes first letters of each word, causing collision.

**Fix:** Added special case handling for "WA Health" to return "WAH" explicitly.

```typescript
const specialCases: Record<string, string> = {
  'WA Health': 'WAH',
}
```

**Files Modified:**
- `src/app/api/clients/segments/route.ts`

---

## Bug 5: By Client View Logo Cutoff

**Issue:** Client logos in the CSEWorkloadPanel "By Client" view were being cut off on the right side.

**Root Cause:** Insufficient avatar size and missing `flex-shrink-0` causing logos to compress.

**Fix:**
- Increased avatar size from `w-8 h-8` to `w-10 h-10`
- Added `flex-shrink-0` class
- Increased gap from `gap-2` to `gap-3`

**Files Modified:**
- `src/components/operating-rhythm/CSEWorkloadPanel.tsx`

---

## Bug 6: Timeline/List View Card Clicks Non-Functional

**Issue:** Clicking event cards in Timeline or List views did nothing - no detail view appeared.

**Root Cause:** The `selectedEvent` state was being set via `setSelectedEvent` but the variable was prefixed with underscore (`_selectedEvent`) indicating intentionally unused, and no component rendered the selected event.

**Fix:**
1. Removed underscore prefix from `_selectedEvent` → `selectedEvent`
2. Added `AnimatePresence` and `EventDetailModal` component
3. Modal displays full event details (category, date, participants, objective, deliverables)

**Files Modified:**
- `src/app/(dashboard)/operating-rhythm/page.tsx`

---

## Bug 7: CE Activity View Orbit Too Small

**Issue:** The mini orbit showing client completion status for activities was too small to be easily readable.

**Root Cause:** Conservative sizing values in the `ClientMiniOrbit` component.

**Fix:**
- Increased orbit radius from 85 to 110
- Increased centre position from (120, 100) to (140, 120)
- Changed viewBox from "0 0 240 200" to "0 0 280 240"
- Increased min-h from 220px to 280px
- Increased max-w from 280px to 340px
- Increased centre label radius from 30 to 36
- Increased client bubble radius (14/18 → 18/22)
- Increased logo image size from 22×22 to 28×28

**Files Modified:**
- `src/components/operating-rhythm/AnnualOrbitView.tsx`

---

## Bug 8: Verify 7 CE On-Site Visits Data Source

**Issue:** User questioned where the "7 CE On-Site Visits completed for January" data comes from.

**Finding:** The completion data is **mock/demo data**, not from a real database.

**Evidence from code (AnnualOrbitView.tsx lines 125-126):**
```typescript
// Generate mock completion data for demonstration
// In production, this would come from the activityCompletions prop (from database)
```

The `seededRandom` function generates deterministic pseudo-random completions:
- Past months: 70-100% completion rate
- Current month: 20-50% completion rate
- Future months: 0%

This ensures consistent rendering between server and client (hydration safe).

**Files Modified:** None (documentation only)

---

## Bug 9: CSE View Client Logo Cropping

**Issue:** Client logos (particularly RVEEH and Barwon Health) were being cropped/cut off in the By CSE orbit view.

**Root Cause:** The SVG `preserveAspectRatio` attribute was set to `"xMidYMid slice"` which crops rectangular images to fill the circular clip area, cutting off parts of the logo.

**Fix:**
- Changed `preserveAspectRatio` from `"xMidYMid slice"` to `"xMidYMid meet"` - this fits the entire logo within the circular boundary without cropping
- Reduced clip path radius from 20 to 16
- Reduced image dimensions from 38×38 to 32×32
- Reduced white background circle from r=20 to r=18

```typescript
// BEFORE (cropping):
preserveAspectRatio="xMidYMid slice"

// AFTER (fit entire logo):
preserveAspectRatio="xMidYMid meet"
```

**Files Modified:**
- `src/components/operating-rhythm/CSEOrbitView.tsx`

---

## Bug 10: CSE View January Blue Dot Clipped

**Issue:** The current month blue indicator dot (January) was being clipped/cut off at the top of the By CSE orbit view.

**Root Cause:** The container `<div>` with `aspect-square` class has implicit `overflow: hidden`, and the SVG element also defaults to hidden overflow, causing elements at the edge of the viewBox to be clipped.

**Fix:**
- Added `overflow-visible` class to the aspect-square container div
- Added `overflow-visible` class to the SVG element

```tsx
// BEFORE:
<div className="aspect-square">
  <svg className="w-full h-full" viewBox="-250 -250 500 500">

// AFTER:
<div className="aspect-square overflow-visible">
  <svg className="w-full h-full overflow-visible" viewBox="-250 -250 500 500">
```

**Files Modified:**
- `src/components/operating-rhythm/CSEOrbitView.tsx`

---

## Testing Performed

1. ✅ Build passes with `npm run build`
2. ✅ Timeline view event click opens modal
3. ✅ List view event click opens modal
4. ✅ Modal displays all event details correctly
5. ✅ Modal close button works
6. ✅ Click outside modal closes it
7. ✅ Netlify deployment successful
8. ✅ CSE view client logos display fully (Barwon Health, RVEEH, Epworth, Western Health, WA Health)
9. ✅ January blue indicator dot visible at top of CSE orbit view

## Deployment

- **Status:** Deployed to production (commit 2b90b67b)
- **URL:** https://apac-cs-dashboards.com/operating-rhythm
