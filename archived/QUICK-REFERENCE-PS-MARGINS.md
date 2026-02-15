# Quick Reference: BURC PS Margins Panel

## Files Created

1. **Component**: `/src/components/burc/BURCPSMarginsPanel.tsx` (19KB)
2. **Hook**: `/src/hooks/useBURCPSMetrics.ts` (6.9KB)
3. **Documentation**: `/docs/components/BURC-PS-MARGINS-PANEL.md`
4. **Updated**: `/src/components/burc/index.ts` (added export)

## Quick Usage

```tsx
import { BURCPSMarginsPanel } from '@/components/burc'

<BURCPSMarginsPanel />
```

## What It Shows

### Top Row Metrics
1. **Overall Margin** - Current PS margin % (Target: ≥25%)
2. **Utilisation Rate** - Team utilisation % (Target: ≥75%)
3. **Avg Project Margin** - Mean profitability across projects
4. **Revenue/Consultant** - Monthly revenue per consultant

### Visualisations
- **Margin Gauge**: Semi-circular gauge showing current margin
- **Project Distribution**: Pie chart of profitable/unprofitable/break-even projects
- **12-Month Trend**: Line chart of margin %, utilisation %, and revenue over time
- **Utilisation Bar**: Progress bar showing current vs. target utilisation

### Project Table
- Top 10 projects by profitability
- Shows: Project, Client, Revenue, Cost, Margin, Margin %, Status

## Colour Thresholds

### Margin
- 🟢 Green: ≥25% (On Target)
- 🟡 Amber: 15-24% (Below Target)
- 🔴 Red: <15% (Critical)

### Utilisation
- 🟢 Green: ≥75% (On Target)
- 🟡 Amber: 60-74% (Below Target)
- 🔴 Red: <60% (Critical)

## Data Source

### Tables Used
1. `burc_ps_margins` - Project-level margin data
2. `burc_ps_utilisation` - Team utilisation metrics

### Sample Data Structure

**burc_ps_margins**:
```sql
fiscal_year    | 2026
month_num      | 1
client_name    | 'Example Client'
project_name   | 'Implementation Project'
revenue        | 150000
cost           | 105000
margin         | 45000
margin_percent | 30.0
```

**burc_ps_utilisation**:
```sql
year                    | 2026
month                   | 1
billable_hours          | 1200
total_available_hours   | 1600
utilisation_rate        | 75.0
revenue_per_consultant  | 18500
```

## Hook Usage (Advanced)

```tsx
import { useBURCPSMetrics } from '@/hooks/useBURCPSMetrics'

const {
  summary,      // Overall metrics
  projects,     // Array of project profitability
  trends,       // 12-month historical data
  loading,      // Boolean
  error,        // String | null
  refresh       // Function to reload data
} = useBURCPSMetrics()
```

## Integration Examples

### In Executive Dashboard
```tsx
import { BURCPSMarginsPanel } from '@/components/burc'

<div className="grid grid-cols-1 gap-6">
  <BURCPSMarginsPanel />
</div>
```

### In Two-Column Layout
```tsx
<div className="grid grid-cols-2 gap-6">
  <BURCPSMarginsPanel height={350} />
  <OtherComponent />
</div>
```

### With Custom Loading State
```tsx
import { useBURCPSMetrics } from '@/hooks/useBURCPSMetrics'

function CustomPSView() {
  const { summary, loading } = useBURCPSMetrics()

  if (loading) return <CustomLoader />

  return (
    <div>
      <h2>PS Margin: {summary?.overall_margin_percent.toFixed(1)}%</h2>
      <BURCPSMarginsPanel />
    </div>
  )
}
```

## Troubleshooting

### No Data Showing
1. Check if tables exist: `burc_ps_margins`, `burc_ps_utilisation`
2. Verify RLS policies allow authenticated read
3. Check data exists for current fiscal year
4. Review browser console for errors

### Wrong Calculations
1. Verify `margin_percent` is correctly calculated in database
2. Check `utilisation_rate` formula matches target
3. Ensure `fiscal_year` matches current year

### Chart Not Rendering
1. Verify `recharts` is installed: `npm list recharts`
2. Check browser console for errors
3. Ensure data has correct structure (see hook interface)

## Database Setup

If tables don't exist, run migration:
```sql
-- See: /docs/migrations/20260103_expanded_burc_tables.sql
-- See: /docs/migrations/20251229_enhanced_financial_analytics.sql
```

## Performance Notes

- Data fetches on component mount
- Calculations happen client-side
- Shows top 10 projects only
- Trends limited to last 12 months
- No real-time updates (manual refresh required)

## Next Steps

1. Add data to `burc_ps_margins` table
2. Add data to `burc_ps_utilisation` table
3. Import component where needed
4. Configure alerts/notifications (optional)
5. Customise thresholds if needed

## Related Documentation

- Full docs: `/docs/components/BURC-PS-MARGINS-PANEL.md`
- Database schema: `/docs/database-schema.md`
- BURC migrations: `/docs/migrations/20260103_expanded_burc_tables.sql`
