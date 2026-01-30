# Bug Report: Operating Rhythm Center Spacing

**Date:** 2026-01-30
**Status:** Fixed
**Commit:** 6983e780

## Issue

The space between the Client Activities ring and milestone events in the Annual Orbit View was too tight, causing visual clutter and overlap concerns.

## Root Cause

- The center card was sized with `p-8` padding and `text-4xl` year text, taking up significant space
- The activity ring radius was set to `100`, positioning it close to the milestone orbit

## Solution

Reduced the center card size and adjusted the activity ring radius to create more breathing room:

### Center Card Changes
| Element | Before | After |
|---------|--------|-------|
| Padding | `p-8` | `p-5` |
| Year text | `text-4xl` | `text-3xl` |
| Subtitle | `text-sm` | `text-xs` |
| Event count | `text-xs` | `text-[10px]` |

### Activity Ring Changes
| Element | Before | After |
|---------|--------|-------|
| Activity radius | `100` | `85` |

## Files Modified

- `src/components/operating-rhythm/AnnualOrbitView.tsx`

## Testing

- Build passes with zero TypeScript errors
- Netlify deployment successful
- Visual spacing between Client Activities and milestones improved

## Related

- Part of Operating Rhythm UI improvements series
- Previous bug report: `2026-01-30-operating-rhythm-ui-bugs.md`
