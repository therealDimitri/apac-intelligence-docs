# Bug Report: Comments Floating Modal Hidden Behind ChaSen Icon

**Date:** 2026-01-12
**Severity:** Medium (UX issue)
**Status:** Resolved

## Summary
The FloatingPageComments button was being hidden behind the FloatingChaSenAI icon because both were positioned in the bottom-right corner with the comments modal having a lower z-index.

## Root Cause
- **FloatingPageComments**: `z-40`, `bottom-6 right-6`
- **FloatingChaSenAI**: `z-[9999]`, `bottom-4 right-4`

The ChaSen icon had z-index 9999 while comments had only 40, causing the overlap issue.

## Solution
1. Increased FloatingPageComments z-index to `z-[9998]` (just below ChaSen)
2. Moved comments button higher to `bottom-24` to stack above ChaSen visually

## Changes Made

### FloatingPageComments.tsx
```typescript
// Before
className="fixed bottom-6 right-6 z-40"

// After
className="fixed bottom-24 right-6 z-[9998]"
```

## Visual Result
```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│                                     │
│                         [Comments]  │  ← bottom-24
│                         [ChaSen]    │  ← bottom-4
└─────────────────────────────────────┘
```

## Files Modified
- `src/components/comments/FloatingPageComments.tsx`

## Testing Performed
- [x] Build passes
- [x] Comments button visible above ChaSen icon
- [x] Both buttons clickable
- [x] Sheet panel opens correctly
