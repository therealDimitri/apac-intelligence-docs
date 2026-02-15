# Predictive Health Scoring System Implementation

**Date:** 2026-01-09
**Type:** Feature Implementation
**Status:** Completed
**Priority:** High

## Summary

Implemented a comprehensive predictive health scoring system that provides AI-driven analytics for client health, including churn risk assessment, expansion probability scoring, and engagement velocity tracking.

## Components Created/Modified

### 1. Library File (Pre-existing - No changes required)

**File:** `src/lib/predictive-health.ts`

The library already existed with the following functions:
- `calculateChurnRisk(clientId)` - Returns 0-100 churn risk score
- `calculateExpansionProbability(clientId)` - Returns 0-100 expansion likelihood
- `calculateEngagementVelocity(clientId)` - Returns meetings per quarter trend
- `predictHealthTrajectory(clientId)` - Predicts health scores at 30 and 90 days
- `calculatePeerBenchmark(clientId)` - Compares client to peers in same tier
- `generatePredictiveScores(clientId)` - Combines all scoring functions

### 2. API Endpoint (New)

**File:** `src/app/api/planning/predictive/health/route.ts`

**Endpoints:**
- `GET /api/planning/predictive/health?clientId=xxx` - Fetch predictive health analysis
- `POST /api/planning/predictive/health` - Refresh/regenerate predictive analysis

**Response Structure:**
```typescript
{
  success: boolean,
  data: {
    clientId: string,
    clientName: string,
    currentHealth: {
      score: number,
      status: 'healthy' | 'at-risk' | 'critical',
      lastUpdated: string | null
    },
    predictions: {
      thirtyDay: { score, status, change, confidence },
      ninetyDay: { score, status, change, confidence },
      trend: 'improving' | 'stable' | 'declining',
      trendSlope: number
    },
    churnRisk: {
      score: number,
      level: 'critical' | 'high' | 'medium' | 'low',
      riskFactors: RiskFactor[]
    },
    expansionProbability: {
      score: number,
      level: 'high' | 'medium' | 'low',
      opportunitySignals: ExpansionFactor[]
    },
    engagementVelocity: {
      meetingsPerQuarter: number,
      trend: 'increasing' | 'stable' | 'decreasing',
      velocityScore: number,
      percentageChange: number
    },
    peerBenchmark: PeerBenchmark | null,
    metadata: { calculatedAt, modelVersion }
  }
}
```

### 3. Component Update (Modified)

**File:** `src/components/planning/AccountPlanAIInsights.tsx`

**Changes:**
- Added `PredictiveScores` interface for type safety
- Added helper functions for styling:
  - `getChurnRiskConfig()`
  - `getExpansionConfig()`
  - `getVelocityTrendConfig()`
  - `getConfidenceConfig()`
- Created `PredictiveScoresPanel` sub-component displaying:
  - Score cards grid (Churn Risk, Expansion, 30-Day Health, Engagement)
  - Health predictions with progress bars and confidence indicators
  - Risk factors list with severity indicators
  - Opportunity signals list with strength indicators
  - Peer benchmark comparison table
- Added new prop: `showPredictiveScores?: boolean` (defaults to true)
- Added state management for predictive scores fetching
- Added `useEffect` hook to fetch scores on component mount

## UI Features

### Score Cards
- **Churn Risk:** Red/orange/amber/green colour coding based on level
- **Expansion Probability:** Green/blue/grey colour coding based on level
- **30-Day Health:** Blue with up/down arrows for predicted change
- **Engagement Velocity:** Grey with trend indicators

### Health Predictions Panel
- Progress bars showing predicted scores
- Confidence badges (high/medium/low)
- Trend indicator badge

### Risk Factors & Opportunity Signals
- Severity/strength indicators with coloured dots
- Truncated descriptions with full text on hover
- Top 3 items shown per section

### Peer Benchmark
- Rank and percentile display
- Peer average comparison
- Standing badge (Above/Below/Average)

## Database Tables Used

- `client_segmentation` - Client identification and tier info
- `client_health_history` - Historical health scores
- `nps_responses` - NPS data for trend analysis
- `unified_meetings` - Meeting frequency data
- `actions` - Action completion rates
- `aging_accounts` - Financial health indicators
- `event_compliance_by_client` - Compliance data
- `segment_tiers` - Tier definitions for benchmarking

## Testing

### Build Validation
- TypeScript compilation: **Passed**
- Next.js build: **Passed**
- API route registered: **Confirmed** (`/api/planning/predictive/health`)

### Manual Testing Checklist
- [ ] API returns data for valid clientId
- [ ] API returns error for invalid clientId
- [ ] Component displays loading state
- [ ] Component displays error state with retry
- [ ] Score cards display correct values and colours
- [ ] Predictions panel shows progress bars correctly
- [ ] Risk factors display with severity indicators
- [ ] Opportunity signals display with strength indicators
- [ ] Peer benchmark shows when available
- [ ] Refresh button triggers new calculation

## Known Limitations

1. **Schema validation warnings** - Two pre-existing table references in `predictive-health.ts` (lines 311, 914) reference tables not in the schema docs:
   - `event_compliance_by_client`
   - `segment_tiers`
   These are views/tables that exist but aren't documented in `docs/database-schema.md`.

2. **Confidence scores** - Predictions use simplified statistical methods (linear regression, moving averages) rather than ML models. Confidence is based on data availability rather than model accuracy.

3. **Peer benchmarking** - Only compares clients within the same tier. Requires at least 2 clients in tier for meaningful comparison.

## Related Files

- `/docs/DATABASE_STANDARDS.md` - Database query standards
- `/docs/database-schema.md` - Table schema reference
- `/src/lib/health-score-config.ts` - Health score calculation configuration

## Future Improvements

1. Add caching layer for frequently-accessed clients
2. Implement webhooks for real-time score updates when data changes
3. Add ML model integration for more accurate predictions
4. Create historical trend visualisation for predictions accuracy
5. Add export functionality for predictive reports
