# Bug Report: Outlook Sync Modal Showing 0 Meetings

## Issue
The Outlook sync modal was displaying "Found 0 meetings" despite the API successfully returning 200+ calendar events from Microsoft Graph.

## Date
2025-01-26

## Symptoms
- User clicks "Sync Outlook" button on the Meetings page
- Modal opens showing "Found 0 meetings"
- API endpoint `/api/outlook/preview` was actually returning 200+ meetings successfully
- Browser evaluate confirmed `data.data?.meetings?.length` returned 200, but modal showed 0

## Root Cause
Mismatch between the standardized API response structure and how the frontend component accessed it.

### The Problem
The `createSuccessResponse()` utility in `api-utils.ts` wraps all response data in a `data` property:

```typescript
// API returns:
{
  success: true,
  data: {
    meetings: [...],  // 200+ meetings here
    metadata: {...}
  }
}
```

But `OutlookSyncButton.tsx` was accessing:
```typescript
// OLD CODE (BUGGY):
const categorizedMeetings = (data.meetings || []).map(...)
// data.meetings is undefined → falls back to empty array
```

### The Fix
```typescript
// NEW CODE (CORRECT):
const categorizedMeetings = (data.data?.meetings || []).map(...)
// data.data.meetings correctly accesses the meetings array
```

## Files Affected
- `src/components/OutlookSyncButton.tsx` - Main sync modal component

## Changes Made

### 1. Preview Response Handling (line 393)
```typescript
// Before:
const categorizedMeetings = (data.meetings || []).map(...)

// After:
const categorizedMeetings = (data.data?.meetings || []).map(...)
```

### 2. Error Response Handling (lines 377-389)
Error responses also have a standardized structure `{ success: false, error: { code, message, details } }`:

```typescript
// Before:
if (data.code === 'TOKEN_EXPIRED' || data.code === 'NO_ACCESS_TOKEN')
const errorMsg = data.error || 'Failed to preview calendar'
const fullError = data.suggestion ? `${errorMsg}\n\n${data.suggestion}` : errorMsg

// After:
if (data.error?.code === 'TOKEN_EXPIRED' || data.error?.code === 'NO_ACCESS_TOKEN')
const errorMsg = data.error?.message || 'Failed to preview calendar'
const suggestion = data.error?.details?.suggestion
const fullError = suggestion ? `${errorMsg}\n\n${suggestion}` : errorMsg
```

### 3. Import Results Handling (lines 494-498)
```typescript
// Before:
throw new Error(data.error || 'Failed to import meetings')
setResult(data)

// After:
throw new Error(data.error?.message || 'Failed to import meetings')
setResult(data.data || data)
```

## Related Fixes
This bug was discovered while investigating the Outlook calendar import feature. A separate API-level fix was also applied in a previous commit (a3345d4f) to use the `/me/calendarView` endpoint instead of `/me/calendar/events` with `$filter` for more reliable date range queries.

## Testing
- Build passes with zero TypeScript errors
- Browser evaluate confirms correct data access pattern:
  - Old pattern (`data.meetings`): returns 0 meetings
  - New pattern (`data.data?.meetings`): returns 200 meetings
- Error handling correctly logs debug info and extracts error messages

## Prevention
- When using standardized API response utilities (`createSuccessResponse`, `createErrorResponse`), always remember:
  - Success: Access data via `response.data.yourProperty`
  - Error: Access error info via `response.error.code`, `response.error.message`, `response.error.details`

## Status
RESOLVED
