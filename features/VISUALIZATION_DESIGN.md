# Client Profile V2 - Visualization Design Specification

**Created**: 2025-12-02
**Purpose**: Comprehensive visualization design for APAC Intelligence V2 Client Profile Page
**Status**: Implementation In Progress

---

## Overview

This document outlines all data visualizations for the enhanced Client Profile V2 page, providing actionable insights through interactive charts and graphs.

---

## 1. NPS Analysis Visualizations

### 1.1 NPS Trend Line Chart

**Location**: Left Column - NPS Action Plans Card
**Purpose**: Show NPS score trends over time to identify patterns and improvement/decline areas

**Chart Type**: Line Chart with Area Fill
**Dimensions**: Full card width × 200px height
**Data Source**: `nps_responses` table, aggregated by period

**Visual Specifications**:

- **X-Axis**: Time periods (Q1 2024, Q2 2024, Q3 2024, Q4 2024, Q1 2025)
- **Y-Axis**: NPS Score (0-10 scale)
- **Line Color**:
  - Gradient from red (0-6) → yellow (7-8) → green (9-10)
  - Primary line: `#8B5CF6` (purple-600)
- **Area Fill**: Semi-transparent gradient `rgba(139, 92, 246, 0.1)` to `rgba(139, 92, 246, 0.3)`
- **Data Points**: Circular markers with white border
- **Threshold Lines**:
  - Detractor threshold (0-6): Red dashed line
  - Passive threshold (7-8): Yellow dashed line
  - Promoter threshold (9-10): Green dashed line
- **Hover State**: Tooltip showing:
  - Period
  - Average score
  - Total responses
  - Breakdown: X promoters, Y passives, Z detractors

**Data Structure**:

```typescript
interface NPSTrendData {
  period: string // "Q1 2024"
  averageScore: number // 7.8
  totalResponses: number // 15
  promoters: number // 8
  passives: number // 4
  detractors: number // 3
}
```

**Mock Data Example**:

- Q1 2024: Avg 7.2, 12 responses (5 promoters, 4 passives, 3 detractors)
- Q2 2024: Avg 7.8, 18 responses (10 promoters, 5 passives, 3 detractors)
- Q3 2024: Avg 8.1, 15 responses (9 promoters, 4 passives, 2 detractors)
- Q4 2024: Avg 7.5, 20 responses (11 promoters, 6 passives, 3 detractors)
- Q1 2025: Avg 8.3, 10 responses (7 promoters, 2 passives, 1 detractor)

---

### 1.2 NPS Category Breakdown Bar Chart

**Location**: Left Column - NPS Action Plans Card (below trend)
**Purpose**: Show which NPS categories have the most feedback volume

**Chart Type**: Horizontal Stacked Bar Chart
**Dimensions**: Full card width × 150px height
**Data Source**: Aggregated from extracted themes in `useNPSAnalysis`

**Visual Specifications**:

- **Y-Axis**: Theme categories (Product Features, Training & Support, Response Time, etc.)
- **X-Axis**: Response count (0 to max)
- **Bar Segments**:
  - Positive: Green `#10B981`
  - Neutral: Yellow `#F59E0B`
  - Negative: Red `#EF4444`
- **Bar Height**: 24px with 8px gap
- **Labels**: Category name on left, total count on right
- **Hover State**: Show exact counts for each sentiment

**Data Structure**:

```typescript
interface NPSCategoryBreakdown {
  category: string
  positive: number
  neutral: number
  negative: number
  total: number
}
```

---

### 1.3 Sentiment Distribution Pie Chart

**Location**: Left Column - NPS Action Plans Card (summary section)
**Purpose**: Quick visual of overall sentiment distribution

**Chart Type**: Donut Chart
**Dimensions**: 120px × 120px (compact)
**Data Source**: Aggregated sentiment from all NPS responses

**Visual Specifications**:

- **Segments**:
  - Promoters (9-10): Green `#10B981`
  - Passives (7-8): Yellow `#F59E0B`
  - Detractors (0-6): Red `#EF4444`
- **Center Text**: Overall NPS score (large, bold)
- **Labels**: Percentage per segment
- **Hover State**: Show exact count and percentage

---

## 2. Portfolio Initiatives Visualizations

### 2.1 Initiative Completion Progress Chart

**Location**: Left Column - Portfolio Initiatives Card
**Purpose**: Show completion progress across different initiative categories

**Chart Type**: Grouped Column Chart
**Dimensions**: Full card width × 200px height
**Data Source**: `usePortfolioInitiatives` hook, grouped by category

**Visual Specifications**:

- **X-Axis**: Initiative categories (Training, Integration, Optimization, Security, etc.)
- **Y-Axis**: Count (0 to max)
- **Column Groups**:
  - 2024: Purple `#8B5CF6`
  - 2025: Blue `#3B82F6`
- **Column Width**: 16px with 4px gap between groups
- **Hover State**:
  - Category name
  - Year
  - Completed / Total
  - Completion rate %

**Data Structure**:

```typescript
interface CategoryProgress {
  category: string
  year2024: { completed: number; total: number }
  year2025: { completed: number; total: number }
}
```

**Example Categories**:

- Training (2024: 4/4, 2025: 1/1)
- Integration (2024: 2/3, 2025: 0/1)
- Optimization (2024: 3/3, 2025: 0/0)
- Security (2024: 2/2, 2025: 1/1)
- Feature Adoption (2024: 3/3, 2025: 1/2)
- Compliance (2024: 1/1, 2025: 0/0)

---

### 2.2 Initiative Timeline Gantt Chart

**Location**: Left Column - Portfolio Initiatives Card (expandable section)
**Purpose**: Visual timeline of all initiatives showing start, duration, and status

**Chart Type**: Horizontal Timeline/Gantt
**Dimensions**: Full card width × 400px height (scrollable)
**Data Source**: Full initiative list from `usePortfolioInitiatives`

**Visual Specifications**:

- **Y-Axis**: Initiative names (truncated to 30 chars)
- **X-Axis**: Timeline (Jan 2024 - Jun 2025)
- **Bar Colors by Status**:
  - Completed: Green `#10B981`
  - In Progress: Blue `#3B82F6`
  - Planned: Gray `#9CA3AF`
  - Cancelled: Red `#EF4444` (strikethrough)
- **Bar Height**: 20px with 6px gap
- **Milestones**: Diamond markers for completion dates
- **Hover State**:
  - Initiative name (full)
  - Category
  - Start date → Completion date
  - Duration (days)
  - Status
  - Description (first 100 chars)

---

### 2.3 Year-over-Year Completion Comparison

**Location**: Right Column - Success Scorecard
**Purpose**: Compare portfolio success between years

**Chart Type**: Radial Progress Chart (dual rings)
**Dimensions**: 180px × 180px
**Data Source**: `portfolioStats.byYear`

**Visual Specifications**:

- **Inner Ring**: 2024 completion rate
  - Color: Purple `#8B5CF6`
  - Thickness: 16px
- **Outer Ring**: 2025 completion rate
  - Color: Blue `#3B82F6`
  - Thickness: 16px
- **Center Text**:
  - "2024" label with completion %
  - "2025" label with completion %
- **Legend**: Color-coded year labels below

---

## 3. Engagement & Activity Visualizations

### 3.1 Meeting Activity Heatmap

**Location**: Right Column - Intelligence Panel
**Purpose**: Show meeting frequency patterns over time

**Chart Type**: Calendar Heatmap
**Dimensions**: Full card width × 120px height
**Data Source**: `unified_meetings` table aggregated by date

**Visual Specifications**:

- **Grid**: Week-by-week calendar view (last 12 weeks)
- **Cell Size**: 12px × 12px with 2px gap
- **Color Intensity**:
  - 0 meetings: `#F3F4F6` (gray-100)
  - 1 meeting: `#DDD6FE` (purple-200)
  - 2 meetings: `#C4B5FD` (purple-300)
  - 3+ meetings: `#8B5CF6` (purple-600)
- **Hover State**: Date + meeting count
- **Labels**: Week numbers on Y-axis, month labels on X-axis

---

### 3.2 Action Item Burn-down Chart

**Location**: Right Column - Intelligence Panel
**Purpose**: Track action item completion velocity

**Chart Type**: Area Chart with Line Overlay
**Dimensions**: Full card width × 150px height
**Data Source**: `actions` table with temporal grouping

**Visual Specifications**:

- **X-Axis**: Last 8 weeks
- **Y-Axis**: Action count
- **Area (background)**: Created actions (light blue)
- **Line (foreground)**: Completed actions (green)
- **Gap Area**: Outstanding actions (red tint)
- **Trend Line**: Projected completion (dashed)
- **Hover State**: Week + created vs completed counts

---

## 4. Financial Health Visualizations

### 4.1 Accounts Aging Distribution

**Location**: Right Column - Financial Health Summary
**Purpose**: Show receivables aging breakdown

**Chart Type**: Stacked Bar Chart (horizontal single bar)
**Dimensions**: Full card width × 60px height
**Data Source**: Aging accounts data

**Visual Specifications**:

- **Segments** (left to right):
  - Current (0-30 days): Green `#10B981`
  - 31-60 days: Yellow `#F59E0B`
  - 61-90 days: Orange `#F97316`
  - 90+ days: Red `#EF4444`
- **Height**: 40px
- **Labels**: Percentage per segment inside bars
- **Total Amount**: Displayed above bar
- **Hover State**: Exact amount per bucket

---

### 4.2 Revenue Trend Sparkline

**Location**: Right Column - Financial Health Summary
**Purpose**: Quick trend indicator for billing

**Chart Type**: Sparkline (mini line chart)
**Dimensions**: 80px × 30px (compact)
**Data Source**: Historical billing data

**Visual Specifications**:

- **Line**: Smooth curve, 2px thickness
- **Color**: Green if trending up, Red if trending down
- **No axes or labels**: Pure visual indicator
- **Hover State**: Show last 6 months values

---

## 5. Compliance & Risk Visualizations

### 5.1 Event Type Compliance Grid

**Location**: Left Column - Compliance Card (new)
**Purpose**: Show compliance status across all required event types

**Chart Type**: Grid/Matrix Heatmap
**Dimensions**: Full card width × 180px height
**Data Source**: `event_types` table with compliance calculations

**Visual Specifications**:

- **Grid Layout**: 3×4 grid of event type cards
- **Card Size**: ~90px × 40px each
- **Card Colors**:
  - Compliant (≥100%): Green `#10B981`
  - Warning (75-99%): Yellow `#F59E0B`
  - Critical (<75%): Red `#EF4444`
  - N/A: Gray `#9CA3AF`
- **Card Content**:
  - Event type icon (top-left)
  - Compliance % (large, center)
  - "X of Y" count (small, bottom)
- **Hover State**: Full event type name + detailed breakdown

---

## 6. Implementation Technical Specs

### 6.1 Charting Library

**Library**: Recharts v2.x
**Reason**:

- Native React integration
- Composable components
- Responsive by default
- TypeScript support
- Good documentation

**Installation**:

```bash
npm install recharts
```

### 6.2 Component Structure

```
src/components/charts/
├── NPSTrendChart.tsx
├── NPSCategoryChart.tsx
├── SentimentPieChart.tsx
├── PortfolioProgressChart.tsx
├── InitiativeTimelineChart.tsx
├── YearComparisonRadial.tsx
├── MeetingHeatmap.tsx
├── ActionBurndownChart.tsx
├── AgingBarChart.tsx
├── RevenueSparkline.tsx
└── ComplianceGrid.tsx
```

### 6.3 Shared Chart Utilities

```typescript
// src/lib/chartUtils.ts
export const chartColors = {
  primary: '#8B5CF6', // purple-600
  success: '#10B981', // green-500
  warning: '#F59E0B', // yellow-500
  danger: '#EF4444', // red-500
  info: '#3B82F6', // blue-500
  neutral: '#9CA3AF', // gray-400
}

export const chartTheme = {
  fontSize: 12,
  fontFamily: 'Inter, sans-serif',
  gridColor: '#E5E7EB', // gray-200
  tooltipBg: '#1F2937', // gray-800
  tooltipText: '#F9FAFB', // gray-50
}

// Responsive config
export const responsiveConfig = {
  desktop: { width: '100%', height: 300 },
  tablet: { width: '100%', height: 250 },
  mobile: { width: '100%', height: 200 },
}
```

### 6.4 Data Fetching Patterns

- Use existing hooks: `useNPSAnalysis`, `usePortfolioInitiatives`
- Create new hooks: `useMeetingActivity`, `useActionBurndown`, `useComplianceMetrics`
- All hooks follow pattern:
  - Return `{ data, loading, error }`
  - Handle empty states gracefully
  - Cache results with React Query (future enhancement)

### 6.5 Responsive Behavior

- **Desktop (>1024px)**: Full-sized charts with all features
- **Tablet (768-1024px)**: Slightly compressed, maintain readability
- **Mobile (<768px)**: Stack vertically, simplified tooltips, touch-friendly

### 6.6 Performance Considerations

- Lazy load charts using React.lazy()
- Debounce hover interactions (100ms)
- Limit data points for sparklines (max 20)
- Use React.memo for chart components
- Virtual scrolling for long timelines (>50 items)

---

## 7. Mock Data Specifications

All mock data is temporary and will be replaced with real Supabase queries. Mock data should:

- Reflect realistic patterns
- Include edge cases (empty states, single data point, etc.)
- Use consistent date ranges (Jan 2024 - Dec 2025)
- Follow TypeScript interfaces strictly

---

## 8. Accessibility Requirements

All charts must:

- Include ARIA labels: `aria-label="NPS trend chart showing scores from Q1 2024 to Q1 2025"`
- Support keyboard navigation for interactive elements
- Provide screen-reader-friendly data tables (hidden visually)
- Meet WCAG 2.1 AA color contrast ratios (4.5:1 minimum)
- Include alt text descriptions for key insights

---

## 9. Testing Checklist

Before considering implementation complete:

- [ ] All charts render without errors
- [ ] Loading states display correctly
- [ ] Empty states show appropriate messaging
- [ ] Error states handled gracefully
- [ ] Tooltips work on hover/touch
- [ ] Charts resize responsively
- [ ] Data updates reflect in real-time
- [ ] Performance: <500ms render time
- [ ] No console errors or warnings
- [ ] TypeScript types are correct
- [ ] Accessibility audit passes

---

## 10. Implementation Priority

**Phase 1 (Critical - Implement First)**:

1. NPS Trend Line Chart
2. Portfolio Progress Chart
3. Sentiment Pie Chart

**Phase 2 (High Priority)**: 4. Initiative Timeline 5. NPS Category Breakdown 6. Year-over-Year Comparison

**Phase 3 (Nice-to-Have)**: 7. Meeting Heatmap 8. Action Burndown 9. Aging Bar Chart 10. Compliance Grid 11. Revenue Sparkline

---

## 11. Future Enhancements

- Export charts as PNG/PDF
- Drill-down interactions (click chart to filter data)
- Custom date range selectors
- Chart configuration presets
- Dashboard layout customization
- Real-time data streaming
- Comparative analysis (client A vs client B)

---

**End of Document**
