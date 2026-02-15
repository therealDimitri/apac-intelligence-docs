# ChaSen Phase 3: Multi-Agent Architecture Completion

**Date:** 2026-01-19
**Status:** Completed
**Components:** Multi-Agent Orchestrator, Memory Context, Write Tools, Proactive Insights

## Overview

Phase 3 implements a multi-agent architecture for ChaSen, enabling complex queries to be routed to specialist agents for more accurate and comprehensive responses.

## Implemented Features

### 3A: Orchestrator Integration ✓

**Location:** `src/app/api/chasen/stream/route.ts`

The orchestrator is now wired into the main stream endpoint:
- Intent classification determines if a query is complex
- Complex intents (`risk_analysis`, `report_generation`, `meeting_prep`) with confidence > 0.75 route to orchestrator
- Fallback to standard path if orchestrator fails or times out

```typescript
// Routing logic
if (complexIntents.includes(intent) && confidence > 0.75) {
  const result = await orchestrate({ query, user_email, ... })
  // Stream result...
}
```

### 3B: Agent Execution ✓

**Location:** `src/lib/chasen-agents.ts`

The `executeAgent()` function now makes real LLM calls:
- Uses claude-haiku for fast responses
- 15s LLM timeout
- Structured prompt with agent capabilities
- Response parsing for insights and actions

### 3C: Memory Context (Optimised) ✓

**Location:** `src/lib/chasen-memory.ts`

Memory context building is now optimised for speed:
- **Batch concept lookup** - Single query instead of per-word
- **Parallel queries** - All database calls run concurrently
- **Aggressive timeouts** - 2s total budget with per-query limits
- **Stop word filtering** - Reduces unnecessary lookups

```typescript
// Parallel execution with timeouts
const [episodic, procedural, concepts] = await Promise.all([
  timeoutPromise(findSimilarEpisodes(...), 1000, []),
  timeoutPromise(findMatchingProcedure(...), 800, null),
  timeoutPromise(findConceptsBatch(...), 800, []),
])
```

### 3D: Memory Extraction ✓

Memory extraction runs in background after responses (fire-and-forget):
```typescript
void extractMemoriesFromConversation(userEmail, query, response, context)
```

### 3E: Proactive Insights ✓

**Location:** `src/app/api/cron/proactive-insights/route.ts`

Cron job generates proactive insights:
- Health score drops (>10 points in 7 days)
- NPS detractors needing follow-up
- Overdue actions
- Engagement gaps (no meeting in 60+ days)

**Schedule:** Daily at 6:00 AM Sydney (via Netlify scheduled functions)

### 3F: Write Tools with Approval ✓

**Location:** `src/lib/agent-workflows.ts`

Write tools enable agents to create/modify data:

| Tool | Description | Requires Approval |
|------|-------------|-------------------|
| `create_action` | Create new action item | Yes |
| `update_action_status` | Update action status | No |
| `create_meeting` | Create meeting record | Yes |
| `add_meeting_notes` | Add notes to meeting | No |

Approval workflow:
1. Tool execution creates approval request
2. Request stored in `chasen_workflow_approvals`
3. User can approve/reject via API
4. Approved operations execute automatically

## Performance

### Orchestration Timing

| Step | Timeout | Typical Time |
|------|---------|--------------|
| Intent classification | - | <50ms |
| Parent task creation | 3s | ~500ms |
| Agent lookup | 2s | ~200ms |
| Memory context | 2.5s | ~1-2s |
| LLM call | 15s | 8-12s |
| **Total** | **~22s** | **16-18s** |

### Test Results

```bash
# Risk analysis query
curl -X POST 'https://apac-cs-dashboards.com/api/chasen/stream' \
  -d '{"message":"Which clients are at risk of churning"}'

# Result: duration_ms: 16464 (well under 25s limit)
```

## Files Modified

| File | Changes |
|------|---------|
| `src/app/api/chasen/stream/route.ts` | Orchestrator routing, memory extraction |
| `src/lib/chasen-agents.ts` | executeAgent impl, timeout protection |
| `src/lib/chasen-memory.ts` | Batch queries, parallel execution |
| `src/lib/agent-workflows.ts` | Write tools, approval workflow |
| `src/app/api/cron/proactive-insights/route.ts` | Proactive insights cron |
| `netlify/functions/proactive-insights.mts` | Scheduled function wrapper |

## Database Tables Used

- `chasen_agents` - Agent definitions
- `chasen_agent_tasks` - Task tracking
- `chasen_workflow_approvals` - Write operation approvals
- `chasen_proactive_insights` - Generated insights
- `chasen_user_memories` - User memory storage
- `chasen_episodes` - Episodic memory
- `chasen_procedures` - Procedural memory
- `chasen_concepts` - Semantic memory

## Known Limitations

1. **Model constraint** - Using claude-haiku instead of sonnet due to timing constraints. Can upgrade when Netlify increases timeout.

2. **Memory context** - Skipped if slow to ensure orchestrator completes. Full memory features deferred to Phase 4.

3. **Write tool approvals** - Currently API-only. UI for approval management planned for future.

## Commits

- `57dfdddd` - feat: Optimise memory context + upgrade to Sonnet
- `117e170b` - fix: Add timeout protection for memory context
- `5d9a88b2` - fix: Add aggressive timeout protection throughout orchestrator

## Verification

1. **Orchestrator works:** Query "Which clients are at risk" returns structured analysis from predictor agent
2. **Timing safe:** Orchestration completes in ~16-18s (under 25s limit)
3. **Fallback works:** Standard path used if orchestrator fails
4. **Write tools ready:** API endpoints available for create_action, update_action, create_meeting
