# Model Upgrade: Haiku to Sonnet

**Date:** 2026-01-19
**Status:** Completed
**Type:** Enhancement
**Component:** ChaSen Multi-Agent Orchestrator

## Overview

Upgraded the default agent model from `claude-haiku` to `claude-sonnet-4` in the ChaSen orchestrator. The Phase 3 optimisations (parallel context retrieval, reduced tokens, batch queries) now provide sufficient headroom for Sonnet to complete within Netlify's 25s timeout.

## Previous State

- **Model:** `claude-haiku` (hardcoded)
- **Max Tokens:** 1000
- **Timeout:** 15s
- **Reason:** Sonnet caused timeouts with memory context loading

## New State

- **Model:** `claude-sonnet-4` (default, configurable per-agent)
- **Max Tokens:** 1500
- **Timeout:** 18s
- **Override:** Agents can set `model_preference` to use Haiku for speed-critical tasks

## Changes Made

### 1. Agent Execution

**File:** `src/lib/chasen-agents.ts`

```typescript
// Before
const preferredModel = 'claude-haiku'
maxTokens: 1000
timeout: 15000

// After
const preferredModel = agent.model_preference || 'claude-sonnet-4'
maxTokens: 1500
timeout: 18000
```

### 2. Database Migration

**File:** `docs/migrations/20260119_chasen_specialist_agents.sql`

Added update statement to upgrade existing agents:
```sql
UPDATE chasen_agents
SET model_preference = 'claude-sonnet-4'
WHERE model_preference = 'claude-sonnet-4' OR model_preference IS NULL;
```

## Expected Performance

| Metric | Haiku | Sonnet | Delta |
|--------|-------|--------|-------|
| LLM Response Time | 8-12s | 12-16s | +4s |
| Total Orchestration | 16-18s | 20-24s | +4-6s |
| Response Quality | Good | Excellent | Improved |

The optimisations provide ~7s buffer (25s - 18s LLM timeout) for:
- Intent classification (~50ms)
- Agent lookup (~200ms)
- Memory context (~2s with optimisations)
- Overhead and streaming

## Benefits

1. **Higher quality responses** - Sonnet produces more nuanced, comprehensive analysis
2. **Better reasoning** - Complex queries (risk analysis, meeting prep) benefit from improved reasoning
3. **Configurable** - Agents can still use Haiku via `model_preference` if speed is critical

## Fallback Strategy

If Sonnet causes timeout issues in production:

1. **Per-agent override:** Set `model_preference = 'claude-haiku'` for time-sensitive agents
2. **Global rollback:** Change default back to `claude-haiku` in code
3. **Timeout increase:** Netlify Pro supports 60s timeout if needed

## Testing

To verify the upgrade:

```bash
# Test risk analysis (complex intent)
curl -X POST 'https://apac-cs-dashboards.com/api/chasen/stream' \
  -d '{"message":"Which clients are at risk of churning"}'

# Check response includes model_used: claude-sonnet-4
# Verify total duration under 25s
```

## Files Changed

| File | Changes |
|------|---------|
| `src/lib/chasen-agents.ts` | Updated default model and timeout |
| `docs/migrations/20260119_chasen_specialist_agents.sql` | Added model upgrade statement |
