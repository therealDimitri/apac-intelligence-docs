# Bug Report: Financials Page alerts.filter Undefined Error

**Date**: 2026-01-26
**Severity**: High
**Status**: Fixed

## Issue Description

The financials page (`/financials`) was crashing with the error:
```
TypeError: undefined is not an object (evaluating 'alerts.filter')
```

This prevented users from accessing the CSI ratios and BURC performance data.

## Root Cause

The `/api/analytics/financial-actions` API wraps its response using `createSuccessResponse()`, which returns:
```json
{
  "success": true,
  "data": {
    "alerts": [...],
    "actions": [...],
    "summary": {...}
  }
}
```

However, the financials page was setting state with the entire response object:
```typescript
const actionsResult = await actionsRes.json()
setData(actionsResult)  // Sets { success: true, data: {...} }
```

Then later destructuring directly:
```typescript
const { alerts, actions, summary } = data  // alerts is undefined!
```

Since `data.alerts` doesn't exist (it's `data.data.alerts`), the subsequent `alerts.filter()` call threw the error.

## Solution

1. Extract the `data` property when setting state:
```typescript
setData(actionsResult.data || actionsResult)
```

2. Add defensive defaults when destructuring:
```typescript
const { alerts = [], actions = [], summary } = data
```

## Files Modified

- `/src/app/(dashboard)/financials/page.tsx` - Fixed data extraction and added defensive defaults

## Prevention

1. When using `createSuccessResponse()` wrapper, always access `.data` when consuming the response
2. Add defensive defaults for arrays that will have methods called on them
3. Consider standardising API response handling across all pages

## Related

This is a common pattern issue - other pages may have similar bugs if they consume APIs that use `createSuccessResponse()`.
