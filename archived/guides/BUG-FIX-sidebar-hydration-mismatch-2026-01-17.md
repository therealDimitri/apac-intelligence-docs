# Bug Fix: Sidebar Hydration Mismatch Error

**Date:** 2026-01-17
**Status:** Resolved
**Component:** `src/components/layout/sidebar.tsx`

## Problem

The sidebar component was causing a React hydration mismatch error:

```
Hydration failed because the server rendered HTML didn't match the client.
```

The error occurred because:
1. The `isActive` state for navigation items depended on `pathname` from `usePathname()`
2. During server-side rendering, `pathname` timing could differ slightly from client hydration
3. This caused different class names to be applied, resulting in tree structure mismatches

## Root Cause

The sidebar navigation items calculated `isActive` based on `pathname` comparison:
```javascript
const isActive = pathname === item.href
```

This could produce different results between server and client renders, causing:
- Different CSS classes to be applied
- React to fail reconciliation between server HTML and client virtual DOM

## Solution

Added a hydration-safe `isMounted` state pattern:

```javascript
const [isMounted, setIsMounted] = useState(false)
useEffect(() => {
  // eslint-disable-next-line react-hooks/set-state-in-effect
  setIsMounted(true)
}, [])

// Use in isActive calculations:
const isActive = isMounted && pathname === item.href
```

This ensures:
1. Server always renders with `isActive = false` (consistent)
2. Client hydrates with `isActive = false` (matches server)
3. After mount, `isMounted` becomes `true` and active states update

## Files Modified

| File | Changes |
|------|---------|
| `src/components/layout/sidebar.tsx` | Added `isMounted` state and updated all `isActive` calculations |

## Changes Made

1. **Added `isMounted` state** (lines 97-102):
   - Initialises as `false`
   - Set to `true` in `useEffect` after mount

2. **Updated standalone items** (line 269):
   ```javascript
   const isActive = isMounted && pathname === item.href
   ```

3. **Updated `isGroupActive` function** (line 144):
   ```javascript
   if (!isMounted) return false
   ```

4. **Updated child navigation items** (lines 345-349):
   ```javascript
   const isActive = isMounted && (hasChildRoutes ? ... : ...)
   ```

## Verification

1. Build passes with zero TypeScript errors
2. No hydration errors in browser console
3. Navigation highlighting works correctly after mount

## Related

- This pattern is commonly used for hydration-safe client-side state
- The ESLint rule `react-hooks/set-state-in-effect` is disabled for this specific case as it's a valid hydration pattern
