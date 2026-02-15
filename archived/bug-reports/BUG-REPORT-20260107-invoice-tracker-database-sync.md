# Bug Report: Invoice Tracker Data Not Syncing to Database

**Date:** 2026-01-07
**Status:** Fixed
**Priority:** High
**Category:** Data Sync

---

## Summary

The `aging_accounts` database table contained stale Excel import data from November 2025, while the Invoice Tracker API had current data. This caused Health Scores, ChaSen AI, and other features to use outdated financial data.

---

## Problem Description

### Symptoms
- `aging_accounts` table showed 20 clients with $1.8M outstanding
- Data source was `excel_import` from 2025-11-10
- Invoice Tracker API showed 11 clients with $2.96M outstanding
- Health Score calculations used stale AR aging data

### Root Cause
The `useAgingAccounts` hook was designed to fetch **live data from Invoice Tracker** for UI display (which works correctly), but there was **no mechanism to sync this live data to the database table**. The database only received one-time Excel imports.

### Affected Features
| Feature | Issue |
|---------|-------|
| Health Score (Working Capital component) | Using stale AR aging data |
| ChaSen AI daily insights | Using stale financial data |
| ChaSen AI recommendations | Using stale financial data |
| Churn prediction model | Using stale financial data |
| Team performance API | Using stale financial data |
| BURC alert detection | Using stale financial data |

---

## Architecture Analysis

### Data Flow (Before Fix)
```
Invoice Tracker API ──→ useAgingAccounts hook ──→ UI (live data) ✅
                        ╳
                   (no sync mechanism)
                        ╳
                       Database (stale Excel import) ❌
                        │
                        └──→ Health Scores, ChaSen AI, etc. (stale data)
```

### Data Flow (After Fix)
```
Invoice Tracker API ──→ useAgingAccounts hook ──→ UI (live data) ✅
        │
        └──→ sync-invoice-tracker-to-database.mjs ──→ Database (live data) ✅
                                                       │
                                                       └──→ Health Scores, ChaSen AI, etc. (live data)
```

---

## Solution

### Created Sync Script
**File:** `scripts/sync-invoice-tracker-to-database.mjs`

The script:
1. Authenticates with Invoice Tracker API
2. Fetches current aging report
3. Excludes non-revenue invoices (Credit Memos, Vendor Invoices, etc.)
4. Matches clients to CSE assignments
5. Excludes non-CSE owned clients (Provation, IQHT, Philips, Altera)
6. Upserts data to `aging_accounts` table

### Usage
```bash
node scripts/sync-invoice-tracker-to-database.mjs
```

### Output
```
=== Syncing Invoice Tracker to Database ===

URL: https://invoice.alteraapacai.dev

1. Authenticating with Invoice Tracker...
   ✅ Authenticated

2. Fetching aging report...
   ✅ Received aging report, generated: 2026-01-07T06:29:36.648Z

3. Getting excluded invoice types...
   Excluding 176 invoices (Credit Memos, Vendor Invoices, etc.)

4. Fetching CSE assignments...
   ✅ Found 25 CSE assignments

5. Processing aging data...

6. Preparing database records...
   ✅ Prepared 11 records

7. Updating database...
   ✅ Deleted old records
   ✅ Inserted 11 records

=== Sync Complete ===

Summary:
  - Clients synced: 11
  - Total outstanding: $2,964,518.00
  - Data source: invoice_tracker_api
  - Sync date: 2026-01-07
```

---

## Verification

### Before Fix
```sql
SELECT data_source, import_date, COUNT(*), SUM(total_outstanding)
FROM aging_accounts
GROUP BY data_source, import_date;

-- Result:
-- data_source    | import_date | count | sum
-- excel_import   | 2025-11-10  | 20    | 1,800,000
```

### After Fix
```sql
SELECT data_source, import_date, COUNT(*), SUM(total_outstanding)
FROM aging_accounts
GROUP BY data_source, import_date;

-- Result:
-- data_source         | import_date | count | sum
-- invoice_tracker_api | 2026-01-07  | 11    | 2,964,518
```

---

## Recommendations

### Automated Sync
Consider adding the sync script to:
1. **Cron job** - Run daily to keep data fresh
2. **Health score snapshot cron** - Trigger before calculating health scores
3. **Vercel cron** - Add to existing scheduled jobs

### Example Cron Entry
```bash
# Run Invoice Tracker sync daily at 6 AM
0 6 * * * cd /path/to/apac-intelligence-v2 && node scripts/sync-invoice-tracker-to-database.mjs
```

---

## Files Changed

| File | Change |
|------|--------|
| `scripts/sync-invoice-tracker-to-database.mjs` | **Created** - New sync script |
| `docs/CHART-DATA-SOURCES-INVENTORY.md` | **Updated** - Marked aging accounts as synced |

---

## Related Documentation

- [Chart Data Sources Inventory](../CHART-DATA-SOURCES-INVENTORY.md)
- [Health Score Config](../../src/lib/health-score-config.ts)
- [useAgingAccounts Hook](../../src/hooks/useAgingAccounts.ts)
