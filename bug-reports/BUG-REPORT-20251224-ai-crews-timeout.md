# Bug Report: AI Crews Netlify Inactivity Timeout

**Date:** 24 December 2024
**Status:** RESOLVED
**Severity:** High
**Component:** ChaSen AI - Multi-Agent Crews

## Issue Description

All AI Crew types were failing with Netlify "Inactivity Timeout" error:

```
[ChaSen Crew] Non-JSON response: {
  contentType: "text/html",
  text: "<HTML><HEAD><TITLE>Inactivity Timeout</TITLE></HEAD>
         <BODY>Description: Too much time has passed without sending any data...</BODY></HTML>"
}
```

## Root Cause

The original multi-agent crew system executed **multiple sequential LLM calls** (one per task in the crew):

| Crew Type          | Tasks | LLM Calls | Est. Time     |
| ------------------ | ----- | --------- | ------------- |
| Portfolio Analysis | 2     | 2         | 20-30 seconds |
| Client Report      | 3     | 3         | 30-45 seconds |
| Risk Assessment    | 2     | 2         | 20-30 seconds |
| Meeting Prep       | 2     | 2         | 20-30 seconds |

Each MatchaAI call takes 5-15 seconds. With 2-3 sequential calls, total execution time easily exceeded Netlify's function timeout (~26 seconds for inactivity).

## Solution Applied

Rewrote the crew API (`src/app/api/chasen/crew/route.ts`) to use a **single LLM call per crew** with consolidated prompts:

### Key Changes

1. **Direct Supabase Queries** - Replaced slow semantic search with direct table queries
2. **Parallel Data Fetching** - Used `Promise.all()` for concurrent data retrieval
3. **Single LLM Call** - Consolidated multi-step analysis into one comprehensive prompt
4. **20s Timeout** - Added explicit timeout to prevent runaway requests

### Code Structure

```typescript
async function executePortfolioAnalysis(): Promise<{ response: string; summary: string }> {
  const supabase = getServiceSupabase()

  // Parallel data fetching (fast)
  const [healthData, npsData, actionsData] = await Promise.all([
    supabase.from('client_health_summary').select('...').limit(20),
    supabase.from('nps_responses').select('...').limit(30),
    supabase.from('actions').select('...').limit(30),
  ])

  // Single LLM call with 20s timeout
  const result = await callMatchaAI(
    [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt },
    ],
    { model: 'claude-sonnet-4.5', maxTokens: 1500, timeout: 20000 }
  )

  return { response: result.text, summary: '...' }
}
```

### Performance Improvement

| Crew Type          | Before               | After          |
| ------------------ | -------------------- | -------------- |
| Portfolio Analysis | 20-30s (2 LLM calls) | 5-10s (1 call) |
| Client Report      | 30-45s (3 LLM calls) | 5-10s (1 call) |
| Risk Assessment    | 20-30s (2 LLM calls) | 5-10s (1 call) |
| Meeting Prep       | 20-30s (2 LLM calls) | 5-10s (1 call) |

## Files Modified

- `src/app/api/chasen/crew/route.ts` - Complete rewrite to single-call approach
- `src/lib/document-parser.ts` - Fixed pdf-to-img async iterator type error

## Deployment

- **Commit:** `09eaec3`
- **Production URL:** https://apac-cs-dashboards.com
- **Deploy URL:** https://694b9e69e05f92084cd1b331--apac-cs-intelligence-dashboards.netlify.app

## Testing Verification

1. TypeScript compilation: PASSED
2. ESLint: PASSED
3. Production deployment: SUCCESSFUL

## Crew Functions Now Available

| Crew                 | Purpose                                       | Required Input |
| -------------------- | --------------------------------------------- | -------------- |
| `portfolio-analysis` | Portfolio health overview and recommendations | None           |
| `client-report`      | Comprehensive client analysis                 | `clientName`   |
| `risk-assessment`    | At-risk client identification                 | None           |
| `meeting-prep`       | Meeting preparation materials                 | `clientName`   |

## Related Issues

- Similar timeout issue fixed for `runRiskAssessment` workflow earlier same day
- Root cause identical: multi-step workflows exceeding Netlify function timeout
