# Bug Report: E2E Test Reliability Improvements

**Date:** 25 January 2025
**Category:** Testing Infrastructure
**Severity:** Medium
**Status:** Resolved

## Issue Summary

Mobile E2E tests were failing on production due to authentication timeouts and deprecated page URLs.

## Root Causes

1. **Authentication Timeout Issues**
   - Tests were using `waitForLoadState('networkidle')` which never resolves on production due to analytics scripts
   - Auth redirect timing was flaky, causing intermittent test failures
   - The dev-signin submit button click wasn't always triggering the redirect before the timeout

2. **Deprecated URL References**
   - Tests were navigating to `/clients` which is a deprecated page
   - The `/clients` page shows a deprecation notice and redirects to `/client-profiles`
   - This caused assertion failures as the page content didn't match expected selectors

## Solution Implemented

### 1. Robust Authentication Helper

Created a centralised `bypassAuth()` function in `tests/e2e/fixtures/auth-helpers.ts`:

```typescript
export async function bypassAuth(page: Page): Promise<void> {
  await page.goto('/auth/dev-signin')
  await page.waitForLoadState('load')

  const submitButton = page.locator('button[type="submit"]')
  await submitButton.waitFor({ state: 'visible', timeout: 10000 })
  await submitButton.click()

  // Use Promise.race for faster completion detection
  await Promise.race([
    page.waitForURL('/', { timeout: 30000 }),
    page.waitForURL(/^\/$/, { timeout: 30000 }),
    page.locator('main').waitFor({ state: 'visible', timeout: 30000 }),
  ])

  // Retry if still on dev-signin
  if (page.url().includes('/auth/dev-signin')) {
    await submitButton.click()
    await page.waitForURL('/', { timeout: 30000 })
  }
}
```

### 2. Load State Strategy

Changed from `waitForLoadState('networkidle')` to `waitForLoadState('load')` across all test files:
- `networkidle` waits for no network activity for 500ms, which never happens with analytics
- `load` event fires when the page has finished loading main resources, which is sufficient for testing

### 3. URL Path Updates

Updated all test files to use `/client-profiles` instead of deprecated `/clients`:
- `responsive-layout.spec.ts`
- `navigation.spec.ts`
- `touch-targets.spec.ts`
- `accessibility.spec.ts`
- `performance.spec.ts`

## Files Modified

- `tests/e2e/fixtures/auth-helpers.ts` - New robust auth helper
- `tests/e2e/mobile/responsive-layout.spec.ts` - Uses bypassAuth, load state, correct URLs
- `tests/e2e/mobile/navigation.spec.ts` - Uses bypassAuth, load state, correct URLs
- `tests/e2e/mobile/touch-targets.spec.ts` - Load state, correct URLs
- `tests/e2e/mobile/accessibility.spec.ts` - Load state, correct URLs
- `tests/e2e/mobile/performance.spec.ts` - Load state, correct URLs

## Test Results

**Before Fix:**
- 4-9 tests passing out of 19 (intermittent)
- Tests timing out during auth
- Failures on deprecated page content

**After Fix:**
- 19/19 tests passing consistently
- Auth completes reliably within 10 seconds
- All page navigations work correctly

## Verification

Run the following command to verify:

```bash
PLAYWRIGHT_BASE_URL=https://apac-cs-dashboards.com npx playwright test tests/e2e/mobile/responsive-layout.spec.ts --project=iphone-12
```

Expected output: `19 passed`

## Prevention

1. Always use the centralised `bypassAuth()` helper for authentication
2. Use `waitForLoadState('load')` instead of `networkidle` for production tests
3. Keep test URLs synchronised with actual navigation links in the app
4. Run E2E tests against production periodically to catch regressions
