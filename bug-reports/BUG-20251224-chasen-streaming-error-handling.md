# Bug Report: ChaSen AI Streaming Error Handling Improvements

**Date:** 24 December 2025
**Status:** Fixed
**Severity:** Medium
**Component:** ChaSen AI > Streaming Chat > Error Handling

---

## Problem Description

After fixing the HTTP 504 timeout issue, users were still seeing generic error messages ("Sorry, I encountered an error while streaming. Please try again.") without any indication of what actually went wrong. This made debugging and troubleshooting difficult.

### Issues Identified

1. **Generic Error Messages**: The frontend displayed the same generic message for all errors, hiding the actual cause
2. **No Error Response Parsing**: When the API returned an error with details in the JSON body, the frontend ignored it
3. **Missing API Key Validation**: No early check for MatchaAI API key configuration
4. **Limited Server-Side Logging**: Error logging didn't include stack traces

---

## Root Cause Analysis

### Issue 1: Frontend Not Reading Error Response Body

**Before Fix:**

```tsx
if (!response.ok) {
  throw new Error(`HTTP ${response.status}: ${response.statusText}`)
}
```

The frontend threw a generic error without reading the detailed error message from the response body.

### Issue 2: Generic Error Display

**Before Fix:**

```tsx
message: 'Sorry, I encountered an error while streaming. Please try again.',
```

Users saw the same message regardless of whether it was a timeout, API key issue, or other error.

---

## Solution Implemented

### 1. Enhanced Frontend Error Parsing

Now reads the error response body to get detailed error information:

```tsx
if (!response.ok) {
  let errorDetail = response.statusText
  try {
    const errorBody = await response.json()
    errorDetail = errorBody.details || errorBody.error || response.statusText
  } catch {
    // Response might not be JSON
  }
  console.error('[ChaSen Stream] API Error:', { status: response.status, errorDetail })
  throw new Error(`${errorDetail}`)
}
```

### 2. Improved Error Message Display

Now shows the actual error to users:

```tsx
const errorDetail = err instanceof Error ? err.message : 'Unknown error'
const errorMessage: ChatMessage = {
  message: `Sorry, I encountered an error: ${errorDetail}\n\nPlease try again or select a different model.`,
  // ...
}
```

### 3. API Key Validation

Added early validation in `callMatchaAI`:

```tsx
if (!MATCHAAI_CONFIG.apiKey) {
  console.error('[MatchaAI] Missing API key - check MATCHAAI_API_KEY environment variable')
  throw new Error('MatchaAI API key is not configured. Please contact your administrator.')
}
```

### 4. Better Server-Side Error Handling

Enhanced error response with timeout detection:

```tsx
const isTimeout = errorMessage.includes('timed out') || errorMessage.includes('504')
const userFriendlyMessage = isTimeout
  ? 'The AI service is taking too long to respond. Please try again or select a different model.'
  : `Failed to generate response: ${errorMessage}`
```

---

## Files Changed

| File                                 | Changes                                                      |
| ------------------------------------ | ------------------------------------------------------------ |
| `src/app/(dashboard)/ai/page.tsx`    | Enhanced error parsing and display with actual error details |
| `src/app/api/chasen/stream/route.ts` | Better error logging and timeout-specific messages           |
| `src/lib/ai-providers.ts`            | Added API key validation at the start of MatchaAI calls      |

---

## Benefits

1. **Better Debugging**: Actual error messages are now visible in console and UI
2. **User Clarity**: Users know if it's a timeout, API key issue, or other error
3. **Actionable Messages**: Suggestions like "select a different model" help users recover
4. **Fail-Fast**: Missing API key detected early with clear error message

---

## Testing Steps

1. Start dev server: `npm run dev`
2. Navigate to ChaSen AI page
3. Send a message
4. If an error occurs, verify:
   - Console shows `[ChaSen Stream] API Error:` with actual error details
   - UI shows specific error message, not generic one
   - Timeout errors show suggestion to try different model

---

## Related Issues

- BUG-20251224-chasen-streaming-timeout.md (Previous timeout fix)
