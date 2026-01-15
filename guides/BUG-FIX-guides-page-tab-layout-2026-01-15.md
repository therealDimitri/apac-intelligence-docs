# Bug Fix: Guides & Resources Tab Layout for 16"/14" Displays

**Date:** 2026-01-15
**Status:** Resolved
**Commit:** e990ff7b

## Problem

The Guides & Resources page tab navigation was not optimised for 16" and 14" MacBook displays. The tabs were:
- Cramped and overflowing on smaller screens
- Using `flex-1` which distributed space equally among 9 tabs, causing compression
- Hiding tab labels at smaller breakpoints (`hidden lg:inline`)

## Root Cause

The tab container used `flex-1` on each tab button, which attempted to distribute available space equally. With 9 tabs, this caused severe compression on smaller displays where there wasn't enough horizontal space.

## Solution

Changed the tab layout to be horizontally scrollable:

### Changes Made

**File:** `src/app/(dashboard)/guides/page.tsx`

1. **Tab Container** - Added horizontal scroll:
   ```tsx
   // Before
   <div className="flex gap-1">

   // After
   <div className="flex gap-1 overflow-x-auto scrollbar-hide">
   ```

2. **Tab Buttons** - Changed from flex-1 to flex-shrink-0:
   ```tsx
   // Before
   className="relative flex-1 flex items-center justify-center gap-2 ..."

   // After
   className="relative flex-shrink-0 flex items-center justify-center gap-2 ..."
   ```

3. **Tab Icons** - Added flex-shrink-0:
   ```tsx
   // Before
   <Icon className={`h-4 w-4 ${isActive ? 'animate-pulse' : ''}`} />

   // After
   <Icon className={`h-4 w-4 flex-shrink-0 ${isActive ? 'animate-pulse' : ''}`} />
   ```

4. **Tab Labels** - Always visible with no-wrap:
   ```tsx
   // Before
   <span className="hidden lg:inline text-sm">{tab.label}</span>

   // After
   <span className="text-sm whitespace-nowrap">{tab.label}</span>
   ```

## Result

- Tabs now scroll horizontally when they don't fit
- Each tab maintains its natural width based on content
- Labels are always visible regardless of screen size
- Hidden scrollbar provides clean aesthetic while maintaining functionality

## Testing

- Build passes with zero TypeScript errors
- Tabs scroll smoothly on smaller displays
- No visual regressions on larger displays
