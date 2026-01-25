# Bug Report: useUserProfile Unit Test Failures

**Date:** 2026-01-25
**Status:** Fixed
**Severity:** Low (Tests only, no production impact)
**Component:** Unit Tests (useUserProfile hook)

## Issue Summary

5 out of 9 useUserProfile unit tests were failing, plus Jest was incorrectly running Playwright E2E tests which caused additional suite failures (7 failed suites despite 56/56 tests passing).

## Root Causes

### 1. Missing direct reports query mocks
The `useUserProfile` hook makes a query for direct reports (`cse_profiles` where `reports_to = userEmail`), but tests didn't mock this call, causing the mock chain to be incomplete.

### 2. Migration uses `upsert`, not `insert`
The `migratePreferencesFromLocalStorage` function uses `supabase.from('user_preferences').upsert(...)` but tests were mocking `.insert()`.

### 3. Incorrect expected migration data
The `preferencesToDb` function intentionally excludes `default_view` due to DB CHECK constraints, but tests expected it to be present in the insert/upsert call.

### 4. Missing fields in mock profile data
Tests didn't include `job_description`, `is_global_role`, and `reports_to` fields in mock cse_profiles responses.

### 5. Jest running E2E tests
The Jest config included `tests/**/*.{spec,test}.{js,jsx,ts,tsx}` which picked up Playwright E2E tests from `tests/e2e/`.

## Fixes Applied

### 1. Added direct reports query mock to all tests
```typescript
const mockDirectReportsQuery = {
  select: jest.fn().mockReturnThis(),
  eq: jest.fn().mockResolvedValue({
    data: [],
    error: null,
  }),
}
```

### 2. Changed migration mock from `insert` to `upsert`
```typescript
// Before
mockSupabase.from.mockReturnValueOnce({ insert: mockInsert } as any)

// After
mockSupabase.from.mockReturnValueOnce({ upsert: mockUpsert } as any)
```

### 3. Fixed expected migration data
```typescript
expect(mockUpsert).toHaveBeenCalledWith(
  {
    user_email: 'test@example.com',
    default_segment_filter: 'Healthcare',  // No default_view
    favorite_clients: ['Client A', 'Client B'],
    hidden_clients: ['Client C'],
    notification_settings: legacyPreferences.notificationSettings,
    dashboard_layout: legacyPreferences.dashboardLayout,
  },
  { onConflict: 'user_email' }
)
```

### 4. Excluded E2E tests from Jest
Added to `jest.config.js`:
```javascript
testPathIgnorePatterns: [
  '<rootDir>/node_modules/',
  '<rootDir>/tests/e2e/', // E2E tests run with Playwright, not Jest
],
```

## Test Results

| Metric | Before | After |
|--------|--------|-------|
| useUserProfile tests passing | 4/9 | 9/9 |
| Test suites passing | 5/12 | 5/5 |
| Total tests passing | 56/56 | 56/56 |

## Files Modified

- `jest.config.js` - Added testPathIgnorePatterns for E2E tests
- `src/hooks/__tests__/useUserProfile.test.ts` - Fixed all 5 failing tests

## Verification

All tests now pass when running:
```bash
npm test
```

## Lessons Learned

1. **Always trace hook data flow** - Before writing mocks, read the hook implementation to understand all Supabase calls made
2. **Match mock to actual implementation** - If hook uses `upsert`, mock `upsert`, not `insert`
3. **Check function outputs** - The `preferencesToDb` function explicitly excludes certain fields - tests should reflect this
4. **Configure test runners properly** - Jest and Playwright have different test file conventions; configure ignore patterns appropriately
