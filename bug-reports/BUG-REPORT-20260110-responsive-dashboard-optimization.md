# Responsive Dashboard Optimization for 14" and 16" Displays

**Date:** 2026-01-10
**Type:** Enhancement
**Status:** Resolved
**Priority:** Medium

---

## Summary

Optimised all dashboard pages for better utilisation of screen real estate on 14" and 16" MacBook displays by adding `xl` (1280px) and `2xl` (1536px) Tailwind breakpoints.

## Target Displays

| Display | Resolution | Viewport Width |
|---------|-----------|----------------|
| 14" MacBook Pro | 1512 x 982 | Above xl (1280px) |
| 16" MacBook Pro | 1728 x 1117 | Above 2xl (1536px) |

## Files Modified

### Dashboard Pages

| File | Changes |
|------|---------|
| `src/app/(dashboard)/alerts/page.tsx` | Widened container from `max-w-7xl` to `max-w-[1920px]`, added `2xl:px-4` padding |
| `src/app/(dashboard)/settings/page.tsx` | Added `2xl:max-w-6xl` for larger screens |
| `src/app/(dashboard)/benchmarking/page.tsx` | Widened container to `max-w-[1920px]`, added `2xl:px-12` padding, increased grid gaps |
| `src/app/(dashboard)/client-profiles/page.tsx` | Added `2xl:grid-cols-5` for grid view, `2xl:grid-cols-8` for compact view |
| `src/app/(dashboard)/planning/page.tsx` | Added `xl:grid-cols-4 2xl:grid-cols-5` for plan cards grid |
| `src/app/(dashboard)/segmentation/page.tsx` | Added `2xl:grid-cols-3` breakpoint for stats grid |
| `src/app/(dashboard)/nps/page.tsx` | Added `2xl:p-8` padding, `2xl:gap-8` grid gaps, `2xl:px-8` header padding |

### Components

| File | Changes |
|------|---------|
| `src/components/TraditionalDashboard.tsx` | Added `2xl:grid-cols-4` to stats grid |
| `src/components/team-performance/TeamKPIGrid.tsx` | Added `2xl:grid-cols-4` to all KPI grids |
| `src/components/compliance/ClientComplianceCard.tsx` | Updated grid to `lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5` for better screen utilization |
| `src/app/(dashboard)/compliance/page.tsx` | Updated skeleton loader grid to match `xl:grid-cols-4 2xl:grid-cols-5` |
| `src/components/GlobalNPSBenchmark.tsx` | Added `2xl:gap-8` to comparison grid |
| `src/components/TopTopicsBySegment.tsx` | Added `2xl:p-8` padding, `2xl:gap-8` grid gap, fixed text overflow with `whitespace-nowrap` and `flex-wrap gap-2` |

## Optimisation Strategy

### Container Width Changes
- Replaced `max-w-7xl` (1280px) with `max-w-[1920px]` for full-width dashboards
- This allows content to expand on larger displays while maintaining readability

### Grid Column Breakpoints
- Added `2xl:` breakpoints to grids with multiple items
- Card grids now show more items per row on 16" displays
- KPI grids maintain 4 columns but benefit from wider containers

### Padding Adjustments
- Added `2xl:px-12` for increased horizontal padding on wide screens
- Added `2xl:gap-8` for larger gaps between grid items

### Text Overflow Fixes
- Fixed topic cards in NPS page where "mentions" text was breaking across lines
- Added `whitespace-nowrap` to prevent badge text from breaking
- Changed `space-x-2` to `flex-wrap gap-2` to allow proper badge wrapping on narrow cards

## Tailwind Breakpoints Reference

```
sm: 640px   - Mobile landscape
md: 768px   - Tablet portrait
lg: 1024px  - Tablet landscape
xl: 1280px  - 14" laptops (new additions target this)
2xl: 1536px - 16" laptops (new additions target this)
```

## Before/After Summary

| Component | Before | After |
|-----------|--------|-------|
| Client Profiles Grid | `xl:grid-cols-4` | `xl:grid-cols-4 2xl:grid-cols-5` |
| Client Profiles Compact | `xl:grid-cols-6` | `xl:grid-cols-6 2xl:grid-cols-8` |
| Plan Cards | `lg:grid-cols-3` | `lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5` |
| Compliance Cards | `xl:grid-cols-3` | `xl:grid-cols-3 2xl:grid-cols-4` |
| Alerts Container | `max-w-7xl` | `max-w-[1920px]` |
| Benchmarking Container | `max-w-7xl` | `max-w-[1920px]` |

## Testing Checklist

- [x] Build passes without TypeScript errors
- [x] All modified pages compile successfully
- [x] Visual verification on 14" display (1280px viewport)
- [x] Visual verification on 16" display (1536px viewport)
- [x] Grid layouts expand correctly at breakpoints
- [x] No horizontal scrolling on any viewport size
- [x] Cards maintain readable proportions

### Verification Results (10 January 2026)

| Page | 14" (1280px / xl) | 16" (1536px / 2xl) | Status |
|------|-------------------|---------------------|--------|
| Client Portfolios | 4 columns | 5 columns | ✓ Pass |
| Segmentation Events | 4 event cards/row | 4 event cards/row (wider) | ✓ Pass |
| NPS Analytics | Good layout, filters wrap | Increased spacing, single-row filters | ✓ Pass |
| Command Centre | Proper spacing | Enhanced spacing | ✓ Pass |

## Notes

1. **Intentional two-column layouts preserved**: Some `lg:grid-cols-2` patterns were intentionally kept as-is because they represent split-view layouts (e.g., charts side-by-side) where expanding to 3+ columns would break the visual design.

2. **KPI grids**: Four-item KPI grids (`lg:grid-cols-4`) remain at 4 columns because:
   - 4 KPIs is a natural grouping
   - Wider cards improve readability
   - Adding more columns would require more KPIs

3. **Container widths**: Using `max-w-[1920px]` instead of removing max-width entirely prevents content from becoming too wide on ultra-wide monitors.

---

## Related Documentation

- Tailwind CSS Breakpoints: https://tailwindcss.com/docs/responsive-design
- `docs/bug-reports/BUG-REPORT-20260110-stakeholder-map-redesign.md` - Related UI enhancement

