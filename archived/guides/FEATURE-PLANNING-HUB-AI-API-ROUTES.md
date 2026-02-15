# Feature: Planning Hub AI API Routes

**Date Implemented:** 2026-01-09
**Author:** Claude Code
**Status:** Completed

---

## Overview

Added 4 new API routes to support the Account Planning AI integration in the Planning Hub. These routes enable AI-powered stakeholder suggestions, action management, and portfolio-level analytics.

## New API Endpoints

### 1. POST `/api/planning/ai/suggest-stakeholders`

**Purpose:** Uses ChaSen AI (MatchaAI) to analyse meeting attendees and suggest stakeholders that should be mapped based on MEDDPICC requirements.

**Request Body:**
```typescript
{
  clientId?: string
  clientName: string           // Required
  planId?: string
  existingStakeholders?: {
    name: string
    role: string
    meddpiccRoles: string[]
  }[]
  meddpiccGaps?: string[]
}
```

**Response:**
```typescript
{
  success: true,
  data: {
    suggestions: [{
      name: string
      suggestedRole: string
      meddpiccRole: string
      confidence: number
      evidence: Array<{ source, date, context }>
      reason: string
      priority: 'high' | 'medium' | 'low'
    }],
    missingMeddpiccRoles: string[],
    analysedMeetings: number,
    totalUnmappedAttendees: number
  }
}
```

**Features:**
- Analyses last 6 months of meeting attendees
- Filters out internal (Altera/Harris) email addresses
- Identifies missing MEDDPICC role coverage
- Provides confidence scores and evidence for suggestions
- Prioritises suggestions by importance

---

### 2. POST `/api/planning/ai/accept-action`

**Purpose:** Updates an AI-recommended action status to 'accepted', indicating the CSE has acknowledged and will act on it.

**Request Body:**
```typescript
{
  actionId: string    // Required
  acceptedBy?: string
  notes?: string
}
```

**Response:**
```typescript
{
  success: true,
  data: {
    action: NextBestAction,
    previousStatus: string,
    newStatus: 'accepted'
  },
  message: string
}
```

**Validations:**
- Action must exist
- Cannot accept an already completed action
- Cannot accept an already dismissed action

---

### 3. POST `/api/planning/ai/dismiss-action`

**Purpose:** Updates an AI-recommended action status to 'dismissed', including the reason for dismissal. Dismissal reasons are tracked to improve future AI recommendations.

**Request Body:**
```typescript
{
  actionId: string           // Required
  reason: DismissalReason    // Required
  reasonDetails?: string
  dismissedBy?: string
}
```

**Valid Dismissal Reasons:**
- `not_relevant` - Not relevant to this client
- `already_done` - Already completed this action
- `wrong_priority` - Priority assessment is incorrect
- `timing_not_right` - Timing is not appropriate
- `different_approach` - Taking a different approach
- `client_preference` - Client preference differs
- `other` - Other reason

**Response:**
```typescript
{
  success: true,
  data: {
    action: NextBestAction,
    previousStatus: string,
    newStatus: 'dismissed',
    dismissalReason: {
      code: string,
      label: string,
      details: string | null
    }
  }
}
```

**Additional Endpoints:**
- `GET /api/planning/ai/dismiss-action` - Returns list of valid dismissal reasons for UI dropdowns

---

### 4. GET `/api/planning/portfolio/analytics`

**Purpose:** Returns portfolio-level analytics for the Planning Hub including health distribution, financial metrics, engagement velocity, and risk indicators.

**Query Parameters:**
- `cseName` - Filter by CSE name
- `camName` - Filter by CAM name
- `includeDetails` - Set to 'true' to include detailed client lists

**Response Structure:**
```typescript
{
  success: true,
  data: {
    overview: {
      totalClients: number,
      totalARR: number,
      avgHealthScore: number,
      healthyPercentage: number,
      atRiskPercentage: number
    },
    healthDistribution: {
      healthy: { count, arr },
      warning: { count, arr },
      critical: { count, arr },
      unknown: { count, arr }
    },
    financialMetrics: {
      totalARR: number,
      atRiskARR: number,
      renewalPipeline30Days: number,
      renewalPipeline90Days: number,
      avgARRPerClient: number,
      topClientsByARR: Array<{ clientName, arr, healthStatus }>
    },
    engagementMetrics: {
      avgDaysSinceContact: number,
      clientsNoContactIn30Days: number,
      clientsNoContactIn60Days: number,
      totalMeetingsLast30Days: number,
      totalMeetingsLast90Days: number,
      avgMeetingsPerClientMonth: number,
      engagementVelocity: 'accelerating' | 'stable' | 'declining'
    },
    riskMetrics: {
      totalAtRiskClients: number,
      totalAtRiskARR: number,
      criticalClients: Array<{ clientName, healthScore, arr, primaryConcern }>,
      decliningHealthClients: number,
      overdueActionsCount: number,
      npsDetractorsCount: number
    },
    trends: {
      healthTrend: Array<{ period, avgScore, count }>,
      engagementTrend: Array<{ period, meetings, avgDaysBetween }>,
      riskTrend: Array<{ period, atRiskCount, atRiskARR }>
    },
    generatedAt: string
  }
}
```

**Health Thresholds:**
- Healthy: score >= 70
- Warning: score >= 50 and < 70
- Critical: score < 50

---

## Database Tables Used

All routes use the service role Supabase client to bypass RLS:

| Route | Tables |
|-------|--------|
| suggest-stakeholders | `unified_meetings` |
| accept-action | `next_best_actions` |
| dismiss-action | `next_best_actions`, `nba_dismissal_feedback` |
| portfolio/analytics | `client_segmentation`, `client_health_history`, `client_arr`, `unified_meetings`, `actions`, `nps_responses` |

---

## Files Created

| File Path | Lines | Purpose |
|-----------|-------|---------|
| `src/app/api/planning/ai/suggest-stakeholders/route.ts` | 380 | AI stakeholder suggestions |
| `src/app/api/planning/ai/accept-action/route.ts` | 119 | Accept NBA action |
| `src/app/api/planning/ai/dismiss-action/route.ts` | 211 | Dismiss NBA action with feedback |
| `src/app/api/planning/portfolio/analytics/route.ts` | 550 | Portfolio-level analytics |

---

## Integration Notes

### MatchaAI Integration
The `suggest-stakeholders` endpoint uses the same MatchaAI configuration as other ChaSen endpoints:
- Uses mission ID from `MATCHAAI_MISSION_ID` env variable
- Uses Claude Sonnet 4.5 (LLM ID: 71)
- Rate limited via `applyRateLimit()` utility

### Rate Limiting
All AI endpoints are rate limited using the existing `applyRateLimit` utility from `@/lib/api-utils`.

### Error Handling
All endpoints use standardised error responses via `createErrorResponse()` with appropriate HTTP status codes:
- 400: Bad request (missing parameters)
- 404: Resource not found
- 500: Server error

---

## Testing

To test the endpoints locally:

```bash
# Suggest stakeholders
curl -X POST http://localhost:3000/api/planning/ai/suggest-stakeholders \
  -H "Content-Type: application/json" \
  -d '{"clientName": "Test Client"}'

# Accept action
curl -X POST http://localhost:3000/api/planning/ai/accept-action \
  -H "Content-Type: application/json" \
  -d '{"actionId": "uuid-here"}'

# Dismiss action
curl -X POST http://localhost:3000/api/planning/ai/dismiss-action \
  -H "Content-Type: application/json" \
  -d '{"actionId": "uuid-here", "reason": "not_relevant"}'

# Get dismissal reasons
curl http://localhost:3000/api/planning/ai/dismiss-action

# Get portfolio analytics
curl "http://localhost:3000/api/planning/portfolio/analytics?cseName=John%20Smith&includeDetails=true"
```

---

## Related Files

- `/src/app/api/planning/ai/insights/route.ts` - Reference pattern
- `/src/app/api/planning/ai/next-best-actions/route.ts` - NBA management
- `/src/lib/next-best-action.ts` - NBA engine utilities
- `/src/types/planning.ts` - Type definitions
