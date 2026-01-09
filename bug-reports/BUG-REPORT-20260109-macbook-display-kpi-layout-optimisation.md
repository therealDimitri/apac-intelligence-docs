# Bug Report: MacBook Display KPI Layout Optimisation

**Date:** 9 January 2026
**Status:** Fixed
**Severity:** Medium (UX/Visual)
**Affected Component:** BURCExecutiveDashboard, globals.css

---

## Problem Description

The Executive Dashboard KPI cards displayed incorrectly on 14" and 16" MacBook screens:

1. **Text Wrapping Issues**
   - KPI labels like "Gross Revenue Retention" and "Net Revenue Retention" wrapped awkwardly
   - Subtitle text "FY26 Full Year (Actuals + Forecasts)" wrapped to multiple lines
   - Status badges wrapped beneath KPI values

2. **Inefficient Space Usage**
   - Cards had excessive padding for laptop screen sizes
   - Gaps between cards were too large
   - Whitespace not optimised for 1512px-1800px viewport widths

3. **Breakpoint Coverage**
   - Previous CSS only had breakpoints for 1440px-1920px (combined)
   - No specific optimisation for 14" MacBook Pro (1512px scaled)
   - No specific optimisation for 16" MacBook Pro (1728px scaled)

---

## Root Cause Analysis

The dashboard was designed primarily for larger external monitors, with laptop displays receiving generic responsive treatment. The existing MacBook CSS breakpoint was too broad (1440px-1920px) and didn't account for the specific constraints of modern MacBook display resolutions.

---

## Solution Implemented

### 1. Enhanced CSS Breakpoints (globals.css)

Created three distinct breakpoint ranges:

```css
/* 14" MacBook Pro and smaller laptops (1280px - 1599px) */
@media (min-width: 1280px) and (max-width: 1599px) {
  /* Compact styles with reduced padding/gaps */
}

/* 16" MacBook Pro and mid-size displays (1600px - 1919px) */
@media (min-width: 1600px) and (max-width: 1919px) {
  /* Balanced styles for larger laptop screens */
}

/* Larger external displays (1920px and above) */
@media (min-width: 1920px) {
  /* Standard/generous spacing */
}
```

### 2. New KPI Utility Classes (globals.css)

Added specialised CSS classes for KPI card elements:

- `.kpi-label-responsive` - Prevents label text wrapping with clamp-based sizing
- `.kpi-subtitle` - Compact subtitle display with truncation
- `.kpi-header` - Flexbox layout with proper overflow handling
- `.kpi-content` - Content wrapper preventing overflow
- `.kpi-icon` - Fixed-size icon container
- `.kpi-metric-row` - Inline value + badge display
- `.kpi-badge` - Compact status pill styling

### 3. Component Updates (BURCExecutiveDashboard.tsx)

**Before:**
```tsx
<span className="text-sm font-medium opacity-80 kpi-label-responsive kpi-truncate block">
  Gross Revenue Retention
</span>
<p className="text-xs opacity-60 kpi-truncate">
  FY26 (Actuals + Forecasts)
</p>
```

**After:**
```tsx
<span className="kpi-label-responsive font-medium opacity-80">GRR</span>
<p className="kpi-subtitle">
  FY26 Actuals + Forecast
</p>
```

Key changes:
- Shortened KPI labels (NRR, GRR, Rule of 40, Total ARR)
- Shortened subtitle text ("Actuals + Forecast" instead of "Full Year (Actuals + Forecasts)")
- Reduced card padding from `p-4 lg:p-5` to `p-3 lg:p-4`
- Reduced grid gaps from `gap-3 lg:gap-4` to `gap-2 lg:gap-3`
- Applied new utility classes for consistent layout

---

## Files Modified

| File | Changes |
|------|---------|
| `src/app/globals.css` | Enhanced MacBook breakpoints, new KPI utility classes |
| `src/components/burc/BURCExecutiveDashboard.tsx` | Updated KPI card structure, reduced padding/gaps |

---

## Responsive Behaviour

| Screen Size | Viewport | Card Padding | Gap | Font Behaviour |
|-------------|----------|--------------|-----|----------------|
| 14" MacBook | 1280-1599px | 0.75rem | 0.5rem | Compact, truncated |
| 16" MacBook | 1600-1919px | 0.875rem | 0.75rem | Balanced |
| External | 1920px+ | 1.25rem | 1rem | Standard |

---

## Testing Checklist

- [x] TypeScript compilation passes
- [x] 14" MacBook display (1512px) - 4 KPI cards fit without wrapping
- [x] 16" MacBook display (1728px) - Comfortable spacing maintained
- [x] External monitor (1920px+) - No regression from previous layout
- [x] Mobile responsive behaviour unchanged

---

## Related Documentation

- Design system: `src/lib/design-tokens.ts`
- CSS utilities: `src/app/globals.css` (lines 370-590)

---

## Lessons Learned

1. **Breakpoint Granularity**: MacBook displays need specific breakpoints rather than generic laptop ranges
2. **Abbreviations**: Using abbreviations (NRR, GRR) in constrained spaces improves layout without losing meaning
3. **CSS Clamp**: Using `clamp()` for font sizes provides smooth scaling across viewport ranges
4. **Overflow Control**: KPI cards benefit from explicit overflow handling on container and content elements
