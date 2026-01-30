# Bug Report: Operating Rhythm UI Issues

**Date:** 30 January 2026
**Reported By:** User
**Fixed By:** Claude Opus 4.5
**Commits:** 7123e75d, 2b90b67b, dfc5be13, 26d590a6, 85ed453b, 21f30226, c626fca2, 1c21c250, e566af75

## Summary

24 bugs were reported and fixed across the Operating Rhythm page affecting responsiveness, styling, data display, interactivity, missing events, and CSE orbit enhancements.

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

## Bug 11: Activity Names Truncated in Panel

**Issue:** Activity names in "Annual Activities" panel showing abbreviated names ("EVP", "On-Site", "Insight", "SLA Review") instead of full names.

**Root Cause:** The panel was using `activity.shortName` instead of `activity.name`.

**Fix:** Changed to use `activity.name` with truncation and title tooltip for overflow:
- Annual Activities grid: "EVP" → "EVP Engagement"
- Activities Due section: "On-Site" → "On-Site Attendance"

**Files Modified:**
- `src/components/operating-rhythm/CSEWorkloadPanel.tsx`

---

## Bug 12: Client Requirements Panel Logo Cropping

**Issue:** Client logos in the "Client Requirements" (By Client) panel being cropped, especially Barwon Health and RVEEH which have text below icons.

**Root Cause:** Using `object-cover rounded-full` which crops rectangular logos to fill a circle.

**Fix:**
- Changed from `<img className="object-cover rounded-full">` to a container div with padding
- Increased container size from `w-10 h-10` to `w-12 h-12`
- Added padding (`p-1.5`) and white background
- Changed image to `object-contain` to fit entire logo

```tsx
// BEFORE (cropping):
<img className="w-10 h-10 rounded-full object-cover" />

// AFTER (full logo):
<div className="w-12 h-12 rounded-full border bg-white flex items-center justify-center p-1.5">
  <img className="w-full h-full object-contain" />
</div>
```

**Files Modified:**
- `src/components/operating-rhythm/CSEWorkloadPanel.tsx`

---

## Bug 13: Orbit Client Logos Still Clipped (Follow-up)

**Issue:** Despite earlier fix, Barwon Health logo in orbit view was still showing text cutoff due to circular clipPath.

**Root Cause:** The SVG `<clipPath>` element was clipping logos to a circle shape, cutting off rectangular logos with text components.

**Fix:**
- Removed the `<defs>` block containing circular clipPaths entirely
- Changed logo container from clipped image to white background circle with coloured tier border
- Increased logo image area from 32×32 to 36×36
- Logos now render with `preserveAspectRatio="xMidYMid meet"` without clipping

**Files Modified:**
- `src/components/operating-rhythm/CSEOrbitView.tsx`

---

## Bug 14: Client Logos Overflowing Circle Containers

**Issue:** After removing clipPath in Bug 13 fix, client logos (WA Health, Barwon Health) overflowed beyond their circular container boundaries, appearing unprofessional.

**Root Cause:** SVG `<image>` element with `preserveAspectRatio="xMidYMid meet"` fits the image within its viewport but does NOT clip overflow - the image can extend beyond specified dimensions.

**Fix:**
- Re-added `<defs>` block with circular clipPath definitions for each client logo
- Wrapped `<image>` elements in `<g clipPath="url(#client-clip-N)">` groups
- ClipPath radius set to 18px to properly constrain logos within the 24px bubble

```tsx
// Added clipPath definitions:
<defs>
  {clientPositions.map(({ client }, idx) => (
    <clipPath key={`clip-${idx}`} id={`client-clip-${idx}`}>
      <circle cx={0} cy={0} r={18} />
    </clipPath>
  ))}
</defs>

// Applied to images:
<g clipPath={`url(#client-clip-${idx})`}>
  <image ... />
</g>
```

**Files Modified:**
- `src/components/operating-rhythm/CSEOrbitView.tsx`

---

## Bug 15: Centre CSE Card Not Geometrically Centred

**Issue:** The centre CSE profile card appeared positioned too high in the orbit, not at the geometric centre.

**Root Cause:** The card used `rounded-full` with `p-6` padding, which creates a non-square element because content height > width. CSS `rounded-full` on a non-square element creates an oval, and the content-based height caused visual misalignment.

**Fix:**
- Changed from content-based sizing to fixed dimensions: `w-[140px] h-[140px]`
- Added `flex flex-col items-center justify-center` for true centring
- Reduced internal spacing (`mb-2` → `mb-1`, removed `mt-0.5`)
- Reduced photo/avatar size (`w-16 h-16` → `w-14 h-14`)

```tsx
// BEFORE (oval, not centred):
className="text-center z-10 bg-white rounded-full p-6 ..."

// AFTER (square, truly centred):
className="w-[140px] h-[140px] flex flex-col items-center justify-center ..."
```

**Files Modified:**
- `src/components/operating-rhythm/CSEOrbitView.tsx`

---

## Bug 16: Current Month Indicator Overlapped by Activity Badge

**Issue:** The current month blue indicator dot was being overlapped/hidden by the activity bubble (badge showing activity count).

**Root Cause:**
1. No separate indicator dot existed - only the blue text colour on month label
2. Activity bubbles rendered at radius 180, near month labels at radius 210, causing visual collision

**Fix:**
- Added new current month indicator dot at radius 230 (outside month labels)
- Renders LAST in the SVG for proper z-order (appears on top)
- Includes outer glow (radius 8, 20% opacity) and inner dot (radius 5 with white stroke)

```tsx
{/* Current month indicator - rendered last for z-order */}
{Object.entries(MONTH_POSITIONS).map(([month, { angle }]) => {
  if (parseInt(month) !== currentMonth) return null
  const pos = getOrbitPosition(angle, 230)
  return (
    <g key={`current-indicator-${month}`}>
      <circle cx={pos.x} cy={pos.y} r={8} fill="#3b82f6" opacity={0.2} />
      <circle cx={pos.x} cy={pos.y} r={5} fill="#3b82f6" stroke="white" strokeWidth="2" />
    </g>
  )
})}
```

**Files Modified:**
- `src/components/operating-rhythm/CSEOrbitView.tsx`

---

## Bug 18: Missing Events on Orbit View

**Issue:** 9 events were not appearing on the orbit visualisation, including:
- CS & MarCom Audit Q4 (Jan 19-23)
- Q1 Account Plan Update (Mar 2-6)
- CS & MarCom Audit Q1 (Apr 13-17)
- NPS Q2 Analysis Workshop (Apr 27 - May 30)
- Segmentation Model Review (May 18 - Jun 12)
- CS & MarCom Audit Q2 (Jul 13-17)
- Q4 Account Plan Update (Oct 8)
- NPS Q4 Analysis Workshop (Oct 26-30)
- NPS Q4 Client Letters (Nov 23-25)

**Root Cause:** The orbit view only renders events with `isMilestone: true` flag. These 9 events were in the data file but missing the milestone flag.

```typescript
// AnnualOrbitView.tsx line 506:
{milestones.map((event, idx) => {
  // Only renders getMilestoneEvents() - events with isMilestone: true
```

**Fix:** Added `isMilestone: true` to all 9 missing events in `data.ts`.

**Files Modified:**
- `src/components/operating-rhythm/data.ts`

---

## Bug 17: Modal Opens Unnecessarily in Orbit View

**Issue:** Clicking an event in Orbit view opened a modal displaying event details, even though the same information was already visible in the right-side panel.

**Root Cause:** The `AnimatePresence` block that renders `EventDetailModal` checked only `selectedEvent` without considering the current view mode.

**Fix:** Added `viewMode !== 'orbit'` condition to only show modal in Timeline and List views.

```tsx
// BEFORE (modal shows in all views):
{selectedEvent && (
  <EventDetailModal ... />
)}

// AFTER (modal only in Timeline/List views):
{selectedEvent && viewMode !== 'orbit' && (
  <EventDetailModal ... />
)}
```

**Files Modified:**
- `src/app/(dashboard)/operating-rhythm/page.tsx`

---

## Bug 19: Missing Q3 CS & MarCom Audit Event

**Issue:** The Q3 CS & MarCom Audit & Review event for October was missing from the Operating Rhythm calendar.

**Root Cause:** Event was never added to the data.ts file.

**Fix:**
- Added new event `cs-marcom-audit-q3` for October 5-9
- Updated all audit shortTitles from "CS Audit" to "CS & MarCom" for consistency

**Event Details:**
- **Dates:** October 5-9, 2026
- **Participants:** EVP, VPs, AVPs, CSEs, CAMs, Marketing Lead, SVP CS + Marketing (Global), VP CS (Global), VP Marketing (Global)
- **Objective:** Prepare and review Q3 CS & Marketing learnings and progress
- **Deliverables:** Q3 CS performance summary, Marketing campaign effectiveness analysis, YTD vs plan variance analysis, Q4 priorities and year-end preparation

**Files Modified:**
- `src/components/operating-rhythm/data.ts`

---

## Bug 20: Client Letters Cluttering Orbit

**Issue:** "Client Letters" event was cluttering the orbit and not essential for the overview.

**Fix:** Set `isMilestone: false` for the `nps-q4-client-letters` event to remove it from the orbit display while keeping it in Timeline/List views.

**Files Modified:**
- `src/components/operating-rhythm/data.ts`

---

## Bug 21: Segmentation Review Label Overflow

**Issue:** "Segmentation Review" label was bleeding outside its container boundary on the orbit.

**Fix:** Renamed shortTitle from "Segmentation Review" to "Segment Review" to fit within container.

**Files Modified:**
- `src/components/operating-rhythm/data.ts`

---

## Bug 22: Event Labels Overlapping

**Issue:** Events in the same month were overlapping due to insufficient spread angle.

**Fix:** Increased spread angle from 15 to 18 degrees in `getOrbitPosition` function.

**Files Modified:**
- `src/components/operating-rhythm/AnnualOrbitView.tsx`

---

## Bug 23: Legend Shows "Planning" Instead of "Account Planning"

**Issue:** The category legend showed "Planning" which was not specific enough.

**Fix:** Changed label from "Planning" to "Account Planning" in `CATEGORY_CONFIG`.

**Files Modified:**
- `src/components/operating-rhythm/types.ts`

---

## Bug 24: CSE Orbits Missing Key OR Events

**Issue:** CSE orbit views did not show key Operating Rhythm milestones that CSEs need to be aware of.

**Fix:** Added 6 key OR events to all CSE orbits:
- Q1 Plan Update (March)
- NPS Q2 Survey (April)
- 2H Plan Review (June)
- NPS Q4 Survey (October)
- Q4 Plan Update (October)
- Year-End Review (December)

Milestones appear as small category-colored dots with labels on the inner ring.

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
10. ✅ Activity names show full names in Annual Activities panel
11. ✅ Client Requirements panel logos display fully without cropping
12. ✅ Orbit client logos show complete with tier-coloured borders
13. ✅ Client logos properly clipped within circular containers (no overflow)
14. ✅ Centre CSE card is geometrically centred (140×140px fixed square)
15. ✅ Current month indicator dot renders above activity badges (proper z-order)
16. ✅ Event clicks in Orbit view do NOT open modal (details in side panel)
17. ✅ Event clicks in Timeline view open modal correctly
18. ✅ Event clicks in List view open modal correctly
19. ✅ Q3 CS & MarCom Audit event appears in October (Oct 5-9)
20. ✅ Total events now 22 (was 21)
21. ✅ Client Letters removed from orbit (still in Timeline/List)
22. ✅ "Segment Review" fits within container boundary
23. ✅ Event labels no longer overlap (18° spread)
24. ✅ Legend shows "Account Planning" instead of "Planning"
25. ✅ CSE orbits show 6 key OR milestones with category-coloured dots

## Deployment

- **Status:** Deployed to production (commit e566af75)
- **URL:** https://apac-cs-dashboards.com/operating-rhythm
