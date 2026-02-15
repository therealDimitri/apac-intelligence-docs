# Bug Report: Compliance Sidebar Badge and Close Button Overlapping Header

**Date:** 17 January 2026
**Status:** Fixed
**Commit:** 8483959d

## Issue Description

In the Compliance page (`/compliance`), when opening an event type sidebar (Sheet component), the percentage badge and close button were overlapping with the sidebar heading text. This was particularly noticeable with long event names like "President/Group Leader Engagement (in person)".

## Root Cause

The Badge component was using absolute positioning (`absolute top-4 right-12`) which caused it to:
1. Overlap with the heading text on the same vertical line
2. Conflict with the Sheet component's built-in close button
3. Truncate long heading text

## Solution

Changed the SheetHeader layout from absolute positioning to inline flexbox:

### Before
```tsx
<SheetHeader className="px-6 py-4 border-b bg-gradient-to-r from-purple-50 to-indigo-50">
  <div className="flex items-center gap-3">
    <div className="p-2 rounded-lg bg-purple-100">
      <Target className="h-5 w-5 text-purple-600" />
    </div>
    <div>
      <SheetTitle>...</SheetTitle>
      <SheetDescription>...</SheetDescription>
    </div>
  </div>
  <Badge className={cn('absolute top-4 right-12', ...)}>
    {Math.round(selectedEventTypeData.percentage)}%
  </Badge>
</SheetHeader>
```

### After
```tsx
<SheetHeader className="px-6 py-4 border-b bg-gradient-to-r from-purple-50 to-indigo-50 pr-12">
  <div className="flex items-start gap-3">
    <div className="p-2 rounded-lg bg-purple-100 flex-shrink-0">
      <Target className="h-5 w-5 text-purple-600" />
    </div>
    <div className="flex-1 min-w-0">
      <div className="flex items-center gap-2 flex-wrap">
        <SheetTitle className="text-lg font-semibold text-gray-900">
          {selectedEventTypeData.eventName}
        </SheetTitle>
        <Badge variant="secondary" className={cn('flex-shrink-0', ...)}>
          {Math.round(selectedEventTypeData.percentage)}%
        </Badge>
      </div>
      <SheetDescription className="text-sm text-gray-500 mt-1">
        {selectedEventTypeData.compliantClients} of {selectedEventTypeData.totalClients} clients meeting target
      </SheetDescription>
    </div>
  </div>
</SheetHeader>
```

## Key Changes

1. Added `pr-12` padding to SheetHeader to accommodate the close button
2. Changed outer flex from `items-center` to `items-start` for better alignment
3. Added `flex-shrink-0` to the icon container
4. Wrapped title and badge in a flex container with `flex-wrap`
5. Removed absolute positioning from Badge
6. Added `flex-shrink-0` to Badge to maintain its size
7. Added `mt-1` to description for proper spacing

## Files Modified

- `/src/app/(dashboard)/compliance/page.tsx` (lines 1326-1356)

## Testing Performed

1. Opened event type sidebar with long name ("President/Group Leader Engagement")
2. Verified badge displays inline with title
3. Verified close button is accessible and not overlapping
4. Verified description displays correctly below title/badge row
5. Browser console shows no hydration errors related to this component

## Verification

- Build passes: `npm run build` - Zero TypeScript errors
- Tested in browser at http://localhost:3001/compliance
