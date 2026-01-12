# Bug Report: Segmentation Events Page Not Optimised for 14" and 16" MacBook Displays

**Date:** 12 January 2026
**Severity:** Medium
**Status:** Resolved
**Affected Files:**
- `src/app/(dashboard)/segmentation/page.tsx`
- `src/components/CSEWorkloadView.tsx`

## Problem Description

The Segmentation Events page layout was not optimised for 14" and 16" MacBook displays (typical resolutions of 1512px and 1728px effective width). Multiple UI elements were cramped or overflowing on laptop screens.

### Root Cause Analysis

1. **Client row layout**: Too many horizontal elements with fixed widths (`w-24`) that didn't adapt to screen size
2. **Summary stats grid**: Jumped from 1 column directly to 4 columns (`md:grid-cols-4`) without intermediate breakpoints
3. **Segment stats grid**: Used 5 columns at `sm` breakpoint (640px+), which was too aggressive for laptop screens
4. **CSEWorkloadView stats grid**: 7 columns on `lg` (1024px+) caused cramped layout on 14" MacBooks

## Solution Applied

### 1. Summary Stats Grid (Segmentation Page)
**Before:**
```tsx
<div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
```

**After:**
```tsx
<div className="grid grid-cols-2 md:grid-cols-4 gap-3 lg:gap-4 xl:gap-6 mb-6 xl:mb-8">
```

### 2. Segment Stats Grid
**Before:**
```tsx
<div className="grid grid-cols-2 sm:grid-cols-5 gap-4 mt-6">
```

**After:**
```tsx
<div className="grid grid-cols-3 lg:grid-cols-5 gap-2 lg:gap-3 xl:gap-4 mt-4 lg:mt-6">
```

### 3. Client Row Health/Compliance Bars
**Key changes:**
- Health score: Hidden on mobile, shown from `md` breakpoint
- Compliance score: Hidden until `lg` breakpoint
- "View Profile" button: Hidden until `xl` breakpoint
- Progress bar widths: Responsive (`w-14 lg:w-16 xl:w-20`)
- Labels: Only shown on `xl+` screens
- Text sizes: Responsive (`text-[10px] lg:text-xs`)

### 4. CSEWorkloadView Overall Statistics Grid
**Before:**
```tsx
<div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-7 gap-4">
```

**After:**
```tsx
<div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-4 xl:grid-cols-7 gap-2 lg:gap-3 xl:gap-4">
```

### 5. CSE Metrics Grid (Header)
**Before:**
```tsx
<div className="hidden lg:grid grid-cols-4 gap-4 flex-1">
```

**After:**
```tsx
<div className="hidden xl:grid grid-cols-4 gap-2 xl:gap-4 flex-1">
```

## Tailwind Breakpoint Reference

| Breakpoint | Width   | Target Devices |
|------------|---------|----------------|
| sm         | 640px   | Mobile landscape |
| md         | 768px   | Tablets |
| lg         | 1024px  | Small laptops |
| xl         | 1280px  | 14" MacBook Pro (~1512px) |
| 2xl        | 1536px  | 16" MacBook Pro (~1728px) |

## Testing Performed

1. TypeScript compilation: Passed
2. Production build: Passed
3. Visual inspection at different breakpoints: Verified

## Verification Steps

1. Navigate to `/segmentation` page
2. Resize browser window to simulate:
   - 14" MacBook Pro resolution (1512px width)
   - 16" MacBook Pro resolution (1728px width)
3. Verify:
   - No horizontal overflow
   - All elements properly spaced
   - Health/Compliance bars visible and readable
   - Text sizes appropriate for screen size

## Related Commits

- `6f4315ae` - Add year toggle to Segmentation Events page and improve responsive design

## Lessons Learned

1. Always consider MacBook laptop resolutions (xl breakpoint ~1280-1536px) when designing grids
2. Use progressive disclosure - hide less critical elements on smaller screens
3. Avoid fixed widths; use responsive widths (`w-14 lg:w-16 xl:w-20`)
4. The existing `macbook-*` CSS utility classes in `globals.css` can be leveraged for future MacBook-specific optimisations
