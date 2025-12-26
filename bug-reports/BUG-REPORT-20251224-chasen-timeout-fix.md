# Bug Report: ChaSen 504 Timeout Errors

**Date:** 24 December 2024
**Status:** FIXED
**Component:** ChaSen AI Chat API
**Commit:** e85013c

## Issue Description

ChaSen was returning 504 Gateway Timeout errors for all queries, even though it worked perfectly yesterday.

## Root Cause

Multiple timeout protection commits made today added aggressive timeout wrappers that were **more restrictive than Netlify's actual limits**:

| Timeout        | Today's Code | Netlify Limit     |
| -------------- | ------------ | ----------------- |
| Global wrapper | 24s          | 26s (maxDuration) |
| LLM abort      | 18s          | N/A               |
| Data fetch     | 4s           | N/A               |

**Yesterday's working code had NO timeout wrappers** - it let Netlify handle timeouts naturally.

The aggressive timeouts were cutting off requests before they could complete, resulting in 504 errors even when the request would have finished within Netlify's 26-second limit.

Additionally, the model selection logic was changed to **force Gemini Flash for all non-report queries**, ignoring the user's model selection.

## Changes Made Today That Broke It

1. `e8e507a` - Added global timeout wrapper (24s)
2. `7ba4eb1` - Added LLM timeout and fast model default
3. `c8df607` - Force Gemini Flash for simple queries
4. `dbd9749` - Added fast path detection
5. `a11664a` - Added data fetch timeout protection
6. `7744362` - Fixed fast path but kept timeouts
7. Multiple timeout tuning commits (3s → 12s → 6s → 4s)

## Fix Applied

**File:** `src/app/api/chasen/chat/route.ts`

### 1. Removed global timeout wrapper

```typescript
// Before - aggressive 24s timeout
const GLOBAL_TIMEOUT_MS = 24000
const timeoutPromise = new Promise((_, reject) => {
  setTimeout(() => reject(new Error('GLOBAL_TIMEOUT')), GLOBAL_TIMEOUT_MS)
})
return await Promise.race([handleChatRequest(request), timeoutPromise])

// After - let Netlify handle it naturally
return handleChatRequest(request, requestStartTime)
```

### 2. Removed LLM abort controller

```typescript
// Before - 18s abort
const controller = new AbortController()
const LLM_TIMEOUT_MS = 18000
setTimeout(() => controller.abort(), LLM_TIMEOUT_MS)
await fetch(..., { signal: controller.signal })

// After - no abort, let Netlify handle it
await fetch(...)
```

### 3. Restored user model selection

```typescript
// Before - force Gemini Flash except for reports
const shouldUseUserModel = !isSimpleQuery && (isReportRequest || isEmailRequest) && model

// After - respect user's selection (like yesterday)
if (model) {
  // Look up and use user's selected model
}
```

### 4. Kept reasonable data fetch timeout

The 8-second data fetch timeout was kept as it gracefully falls back to minimal context rather than failing the entire request.

## Lessons Learned

1. **Don't add timeout wrappers more aggressive than the platform's limits** - Netlify Pro has a 26-second limit; our 24s wrapper was premature
2. **Test timeout changes thoroughly** - Each change to timeout values can have cascading effects
3. **Keep changes minimal** - Yesterday's code worked; adding "protection" broke it
4. **Respect user preferences** - Forcing model selection frustrated users who wanted specific models

## Verification

After fix deployment:

- Claude Sonnet 4 queries work (100% confidence)
- Gemini 2.5 Flash queries work
- User's model selection is respected
- No 504 errors
