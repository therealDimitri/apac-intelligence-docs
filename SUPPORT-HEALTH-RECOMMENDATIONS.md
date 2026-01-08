# Support Health Page Enhancement Recommendations

**Date:** 8 January 2026
**Based on:** Excel data analysis, UI/UX research from Zendesk, Freshdesk, Intercom, ServiceNow, Jira Service Management

---

## Executive Summary

The current Support Health page displays basic metrics from the `support_sla_metrics` table. Analysis of client Support Dashboard Excel files reveals **significantly more data available** that could enhance the dashboard. This document provides recommendations for:

1. **Historical Data Storage Strategy** - How to store monthly snapshots for trend analysis
2. **Additional Data to Capture** - New fields from Excel worksheets
3. **UI/UX Enhancements** - Based on industry best practices
4. **Implementation Priority** - Phased approach

---

## Part 1: Historical Data Storage Strategy

### Current State
- `support_sla_metrics` table stores one record per client per period
- Only 7 records currently (latest month for 6 clients)
- No historical trend data preserved

### Recommended Approach: Monthly Snapshots

#### Option A: Append-Only Pattern (Recommended)
Keep all monthly records in `support_sla_metrics` with composite unique key:

```sql
-- Add unique constraint for client + period
ALTER TABLE support_sla_metrics
ADD CONSTRAINT support_sla_metrics_client_period_unique
UNIQUE (client_name, period_end);

-- Index for efficient querying
CREATE INDEX idx_support_metrics_client_period
ON support_sla_metrics (client_name, period_end DESC);
```

**Benefits:**
- Simple querying for trends
- No data migration needed
- Natural time-series analysis

#### Option B: Separate History Table
```sql
CREATE TABLE support_metrics_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  snapshot_date DATE NOT NULL,
  metrics JSONB NOT NULL, -- Full metrics object
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (client_name, snapshot_date)
);
```

**Benefits:**
- Main table stays lean
- JSONB allows schema flexibility
- Good for archival

### Recommended: Option A
The append-only pattern is simpler and allows direct SQL queries for trend analysis without JSON parsing.

---

## Part 2: Additional Data to Capture

### Data Available in Excel Files (Not Currently Captured)

| Worksheet | Data Available | Priority | Use Case |
|-----------|---------------|----------|----------|
| **Resolution Details** | Per-case resolution times, breach reasons | High | Root cause analysis |
| **Response Details** | First response times by priority | High | SLA monitoring |
| **Case Volume** | Incoming vs Closed by month (historical) | High | Volume trends |
| **Age Bucket** | Cases by product (Sunrise, Opal) | Medium | Product health |
| **Problems** | Known issues, target releases | Medium | Proactive alerts |
| **Enhancements** | Enhancement requests, status | Medium | Client roadmap |
| **Service Credit** | Quarterly SLA performance, credits issued | High | Financial impact |
| **Professional Services** | PS cases, assigned resources | Low | Resource planning |
| **Availability** | PM, SO, UO, SE breakdown | High | Uptime details |
| **Case Survey** | Individual survey responses | Medium | Detailed CSAT |

### Recommended New Tables

#### 1. Support Case Details (for drill-down)
```sql
CREATE TABLE support_case_details (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  case_number TEXT NOT NULL,
  priority TEXT, -- Critical, High, Moderate, Low
  status TEXT, -- Open, Closed, Pending
  product TEXT, -- Sunrise Acute Care, Opal, etc.
  opened_date DATE,
  closed_date DATE,
  resolution_sla_met BOOLEAN,
  response_sla_met BOOLEAN,
  days_open INTEGER,
  assigned_to TEXT,
  period_end DATE NOT NULL,
  UNIQUE (case_number, period_end)
);
```

#### 2. Service Credits
```sql
CREATE TABLE support_service_credits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  quarter TEXT NOT NULL, -- Q1-2024, Q2-2024
  metric_type TEXT NOT NULL, -- Resolution Time, Availability
  target_performance DECIMAL(5,2),
  actual_performance DECIMAL(5,2),
  met BOOLEAN,
  quarterly_payment DECIMAL(12,2),
  service_credit DECIMAL(12,2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (client_name, quarter, metric_type)
);
```

#### 3. Known Problems
```sql
CREATE TABLE support_problems (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  problem_number TEXT NOT NULL,
  priority TEXT,
  status TEXT, -- Pending Permanent Fix, Closed, Workaround Provided
  target_release TEXT,
  description TEXT,
  year_opened INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (problem_number)
);
```

#### 4. System Availability Details
```sql
CREATE TABLE support_availability (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  period_month DATE NOT NULL,
  possible_minutes INTEGER,
  scheduled_outage_minutes INTEGER,
  unscheduled_outage_minutes INTEGER,
  severity_exception_minutes INTEGER,
  availability_percent DECIMAL(5,2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (client_name, period_month)
);
```

---

## Part 3: UI/UX Enhancement Recommendations

### Based on Industry Research (Zendesk, Freshdesk, ServiceNow)

### 3.1 Dashboard Layout Redesign

#### Current Layout
- Summary cards (6 metrics)
- Single table with all clients

#### Recommended Layout

```
┌─────────────────────────────────────────────────────────────────┐
│  SUMMARY CARDS (4)                    │  QUICK ACTIONS          │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐     │  • View Critical Cases  │
│  │Total│ │ SLA │ │Aging│ │ At  │     │  • Export Report        │
│  │Open │ │ %   │ │30d+ │ │Risk │     │  • Schedule Review      │
│  └─────┘ └─────┘ └─────┘ └─────┘     │                         │
├─────────────────────────────────────────────────────────────────┤
│  TREND CHARTS (Collapsible Section)                             │
│  ┌──────────────────┐  ┌──────────────────┐                     │
│  │ Case Volume      │  │ SLA Compliance   │                     │
│  │ (Line Chart)     │  │ (Area Chart)     │                     │
│  │ 6-month trend    │  │ 6-month trend    │                     │
│  └──────────────────┘  └──────────────────┘                     │
├─────────────────────────────────────────────────────────────────┤
│  TABS: [ Overview ] [ By CSE ] [ By Product ] [ Trends ]        │
├─────────────────────────────────────────────────────────────────┤
│  CLIENT TABLE (Expandable Rows)                                 │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ Client │ Health │ Open │ SLA% │ CSAT │ Aging │ ▶ Details   ││
│  ├─────────────────────────────────────────────────────────────┤│
│  │ ▼ WA Health                                                 ││
│  │   ├─ Case Breakdown: P1(0) P2(3) P3(12) P4(2)              ││
│  │   ├─ Age Buckets: [0-7d: 5] [8-30d: 8] [31-60d: 3] [60+: 1]││
│  │   └─ Products: Sunrise(12), Opal(5)                        ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Specific UI Components

#### A. Health Score Ring (Enhanced)
Current: Simple percentage ring
Recommended: Multi-ring showing component breakdown

```tsx
// Component breakdown ring
<HealthScoreRing
  score={75}
  components={{
    sla: 40,      // 40% weight
    csat: 30,     // 30% weight
    aging: 20,    // 20% weight
    critical: 10  // 10% weight
  }}
/>
```

#### B. SLA Compliance Gauge
Industry standard: Colour-coded gauge with threshold markers

```tsx
<SLAGauge
  value={94.5}
  thresholds={{
    critical: 90,
    warning: 95,
    target: 99
  }}
  showBreachCountdown={true}
/>
```

**Colour Scheme:**
- Green: ≥95% (Target met)
- Amber: 90-94% (Warning)
- Red: <90% (Critical)

#### C. Aging Tickets Visualisation
Horizontal stacked bar showing distribution:

```tsx
<AgingStackedBar
  data={{
    '0-7d': 12,
    '8-30d': 8,
    '31-60d': 4,
    '61-90d': 2,
    '90d+': 1
  }}
  colours={{
    '0-7d': '#10B981',    // Green
    '8-30d': '#3B82F6',   // Blue
    '31-60d': '#F59E0B',  // Amber
    '61-90d': '#F97316',  // Orange
    '90d+': '#EF4444'     // Red
  }}
/>
```

#### D. CSAT Display
Emoji-based with trend indicator:

```tsx
<CSATDisplay
  score={4.7}
  surveysCompleted={56}
  surveysSent={77}
  responseRate={72.7}
  trend="+0.2" // vs last month
/>
```

Visual: ⭐ 4.7 / 5.0 (72.7% response rate) ↑

#### E. Critical Alerts Banner
Prominent at-risk notification (Zendesk pattern):

```tsx
<AlertBanner severity="warning">
  <AlertIcon />
  <span>2 clients have SLA breaches this month</span>
  <Button variant="ghost">View Details →</Button>
</AlertBanner>
```

### 3.3 New Features to Add

#### Feature 1: Expandable Row Details
Click to expand any client row to see:
- Case breakdown by priority
- Age bucket distribution
- Product breakdown (Sunrise, Opal, etc.)
- Recent trend sparkline
- Quick action buttons

#### Feature 2: Trend Charts Section
6-month historical view showing:
- Case volume (incoming vs closed)
- SLA compliance percentage
- CSAT scores
- Backlog growth/reduction

#### Feature 3: Grouped Views
Tabs or dropdown to view data grouped by:
- CSE (see each CSE's portfolio health)
- Product (Sunrise vs Opal metrics)
- Segment (Platinum, Gold, Silver clients)

#### Feature 4: Export & Reporting
- Export to Excel (formatted report)
- Schedule monthly email reports
- Print-friendly view

#### Feature 5: Drill-Down Modal
Click any metric to see details:
- Which cases are aging?
- Which cases breached SLA?
- Survey response details

---

## Part 4: Implementation Priority

### Phase 1: Quick Wins (1-2 weeks)
1. ✅ Add historical data storage (composite key)
2. Add expandable row details
3. Enhance health score ring with breakdown
4. Add aging stacked bar visualisation

### Phase 2: Trend Analysis (2-3 weeks)
1. Add trend charts section
2. Implement 6-month historical view
3. Add sparklines to table rows
4. Create monthly snapshot sync job

### Phase 3: Advanced Features (3-4 weeks)
1. Add grouped views (by CSE, Product)
2. Implement drill-down modals
3. Add service credits tracking
4. Create known problems display

### Phase 4: Reporting (2 weeks)
1. Excel export with formatting
2. Scheduled email reports
3. Print-friendly dashboard view

---

## Part 5: Database Migration Scripts

### Migration 1: Add Historical Support
```sql
-- Enable historical tracking
ALTER TABLE support_sla_metrics
ADD CONSTRAINT support_sla_metrics_client_period_unique
UNIQUE (client_name, period_end);

-- Add indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_support_metrics_client
ON support_sla_metrics (client_name);

CREATE INDEX IF NOT EXISTS idx_support_metrics_period
ON support_sla_metrics (period_end DESC);

CREATE INDEX IF NOT EXISTS idx_support_metrics_health
ON support_sla_metrics (client_name, period_end DESC);
```

### Migration 2: Create Case Details Table
```sql
CREATE TABLE IF NOT EXISTS support_case_details (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  case_number TEXT NOT NULL,
  priority TEXT CHECK (priority IN ('1 - Critical', '2 - High', '3 - Moderate', '4 - Low')),
  status TEXT,
  product TEXT,
  opened_date DATE,
  closed_date DATE,
  resolution_sla_met BOOLEAN,
  response_sla_met BOOLEAN,
  days_open INTEGER,
  assigned_to TEXT,
  period_end DATE NOT NULL,
  source_file TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (case_number, period_end)
);

-- RLS Policy
ALTER TABLE support_case_details ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for support_case_details" ON support_case_details
  FOR ALL USING (true) WITH CHECK (true);

-- Index for efficient lookups
CREATE INDEX idx_case_details_client ON support_case_details (client_name);
CREATE INDEX idx_case_details_priority ON support_case_details (priority);
CREATE INDEX idx_case_details_product ON support_case_details (product);
```

---

## Part 6: Sync Script Enhancements

### Current Sync Script
- Extracts basic metrics from "SLA Compliance" worksheet
- Stores in `support_sla_metrics`

### Recommended Enhancements

```javascript
// Additional worksheets to parse
const WORKSHEETS_TO_PARSE = [
  { name: 'SLA Compliance', table: 'support_sla_metrics' },
  { name: 'Resolution Details', table: 'support_case_details' },
  { name: 'Open Aging Cases', table: 'support_case_details' },
  { name: 'Case Survey', table: 'support_surveys' },
  { name: 'Service Credit', table: 'support_service_credits' },
  { name: 'Problems', table: 'support_problems' },
  { name: 'Availability', table: 'support_availability' },
];

// Parse each worksheet and upsert to appropriate table
for (const config of WORKSHEETS_TO_PARSE) {
  const worksheet = workbook.Sheets[config.name];
  if (worksheet) {
    const data = parseWorksheet(worksheet, config.name);
    await upsertToTable(config.table, data);
  }
}
```

---

## Summary

| Category | Current | Recommended |
|----------|---------|-------------|
| **Data Storage** | Single latest record | Monthly historical snapshots |
| **Tables** | 1 (support_sla_metrics) | 5 (+ case_details, service_credits, problems, availability) |
| **UI Layout** | Basic table | Dashboard with trends, expandable rows, grouped views |
| **Visualisations** | Health ring only | Gauge, stacked bars, sparklines, trend charts |
| **Features** | View only | Export, drill-down, filters, alerts |

### Next Steps
1. Review and approve recommendations
2. Create database migrations
3. Enhance sync scripts
4. Implement UI changes in phases

---

*Document generated by Claude Code analysis of Support Dashboard Excel files and UI/UX research.*
