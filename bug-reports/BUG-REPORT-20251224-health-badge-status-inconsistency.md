# Bug Report: Health Badge Status Inconsistency Between Summary and Detail Views

**Date:** 24 December 2024
**Status:** Fixed
**Severity:** Medium
**Component:** Client Health Status Display

## Summary

Health status badges displayed inconsistent values between the Client Profiles summary cards and the Client Detail page for the same client and health score.

## Symptoms

For a client with **Health Score: 70** (e.g., Grampians Health):

- **Summary Card** (Client Profiles page): Showed **"At-risk"** (amber badge)
- **Detail Page** (Client Profile v2): Showed **"Healthy"** (green badge)

## Root Cause

Three different threshold systems were being used across the application:

| Location                   | Source                  | Thresholds               | Score 70 Result |
| -------------------------- | ----------------------- | ------------------------ | --------------- |
| `client-profiles/page.tsx` | Inline calculation      | ≥75 Healthy, ≥50 At-risk | **At-risk**     |
| `LeftColumn.tsx`           | `client.status` from DB | Pre-calculated in view   | **Healthy**     |
| `health-score-config.ts`   | Centralised config      | ≥70 Healthy, ≥60 At-risk | **Healthy**     |

### Detailed Analysis

1. **Summary Card** (`client-profiles/page.tsx:338-339`):

   ```typescript
   // OLD: Hardcoded thresholds different from config
   const healthStatus = healthScore >= 75 ? 'Healthy' : healthScore >= 50 ? 'At-risk' : 'Critical'
   ```

2. **Detail Page** (`LeftColumn.tsx:471-474`):

   ```typescript
   // OLD: Used pre-stored client.status from database
   const normalizedStatus = (client.status || '').toLowerCase().replace(/\s+/g, '-')
   ```

3. **Centralised Config** (`health-score-config.ts:88-91`):
   ```typescript
   thresholds: {
     healthy: 70,  // >= 70 is Healthy
     atRisk: 60,   // >= 60 and < 70 is At-risk
   }
   ```

## Solution

Updated both components to use the centralised `getHealthStatus()` function from `@/lib/health-score-config`:

### Changes Made

**1. `src/app/(dashboard)/client-profiles/page.tsx`**

- Added import: `import { getHealthStatus } from '@/lib/health-score-config'`
- Replaced inline threshold calculation with `getHealthStatus(healthScore)`
- All colour/icon logic now derives from the centralised status

**2. `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`**

- Added import: `import { getHealthStatus } from '@/lib/health-score-config'`
- Replaced `client.status` database value with `getHealthStatus(healthScore)`
- Removed unused `normalizedStatus` variable

### Result

Both views now use identical thresholds:

- **Healthy:** Score ≥ 70
- **At-risk:** Score 60-69
- **Critical:** Score < 60

Score 70 now consistently shows **"Healthy"** across all views.

## Files Modified

1. `src/app/(dashboard)/client-profiles/page.tsx`
2. `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`

## Testing

- [x] TypeScript compilation passes
- [ ] Visual verification on Client Profiles page
- [ ] Visual verification on Client Detail page
- [ ] Verified thresholds match across all clients

## Prevention

The centralised `health-score-config.ts` file should be the **single source of truth** for:

- Health score thresholds
- Status determination logic
- Colour mappings

Any future health status displays must import and use `getHealthStatus()` rather than implementing inline threshold logic.

## Related Files

- `src/lib/health-score-config.ts` - Single source of truth for health thresholds
- `docs/DATABASE_STANDARDS.md` - Database column verification rules
