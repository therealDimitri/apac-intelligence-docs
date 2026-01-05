# Enhancement Report: Revenue Trend Display in Health Card

**Date**: 2026-01-05
**Type**: Feature Enhancement
**Priority**: Medium
**Status**: Completed

---

## Summary

Added revenue trend display to the client health card breakdown component, providing at-a-glance financial performance metrics alongside existing health score components (NPS, Compliance, Working Capital, Actions).

---

## Changes Implemented

### 1. New Hook: `useClientRevenueTrend`

**File**: `/src/hooks/useClientRevenueTrend.ts`

**Purpose**: Provides formatted revenue trend data optimised for compact display in health cards and dashboards.

**Features**:
- Fetches current year revenue from BURC historical revenue tables
- Calculates YoY growth percentage
- Provides trend indicators (up/down/flat)
- Formats revenue in compact notation ($1.2M)
- Returns sparkline data for mini charts (last 5 years)

**API**:
```typescript
interface RevenueTrendData {
  currentYearRevenue: number
  currentYear: number | null
  yoyGrowth: number
  yoyGrowthLabel: string
  trend: 'up' | 'down' | 'flat'
  trendColour: string
  formattedRevenue: string
  hasData: boolean
  sparklineData: Array<{ year: number; value: number }>
}

function useClientRevenueTrend(clientName: string | null | undefined): {
  trendData: RevenueTrendData | null
  loading: boolean
  error: string | null
  hasData: boolean
}
```

**Usage**:
```typescript
const { trendData, loading, hasData } = useClientRevenueTrend(client.name)
```

---

### 2. Updated Component: `HealthBreakdown`

**File**: `/src/app/(dashboard)/clients/[clientId]/components/HealthBreakdown.tsx`

**Changes**:
1. Added import for `useClientRevenueTrend` hook
2. Added import for `DollarSign` icon from lucide-react
3. Added import for `Link` component from Next.js
4. Integrated revenue trend data fetching
5. Added revenue trend section after health components

**New Section Features**:
- Shows current year revenue in large, formatted text
- Displays YoY growth percentage with colour-coded trend indicator
- Green/red colours for positive/negative growth
- Includes link to full financials view
- Only renders when revenue data is available (graceful degradation)

**Visual Design**:
- Emerald gradient background (`from-emerald-50 to-green-50`)
- Matches existing component styling patterns
- Responsive layout with flex positioning
- Icon-based visual hierarchy

---

## Data Source

**Database Tables**:
- `burc_historical_revenue_detail` - Primary revenue data source

**API Endpoint**:
- `/api/analytics/burc/client-revenue` - Fetches and aggregates client revenue data

**Query Parameters**:
- `client` - Client name (required)
- `fuzzy` - Enable fuzzy name matching (default: true)

**Data Flow**:
1. `useClientRevenueTrend` → calls `useClientRevenue` hook
2. `useClientRevenue` → fetches from `/api/analytics/burc/client-revenue`
3. API queries `burc_historical_revenue_detail` table via Supabase
4. Data aggregated by fiscal year and revenue type
5. YoY growth calculated from latest and previous year totals
6. Results cached for 1 hour (in-memory cache)

---

## Component Structure

```
HealthBreakdown Component
├── Health Components (existing)
│   ├── NPS Score
│   ├── Compliance
│   ├── Working Capital
│   └── Actions Completion
├── Revenue Trend (NEW)
│   ├── Current Year Revenue
│   └── YoY Growth Indicator
└── Total Health Score
```

---

## Styling Patterns

### Colour Scheme
- **Positive Growth**: `text-green-600` with `TrendingUp` icon
- **Negative Growth**: `text-red-600` with `TrendingDown` icon
- **Flat Growth**: `text-gray-500` with `Minus` icon
- **Background**: `bg-gradient-to-br from-emerald-50 to-green-50`
- **Primary Text**: `text-emerald-700`
- **Secondary Text**: `text-emerald-600`

### Typography
- **Revenue Value**: `text-2xl font-bold text-emerald-700`
- **Year Label**: `text-xs text-emerald-600`
- **Growth Percentage**: `text-sm font-semibold` with dynamic colour
- **Growth Label**: `text-xs text-gray-500`

### Layout
- Flexbox container with `justify-between` for revenue value and growth indicator
- Rounded corners (`rounded-lg`)
- Padding: `p-4` for content area
- Border separator: `border-t border-gray-100`

---

## User Experience Improvements

1. **At-a-Glance Financial Context**: Users can now see revenue performance without navigating to financials page
2. **Integrated Health View**: Financial metrics alongside operational metrics (NPS, compliance, etc.)
3. **Quick Navigation**: Link to full financials view for detailed analysis
4. **Graceful Degradation**: Component only shows when revenue data is available
5. **Consistent Design**: Matches existing health card styling patterns

---

## Browser Compatibility

Tested and verified on:
- Chrome (latest)
- Safari (latest)
- Firefox (latest)
- Edge (latest)

---

## Performance Considerations

1. **API Caching**: Client revenue data cached for 1 hour at API level
2. **Lazy Loading**: Revenue data only fetched when component is rendered
3. **Conditional Rendering**: Revenue section only renders when data is available
4. **Optimised Queries**: Uses indexed database columns for fast lookups

---

## Future Enhancements

Potential improvements for future iterations:

1. **Mini Sparkline Chart**: Add visual trend chart in the revenue section
2. **Revenue Breakdown**: Show revenue by type (SW, PS, Maintenance, HW) on hover
3. **Multi-Year Comparison**: Display 3-year revenue trend
4. **Forecast Integration**: Show predicted revenue based on historical trends
5. **Currency Support**: Support multiple currencies beyond USD
6. **Custom Date Ranges**: Allow users to select different fiscal periods

---

## Testing Checklist

- [x] TypeScript compilation successful
- [x] Build process completed without errors
- [x] Component renders correctly with revenue data
- [x] Component gracefully handles missing revenue data
- [x] Trend indicators display correct colours (green/red/grey)
- [x] Link to financials page works correctly
- [x] Responsive layout verified
- [x] Existing health score components unaffected
- [x] No console errors or warnings

---

## Files Modified

1. `/src/hooks/useClientRevenueTrend.ts` - **Created**
2. `/src/app/(dashboard)/clients/[clientId]/components/HealthBreakdown.tsx` - **Updated**

---

## Dependencies

**Existing Dependencies**:
- `@/hooks/useClientRevenue` - Base hook for client revenue data
- `lucide-react` - Icon components
- `next/link` - Navigation component

**No new dependencies added**

---

## Related Components

- `ClientRevenueCard` - Full revenue display component (already exists)
- `FinancialHealthCard` - Financial metrics dashboard card
- `BURCExecutiveDashboard` - Executive financial overview

---

## API Reference

**Endpoint**: `GET /api/analytics/burc/client-revenue`

**Query Parameters**:
- `client` (required): Client name
- `fuzzy` (optional): Enable fuzzy matching (default: true)

**Response**:
```json
{
  "clientName": "Example Client",
  "found": true,
  "lifetimeRevenue": 5000000,
  "yearsActive": 5,
  "latestYear": 2025,
  "latestRevenue": 1200000,
  "yoyGrowth": 15.5,
  "cagr": 12.3,
  "yearlyBreakdown": [...],
  "revenueByType": {...},
  "trend": [...]
}
```

---

## Notes

- Revenue data sourced from BURC (Business Unit Revenue Contribution) tables
- Fuzzy name matching enabled by default to handle client name variations
- YoY growth threshold for colour coding: +5% (green), -5% (red), else grey
- Component only displays when health breakdown is expanded

---

## Rollback Instructions

If rollback is needed:

1. Remove the revenue trend section from `HealthBreakdown.tsx`:
   - Remove imports for `useClientRevenueTrend`, `DollarSign`, and `Link`
   - Remove the `revenueTrend` hook call
   - Remove the revenue trend section JSX (lines 249-294)

2. Optionally delete `/src/hooks/useClientRevenueTrend.ts` if no longer needed

3. Rebuild the application: `npm run build`

---

## Support

For questions or issues related to this enhancement, contact:
- Development Team
- Product Owner

---

**Enhancement Completed**: 2026-01-05
**Next Review**: 2026-02-05
