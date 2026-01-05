# BURC PS Margins Panel Component

## Overview

The `BURCPSMarginsPanel` component provides comprehensive visualisation and analysis of Professional Services (PS) margins, utilisation rates, and project profitability metrics for the BURC (Business Unit Review Committee) dashboard.

## Features

### Key Metrics Display
- **Overall PS Margin %** - Current margin percentage with target threshold (>25%)
- **Utilisation Rate %** - Current utilisation with target threshold (>75%)
- **Average Project Profitability** - Mean margin across all active projects
- **Revenue per Consultant** - Monthly average revenue per consultant

### Visualisations

1. **Margin Gauge Chart**
   - Semi-circular gauge showing current margin vs. 100%
   - Colour-coded thresholds (Green ≥25%, Amber 15-24%, Red <15%)

2. **Project Distribution Pie Chart**
   - Breakdown of projects by status (Profitable, Break-even, Loss-making)
   - Visual representation of project health distribution

3. **12-Month Trend Line Chart**
   - Dual-axis chart showing:
     - Margin % over time
     - Utilisation % over time
     - Revenue trend (secondary axis)

4. **Utilisation Progress Bar**
   - Visual progress bar showing current utilisation vs. target
   - Colour-coded thresholds (Green ≥75%, Amber 60-74%, Red <60%)

### Data Tables

**Projects by Profitability**
- Top 10 projects ranked by margin percentage
- Columns: Project, Client, Revenue, Cost, Margin, Margin %, Status
- Status badges: Profitable (green), Break-even (amber), Loss-making (red)

## Data Sources

### Supabase Tables

1. **`burc_ps_margins`**
   - Columns: `fiscal_year`, `month_num`, `client_name`, `project_name`, `revenue`, `cost`, `margin`, `margin_percent`
   - Purpose: Project-level PS margin data

2. **`burc_ps_utilisation`**
   - Columns: `year`, `month`, `total_available_hours`, `billable_hours`, `non_billable_hours`, `utilisation_rate`, `target_utilisation`, `billable_headcount`, `avg_bill_rate`, `revenue_per_consultant`, `backlog_hours`, `backlog_value`
   - Purpose: PS team utilisation and productivity metrics

## Thresholds

### Margin Thresholds
- **Green (On Target)**: ≥25%
- **Amber (Below Target)**: 15-24%
- **Red (Critical)**: <15%

### Utilisation Thresholds
- **Green (On Target)**: ≥75%
- **Amber (Below Target)**: 60-74%
- **Red (Critical)**: <60%

## Usage

### Basic Implementation

```tsx
import { BURCPSMarginsPanel } from '@/components/burc'

export default function PSMarginsPage() {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-6">Professional Services Margins</h1>
      <BURCPSMarginsPanel />
    </div>
  )
}
```

### Custom Height

```tsx
import { BURCPSMarginsPanel } from '@/components/burc'

export default function CompactView() {
  return (
    <div className="grid grid-cols-2 gap-4">
      <BURCPSMarginsPanel height={350} />
    </div>
  )
}
```

### In BURC Executive Dashboard

```tsx
import { BURCExecutiveDashboard, BURCPSMarginsPanel } from '@/components/burc'

export default function ExecutiveDashboard() {
  return (
    <div className="space-y-6">
      <BURCExecutiveDashboard />

      <div className="grid grid-cols-1 gap-6">
        <BURCPSMarginsPanel />
      </div>
    </div>
  )
}
```

## Hook: useBURCPSMetrics

The component uses the `useBURCPSMetrics` hook to fetch and process data.

### Hook Interface

```typescript
interface PSMetricsSummary {
  overall_margin_percent: number
  current_utilisation_rate: number
  avg_project_profitability: number
  revenue_per_consultant: number
  total_ps_revenue: number
  total_projects: number
  profitable_projects: number
  unprofitable_projects: number
  target_margin: number
  target_utilisation: number
}

interface PSProjectProfitability {
  project_name: string
  client_name: string
  revenue: number
  cost: number
  margin: number
  margin_percent: number
  status: 'profitable' | 'break-even' | 'loss-making'
}

interface PSMarginTrend {
  period: string
  margin_percent: number
  utilisation_rate: number
  revenue: number
}

function useBURCPSMetrics(): {
  summary: PSMetricsSummary | null
  projects: PSProjectProfitability[]
  trends: PSMarginTrend[]
  loading: boolean
  error: string | null
  refresh: () => Promise<void>
}
```

### Direct Hook Usage

```tsx
import { useBURCPSMetrics } from '@/hooks/useBURCPSMetrics'

export default function CustomPSView() {
  const { summary, projects, trends, loading, error, refresh } = useBURCPSMetrics()

  if (loading) return <div>Loading...</div>
  if (error) return <div>Error: {error}</div>
  if (!summary) return <div>No data available</div>

  return (
    <div>
      <h2>PS Margin: {summary.overall_margin_percent.toFixed(1)}%</h2>
      <h3>Utilisation: {summary.current_utilisation_rate.toFixed(1)}%</h3>
      <button onClick={refresh}>Refresh Data</button>

      <ul>
        {projects.slice(0, 5).map(p => (
          <li key={p.project_name}>
            {p.project_name}: {p.margin_percent.toFixed(1)}%
          </li>
        ))}
      </ul>
    </div>
  )
}
```

## Styling

The component uses Tailwind CSS and follows the BURC design system:

- **Background**: White/Grey-900 (dark mode)
- **Borders**: Grey-200/Grey-700 (dark mode)
- **Text**: Grey-900/White (dark mode)
- **Chart Colours**:
  - Blue (#3B82F6): Margin trend
  - Green (#10B981): Utilisation trend, Profitable status
  - Amber (#F59E0B): Revenue trend, Break-even status
  - Red (#EF4444): Loss-making status

## Error Handling

The component handles three states:

1. **Loading**: Shows spinner with blue colour
2. **Error**: Shows error message in red background
3. **No Data**: Shows grey message indicating no data available

## Performance Considerations

- Data is fetched once on mount
- Calculations are performed client-side after data fetch
- Projects table shows top 10 only (with indication if more exist)
- Charts use responsive containers for dynamic sizing

## Accessibility

- Semantic HTML structure
- Colour-blind friendly status indicators (uses icons + colours)
- ARIA labels on interactive elements
- Responsive design for mobile/tablet/desktop

## Browser Compatibility

- Modern browsers (Chrome, Firefox, Safari, Edge)
- Requires JavaScript enabled
- Recharts library for visualisations

## Dependencies

- `@/hooks/useBURCPSMetrics`: Custom hook for data fetching
- `recharts`: Charting library
- `lucide-react`: Icon library
- `@supabase/supabase-js`: Database client

## Related Components

- `BURCExecutiveDashboard`: Main BURC dashboard
- `BURCConcentrationRisk`: Revenue concentration analysis
- `BURCRevenueTrendChart`: Revenue trend visualisation
- `BURCNRRTrendChart`: Net Revenue Retention trends

## Migration Notes

If you need to add custom fields to the PS margins tracking:

1. Update the database schema in `burc_ps_margins` table
2. Update the `PSMarginData` interface in `useBURCPSMetrics.ts`
3. Update calculation logic in the hook
4. Update component to display new fields

## Support

For issues or questions:
- Check Supabase connection and RLS policies
- Verify data exists in `burc_ps_margins` and `burc_ps_utilisation` tables
- Check browser console for errors
- Review hook return values for error messages

## Version History

- **v1.0.0** (2026-01-05): Initial release
  - Core margin and utilisation metrics
  - Gauge and pie charts
  - 12-month trend analysis
  - Top 10 projects table
  - Threshold-based colour coding
