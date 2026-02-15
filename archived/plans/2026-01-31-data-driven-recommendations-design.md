# Data-Driven Recommendations with Evidence Cards

## Overview

Enhance the Sales Hub AI Recommendations page to show transparent, data-backed reasoning for each recommendation. Users will see exactly why a product/bundle was recommended with cited evidence from client data.

## Current State

Recommendations show:
- Product/bundle title
- Match percentage (opaque calculation)
- Generic reason text ("Directly addresses SA Health's interest in...")

**Problem:** No transparency into scoring logic, no cited evidence, builds limited trust.

## Design: Evidence Cards

Each recommendation expands to show structured evidence:

```
┌────────────────────────────────────────────────────────────────────┐
│ ┌──┐                                                               │
│ │1 │  TouchWorks Note+              Product    85% match    [+] [↗]│
│ └──┘                                                               │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  📋 WHY THIS MATCHES                                               │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │ ✓ Topic match      "clinical documentation" — 3 meetings    │  │
│  │ ✓ NPS feedback     Client mentioned documentation needs     │  │
│  │ ✓ Health priority  At-risk client → retention focus         │  │
│  │ ✓ ARR tier         Enterprise ($1.2M) → strategic fit       │  │
│  │ ✓ Stack gap        Not in current: Sunrise, OPAL            │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                                                    │
│  📊 SCORE BREAKDOWN                                                │
│  [████████████░░░░] Topic 30  [██████░░░░] NPS 20                 │
│  [██████░░░░░░░░░░] Health 20 [████░░░░░░] ARR 10                 │
│  [████░░░░░░░░░░░░] Stack 10  [██░░░░░░░░] Base 10   = 85%       │
│                                                                    │
│  💬 CLIENT FEEDBACK                                                │
│  "We need better tools for clinical documentation — our            │
│   physicians spend too much time on paperwork" — Q4 25 NPS        │
│                                                                    │
│  💡 EVIDENCE                                                       │
│  • "40% reduction in documentation time" — NHS Trust case study   │
│  • 12 similar APAC clients using this product                     │
│  • Target personas: CMIO, CNO ← aligns with your stakeholders     │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

## Data Model

### Evidence Factors (scoring inputs)

| Factor | Source Table | Data Point | Max Points |
|--------|--------------|------------|------------|
| Topic match | `unified_meetings` | Topics from last 90 days matching product | 30 |
| NPS feedback | `nps_responses` | Verbatim text matching product keywords | 20 |
| Health priority | `client_health_history` | Status affects recommendation weight | 20 |
| ARR tier | `nps_clients` | Enterprise/mid-market/standard | 10 |
| Stack gap | `client_products` | Products NOT in current deployment | 10 |
| Base score | - | All recommendations start here | 10 |

**Total: 100 points maximum**

### Supporting Evidence (credibility builders)

| Evidence | Source Table | Data Point |
|----------|--------------|------------|
| Proof points | `value_wedges` | `defensible_proof` array |
| Similar clients | `client_products` | Count of APAC clients with this product |
| Target personas | `value_wedges` | `target_personas` array |
| Competitive positioning | `value_wedges` | Positioning statement |

### TypeScript Types

```typescript
type RecommendationEvidence = {
  factors: {
    topicMatch: {
      matched: string[]
      meetingCount: number
      score: number
    }
    npsMatch: {
      verbatim: string | null
      period: string | null
      score: number
    }
    healthPriority: {
      status: string
      reason: string
      score: number
    }
    arrTier: {
      tier: 'enterprise' | 'mid-market' | 'standard'
      amount: number
      score: number
    }
    stackGap: {
      missing: boolean
      currentStack: string[]
      score: number
    }
  }
  proofPoints: string[]
  similarClientCount: number
  targetPersonas: string[]
  totalScore: number
}

type EnrichedRecommendation = Recommendation & {
  evidence: RecommendationEvidence
}
```

## Updated Client Context

```typescript
type ClientContext = {
  // Existing fields
  id: number
  name: string
  arr_usd: number | null
  health_score: number | null
  health_status: string | null
  currentProducts: string[]
  recentTopics: string[]

  // New fields for evidence
  npsVerbatims: Array<{
    feedback: string
    score: number
    period: string
  }>
  meetingTopicCounts: Record<string, number>
  arrTier: 'enterprise' | 'mid-market' | 'standard'
}
```

## File Changes

| File | Change |
|------|--------|
| `src/hooks/useClientContext.ts` | Add NPS verbatims, topic counts, ARR tier |
| `src/app/(dashboard)/sales-hub/recommendations/page.tsx` | New evidence generation logic |
| `src/components/sales-hub/EvidenceCard.tsx` | NEW: Expandable evidence card |

## UI Behaviour

### Expand/Collapse
- Click card → toggle expanded state
- Chevron indicator (▼/▲) shows current state
- Smooth CSS transition on height change
- Default: First recommendation expanded, rest collapsed

### Visual Hierarchy
- **Header row**: Always visible (rank, title, badges, actions)
- **Factors section**: Green checkmarks for positive factors
- **Score bars**: Purple filled bars showing contribution
- **Feedback quote**: Blue background block with verbatim
- **Evidence bullets**: Muted grey with source attribution

### Colour Tokens
- Positive factor: `text-green-600` with ✓
- Neutral factor: `text-gray-400` with ○
- Score bars: `bg-purple-200` (track), `bg-purple-600` (fill)
- Feedback block: `bg-blue-50` with `border-l-4 border-blue-400`

## Data Flow

1. **Select client** → Fetch enriched context (existing + NPS + topic counts)
2. **Generate recommendations** → Calculate scores with factor breakdown
3. **Enrich each recommendation** → Query `value_wedges`, count similar clients
4. **Render Evidence Cards** → Display with expand/collapse interaction

## Performance Considerations

- 2 additional queries per recommendation generation (value_wedges, client_products count)
- NPS verbatims fetched once per client selection (batch with context)
- Similar client count can be cached (changes infrequently)

## Success Criteria

1. Each recommendation shows clear reasoning with cited data
2. Score breakdown is transparent and understandable
3. NPS verbatims surface when relevant
4. Users can see proof points from value wedges
5. UI remains clean with progressive disclosure (expand to see detail)
