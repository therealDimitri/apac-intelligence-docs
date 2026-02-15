# Bug Report: Card Order and Card Styling Consistency

**Date:** 2026-01-04
**Status:** FIXED
**Severity:** Low (UI/UX)

## Problem Description

Four UI issues on the Client Profile detail page:

### Issue 1: Historical Revenue Card Styling
The Historical Revenue card used a different visual style from other cards on the page (light gradient background instead of white card with coloured header).

### Issue 2: Card Order
User requested specific card ordering that wasn't implemented correctly. The Health Score Trend chart was appearing before Historical Revenue.

**Requested Order:**
1. Historical Revenue
2. Segmentation Actions
3. Working Capital Health
4. Most Recent NPS Result
5. Support SLA
6. Portfolio Initiatives
7. Event Engagement

**Actual Order (before fix):**
1. Health Score Trend ← Wrong position
2. Historical Revenue
3. Segmentation Actions
4. ...etc

### Issue 3: Health Score Trend Card Styling
The Health Score Trend card didn't match other cards (plain white without gradient header).

### Issue 4: Chart Text Overlap
The Health Score Trend chart had overlapping labels:
- X-axis date labels were too close together
- Y-axis had too many ticks (0, 25, 50, 75, 100)
- Reference line labels ("Healthy", "At-Risk") overlapped at same position

## Root Cause

### Issues 1-3
Components were styled inconsistently - some used gradient headers, others used plain white backgrounds.

### Issue 4
The chart was rendering all data point labels on the X-axis, and reference line labels were both positioned at `insideTopRight`.

## Solution

### 1. Restyled Historical Revenue Card

Updated `ClientRevenueCard.tsx` to match other cards:
- White card background with rounded corners and border
- Dynamic gradient header based on YoY trend:
  - Green gradient (`from-emerald-500 to-green-500`) for positive YoY
  - Red gradient (`from-red-500 to-rose-500`) for negative YoY
  - Grey gradient for stable/no change
- Status badge in header showing YoY percentage with icon
- Clean content area with large revenue figure and mini sparkline

### 2. Reordered Cards in LeftColumn.tsx

Moved `<ClientRevenueCard />` component to appear immediately after the hero section, BEFORE the Health Score Trend chart.

**New Order:**
1. Hero section (Health Score button)
2. **Historical Revenue** ← Now first card
3. Health Score Trend (chart)
4. Segmentation Actions
5. Working Capital Health
6. Most Recent NPS Result
7. Support SLA
8. Portfolio Initiatives
9. Event Engagement

### 3. Restyled Health Score Trend Card

Updated the Health Score Trend section in `LeftColumn.tsx`:
- Added gradient header matching other cards
- Dynamic header colour based on 90-day health trend:
  - Green gradient for improving health (positive trend)
  - Red gradient for declining health (negative trend)
  - Purple gradient for stable/no change
- TrendingUp icon in header
- White status badge showing trend points (e.g., "+5 pts (90d)")

### 4. Redesigned Health Score Trend Chart

Updated `HealthTrendChart.tsx` for better readability:
- **X-axis**: Dynamic tick interval to show ~5 labels maximum (prevents overlap)
- **Y-axis**: Simplified to just 0, 50, 100 (3 ticks instead of 5)
- **Reference lines**: Labels changed from "Healthy"/"At-Risk" to "70"/"60" positioned on the right edge
- **Margins**: Adjusted to give room for right-side labels
- **Line/dots**: Made slightly smaller (strokeWidth 2, dot radius 2) for cleaner look

## Files Modified

1. `src/components/client/ClientRevenueCard.tsx`
   - Restyled to match other cards
   - Added dynamic header colours based on YoY trend
   - Added status badge with YoY percentage

2. `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`
   - Moved `<ClientRevenueCard />` before Health Score Trend section
   - Restyled Health Score Trend card with gradient header
   - Added dynamic header colour based on trend

3. `src/components/charts/HealthTrendChart.tsx`
   - Added dynamic tick interval for X-axis
   - Simplified Y-axis to 3 ticks (0, 50, 100)
   - Repositioned reference line labels to right edge
   - Adjusted margins and line styling

## Visual Changes

### Before
- Historical Revenue: light emerald gradient background, appeared after Health Score Trend
- Health Score Trend: plain white card, overlapping chart labels
- Cards in wrong order

### After
- Historical Revenue: white card with gradient header, appears first after hero
- Health Score Trend: white card with dynamic gradient header (green/red/purple based on trend)
- Chart: clean, readable labels with no overlap
- All cards now have consistent styling pattern

## Testing

1. Navigate to any client profile page
2. Verify Historical Revenue appears as first card after hero
3. Verify Health Score Trend card has gradient header
4. Check chart labels are not overlapping
5. Check different clients with positive/negative trends to verify header colours change
