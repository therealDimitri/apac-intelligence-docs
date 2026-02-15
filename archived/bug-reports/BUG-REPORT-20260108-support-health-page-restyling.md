# Bug Report: Support Health Page Inconsistent Styling

**Date:** 8 January 2026
**Status:** ✅ Fixed
**Commits:** `88e603f0`, `50666fd0`

## Issue Summary

The Support Health page (`/support`) had inconsistent styling compared to the Segmentation Events page. The first fix attempt used gradient icons and dark Card components, which didn't match the standard dashboard styling pattern.

## Visual Comparison

### Before (Original)
- Basic grey background (`bg-gray-50`)
- Raw HTML `<button>` element
- Simple `<table>` with inline CSS classes
- No summary cards
- No proper loading skeletons

### First Fix Attempt (Wrong Style)
- Themed header with **gradient icon container** (not standard)
- 6 gradient summary cards with dark borders
- Card components with borders

### Final Fix (Matches Segmentation Events)
- Plain white header with shadow (no gradient icon)
- 4 pastel gradient summary cards with icons on the right
- White rounded container without dark borders
- Alert banner for at-risk clients
- Lighter grey table border (`border-gray-200`)

## Solution

### 1. Updated `/src/app/(dashboard)/support/page.tsx`

Matched the Segmentation Events page header style:
- Plain white background with `shadow-sm`
- No gradient icon container
- Title and subtitle on left, action buttons on right

```typescript
<div className="bg-white shadow-sm border-b border-gray-200">
  <div className="px-3 sm:px-6 py-3 sm:py-4">
    <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
      <div>
        <h1 className="text-2xl sm:text-3xl font-bold text-gray-900">Support Health</h1>
        <p className="text-xs sm:text-sm text-gray-600 mt-1">...</p>
      </div>
      ...
    </div>
  </div>
</div>
```

### 2. Updated `/src/components/support/SupportOverviewTable.tsx`

- **Summary Cards**: Reduced to 4 cards with pastel gradient backgrounds and icons on the right
- **Alert Banner**: Added for at-risk/critical clients with "View All" button
- **Table Container**: White rounded card with `shadow-sm` (no border)
- **Table Border**: Light grey border (`border-gray-200`)
- **Table Headers**: Uppercase grey text matching Segmentation Events

```typescript
// Summary card pattern matching Segmentation Events
<motion.div
  className={cn('rounded-xl shadow-sm p-4 bg-gradient-to-br', card.bgGradient)}
>
  <div className="flex items-center justify-between">
    <div>
      <p className="text-sm font-medium text-gray-600">{card.title}</p>
      <p className="text-3xl font-bold text-gray-900">{card.value}</p>
    </div>
    <div className={cn('rounded-xl p-3', card.iconBg)}>
      <Icon className={cn('h-6 w-6', card.iconColour)} />
    </div>
  </div>
</motion.div>
```

## Files Modified

1. `src/app/(dashboard)/support/page.tsx` - Main page layout and header
2. `src/components/support/SupportOverviewTable.tsx` - Summary cards, alert banner, table styling

## Design Patterns Applied (Matching Segmentation Events)

| Pattern | Segmentation Events | Support Health |
|---------|---------------------|----------------|
| Header | White bg, shadow, no icon | ✅ Same |
| Summary Cards | Pastel gradients, icon right | ✅ Same |
| Card Container | White rounded, shadow-sm | ✅ Same |
| Table Border | Light grey (border-gray-200) | ✅ Same |
| Table Headers | Uppercase grey text | ✅ Same |
| Alert Banner | Gradient background | ✅ Same |

## Verification

- TypeScript compilation: ✅ Passed
- ESLint: ✅ Passed
- Visual inspection: ✅ Matches Segmentation Events design

## Related Pages

The styling now matches:
- `/compliance` - Segmentation Events (primary reference)
- `/financials` - BURC Performance
- `/aging-accounts` - Working Capital
