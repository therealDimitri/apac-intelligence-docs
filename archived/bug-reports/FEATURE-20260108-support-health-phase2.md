# Feature: Support Health Page - Phase 2 (Trend Analysis)

**Date:** 8 January 2026
**Status:** ✅ Completed
**Related:** FEATURE-20260108-support-health-phase1.md

## Overview

Phase 2 adds historical trend visualisation to the Support Health page, including:
- 6-month trend charts section with area and line charts
- Sparklines in table rows showing health score trends
- Monthly snapshot sync job for data validation
- Period comparison indicators (MoM change)

## Files Created

### 1. API Endpoint: `/src/app/api/support-metrics/trends/route.ts`

New API endpoint for fetching historical trend data.

**Features:**
- Returns per-client trend data points
- Calculates aggregated averages across all clients
- Determines trend direction (improving/declining/stable)
- Computes month-over-month (MoM) percentage change
- Supports configurable months parameter (default: 6)

**Response Structure:**
```typescript
interface TrendsData {
  clientTrends: ClientTrend[]
  aggregatedTrends: AggregatedTrend[]
}

interface ClientTrend {
  client_name: string
  data_points: TrendDataPoint[]
  trend_direction: 'improving' | 'declining' | 'stable'
  mom_change: number | null
}
```

### 2. Component: `/src/components/support/TrendChartsSection.tsx`

Collapsible section displaying 6-month historical charts.

**Features:**
- Two charts side-by-side:
  - "Health Score & SLA Compliance" (AreaChart with gradient fills)
  - "Open Cases & Critical" (LineChart)
- Quick stats in header showing Health change and SLA change
- Expand/collapse animation with Framer Motion
- Responsive design using Recharts ResponsiveContainer

### 3. Component: `/src/components/support/Sparkline.tsx`

Pure SVG sparkline component for inline trend visualisation.

**Features:**
- Configurable dimensions (default 80x24)
- Gradient fill under the line
- Trend indicator icon (TrendingUp/TrendingDown/Minus)
- Tooltip showing historical values
- Customisable stroke colour

**Props:**
```typescript
interface SparklineProps {
  data: number[]
  width?: number
  height?: number
  strokeWidth?: number
  colour?: string
  showTrendIndicator?: boolean
  labels?: string[]
}
```

### 4. Script: `/scripts/sync-support-monthly-snapshot.mjs`

Monthly data validation and reporting script.

**Features:**
- Validates data integrity in support_sla_metrics table
- Reports on historical period coverage
- Identifies duplicate records
- Provides recommendations for trend analysis

**Usage:**
```bash
node scripts/sync-support-monthly-snapshot.mjs
node scripts/sync-support-monthly-snapshot.mjs --dry-run
```

## Files Modified

### 1. `/src/components/support/SupportOverviewTable.tsx`

**Changes:**
- Added `trendData` state to store per-client trend information
- Parallel fetch of metrics and trends data
- Added `getClientSparklineData()` helper function
- New "Trend" column with sparklines or "—" placeholder
- Tooltip explaining sparkline functionality

### 2. `/src/components/support/ExpandableRowContent.tsx`

**Changes:**
- Updated `colSpan` from 9 to 10 to accommodate new Trend column

### 3. `/src/app/(dashboard)/support/page.tsx`

**Changes:**
- Added import for TrendChartsSection
- Added TrendChartsSection before SupportOverviewTable
- Both components share the same refreshKey for synchronised refresh

### 4. `/src/components/support/index.ts`

**Changes:**
- Added exports for TrendChartsSection and Sparkline

## Database Changes

### Indexes Added

```sql
-- Composite index for efficient client-period queries
CREATE INDEX idx_support_metrics_client_period
ON support_sla_metrics (client_name, period_end DESC);

-- Partial index for SLA compliance filtering
CREATE INDEX idx_support_metrics_health_score
ON support_sla_metrics (resolution_sla_percent)
WHERE resolution_sla_percent IS NOT NULL;
```

**Applied via:** Direct psql connection to Supabase

## Technical Details

### Trend Calculation Logic

1. **Data Requirements:** Minimum 2 periods required for trend analysis
2. **Trend Direction:**
   - `improving`: Latest health score > previous by ≥5 points
   - `declining`: Latest health score < previous by ≥5 points
   - `stable`: Change within ±5 points
3. **MoM Change:** Percentage change between latest and previous period

### Chart Configuration

- **AreaChart:** Semi-transparent gradient fills with stroke lines
- **LineChart:** Solid stroke lines with dot markers
- **Colours:**
  - Health Score: Emerald (#10b981)
  - SLA Compliance: Blue (#3b82f6)
  - Open Cases: Amber (#f59e0b)
  - Critical Cases: Red (#ef4444)

## Testing

### Manual Testing Steps

1. Navigate to `/support` page
2. Verify Trend Analysis section displays with charts
3. Check quick stats show MoM changes (e.g., "+10.7%")
4. Expand/collapse the trend section
5. Scroll to table and verify Trend column
6. Clients with multiple periods show sparklines
7. Clients with single period show "—"
8. Hover over sparkline to see tooltip with values

### Verified Behaviour

- ✅ Trend charts display Sept-Dec 2024 data points
- ✅ SLA change indicator shows "+10.7%"
- ✅ SA Health shows sparkline (has 2 periods)
- ✅ Other clients show "—" placeholder (single period)
- ✅ TypeScript compilation passes with no errors
- ✅ Refresh button updates both sections

## Screenshots

Location: `/Users/jimmy.leimonitis/.playwright-mcp/support-health-phase2-trends.png`

## Known Limitations

1. **Single Period Data:** Most clients currently only have one period of data, so sparklines show "—"
2. **Chart Dimension Warning:** Recharts ResponsiveContainer shows -1,-1 dimensions on initial render (cosmetic, doesn't affect functionality)
3. **Historical Data:** Trend analysis requires manual import of monthly SLA reports to build history

## Future Enhancements (Phase 3)

From SUPPORT-HEALTH-RECOMMENDATIONS.md:
- Client detail drill-down page
- Historical comparison modal
- CSV/PDF export functionality
- Alert configuration for SLA breaches

## Dependencies

- `recharts` - Charting library (existing)
- `framer-motion` - Animations (existing)
- `lucide-react` - Icons (existing)
