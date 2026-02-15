# Bug Report: ChaSen Streaming Removed & Workflow Error Handling

**Date:** 2024-12-24
**Status:** Fixed
**Severity:** Functional

## Issues Addressed

### 1. Streaming Mode Removed

**Problem:** Streaming responses were causing blank response bubbles and UI issues during the "thinking" phase.

**Solution:** Removed streaming mode entirely and switched to batch-only mode.

**Changes:**

- Removed `streamingEnabled` and `isStreaming` state variables
- Removed `sendStreamingMessage` function
- Removed `stopStreaming` function
- Removed `abortControllerRef` reference
- Removed streaming toggle button from header UI
- Removed `Square` icon import (was used for stop button)
- Updated auto-scroll effect to only depend on `isLoading`
- Removed streaming branch from `handleSend` function

### 2. AI Workflow JSON Parse Error

**Problem:** ChaSen workflows were failing with:

```
SyntaxError: Unexpected token '<', "<HTML><HE"... is not valid JSON
```

This occurred when the MatchaAI API returned an HTML error page instead of JSON.

**Root Cause:** The `callMatchaAI` function in `src/lib/ai-providers.ts` was attempting to parse the response as JSON without first checking the content-type header.

**Solution:** Added content-type validation before JSON parsing:

```typescript
// Check content-type before parsing
const contentType = response.headers.get('content-type') || ''

// Ensure we received JSON, not HTML (e.g., error page or login redirect)
if (!contentType.includes('application/json')) {
  const responseText = await response.text()
  console.error('[MatchaAI] Unexpected response format:', {
    contentType,
    body: responseText.substring(0, 500),
  })
  throw new Error(
    `MatchaAI returned non-JSON response (${contentType || 'unknown'}). The API may be unavailable or returning an error page.`
  )
}
```

### 3. AI Crew Client Dropdown

**Problem:** Client name for AI Crew was a text input instead of a dropdown.

**Solution:** Converted to a native `<select>` dropdown populated with client names from the database.

## Files Modified

| File                              | Changes                                           |
| --------------------------------- | ------------------------------------------------- |
| `src/app/(dashboard)/ai/page.tsx` | Removed streaming code, updated imports           |
| `src/lib/ai-providers.ts`         | Added content-type validation before JSON parsing |

## Testing

To verify the fixes:

1. **Batch Mode:**
   - Navigate to `/ai`
   - Send a message to ChaSen
   - Verify response appears after processing (no streaming)
   - Confirm no blank response bubble during "thinking" phase

2. **Workflow Error Handling:**
   - Run a Portfolio Analysis workflow
   - If MatchaAI is down/returning errors, verify you get a clear error message instead of JSON parse error

3. **Client Dropdown:**
   - Expand "AI Crews" section in sidebar
   - Verify Client Name shows as a dropdown with all clients
   - Select a client and run a crew

## Prevention

- Use content-type checking before parsing any API response as JSON
- Test streaming features thoroughly before enabling by default
- Consider feature flags for experimental features
