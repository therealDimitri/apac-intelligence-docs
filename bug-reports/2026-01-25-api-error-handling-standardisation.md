# API Error Handling Standardisation

**Date:** 25 January 2026
**Type:** Enhancement / Technical Debt Resolution
**Status:** Completed
**Commit:** `4a7b7bc3`

## Summary

Migrated 68 API routes across 4 directories to use centralised error handling utilities from `@/lib/api-utils`, improving consistency, logging, and maintainability.

## Background

API routes were using inconsistent error handling patterns:
- Some used `NextResponse.json({ error: ... }, { status: ... })`
- Some wrapped errors manually with varying formats
- Error logging was inconsistent across endpoints
- No standardised error codes or response structure

## Changes Made

### Routes Migrated (68 total)

**Analytics (26 routes)**
- `ai-summary/route.ts`
- `burc/alerts/route.ts`
- `burc/alerts/thresholds/route.ts`
- `burc/client-revenue/route.ts`
- `burc/csi-insights/route.ts`
- `burc/csi-ratios/route.ts`
- `burc/drill-down/route.ts`
- `burc/email-alerts/route.ts`
- `burc/export/route.ts`
- `burc/financial-health/route.ts`
- `burc/historical/route.ts`
- `burc/matrix-items/route.ts`
- `burc/pipeline-items/route.ts`
- `burc/suppliers/route.ts`
- `burc/sync-notifications/route.ts`
- `burc/sync/route.ts`
- `burc/teams-notify/route.ts`
- `churn-prediction/route.ts`
- `contract-renewals/route.ts`
- `dashboard/route.ts`
- `financial-actions/route.ts`
- `health-prediction/route.ts`
- `insights/route.ts`
- `meetings/route.ts`
- `ml-forecast/route.ts`
- `trends/route.ts`

**ChaSen AI (31 routes)**
- `action-context/route.ts`
- `analytics/route.ts`
- `analyze/route.ts`
- `anomalies/route.ts`
- `ar-insights/route.ts`
- `conversations/[id]/messages/route.ts`
- `conversations/[id]/route.ts`
- `correlations/route.ts`
- `daily-insights/route.ts`
- `data-sources/route.ts`
- `email-assist/route.ts`
- `feedback/route.ts`
- `folders/route.ts`
- `index/route.ts`
- `knowledge/route.ts`
- `knowledge/setup/route.ts`
- `learn/route.ts`
- `learned-qa/route.ts`
- `meeting-prep/route.ts`
- `memories/route.ts`
- `methodology/route.ts`
- `nps-insights/route.ts`
- `nps-sentiment/route.ts`
- `products/route.ts`
- `recommend-actions/route.ts`
- `signals/route.ts`
- `suggestions/route.ts`
- `summary/route.ts`
- `track-interaction/route.ts`
- `upload/route.ts`
- `workflow/route.ts`

**Compliance (3 routes)**
- `events/bulk/route.ts`
- `events/sync/route.ts`
- `export/route.ts`

**Cron Jobs (8 routes)**
- `aged-accounts-snapshot/route.ts`
- `chasen-auto-discover/route.ts`
- `compliance-snapshot/route.ts`
- `cse-emails/route.ts`
- `graph-embed/route.ts`
- `proactive-insights/route.ts`
- `segmentation-refresh/route.ts`
- `support-health-report/route.ts`

### Pattern Applied

**Before:**
```typescript
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  try {
    // ... business logic
    return NextResponse.json({ success: true, data })
  } catch (error) {
    console.error('[Endpoint] Error:', error)
    return NextResponse.json(
      { error: error instanceof Error ? error.message : 'Failed' },
      { status: 500 }
    )
  }
}
```

**After:**
```typescript
import { NextRequest } from 'next/server'
import { createSuccessResponse, createErrorResponse, handleApiError } from '@/lib/api-utils'

export async function GET(request: NextRequest) {
  try {
    // ... business logic
    return createSuccessResponse(data)
  } catch (error) {
    return handleApiError(error, 'GET /api/endpoint')
  }
}
```

### Type Safety Improvements

Also fixed pre-existing TypeScript `any` types with proper interfaces:

**`/api/analytics/insights/route.ts`:**
- Added `NPSMetrics`, `MeetingsMetrics`, `ActionsMetrics`, `ComplianceMetrics`, `AllMetrics` interfaces
- Updated all `generateXInsights(data: any)` functions to use typed parameters

**`/api/analytics/trends/route.ts`:**
- Added `NPSResponseItem`, `MeetingItem`, `ActionItem`, `TrendResult` interfaces
- Updated helper functions to use proper types instead of `any`

**`/api/chasen/track-interaction/route.ts`:**
- Changed `interactionData?: any` to `interactionData?: Record<string, unknown>`
- Fixed nested type assertions for `contextData.eventCompliance`

### Routes Skipped

- `burc/route.ts` - Already used `handleApiError`

### Special Handling

Some routes retained `NextResponse` where needed for:
- Binary responses (CSV/Excel exports in `burc/export/route.ts`, `compliance/export/route.ts`)
- Cache-Control headers (in `burc/client-revenue/route.ts`, `burc/financial-health/route.ts`, `burc/historical/route.ts`)

## Testing

1. Build passed with zero TypeScript errors
2. ESLint/Prettier passed all staged files
3. Netlify deployment successful
4. Site responding with HTTP 200

## Benefits

1. **Consistency**: All API routes now use the same error response format
2. **Better Logging**: `handleApiError` automatically logs with context (endpoint path)
3. **Type Safety**: Proper interfaces instead of `any` types
4. **Maintainability**: Single source of truth for error handling logic
5. **Code Reduction**: -303 lines net (1079 added, 1382 removed)

## Files Changed

73 files changed, 1079 insertions(+), 1382 deletions(-)

## Related

- Error handling utilities: `/src/lib/api-utils.ts`
- Standardised response types: `ApiSuccessResponse`, `ApiErrorResponse`
