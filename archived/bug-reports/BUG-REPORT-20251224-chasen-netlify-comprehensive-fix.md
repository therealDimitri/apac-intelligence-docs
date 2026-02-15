# Bug Report: ChaSen AI Netlify Function Timeout - Comprehensive Fix

**Date:** 2024-12-24
**Status:** FIXED
**Commits:** 433270c, 36e9e66, d72d9fc, 66d9602, 207b00a, 7ba4eb1, c5d2840, 3e2e0ea, 9c412e5, e5767da, ab32962

## Problem Description

ChaSen AI streaming worked correctly on the development server (localhost) but consistently failed on production (Netlify) with HTTP 504 timeout errors and empty responses.

### Symptoms

1. ChaSen would show "Sorry, I encountered an error" on the live site
2. Console errors showed: `Inactivity Timeout: Too much time has passed without sending any data`
3. Quick Insights "Tell me more" feature returned 504 errors
4. Development site (localhost) worked perfectly
5. Errors occurred ~26 seconds after sending a message
6. Later symptoms: empty responses with no console logs

### Root Causes

1. **Netlify function timeout limit**: Netlify Pro tier limits serverless functions to 26 seconds of inactivity
2. **MatchaAI response time**: Corporate AI proxy takes 60-70 seconds to generate responses
3. **Sequential wait pattern**: Original implementation waited for complete AI response before streaming
4. **Slow context queries**: Semantic search and dashboard context queries added latency before AI call
5. **Model selection**: Default model (Claude Sonnet) was slower than necessary
6. **Unused imports**: semantic-search import caused unnecessary module loading overhead

## Solution

### Phase 1: Heartbeat Streaming (433270c, 36e9e66)

Added heartbeat streaming pattern to keep connection alive:

```typescript
function createStreamWithHeartbeat(
  aiPromise: Promise<{ text: string }>,
  onComplete?: (text: string) => void
): ReadableStream<Uint8Array> {
  // Send heartbeat every 3 seconds while waiting for AI response
  // This keeps the HTTP connection alive during processing
}
```

**Lesson learned**: Heartbeat doesn't bypass Netlify's hard function timeout - the function itself still times out at 26 seconds.

### Phase 2: Simplified Context (d72d9fc, 66d9602)

Removed slow context-gathering queries:

- Removed semantic search (embeddings lookup)
- Removed live dashboard context queries
- Simplified system prompt to basic instructions

This reduced latency before the AI call starts.

### Phase 3: Fast Model Default (d72d9fc, 7ba4eb1)

Changed default model from Claude Sonnet to Gemini Flash:

```typescript
// stream/route.ts
const MODEL_ID_TO_KEY: Record<number, string> = {
  71: 'gemini-2-flash', // Fastest - default for Netlify
  27: 'claude-3-7-sonnet',
  28: 'claude-sonnet-4',
  // ...
}

// chat/route.ts
let selectedLlmId = 71 // Default to Gemini Flash (fastest for Netlify)
```

Gemini Flash typically responds in 5-15 seconds vs 60-70 seconds for Claude.

### Phase 4: Timeout Configuration (7ba4eb1)

Added proper timeout to both endpoints:

```typescript
// Netlify edge function configuration
export const dynamic = 'force-dynamic'
export const maxDuration = 25 // Netlify limit

// Timeout on fetch
const controller = new AbortController()
const timeoutId = setTimeout(() => controller.abort(), 20000) // 20s timeout
```

### Phase 5: Response Parsing Fallbacks (207b00a, c5d2840)

Added fallback parsing for different MatchaAI response formats:

```typescript
let aiText = data.output?.[0]?.content?.[0]?.text || ''

// Fallback: try other possible response structures
if (!aiText) {
  const dataAny = data as any
  if (dataAny.output?.[0]?.message?.content) {
    aiText = dataAny.output[0].message.content
  } else if (dataAny.choices?.[0]?.message?.content) {
    aiText = dataAny.choices[0].message.content
  } else if (dataAny.response) {
    aiText = dataAny.response
  } else if (dataAny.text) {
    aiText = dataAny.text
  }
}
```

### Phase 6: Remove Unused Import (3e2e0ea)

Removed unused semantic-search import from stream endpoint:

```diff
- import { semanticSearch, formatContextForPrompt, CONTENT_TYPES } from '@/lib/semantic-search'
```

This eliminates unnecessary module loading and potential initialization overhead.

## Files Changed

| File                                  | Changes                                                                           |
| ------------------------------------- | --------------------------------------------------------------------------------- |
| `src/app/api/chasen/stream/route.ts`  | Heartbeat streaming, model ID mapping, simplified prompts, removed unused imports |
| `src/app/api/chasen/chat/route.ts`    | maxDuration, timeout, fast model default, response parsing fallbacks              |
| `src/lib/ai-providers.ts`             | Response parsing fallbacks, logging                                               |
| `src/app/(dashboard)/ai/page.tsx`     | Heartbeat event handling                                                          |
| `src/components/FloatingChaSenAI.tsx` | Heartbeat event handling                                                          |

## Frontend Heartbeat Handling

Both AI page and FloatingChaSenAI components now handle heartbeat events:

```typescript
// Handle heartbeat messages (ignore - just keeps connection alive)
if (data.heartbeat) {
  continue
}
// Handle error messages from stream
if (data.error) {
  throw new Error(data.error)
}
```

## Testing

1. Build passes: `npm run build` ✅
2. TypeScript check passes ✅
3. ESLint passes ✅
4. All commits pushed to trigger Netlify deployment

## Lessons Learned

1. **Serverless timeout limits are hard limits** - heartbeat streaming can't bypass them
2. **Model selection matters** - Gemini Flash is significantly faster for Netlify deployments
3. **Reduce latency before AI calls** - context queries can consume timeout budget
4. **Add timeouts to fetch calls** - prevents hanging requests
5. **Parse multiple response formats** - AI providers can return different structures
6. **Remove unused imports** - they still get loaded and can cause overhead

## Phase 7: Model Selection Fix (9c412e5)

**Root Cause:** When `ANTHROPIC_API_KEY` was set on Netlify but user selected Gemini Flash (model 71), the `getAIModel()` function's `default:` switch case returned a Claude model instead of `null`. This caused:

1. AI SDK native streaming was used (not MatchaAI)
2. Wrong model configuration was passed
3. Empty response (content-length: 0) returned

**Fix:** Removed `default:` cases from switch statements. Now `getAIModel()` only returns models for explicitly supported model names, returning `null` for others to fall back to MatchaAI.

```typescript
// Before (broken)
switch (modelName) {
  case 'claude-opus-4':
    return anthropic('...')
  default:
    return anthropic('claude-3-5-sonnet-20241022') // BAD: catches gemini too!
}

// After (fixed)
switch (modelName) {
  case 'claude-opus-4':
    return anthropic('...')
  case 'claude-sonnet-4':
    return anthropic('...')
  case 'claude-3-7-sonnet':
    return anthropic('...')
  // No default - falls through to return null for unsupported models
}
```

## Phase 8: SSE Stream Buffering (e5767da)

**Root Cause:** SSE chunks can be split mid-JSON across network packets. When a chunk arrives like `data: {"text":"Hel` (incomplete), `JSON.parse()` fails with:

```
SyntaxError: Unterminated string in JSON at position 12
```

**Fix:** Added buffer to accumulate incomplete SSE lines. Only parse complete lines (those ending with `\n`).

```typescript
let buffer = '' // Buffer for incomplete SSE lines

while (true) {
  const { done, value } = await reader.read()
  if (done) break

  const chunk = decoder.decode(value)
  buffer += chunk

  // Parse complete SSE events (lines ending with \n)
  const lines = buffer.split('\n')
  // Keep the last incomplete line in buffer
  buffer = lines.pop() || ''

  for (const line of lines) {
    if (line.startsWith('data: ')) {
      try {
        const jsonStr = line.slice(6)
        if (!jsonStr.trim()) continue
        const data = JSON.parse(jsonStr)
        // ... handle data
      } catch (parseError) {
        // Ignore JSON parse errors from incomplete data
      }
    }
  }
}
```

**Files Modified:**

- `src/app/(dashboard)/ai/page.tsx` - SSE buffering
- `src/components/FloatingChaSenAI.tsx` - SSE buffering

## Phase 9: Restore Dashboard Context (ab32962)

**Root Cause:** Phase 2 removed all context-gathering queries from the stream route to fix timeouts. This caused ChaSen to give generic advice instead of using actual portfolio data.

**Fix:** Re-enabled `getLiveDashboardContext()` in the stream route with a 5-second timeout race condition to prevent blocking:

```typescript
// Fetch live dashboard context - this provides real portfolio data
// Use a timeout to ensure context gathering doesn't block the request
let dashboardContext = ''
try {
  const contextPromise = getLiveDashboardContext(clientName)
  const timeoutPromise = new Promise<string>(resolve => setTimeout(() => resolve(''), 5000))
  dashboardContext = await Promise.race([contextPromise, timeoutPromise])
} catch (err) {
  console.warn('[ChaSen Stream] Context fetch failed, continuing without:', err)
}

// Include context in system prompt
const systemPrompt = `...
- Use the ACTUAL DATA provided below to answer questions
- Reference specific clients, scores, and metrics from the data
${dashboardContext ? `\n\n## Your Portfolio Data:\n${dashboardContext}` : ''}`
```

The context includes:

- Client health scores and status
- Client segmentation data
- Recent meetings (last 7 days)
- Open actions
- Recent NPS responses

**Files Modified:**

- `src/app/api/chasen/stream/route.ts` - Restored dashboard context with timeout

## Recommendations for Future

1. Consider using Netlify Background Functions for long-running AI operations (up to 15 minutes)
2. Implement client-side polling for slow operations
3. Cache common queries to reduce AI call frequency
4. Monitor response times to identify slow queries
5. Consider edge caching for frequently-asked questions
6. Always test with production environment variables - direct API keys can change behaviour
7. Always buffer SSE streams - network packets don't respect JSON boundaries
