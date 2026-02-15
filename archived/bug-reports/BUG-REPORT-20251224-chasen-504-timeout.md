# Bug Report: ChaSen AI 504 Gateway Timeout

**Date:** 24 December 2025
**Severity:** Critical
**Status:** Fixed
**Commits:** dbd9749, c8df607, a11664a, 66d1a81

## Summary

ChaSen AI was returning 504 Gateway Timeout errors on production (Netlify) for all queries, including simple greetings like "hi" or "hello". The error message displayed was a generic API connectivity failure.

## Error Message

```
I apologize, but I encountered an error processing your request. This could be due to:
- MatchaAI API connectivity issues
- Missing environment variables
- Database connection problems

Please check the console for details and try again.
```

Console error:

```
ChaSen API error: Error: API error: 504
```

## Root Cause

The ChaSen chat API was performing heavy data fetching operations for ALL queries, regardless of complexity:

1. **Portfolio context data** - Fetching all client health scores, NPS data, meetings, actions, ARR, aging accounts
2. **Knowledge base** - Loading entire knowledge base
3. **Semantic search** - Vector similarity search across embeddings
4. **Model database lookup** - Query to get LLM model ID

Additionally, the user's selected model (Claude Sonnet 4) was being used for all queries, which is slower than the default Gemini Flash model.

Combined with Netlify's function timeout limits (10-26 seconds depending on plan), simple queries that should respond in ~3 seconds were timing out at 25+ seconds.

## Affected Files

- `src/app/api/chasen/chat/route.ts`

## Solution

### Fix 1: Fast Path Detection (commit dbd9749)

Added detection for simple queries that don't require portfolio data:

```typescript
// FAST PATH: Detect simple queries that don't need portfolio data
const questionLower = sanitisedQuestion.toLowerCase().trim()
const isSimpleQuery =
  // Greetings
  /^(hi|hello|hey|g'day|good morning|good afternoon|good evening|howdy|yo|sup)\b/i.test(
    questionLower
  ) ||
  // System checks
  /^(can you hear me|are you there|test(ing)?|ping)\??$/i.test(questionLower) ||
  // Help/capability questions
  /^(what can you do|help|how do i use|show me examples?|what questions can i ask)/i.test(
    questionLower
  ) ||
  // Very short queries without client-specific keywords
  (questionLower.length < 20 &&
    !/client|nps|health|meeting|action|risk|revenue|arr|aging|renewal/i.test(questionLower))
```

For simple queries, the heavy data fetching is skipped:

```typescript
if (isSimpleQuery && !isReportRequest && !isEmailRequest) {
  // Fast path: minimal data fetching for simple queries
  portfolioContext = {
    summary: {},
    recentNPS: [],
    recentMeetings: [],
    openActions: [],
  }
  knowledgeContext = ''
}
```

### Fix 2: Force Fast Model for ALL Queries (commits c8df607, a11664a)

Gemini Flash (ID 26) is now used as the default model for ALL queries to ensure reliability:

```typescript
// DEFAULT: Use Gemini Flash (ID 26) for ALL queries to prevent Netlify timeouts
const GEMINI_FLASH_ID = 26 // Fastest model - 2-5 second responses
let selectedLlmId = GEMINI_FLASH_ID // Default to Gemini Flash for reliability

// Only use user's selected model for explicit report/email requests
const shouldUseUserModel = !isSimpleQuery && (isReportRequest || isEmailRequest) && model
```

### Fix 3: Data Fetching Timeout Protection (commit a11664a)

Added 5-second timeout to portfolio data fetching with graceful fallback:

```typescript
const DATA_FETCH_TIMEOUT_MS = 5000 // 5 seconds max for data fetching

// Race between data fetch and timeout
const timeoutPromise = new Promise<'timeout'>(resolve => {
  setTimeout(() => resolve('timeout'), DATA_FETCH_TIMEOUT_MS)
})

const raceResult = await Promise.race([dataFetchPromise, timeoutPromise])

if (raceResult === 'timeout') {
  console.warn('[ChaSen Chat] Data fetch timed out, using minimal context')
  dataFetchTimedOut = true
  portfolioContext = { summary: {}, recentNPS: [], recentMeetings: [], openActions: [] }
  knowledgeContext = ''
}
```

### Fix 4: Increased LLM Timeout (commit a11664a)

Increased LLM call timeout from 15s to 18s to utilise full Netlify budget:

```typescript
// Data fetch timeout: 5s, LLM timeout: 18s, buffer: 2s = 25s total (Netlify maxDuration)
const LLM_TIMEOUT_MS = 18000 // 18s timeout for LLM call
```

### Fix 6: Final Timeout Tuning (commit 66d1a81)

After production testing revealed complex queries still timing out, increased all limits to use full Netlify Pro allowance:

```typescript
export const maxDuration = 26 // Netlify Pro limit
const GLOBAL_TIMEOUT_MS = 24000 // 24s (buffer for 26s maxDuration)
const DATA_FETCH_TIMEOUT_MS = 3000 // 3 seconds max
const LLM_TIMEOUT_MS = 20000 // 20s timeout for LLM call
```

### Fix 5: Unsafe Property Access (included in dbd9749)

Fixed unsafe property access on `portfolioData.aging?.goals`:

```typescript
// Before (unsafe):
portfolioData.aging?.goals?.gap90Days !== null ? portfolioData.aging.goals.gap90Days + '%' : 'N/A'

// After (safe):
portfolioData.aging?.goals?.gap90Days != null ? portfolioData.aging?.goals?.gap90Days + '%' : 'N/A'
```

## Performance Impact

| Scenario                   | Before             | After               |
| -------------------------- | ------------------ | ------------------- |
| Simple query (local)       | ~17 seconds        | ~9 seconds          |
| Simple query (production)  | 504 Timeout        | ~10-15 seconds      |
| Complex query (local)      | ~22+ seconds (504) | ~20 seconds (works) |
| Complex query (production) | 504 Timeout        | ~20-24 seconds      |

**Final Timeout Budget (commit 66d1a81):**

- Data fetching: 3 seconds max (graceful fallback if exceeded)
- LLM call: 20 seconds max
- Global timeout: 24 seconds
- **maxDuration: 26 seconds** (Netlify Pro limit)

## Testing

### Simple Query Test

1. Navigate to https://apac-cs-dashboards.com/ai
2. Type "hello" or "hi" in the chat input
3. Press Enter or click Send
4. ChaSen should respond within 10-15 seconds with a greeting
5. Response should show 95%+ confidence

### Complex Query Test

1. Navigate to https://apac-cs-dashboards.com/ai
2. Type "Which clients need immediate attention?" in the chat input
3. Press Enter or click Send
4. ChaSen should respond within 20-24 seconds with portfolio insights
5. Response should include key insights and recommended actions

## Prevention

1. **Test API routes locally before deploying** - Use curl with timeout to simulate Netlify limits
2. **Add timeouts to all external API calls** - Ensure graceful degradation
3. **Consider serverless function limits** - Netlify has 10-26 second limits
4. **Implement streaming for long operations** - Avoid timeout issues entirely
5. **Use fast models for simple queries** - Don't waste resources on trivial requests

## Related Issues

- Voice Settings Crash (BUG-REPORT-20251224-voice-settings-crash.md)

## Notes

- Gemini Flash (ID 26) is now the default model for ALL queries to ensure reliability within Netlify's timeout limits
- The user's selected model (e.g. Claude Sonnet 4) is only used for explicit report/email generation requests
- If data fetching takes longer than 5 seconds, ChaSen proceeds with minimal context rather than timing out
- This trade-off prioritises response reliability over comprehensive data context
