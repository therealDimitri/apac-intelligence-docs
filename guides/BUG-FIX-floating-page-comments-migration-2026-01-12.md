# Bug Fix: FloatingPageComments Migration and Related Fixes

**Date**: 2026-01-12
**Component**: Comments System, Dashboard Pages
**Files Modified**: 15 files

## Summary

Migration of all 12 dashboard pages from the inline `PageComments` component to the new `FloatingPageComments` component, which provides a floating action button (FAB) pattern with a slide-out sheet panel for page discussions.

## Issues Fixed

### 1. FloatingPageComments Supabase Client Import Error

**Problem**: The `FloatingPageComments` component was importing from a non-existent path:
```tsx
import { createClient } from '@/utils/supabase/client'  // Path doesn't exist
```

**Root Cause**: The component was created with an incorrect import path. The project uses `@/lib/supabase` for the Supabase client, not `@/utils/supabase/client`.

**Solution**: Updated the import to use the correct project-standard import:
```tsx
import { supabase } from '@/lib/supabase'
```

Also removed the redundant `const supabase = createClient()` calls since the supabase instance is now imported directly.

**File**: `/src/components/comments/FloatingPageComments.tsx`

### 2. Compliance Page EventTypeSummary TypeScript Error

**Problem**: The `EventTypeSummary` component was being called with props that weren't defined in its interface:
```tsx
<EventTypeSummary
  eventTypeSummaries={eventTypeSummaries}
  clients={filteredClients}           // Not in component props
  expandedEventCode={expandedEventType}
  onEventTypeClick={handleEventTypeClick}
  onClientClick={handleClientClick}   // Not in component props
/>
```

**Root Cause**: Props were added to the call site without updating the component's TypeScript interface.

**Solution**: Removed the unused props from the call site:
```tsx
<EventTypeSummary
  eventTypeSummaries={eventTypeSummaries}
  expandedEventCode={expandedEventType}
  onEventTypeClick={handleEventTypeClick}
/>
```

**File**: `/src/app/(dashboard)/compliance/page.tsx`

## Pages Updated with FloatingPageComments

All 12 dashboard pages were updated:

1. `/src/app/(dashboard)/support/page.tsx`
2. `/src/app/(dashboard)/alerts/page.tsx`
3. `/src/app/(dashboard)/nps/page.tsx`
4. `/src/app/(dashboard)/team-performance/page.tsx`
5. `/src/app/(dashboard)/financials/page.tsx`
6. `/src/app/(dashboard)/planning/account/[id]/page.tsx`
7. `/src/app/(dashboard)/planning/account/new/page.tsx`
8. `/src/app/(dashboard)/planning/territory/[id]/page.tsx`
9. `/src/app/(dashboard)/planning/territory/new/page.tsx`
10. `/src/app/(dashboard)/planning/strategic/new/page.tsx`
11. `/src/app/(dashboard)/aging-accounts/page.tsx`
12. `/src/app/(dashboard)/segmentation/page.tsx`

## Changes Made Per Page

For each page:
1. Changed import from `PageComments` to `FloatingPageComments`
2. Removed the wrapping `<div className="mt-8">` container
3. Removed `collapsible` and `defaultExpanded={false}` props
4. Added `description` prop with pattern "Discuss [topic] with your team"
5. Moved component placement to end of return statement (floating position)

### Example Transformation

**Before**:
```tsx
import { PageComments } from '@/components/comments'

// ... in JSX
<div className="mt-8">
  <PageComments
    entityType="support"
    entityId="support-dashboard"
    title="Support Discussion"
    collapsible
    defaultExpanded={false}
  />
</div>
```

**After**:
```tsx
import { FloatingPageComments } from '@/components/comments'

// ... at end of JSX, before closing tag
<FloatingPageComments
  entityType="support"
  entityId="support-dashboard"
  title="Support Discussion"
  description="Discuss support health metrics with your team"
/>
```

## Testing

- Build completed successfully with zero TypeScript errors
- All 143 pages compiled and generated without issues

## UX Improvement

The FloatingPageComments component provides:
- Fixed position floating button (bottom-right corner)
- Badge showing unread comment count
- Sheet/slide-over panel from the right side
- Always visible and accessible from any scroll position
- Real-time comment count updates via Supabase subscriptions
