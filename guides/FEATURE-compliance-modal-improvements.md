# Feature: Segmentation Event Progress Modal Improvements

**Date:** 2026-01-10
**Type:** Enhancement
**Status:** Completed

## Summary

Improvements to the Segmentation Event Progress modal (formerly "Compliance Details") to make it reporting-period agnostic and add visibility for segment changes.

## Changes Made

### 1. Renamed Modal and Removed Year from Heading

**Problem:** The modal heading included the year (e.g., "2026 Compliance Details"), but clients have different reporting periods (calendar year, fiscal year Jul-Jun, etc.). Additionally, "Compliance Details" was unclear.

**Solution:**
- Renamed modal from "Compliance Details" to "Segmentation Event Progress"
- Removed year reference to be period-agnostic

**Files Changed:**
- `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx:1712`
- `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx:2076`

### 2. Added Segment Change Badge

**Problem:** Users had no visibility into which clients had segment changes mid-year, which affects compliance calculation periods and deadlines.

**Solution:** Added an amber badge that displays when a client's segment changed during the reporting period.

**Badge Features:**
- Shows "Segment Changed" with an arrow icon
- Displays previous → current segment transition (e.g., "Nurture → Sleeping Giant")
- Shows extended deadline date for clients with segment changes

**Business Rule:**
If a client's segment changed mid-year, their compliance deadline is extended to June 30 of the following year (instead of December 31 of the current year). This allows a full 12 months for compliance activities to be scheduled and addressed.

**Files Changed:**
- `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`
  - Added `ArrowRightLeft` icon import
  - Added segment change badge component (lines 1778-1796)
- `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`
  - Added `ArrowRightLeft` icon import
  - Added segment change badge component (lines 2142-2160)

## Clients with Segment Changes (Sep 2025)

Based on the APAC Client Segmentation Activity Register 2025.xlsx, these clients changed segments in September 2025:

| Client | Jan 2025 | Sep 2025 |
|--------|----------|----------|
| Gippsland Health Alliance (GHA) | Collaboration | Leverage |
| Grampians Health | Collaboration | Leverage |
| Guam Regional Medical City (GRMC) | Leverage | Maintain |
| NCS/MinDef Singapore | Maintain | Leverage |
| SA Health (Sunrise) | Sleeping Giant | Giant |
| Saint Luke's Medical Centre (SLMC) | Leverage | Maintain |
| Department of Health - Victoria | Collaboration | Nurture |
| WA Health | Nurture | Sleeping Giant |
| Epworth Healthcare | Leverage | Maintain |
| SA Health (iPro) | Nurture | Collaboration |
| SingHealth | Nurture | Sleeping Giant |

### Clients Re-assessed with No Change
| Client | Segment (unchanged) |
|--------|---------------------|
| Barwon Health Australia | Maintain |
| Royal Victorian Eye and Ear Hospital | Maintain |
| Western Health | Maintain |
| Te Whatu Ora Waikato | Collaboration |
| Mount Alvernia Hospital | Leverage |
| Albury Wodonga Health | Leverage |
| SA Health (iQemo) | Nurture |

## Assessment Period Logic

The `useEventCompliance` hook calculates compliance based on assessment periods:

### Clients WITHOUT Segment Change
- **Assessment period:** Jan 1 to Dec 31 of the assessment year
- **Example:** Jan 2025 - Dec 2025
- **Deadline:** Dec 31, 2025

### Clients WITH Segment Change (Sep 2025)
- **Assessment period:** Change month to June 30 of the following year
- **Example:** Sep 2025 - June 30, 2026
- **Deadline:** June 30, 2026
- This allows a full 12 months for compliance activities to be scheduled and addressed

This logic is implemented in:
- `src/hooks/useEventCompliance.ts` - Compliance calculation with assessment period logic
- `src/lib/segment-deadline-utils.ts` - Segment change detection and deadline calculation

## Visual Design

The segment change badge uses:
- **Background:** `bg-amber-100`
- **Border:** `border-amber-300`
- **Icon:** `ArrowRightLeft` in `text-amber-600`
- **Text:** `text-amber-800` for label, `text-amber-600` for transition, `text-amber-700` for deadline

## Progress Badge Logic

The progress status badge now considers whether the assessment period is still active:

### Status Logic
- **Meets Goals**: `overall_compliance_score >= 80%`
- **On Track**: Deadline NOT passed AND `score >= 50%`
- **At Risk**: Deadline NOT passed AND `score < 50%`
- **Missed**: Deadline HAS passed AND `score < 80%`

### Rationale
Clients with segment changes have until June 30, 2026 to complete their required events. Showing "Missed" before the deadline is misleading - they should show "On Track" or "At Risk" depending on their progress.

## Calendar Tile Display

The calendar now shows the true assessment period months:

### Clients WITHOUT Segment Change
- Shows: Jan '25 - Dec '25 (12 tiles)
- Heading: "Jan - Dec 2025 Assessment Period"

### Clients WITH Segment Change (Sep 2025)
- Shows: Sep '25 - Jun '26 (10 tiles)
- Heading: "Sep 2025 - Jun 2026 Assessment Period"
- Badge shows: "Deadline: Jun 30, 2026"

## Testing

1. Verify modal heading shows "Segmentation Event Progress" (no year reference)
2. Open compliance modal for SingHealth - should show segment change badge
3. Badge should display "Nurture → Sleeping Giant" with extended deadline (June 30, 2026)
4. Verify badge does NOT appear for clients without segment changes
5. **Calendar tiles for SingHealth**: Should show Sep '25, Oct '25, Nov '25, Dec '25, Jan '26, Feb '26, Mar '26, Apr '26, May '26, Jun '26
6. **Calendar tiles for unchanged clients**: Should show Jan '25 through Dec '25
7. **Progress badge**: Clients with time remaining should show "On Track" or "At Risk", NOT "Missed"
8. Check console logs for assessment period calculations:
   - Unchanged: "assessment period: Jan 2025 - Dec 2025"
   - Changed: "assessment period: 2025-09-01 to June 30, 2026"

## Files Changed

- `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`
  - Updated `monthlyComplianceStatus` to calculate true assessment periods
  - Added `isDeadlinePassed`, `assessmentPeriod` to return object
  - Updated progress badge logic to consider deadline status
  - Updated calendar heading to show assessment period
  - Updated calendar tile generation to show correct months

- `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`
  - Same changes as LeftColumn.tsx

## Related

- `src/hooks/useEventCompliance.ts` - Compliance calculation logic
- `src/hooks/useSegmentChange.ts` - Segment change detection hook
- `src/lib/segment-deadline-utils.ts` - Deadline extension utilities
