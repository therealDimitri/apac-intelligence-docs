# Bug Report: ChaSen Floating Button Overlapping Mobile Bottom Navigation

**Date:** 2026-01-25
**Status:** Fixed
**Severity:** Medium
**Component:** FloatingChaSenAI

## Problem Description

The ChaSen AI floating button (purple brain icon) was positioned at `bottom-4` (16px from bottom), which caused it to overlap with the mobile bottom navigation bar. This made the "More" menu button in the bottom nav inaccessible on mobile devices.

## Root Cause

The `FloatingChaSenAI` component used fixed positioning `bottom-4 right-4` without accounting for the mobile bottom navigation bar which is 64px tall (`h-16`) and positioned at `bottom-0`.

## Solution

Added responsive positioning to the FloatingChaSenAI component using the `useIsMobile` hook:

1. **Import mobile detection hook:**
   ```tsx
   import { useIsMobile } from '@/hooks/useMediaQuery'
   ```

2. **Add hook call in component:**
   ```tsx
   const isMobile = useIsMobile()
   ```

3. **Update bubble positioning:**
   - Desktop: `bottom-4` (16px from bottom)
   - Mobile: `bottom-20` (80px from bottom) - clears the 64px nav bar with margin

4. **Update suggestions panel positioning:**
   - Desktop: `bottom-20 right-4 w-96`
   - Mobile: `bottom-36 left-4 right-4` (full width, above bubble)

5. **Update full chat panel:**
   - Desktop: Fixed size `w-[560px] h-[640px]` positioned `bottom-4 right-4`
   - Mobile: Full screen `inset-0 bottom-16` (leaves space for nav bar)

6. **Update loading overlay:**
   - Desktop: `bottom-20 right-4 w-96`
   - Mobile: `bottom-36 left-4 right-4` (matches suggestions panel)

## Files Modified

- `src/components/FloatingChaSenAI.tsx`
  - Line 53: Added `useIsMobile` import
  - Line 155: Added `isMobile` hook call
  - Line 1546: Updated bubble className with conditional positioning
  - Line 1570: Updated suggestions panel className
  - Line 2104: Updated full chat panel className
  - Line 3179: Updated loading overlay className

## Testing

### Automated Tests (Playwright)
- Mobile viewport: 390x844 (iPhone 14 Pro)
- Verified ChaSen bubble position: `bottom=764px` (CSS `bottom: 80px`)
- Verified bottom nav position: `top=779px`
- Gap between bubble and nav: 15px
- No overlap detected

### Manual Verification
- ChaSen bubble visible and clickable on mobile
- Full chat panel takes full screen on mobile with nav bar visible
- All touch targets meet 44px minimum requirement

## Screenshots

### Before Fix
ChaSen bubble overlapping "More" button in bottom navigation.

### After Fix
ChaSen bubble positioned above bottom navigation with 15px gap.

## Commit

```
54523b2d Add mobile responsiveness to ChaSen AI floating button
```
