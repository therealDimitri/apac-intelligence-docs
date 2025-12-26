# Bug Report: ChaSen Empty Response - Native AI SDK Bypass Fix

**Date:** 24 December 2024
**Status:** FIXED
**Component:** ChaSen AI Streaming API
**Commit:** 7b4aa2e

## Issue Description

After deploying the heartbeat streaming fix, ChaSen returned 200 OK but with an **empty response body**. The streaming endpoint appeared to work (no 504 errors) but no text was being returned to the user.

## Root Cause

The streaming endpoint had two code paths:

1. **Native AI SDK path** - Used when `ANTHROPIC_API_KEY` is set (uses Vercel AI SDK's `streamText()`)
2. **MatchaAI path** - Uses our custom `createStreamWithHeartbeat()` function

The issue was that `getAIModel(model)` was returning a valid Anthropic model object (because `ANTHROPIC_API_KEY` is set in production), causing the code to take the native AI SDK path:

```typescript
const aiModel = getAIModel(model) // Returns Anthropic model if API key set

if (aiModel) {
  // Uses native AI SDK streaming - NO heartbeats!
  return result.toTextStreamResponse()
}
```

**The native AI SDK path was failing silently** - it would return a valid stream but with no content. This could be due to:

- API authentication issues
- Model mismatch (requesting Claude Sonnet 4 but SDK configured differently)
- Network/timeout issues without proper error handling

## Solution Applied

**File:** `src/app/api/chasen/stream/route.ts`

Disabled the native AI SDK path to force all requests through MatchaAI with heartbeat streaming:

```typescript
// Check if we have direct AI SDK access
// TEMPORARILY DISABLED: Force MatchaAI with heartbeats to fix 504 timeouts
// The native AI SDK path doesn't have heartbeat streaming and may fail silently
const _providers = getAvailableProviders()
const aiModel = null // getAIModel(model) - disabled to use heartbeat streaming

if (aiModel) {
  // This block is now never executed
  // Use native AI SDK streaming (currently disabled)
  ...
}

// Always falls through to MatchaAI with heartbeat streaming
const matchaPromise = callMatchaAI(messages, { ... })
const stream = createStreamWithHeartbeat(matchaPromise, callback)
```

## Why This Works

1. **MatchaAI is reliable** - It's been working consistently through the internal API gateway
2. **Heartbeat streaming prevents 504s** - Sends events every 3 seconds to keep connection alive
3. **Better error handling** - MatchaAI path has proper error logging and fallbacks

## Verification

After deployment, tested with query: "Which clients are at risk and need immediate attention?"

**Result:** ChaSen responded successfully with at-risk client information:

- SA Health (Sunrise) - 65% Health, 9pts NPS
- NCS/MinDef Singapore - 60% Health, 29pts Compliance
- Mount Alvernia Hospital - 63% Health, 13pts NPS
- GRMC - 18pts Compliance

No 504 errors, response streamed correctly.

## Future Improvements

1. **Investigate native AI SDK issue** - Why was it returning empty responses?
2. **Add heartbeat support to native path** - If we want to use direct API access
3. **Better error detection** - Native SDK path should throw/log on empty response
4. **Model configuration audit** - Ensure API keys and model IDs are correctly configured

## Related Bug Reports

- `BUG-REPORT-20251224-chasen-timeout-fix.md` - Initial timeout wrapper removal
- `BUG-REPORT-20251224-chasen-streaming-heartbeat-fix.md` - Heartbeat streaming implementation

## Timeline of Fixes Today

| Time      | Commit  | Change                              | Result           |
| --------- | ------- | ----------------------------------- | ---------------- |
| Morning   | e85013c | Removed aggressive timeout wrappers | Still 504s       |
| Afternoon | c713290 | Implemented heartbeat streaming     | 200 OK but empty |
| Evening   | 7b4aa2e | Disabled native AI SDK path         | ✅ Working       |
