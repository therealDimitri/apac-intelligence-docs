# Feature: Support Health Page - Phase 3 (Advanced Features)

**Date:** 8 January 2026
**Status:** ✅ Completed
**Related:** FEATURE-20260108-support-health-phase1.md, FEATURE-20260108-support-health-phase2.md

## Overview

Phase 3 adds advanced features to the Support Health page:
- Segment grouping option for clients
- Drill-down modals for detailed metric analysis
- Service Credits tracking panel
- Known Problems display panel
- New database tables for enhanced data tracking

## Database Changes

### New Tables Created

#### 1. `support_service_credits`
Tracks quarterly SLA performance and service credits issued.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| client_name | TEXT | Client identifier |
| canonical_name | TEXT | Normalised client name |
| quarter | TEXT | e.g., Q1-2024 |
| fiscal_year | INTEGER | Fiscal year |
| metric_type | TEXT | Resolution Time, Response Time, Availability |
| target_performance | DECIMAL(5,2) | Target SLA percentage |
| actual_performance | DECIMAL(5,2) | Actual performance achieved |
| met | BOOLEAN | Whether target was met |
| quarterly_payment | DECIMAL(12,2) | Contract payment amount |
| service_credit | DECIMAL(12,2) | Credit issued if breached |

#### 2. `support_known_problems`
Tracks known issues/bugs affecting clients.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| client_name | TEXT | Client identifier |
| problem_number | TEXT | Unique problem ID |
| priority | TEXT | Critical, High, Medium, Low |
| status | TEXT | Open, In Progress, Pending Fix, Closed |
| target_release | TEXT | Target fix release version |
| product | TEXT | Affected product |
| description | TEXT | Problem description |
| workaround | TEXT | Temporary workaround if available |

#### 3. `support_case_details`
Individual case-level data for drill-down analysis.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| client_name | TEXT | Client identifier |
| case_number | TEXT | Support case ID |
| priority | TEXT | 1 - Critical, 2 - High, etc. |
| status | TEXT | Open, Closed, Pending |
| product | TEXT | Associated product |
| days_open | INTEGER | Age of the case |
| resolution_sla_met | BOOLEAN | Met resolution SLA |
| response_sla_met | BOOLEAN | Met response SLA |

### Schema Modifications

- Added `client_segment` column to `support_sla_metrics` table
- Auto-populates from `clients` table where available

### Migration Applied

```bash
node scripts/apply-support-phase3-migration.mjs
```

## Files Created

### API Endpoints

1. **`/api/support-metrics/cases/route.ts`**
   - GET endpoint for case-level details
   - Supports client, priority, status filters
   - Returns summary with counts by priority/status

2. **`/api/support-metrics/service-credits/route.ts`**
   - GET endpoint for service credits data
   - Supports client, year, quarter filters
   - Returns summary with compliance rate

3. **`/api/support-metrics/problems/route.ts`**
   - GET endpoint for known problems
   - Supports client, status, priority, product filters
   - Returns summary with counts by priority/status

### UI Components

1. **`SupportDrillDownModal.tsx`**
   - Modal component for detailed metric analysis
   - Supports drill-down types: health, sla, csat, aging, critical, open
   - Displays component breakdowns, historical trends, case lists
   - Animated progress bars with Framer Motion

2. **`ServiceCreditsPanel.tsx`**
   - Collapsible panel showing quarterly SLA reviews
   - Summary cards: Met, Missed, Quarters, Credits
   - Colour-coded list of credit records
   - Currency formatting in AUD

3. **`KnownProblemsPanel.tsx`**
   - Collapsible panel showing known issues
   - Filters by priority and status
   - Priority breakdown summary
   - Workaround badges with tooltips
   - Product and target release information

### Updated Files

1. **`SupportOverviewTable.tsx`**
   - Added `client_segment` to SupportMetrics interface
   - Added 'segment' to GroupBy type
   - Updated getGroupKey function for segment grouping
   - Added Segment option to Group By dropdown

2. **`support/page.tsx`**
   - Added imports for new components
   - Added ServiceCreditsPanel and KnownProblemsPanel in 2-column grid

3. **`support/index.ts`**
   - Added exports for new components

## Feature Details

### 1. Segment Grouping

Clients can now be grouped by segment (Platinum, Gold, Silver, etc.):
- Available in the "Group By" dropdown
- Shows group headers with aggregate stats
- Segment data sourced from `clients` table

### 2. Drill-Down Modal

Click on any metric to see detailed breakdown:

**Health Score Drill-Down:**
- Overall score with status badge
- Component breakdown with weights (SLA 40%, CSAT 30%, Aging 20%, Critical 10%)
- Animated progress bars
- Historical trend sparkline

**SLA Drill-Down:**
- Response and Resolution SLA percentages
- Breach count alert
- Availability percentage

**CSAT Drill-Down:**
- Large score display
- Survey stats (sent/completed)
- Response rate with progress bar

**Aging Drill-Down:**
- Total aging 30d+ count
- Age bucket breakdown with visualisation
- Priority indicator

**Open Cases Drill-Down:**
- Priority breakdown grid
- Recent cases list (if case details available)

### 3. Service Credits Panel

Displays quarterly SLA performance reviews:
- Compliance rate badge in header
- Quick stats: Met, Missed, Quarters tracked, Credits issued
- Expandable list of all credit records
- Met/Missed visual indicators

### 4. Known Problems Panel

Displays tracked known issues:
- Critical/Pending/Workaround badges in header
- Filter dropdowns for priority and status
- Priority breakdown grid
- Detailed problem cards with:
  - Problem number
  - Priority badge
  - Workaround indicator
  - Product and target release info
  - Status badge

## Testing

### Manual Testing Steps

1. Navigate to `/support` page
2. Verify Group By dropdown includes "Segment" option
3. Select Segment grouping and verify clients are grouped
4. Scroll down to see Service Credits and Known Problems panels
5. Expand/collapse panels
6. Use filters in Known Problems panel
7. (Note: Panels will show empty state until data is imported)

### Verified Behaviour

- ✅ TypeScript compilation passes
- ✅ Segment grouping option available
- ✅ Service Credits Panel renders correctly
- ✅ Known Problems Panel renders correctly
- ✅ Empty states display appropriately
- ✅ Database tables created successfully

## Data Population

The new tables require data import from Excel reports:
- Service Credits: Import from "Service Credit" worksheet
- Known Problems: Import from "Problems" worksheet
- Case Details: Import from "Resolution Details" or "Open Aging Cases" worksheets

## Dependencies

- `framer-motion` - Animations (existing)
- `lucide-react` - Icons (existing)
- `@supabase/supabase-js` - Database client (existing)

## Future Enhancements (Phase 4)

From SUPPORT-HEALTH-RECOMMENDATIONS.md:
- Excel export with formatting
- Scheduled email reports
- Print-friendly dashboard view
