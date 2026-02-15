# Bug Report: ChaSen Conversation Creation Failure

**Date:** 2025-12-18
**Status:** Fixed
**Severity:** Medium
**Component:** FloatingChaSenAI

## Issue Summary

ChaSen AI was failing to create conversations due to a context validation mismatch between the frontend component and the API endpoint.

## Symptoms

1. Console error: `[FloatingChaSenAI] Failed to create conversation`
2. Conversations were not being persisted to the database
3. API returned 400 error with message: `Context must be one of: portfolio, client, general`

## Root Cause

The `createConversation` function in `FloatingChaSenAI.tsx` was sending `context.page` directly to the API:

```typescript
body: JSON.stringify({
  title,
  context: context.page, // Sends 'meetings', 'actions', 'nps', etc.
  client_name: context.focusedClient || null,
  model_id: null,
})
```

However, the API endpoint `/api/chasen/conversations` (route.ts:50-52) validates that context must be one of `['portfolio', 'client', 'general']`:

```typescript
const validContexts = ['portfolio', 'client', 'general']
if (!validContexts.includes(context)) {
  return createErrorResponse(
    'INVALID_CONTEXT',
    `Context must be one of: ${validContexts.join(', ')}`,
    400
  )
}
```

The valid `PageContext` types from `src/types/chasen.ts` are:

- `'dashboard'`
- `'clients'`
- `'segmentation'`
- `'nps'`
- `'meetings'`
- `'actions'`
- `'ai'`
- `'guides'`
- `'apac'`

None of these match the API's expected values.

## Solution

Added a helper function `getApiContext()` in `FloatingChaSenAI.tsx` (line 304-328) to map page context values to valid API context values:

```typescript
const getApiContext = (): 'portfolio' | 'client' | 'general' => {
  // If there's a focused client, use 'client' context
  if (context.focusedClient) {
    return 'client'
  }

  // Map page types to API context
  // All data-related pages are portfolio context
  switch (context.page) {
    case 'meetings':
    case 'actions':
    case 'nps':
    case 'dashboard':
    case 'clients':
    case 'segmentation':
    case 'apac':
      return 'portfolio'
    case 'ai':
    case 'guides':
      return 'general'
    default:
      return 'general'
  }
}
```

The `createConversation` function now uses this helper:

```typescript
const apiContext = getApiContext()
const res = await fetch('/api/chasen/conversations', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    title,
    context: apiContext,
    client_name: context.focusedClient || null,
    model_id: null,
  }),
})
```

## Context Mapping Logic

| Page Context             | API Context | Reasoning                                 |
| ------------------------ | ----------- | ----------------------------------------- |
| `meetings`               | `portfolio` | Meetings view shows portfolio-wide data   |
| `actions`                | `portfolio` | Actions view shows portfolio-wide actions |
| `nps`                    | `portfolio` | NPS view shows portfolio-wide feedback    |
| `dashboard`              | `portfolio` | Dashboard shows portfolio overview        |
| `clients`                | `portfolio` | Clients list is portfolio-wide            |
| `segmentation`           | `portfolio` | Segmentation is portfolio-wide analysis   |
| `apac`                   | `portfolio` | APAC view is portfolio-wide               |
| `ai`                     | `general`   | AI/ChaSen page is general context         |
| `guides`                 | `general`   | Guides page is general context            |
| _any with focusedClient_ | `client`    | When a specific client is selected        |

## Related Fix (Same Session)

Also fixed a duplicate React key warning for `gpt-4o` in the model selector dropdown by adding deduplication logic:

```typescript
const uniqueModels = models.filter(
  (model: any, index: number, self: any[]) =>
    index === self.findIndex(m => m.model_key === model.model_key)
)
setAvailableModels(uniqueModels)
```

## Files Modified

- `src/components/FloatingChaSenAI.tsx`
  - Added `getApiContext()` helper function (lines 304-328)
  - Updated `createConversation()` to use helper (line 331)
  - Added model deduplication (lines 46-50)

## Testing

1. Build verification: `npm run build` - Success
2. Verify conversation creation works from any page
3. Verify conversations persist to database
4. Verify no console errors appear

## Prevention

Consider:

1. Creating a shared type for valid API context values
2. Adding TypeScript type checking between frontend and backend context values
3. Updating API to accept page context values directly and map internally
