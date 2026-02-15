# Bug Report: ChaSen 504 Timeouts - Streaming Heartbeat Fix

**Date:** 24 December 2024
**Status:** FIXED
**Component:** ChaSen AI Streaming API
**Commit:** c713290

## Issue Description

ChaSen was returning 504 Gateway Timeout errors despite having a streaming endpoint (`/api/chasen/stream`) that was supposed to prevent timeouts. The problem persisted even after removing aggressive timeout wrappers from the non-streaming endpoint.

## Root Cause

The streaming endpoint had a critical design flaw that defeated the purpose of streaming:

```typescript
// BEFORE - The code AWAITED the full response before streaming
const response = await callMatchaAI(messages, { ... })  // ❌ Blocks until complete
const stream = createChunkedStream(response.text, metadata)  // ❌ Only then creates stream
```

**The problem:** The code waited for the full LLM response before creating the stream. If the LLM took longer than Netlify's timeout (~26s), the connection would die before any data was streamed.

**Additionally:** The `createStreamWithHeartbeat()` function existed in the codebase but was NOT being used. This function sends heartbeat messages every 3 seconds to keep the connection alive.

## Solution Applied

### 1. Use Heartbeat Streaming (`src/app/api/chasen/stream/route.ts`)

```typescript
// AFTER - Create MatchaAI promise (doesn't await - runs in background)
const matchaPromise = callMatchaAI(messages, {
  model,
  maxTokens: 2048,
  temperature: 0.7,
  // No timeout - let Netlify handle the 26s limit naturally
})

// Use heartbeat streaming to keep connection alive
const stream = createStreamWithHeartbeat(matchaPromise, async (responseText: string) => {
  // Callback runs when MatchaAI completes
  // Handle tracing, conversation storage, metadata extraction
})
```

### 2. Update AI Page to Use Streaming (`src/app/(dashboard)/ai/page.tsx`)

The main AI page was calling `/api/chasen/chat` (non-streaming). Updated to use `/api/chasen/stream` with proper SSE parsing:

```typescript
// Create placeholder message for streaming updates
const aiMessage = { id: aiMessageId, type: 'assistant', message: '', ... }
setChatHistory(prev => [...prev, aiMessage])

// Use streaming API
const response = await fetch('/api/chasen/stream', {
  method: 'POST',
  body: JSON.stringify({ message, model, context: 'portfolio' }),
})

// Read SSE stream
const reader = response.body?.getReader()
while (true) {
  const { done, value } = await reader.read()
  if (done) break

  // Parse SSE events
  // Handle heartbeats (ignore), text chunks (append), metadata (store)
  // Update message in real-time as chunks arrive
}
```

## How Heartbeat Streaming Works

1. **Immediate heartbeat:** First heartbeat sent as soon as stream starts
2. **Continuous heartbeats:** Every 3 seconds while waiting for LLM
3. **Connection stays alive:** Netlify sees activity, doesn't timeout
4. **Response streams:** Once LLM responds, text chunks stream through
5. **Frontend ignores heartbeats:** `if (data.heartbeat) continue`

```
Client <---> Netlify <---> LLM (MatchaAI)

Time 0s:   [heartbeat] -->
Time 3s:   [heartbeat] -->
Time 6s:   [heartbeat] -->
...
Time 15s:  <-- LLM responds
           [text chunk] -->
           [text chunk] -->
           [done]
```

## Files Changed

| File                                 | Change                                                                  |
| ------------------------------------ | ----------------------------------------------------------------------- |
| `src/app/api/chasen/stream/route.ts` | Use `createStreamWithHeartbeat()` instead of awaiting response          |
| `src/app/(dashboard)/ai/page.tsx`    | Switch from `/api/chasen/chat` to `/api/chasen/stream` with SSE parsing |

## Why Previous Fixes Didn't Work

Earlier today, multiple commits tried to fix 504s by adjusting timeout values:

| Commit                                    | Approach                   | Why It Failed                               |
| ----------------------------------------- | -------------------------- | ------------------------------------------- |
| Aggressive timeouts (24s global, 18s LLM) | Cut off requests early     | More restrictive than Netlify's limit       |
| Removed timeouts                          | Let requests run naturally | Non-streaming still waits for full response |
| Streaming endpoint                        | Should have worked         | But it awaited the full response first      |

**The breakthrough:** Realising the streaming endpoint defeated its own purpose by blocking on `await callMatchaAI()`.

## Verification

After deployment:

1. ChaSen responds even for slow models (Claude Sonnet 4)
2. Text streams in real-time character by character
3. Heartbeats visible in Network tab as SSE events
4. No 504 errors even for complex queries

## Lessons Learned

1. **Streaming must be end-to-end:** If you await before streaming, you lose the benefit
2. **Use existing infrastructure:** `createStreamWithHeartbeat` was already written, just not used
3. **Test with slow models:** Fast models (Gemini Flash) may hide timeout issues
4. **Check both endpoints:** FloatingChaSenAI used streaming, but AI page used non-streaming

## Future Improvements

1. Add streaming support to all ChaSen endpoints that call LLMs
2. Consider server-sent events for other long-running operations
3. Add client-side timeout handling with user-friendly retry UI
