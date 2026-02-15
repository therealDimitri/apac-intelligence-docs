# Bug Report: ChaSen Not Reading Real Data

**Date:** 24 December 2024
**Status:** FIXED
**Component:** ChaSen AI Chat API
**Commit:** 087c7fc

## Issue Description

ChaSen was responding with generic advice instead of using real portfolio data. When asked about at-risk clients, it would provide template-style responses like "Risk Assessment Report" with hardcoded "LOW" risk levels instead of actual client health scores and status.

## Root Cause

The `DATA_FETCH_TIMEOUT_MS` was set to **3 seconds** which was too aggressive for the 25+ concurrent database queries in `gatherPortfolioContext()`. This caused:

1. **Timeout on data fetch** - The Promise.race between data fetching and timeout would resolve to 'timeout' before queries completed
2. **Empty context passed to LLM** - When timeout occurred, ChaSen received minimal empty context:
   ```typescript
   portfolioContext = {
     summary: {},
     recentNPS: [],
     recentMeetings: [],
     openActions: [],
   }
   ```
3. **Generic responses** - Without real data, the LLM had to generate template-style responses

## Fix Applied

**File:** `src/app/api/chasen/chat/route.ts`

### 1. Increased timeout from 3s to 12s

```typescript
// Before
const DATA_FETCH_TIMEOUT_MS = 3000

// After
const DATA_FETCH_TIMEOUT_MS = 12000 // 12 seconds max for data fetching (leaves 13s for LLM)
```

This gives adequate time for 25+ concurrent Supabase queries while still leaving ~13 seconds for LLM response generation within Netlify's 25-second function limit.

### 2. Added context stats logging

Added detailed logging to track what data was actually fetched:

```typescript
const contextStats = {
  npsCount: portfolioContext.recentNPS?.length || 0,
  meetingsCount: portfolioContext.recentMeetings?.length || 0,
  actionsCount: portfolioContext.openActions?.length || 0,
  hasHealth: !!portfolioContext.health,
  hasARR: !!portfolioContext.arr,
  hasAging: !!portfolioContext.aging,
  hasSummary: Object.keys(portfolioContext.summary || {}).length > 0,
  knowledgeLength: knowledgeContext?.length || 0,
  semanticDocs: semanticContext?.relevantDocuments?.length || 0,
}
console.log(`[ChaSen Chat] Context data loaded: ${JSON.stringify(contextStats)}`)
```

This allows easy debugging in Netlify logs when data access issues occur.

## Data Flow Analysis

The `gatherPortfolioContext()` function queries:

- `nps_clients` - Client list and segments
- `unified_meetings` - Recent and historical meetings
- `actions` - Open action items
- `nps_responses` - Recent and historical NPS scores
- `segmentation_event_compliance` - Compliance status
- `client_arr` - Revenue data
- `segmentation_compliance_scores` - AI predictions
- `segmentation_events` - Scheduled events
- `nps_topic_classifications` - NPS topic analysis
- `portfolio_initiatives` - Strategic projects
- `client_segmentation` - Tier assignments
- `client_health_summary` - Pre-calculated health scores (materialized view)
- `cse_profiles` - Team member data
- `cse_client_assignments` - CSE assignments
- `event_compliance_summary` - Event metrics
- `departments`, `activity_types` - Reference data
- `notifications` - User alerts
- `nps_period_config` - NPS settings
- `chasen_conversations` - Previous conversations
- Plus knowledge base and semantic search

All these queries running in parallel via `Promise.all` need adequate time to complete.

## Testing

After deployment, verify ChaSen responds with real data:

1. Ask "Which clients are at risk?"
2. Ask "What's the health status of my portfolio?"
3. Check Netlify logs for context stats showing non-zero counts

## Prevention

Consider future optimisations:

1. **Query caching** - Cache frequently accessed data like client lists
2. **Query batching** - Combine related queries into single requests
3. **Progressive loading** - Return initial response while loading additional context
4. **Connection pooling** - Reuse database connections
