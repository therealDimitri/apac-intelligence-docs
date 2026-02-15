# Feature: AI Components Integration for Planning Pages

**Date:** 2026-01-09
**Type:** Feature Implementation
**Status:** Completed

## Summary

Integrated AI-powered components into the Business Unit and APAC planning pages to provide intelligent insights, risk analysis, and strategic recommendations.

## Changes Made

### New Components Created

#### 1. BULevelAIInsights Component
**Location:** `src/components/planning/BULevelAIInsights.tsx`

Features:
- AI-powered summary specific to each Business Unit (ANZ, SEA, Greater China)
- Risk summary cards with severity classification and ARR impact
- Expansion opportunity tracker with probability and value
- Strategic recommendations categorised by type (growth, retention, efficiency, compliance)
- Key strengths and areas of concern analysis
- Quarterly outlook projections

Props interface:
```typescript
interface BULevelAIInsightsProps {
  businessUnit: string
  risks?: BURiskItem[]
  opportunities?: BUOpportunity[]
  recommendations?: BUStrategicRecommendation[]
  aiSummary?: BUAISummary
  isLoading?: boolean
  onRefresh?: () => Promise<void>
  onViewRiskDetails?: (risk: BURiskItem) => void
  onViewOpportunityDetails?: (opportunity: BUOpportunity) => void
  className?: string
}
```

#### 2. APACLevelAIInsights Component
**Location:** `src/components/planning/APACLevelAIInsights.tsx`

Features:
- APAC-wide executive summary with quarterly forecast
- BU performance grid showing progress against targets
- Regional insights panel with trend, risk, opportunity, and anomaly detection
- Cross-BU recommendations for alignment, resource sharing, best practices, and risk mitigation
- Strategic priorities and risk alerts
- Interactive expansion with detailed data points

Props interface:
```typescript
interface APACLevelAIInsightsProps {
  buPerformance?: BUPerformance[]
  regionalInsights?: RegionalInsight[]
  recommendations?: CrossBURecommendation[]
  apacSummary?: APACSummary
  isLoading?: boolean
  onRefresh?: () => Promise<void>
  onViewBUDetails?: (bu: string) => void
  className?: string
}
```

### Pages Updated

#### Business Unit Planning Page
**Location:** `src/app/(dashboard)/planning/business-unit/page.tsx`

Additions:
- Imported `BULevelAIInsights` and `NextBestActionsPanel` components
- Added AI-related state management for risks, opportunities, recommendations, and summaries
- Implemented `generateAIInsights` callback with BU-specific mock data generation
- Added `handleViewRiskDetails` and `handleViewOpportunityDetails` handlers
- Integrated AI section after existing dashboard components
- Added NextBestActionsPanel for BU-level recommended actions

#### APAC Planning Command Centre
**Location:** `src/app/(dashboard)/planning/apac/page.tsx`

Additions:
- Imported `APACLevelAIInsights` and `NextBestActionsPanel` components
- Added AI-related state for BU performance, regional insights, cross-BU recommendations, and APAC summary
- Implemented `generateAIInsights` callback with regional mock data
- Added `handleViewBUDetails` handler for navigation
- Integrated AI section (Row 6) after Risk and Planning Status section
- Added APAC-level NextBestActionsPanel with 15 action limit

## Technical Details

### State Management
Both pages use local state management with React hooks:
- `useState` for AI data storage
- `useCallback` for memoised insight generation functions
- `useEffect` for loading AI insights after main data loads

### Loading States
- Separate `aiInsightsLoading` state to manage AI component loading independently
- Loading spinners and skeleton states in AI components
- Graceful fallback when no data is available

### Data Flow
1. Page loads main planning data from Supabase
2. After main data loads, `generateAIInsights` is triggered
3. AI insights are generated (currently mock data, designed for API integration)
4. Components render with generated insights

### Future API Integration Points
The `generateAIInsights` functions in both pages are designed for easy API integration:
- Replace mock data generation with API calls to `/api/planning/ai/insights`
- Use `usePlanningAI` hook for client-level insights
- Integrate with existing `usePlanningInsights` hook for aggregated views

## Component Dependencies

### Existing Components Used
- `NextBestActionsPanel` from `@/components/planning/NextBestActionsPanel`
- Various Lucide icons for UI elements
- `cn` utility from `@/lib/utils` for conditional classes

### New Type Exports
Both new components export their interfaces for use elsewhere:
- `BURiskItem`, `BUOpportunity`, `BUStrategicRecommendation`, `BUAISummary`
- `BUPerformance`, `RegionalInsight`, `CrossBURecommendation`, `APACSummary`

## Testing

Verified:
- TypeScript compilation passes without errors
- Component imports resolve correctly
- State management works as expected
- Loading states display properly

## Files Changed

| File | Change Type |
|------|-------------|
| `src/components/planning/BULevelAIInsights.tsx` | Created |
| `src/components/planning/APACLevelAIInsights.tsx` | Created |
| `src/app/(dashboard)/planning/business-unit/page.tsx` | Modified |
| `src/app/(dashboard)/planning/apac/page.tsx` | Modified |

## UI/UX Notes

- AI insights sections use consistent purple/indigo gradient theming matching ChaSen branding
- Sparkles icon used consistently to indicate AI-generated content
- Collapsible sections for detailed data exploration
- Priority-based colour coding (critical=red, high=amber, medium=blue/gray)
- Responsive grid layouts for different screen sizes
