# Bug Report: BURC Page Client Health Data Not Using Corrected Compliance

**Date:** 10 January 2026
**Severity:** Medium
**Status:** Fixed and Deployed

## Summary

The BURC Performance page was displaying client health data using the raw `client_health_summary` materialised view, which uses uncorrected compliance percentages. This resulted in health scores that did not match the segment-change-corrected values shown elsewhere in the application.

## Symptoms

1. Health scores on the BURC dashboard could differ from those shown on the Client Portfolio page
2. "Requires Attention" items used uncorrected health status classifications
3. Client Health Summary widget displayed health scores calculated from raw compliance data
4. Inconsistent health status classifications between BURC and other pages

## Root Cause

The `BURCExecutiveDashboard` component was directly querying the `client_health_summary` view for client health data:

```typescript
// Before: Direct query to materialised view
const { data: healthData } = await supabase
  .from('client_health_summary')
  .select('id, client_name, health_score, nps_score, status, days_since_last_meeting')
  .neq('client_name', 'Internal')
  .order('health_score', { ascending: true, nullsFirst: false })
```

This view uses the raw `compliance_percentage` from the `segmentation_event_compliance` table, which does not account for:
- Segment changes requiring recalculation
- Proper compliance deadline handling
- Correct proportional calculations for on-target event types

## Solution

Integrated the `ClientPortfolioContext` to provide corrected client health data:

### 1. Component Structure Change

Wrapped the dashboard content in `ClientPortfolioProvider`:

```typescript
// After: Wrapper provides corrected data
export default function BURCExecutiveDashboard() {
  return (
    <ClientPortfolioProvider>
      <BURCDashboardContent />
    </ClientPortfolioProvider>
  )
}
```

### 2. Context Integration

Replaced direct Supabase queries with context data:

```typescript
// Using context for corrected compliance data
const {
  clients: portfolioClients,
  isLoading: clientHealthLoading,
  stats: portfolioStats,
} = useClientPortfolio()
```

### 3. Health Data Transformation

Updated the `transformedClientHealth` derivation to use corrected values:

```typescript
const transformedClientHealth: ClientHealthData[] = useMemo(() => {
  return portfolioClients
    .filter(c => c.name !== 'Internal')
    .map(c => ({
      name: c.name,
      healthScore: c.calculated_health_score,  // Uses corrected compliance
      npsScore: c.nps_score,
      status: c.health_status,  // Already calculated with corrected compliance
      daysSinceLastMeeting: c.days_since_last_meeting,
    }))
    .sort((a, b) => (a.healthScore ?? 100) - (b.healthScore ?? 100))
}, [portfolioClients])
```

### 4. Attention Items Update

Updated the "Requires Attention" panel to use corrected health status:

```typescript
// Using corrected health status from context
portfolioClients
  .filter(c => c.name !== 'Internal' && c.health_status === 'critical')
  .forEach(c => {
    items.push({
      id: `health-${c.name}`,
      type: 'churn-risk',
      severity: 'critical',
      clientName: c.name,
      message: `Critical health score: ${c.calculated_health_score || 'N/A'}`,
    })
  })
```

## What Was Preserved

BURC-specific financial metrics remain unchanged and continue to use direct queries:
- `burc_executive_summary` - NRR, GRR, Rule of 40, ARR
- `burc_attrition_summary` - Churn risk data
- `burc_contracts` - Renewal information
- `burc_pipeline_detail` - Pipeline breakdown
- `burc_historical_revenue_detail` - ARR by client
- Aging accounts data via `useAgingAccounts` hook

## Files Changed

- `/src/components/burc/BURCExecutiveDashboard.tsx`
  - Added `ClientPortfolioProvider` and `useClientPortfolio` imports
  - Renamed main function to `BURCDashboardContent`
  - Added wrapper `BURCExecutiveDashboard` component with provider
  - Removed `clientHealthData` state and direct Supabase query
  - Updated `transformedClientHealth` to use `portfolioClients`
  - Updated `attentionItems` to use corrected health data
  - Updated `recentActivityData` to use `portfolioClients` count
  - Updated loading state to include `clientHealthLoading`

## Testing

1. **Build Verification:** `npm run build` passes with no TypeScript errors
2. **Manual Testing Required:**
   - Verify BURC dashboard loads correctly
   - Verify client health scores match Client Portfolio page
   - Verify "Requires Attention" items show correct critical clients
   - Verify all BURC financial metrics display correctly
   - Verify loading states work properly

## Related Documentation

- `/docs/design/CLIENT-PORTFOLIO-CONTEXT.md` - Context design and usage
- `/docs/bug-reports/BUG-REPORT-20251216-health-score-compliance-mismatch.md` - Original compliance fix
