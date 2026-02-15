# Feature Report: CSE/CAM Performance Dashboard

**Date**: 2026-01-10
**Feature**: CSE/CAM Performance Dashboard with Territory and Region Rollups
**Status**: Implemented

---

## Summary

Implemented a comprehensive CSE/CAM Performance Dashboard component that provides performance scorecards with territory and region rollups. This dashboard enables managers to track individual CSE performance, compare territories, and view regional aggregations.

## Components Created

### 1. CSEPerformanceDashboard.tsx
**Location**: `/src/components/planning/CSEPerformanceDashboard.tsx`

Main dashboard component with multiple views:
- **CSE Performance Cards**: Individual cards showing health distribution, pipeline value, targets, MEDDPICC scores, and readiness status
- **Performance Heat Map**: Visual grid showing all CSEs against key metrics with colour-coded status indicators
- **Summary Statistics**: Aggregate metrics across all CSEs including total clients, pipeline, targets, and averages

**Key Features**:
- Tabbed navigation between CSE Cards, Heat Map, Territory, and Region views
- Automatic calculation of territory and region rollups from CSE data
- BURC alignment gauge integration
- Loading skeleton states
- Click handlers for CSE navigation
- Responsive grid layouts for different screen sizes

### 2. TerritoryView.tsx
**Location**: `/src/components/planning/TerritoryView.tsx`

Territory-focused dashboard showing:
- **Territory Cards**: Ranked performance cards with states/coverage, key metrics, target achievement, health distribution, and MEDDPICC/readiness scores
- **Territory Comparison Table**: Sortable table comparing all territories side-by-side
- **Summary Statistics**: Aggregate metrics across all territories

**Key Features**:
- Performance ranking with visual indicators (gold/silver/bronze)
- Progress bars for target achievement
- Gap analysis with directional indicators
- Health distribution visualisation
- Click handlers for territory drill-down

### 3. RegionView.tsx
**Location**: `/src/components/planning/RegionView.tsx`

Region-focused dashboard showing:
- **Region Cards**: Comprehensive cards with territory coverage, client counts, pipeline contribution, target achievement, and health/MEDDPICC metrics
- **Region Comparison Table**: Side-by-side comparison of regions with APAC totals
- **Pipeline Contribution Visualisation**: Visual breakdown of pipeline across regions

**Key Features**:
- Colour-coded region identifiers (Australia+NZ: blue, Asia+Guam: green)
- Pipeline contribution percentages
- Weighted vs unweighted pipeline display
- APAC total aggregation
- Interactive region selection

### 4. BURCAlignmentGauge.tsx
**Location**: `/src/components/planning/BURCAlignmentGauge.tsx`

Circular gauge component showing pipeline alignment to BURC targets:
- **BURCAlignmentGauge**: SVG-based circular progress gauge with configurable sizes (sm/md/lg)
- **BURCAlignmentCard**: Detailed card component with gauge, pipeline details, gap analysis, and threshold legend

**Key Features**:
- Animated progress arc
- Colour-coded status (On Track/Good/At Risk/Critical)
- Support for values exceeding 100% (over-achievement indicator)
- Configurable target thresholds
- Status badges with icons

## Type Definitions

### CSEPerformance
```typescript
interface CSEPerformance {
  cse_name: string
  territory: string
  region: 'Australia+NZ' | 'Asia+Guam'
  client_count: number
  health_distribution: {
    healthy: number
    at_risk: number
    critical: number
  }
  avg_health_score: number
  avg_compliance: number
  total_arr: number
  pipeline: {
    total_value: number
    weighted_value: number
    focus_deals: number
    opportunity_count: number
  }
  targets: {
    quarterly_target: number
    quarterly_actual: number
    gap: number
    achievement_pct: number
  }
  meddpicc: {
    avg_score: number
    scored_count: number
    low_score_count: number
  }
  readiness: {
    upcoming_meetings: number
    avg_readiness: number
    low_readiness_count: number
  }
}
```

### TerritoryRollup
```typescript
interface TerritoryRollup {
  territory: string
  cse_name: string
  states: string[]
  client_count: number
  total_arr: number
  pipeline_value: number
  weighted_pipeline: number
  quarterly_target: number
  quarterly_actual: number
  gap: number
  achievement_pct: number
  avg_health: number
  avg_meddpicc: number
  avg_readiness: number
  health_distribution: {
    healthy: number
    at_risk: number
    critical: number
  }
}
```

### RegionRollup
```typescript
interface RegionRollup {
  region: string
  territories: string[]
  client_count: number
  total_arr: number
  pipeline_value: number
  weighted_pipeline: number
  quarterly_target: number
  quarterly_actual: number
  gap: number
  achievement_pct: number
  avg_health: number
  avg_meddpicc: number
  cse_count: number
  health_distribution: {
    healthy: number
    at_risk: number
    critical: number
  }
}
```

## Colour Thresholds

### Health Score
- **Green** (70%+): Healthy
- **Amber** (50-70%): At Risk
- **Red** (<50%): Critical

### Target Achievement
- **Green** (90%+): On Track
- **Amber** (70-90%): At Risk
- **Red** (<70%): Critical

### MEDDPICC Score
- **Blue** (70%+): Strong
- **Amber** (50-70%): Needs Improvement
- **Red** (<50%): Weak

### Readiness Score
- **Green** (80%+): Ready
- **Amber** (60-80%): Needs Preparation
- **Red** (<60%): Not Ready

### BURC Alignment
- **Green** (100%+): On Track
- **Sky Blue** (80-99%): Good
- **Amber** (60-79%): At Risk
- **Red** (<60%): Critical

## Usage Example

```tsx
import { CSEPerformanceDashboard } from '@/components/planning'

const cseData: CSEPerformance[] = [
  {
    cse_name: 'Tracey Bland',
    territory: 'VIC + NZ',
    region: 'Australia+NZ',
    client_count: 8,
    health_distribution: { healthy: 5, at_risk: 2, critical: 1 },
    avg_health_score: 72,
    avg_compliance: 88,
    total_arr: 2500000,
    pipeline: {
      total_value: 1200000,
      weighted_value: 720000,
      focus_deals: 3,
      opportunity_count: 7,
    },
    targets: {
      quarterly_target: 800000,
      quarterly_actual: 650000,
      gap: 150000,
      achievement_pct: 81.25,
    },
    meddpicc: {
      avg_score: 68,
      scored_count: 5,
      low_score_count: 1,
    },
    readiness: {
      upcoming_meetings: 4,
      avg_readiness: 75,
      low_readiness_count: 1,
    },
  },
  // ... more CSE data
]

<CSEPerformanceDashboard
  data={cseData}
  currentQuarter="Q1 FY26"
  onCSEClick={(cseName) => router.push(`/cse/${cseName}`)}
  showTerritoryView={true}
  showRegionView={true}
/>
```

## Files Modified

- `/src/components/planning/index.ts` - Added exports for new components and types

## Dependencies

- shadcn/ui components: Card, Progress, Badge, Tabs
- lucide-react icons
- @/lib/utils (cn utility)

## Testing

- Build completed successfully with no TypeScript errors
- All components properly exported from index.ts

## Future Enhancements

1. **Data Integration**: Connect to Supabase API to fetch real CSE performance data
2. **Filtering**: Add date range and segment filters
3. **Export**: Add Excel/PDF export functionality
4. **Real-time Updates**: Subscribe to performance updates
5. **Drill-down Navigation**: Link to individual CSE detail pages
6. **Historical Comparison**: Add period-over-period comparison

---

**Implemented by**: Claude Code
**Build Status**: Verified
