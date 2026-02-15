# Bug Fix: Hydration Mismatches in Sidebar and Dashboard

**Date**: 2026-01-19
**Type**: Bug Fix
**Component**: Sidebar Navigation, Dashboard Page
**Status**: Resolved

## Description

The application experienced React hydration errors causing the page to fail rendering. The error message was: "Hydration failed because the server rendered HTML didn't match the client."

## Root Causes

### 1. Sidebar Navigation Hydration Mismatch

The sidebar component rendered navigation items differently on server vs client due to:
- `isMounted` state affecting what gets rendered
- `expandedGroups` state loaded from localStorage only on client
- Server rendered `<a>` tags while client expected `<div>` tags for collapsed groups

### 2. Dashboard Greeting Hydration Mismatch

The greeting ("Good morning", "Good afternoon", "Good evening") was computed using `new Date().getHours()` during render, which produced different values on server vs client due to timezone/time differences.

## Solutions

### Sidebar Fix

Wrapped the entire navigation in a conditional render that shows a static placeholder during SSR:

```tsx
{isMounted ? (
  <>
    {/* Full interactive navigation with Link components */}
    {standaloneItems.map(item => (
      <Link key={item.name} href={item.href}>...</Link>
    ))}
    {navigationGroups.map(group => (
      <div key={group.name}>
        <button onClick={() => toggleGroup(group.name)}>...</button>
        <div className={isExpanded ? 'max-h-96' : 'max-h-0'}>...</div>
      </div>
    ))}
  </>
) : (
  /* Server-side placeholder - static divs only */
  <div className="space-y-1">
    {navigationGroups.map(group => (
      <div key={group.name}>
        <div className="w-full flex items-center...">
          <group.icon className="mr-3 h-4 w-4" />
          <span>{group.name}</span>
          <ChevronRight className="h-4 w-4" />
        </div>
      </div>
    ))}
  </div>
)}
```

### Dashboard Greeting Fix

Added `suppressHydrationWarning` to the greeting element, which is the recommended React pattern for intentional hydration differences:

```tsx
<h2 className="text-lg font-semibold text-gray-900" suppressHydrationWarning>
  {getGreeting()}, {profile.firstName}!
</h2>
```

This tells React that the mismatch between server time and client time is expected and acceptable.

## Files Modified

1. `src/components/layout/sidebar.tsx` - Conditional SSR placeholder rendering
2. `src/app/(dashboard)/page.tsx` - suppressHydrationWarning on greeting element

## Additional Change

Also included in this commit: Added "South Australia Health" to `CLIENT_PARENT_MAP` in `src/app/api/analytics/burc/historical/route.ts` for CLV table consolidation.

## Verification

- Page loads without hydration errors
- Navigation renders correctly after mount
- Greeting displays time-appropriate message
- CLV table consolidates SA Health entries properly

## Commit

`1279e978` - fix: Resolve hydration mismatches in Sidebar and Dashboard page
