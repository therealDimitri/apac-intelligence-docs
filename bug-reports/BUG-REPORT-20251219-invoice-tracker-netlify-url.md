# Bug Report: Invoice Tracker Netlify Environment URL Misconfiguration

**Date**: 2025-12-19
**Status**: RESOLVED
**Severity**: High
**Component**: Invoice Tracker Integration (Production)

---

## Issue Summary

The live Netlify deployment is failing to fetch data from the Invoice Tracker API because the `INVOICE_TRACKER_URL` environment variable is pointing to a non-existent domain.

## Symptoms

- Live site (apac-cs-dashboards.com) shows incorrect/stale Working Capital Health data
- Dev site shows correct data (USD 42,429 for Albury Wodonga Health)
- Live site shows stale database fallback data (USD 28,090)
- Console shows: `Failed to fetch from Invoice Tracker (500): Internal server error`

## Root Cause

### DNS Resolution Failure

The Netlify environment variable `INVOICE_TRACKER_URL` is configured with a **non-existent domain**:

| Environment          | URL                                       | DNS Status                          |
| -------------------- | ----------------------------------------- | ----------------------------------- |
| Netlify (Production) | `https://invoice-tracker.altera-apac.com` | **NXDOMAIN - Domain doesn't exist** |
| Local (Dev)          | `https://invoice.alteraapacai.dev`        | ✅ Resolves to `16.26.187.58`       |

### DNS Verification

```bash
$ nslookup invoice-tracker.altera-apac.com
** server can't find invoice-tracker.altera-apac.com: NXDOMAIN

$ nslookup invoice.alteraapacai.dev
Name:    invoice.alteraapacai.dev
Address: 16.26.187.58
```

### Failure Flow

1. User loads client profile on live site
2. Page calls `/api/invoice-tracker/aging-by-cse`
3. API attempts to authenticate with Invoice Tracker at `invoice-tracker.altera-apac.com`
4. DNS lookup fails immediately (NXDOMAIN)
5. Even with retry logic, all attempts fail
6. API returns HTTP 500
7. `useAgingAccounts.ts` hook detects failure
8. Hook falls back to querying `aging_accounts` database table
9. Database contains older/different data than live Invoice Tracker

## Solution

### Immediate Fix Required

Update Netlify environment variable:

**Current (broken):**

```
INVOICE_TRACKER_URL=https://invoice-tracker.altera-apac.com
```

**Correct (working):**

```
INVOICE_TRACKER_URL=https://invoice.alteraapacai.dev
```

### Steps to Fix

1. Go to Netlify Dashboard → Site Settings → Environment Variables
2. Find `INVOICE_TRACKER_URL`
3. Change value from `https://invoice-tracker.altera-apac.com` to `https://invoice.alteraapacai.dev`
4. Trigger a new deployment (Deploys → Trigger Deploy)

## Netlify Environment Variables (Current State)

From screenshot analysis:

- `INVOICE_TRACKER_EMAIL` = `dimitri.leimonitis@alterahealth.com` ✅
- `INVOICE_TRACKER_PASSWORD` = `Welcome01!` ✅
- `INVOICE_TRACKER_URL` = `https://invoice-tracker.altera-apac.com` ❌ **WRONG**

## Related Issues

This issue was discovered while investigating a separate DNS intermittent failure issue (see `BUG-REPORT-20251219-invoice-tracker-dns-retry.md`). The retry logic added in that fix is working correctly - the fundamental problem is the URL itself doesn't exist.

## Verification After Fix

After updating Netlify environment variable:

1. Trigger new deployment
2. Navigate to any client profile (e.g., Albury Wodonga Health)
3. Working Capital Health card should show USD 42,429 (matching Invoice Tracker)
4. Console should NOT show "Falling back to database source..."

---

**Resolution**: Updated Netlify environment variable `INVOICE_TRACKER_URL` from `https://invoice-tracker.altera-apac.com` to `https://invoice.alteraapacai.dev`. Live site now correctly fetches data from Invoice Tracker API.
