# Bug Report: Invoice Tracker DNS Resolution Failures

**Date**: 2025-12-19
**Status**: RESOLVED
**Severity**: Medium
**Component**: Invoice Tracker Integration

---

## Issue Summary

The Working Capital Health card was intermittently showing incorrect/stale data due to DNS resolution failures when fetching data from the Invoice Tracker external API.

## Symptoms

- Dev site showed different amounts (USD 28,090) compared to expected live data (USD 42,429)
- Console showed: `Failed to fetch from Invoice Tracker: Internal Server Error`
- Followed by: `Falling back to database source...`

## Root Cause Analysis

### Primary Cause: Intermittent DNS Resolution Failure

The Invoice Tracker API at `invoice.alteraapacai.dev` was experiencing intermittent DNS lookup failures on the dev machine/network.

**Server logs showed:**

```
[Invoice Tracker by CSE] Error: TypeError: fetch failed
  [cause]: Error: getaddrinfo ENOTFOUND invoice.alteraapacai.dev
```

### Failure Flow

1. User loads client profile page
2. Page calls `/api/invoice-tracker/aging-by-cse`
3. API attempts to authenticate with Invoice Tracker
4. DNS lookup for `invoice.alteraapacai.dev` fails intermittently
5. `fetch()` throws `ENOTFOUND` error
6. Catch block returns HTTP 500 Internal Server Error
7. `useAgingAccounts.ts` hook detects 500 status
8. Hook falls back to querying `aging_accounts` database table
9. Database contains older/different data than live Invoice Tracker

### Why Data Differed

- **Invoice Tracker (live)**: USD 42,429 (1 invoice for Albury Wodonga Health)
- **Database fallback (stale)**: USD 28,090 (historical data)

## Solution Implemented

Added `fetchWithRetry()` wrapper function with exponential backoff to both Invoice Tracker API routes.

### Files Modified

1. `src/app/api/invoice-tracker/aging-by-cse/route.ts`
2. `src/app/api/invoice-tracker/aging/route.ts`

### Retry Configuration

```typescript
const MAX_RETRIES = 3
const INITIAL_RETRY_DELAY = 500 // ms

// Exponential backoff: 500ms, 1000ms, 2000ms
```

### Retryable Errors

- `ENOTFOUND` - DNS lookup failure
- `ETIMEDOUT` - Connection timeout
- `ECONNRESET` - Connection reset
- `fetch failed` - Generic fetch failure

### Implementation

```typescript
async function fetchWithRetry(
  url: string,
  options: RequestInit,
  retries = MAX_RETRIES
): Promise<Response> {
  let lastError: Error | null = null

  for (let attempt = 0; attempt < retries; attempt++) {
    try {
      const response = await fetch(url, options)
      return response
    } catch (error) {
      lastError = error as Error
      const isRetryable =
        error instanceof Error &&
        (error.message.includes('ENOTFOUND') ||
          error.message.includes('ETIMEDOUT') ||
          error.message.includes('ECONNRESET') ||
          error.message.includes('fetch failed'))

      if (!isRetryable || attempt === retries - 1) {
        throw error
      }

      const delay = INITIAL_RETRY_DELAY * Math.pow(2, attempt)
      console.log(`[Invoice Tracker] Retry ${attempt + 1}/${retries} after ${delay}ms`)
      await new Promise(resolve => setTimeout(resolve, delay))
    }
  }

  throw lastError || new Error('Failed after retries')
}
```

## Testing

### Before Fix

- Random 500 errors during Invoice Tracker fetch
- Fallback to database with stale data

### After Fix

- Retry logic handles transient DNS failures
- Up to 3 attempts with exponential backoff (max ~3.5s total delay)
- Only falls back to database after all retries exhausted

## Prevention

### Short-term (Implemented)

- Retry logic with exponential backoff

### Medium-term (Recommended)

- Configure local DNS cache (e.g., dnsmasq)
- Add hostname to `/etc/hosts` for critical external services

### Long-term (Recommended)

- Implement scheduled sync to keep `aging_accounts` database in sync with Invoice Tracker
- Add monitoring for DNS resolution failures

## Verification

```bash
# Check TypeScript compilation
npx tsc --noEmit

# Check ESLint
npx eslint src/app/api/invoice-tracker --max-warnings=0
```

Both checks pass.

## Related Files

- `src/hooks/useAgingAccounts.ts` - Client-side hook with fallback logic
- `src/components/FinancialHealthCard.tsx` - Working Capital Health display component
- `docs/INVOICE-TRACKER-INTEGRATION-GUIDE.md` - Integration documentation

---

**Resolution**: Added retry logic with exponential backoff to Invoice Tracker API routes.
