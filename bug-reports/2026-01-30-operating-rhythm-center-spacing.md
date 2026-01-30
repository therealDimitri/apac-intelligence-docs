# Bug Report: Operating Rhythm Center Spacing

**Date:** 2026-01-30
**Status:** Fixed
**Commits:** 6983e780, d5ba5d25, 7f4866bf

## Issue

The space between the Client Activities ring and milestone events in both the Annual Orbit View (By Month) and CSE Orbit View (By CSE) was too tight, causing visual clutter and overlap concerns.

## Root Cause

- The center cards were sized too large, taking up significant space
- Activity/client ring radii were positioned too close to the milestone orbit

## Solution

Reduced the center card sizes and adjusted ring radii to create more breathing room in both views.

### Annual Orbit View (AnnualOrbitView.tsx)

| Element | Before | After |
|---------|--------|-------|
| Padding | `p-8` | `p-5` |
| Year text | `text-4xl` | `text-3xl` |
| Subtitle | `text-sm` | `text-xs` |
| Event count | `text-xs` | `text-[10px]` |
| Activity radius | `100` | `85` |

### CSE Orbit View (CSEOrbitView.tsx)

**Center Card Changes:**
| Element | Before | After |
|---------|--------|-------|
| Center card | `w-[140px] h-[140px]` | `w-[110px] h-[110px]` |
| CSE photo | `w-14 h-14` | `w-10 h-10` |
| Name text | `text-sm` | `text-xs` |
| Client/touches text | `text-xs` | `text-[10px]` |

**Layer Order Restructure (to mirror By Month view):**
| Layer | Before | After |
|-------|--------|-------|
| Activity bubbles | Outer (radius 180) | Inner (radius 85) |
| Client logos | Inner (radius 115) | Middle (radius 140) |
| Milestones | Middle (radius 145/175) | Outer (radius 195/215) |
| Quarter arcs | radius 160 | radius 112 |

## Files Modified

- `src/components/operating-rhythm/AnnualOrbitView.tsx`
- `src/components/operating-rhythm/CSEOrbitView.tsx`

## Testing

- Build passes with zero TypeScript errors
- Netlify deployments successful
- Visual spacing between inner elements and milestones improved in both views

## Related

- Part of Operating Rhythm UI improvements series
- Previous bug report: `2026-01-30-operating-rhythm-ui-bugs.md`
