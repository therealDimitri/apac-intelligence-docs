# Bug Report: Sidebar Navigation Active State Hydration Mismatch

**Date:** 17 January 2026
**Status:** Fixed
**Severity:** Medium (Recoverable Error)
**Component:** Layout > Sidebar Navigation

---

## Problem Description

React hydration error in the Sidebar component when rendering navigation item active states. The server rendered active styles while the client rendered inactive styles, causing a hydration mismatch.

### Error Message

```
Hydration failed because the server rendered HTML didn't match the client.

At: div > div > nav > div > a > svg

Server: className="mr-3 flex-shrink-0 h-5 w-5 text-white"
Client: className="mr-3 flex-shrink-0 h-5 w-5 text-white/70 group-hover:text-white"
```

The error occurred at `sidebar.tsx:274` in the standalone navigation items section.

---

## Root Cause Analysis

The `usePathname()` hook can return different values during server-side rendering vs client-side hydration. When the component checked `pathname === item.href` directly, the server might evaluate this as true (active) while the client initially evaluates it as false (inactive), causing a hydration mismatch.

### Affected Code (Before Fix)

```tsx
// Direct pathname comparison - causes hydration mismatch
const isActive = pathname === item.href
```

---

## Solution Implemented

Added an `isMounted` state that starts as `false` and is set to `true` in a useEffect after mount. This ensures both server and client initially render all items as inactive, preventing the hydration mismatch.

### Changes Made

**1. Added isMounted state:**
```tsx
const [isMounted, setIsMounted] = useState(false)
useEffect(() => {
  setIsMounted(true)
}, [])
```

**2. Updated standalone items active check:**
```tsx
// Before
const isActive = pathname === item.href

// After - hydration-safe
const isActive = isMounted && pathname === item.href
```

**3. Updated group active check:**
```tsx
const isGroupActive = (group: NavigationGroup) => {
  if (!isMounted) return false // Consistent false during SSR/hydration
  return group.children.some((child, idx) => {
    // ... existing logic ...
  })
}
```

**4. Updated child items active check:**
```tsx
const isActive =
  isMounted &&
  (hasChildRoutes
    ? pathname === child.href
    : pathname === child.href || pathname.startsWith(child.href + '/'))
```

---

## Files Changed

| File | Changes |
|------|---------|
| `src/components/layout/sidebar.tsx` | Added `isMounted` state, updated all active state checks to use it |

---

## How This Prevents Recurrence

The `isMounted` pattern ensures:

1. **Server render:** `isMounted = false` → All items render as inactive
2. **Client hydration:** `isMounted = false` → All items render as inactive (matches server)
3. **After mount:** `isMounted = true` → Active items correctly highlight

This guarantees server and client produce identical HTML during hydration, then the correct active state is applied after mount.

---

## Testing Steps

1. Start dev server: `npm run dev`
2. Open browser DevTools console
3. Navigate to any dashboard page
4. Verify no hydration mismatch errors in console
5. Verify navigation items highlight correctly when active
6. Navigate between pages and confirm active states update

---

## Related Issues

- BUG-20251224: Sidebar User Initials Hydration Mismatch (different issue, also fixed)
