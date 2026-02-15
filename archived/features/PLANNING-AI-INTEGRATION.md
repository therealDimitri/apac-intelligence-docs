# ChaSen AI Integration for Account Planning

**Created:** 2026-01-09
**Status:** Implemented
**Category:** Feature - AI Integration

## Summary

Implemented a comprehensive AI-powered planning library (`/src/lib/planning-ai.ts`) and React hook (`/src/hooks/usePlanningAI.ts`) that provides intelligent account planning features for Customer Success.

## Components Created

### 1. Planning AI Library (`/src/lib/planning-ai.ts`)

A server-side library that provides six AI-powered planning functions:

| Function | Purpose | Data Sources |
|----------|---------|--------------|
| `generateAccountSummary(clientId)` | Executive summary with health, NPS, engagement overview | Health, NPS, Meetings, Actions, AR |
| `analyseRisks(clientId)` | Risk identification and scoring | Health trends, NPS detractors, Meeting risks, AR |
| `detectMEDDPICC(clientId)` | MEDDPICC sales methodology element detection | Meeting notes, NPS feedback, Actions |
| `suggestStakeholders(clientId)` | Stakeholder mapping from interactions | Meeting attendees, NPS respondents |
| `generateNextBestActions(clientId)` | Prioritised action recommendations | All data sources |
| `generateDraftPlan(clientId)` | Complete draft account plan | Composes all above functions |

### 2. React Hook (`/src/hooks/usePlanningAI.ts`)

A comprehensive React hook providing:

- **Individual function states** with loading, error, and data
- **Caching** with configurable TTL (default 10 minutes)
- **Batch operations** for efficient multi-function calls
- **Convenience hooks** for single-function usage
- **Direct API functions** for non-React contexts

## Architecture

### Data Flow

```
Client ID
    |
    v
+------------------+
| gatherClientContext() |  <-- Supabase queries (parallel)
+------------------+
    |
    v
+------------------+
| Build AI Prompt  |  <-- Context-specific prompts
+------------------+
    |
    v
+------------------+
| callMatchaAI()   |  <-- MatchaAI corporate AI proxy
+------------------+
    |
    v
+------------------+
| Parse & Structure|  <-- JSON parsing with fallbacks
+------------------+
    |
    v
+------------------+
| Return Typed Data|  <-- Full TypeScript types
+------------------+
```

### Data Sources Queried

The library queries the following Supabase tables:

1. `client_health_history` - Health scores and trends
2. `unified_meetings` - Meeting notes, topics, risks, attendees
3. `nps_responses` - NPS scores, feedback, respondent info
4. `actions` - Open actions, priorities, due dates
5. `client_segmentation` - Tier, CSE assignment
6. `aging_accounts` - AR outstanding and overdue
7. `clients` / `client_aliases` - Client UUID resolution

### AI Model Used

- **Primary:** Claude Sonnet 4.5 via MatchaAI proxy (llm_id: 28)
- **Fallback:** Direct Anthropic API if configured

## Type Definitions

All functions return structured TypeScript types with:

- Confidence scores (0-1 scale)
- Data source attribution
- Generation timestamps
- Composable sub-types

### Key Types

```typescript
// All results include confidence scoring
interface ConfidenceScored {
  confidence: number // 0-1 scale
}

// Data provenance tracking
interface DataSource {
  type: 'meeting' | 'nps' | 'action' | 'health' | 'financial' | 'stakeholder' | 'compliance'
  id?: string
  name: string
  date?: string
  relevance: number
}

// Example: Account Summary
interface AccountSummary extends ConfidenceScored {
  clientName: string
  executiveSummary: string
  keyHighlights: string[]
  healthOverview: { ... }
  engagementSummary: { ... }
  npsSnapshot: { ... }
  financialStatus: { ... }
  topPriorities: Array<{ ... }>
  dataSources: DataSource[]
  generatedAt: string
}
```

## Usage Examples

### Basic Hook Usage

```tsx
'use client'

import { usePlanningAI } from '@/hooks/usePlanningAI'

function AccountPlanningPage({ clientId }: { clientId: string }) {
  const {
    accountSummary,
    riskAnalysis,
    generateAccountSummary,
    analyseRisks,
    isAnyLoading,
  } = usePlanningAI(clientId)

  return (
    <div>
      <button onClick={() => generateAccountSummary()}>
        Generate Summary
      </button>

      {accountSummary.loading && <Spinner />}
      {accountSummary.data && (
        <SummaryCard data={accountSummary.data} />
      )}
    </div>
  )
}
```

### Auto-fetch on Mount

```tsx
const planning = usePlanningAI(clientId, {
  autoFetch: true,
  cacheTTL: 15 * 60 * 1000, // 15 minutes
})
```

### Single Function Hook

```tsx
import { useAccountSummary } from '@/hooks/usePlanningAI'

function SummaryWidget({ clientId }: { clientId: string }) {
  const { data, loading, error, generate } = useAccountSummary(clientId)

  // ...
}
```

### Batch Generation

```tsx
const { generateAll, generateQuickInsights } = usePlanningAI(clientId)

// Generate all 6 functions in parallel
await generateAll()

// Generate just summary, risks, and actions (faster)
await generateQuickInsights()
```

### Force Refresh

```tsx
// Skip cache and regenerate
await generateAccountSummary(true)
```

## API Endpoints Required

The hook expects these API endpoints to exist:

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/planning/ai/summary` | POST | Account summary |
| `/api/planning/ai/risks` | POST | Risk analysis |
| `/api/planning/ai/meddpicc` | POST | MEDDPICC detection |
| `/api/planning/ai/stakeholders` | POST | Stakeholder suggestions |
| `/api/planning/ai/actions` | POST | Next best actions |
| `/api/planning/ai/plan` | POST | Draft plan generation |

All endpoints accept:
```json
{
  "clientId": "Client Name or UUID",
  "forceRefresh": false
}
```

## Error Handling

- Network errors caught and stored in state
- AI parsing errors handled with fallback defaults
- Missing client data returns null with appropriate error
- Rate limiting supported via existing `api-utils` patterns

## Caching Strategy

1. **Client-side cache** via `@/lib/cache` singleton
2. **Cache key format:** `planning-ai-{function}-{sanitised-client-id}`
3. **Default TTL:** 10 minutes
4. **Cache invalidation:** Manual via `clearCache()` or force refresh

## Performance Considerations

1. **Parallel queries:** All Supabase queries run in parallel via `Promise.all`
2. **UUID optimisation:** Uses `client_uuid` for joins where available
3. **Caching:** Prevents redundant AI calls
4. **Batch operations:** `generateAll` runs all functions in parallel
5. **In-flight tracking:** Prevents duplicate concurrent requests

## Future Enhancements

1. Add API route implementations for all endpoints
2. Add streaming support for real-time AI responses
3. Add insight persistence to database
4. Add comparative analysis between clients
5. Add custom prompt templates per client tier

## Files Created

| File | Purpose |
|------|---------|
| `/src/lib/planning-ai.ts` | Core AI planning functions library |
| `/src/hooks/usePlanningAI.ts` | React hook with state management |

## Related Documentation

- `@/lib/ai-providers.ts` - MatchaAI configuration
- `@/lib/client-resolver.ts` - Client UUID resolution
- `@/lib/api-utils.ts` - Rate limiting and error handling
- `/api/planning/ai/insights/route.ts` - Existing insights API pattern
