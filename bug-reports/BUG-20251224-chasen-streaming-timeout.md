# Bug Report: ChaSen AI Streaming Error (HTTP 504 Timeout)

**Date:** 24 December 2025
**Status:** Fixed
**Severity:** High
**Component:** ChaSen AI > Streaming Chat

---

## Problem Description

ChaSen AI chat was showing "Sorry, I encountered an error while streaming. Please try again." The actual error was an HTTP 504 Gateway Timeout from the MatchaAI API.

### Console Error

```
[ChaSen Stream] Error: Error: HTTP 504:
```

---

## Root Cause Analysis

### Issue 1: No Fetch Timeout

The `callMatchaAI` function in `src/lib/ai-providers.ts` had no timeout configured for the fetch request. When the MatchaAI API took longer than the gateway's default timeout, a 504 error was returned.

**Before Fix:**

```ts
const response = await fetch(`${MATCHAAI_CONFIG.baseUrl}/completions`, {
  method: 'POST',
  headers: { ... },
  body: JSON.stringify({ ... }),
})
// No timeout - relies on gateway timeout (unpredictable)
```

### Issue 2: Preferences Migration Duplicate Key

The console also showed repeated "Failed to migrate preferences" errors. This was caused by using `insert` instead of `upsert` when migrating user preferences from localStorage to Supabase. If a row already existed, the insert would fail.

---

## Solution Implemented

### 1. Added Timeout to MatchaAI Fetch

Added `AbortController` with 55-second timeout (under typical gateway limits):

```ts
const controller = new AbortController()
const timeoutId = setTimeout(() => controller.abort(), timeout)

try {
  const response = await fetch(url, {
    ...options,
    signal: controller.signal,
  })
  clearTimeout(timeoutId)
  // ... handle response
} catch (error) {
  clearTimeout(timeoutId)
  if (error.name === 'AbortError') {
    throw new Error(`MatchaAI request timed out after ${timeout}ms`)
  }
  throw error
}
```

### 2. Fixed Preferences Migration

Changed from `insert` to `upsert` with `onConflict`:

```ts
const { error } = await supabase
  .from('user_preferences')
  .upsert({ user_email: userEmail, ...preferencesToDb(parsed) }, { onConflict: 'user_email' })
```

---

## Files Changed

| File                          | Changes                                                             |
| ----------------------------- | ------------------------------------------------------------------- |
| `src/lib/ai-providers.ts`     | Added timeout parameter, AbortController, and proper error handling |
| `src/hooks/useUserProfile.ts` | Changed `insert` to `upsert` for preferences migration              |

---

## Configuration

The default timeout is 55 seconds, but can be overridden:

```ts
await callMatchaAI(messages, {
  model: 'claude-3-7-sonnet',
  timeout: 30000, // 30 seconds
})
```

---

## Testing Steps

1. Start dev server: `npm run dev`
2. Navigate to ChaSen AI page
3. Send a message
4. Verify streaming response works without timeout error
5. Check console for no "Failed to migrate preferences" errors

---

## Related Systems

- MatchaAI API: Corporate AI proxy
- Supabase: user_preferences table
- Next.js streaming: SSE response handling
