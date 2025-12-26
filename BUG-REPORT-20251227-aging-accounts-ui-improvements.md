# Bug Report: Aging Accounts UI Improvements

**Date:** 27 December 2025
**Severity:** Low
**Status:** Fixed
**Commits:** `61f4ffa`, `ed90c42`

## Summary

Multiple UI consistency issues in the Working Capital > Detailed View table were identified and resolved:

1. **$0 bucket values not visually differentiated** - Green and blue coloured text was applied to $0 values, making them appear as significant amounts
2. **Trend column misalignment** - Sparklines and placeholder dashes had inconsistent widths, causing column misalignment

## Issues and Fixes

### Issue 1: $0 Bucket Values Colour Inconsistency

**Before:**
- 0-30 Days column: Always green (`text-green-600`)
- 31-60 Days column: Always blue (`text-blue-600`)
- 61-90 Days column: Conditional (amber if > 0, grey if $0)
- 90+ Days column: Conditional (red if > 0, grey if $0)

**After:**
All bucket columns now use grey (`text-gray-400`) when the value is $0, providing consistent visual indication of empty buckets.

**Files Changed:**
- `src/app/(dashboard)/aging-accounts/page.tsx`

**Code Pattern:**
```tsx
// Before
<td className="text-green-600">$0</td>

// After
<td className={amount > 0 ? 'text-green-600' : 'text-gray-400'}>$0</td>
```

### Issue 2: Trend Column Alignment

**Before:**
- Sparklines rendered at 60px width with trend indicator icon
- No-data placeholder was a simple dash with no fixed width
- Caused visual misalignment between rows

**After:**
- Added fixed 80px width container around both sparklines and placeholders
- Ensures consistent column alignment regardless of data availability

**Code Pattern:**
```tsx
<div className="w-[80px] flex items-center justify-center">
  {trendData ? (
    <TrendSparkline dataPoints={...} width={60} height={18} />
  ) : (
    <span className="w-[60px] text-center">—</span>
  )}
</div>
```

## Testing

- TypeScript compilation: Passed
- ESLint: Passed
- Visual verification: Confirmed alignment and colour consistency

## Related Changes in This Session

1. Historical Trend chart x-axis dates now use actual database dates
2. Historical Trend chart Y-axis now uses dynamic scaling (matching sparkline behaviour)
3. Dollar-weighted average calculation for historical compliance data

## Screenshots

N/A - Visual changes verified by user

## Lessons Learned

1. Apply consistent conditional styling patterns across all similar UI elements
2. Use fixed-width containers when mixing different content types in table columns
3. Empty/zero values should be visually differentiated from meaningful data
