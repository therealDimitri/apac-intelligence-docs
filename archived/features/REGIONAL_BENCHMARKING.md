# Regional Benchmarking Dashboard

## Overview

The Regional Benchmarking Dashboard is a comprehensive cross-region performance comparison tool that allows APAC stakeholders to compare their performance against other global regions (EMEA, Americas) and global aggregates.

## Feature Summary

### Key Capabilities

1. **Cross-Region Comparison**
   - Side-by-side metrics comparison across APAC, EMEA, Americas, and Global
   - Variance calculations showing difference from global average
   - Visual indicators highlighting best and worst performers

2. **Interactive Visualizations**
   - Bar charts for regional performance comparison
   - Line charts for trend analysis over time
   - Ranking cards with status indicators and trend arrows

3. **Flexible Filtering**
   - Region selector (All, APAC, EMEA, Americas, Global)
   - Time period selector (Quarter, YTD, Full Year)
   - Comparison mode selector (Current, vs Previous, vs Other Regions)

4. **Key Metrics Tracked**
   - **NRR (Net Revenue Retention)** - Revenue growth from existing customers
   - **GRR (Gross Revenue Retention)** - Revenue retained before expansion
   - **Rule of 40** - Sum of growth rate and profit margin
   - **DSO (Days Sales Outstanding)** - Collection efficiency
   - **Churn Rate** - Percentage of customers lost
   - **ARR Growth** - Annual recurring revenue growth rate
   - Additional metrics: CAC, LTV, Revenue per Client, Margins

## Files Created

### Database Migration
- `/docs/migrations/20260105_regional_benchmarks.sql` - Table creation DDL
- `/docs/migrations/20260105_regional_benchmarks_seed.sql` - Sample data insertion

### Hook
- `/src/hooks/useBenchmarkData.ts` - Data fetching, comparisons, and ranking calculations

### Components
- `/src/components/benchmarking/RegionalComparisonTable.tsx` - Comparison table with variance indicators
- `/src/components/benchmarking/RegionalPerformanceChart.tsx` - Bar chart for regional comparison
- `/src/components/benchmarking/BenchmarkTrendChart.tsx` - Line chart for trend analysis
- `/src/components/benchmarking/RegionalRankingCards.tsx` - Ranking cards with status badges

### Page
- `/src/app/(dashboard)/benchmarking/page.tsx` - Main dashboard page with filters and layout

### Documentation
- `/docs/BENCHMARKING_SETUP.md` - Setup guide and usage instructions
- `/docs/features/REGIONAL_BENCHMARKING.md` - This file (feature documentation)

### Navigation
- Updated `/src/components/layout/sidebar.tsx` to add "Regional Benchmarking" menu item

## Database Schema

### Table: `regional_benchmarks`

```sql
CREATE TABLE regional_benchmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  region VARCHAR(20) NOT NULL CHECK (region IN ('APAC', 'EMEA', 'Americas', 'Global')),
  period VARCHAR(20) NOT NULL,
  metric_name VARCHAR(50) NOT NULL,
  metric_value NUMERIC(15,2) NOT NULL,
  target_value NUMERIC(15,2),
  previous_value NUMERIC(15,2),
  unit VARCHAR(10) DEFAULT '%',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_region_period_metric UNIQUE (region, period, metric_name)
);
```

**Indexes:**
- `idx_regional_benchmarks_region` on `region`
- `idx_regional_benchmarks_period` on `period`
- `idx_regional_benchmarks_metric` on `metric_name`
- `idx_regional_benchmarks_region_period` on `(region, period)`

**Row Level Security:**
- Authenticated users can read all data
- Service role can insert/update/delete data

## Setup Instructions

### 1. Create the Database Table

1. Open Supabase SQL Editor
2. Execute the SQL from `/docs/migrations/20260105_regional_benchmarks.sql`
3. Verify table creation: `SELECT * FROM regional_benchmarks LIMIT 1;`

### 2. Populate Sample Data

1. In Supabase SQL Editor
2. Execute the SQL from `/docs/migrations/20260105_regional_benchmarks_seed.sql`
3. Verify data: `SELECT region, period, COUNT(*) FROM regional_benchmarks GROUP BY region, period;`

### 3. Access the Dashboard

1. Navigate to the application sidebar
2. Click "Regional Benchmarking" under the Financials section
3. The dashboard will load with default filters (All Regions, Q4 2025)

## Usage Examples

### Viewing Current Quarter Performance

1. Set Period to "Q4 2025"
2. Set Region to "All Regions"
3. Review the Regional Comparison Table to see APAC variance from global average
4. Check the Regional Ranking Cards to see APAC's position among regions

### Analyzing Trends Over Time

1. Use the Benchmark Trend Chart
2. Select a metric from the dropdown (e.g., "NRR")
3. Toggle "Show Global" to compare APAC vs global average
4. Observe trend arrows and changes quarter-over-quarter

### Identifying Improvement Areas

1. Look for red/amber status indicators in Ranking Cards
2. Check metrics where APAC ranks #3 of 3
3. Review variance from target to identify gaps
4. Compare with best performer to understand the gap

## Component Architecture

### Data Flow

```
User Interaction (Filter Selection)
    ↓
useBenchmarkData Hook
    ↓
Supabase Query (regional_benchmarks table)
    ↓
Data Processing (calculateComparisons, calculateRankings)
    ↓
Components (Table, Charts, Cards)
    ↓
Rendered Dashboard
```

### Hook Functions

**`useBenchmarkData`**
- Fetches benchmark data from Supabase
- Calculates cross-region comparisons
- Computes APAC rankings against other regions
- Determines trends (up/down/stable)
- Returns processed data, comparisons, rankings, and loading/error states

**Key Calculations:**
- **Variance**: `(APAC_value - Global_value)` - Absolute difference from global
- **Rank**: Position among regions (1-3), considering if lower or higher is better
- **Trend**: Comparison with previous period value (>0.5 change required)
- **Status**: Excellent (rank 1), Good (rank 2), Needs Improvement (rank 3)

### Component Hierarchy

```
BenchmarkingPage
├── RegionalRankingCards (Top Section)
├── Grid Layout (2 columns)
│   ├── RegionalPerformanceChart (Left)
│   └── BenchmarkTrendChart (Right)
└── RegionalComparisonTable (Bottom)
```

## Features in Detail

### 1. Regional Comparison Table

**What it shows:**
- All key metrics in rows
- APAC, EMEA, Americas, Global values in columns
- Variance from global average
- Trophy icon for best performer
- Red/amber/green highlighting

**How to read:**
- Green background = Best performer
- Red background = Worst performer
- Positive variance = Above global (good for most metrics)
- Negative variance = Below global (may need attention)
- "pp" = Percentage points

### 2. Regional Performance Chart

**What it shows:**
- Bar chart comparing regions for selected metric
- Global average reference line (red dashed)
- Color-coded bars (Purple=APAC, Blue=EMEA, Green=Americas)

**How to use:**
- Select metric from dropdown
- Hover bars for exact values
- Compare bar heights to identify performance gaps
- Check position relative to global average line

### 3. Benchmark Trend Chart

**What it shows:**
- Line chart of APAC performance over time
- Optional global average overlay
- Target reference line
- Trend over multiple periods

**How to use:**
- Select metric from dropdown
- Toggle global average on/off
- Look for upward or downward trends
- Compare current vs previous periods

### 4. Regional Ranking Cards

**What it shows:**
- Individual cards for each metric
- APAC rank (1st, 2nd, or 3rd)
- Current value, target, and global average
- Variance percentages
- Status badge and trend arrow

**How to read:**
- **Excellent** (green) = Rank #1 among regions
- **Good** (blue) = Rank #2 among regions
- **Needs Improvement** (amber) = Rank #3 among regions
- ⬆️ Up arrow = Improving trend
- ⬇️ Down arrow = Declining trend
- ➖ Flat = Stable, no significant change

## Best Practices

### Data Quality

1. **Regular Updates**: Update benchmark data quarterly
2. **Consistent Metrics**: Ensure metric definitions are standardised across regions
3. **Accurate Targets**: Set realistic, achievable targets based on industry standards
4. **Historical Data**: Maintain previous period values for trend analysis

### Analysis Approach

1. **Start with Rankings**: Review Regional Ranking Cards first for quick overview
2. **Identify Gaps**: Look for red/amber status and low rankings
3. **Analyse Trends**: Check if performance is improving or declining
4. **Compare Peers**: See which region is excelling and why
5. **Set Priorities**: Focus on metrics furthest from target or global average

### Reporting Tips

1. **Executive Summary**: Use ranking cards for high-level overview
2. **Detailed Analysis**: Use comparison table for metric-by-metric breakdown
3. **Storytelling**: Use trend charts to show progress over time
4. **Benchmarking**: Use performance chart to compare against best-in-class

## Technical Considerations

### Performance

- Database indexes ensure fast query performance
- Component memoization prevents unnecessary re-renders
- Data is fetched once per filter change and cached
- Charts use Recharts for performant rendering

### Accessibility

- Colour-blind friendly palette (purple, blue, green)
- Icons supplement colour coding
- Clear labels and tooltips
- Keyboard navigation support

### Security

- RLS policies ensure data access control
- Authenticated users can only read data
- Only service role can modify data
- No sensitive client information exposed

## Future Enhancements

### Short Term (1-2 months)

1. **Data Export** - Download benchmarks as CSV/Excel
2. **Custom Date Ranges** - Select arbitrary date ranges
3. **Metric Definitions** - Tooltips explaining each metric
4. **Print View** - Optimised layout for printing reports

### Medium Term (3-6 months)

1. **Historical Analysis** - 12-month rolling trends
2. **Peer Groups** - Compare against industry benchmarks
3. **Drill-Down** - Click metrics to see contributing factors
4. **Alerts** - Email notifications when APAC falls below thresholds

### Long Term (6-12 months)

1. **Predictive Analytics** - Forecast future performance
2. **AI Insights** - Automated insights and recommendations
3. **Competitive Intelligence** - External market benchmarks
4. **Custom Metrics** - User-defined KPIs and calculations

## Troubleshooting

### Common Issues

**Issue**: "Table not found" error
**Solution**: Execute migration SQL in Supabase Dashboard

**Issue**: No data showing in dashboard
**Solution**: Run seed SQL to populate sample data

**Issue**: Charts not rendering
**Solution**: Check browser console, ensure Recharts is installed

**Issue**: Incorrect rankings or calculations
**Solution**: Verify data quality and metric definitions

## Support

For questions or issues with the Regional Benchmarking dashboard:

1. Review this documentation
2. Check the setup guide at `/docs/BENCHMARKING_SETUP.md`
3. Examine database schema at `/docs/database-schema.md`
4. Review TypeScript interfaces in `/src/hooks/useBenchmarkData.ts`
5. Contact the development team

---

**Created:** 2026-01-05
**Version:** 1.0.0
**Status:** Production Ready (pending database setup)
**Authors:** Claude Code, APAC Intelligence Team
