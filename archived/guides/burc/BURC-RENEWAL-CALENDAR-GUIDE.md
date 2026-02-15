# BURC Contract Renewal Calendar - User Guide

**Created**: 5 January 2026
**Component**: BURCRenewalCalendar, RenewalUpcomingWidget
**Author**: Claude Code
**Version**: 1.0.0

---

## Overview

The BURC Renewal Calendar provides comprehensive visibility into upcoming contract renewals with risk-based prioritisation and multiple viewing modes. This guide covers implementation, features, and best practices.

## Components

### 1. BURCRenewalCalendar (Full Page Component)

Comprehensive contract renewal management interface with calendar and list views.

**Location**: `/src/components/burc/BURCRenewalCalendar.tsx`

**Features**:
- **Dual View Modes**: Calendar view (monthly cards) and List view (detailed table)
- **Risk Assessment**: Automatic risk scoring based on renewal timeline
- **Flexible Filtering**: Filter by period (30/60/90/180/365 days), risk level, and custom sorting
- **Summary Statistics**: Real-time aggregation of contracts, values, and risk counts
- **Colour-Coded Alerts**: Visual indicators for high-risk renewals
- **Client Details**: Full client names, contract counts, and values per renewal period

**Usage Example**:

```tsx
import { BURCRenewalCalendar } from '@/components/burc'

export default function RenewalsPage() {
  return (
    <div className="container mx-auto p-6">
      <BURCRenewalCalendar />
    </div>
  )
}
```

### 2. RenewalUpcomingWidget (Dashboard Widget)

Compact widget showing the next 5 critical renewals, optimised for dashboard placement.

**Location**: `/src/components/burc/RenewalUpcomingWidget.tsx`

**Features**:
- **Compact Display**: Shows top 5 upcoming renewals in 90-day window
- **Quick Stats**: Total contracts, value, and high-risk count at a glance
- **Risk Indicators**: Visual dots and badges for priority levels
- **Auto-Refresh**: Built-in refresh functionality
- **Loading State**: Skeleton component for smooth loading experience

**Usage Example**:

```tsx
import { RenewalUpcomingWidget } from '@/components/burc'

// Dashboard implementation
<div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
  <RenewalUpcomingWidget limit={5} />
  {/* Other dashboard widgets */}
</div>

// With Suspense boundary
<Suspense fallback={<RenewalUpcomingWidgetSkeleton />}>
  <RenewalUpcomingWidget />
</Suspense>
```

### 3. useBURCRenewals Hook

Custom React hook for fetching and managing renewal data.

**Location**: `/src/hooks/useBURCRenewals.ts`

**Features**:
- **Smart Filtering**: Apply period, risk level, and sorting filters
- **Enriched Data**: Automatic calculation of days until renewal and risk levels
- **Summary Stats**: Real-time aggregation of renewal metrics
- **Error Handling**: Comprehensive error states and retry logic
- **Refresh Function**: Manual data refresh capability

**Usage Example**:

```tsx
import { useBURCRenewals } from '@/hooks/useBURCRenewals'

function MyComponent() {
  const { renewals, loading, error, stats, refresh } = useBURCRenewals({
    period: 90,
    riskLevel: 'red',
    sortBy: 'date',
    sortDirection: 'asc',
  })

  if (loading) return <LoadingSpinner />
  if (error) return <ErrorMessage error={error} onRetry={refresh} />

  return (
    <div>
      <h2>High Risk Renewals: {stats.byRisk.red}</h2>
      {renewals.map(renewal => (
        <RenewalCard key={renewal.renewal_period} renewal={renewal} />
      ))}
    </div>
  )
}
```

## Data Model

### BURCRenewal Interface

```typescript
interface BURCRenewal {
  renewal_year: number              // Year of renewal
  renewal_month: number             // Month of renewal (1-12)
  renewal_period: string            // Formatted period (e.g., "Jan 2026")
  contract_count: number            // Number of contracts renewing
  total_value_usd: number           // Total contract value in USD
  total_value_aud: number           // Total contract value in AUD
  clients: string                   // Comma-separated client names
  days_until_renewal?: number       // Calculated: days until renewal
  risk_level?: 'green' | 'amber' | 'red'  // Calculated: risk assessment
}
```

### Risk Calculation Logic

Risk levels are automatically calculated based on renewal timeline:

| Risk Level | Criteria | Visual Indicator |
|------------|----------|------------------|
| **Green** | >90 days until renewal | 🟢 Green dot/badge |
| **Amber** | 30-90 days until renewal | 🟡 Amber dot/badge |
| **Red** | <30 days until renewal | 🔴 Red dot/badge |

**Note**: In production, risk scoring should also consider:
- Client engagement scores (from NPS, meeting frequency)
- Recent communication patterns
- Payment history
- Support ticket trends
- Health score metrics

## Filter Options

### Period Filters

```typescript
type PeriodOption = 30 | 60 | 90 | 180 | 365

// Shows renewals in the next X days
period: 30    // Next 30 days (critical)
period: 60    // Next 60 days (urgent)
period: 90    // Next 90 days (attention)
period: 180   // Next 6 months (planning)
period: 365   // Next 12 months (overview)
```

### Risk Level Filters

```typescript
type RiskLevel = 'all' | 'green' | 'amber' | 'red'

riskLevel: 'red'    // High-risk only
riskLevel: 'amber'  // Medium-risk only
riskLevel: 'green'  // Low-risk only
riskLevel: 'all'    // Show all renewals
```

### Sorting Options

```typescript
type SortOption = 'date' | 'value' | 'risk'

sortBy: 'date'   // Sort by renewal date (default)
sortBy: 'value'  // Sort by contract value
sortBy: 'risk'   // Sort by risk level (red → amber → green)

sortDirection: 'asc' | 'desc'  // Sort direction
```

## View Modes

### Calendar View

Displays renewals grouped by month in a card-based layout.

**Best for**:
- Strategic planning
- Visual timeline overview
- Executive presentations
- Identifying renewal clusters

**Features**:
- Month-by-month cards
- Contract count and value per month
- Risk indicators for each month
- Client previews (first 3 clients shown)

### List View

Displays renewals in a detailed table format.

**Best for**:
- Detailed analysis
- CSE work planning
- Filtering and sorting large datasets
- Exporting to spreadsheets

**Features**:
- Sortable columns
- Full client lists (with tooltips)
- Detailed contract information
- Action buttons per row
- Responsive table design

## Best Practices

### 1. Dashboard Integration

Place the `RenewalUpcomingWidget` on executive dashboards for high-visibility:

```tsx
// Recommended dashboard layout
<div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
  {/* Left column - Critical alerts */}
  <div className="space-y-6">
    <RenewalUpcomingWidget limit={5} />
    <FinancialHealthCard />
  </div>

  {/* Centre column - KPIs */}
  <div className="lg:col-span-2">
    <BURCExecutiveSummary />
  </div>
</div>
```

### 2. CSE Workflow

Implement dedicated renewal management page:

```tsx
// /app/burc/renewals/page.tsx
import { BURCRenewalCalendar } from '@/components/burc'

export default function RenewalsPage() {
  return (
    <div className="container mx-auto p-6">
      <BURCRenewalCalendar />
    </div>
  )
}
```

### 3. Automated Alerts

Set up proactive notifications:

```tsx
// Example: Alert on high-risk renewals
const { renewals, stats } = useBURCRenewals({ riskLevel: 'red', period: 30 })

useEffect(() => {
  if (stats.byRisk.red > 0) {
    // Trigger notification to CSE team
    notifyTeam({
      type: 'renewal-risk',
      count: stats.byRisk.red,
      value: stats.totalValue,
      renewals: renewals.slice(0, 5)
    })
  }
}, [stats.byRisk.red])
```

### 4. Performance Optimisation

For large datasets, implement pagination:

```tsx
const [page, setPage] = useState(1)
const ITEMS_PER_PAGE = 20

const paginatedRenewals = useMemo(() => {
  const start = (page - 1) * ITEMS_PER_PAGE
  return renewals.slice(start, start + ITEMS_PER_PAGE)
}, [renewals, page])
```

## Customisation

### Styling

All components use Tailwind CSS and follow the design system:

```tsx
// Custom colour scheme
<RenewalUpcomingWidget
  className="shadow-lg" // Add custom classes
/>

// Modify risk colours in getRiskColour() function
const getRiskColour = (risk: 'green' | 'amber' | 'red') => {
  // Customise colours here
}
```

### Data Enrichment

Enhance risk scoring with additional metrics:

```tsx
// In useBURCRenewals.ts - calculateRiskLevel function
const calculateRiskLevel = (
  daysUntil: number,
  engagementScore?: number,
  npsScore?: number
): 'green' | 'amber' | 'red' => {
  // Enhanced logic
  if (daysUntil < 30 && (npsScore < 7 || engagementScore < 50)) return 'red'
  if (daysUntil < 90 || engagementScore < 70) return 'amber'
  return 'green'
}
```

## Database Schema

### Source Table: `burc_renewal_calendar`

```sql
CREATE VIEW burc_renewal_calendar AS
SELECT
  renewal_year,
  renewal_month,
  renewal_period,
  COUNT(*) as contract_count,
  SUM(contract_value_usd) as total_value_usd,
  SUM(contract_value_aud) as total_value_aud,
  STRING_AGG(client_name, ', ') as clients
FROM burc_contracts
WHERE renewal_date IS NOT NULL
GROUP BY renewal_year, renewal_month, renewal_period
ORDER BY renewal_year, renewal_month;
```

### Required Permissions

Ensure service worker has read access:

```sql
-- Grant read access to burc_renewal_calendar
GRANT SELECT ON burc_renewal_calendar TO service_worker;
```

## Troubleshooting

### No Renewals Showing

**Possible Causes**:
1. Filters too restrictive (e.g., period: 30 with no renewals in next 30 days)
2. Database permissions issue
3. No data in `burc_renewal_calendar` table

**Solution**:
```tsx
// Reset filters
setFilters({
  period: 365,
  riskLevel: 'all',
  sortBy: 'date'
})

// Check data availability
console.log('Renewals:', renewals.length)
console.log('Stats:', stats)
```

### Incorrect Risk Levels

Risk calculation is based on `days_until_renewal`. Verify:

```tsx
// Debug risk calculation
renewals.forEach(r => {
  console.log(r.renewal_period, r.days_until_renewal, r.risk_level)
})
```

### Performance Issues

For large datasets:
1. Implement pagination
2. Add database indexes on `renewal_year`, `renewal_month`
3. Use React.memo for list items
4. Implement virtual scrolling for large tables

## Future Enhancements

### Planned Features
- [ ] Email notifications for approaching renewals
- [ ] Integration with CRM for engagement data
- [ ] Predictive risk scoring using ML
- [ ] Export to Excel/PDF
- [ ] Customisable risk thresholds
- [ ] Historical renewal success rates
- [ ] CSE assignment and tracking
- [ ] Action plan templates

### Advanced Integration
- Link to client health scores
- Integrate with NPS feedback
- Connect to support ticket volumes
- Track renewal success rates
- Generate renewal preparation checklists

## Related Components

- `BURCExecutiveDashboard` - Main BURC dashboard
- `ContractRenewalsWidget` - Alternative renewal widget
- `ClientHealthCard` - Client engagement metrics
- `FinancialHealthCard` - Financial indicators

## Support

For issues or questions:
- Check TypeScript types in `/src/hooks/useBURCRenewals.ts`
- Review database schema in `/docs/database-schema.md`
- See BURC documentation in `/docs/BURC-ENHANCEMENT-ANALYSIS.md`

---

**Last Updated**: 5 January 2026
**Component Version**: 1.0.0
**Tested**: TypeScript 5.x, Next.js 14.x, React 18.x
