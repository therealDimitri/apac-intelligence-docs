# Feature: Business Unit Page Real Compliance/Health Data Integration

## Date
2026-01-10

## Summary
Integrated `ClientPortfolioContext` into the Business Unit Planning page to replace mock/hardcoded compliance and health score data with real, dynamically calculated values from enriched client data.

## Problem Statement
The Business Unit Planning page at `/planning/business-unit` was fetching data from `/api/planning/financials/business-unit` which returned hardcoded mock data for:
- KPI compliance rate
- KPI health score
- Per-segment compliance rates
- Per-segment average health scores

This meant the displayed values did not reflect actual client data from the database.

## Solution

### Changes Made

1. **Added Context Integration**
   - Imported `ClientPortfolioProvider` and `useClientPortfolio` from `@/contexts/ClientPortfolioContext`
   - Wrapped the page component with `ClientPortfolioProvider`
   - Created inner component `BusinessUnitPlanningContent` to access context

2. **Added BU Client Filtering**
   - Created `BU_CLIENT_PATTERNS` constant mapping Business Units to client name patterns (ANZ, SEA, Greater China)
   - Implemented `filterClientsByBU()` function to filter enriched clients by BU
   - Pattern matching uses lowercase comparison for case-insensitive matching

3. **Real Metrics Calculation**
   - Implemented `calculateBUMetrics()` function that calculates:
     - `complianceRate`: Average of `corrected_compliance_percentage` across BU clients
     - `healthScore`: Average of `calculated_health_score` across BU clients
     - `segmentDistribution`: Per-segment breakdown with real compliance/health values
   - Added `normaliseSegment()` function to standardise segment names (Enterprise, Mid-Market, SMB)

4. **Data Enrichment**
   - Created memoised `enrichedData` object that merges API data with real metrics
   - API data retained for: ARR, territories, APAC contribution, strategic initiatives
   - Real data used for: compliance rate, health score, segment compliance/health

5. **Loading States**
   - Combined loading state from both API fetch and portfolio context
   - Refresh button now triggers both data sources
   - Loading indicators show when either source is loading

### Files Modified
- `/src/app/(dashboard)/planning/business-unit/page.tsx`

### Key Implementation Details

```typescript
// BU Client Filtering Pattern
const BU_CLIENT_PATTERNS: Record<BusinessUnit, string[]> = {
  ANZ: ['barwon', 'epworth', 'wa health', ...],
  SEA: ['mount alvernia', 'ncs', 'singapore', ...],
  'Greater China': ['hong kong', 'taiwan', 'china', ...],
}

// Enriched Data Merge Logic
const enrichedData = useMemo((): BusinessUnitData | null => {
  if (!data) return null

  // Override KPIs with real data
  const enrichedKPIs = {
    ...data.kpis,
    complianceRate: realBUMetrics.complianceRate > 0 ? realBUMetrics.complianceRate : data.kpis.complianceRate,
    healthScore: realBUMetrics.healthScore > 0 ? realBUMetrics.healthScore : data.kpis.healthScore,
  }

  // Merge segment data...
}, [data, realBUMetrics])
```

## Testing
- Build passes with zero TypeScript errors
- Page loads correctly with context provider
- BU selector changes trigger recalculation of real metrics
- Refresh button updates both API data and portfolio data

## Impact
- **KPI Scorecard**: Now shows real compliance rate and health score
- **Segment Distribution**: Now shows real compliance and health per segment
- **Data Source**: Uses `corrected_compliance_percentage` from ClientPortfolioContext which handles segment change recalculation

## Notes
- ARR/financial data still comes from API (not available in enriched clients)
- Fallback to API data when real data is unavailable (e.g., 0 clients matched)
- Client-to-BU mapping uses pattern matching on client names; may need refinement for production use
