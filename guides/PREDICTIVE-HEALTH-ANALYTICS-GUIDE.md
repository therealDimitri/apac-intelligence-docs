# Predictive Health Analytics System Guide

**Created**: 2026-01-09
**Version**: 1.0.0
**Status**: Implemented

## Overview

The Predictive Health Analytics system provides forward-looking insights into client health by analysing historical data and identifying patterns that indicate future behaviour. It uses simple statistical methods (moving averages, linear regression) to keep the system lightweight without external ML library dependencies.

## Components

### 1. Core Library (`/src/lib/predictive-health.ts`)

The main TypeScript library providing all predictive analytics functions.

#### Key Functions

| Function | Description | Returns |
|----------|-------------|---------|
| `calculateChurnRisk(clientId)` | Calculate churn probability (0-100) | Risk score, level, contributing factors |
| `calculateExpansionProbability(clientId)` | Calculate expansion/upsell likelihood (0-100) | Probability, level, positive factors |
| `calculateEngagementVelocity(clientId)` | Measure meetings per quarter and trend | Velocity score, trend direction, % change |
| `predictHealthTrajectory(clientId)` | Predict health score 30/90 days out | Current, predicted scores, trend, confidence |
| `identifyRiskFactors(clientId)` | Return array of risk factors | Array of RiskFactor objects |
| `calculatePeerBenchmark(clientId)` | Compare to similar accounts in same tier | Rank, percentile, comparison status |
| `generatePredictiveScores(clientId)` | Generate complete predictive scores | Full PredictiveScores object |
| `generateAllPredictiveScores()` | Batch generate for all clients | Array of PredictiveScores |

### 2. Batch Job Script (`/scripts/generate-predictive-scores.mjs`)

A standalone Node.js script that calculates and stores predictive scores for all clients in the `predictive_health_scores` table.

#### Usage

```bash
# Generate scores for all clients
node scripts/generate-predictive-scores.mjs

# Generate for a specific client only
node scripts/generate-predictive-scores.mjs --client "Client Name"

# Dry run (calculate but don't save)
node scripts/generate-predictive-scores.mjs --dry-run

# Verbose output
node scripts/generate-predictive-scores.mjs --verbose
```

## Algorithm Details

### Churn Risk Calculation

The churn risk score (0-100) is calculated using a weighted combination of factors:

| Factor | Weight | Description |
|--------|--------|-------------|
| Health Trajectory | 25% | Declining health score trend |
| NPS Trend | 20% | Declining NPS scores over time |
| Meeting Frequency | 15% | Low engagement in last 3 months |
| Action Completion | 15% | Poor follow-through on actions |
| Aging Balance | 15% | Overdue receivables indicating financial stress |
| Sentiment Trend | 10% | Negative sentiment in communications |

**Risk Levels**:
- High: Score >= 65
- Medium: Score 40-64
- Low: Score < 40

### Expansion Probability Calculation

The expansion probability (0-100) is calculated from positive indicators:

| Factor | Weight | Description |
|--------|--------|-------------|
| Health Improvement | 25% | Upward health score trend |
| Promoter NPS | 25% | High NPS score (50+) |
| Positive Sentiment | 20% | Positive sentiment in communications |
| Engagement Increase | 15% | Meeting frequency growing |
| Compliance Rate | 15% | High compliance percentage |

**Probability Levels**:
- High: Score >= 70
- Medium: Score 45-69
- Low: Score < 45

### Health Trajectory Prediction

Uses linear regression on historical health scores to project future values:

1. Collect health history (last 6 months)
2. Fit linear regression model (y = slope * x + intercept)
3. Project 30 days (1 period) and 90 days (3 periods) ahead
4. Determine confidence based on R² value and data quantity

**Confidence Levels**:
- High: R² >= 0.6 and 6+ data points
- Medium: Default
- Low: R² < 0.3 or fewer than 4 data points

### Peer Benchmarking

Compares the client against others in the same tier:

1. Fetch all clients in the same tier
2. Get latest health scores for each
3. Rank by health score (highest = rank 1)
4. Calculate percentile (100 = top performer)
5. Determine comparison status (above/average/below)

## Data Sources

The system pulls data from these tables:

| Table | Data Used |
|-------|-----------|
| `client_segmentation` | Client info, tier assignment |
| `client_health_history` | Historical health scores and components |
| `nps_responses` | NPS scores over time |
| `unified_meetings` | Meeting history and sentiment |
| `aging_accounts` | Receivables and overdue amounts |
| `actions` | Action completion tracking |
| `event_compliance_by_client` | Compliance percentage |
| `segment_tiers` | Tier names for benchmarking |

## Database Schema

The `predictive_health_scores` table stores calculated scores:

```sql
CREATE TABLE IF NOT EXISTS predictive_health_scores (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  client_id TEXT NOT NULL UNIQUE,
  client_name TEXT NOT NULL,
  client_uuid TEXT,
  tier TEXT,

  -- Core predictive metrics
  churn_risk INTEGER NOT NULL,
  churn_risk_level TEXT NOT NULL,
  expansion_probability INTEGER NOT NULL,
  expansion_level TEXT NOT NULL,
  engagement_velocity INTEGER NOT NULL,

  -- Health trajectory
  current_health_score INTEGER NOT NULL,
  predicted_health_30_days INTEGER NOT NULL,
  predicted_health_90_days INTEGER NOT NULL,
  health_trend TEXT NOT NULL,
  health_confidence TEXT NOT NULL,

  -- Peer benchmarking
  peer_benchmark JSONB,

  -- Risk and expansion factors
  churn_risk_factors JSONB NOT NULL DEFAULT '[]',
  expansion_factors JSONB NOT NULL DEFAULT '[]',

  -- Metadata
  model_version TEXT NOT NULL,
  calculated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_predictive_health_client_name
  ON predictive_health_scores(client_name);
CREATE INDEX IF NOT EXISTS idx_predictive_health_churn_risk
  ON predictive_health_scores(churn_risk DESC);
CREATE INDEX IF NOT EXISTS idx_predictive_health_calculated_at
  ON predictive_health_scores(calculated_at);
```

## Usage Examples

### TypeScript (Server-Side)

```typescript
import {
  calculateChurnRisk,
  calculateExpansionProbability,
  predictHealthTrajectory,
  generatePredictiveScores,
} from '@/lib/predictive-health'

// Single metric
const churn = await calculateChurnRisk('client-uuid-here')
console.log(`Churn Risk: ${churn.riskScore}% (${churn.riskLevel})`)

// Full predictive analysis
const scores = await generatePredictiveScores('client-uuid-here')
console.log(`Predicted Health (30d): ${scores.predictedHealth30Days}`)
console.log(`Expansion Probability: ${scores.expansionProbability}%`)
```

### API Endpoint Example

```typescript
// /api/clients/[clientId]/predictive-scores/route.ts
import { NextResponse } from 'next/server'
import { generatePredictiveScores } from '@/lib/predictive-health'

export async function GET(
  request: Request,
  { params }: { params: { clientId: string } }
) {
  const scores = await generatePredictiveScores(params.clientId)

  if (!scores) {
    return NextResponse.json({ error: 'Client not found' }, { status: 404 })
  }

  return NextResponse.json(scores)
}
```

## Scheduled Execution

For production use, the batch job should be scheduled to run regularly:

### Recommended Schedule
- **Daily**: Run at 6:00 AM AEST before business hours
- **On-Demand**: Trigger after significant data imports

### Cron Configuration (Example)

```bash
# Run daily at 6 AM AEST (8 PM UTC previous day)
0 20 * * * cd /path/to/apac-intelligence-v2 && node scripts/generate-predictive-scores.mjs >> /var/log/predictive-scores.log 2>&1
```

### Vercel/Netlify Scheduled Function

The batch job can also be triggered via a scheduled serverless function or webhook.

## Troubleshooting

### Common Issues

1. **"Client not found" errors**
   - Ensure client exists in `client_segmentation` with `effective_to` = null
   - Verify client_id format matches expectations

2. **Low confidence predictions**
   - Client may have insufficient historical data (< 4 health snapshots)
   - Consider extending health history collection period

3. **Unexpected churn risk scores**
   - Check individual factor contributions via `identifyRiskFactors()`
   - Verify data quality in source tables

4. **Peer benchmark returns null**
   - Client may not have a tier assigned
   - Tier may have fewer than 2 clients

### Debugging

Run with verbose mode to see detailed processing:

```bash
node scripts/generate-predictive-scores.mjs --verbose --client "Problem Client"
```

## Future Enhancements

1. **Additional Data Sources**
   - Support ticket volume and resolution times
   - Revenue trend data from BURC
   - Contract renewal proximity

2. **Model Improvements**
   - Seasonal adjustment for compliance patterns
   - Weighted recency for more recent data
   - Cross-validation for model accuracy assessment

3. **Alerting Integration**
   - Teams notifications for high-risk clients
   - Dashboard widgets showing prediction changes
   - Email summaries for CSE managers

## Related Documentation

- [Churn Prediction System Guide](./CHURN-PREDICTION-SYSTEM-GUIDE.md)
- [Health Score Configuration](../src/lib/health-score-config.ts)
- [Database Schema](../docs/database-schema.md)

---

**Maintainer**: APAC Intelligence Team
**Last Updated**: 2026-01-09
