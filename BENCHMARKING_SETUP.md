# Regional Benchmarking Dashboard - Setup Guide

## Overview

The Regional Benchmarking dashboard provides cross-region performance comparison capabilities, allowing you to compare APAC performance against EMEA, Americas, and Global aggregates across key business metrics.

## Features

### 1. Regional Comparison Table
- Side-by-side metrics comparison across all regions
- Variance calculations showing difference from global average
- Visual indicators for best/worst performers
- Metrics tracked: NRR, GRR, Rule of 40, DSO, Churn Rate, ARR Growth, and more

### 2. Regional Performance Chart
- Interactive bar chart comparing regions
- Toggle between different metrics
- Reference lines showing global averages and targets
- Tooltips with exact values

### 3. Benchmark Trend Chart
- Line chart showing APAC vs Global performance over time
- Multi-period view (quarterly, YTD, full year)
- Target reference lines
- Toggleable global average overlay

### 4. Regional Ranking Cards
- Summary cards showing APAC's ranking among regions
- Status indicators: Excellent, Good, Needs Improvement
- Trend arrows (up/down/stable)
- Variance from both target and global average

## Database Setup

### Step 1: Create the Table

1. Open Supabase SQL Editor:
   - Navigate to: https://supabase.com/dashboard/project/[your-project-id]/sql/new

2. Copy and paste the SQL from:
   ```
   docs/migrations/20260105_regional_benchmarks.sql
   ```

3. Click "Run" to execute the migration

This will create:
- `regional_benchmarks` table with proper schema
- Indexes for optimal query performance
- Row Level Security (RLS) policies
- Check constraints ensuring data integrity

### Step 2: Populate with Sample Data

1. In the same SQL Editor, copy and paste the SQL from:
   ```
   docs/migrations/20260105_regional_benchmarks_seed.sql
   ```

2. Click "Run" to populate the table

This will insert:
- Q4 2025 data for all regions (APAC, EMEA, Americas, Global)
- YTD 2025 data for trend analysis
- Full year 2025 summary data
- Realistic benchmark values with targets and previous period comparisons

### Step 3: Verify Installation

Run the following query to verify data was loaded correctly:

```sql
SELECT
  region,
  period,
  COUNT(*) as metric_count
FROM regional_benchmarks
GROUP BY region, period
ORDER BY region, period;
```

Expected output:
- Each region should have 6-12 metrics per period
- You should see data for periods: 2025-Q4, 2025-YTD, 2025-FY

## Usage

### Accessing the Dashboard

1. Navigate to the sidebar
2. Click on "Regional Benchmarking" under the Financials section
3. The dashboard will load with default filters

### Using Filters

**Region Selector:**
- All Regions (default) - Shows comparison across all regions
- APAC - Focus on APAC metrics only
- EMEA - Focus on EMEA metrics only
- Americas - Focus on Americas metrics only
- Global - Show global aggregates only

**Period Selector:**
- Q4 2025 (default) - Most recent quarter
- Q3 2025, Q2 2025, Q1 2025 - Previous quarters
- YTD 2025 - Year to date
- FY 2025 - Full fiscal year

**Comparison Mode:**
- Current Period - Show current values
- vs Previous Period - Compare with previous quarter
- vs Other Regions - Cross-region comparison (default)

### Interpreting the Data

**Metrics Explained:**

1. **NRR (Net Revenue Retention)** - Higher is better
   - Target: 110%+
   - Excellent: >115%
   - Measures revenue growth from existing customers

2. **GRR (Gross Revenue Retention)** - Higher is better
   - Target: 96%+
   - Excellent: >97%
   - Measures revenue retained before expansion

3. **Rule of 40** - Higher is better
   - Target: 45%+
   - Excellent: >50%
   - Sum of growth rate + profit margin

4. **DSO (Days Sales Outstanding)** - Lower is better
   - Target: <45 days
   - Excellent: <40 days
   - Measures collection efficiency

5. **Churn Rate** - Lower is better
   - Target: <4%
   - Excellent: <3%
   - Percentage of customers lost

6. **ARR Growth** - Higher is better
   - Target: 25%+
   - Excellent: >30%
   - Annual recurring revenue growth rate

**Color Coding:**

- 🟢 Green: Best performer or exceeding target
- 🟡 Amber: Good performance, room for improvement
- 🔴 Red: Needs improvement or below target
- 🏆 Trophy icon: Best regional performer for that metric
- 📉 Down arrow: Worst regional performer

## Adding New Data

### Manual Entry via SQL

To add new period data:

```sql
INSERT INTO regional_benchmarks (region, period, metric_name, metric_value, target_value, previous_value, unit)
VALUES
  ('APAC', '2026-Q1', 'NRR', 109.5, 110.0, 108.5, '%'),
  ('APAC', '2026-Q1', 'GRR', 95.8, 96.0, 95.2, '%');
  -- Add more metrics as needed
```

### Programmatic Updates

Use the service role client to insert data:

```typescript
import { getServiceSupabase } from '@/lib/supabase'

const supabase = getServiceSupabase()

await supabase
  .from('regional_benchmarks')
  .insert([
    {
      region: 'APAC',
      period: '2026-Q1',
      metric_name: 'NRR',
      metric_value: 109.5,
      target_value: 110.0,
      previous_value: 108.5,
      unit: '%'
    }
  ])
```

## Technical Architecture

### Files Created

**Hook:**
- `/src/hooks/useBenchmarkData.ts` - Data fetching and calculations

**Components:**
- `/src/components/benchmarking/RegionalComparisonTable.tsx` - Comparison table
- `/src/components/benchmarking/RegionalPerformanceChart.tsx` - Bar chart
- `/src/components/benchmarking/BenchmarkTrendChart.tsx` - Line chart
- `/src/components/benchmarking/RegionalRankingCards.tsx` - Ranking cards

**Page:**
- `/src/app/(dashboard)/benchmarking/page.tsx` - Main dashboard page

**Database:**
- `/docs/migrations/20260105_regional_benchmarks.sql` - Table creation
- `/docs/migrations/20260105_regional_benchmarks_seed.sql` - Sample data

**Scripts:**
- `/scripts/create-benchmarks-table.ts` - Automated table creation helper
- `/scripts/execute-sql.ts` - SQL execution utility

### Data Flow

1. User selects filters (region, period, comparison mode)
2. `useBenchmarkData` hook fetches data from Supabase
3. Hook calculates comparisons, rankings, and variances
4. Components receive processed data and render visualizations
5. All changes are reactive - updating filters re-fetches and recalculates

### Performance Considerations

- Indexes on `region`, `period`, and `metric_name` ensure fast queries
- Data is fetched once per filter change and cached
- Components use React memoization to prevent unnecessary re-renders
- Charts use Recharts library for performant visualizations

## Troubleshooting

### "Table not found" Error

If you see this error:
1. Verify the table exists in Supabase
2. Check RLS policies are configured correctly
3. Ensure your user has proper authentication

### No Data Showing

If the dashboard shows no data:
1. Run the verification query in Step 3 above
2. Check that seed data was inserted correctly
3. Verify period filter matches available data

### Chart Not Rendering

If charts don't display:
1. Check browser console for errors
2. Ensure data contains the expected fields
3. Verify Recharts library is installed: `npm install recharts`

## Future Enhancements

Potential improvements for future iterations:

1. **Data Export** - Export benchmark data to CSV/Excel
2. **Historical Trends** - 12-month rolling view with seasonality analysis
3. **Custom Metrics** - Allow users to define custom benchmarks
4. **Alerts** - Automated alerts when APAC falls below thresholds
5. **Drill-Down** - Click metrics to see contributing factors
6. **Forecasting** - Predictive analytics based on trends
7. **Peer Comparison** - Industry benchmark comparisons

## Support

For questions or issues:
1. Check this documentation first
2. Review the database schema in `/docs/database-schema.md`
3. Examine the TypeScript interfaces in `/src/hooks/useBenchmarkData.ts`
4. Contact the development team

---

**Last Updated:** 2026-01-05
**Version:** 1.0.0
**Status:** Ready for Production (pending table creation)
