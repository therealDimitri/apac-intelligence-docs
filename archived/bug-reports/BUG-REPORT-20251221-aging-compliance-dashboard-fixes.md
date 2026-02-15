# Bug Report: Aging Compliance Dashboard Fixes

**Date:** 2025-12-21
**Status:** ✅ Resolved
**Components:** Executive View, KPI Cards, Trend Sparklines, Snapshot API

## Issues Identified and Fixed

### 1. AR Amount Reconciliation Mismatch

**Problem:**
Dollar amounts in the expanded KPI cards on the Executive View (AR Health tab) were not matching the actual bucket totals from the detailed view. The expanded content was using percentage-based calculations like `summary.totalOutstanding * 0.1` instead of actual bucket values.

**Root Cause:**
ExecutiveView.tsx was calculating expanded content values using hardcoded percentages instead of summing the actual bucket data from client records.

**Fix:**

- Added actual bucket totals calculation (`under60Total`, `days61to90Total`, `over90Total`) to the summary useMemo
- Updated Total AR Outstanding card's expandedContent to use `summary.under60Total`, `summary.days61to90Total`, `summary.over90Total`
- Updated Critical (90+ Days) card's expandedContent to use `summary.over90Total`

**Files Modified:**

- `src/app/(dashboard)/aging-accounts/compliance/components/ExecutiveView.tsx`

### 2. Trend Sparklines Not Centred

**Problem:**
TrendSparkline components in the detailed table view were not centred within their table cells.

**Fix:**
Changed container from `flex` to `inline-flex` with `justify-center` class.

**Files Modified:**

- `src/components/aged-accounts/TrendSparkline.tsx`

### 3. Trend Data Not Loading

**Problem:**
TREND column in the detailed table view was showing "—" for all clients instead of sparklines.

**Root Cause:**

1. Only one snapshot date existed in `aged_accounts_history` table (2025-12-20)
2. The `capture_aged_accounts_snapshot` RPC function relied on a non-existent `aged_accounts` table

**Fix:**

- Rewrote the POST endpoint in `/api/cron/aged-accounts-snapshot` to fetch data directly from Invoice Tracker API
- The endpoint now:
  - Authenticates with Invoice Tracker
  - Fetches aging report data
  - Transforms and aggregates client data into buckets
  - Upserts directly into `aged_accounts_history` table
- Created `scripts/backfill-trend-history.mjs` to generate 30 days of historical data for testing

**Files Modified:**

- `src/app/api/cron/aged-accounts-snapshot/route.ts`

**Files Created:**

- `scripts/backfill-trend-history.mjs`

### 4. Goal Badge Text Clarity

**Problem:**
The KPI card goal badge displayed "Missed" which was considered unclear.

**Fix:**
Changed "Missed" to "Goal Not Met" for better clarity.

**Files Modified:**

- `src/app/(dashboard)/aging-accounts/compliance/components/KPICard.tsx`

## Commits

1. `37516e4` - Fix AR amount reconciliation and trend sparkline centering
2. `9902eb8` - Fix snapshot API to use Invoice Tracker and update goal badge text
3. `ea2119c` - Add trend history backfill script

## Verification Steps

1. Navigate to Aging Accounts → Performance Dashboard (AR Health tab)
2. Expand the Total AR Outstanding KPI card - amounts should match detailed view
3. Expand the Critical (90+ Days) card - should show accurate 90+ amounts
4. Check the detailed view TREND column - sparklines should now appear with trend data
5. Verify goal badges show "Goal Not Met" instead of "Missed"

### 5. AI Insights 90+ Day Amount Not Reconciling

**Problem:**
The AI Insights summary was showing an incorrect "At-Risk Amount (90+ days)" that didn't match the actual bucket data.

**Root Cause:**
The `/api/chasen/ar-insights` endpoint was calculating `atRiskAmount` using a percentage-based formula (`totalOutstanding * (atRiskPercent / 100)`) instead of summing actual bucket values.

**Fix:**

- Calculate `atRiskAmount` by summing actual 90+ day bucket values from client data
- Then calculate `atRiskPercent` from the actual amount

**Files Modified:**

- `src/app/api/chasen/ar-insights/route.ts`

### 6. Historical Trend Chart Empty

**Problem:**
The historical trend chart on the AR Health tab was empty with no data.

**Root Cause:**
The `aging_compliance_history` table only had one week of data - no historical trend data existed.

**Fix:**
Created `scripts/backfill-compliance-history.mjs` to generate 12 weeks of historical CSE-level compliance data with realistic trend variations.

**Files Created:**

- `scripts/backfill-compliance-history.mjs`

### 7. CSE Goal Achievement Donut Chart Replaced

**Problem:**
The donut chart showing CSE Goal Achievement status was not intuitive - users wanted to see actual compliance percentages.

**Fix:**
Replaced the donut chart with a horizontal bar chart showing "Performance by CSE - % under 90 days (Goal: 100%)". Each CSE bar shows their compliance percentage with colour coding (green for meeting goal, red for not meeting).

**Files Modified:**

- `src/app/(dashboard)/aging-accounts/compliance/components/ExecutiveView.tsx`

### 8. Tab Renamed to Performance Dashboard

**Problem:**
"Compliance Dashboard" naming was considered too technical.

**Fix:**
Renamed the tab label from "Compliance Dashboard" to "Performance Dashboard".

**Files Modified:**

- `src/app/(dashboard)/aging-accounts/compliance/components/design-tokens.ts`
- `src/app/(dashboard)/aging-accounts/compliance/page.tsx`

### 9. Chart Titles Updated

**Problem:**
Chart titles showed "Compliance by CSE" which didn't match the new "Performance Dashboard" branding.

**Fix:**
Changed both chart titles to "Performance by CSE".

**Files Modified:**

- `src/app/(dashboard)/aging-accounts/compliance/components/ExecutiveView.tsx`

### 10. Historical Trend Line Colour Confusion

**Problem:**
The "Under 60 Days" line in the historical trend chart was purple (#a855f7), which was confusing with other purple elements on the page.

**Fix:**
Changed the line colour to emerald green (#10b981) to clearly distinguish it as a positive metric.

**Files Modified:**

- `src/app/(dashboard)/aging-accounts/compliance/components/ExecutiveView.tsx`

### 11. Chart White Space Optimisation

**Problem:**
Charts had excessive white space on the left side and weren't utilising available screen space.

**Fix:**

- Increased bar chart heights from h-72/h-64 to h-80
- Increased historical trend chart height from h-64 to h-72
- Reduced left margins from 10px to 0px to maximise chart area

**Files Modified:**

- `src/app/(dashboard)/aging-accounts/compliance/components/ExecutiveView.tsx`

## Commits

1. `37516e4` - Fix AR amount reconciliation and trend sparkline centering
2. `9902eb8` - Fix snapshot API to use Invoice Tracker and update goal badge text
3. `ea2119c` - Add trend history backfill script
4. `e48f4ea` - Fix AI insights 90+ amount and add compliance history backfill
5. `b2b9148` - Replace CSE Goal Achievement donut with % under 90 days bar chart
6. `a2ffe9a` - Improve Performance Dashboard charts layout and colours

## Verification Steps

1. Navigate to Aging Accounts → Performance Dashboard (AR Health tab)
2. Expand the Total AR Outstanding KPI card - amounts should match detailed view
3. Expand the Critical (90+ Days) card - should show accurate 90+ amounts
4. Check the detailed view TREND column - sparklines should now appear with trend data
5. Verify goal badges show "Goal Not Met" instead of "Missed"
6. Check AI Insights summary - 90+ day amount should match Critical card
7. Verify Historical Trend chart shows data for past 12 weeks
8. Verify both Performance by CSE charts display with larger dimensions
9. Confirm "Under 60 Days" historical line is green (not purple)

## Technical Notes

- The snapshot API now authenticates with Invoice Tracker using stored credentials
- Historical data was backfilled for 30 days with realistic trend variations (aged_accounts_history)
- Compliance history was backfilled for 12 weeks with CSE-level trends (aging_compliance_history)
- Client exclusion list (Provation, IQHT, Philips, Altera) is applied during snapshot capture
- Snapshot uses upsert with conflict on `(client_name, snapshot_date)` to handle duplicates
