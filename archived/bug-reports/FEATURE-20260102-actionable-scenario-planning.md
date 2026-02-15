# Feature: Actionable Scenario Planning with Business Context

**Date**: 2 January 2026
**Status**: Implemented
**Priority**: High
**Component**: BURC Performance > CSI Ratios > Analysis > Scenario Planning

## Overview

Enhanced scenario planning to generate specific, actionable recommendations based on real business data from clients, NPS, compliance, and financial sources. Also added probability percentages to all scenario types.

## User Request

> "Create real and impactful scenario planning actions to meet/exceed targets. Be very specific and use real-data that is provided or search the internet leverage ChaSen AI."

> "What is the probability of the most likely scenario? Add this to the data/pages"

## Implementation

### New Types Added

```typescript
export interface ActionableRecommendation {
  id: string
  priority: 'critical' | 'high' | 'medium' | 'low'
  title: string
  description: string
  metric?: string // e.g., "$2.3M ARR at risk"
  deadline?: string // e.g., "By end of Q1 2026"
  owner?: string // e.g., "CSE Team"
  actionType: 'meeting' | 'review' | 'escalation' | 'initiative' | 'training' | 'financial'
  linkedClients?: string[]
  expectedImpact?: string
}

export interface BusinessContext {
  clients?: Array<{
    name: string
    healthScore: number
    npsScore: number | null
    lastMeetingDays: number | null
    compliancePercent: number
    segment?: string
    status?: 'healthy' | 'at-risk' | 'critical'
  }>
  nps?: { overallScore: number; detractorCount: number; promoterCount: number; responseRate: number }
  compliance?: { overdueQBRs: number; overdueExecutiveReviews: number; clientsBelowTarget: string[] }
  financials?: { totalARR: number; atRiskARR: number; avgAgingDays: number; clientsOver90Days: string[] }
  currentQuarter?: string
  currentYear?: number
}
```

### Modified Files

1. **`src/lib/scenario-planning.ts`**
   - Added `ActionableRecommendation` and `BusinessContext` interfaces
   - Created ratio-specific action generators:
     - `generatePSActions()` - PS ratio actions (pricing review, utilisation, client expansion)
     - `generateSalesActions()` - Sales actions (pipeline, CAC, promoter referrals)
     - `generateMaintenanceActions()` - Maintenance actions (churn prevention, at-risk outreach, detractor conversion)
     - `generateRDActions()` - R&D actions (prioritisation, monetisable features, enterprise discovery)
     - `generateGAActions()` - G&A actions (cost audit, automation, collections)
   - Updated probability text for Most Likely scenario to "~80% probability"

2. **`src/components/csi/ScenarioPlanning.tsx`**
   - Added `ActionCard` component with priority-based styling (critical/high/medium/low)
   - Added `ActionTypeIcon` component for visual action type indicators
   - Added `businessContext` prop support
   - Updated legend to show probability percentages for all scenarios
   - Displays action counts (critical/total) in ratio row headers

3. **`src/components/csi/TrendAnalysisPanel.tsx`**
   - Added `BusinessContext` import
   - Added `businessContext` prop to interface
   - Passes `businessContext` to `ScenarioPlanning` component

4. **`src/components/csi/CSITabsContainer.tsx`**
   - Added imports for `useClients`, `useNPSData`, `useAgingAccounts` hooks
   - Created `businessContext` useMemo that transforms hook data into context format
   - Passes `businessContext` to `TrendAnalysisPanel`

## How It Works

### Data Flow

```
useClients() + useNPSData() + useAgingAccounts()
        ↓
CSITabsContainer builds businessContext
        ↓
TrendAnalysisPanel receives businessContext
        ↓
ScenarioPlanning generates actions with createRatioScenarios()
        ↓
ActionCard displays priority, metrics, deadlines, owners, linked clients
```

### Action Generation Logic

Each ratio has specific action generators that:
1. Check if base scenario meets target
2. If NOT meeting target: generate improvement actions based on gap size
3. If meeting target: generate maintenance/growth actions
4. Uses business context to add specific client/NPS/financial data

### Example Actions Generated

**Maintenance Ratio (below target)**:
- 🔴 **Critical**: "Executive Outreach: 3 At-Risk Clients" - $2.1M ARR at risk
- 🟠 **High**: "Address 5 NPS Detractors" - Convert within 48 hours
- 🟠 **High**: "Launch Churn Prevention Programme" - Target <5% annual churn

**G&A Ratio (above target)**:
- 🔴 **Critical**: "G&A Cost Audit" - Reduce by 12% of revenue within 30 days
- 🟠 **High**: "Collections Focus: 4 Clients >90 Days" - Improve cash flow
- 🟠 **High**: "Process Automation Initiative" - Reduce headcount dependency

## Probability Explanation

The three scenarios represent probability distribution from the 80% prediction interval:

| Scenario | Probability | Description |
|----------|-------------|-------------|
| Best Case | ~10% | Upper bound - 10% chance of exceeding |
| Most Likely | ~80% | Central estimate - 80% of outcomes near this value |
| Worst Case | ~10% | Lower bound - 10% chance of falling below |

Note: For G&A ratio (where lower is better), best/worst cases are inverted.

## UI Features

1. **Action Priority Badges** - Colour-coded: red (critical), orange (high), yellow (medium), grey (low)
2. **Action Type Icons** - Visual indicators: meeting, review, escalation, initiative, training, financial
3. **Metrics Display** - Shows specific data like "$2.1M ARR at risk" or "12% improvement needed"
4. **Linked Clients** - Shows affected clients with external link icons
5. **Expected Impact** - Quantified outcomes like "+0.3 ratio improvement"
6. **Action Counts** - Header shows "3 critical, 7 total actions"

## Testing

1. Navigate to **BURC Performance > CSI Ratios > Analysis** tab
2. Scroll to **Scenario Planning** section
3. Verify probability percentages show:
   - Best Case (~10% probability)
   - Most Likely (~80% probability)
   - Worst Case (~10% probability)
4. Expand a ratio row and verify:
   - Action cards display with priority colours
   - Metrics show real data from clients/NPS/aging
   - Linked clients are clickable
   - Expected impact is meaningful

## Dependencies

- `useClients` hook for client health data
- `useNPSData` hook for NPS summary and detractor counts
- `useAgingAccounts` hook for financial/aging data
- Requires `includeAdvancedML=true` for prediction intervals
