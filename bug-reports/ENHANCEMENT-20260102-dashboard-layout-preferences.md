# Enhancement Report: Dashboard Layout Preferences

**Date:** 2 January 2026
**Type:** Enhancement
**Status:** Completed
**Priority:** Medium

## Summary
Implemented dashboard layout preferences so the toggles in User Preferences actually control which sections are visible on the Command Centre dashboard.

## Problem
The UserPreferencesModal had toggles for:
- **Command Centre Overview** (`showCommandCentre`)
- **Smart Insights & Alerts** (`showSmartInsights`)
- **ChaSen AI Assistant** (`showChaSen`)

However, these toggles were stored in user preferences but never applied - the dashboard always showed all sections regardless of user settings.

## Solution
Connected the preference toggles to the actual dashboard rendering:

1. **ActionableIntelligenceDashboard** - Added `layoutPreferences` prop to control visibility
2. **DataInsightsSection** - Added `showChaSen` and `showSmartInsights` props
3. **Main Dashboard Page** - Passes user's layout preferences from profile

## Changes Implemented

### 1. ActionableIntelligenceDashboard.tsx

Added interface and props:
```typescript
interface DashboardLayoutPreferences {
  showCommandCentre: boolean
  showSmartInsights: boolean
  showChaSen: boolean
}

interface ActionableIntelligenceDashboardProps {
  clientFilter?: 'my-clients' | 'all-clients'
  layoutPreferences?: DashboardLayoutPreferences // NEW
}
```

Conditional rendering:
```tsx
{/* Priority Matrix (Command Centre) */}
{layoutPreferences.showCommandCentre && (
  <MatrixProvider ...>
    <PriorityMatrixMultiView ... />
  </MatrixProvider>
)}

{/* Data Insights Section */}
{(layoutPreferences.showSmartInsights || layoutPreferences.showChaSen) && (
  <DataInsightsSection
    showChaSen={layoutPreferences.showChaSen}
    showSmartInsights={layoutPreferences.showSmartInsights}
  />
)}

{/* Fallback message when all sections hidden */}
{!layoutPreferences.showCommandCentre &&
  !layoutPreferences.showSmartInsights &&
  !layoutPreferences.showChaSen && (
    <div className="bg-gray-50 ...">
      All dashboard sections are hidden. Go to Settings → Dashboard Layout...
    </div>
  )}
```

### 2. DataInsightsWidgets.tsx

Updated DataInsightsSection to accept visibility props:
```typescript
interface DataInsightsSectionProps {
  showChaSen?: boolean
  showSmartInsights?: boolean
}

export function DataInsightsSection({
  showChaSen = true,
  showSmartInsights = true,
}: DataInsightsSectionProps) {
  // Dynamic grid columns based on visible widgets
  const visibleWidgets = [showChaSen, showSmartInsights, showSmartInsights, showSmartInsights]
    .filter(Boolean).length

  return (
    <div className={`grid ${gridCols} gap-4`}>
      {showChaSen && <ChaSenInsightsWidget />}
      {showSmartInsights && (
        <>
          <PortfolioInitiativesWidget />
          <TopicsTrendingWidget />
          <HealthAlertsWidget />
        </>
      )}
    </div>
  )
}
```

### 3. Main Dashboard Page (page.tsx)

Passes layout preferences from user profile:
```tsx
<ActionableIntelligenceDashboard
  clientFilter={clientFilter}
  layoutPreferences={profile?.preferences?.dashboardLayout}
/>
```

## User Flow

1. User navigates to **Settings** (via profile dropdown)
2. Clicks **Dashboard Layout** tab
3. Toggles visibility for:
   - Command Centre Overview (Priority Matrix)
   - Smart Insights & Alerts (Portfolio, Topics, Health widgets)
   - ChaSen AI Assistant
4. Changes are saved to Supabase `user_preferences` table
5. Dashboard immediately reflects the changes

## Files Modified

| File | Change |
|------|--------|
| `src/components/ActionableIntelligenceDashboard.tsx` | Added layoutPreferences prop and conditional rendering |
| `src/components/dashboard/DataInsightsWidgets.tsx` | Added props to DataInsightsSection |
| `src/app/(dashboard)/page.tsx` | Passes layout preferences to dashboard |

## Technical Notes

- Default behaviour: All sections visible (backwards compatible)
- Preferences stored in Supabase `user_preferences.dashboard_layout`
- Dynamic grid adjustment when widgets are hidden
- Fallback message if user hides all sections

## Testing

- **TypeScript compilation**: PASSED
- **Visual verification**: Toggles now control section visibility
- **Default behaviour**: All sections shown when no preferences set

## Mapping

| Preference Toggle | Dashboard Section |
|------------------|-------------------|
| `showCommandCentre` | Priority Matrix (all quadrants) |
| `showSmartInsights` | Portfolio Initiatives, Topics Trending, Health Alerts |
| `showChaSen` | ChaSen AI Insights widget |
