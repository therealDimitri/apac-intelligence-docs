# Bug Report: Progress Ring Styling and Column Headers

**Date:** 2026-01-14
**Status:** Fixed
**Priority:** Medium
**Component:** Strategic Planning - Discovery & Diagnosis Step

---

## Issues Addressed

### 1. Progress Ring Too Small and Hard to Read
**Problem:** The progress ring in QuestionnaireSection was only 32px (w-8 h-8) with 8px text, making the percentage difficult to read.

**Solution:**
- Increased ring size from 32px to 44px (w-11 h-11)
- Changed viewBox to "0 0 44 44" for proper scaling
- Increased circle radius from 12 to 18
- Increased stroke width from 2.5 to 3
- Changed percentage text from text-[8px] to text-xs (12px)
- Added strokeLinecap="round" for rounded progress ends

---

### 2. Progress Ring Animated/Dot Visible at 0%
**Problem:** A small dot appeared at the top of the progress ring even when progress was 0%, and the ring appeared to animate due to `transition-all` affecting SVG properties.

**Solution:**
- Changed `transition-all duration-200` to `transition-[border-color,box-shadow] duration-200` to prevent SVG properties from animating
- Wrapped the progress stroke circle in a conditional: `{progressPercent > 0 && (...)}` so it only renders when there's actual progress

---

### 3. Missing Column Headers in Client Gap Diagnosis Table
**Problem:** The Client Gap Diagnosis table showed client data (Segment, Health Score, NPS, Support Health) but had no column headers, making it difficult to understand what each column represented.

**Solution:** Added a header row with uppercase labels:
- CLIENT
- SEGMENT
- HEALTH
- NPS
- SUPPORT
- COST AT RISK

---

## Technical Changes

### Files Modified

1. **`src/components/planning/methodology/QuestionnaireSection.tsx`**
   - Line 176: Changed transition from `transition-all` to `transition-[border-color,box-shadow]`
   - Lines 243-274: Updated progress ring dimensions and conditional rendering
   - Increased SVG viewBox, circle radius, stroke width
   - Changed center text size from 8px to 12px
   - Added conditional rendering for progress stroke

2. **`src/app/(dashboard)/planning/strategic/new/steps/DiscoveryDiagnosisStep.tsx`**
   - Lines 431-451: Added column headers row in Client Gap Diagnosis section
   - Used 12-column grid matching existing data rows

---

## Code Changes

### QuestionnaireSection.tsx - Progress Ring

```tsx
// Before
<div className="w-8 h-8 relative flex-shrink-0">
  <svg className="w-8 h-8 transform -rotate-90">
    <circle cx="16" cy="16" r="12" ... />
    <circle cx="16" cy="16" r="12" strokeDasharray={...} ... />
  </svg>
  <span className="text-[8px] font-bold">{progressPercent}%</span>
</div>

// After
<div className="w-11 h-11 relative flex-shrink-0">
  <svg className="w-11 h-11 transform -rotate-90" viewBox="0 0 44 44">
    <circle cx="22" cy="22" r="18" ... />
    {progressPercent > 0 && (
      <circle cx="22" cy="22" r="18" strokeDasharray={...} strokeLinecap="round" ... />
    )}
  </svg>
  <span className="text-xs font-bold">{progressPercent}%</span>
</div>
```

### DiscoveryDiagnosisStep.tsx - Column Headers

```tsx
{/* Column Headers */}
<div className="px-4 py-2 grid grid-cols-12 gap-3 items-center bg-gray-50 border-b border-gray-200">
  <div className="col-span-4 text-xs font-medium text-gray-500 uppercase tracking-wider">Client</div>
  <div className="col-span-2 text-xs font-medium text-gray-500 uppercase tracking-wider">Segment</div>
  <div className="col-span-1 text-xs font-medium text-gray-500 uppercase tracking-wider text-center">Health</div>
  <div className="col-span-1 text-xs font-medium text-gray-500 uppercase tracking-wider text-center">NPS</div>
  <div className="col-span-1 text-xs font-medium text-gray-500 uppercase tracking-wider text-center">Support</div>
  <div className="col-span-3 text-xs font-medium text-gray-500 uppercase tracking-wider text-right">Cost at Risk</div>
</div>
```

---

## Testing Checklist

- [x] Progress ring displays at 44px size
- [x] Percentage text is readable (12px/text-xs)
- [x] No dot appears at 0% progress
- [x] No animation on progress ring when not changing
- [x] Progress stroke appears correctly when > 0%
- [x] Column headers display in Client Gap Diagnosis table
- [x] Column headers align with data columns
- [x] Build passes with no TypeScript errors
- [x] No console errors

---

## Related Components

- QuestionnaireSection used across multiple strategic planning steps
- Client Gap Diagnosis table in Discovery & Diagnosis step

---

## Notes

- The `transition-all` was causing SVG stroke properties to animate
- `strokeLinecap="round"` with a zero-length dash still renders a small dot, hence the conditional rendering
- Column header grid uses same 12-column layout as data rows for alignment
