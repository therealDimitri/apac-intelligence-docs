# Bug Report: Mobile Navigation Responsiveness Issues

**Date:** 2 February 2026
**Status:** Fixed
**Commit:** 8388d100

## Summary

Several issues affected mobile navigation usability:

1. **Missing pages in mobile drawer** - Operating Rhythm and Sales Hub pages were not accessible from mobile navigation
2. **Floating buttons overlapping mobile nav** - Help widget, ComplianceAlerts, and BulkActionsTable floated at `bottom-6` which overlapped the 64px mobile bottom navigation bar

## Root Cause

1. `MobileDrawer.tsx` had outdated navigation structure that didn't match the desktop sidebar
2. Floating elements used static `bottom-6` positioning without accounting for the mobile bottom nav height (64px / `h-16`)

## Fix Applied

### 1. MobileDrawer.tsx - Updated navigation structure

Added missing pages and reorganised groups to match desktop:
- **Command Centre**: BU Performance, Operating Rhythm (was missing)
- **Clients**: Portfolio Health, Segmentation Progress
- **Action Hub**: Meetings, Actions & Tasks
- **Analytics**: Team Performance, NPS Analytics, Support Health, Working Capital
- **Resources**: Sales Hub (was missing), Guides & Templates

Removed duplicate standalone "Command Centre" link.

### 2. Floating elements - Responsive bottom positioning

Changed from static `bottom-6` to responsive `bottom-20 md:bottom-6`:
- `ContextualHelpWidget.tsx` line 304
- `ComplianceAlerts.tsx` line 328
- `BulkActionsTable.tsx` line 591

This moves floating elements 80px from bottom on mobile (clearing the 64px nav) while keeping them at 24px on desktop.

### Already Handled

- `FloatingChaSenAI.tsx` already uses `isMobile` check to set `bottom-20` on mobile
- `KeyboardShortcutsButton` uses `hidden md:flex` to hide on mobile
- `FloatingPageComments.tsx` uses `bottom-24` which already clears the nav

## Files Changed

- `src/components/layout/MobileDrawer.tsx`
- `src/components/guides/ContextualHelpWidget.tsx`
- `src/components/compliance/ComplianceAlerts.tsx`
- `src/components/compliance/BulkActionsTable.tsx`

## Testing Notes

- Mobile bottom nav is 64px (`h-16` = 4rem)
- `bottom-20` = 5rem = 80px, providing 16px clearance
- Build passes with zero TypeScript errors
- Netlify deployment successful
