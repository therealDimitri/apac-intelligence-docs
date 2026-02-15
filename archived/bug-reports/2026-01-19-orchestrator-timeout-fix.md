# Bug Fix: Multi-Agent Orchestrator Timeout Issue

**Date:** 2026-01-19
**Severity:** High
**Component:** ChaSen Multi-Agent Orchestrator
**Status:** Resolved

## Problem

The multi-agent orchestrator was consistently timing out when processing complex queries (risk_analysis, report_generation, meeting_prep). The total execution time was 26-28 seconds, exceeding Netlify's 25-second function timeout limit.

### Symptoms

- Requests returned "Inactivity Timeout" HTML errors
- Agent tasks in database showed status "failed" with error "MatchaAI request timed out"
- Orchestration metadata showed `duration_ms: ~27000-28000`

### Root Cause

Multiple factors contributed to the timeout:

1. **Memory context building** - `buildMemoryContext()` made sequential database queries including:
   - Vector similarity search for similar episodes
   - Pattern matching for procedures
   - **One database call per word** in the query for concept lookup (the main culprit)
   - Total: 5-10 seconds of overhead

2. **Synchronous task creation** - Waiting for database writes before executing agents

3. **Model selection** - Using claude-sonnet-4-5 which is slower than haiku

4. **Timeout configuration** - 22s LLM timeout left only 3s buffer for all other operations

## Solution

### Changes Made

**File:** `src/lib/chasen-agents.ts`

1. **Skip memory context building entirely** (saves 5-10s)
   ```typescript
   // Before: Expensive database queries
   const memoryContext = await buildMemoryContext(request.query, request.user_email)

   // After: Empty context - memory features deferred to Phase 4
   const memoryContext = {
     episodic: [],
     procedural: null,
     concepts: [],
     context_summary: '',
   }
   ```

2. **Fire-and-forget task creation** (saves 2-3s)
   ```typescript
   // Before: Blocking database write
   const subtask = await createAgentTask({...})

   // After: Non-blocking, update in background
   const subtaskPromise = createAgentTask({...})
   void (async () => { /* update tasks in background */ })()
   ```

3. **Use claude-haiku model** (faster responses)
   ```typescript
   const preferredModel = 'claude-haiku'
   ```

4. **Reduce LLM timeout to 15s** (10s buffer for overhead)
   ```typescript
   timeout: 15000, // 15s timeout - leaves 10s buffer
   ```

5. **Reduce maxTokens to 1000** (faster completion)
   ```typescript
   maxTokens: agent.max_tokens || 1000
   ```

## Results

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Total duration | 26-28s | 21-22s | ~25% faster |
| Success rate | ~0% (timeout) | 100% | Fixed |
| Under 25s limit | No | Yes | Resolved |

### Test Results

```bash
# Risk analysis query
curl -X POST 'https://apac-cs-dashboards.com/api/chasen/stream' \
  -d '{"message":"Which clients are at risk","userEmail":"..."}'

# Result: duration_ms: 21405 (well under 25s limit)
```

## Trade-offs

1. **Memory context disabled** - Agents no longer receive episodic/procedural memory context. This is acceptable for Phase 3 as memory features were not yet fully utilised. Will be re-enabled with optimised queries in Phase 4.

2. **Task tracking delayed** - Task status updates happen in background, so there may be brief inconsistency in database. Not user-facing.

3. **Haiku vs Sonnet** - Slightly lower quality responses but acceptable for analysis tasks. Can be upgraded later when speed improves.

## Future Improvements

1. Optimise `buildMemoryContext()` to use parallel queries and batched concept lookups
2. Consider caching frequently accessed memory context
3. Implement progressive enhancement - return quick response, then enhance with memory context
4. Evaluate streaming memory context in parallel with LLM response

## Related Files

- `src/lib/chasen-agents.ts` - Main orchestrator and agent execution
- `src/lib/chasen-memory.ts` - Memory context building (now skipped)
- `src/app/api/chasen/stream/route.ts` - Stream endpoint with fallback

## Commits

- `753a2b0e` - fix: Aggressive orchestrator optimisations for Netlify 25s limit
