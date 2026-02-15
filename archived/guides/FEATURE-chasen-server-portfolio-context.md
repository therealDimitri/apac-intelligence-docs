# Feature: ChaSen Server-Side Portfolio Context

**Date Implemented:** 2026-01-10
**Status:** Completed
**Phase:** 8 - ChaSen Corrected Compliance Integration

## Overview

Created a server-side portfolio context utility for ChaSen AI to access corrected compliance data. This ensures ChaSen uses the same segment-change-aware compliance calculations as the client-side UI.

## Problem Statement

ChaSen AI runs server-side in `/src/app/api/chasen/chat/route.ts` and cannot use React hooks directly. The `ClientPortfolioContext` on the client side provides corrected compliance calculations via `useAllClientsCompliance`, but ChaSen was using raw compliance data from the materialized view, which didn't account for segment changes.

### Impact
- ChaSen responses about client health could use inaccurate compliance data
- Clients with segment changes mid-year would show incorrect compliance percentages
- Health scores in ChaSen responses wouldn't match the UI

## Solution

### New Utility: `/src/lib/server-portfolio-context.ts`

Created a server-side utility that provides the same corrected compliance logic as the client-side context:

#### Exported Functions

1. **`getPortfolioData()`** - Returns enriched clients with:
   - Corrected compliance (segment-change-aware)
   - Recalculated health scores using corrected compliance
   - Segment change metadata (deadline, months remaining)
   - All standard client metrics

2. **`getPortfolioStats()`** - Returns aggregated statistics:
   - Health distribution (healthy/at-risk/critical counts)
   - Average health score and compliance
   - Segment distribution
   - CSE workload distribution

3. **`getAllClientsComplianceServer(year)`** - Returns compliance map:
   - Corrected compliance for each client
   - Event-type breakdown
   - Segment change detection

4. **`getClientCompliance(clientName)`** - Single client lookup

5. **`getEnrichedClient(clientName)`** - Single enriched client lookup

6. **`formatPortfolioContextForChaSen()`** - Pre-formatted context string for ChaSen prompts

7. **`clearServerPortfolioCache()`** - Cache management

#### Key Features

- **No React Hooks** - Pure async functions suitable for server-side use
- **Segment Change Detection** - Replicates client-side `detectSegmentChange` logic
- **Compliance Recalculation** - When segment changes mid-year, compliance is recalculated from the change month onwards
- **Extended Deadlines** - Clients with segment changes get deadlines extended to June 30 of following year
- **Short TTL Caching** - 30 seconds to balance performance with data freshness

### ChaSen Route Updates

Modified `/src/app/api/chasen/chat/route.ts`:

1. **Import new utility**
2. **Fetch corrected compliance data** in parallel with existing queries
3. **Merge corrected data** into client health scores
4. **Add to system prompt** - New sections for:
   - Corrected compliance context
   - Clients with extended deadlines
   - Segment change metadata

## Type Changes

### `PortfolioSummary` Interface
Added:
- `correctedComplianceAverage: number | null`
- `segmentChangedClientsCount: number`

### `HealthScoreData` Interface
Added:
- `hasSegmentChanged?: boolean`
- `monthsToDeadline?: number`
- `complianceDeadline?: string | null`
- `segment?: string | null`
- `status?: string`
- `meetingCount90d?: number`

### `PortfolioData.health` Interface
Added:
- `correctedComplianceContext?: string`
- `segmentChangedClients?: Array<{ client, compliancePercentage, monthsToDeadline, deadline }>`

## Files Changed

1. **Created:** `/src/lib/server-portfolio-context.ts`
2. **Modified:** `/src/app/api/chasen/chat/route.ts`
   - Added imports
   - Enhanced `gatherPortfolioContext()` function
   - Updated `PortfolioSummary` interface
   - Updated `HealthScoreData` interface
   - Updated `PortfolioData` interface
   - Added corrected compliance to system prompt

## Testing

- Build passes with no TypeScript errors
- Existing tests unaffected (pre-existing failures in unrelated `useUserProfile` tests)
- Server-side utility can be imported and used in API routes

## Cache Strategy

The server-side cache uses a 30-second TTL because:
- Compliance can change when meetings are recorded
- Balance between performance and data freshness
- Queries to Supabase are relatively fast (~150ms)

## Usage Example

```typescript
// In any server-side API route
import {
  getPortfolioData,
  getPortfolioStats,
  formatPortfolioContextForChaSen
} from '@/lib/server-portfolio-context'

// Get all enriched clients with corrected compliance
const clients = await getPortfolioData()

// Get portfolio summary stats
const stats = await getPortfolioStats()

// Get pre-formatted context for AI prompts
const context = await formatPortfolioContextForChaSen()
```

## Related Files

- `/src/contexts/ClientPortfolioContext.tsx` - Client-side equivalent
- `/src/hooks/useEventCompliance.ts` - Compliance calculation logic source
- `/src/lib/segment-deadline-utils.ts` - Segment deadline utilities
- `/src/lib/health-score-config.ts` - Health score calculation

## Follow-Up Considerations

1. Consider adding real-time cache invalidation when compliance data changes
2. Could add more granular caching (per-client vs whole portfolio)
3. Monitor Supabase query performance in production
