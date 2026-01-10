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

Based on database analysis, these clients have segment records starting September 2025:

| Client | Previous Segment | Current Segment | Actual Change? |
|--------|-----------------|-----------------|----------------|
| SingHealth | Nurture | Sleeping Giant | ✅ Yes |
| Epworth Healthcare | Leverage | Maintain | ✅ Yes |
| SA Health (iPro) | Nurture | Collaboration | ✅ Yes |
| RVEEH | Maintain | Maintain | No (re-assigned) |
| Western Health | Maintain | Maintain | No (re-assigned) |
| Te Whatu Ora Waikato | Collaboration | Collaboration | No (re-assigned) |
| Mount Alvernia Hospital | Leverage | Leverage | No (re-assigned) |
| Albury Wodonga Health | Leverage | Leverage | No (re-assigned) |

## Progress Calculation Logic

The `useEventCompliance` hook already accounts for segment changes:

1. **No segment change:** Calculates from Jan 1 to Dec 31 of prior year
2. **Segment changed:** Calculates from change month in prior year to June 30 of current year

This logic is implemented in `src/hooks/useEventCompliance.ts` (lines 147-413).

## Visual Design

The segment change badge uses:
- **Background:** `bg-amber-100`
- **Border:** `border-amber-300`
- **Icon:** `ArrowRightLeft` in `text-amber-600`
- **Text:** `text-amber-800` for label, `text-amber-600` for transition, `text-amber-700` for deadline

## Testing

1. Verify modal heading shows "Compliance Details" (no year)
2. Open compliance modal for SingHealth - should show segment change badge
3. Badge should display "Nurture → Sleeping Giant" with extended deadline
4. Verify badge does NOT appear for clients without segment changes

## Related

- `src/hooks/useEventCompliance.ts` - Compliance calculation logic
- `src/hooks/useSegmentChange.ts` - Segment change detection hook
- `src/lib/segment-deadline-utils.ts` - Deadline extension utilities
