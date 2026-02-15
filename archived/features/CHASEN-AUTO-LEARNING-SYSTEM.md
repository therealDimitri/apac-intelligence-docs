# ChaSen Auto-Learning & Continuous Refresh System

**Version:** 1.0
**Date:** 2025-12-03
**Status:** Production Ready

---

## Overview

The ChaSen Auto-Learning System provides **continuously refreshed, AI-powered recommendations** that **automatically improve over time** by learning from successful interventions.

### Key Features

1. **Automatic Cache & Refresh** (1-hour TTL, 30-min refresh interval)
2. **Continuous Learning** from CSE actions and client outcomes
3. **Success Pattern Database** feeding insights back into recommendations
4. **Real-Time Tracking** of all interactions and outcomes
5. **Daily Metric Snapshots** for before/after analysis
6. **Background Jobs** for automated outcome measurement

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CLIENT BROWSER                              │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  RightColumn.tsx (Client Page)                             │    │
│  │  ┌──────────────────────────────────────────────────┐     │    │
│  │  │  useChaSenRecommendations()                      │     │    │
│  │  │  • Auto-fetch every 30 minutes                   │     │    │
│  │  │  • Track views, clicks, completions              │     │    │
│  │  │  • Cache with React Query                        │     │    │
│  │  └──────────────────────────────────────────────────┘     │    │
│  └────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
                              ↓ ↑
                     API Requests / Responses
                              ↓ ↑
┌─────────────────────────────────────────────────────────────────────┐
│                         API ENDPOINTS                               │
│  ┌──────────────────────────────┐  ┌─────────────────────────────┐ │
│  │ /api/chasen/recommend-actions│  │ /api/chasen/track-interaction│ │
│  │  1. Check cache             │  │  1. Log interaction         │ │
│  │  2. Gather client context   │  │  2. Update patterns if       │ │
│  │  3. Gather portfolio context│  │     completed                │ │
│  │  4. Fetch success patterns  │  └─────────────────────────────┘ │
│  │  5. Call Claude API         │                                  │
│  │  6. Cache results (1hr TTL) │                                  │
│  │  7. Log generation event    │                                  │
│  └──────────────────────────────┘                                  │
└─────────────────────────────────────────────────────────────────────┘
                              ↓ ↑
                         Database Queries
                              ↓ ↑
┌─────────────────────────────────────────────────────────────────────┐
│                         SUPABASE DATABASE                           │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │  TABLES                                                     │   │
│  │  • chasen_recommendations (cache, TTL)                     │   │
│  │  • chasen_recommendation_interactions (tracking)           │   │
│  │  • chasen_success_patterns (learning database)             │   │
│  │  • chasen_generation_log (audit trail)                     │   │
│  │  • client_metric_snapshots (daily snapshots)               │   │
│  └────────────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │  FUNCTIONS                                                  │   │
│  │  • get_active_recommendations(client_name)                 │   │
│  │  • get_relevant_success_patterns(segment, health, nps)     │   │
│  └────────────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │  MATERIALIZED VIEW                                          │   │
│  │  • chasen_recommendation_effectiveness                     │   │
│  └────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                              ↓ ↑
                       Daily Background Job
                              ↓ ↑
┌─────────────────────────────────────────────────────────────────────┐
│                    BACKGROUND LEARNING JOB                          │
│             (scripts/chasen-learning-job.mjs)                       │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │  1. Take daily client metric snapshots                     │   │
│  │  2. Measure outcomes for completed recommendations         │   │
│  │     (30/60/90 days after completion)                       │   │
│  │  3. Calculate success scores and improvements              │   │
│  │  4. Update success patterns with results                   │   │
│  │  5. Refresh materialized view                              │   │
│  └────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Cron Schedule: 0 2 * * * (Daily at 2 AM)                          │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow

### 1. **Recommendation Generation** (First Request or Cache Miss)

```
User opens client page
    ↓
useChaSenRecommendations() hook triggers
    ↓
POST /api/chasen/recommend-actions
    ↓
Check cache: SELECT * FROM chasen_recommendations WHERE expires_at > NOW()
    ↓
[CACHE MISS]
    ↓
Gather Client Context:
  • Health score, NPS, compliance, engagement, financial metrics
  • Recent NPS themes, upcoming events, overdue actions
  • Compliance predictions, portfolio initiatives
    ↓
Gather Portfolio Context:
  • Segment averages (health, NPS, engagement frequency)
  • Success patterns: SELECT * FROM get_relevant_success_patterns(segment, health, nps)
    ↓
Build ChaSen Prompt:
  • Client context JSON
  • Portfolio context JSON
  • Success stories from similar clients
  • Instructions for generating 5 prioritized recommendations
    ↓
Call Claude API (Sonnet 4.5):
  • Model: claude-sonnet-4-20250514
  • Max tokens: 4096
  • Expected output: JSON array of recommendations
    ↓
Post-process recommendations:
  • Validate JSON structure
  • Normalize impact/confidence scores (0-1)
  • Add TTL (1 hour)
  • Generate unique IDs
    ↓
Cache recommendations:
  • INSERT INTO chasen_recommendations
  • Set expires_at = NOW() + 1 hour
    ↓
Log generation event:
  • INSERT INTO chasen_generation_log
  • Track tokens used, latency, cost
    ↓
Return recommendations to client
    ↓
Hook displays recommendations in UI
```

### 2. **Cached Recommendations** (Subsequent Requests)

```
User opens client page
    ↓
useChaSenRecommendations() hook triggers
    ↓
POST /api/chasen/recommend-actions
    ↓
Check cache: SELECT * FROM chasen_recommendations WHERE expires_at > NOW()
    ↓
[CACHE HIT]
    ↓
Return cached recommendations immediately (no API call)
    ↓
Hook displays recommendations in UI
```

### 3. **Auto-Refresh** (Every 30 Minutes)

```
React Query refetchInterval triggers (30 min)
    ↓
POST /api/chasen/recommend-actions
    ↓
Check cache expiration
    ↓
[EXPIRED or STALE]
    ↓
Generate new recommendations (same flow as #1)
    ↓
Update cache
    ↓
Re-render UI with fresh recommendations
```

### 4. **Interaction Tracking** (User Clicks/Completes Recommendation)

```
User clicks "Schedule Meeting" action button
    ↓
trackClick(recommendationId, 'schedule_meeting') called
    ↓
POST /api/chasen/track-interaction
    ↓
INSERT INTO chasen_recommendation_interactions:
  • recommendation_id
  • client_name
  • cse_email
  • interaction_type: 'clicked'
  • interaction_data: { actionType: 'schedule_meeting' }
    ↓
[If interaction_type === 'completed']
    ↓
Trigger analyzeAndStoreSuccessPattern():
  • Get original recommendation context
  • Capture "before" metrics (health, NPS, compliance)
  • INSERT INTO chasen_success_patterns
  • Set measured_at = NOW() + 30 days (measure outcome later)
    ↓
Return success response
```

### 5. **Continuous Learning** (Daily Background Job)

```
Cron triggers at 2 AM daily
    ↓
scripts/chasen-learning-job.mjs runs
    ↓
─────────────────────────────────────────
STEP 1: Take Daily Client Metric Snapshots
─────────────────────────────────────────
For each client:
  • Fetch current metrics (health, NPS, compliance, engagement, financial)
  • INSERT INTO client_metric_snapshots (upsert on conflict)
    ↓
─────────────────────────────────────────
STEP 2: Measure Recommendation Outcomes
─────────────────────────────────────────
SELECT * FROM chasen_success_patterns
WHERE applied_at <= NOW() - 30 days
AND health_score_after IS NULL
    ↓
For each pending pattern:
  • Get current client metrics (30+ days after action)
  • Calculate improvements:
    - health_improvement = health_after - health_before
    - nps_improvement = nps_after - nps_before
    - compliance_improvement = compliance_after - compliance_before
  • Calculate success_score (0-1):
    - 0.3 weight for health improvement
    - 0.3 weight for NPS improvement
    - 0.2 weight for compliance improvement
    - 0.2 weight for engagement improvement
  • Determine confidence_level (high/medium/low)
  • UPDATE chasen_success_patterns SET health_score_after, success_score, etc.
    ↓
─────────────────────────────────────────
STEP 3: Update Success Rates
─────────────────────────────────────────
Group patterns by (pattern_name, client_segment)
    ↓
For each group:
  • Count successes (success_score >= 0.6)
  • Calculate success_rate = successes / total
  • UPDATE times_applied, success_rate
    ↓
─────────────────────────────────────────
STEP 4: Refresh Materialized View
─────────────────────────────────────────
REFRESH MATERIALIZED VIEW chasen_recommendation_effectiveness
    ↓
Complete!
```

---

## Database Schema

### Core Tables

#### 1. `chasen_recommendations`

Caches AI-generated recommendations with 1-hour TTL.

| Column                | Type         | Description                                                           |
| --------------------- | ------------ | --------------------------------------------------------------------- |
| `id`                  | UUID         | Primary key                                                           |
| `client_name`         | TEXT         | Client this recommendation is for                                     |
| `recommendation_type` | TEXT         | 'engagement', 'satisfaction', 'compliance', 'financial', 'initiative' |
| `severity`            | TEXT         | 'critical', 'warning', 'info'                                         |
| `title`               | TEXT         | Short actionable title                                                |
| `description`         | TEXT         | Detailed explanation with context                                     |
| `reasoning`           | TEXT         | Why ChaSen recommended this                                           |
| `impact_score`        | NUMERIC(3,2) | 0-1 scale (business impact)                                           |
| `confidence_score`    | NUMERIC(3,2) | 0-1 scale (AI confidence)                                             |
| `estimated_effort`    | TEXT         | e.g., "2 hours", "1 day"                                              |
| `expected_outcome`    | TEXT         | Measurable outcome expectation                                        |
| `recommended_actions` | JSONB        | Array of action objects                                               |
| `context_data`        | JSONB        | Client context snapshot                                               |
| `portfolio_insights`  | JSONB        | Portfolio-wide insights used                                          |
| `generated_at`        | TIMESTAMPTZ  | When this was generated                                               |
| `expires_at`          | TIMESTAMPTZ  | Cache expiration (1 hour TTL)                                         |

**Indexes:**

- `idx_chasen_recommendations_client` on `client_name`
- `idx_chasen_recommendations_expires` on `expires_at`
- `idx_chasen_recommendations_active` on `(client_name, expires_at) WHERE expires_at > NOW()`

#### 2. `chasen_recommendation_interactions`

Tracks all CSE interactions for learning.

| Column              | Type        | Description                                                              |
| ------------------- | ----------- | ------------------------------------------------------------------------ |
| `id`                | UUID        | Primary key                                                              |
| `recommendation_id` | UUID        | FK to chasen_recommendations                                             |
| `client_name`       | TEXT        | Client name                                                              |
| `cse_email`         | TEXT        | Who interacted                                                           |
| `interaction_type`  | TEXT        | 'viewed', 'clicked', 'dismissed', 'snoozed', 'completed', 'action_taken' |
| `interaction_data`  | JSONB       | Additional context (action type, dismiss reason, etc.)                   |
| `created_at`        | TIMESTAMPTZ | When interaction occurred                                                |

**Indexes:**

- `idx_recommendation_interactions_cse` on `(cse_email, created_at)`
- `idx_recommendation_interactions_rec` on `(recommendation_id, interaction_type)`

#### 3. `chasen_success_patterns`

Stores successful interventions for continuous learning.

| Column                 | Type         | Description                            |
| ---------------------- | ------------ | -------------------------------------- |
| `id`                   | UUID         | Primary key                            |
| `pattern_name`         | TEXT         | Pattern identifier                     |
| `client_segment`       | TEXT         | 'Enterprise', 'Strategic', 'Core'      |
| `trigger_conditions`   | JSONB        | What triggered this recommendation     |
| `recommendation_title` | TEXT         | The recommendation that was acted upon |
| `actions_taken`        | JSONB        | What the CSE actually did              |
| `health_score_before`  | NUMERIC      | Health score when action was taken     |
| `health_score_after`   | NUMERIC      | Health score 30+ days later            |
| `nps_score_before`     | NUMERIC      | NPS before action                      |
| `nps_score_after`      | NUMERIC      | NPS after action                       |
| `health_improvement`   | NUMERIC      | Calculated improvement                 |
| `nps_improvement`      | NUMERIC      | Calculated improvement                 |
| `success_score`        | NUMERIC(3,2) | Overall success rating (0-1)           |
| `confidence_level`     | TEXT         | 'high', 'medium', 'low'                |
| `times_applied`        | INTEGER      | How many times this pattern used       |
| `success_rate`         | NUMERIC(3,2) | % of times pattern led to improvement  |
| `applied_at`           | TIMESTAMPTZ  | When CSE took action                   |
| `measured_at`          | TIMESTAMPTZ  | When outcome was measured              |

**Indexes:**

- `idx_success_patterns_segment` on `(client_segment, success_score DESC)`
- `idx_success_patterns_conditions` (GIN) on `trigger_conditions`
- `idx_success_patterns_success` on `(success_score DESC, times_applied DESC)`

#### 4. `chasen_generation_log`

Audit trail for all AI recommendation generations.

| Column                      | Type          | Description                               |
| --------------------------- | ------------- | ----------------------------------------- |
| `id`                        | UUID          | Primary key                               |
| `client_name`               | TEXT          | Client recommendations were generated for |
| `generation_type`           | TEXT          | 'scheduled', 'manual', 'triggered'        |
| `trigger_reason`            | TEXT          | Why generation happened                   |
| `context_snapshot`          | JSONB         | Full context used                         |
| `recommendations_generated` | INTEGER       | How many recommendations                  |
| `api_latency_ms`            | INTEGER       | Claude API response time                  |
| `tokens_used`               | INTEGER       | Claude API token usage                    |
| `cost_usd`                  | NUMERIC(10,4) | Estimated cost                            |
| `success`                   | BOOLEAN       | Did generation succeed?                   |
| `error_message`             | TEXT          | Error if failed                           |
| `created_at`                | TIMESTAMPTZ   | When this happened                        |

**Indexes:**

- `idx_generation_log_cost` on `(created_at, cost_usd)`
- `idx_generation_log_latency` on `api_latency_ms DESC`

#### 5. `client_metric_snapshots`

Daily snapshots of client metrics for before/after analysis.

| Column                    | Type    | Description                   |
| ------------------------- | ------- | ----------------------------- |
| `id`                      | UUID    | Primary key                   |
| `client_name`             | TEXT    | Client                        |
| `snapshot_date`           | DATE    | Date of snapshot              |
| `health_score`            | NUMERIC | Health score on this date     |
| `nps_score`               | NUMERIC | NPS score on this date        |
| `compliance_score`        | NUMERIC | Compliance score on this date |
| `days_since_last_meeting` | INTEGER | Engagement metric             |
| `open_actions`            | INTEGER | Action count                  |
| `overdue_actions`         | INTEGER | Overdue action count          |
| ... (other metrics)       | ...     | ...                           |

**Unique Constraint:** `(client_name, snapshot_date)`

**Indexes:**

- `idx_metric_snapshots_client_date` on `(client_name, snapshot_date DESC)`

---

## API Endpoints

### 1. `POST /api/chasen/recommend-actions`

Generate AI-powered recommendations for a client.

**Request:**

```json
{
  "clientName": "Albury Wodonga Health",
  "includePortfolioContext": true,
  "limit": 5,
  "refreshCache": false
}
```

**Response (Cache Hit):**

```json
{
  "recommendations": [
    {
      "id": "rec_1733123456789_0",
      "severity": "critical",
      "category": "satisfaction",
      "title": "Schedule urgent feedback session",
      "description": "NPS dropped 45 points in Q4. Analysis shows 3 detractors citing lack of communication. Schedule 1:1s with key stakeholders.",
      "reasoning": "ChaSen analyzed 12 NPS responses and identified communication as primary concern. Similar pattern in 2 other healthcare clients.",
      "impactScore": 0.89,
      "confidenceScore": 0.92,
      "estimatedEffort": "2 hours",
      "expectedOutcome": "Improve NPS by 15-20 points within 30 days",
      "actions": [
        {
          "type": "schedule_meeting",
          "label": "Schedule feedback session",
          "deepLink": "/meetings/calendar?action=schedule&client=Albury+Wodonga+Health"
        }
      ],
      "generatedAt": "2025-12-03T10:30:00Z",
      "expiresAt": "2025-12-03T11:30:00Z"
    }
  ],
  "metadata": {
    "cacheHit": true,
    "generatedAt": "2025-12-03T10:30:00Z",
    "expiresAt": "2025-12-03T11:30:00Z"
  }
}
```

**Response (Cache Miss - Fresh Generation):**

```json
{
  "recommendations": [
    /* same as above */
  ],
  "metadata": {
    "clientContext": {
      "segment": "Enterprise",
      "healthScore": 67,
      "npsScore": -8,
      "revenueAtRisk": 450000,
      "daysToRenewal": 127
    },
    "portfolioInsights": {
      "successfulInterventions": 3
    },
    "generationTime": "1.2s",
    "tokensUsed": 2500,
    "cacheHit": false
  }
}
```

### 2. `POST /api/chasen/track-interaction`

Track CSE interaction with a recommendation.

**Request:**

```json
{
  "recommendationId": "rec_1733123456789_0",
  "clientName": "Albury Wodonga Health",
  "cseEmail": "cse@example.com",
  "interactionType": "clicked",
  "interactionData": {
    "actionType": "schedule_meeting"
  }
}
```

**Response:**

```json
{
  "success": true,
  "interactionId": "uuid-12345",
  "message": "Interaction tracked successfully"
}
```

---

## React Hook Usage

### `useChaSenRecommendations(clientName, options)`

**Basic Usage:**

```typescript
import { useChaSenRecommendations } from '@/hooks/useChaSenRecommendations'

function ClientPage({ client }) {
  const {
    recommendations,
    loading,
    error,
    refresh,
    trackClick,
    trackComplete,
    trackDismiss
  } = useChaSenRecommendations(client.name, {
    includePortfolioContext: true,
    limit: 5,
    refreshInterval: 30 * 60 * 1000, // 30 minutes
    autoRefresh: true,
    cseEmail: user.email
  })

  if (loading) return <Skeleton />
  if (error) return <Error message={error.message} />

  return (
    <div>
      {recommendations.map(rec => (
        <RecommendationCard
          key={rec.id}
          recommendation={rec}
          onActionClick={(actionType) => {
            trackClick(rec.id, actionType)
            // Navigate to action page
          }}
          onComplete={(outcome) => {
            trackComplete(rec.id, outcome)
          }}
          onDismiss={(reason) => {
            trackDismiss(rec.id, reason)
          }}
        />
      ))}
    </div>
  )
}
```

**Options:**

| Option                    | Type    | Default   | Description                     |
| ------------------------- | ------- | --------- | ------------------------------- |
| `includePortfolioContext` | boolean | `true`    | Include portfolio-wide insights |
| `limit`                   | number  | `5`       | Max number of recommendations   |
| `refreshInterval`         | number  | `1800000` | Auto-refresh interval (30 min)  |
| `autoRefresh`             | boolean | `true`    | Enable automatic refresh        |
| `cseEmail`                | string  | required  | CSE email for tracking          |

**Returns:**

| Property           | Type                     | Description                               |
| ------------------ | ------------------------ | ----------------------------------------- |
| `recommendations`  | `ChaSenRecommendation[]` | Array of recommendations                  |
| `metadata`         | object                   | Cache info, generation time, etc.         |
| `loading`          | boolean                  | Is fetching recommendations?              |
| `error`            | Error \| null            | Error if fetch failed                     |
| `refresh`          | function                 | Manually trigger refresh (bypasses cache) |
| `trackInteraction` | function                 | Low-level tracking function               |
| `trackClick`       | function                 | Track click on action button              |
| `trackComplete`    | function                 | Track completion of recommendation        |
| `trackDismiss`     | function                 | Track dismissal of recommendation         |
| `trackSnooze`      | function                 | Track snoozing recommendation             |

---

## Continuous Learning Loop

### How ChaSen Learns

1. **Initial Recommendations** (Day 1)
   - ChaSen generates recommendations based on client context
   - No success patterns exist yet (cold start)
   - Recommendations are generic but contextual

2. **CSE Takes Action** (Day 2)
   - CSE sees "Schedule urgent feedback session" recommendation
   - CSE clicks action → `trackClick()` logs interaction
   - CSE completes action → `trackComplete()` creates success pattern:
     - Captures "before" metrics (health: 52, NPS: -42)
     - Stores actions taken (scheduled meeting with CIO, Nurse Manager)
     - Sets `measured_at` = 30 days from now

3. **Daily Background Job** (Every Day)
   - Takes snapshots of all client metrics
   - Stores in `client_metric_snapshots` table

4. **Outcome Measurement** (Day 32)
   - Background job finds success patterns where `applied_at <= 30 days ago`
   - Fetches current client metrics:
     - Health score: 68 (+16 improvement!)
     - NPS score: -8 (+34 improvement!)
   - Calculates success_score: 0.85 (high success!)
   - Updates pattern with results

5. **Success Rate Calculation** (Day 32)
   - Background job groups patterns by (pattern_name, segment)
   - Example: "urgent_feedback_session" for "Enterprise" clients
   - Counts: 3 applications, 2 successes (success_rate = 0.67)
   - Updates all patterns in group

6. **Next Recommendation** (Day 33)
   - ChaSen generates recommendations for another client with similar issues
   - Queries: `get_relevant_success_patterns('Enterprise', 52, -42)`
   - Finds the successful pattern from Day 2-32!
   - Includes in prompt:
     ```
     SUCCESS STORIES FROM SIMILAR CLIENTS:
     1. Schedule urgent feedback session
        - Actions Taken: [{"action": "scheduled_feedback_session", "attendees": [...]}]
        - Results: Health improved by 16 points in 3 cases
        - Success Rate: 67%
     ```
   - ChaSen now recommends this action with higher confidence
   - Provides specific context: "Similar to Royal Melbourne Hospital case, which improved NPS by 34 points"

7. **Continuous Improvement** (Ongoing)
   - More patterns accumulate
   - Success rates become more accurate
   - ChaSen learns which actions work for which client types
   - Recommendations become increasingly personalized and effective

### Success Score Calculation

```typescript
const successScore = Math.max(
  0,
  Math.min(
    1,
    // Base score (up to 1.0):
    (healthImprovement > 0 ? 0.3 : 0) + // 30% weight for any health improvement
      (npsImprovement > 0 ? 0.3 : 0) + // 30% weight for any NPS improvement
      (complianceImprovement > 0 ? 0.2 : 0) + // 20% weight for compliance improvement
      (engagementImprovement > 0 ? 0.2 : 0) + // 20% weight for engagement improvement
      // Bonus for magnitude of health improvement:
      (healthImprovement / 100) * 0.3 // Up to +0.3 for big health improvements
  )
)
```

**Examples:**

- Health +20, NPS +30, Compliance +10, Engagement +5 → **0.9-1.0** (highly successful)
- Health +10, NPS +5, Compliance 0, Engagement -2 → **0.6-0.7** (moderately successful)
- Health -5, NPS -10, Compliance -5, Engagement 0 → **0.0-0.2** (unsuccessful)

---

## Deployment

### 1. Database Migration

```bash
node scripts/run-migration.mjs docs/migrations/20251203_chasen_recommendations_and_learning.sql
```

### 2. Verify Tables Created

```bash
node scripts/introspect-database-schema.mjs
```

Verify these tables exist:

- `chasen_recommendations`
- `chasen_recommendation_interactions`
- `chasen_success_patterns`
- `chasen_generation_log`
- `client_metric_snapshots`

### 3. Set Up Cron Job

Add to your cron scheduler (e.g., Vercel Cron, AWS EventBridge, GitHub Actions):

```yaml
# .github/workflows/chasen-learning.yml
name: ChaSen Learning Job
on:
  schedule:
    - cron: '0 2 * * *' # Daily at 2 AM UTC
jobs:
  run-learning-job:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '20'
      - run: npm ci
      - run: node scripts/chasen-learning-job.mjs
        env:
          NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_SERVICE_ROLE_KEY: ${{ secrets.SUPABASE_SERVICE_ROLE_KEY }}
```

**Or use Vercel Cron (vercel.json):**

```json
{
  "crons": [
    {
      "path": "/api/cron/chasen-learning",
      "schedule": "0 2 * * *"
    }
  ]
}
```

### 4. Create Cron API Route (If Using Vercel)

```typescript
// src/app/api/cron/chasen-learning/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { main as runLearningJob } from '../../../../scripts/chasen-learning-job.mjs'

export async function GET(request: NextRequest) {
  // Verify cron secret
  const authHeader = request.headers.get('authorization')
  if (authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  try {
    await runLearningJob()
    return NextResponse.json({ success: true })
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}
```

### 5. Environment Variables

Ensure these are set:

```env
# .env.local
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
ANTHROPIC_API_KEY=sk-ant-...
CRON_SECRET=your-cron-secret  # For Vercel Cron
```

---

## Monitoring & Analytics

### 1. Track API Costs

```sql
-- Daily Claude API costs
SELECT
  DATE(created_at) as date,
  SUM(cost_usd) as total_cost,
  AVG(api_latency_ms) as avg_latency_ms,
  SUM(tokens_used) as total_tokens,
  COUNT(*) as generations
FROM chasen_generation_log
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

### 2. Recommendation Effectiveness

```sql
-- View recommendation completion rates
SELECT
  recommendation_type,
  severity,
  total_recommendations,
  completed_count,
  completion_rate,
  avg_impact_score,
  avg_days_to_action
FROM chasen_recommendation_effectiveness
ORDER BY completion_rate DESC;
```

### 3. Top Success Patterns

```sql
-- Best performing patterns
SELECT
  pattern_name,
  client_segment,
  recommendation_title,
  times_applied,
  success_rate,
  AVG((health_improvement + nps_improvement + compliance_improvement) / 3) as avg_total_improvement
FROM chasen_success_patterns
WHERE success_score >= 0.6
GROUP BY pattern_name, client_segment, recommendation_title, times_applied, success_rate
ORDER BY success_rate DESC, times_applied DESC
LIMIT 10;
```

### 4. CSE Effectiveness

```sql
-- Which CSEs are most effective at completing recommendations?
SELECT
  cse_email,
  COUNT(DISTINCT CASE WHEN interaction_type = 'completed' THEN recommendation_id END) as completed,
  COUNT(DISTINCT CASE WHEN interaction_type = 'dismissed' THEN recommendation_id END) as dismissed,
  COUNT(DISTINCT recommendation_id) as total_interactions,
  ROUND(
    COUNT(DISTINCT CASE WHEN interaction_type = 'completed' THEN recommendation_id END)::NUMERIC /
    NULLIF(COUNT(DISTINCT recommendation_id), 0) * 100,
    2
  ) as completion_rate
FROM chasen_recommendation_interactions
WHERE created_at >= NOW() - INTERVAL '90 days'
GROUP BY cse_email
ORDER BY completion_rate DESC;
```

---

## Troubleshooting

### Issue: Recommendations Not Refreshing

**Check:**

1. Cache expiration: `SELECT expires_at FROM chasen_recommendations WHERE client_name = 'X'`
2. React Query refetch interval in `useChaSenRecommendations` hook
3. Browser console for errors

**Fix:**

```typescript
// Force refresh
const { refresh } = useChaSenRecommendations(client.name)
await refresh() // Bypasses cache
```

### Issue: High API Costs

**Check:**

```sql
SELECT SUM(cost_usd) FROM chasen_generation_log WHERE created_at >= NOW() - INTERVAL '7 days'
```

**Fix:**

- Increase cache TTL from 1 hour to 2-4 hours
- Reduce refresh interval from 30 min to 60 min
- Implement rate limiting per client

### Issue: Success Patterns Not Appearing

**Check:**

1. Are CSEs completing recommendations? `SELECT COUNT(*) FROM chasen_recommendation_interactions WHERE interaction_type = 'completed'`
2. Has background job run? Check logs
3. Are patterns being created? `SELECT COUNT(*) FROM chasen_success_patterns`

**Fix:**

```bash
# Manually run learning job
node scripts/chasen-learning-job.mjs
```

### Issue: Background Job Failing

**Check logs:**

```bash
# If using GitHub Actions
gh run list --workflow=chasen-learning

# If using Vercel Cron
vercel logs --since 24h | grep chasen-learning
```

**Common fixes:**

- Verify environment variables are set
- Check Supabase service role permissions
- Ensure database functions exist

---

## Performance Benchmarks

**Target Metrics:**

- API Response Time (cached): < 200ms
- API Response Time (fresh generation): < 3s
- Cache Hit Rate: > 70%
- Recommendation Accuracy: > 80% (CSE rates as "relevant")
- Action Completion Rate: > 60%
- Success Pattern Accumulation: 10+ patterns per segment within 90 days

**Current Actual (to be measured):**

- TBD after production deployment

---

## Future Enhancements

### Phase 2: Portfolio-Wide Insights

- Identify trends across multiple clients
- "3 healthcare clients trending down - common issue: product roadmap uncertainty"
- Recommend portfolio-wide actions (webinars, documentation updates)

### Phase 3: Proactive Alerts

- ChaSen predicts churn risk based on patterns
- Sends Slack/email alerts: "68% churn risk for Client X - escalate now"
- Auto-escalation workflows

### Phase 4: Natural Language Interface

- CSE asks: "What should I focus on this week?"
- ChaSen responds with prioritized list across entire portfolio
- Conversational UI for recommendations

### Phase 5: Advanced ML

- Train custom model on success patterns
- Predict optimal timing for interventions
- Personalized recommendations per CSE style

---

## Conclusion

The ChaSen Auto-Learning System provides:

✅ **Automatic refresh** - Recommendations stay current without manual intervention
✅ **Continuous learning** - System improves over time from real outcomes
✅ **Scalable architecture** - Handles hundreds of clients efficiently
✅ **Cost-effective** - Aggressive caching minimizes API costs
✅ **Production-ready** - Comprehensive error handling, logging, monitoring

**Next Steps:**

1. Deploy to production
2. Monitor for 30 days to accumulate initial success patterns
3. A/B test AI vs. rule-based recommendations
4. Gather CSE feedback and iterate

---

**Version History:**

- v1.0 (2025-12-03): Initial implementation with full learning loop

**Maintained By:** Claude Code
**Last Updated:** 2025-12-03
