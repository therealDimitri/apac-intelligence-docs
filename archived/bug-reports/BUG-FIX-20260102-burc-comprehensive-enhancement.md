# Bug Fix Report: BURC Comprehensive Enhancement

**Date:** 2 January 2026
**Severity:** High
**Status:** ✅ Resolved
**Reporter:** System
**Components Affected:** BURC Dashboard, Data Sync, Alerts, Notifications

---

## Summary

This report documents a comprehensive enhancement to the BURC (Business Unit Review Committee) Executive Dashboard, including multiple bug fixes and new feature implementations.

---

## Issues Resolved

### 1. NRR/GRR Showing 0% (Critical)

**Problem:** Net Revenue Retention (NRR) and Gross Revenue Retention (GRR) were displaying 0% despite having valid historical revenue data.

**Root Cause:** The `burc_revenue_retention` database view filtered for `revenue_type = 'Total Revenue'`, but the sync script was inserting individual revenue types ('Hardware', 'License', 'Maintenance', 'Professional Services') instead of a pre-aggregated 'Total Revenue' row.

**Solution:**
- Updated the view to aggregate all revenue types per customer using `SUM()` and `GROUP BY customer_name`
- Created migration: `20260102_fix_burc_revenue_aggregation.sql`
- Applied via direct database connection script

**Result:**
- 2024 NRR: 141.6% (was 0%)
- 2024 GRR: 100.0% (was 0%)
- Rule of 40: 56.6 - Passing (was 15.0)

### 2. Pipeline Values Showing $0

**Problem:** Business cases/pipeline opportunities were showing $0 values.

**Root Cause:** The sync script was looking for a 'Business Cases' sheet that didn't exist. The actual data is stored in separate sheets (SW, PS, Maint, HW) with different column structures.

**Solution:**
- Updated `sync-burc-comprehensive.mjs` to parse all four revenue sheets
- Fixed column mapping: Revenue USD is in column 7 (index 6), not column 5
- Added proper stage detection from 'Forecast Category' column

**Result:**
- 121 pipeline opportunities with values (was 68 with $0)
- Total Pipeline: $54.9M
- Weighted Pipeline: $34.1M

### 3. Historical Revenue Missing Customer Names

**Problem:** Only 1 historical revenue record was being synced due to null customer names.

**Root Cause:** The Excel file uses merged cells for parent company and customer name columns, where only the first row of each group contains the value.

**Solution:**
- Implemented carry-forward logic to preserve parent company and customer name across rows
- Added null checks and proper row iteration

**Result:**
- 4 historical revenue records (was 1)
- Proper year values: 2023: $7.53M, 2024: $10.66M

---

## New Features Implemented

### 1. Netlify Scheduled Functions (Cron Jobs)

Created two scheduled functions in `netlify/functions/`:

| Function | Schedule | Purpose |
|----------|----------|---------|
| `burc-data-sync.mts` | 6:30 AM AEST daily | Triggers BURC data sync |
| `burc-alert-check.mts` | 7:30 AM AEST daily | Checks thresholds and sends notifications |

### 2. Alert Threshold Configuration

- **Component:** `src/components/burc/AlertThresholdConfig.tsx`
- **API:** `src/app/api/analytics/burc/alerts/thresholds/route.ts`
- **Database:** `burc_alert_thresholds` table with default KPI thresholds
- **Features:**
  - Configure warning and critical thresholds per KPI
  - Enable/disable individual alerts
  - Comparison operators (lt, gt, lte, gte, eq)
  - Real-time alert refresh on save

### 3. Email Alerts

- **API:** `src/app/api/analytics/burc/email-alerts/route.ts`
- **Integration:** Resend email service
- **Features:**
  - HTML-formatted alert emails
  - Critical vs warning severity indicators
  - Links to BURC dashboard
  - Targets leaders and managers from cse_profiles

### 4. Teams Notifications

- **Library:** `src/lib/teams-notifications.ts`
- **API:** `src/app/api/analytics/burc/teams-notify/route.ts`
- **Features:**
  - MessageCard format with adaptive cards
  - Alert notifications with severity colours
  - Daily summary cards
  - Deep links to dashboard

### 5. Trend Charts

- **Component:** `src/components/burc/KPITrendChart.tsx`
- **Features:**
  - Area/line charts with gradients
  - Warning/critical threshold reference lines
  - Trend indicators (up/down/flat)
  - Mini sparkline variant
  - Multiple colour themes

### 6. Drill-Down Views

- **Component:** `src/components/burc/BURCDrillDown.tsx`
- **API:** `src/app/api/analytics/burc/drill-down/route.ts`
- **Features:**
  - Expandable client details
  - Revenue breakdown
  - Pipeline by opportunity
  - Attrition risk details
  - Contract information

### 7. Export Functionality

- **Component:** `src/components/burc/BURCExport.tsx`
- **API:** `src/app/api/analytics/burc/export/route.ts`
- **Formats:**
  - Excel (.xlsx) with multiple sheets
  - CSV (summary data)
  - PDF (printable HTML)

### 8. ChaSen AI Integration

- **Library:** `src/lib/chasen-burc-context.ts`
- **Features:**
  - BURC-specific query patterns
  - Real-time KPI context injection
  - Auto-generated insights
  - Natural language query handlers

### 9. Priority Matrix Linking

- **Library:** `src/lib/burc-priority-matrix.ts`
- **Features:**
  - Auto-maps attrition risks to Priority Matrix quadrants
  - Urgency/Impact calculation based on revenue
  - Suggested actions based on risk reason
  - Sync function for automated updates

---

## Database Changes

### New Tables

```sql
-- Alert thresholds configuration
CREATE TABLE burc_alert_thresholds (
  id UUID PRIMARY KEY,
  metric_name VARCHAR(100) UNIQUE,
  metric_category VARCHAR(100),
  warning_threshold NUMERIC,
  critical_threshold NUMERIC,
  comparison_operator VARCHAR(10),
  enabled BOOLEAN,
  description TEXT
);

-- Active alerts
CREATE TABLE burc_active_alerts (
  id UUID PRIMARY KEY,
  metric_name VARCHAR(100),
  metric_category VARCHAR(100),
  severity VARCHAR(20),
  current_value NUMERIC,
  threshold_value NUMERIC,
  message TEXT,
  priority_order INTEGER
);
```

### Modified Views

- `burc_revenue_retention` - Now aggregates all revenue types
- `burc_rule_of_40` - Now aggregates all revenue types
- `burc_executive_summary` - Added COALESCE for null safety

---

## Files Created/Modified

### New Files

1. `netlify/functions/burc-data-sync.mts`
2. `netlify/functions/burc-alert-check.mts`
3. `src/components/burc/AlertThresholdConfig.tsx`
4. `src/components/burc/BURCDrillDown.tsx`
5. `src/components/burc/BURCExport.tsx`
6. `src/components/burc/KPITrendChart.tsx`
7. `src/components/burc/index.ts`
8. `src/app/api/analytics/burc/email-alerts/route.ts`
9. `src/app/api/analytics/burc/teams-notify/route.ts`
10. `src/app/api/analytics/burc/drill-down/route.ts`
11. `src/app/api/analytics/burc/export/route.ts`
12. `src/app/api/analytics/burc/alerts/thresholds/route.ts`
13. `src/lib/teams-notifications.ts`
14. `src/lib/chasen-burc-context.ts`
15. `src/lib/burc-priority-matrix.ts`
16. `docs/migrations/20260102_fix_burc_revenue_aggregation.sql`
17. `docs/migrations/20260102_burc_alert_thresholds.sql`
18. `scripts/apply-burc-view-fix-final.mjs`

### Modified Files

1. `netlify.toml` - Added BURC cron schedules
2. `scripts/sync-burc-comprehensive.mjs` - Fixed parsing logic

---

## Testing

### Verification Commands

```bash
# Verify NRR/GRR values
node scripts/verify-burc-kpis.mjs

# Test export
curl http://localhost:3000/api/analytics/burc/export?format=csv

# Test Teams notification (requires webhook URL)
curl -X POST http://localhost:3000/api/analytics/burc/teams-notify \
  -H "Content-Type: application/json" \
  -d '{"type": "summary"}'
```

### Results After Fix

| Metric | Before | After |
|--------|--------|-------|
| NRR | 0% | 141.6% |
| GRR | 0% | 100.0% |
| Rule of 40 | 15.0 | 56.6 |
| Pipeline | $0 | $54.9M |
| Historical Revenue Records | 1 | 4 |

---

## Environment Variables Required

```env
# For Teams notifications
TEAMS_WEBHOOK_URL=https://outlook.office.com/webhook/...
TEAMS_WEBHOOK_ALERTS=https://outlook.office.com/webhook/...  # Optional separate channel
TEAMS_WEBHOOK_SUMMARY=https://outlook.office.com/webhook/...  # Optional separate channel

# For email alerts
RESEND_API_KEY=re_...

# For cron authentication
CRON_SECRET=your-secret-key
```

---

## Recommendations

1. **Configure Teams Webhooks:** Set up incoming webhooks in your Teams channels for alert and summary notifications
2. **Review Thresholds:** Adjust the default alert thresholds based on your business targets
3. **Monitor Sync Logs:** Check `burc_sync_log` table for sync status and errors
4. **Schedule Reviews:** Use the daily summary feature for executive morning briefings

---

## Related Documentation

- [BURC Enhancement Implementation Guide](../FEATURE-20260102-burc-enhancement-implementation.md)
- [Database Schema](../database-schema.md)
