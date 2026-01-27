# Enhancement Report: Predictive Alerts Dashboard Section

**Date:** 2026-01-27
**Type:** Enhancement
**Status:** Completed & Deployed
**Author:** Claude Opus 4.5

---

## Overview

Added a new "Predictive Alerts" section to the Command Centre dashboard, providing users with a dedicated view of AI-generated predictive alerts across their client portfolio.

## Background

The `/api/alerts/predictive` endpoint was already generating and persisting predictive alerts (churn risk, engagement decline, health trajectory, etc.) to the database. However, these alerts were only visible on individual client profile pages via the Risk Signals card. Users needed a centralised view to see all predictive alerts across their portfolio.

## Implementation

### New Files Created

#### 1. `src/hooks/usePredictiveAlertsAll.ts`
Custom React hook for fetching portfolio-wide predictive alerts from the API.

**Key Features:**
- Fetches all active predictive alerts with pagination support
- Returns summary counts by severity and category
- Supports auto-refresh interval configuration
- Handles loading, error, and empty states

```typescript
export function usePredictiveAlertsAll(options: {
  limit?: number
  offset?: number
  autoRefreshInterval?: number
}): {
  alerts: PredictiveAlert[]
  summary: AlertSummary
  byCategory: AlertsByCategory
  pagination: PaginationInfo
  loading: boolean
  error: string | null
  refetch: () => Promise<void>
}
```

#### 2. `src/components/PredictiveAlertsSection.tsx`
Main component displaying the predictive alerts with filtering capabilities.

**Key Features:**
- Alert cards with severity indicators, client logos, category labels, and timestamps
- Expandable details showing description, metrics, recommendations, and client profile links
- Severity filtering (critical, high, medium, low)
- Category filtering (churn risk, health trajectory, engagement decline, peer underperformance, expansion opportunity)
- Summary stats bar showing total alerts and breakdown by severity
- Responsive two-column layout (single column on mobile)
- Refresh button for manual data refresh
- "Show more" pagination for large alert lists

### Modified Files

#### `src/components/ActionableIntelligenceDashboard.tsx`
- Added Bell icon import from lucide-react
- Imported `PredictiveAlertsSection` component
- Extended tab state type to include `'alerts'`
- Added "Predictive Alerts" option to mobile dropdown and desktop tab navigation
- Added tab content section rendering `<PredictiveAlertsSection />`

## Technical Details

### Alert Category Mapping

Database categories are mapped to user-friendly display labels:

| Database Category | Display Label |
|-------------------|---------------|
| `health_decline` | Health Trajectory |
| `churn_prediction` | Churn Risk |
| `engagement_gap` | Engagement Decline |
| `attrition_risk` | Peer Underperformance |
| `servicing_issue` | Expansion Opportunity |

### ESLint Compliance

The initial implementation triggered a `react-hooks/static-components` ESLint error because icons were being selected dynamically during render. This was resolved by creating `AlertCategoryIcon` as a proper React component with a switch statement:

```typescript
// Before (caused ESLint error):
const CategoryIcon = getCategoryIcon(alert.category)
<CategoryIcon className="..." />

// After (ESLint compliant):
function AlertCategoryIcon({ category, className }) {
  switch (category) {
    case 'health_decline': return <Activity className={className} />
    case 'churn_prediction': return <AlertTriangle className={className} />
    // ...
  }
}
<AlertCategoryIcon category={alert.category} className="..." />
```

### API Integration

The component fetches data from `GET /api/alerts/predictive` which returns:

```json
{
  "success": true,
  "data": {
    "alerts": [...],
    "alertCount": 13,
    "summary": {
      "critical": 0,
      "high": 5,
      "medium": 8,
      "low": 0
    },
    "byCategory": {
      "health_trajectory": 1,
      "churn_risk": 5,
      "engagement_decline": 5,
      "peer_underperformance": 1,
      "expansion_opportunity": 1
    },
    "pagination": {
      "total": 13,
      "offset": 0,
      "limit": 100,
      "hasMore": false
    }
  }
}
```

## User Interface

### Tab Navigation
- New "Predictive Alerts" tab added between "Priority Actions Matrix" and "Historical Revenue"
- Bell icon used for visual identification
- Active state indicated by purple underline (consistent with other tabs)

### Alert Card Design
- Colour-coded severity indicator (red=critical, orange=high, yellow=medium, blue=low)
- Client logo with fallback to initials
- Category label in uppercase with matching icon
- Relative timestamp (e.g., "17m ago", "9h ago")
- Expandable on click to show full details

### Filter Panel
- Collapsible filter section triggered by "Filters" button
- Severity chips with count badges
- Category chips with count badges
- "Clear all filters" link when filters are active
- Filter results indicator showing "Showing X of Y alerts"

## Testing

### Verified Functionality
- Tab navigation works on desktop and mobile (dropdown)
- Alerts load from API with correct data
- Alert cards expand/collapse correctly
- Severity filtering works (reduces displayed alerts)
- Category filtering works (reduces displayed alerts)
- Combined filters work correctly
- Refresh button fetches fresh data
- "View Client Profile" links navigate correctly
- Empty state displays when no alerts exist
- Error state displays when API fails
- Loading spinner shows during data fetch

### Test Data
Tested with 13 predictive alerts:
- 5 Churn Risk alerts (Epworth Healthcare, Barwon Health Australia, Albury Wodonga Health, Gippsland Health Alliance, Test Client)
- 5 Engagement Decline alerts (same clients)
- 1 Health Trajectory alert
- 1 Peer Underperformance alert
- 1 Expansion Opportunity alert

## Screenshots

The Predictive Alerts section displays:
- Summary bar: "13 active alerts • 5 high • 8 medium"
- Filter chips for severity and category
- Two-column grid of alert cards
- Expanded alert showing metrics and recommendations

---

## Related Files

- `src/hooks/usePredictiveAlerts.ts` - Existing client-specific hook (unchanged)
- `src/lib/predictive-alert-detection.ts` - Alert generation logic (unchanged)
- `src/app/api/alerts/predictive/route.ts` - API endpoint (unchanged)
- `docs/bug-reports/2026-01-26-predictive-alerts-persistence-fix.md` - Previous fix for alert persistence



