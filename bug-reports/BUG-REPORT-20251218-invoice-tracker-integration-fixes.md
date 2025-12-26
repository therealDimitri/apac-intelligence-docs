# Bug Report: Invoice Tracker Integration Fixes

**Date:** 18 December 2025
**Status:** Resolved
**Severity:** High
**Component:** Ageing Accounts / Invoice Tracker Integration

---

## Summary

The Invoice Tracker integration was failing to connect to the live API, and the dashboard was displaying inaccurate data due to incorrect URL configuration, authentication header issues, and inclusion of unassigned clients in totals.

---

## Issues Identified

### Issue 1: Incorrect Invoice Tracker URL

**Symptom:** "Failed to fetch from Invoice Tracker: Unauthorized" error
**Root Cause:** Environment variable `INVOICE_TRACKER_URL` was set to `https://invoice-tracker.altera-apac.com` which returned NXDOMAIN (domain doesn't exist)
**Resolution:** Updated to correct URL `https://invoice.alteraapacai.dev`

**File Modified:** `.env.local`

```diff
- INVOICE_TRACKER_URL=https://invoice-tracker.altera-apac.com
+ INVOICE_TRACKER_URL=https://invoice.alteraapacai.dev
```

### Issue 2: Authentication Failing with "Bad Request"

**Symptom:** Auth endpoint returning "Bad Request" even with correct credentials
**Root Cause:** Invoice Tracker API requires `Content-Type: application/json; charset=utf-8` header (not just `application/json`)
**Resolution:** Added charset to Content-Type header in auth requests

**Files Modified:**

- `src/app/api/invoice-tracker/aging/route.ts`
- `src/app/api/invoice-tracker/aging-by-cse/route.ts`

```typescript
// Before
headers: { 'Content-Type': 'application/json' }

// After
headers: { 'Content-Type': 'application/json; charset=utf-8' }
```

### Issue 3: Error Handling Not Clearing on Fallback Success

**Symptom:** Error message displayed even when database fallback succeeded
**Root Cause:** Error state was set before attempting fallback, not cleared on success
**Resolution:** Restructured error handling to only set error if both Invoice Tracker AND database fallback fail

**File Modified:** `src/hooks/useAgingAccounts.ts`

```typescript
} catch (err) {
  console.error('Error fetching aging accounts data:', err)

  if (source === 'invoice-tracker') {
    console.log('Falling back to database source...')
    try {
      await fetchFromDatabase()
      setError(null)  // Clear error if fallback succeeds
    } catch (dbErr) {
      console.error('Database fallback also failed:', dbErr)
      setError(err as Error)  // Only set error if both fail
    }
  } else {
    setError(err as Error)
  }
}
```

### Issue 4: Unassigned Clients Included in Totals

**Symptom:** Dashboard showing 14 clients with $3,310,934 total, including unassigned clients (IQHT, Philips Electronics Australia, Provation)
**Root Cause:** No filtering of "Unassigned" CSE group from data display
**Resolution:** Filter out unassigned clients from display and calculations

**File Modified:** `src/app/(dashboard)/aging-accounts/page.tsx`

Changes made:

1. Filtered out `cseName === 'Unassigned'` from `allClients` array
2. Removed "Unassigned" from CSE dropdown filter
3. Removed `UnmatchedClientsWarning` component
4. Removed unused imports (`AlertCircle`, `unmatchedClients`)

```typescript
// Filter out unassigned clients
const allClients = useMemo(() => {
  return agingData
    .filter(cseData => cseData.cseName !== 'Unassigned')
    .flatMap(cseData => /* ... */)
}, [agingData])

// Filter out from CSE dropdown
const cses = useMemo(() => {
  const unique = new Set(agingData.filter(d => d.cseName !== 'Unassigned').map(d => d.cseName))
  return Array.from(unique).sort()
}, [agingData])
```

---

## CSE Assignments Added

Added 5 new CSE-to-client mappings to `cse_client_assignments` table:

| Client Name                       | CSE Name           |
| --------------------------------- | ------------------ |
| Singapore Health Services Pte Ltd | BoonTeck Lim       |
| South Australia Health            | Laura Messing      |
| Strategic Asia Pacific Partners   | Gilbert So         |
| Strategic Asia Pacific Partners,  | Gilbert So         |
| Barwon Health Australia           | Jonathan Salisbury |

---

## Data Reconciliation

Post-fix verification confirmed all values match between Invoice Tracker source and Dashboard:

| Metric            | Invoice Tracker | Dashboard  | Status |
| ----------------- | --------------- | ---------- | ------ |
| Total Outstanding | $3,202,240      | $3,202,240 | ✓      |
| Current           | $2,466,889      | $2,466,889 | ✓      |
| 31-60 Days        | $343,542        | $343,542   | ✓      |
| 61-90 Days        | $240,894        | $240,894   | ✓      |
| 90+ Days          | $150,915        | $150,915   | ✓      |
| Client Count      | 11 (assigned)   | 11         | ✓      |

---

## Files Modified

1. `.env.local` - URL correction
2. `src/app/api/invoice-tracker/aging/route.ts` - Content-Type header
3. `src/app/api/invoice-tracker/aging-by-cse/route.ts` - Content-Type header
4. `src/hooks/useAgingAccounts.ts` - Error handling
5. `src/app/(dashboard)/aging-accounts/page.tsx` - Unassigned client filtering

---

## Testing Performed

1. Verified Invoice Tracker API authentication succeeds
2. Confirmed live data loads on Ageing Accounts page
3. Verified all bucket totals match source system
4. Confirmed client-level amounts reconcile
5. Verified CSE assignments display correctly
6. Confirmed unassigned clients excluded from display and totals

---

## Related Configuration

**Invoice Tracker API Endpoints:**

- Auth: `POST /api/auth/login`
- Aging Report: `GET /api/aging-report`

**Required Headers:**

```
Content-Type: application/json; charset=utf-8
Authorization: Bearer {token}
```

**Environment Variables:**

```
INVOICE_TRACKER_URL=https://invoice.alteraapacai.dev
INVOICE_TRACKER_EMAIL={service_account_email}
INVOICE_TRACKER_PASSWORD={service_account_password}
```
