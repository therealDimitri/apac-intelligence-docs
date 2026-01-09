# Feature: Next Best Action (NBA) Engine

**Date**: 9 January 2026
**Status**: Implemented
**Phase**: Account Planning Hub Enhancement

---

## Summary

The Next Best Action (NBA) Engine is an intelligent recommendation system that analyses client data to surface prioritised, actionable recommendations for Customer Success Executives. It uses a weighted scoring algorithm combining Impact, Urgency, and Confidence to help CSEs focus on the highest-value activities.

## Components Created

### 1. Core Engine Library
**File**: `/src/lib/next-best-action.ts`

The engine provides:
- Action generation based on 8 trigger categories
- Priority scoring algorithm (Impact x Urgency x Confidence)
- Database persistence and retrieval functions
- Client context aggregation from multiple tables
- Batch processing for portfolio-wide generation

### 2. UI Panel Component
**File**: `/src/components/planning/NextBestActionsPanel.tsx`

The panel provides:
- Prioritised action list with expand/collapse details
- Accept, Complete, and Dismiss action workflows
- Category and urgency filtering
- Compact mode for sidebar integration
- Real-time status updates

---

## Action Categories and Triggers

| Category | Trigger Condition | Recommended Action |
|----------|-------------------|-------------------|
| `engagement` | Meeting gap > 30 days | Schedule check-in |
| `nps_followup` | Detractor score (<=6) | Address feedback from {contact} |
| `risk_mitigation` | Health decline > 10 pts | Escalate to leadership |
| `relationship` | Missing MEDDPICC role | Identify Economic Buyer |
| `financial` | Aging > 60 days | Coordinate with finance |
| `expansion` | High health + engagement | Propose growth discussion |
| `compliance` | Missing required events | Schedule {event_type} |
| `action_completion` | Overdue items | Complete overdue actions |

---

## Priority Scoring Algorithm

The priority score is calculated using:

```
Priority = (Impact × 0.40) + (Urgency × 0.35) + (Confidence × 0.25)
```

Each component is scored 0-100:
- **Impact**: Business value if action is completed
- **Urgency**: Time sensitivity of the action
- **Confidence**: Data quality supporting the recommendation

### Urgency Levels

| Score Range | Level | Display |
|-------------|-------|---------|
| >= 80 | Immediate | Red badge |
| 50-79 | This Week | Amber badge |
| < 50 | This Month | Blue badge |

---

## Core Functions

### Action Generation

```typescript
// Generate actions for a single client
const actions = generateActionsForClient(clientContext, config)

// Prioritise actions by score
const sortedActions = prioritiseActions(actions)

// Generate for entire portfolio
const result = await generateActionsForPortfolio('Jimmy Leimonitis', config, {
  persistActions: true,
  onProgress: (current, total, client) => console.log(`${current}/${total}: ${client}`)
})
```

### Action Lifecycle

```typescript
// Accept an action (CSE commits to it)
await acceptAction(actionId)

// Complete an action (work done)
await completeAction(actionId)

// Dismiss with reason (not applicable)
await dismissAction(actionId, 'Already addressed in previous meeting')
```

### Fetching Actions

```typescript
// Get actions for a CSE
const { actions } = await getActionsForCSE('Jimmy Leimonitis', {
  status: ['pending', 'accepted'],
  limit: 50,
  includeExpired: false
})

// Get actions for a specific client
const { actions } = await getActionsForClient('Royal Brisbane Hospital', {
  status: ['pending'],
  limit: 20
})
```

---

## Configuration Options

```typescript
interface NBAConfig {
  // Engagement triggers
  meetingGapDays: number           // Default: 30
  criticalMeetingGapDays: number   // Default: 45

  // NPS triggers
  detractorThreshold: number       // Default: 6
  passiveThreshold: number         // Default: 8

  // Health triggers
  healthDeclineThreshold: number   // Default: 10 points
  criticalHealthThreshold: number  // Default: 50

  // Financial triggers
  agingDaysThreshold: number       // Default: 60
  criticalAgingDaysThreshold: number // Default: 90

  // Action triggers
  overdueActionDaysThreshold: number // Default: 7
  criticalOverdueActionDays: number  // Default: 14

  // Expansion triggers
  healthScoreForExpansion: number    // Default: 75
  engagementScoreForExpansion: number // Default: 80

  // Priority weights
  impactWeight: number             // Default: 0.40
  urgencyWeight: number            // Default: 0.35
  confidenceWeight: number         // Default: 0.25
}
```

---

## UI Component Usage

### Full Panel

```tsx
<NextBestActionsPanel
  cseName="Jimmy Leimonitis"
  limit={20}
  showFilters={true}
  showRefresh={true}
  onActionAccepted={(action) => toast.success('Action accepted')}
  onActionCompleted={(action) => toast.success('Action completed')}
/>
```

### Compact Sidebar Mode

```tsx
<NextBestActionsPanel
  cseName="Jimmy Leimonitis"
  compact={true}
  limit={5}
/>
```

### Client-Specific View

```tsx
<NextBestActionsPanel
  clientName="Royal Brisbane Hospital"
  showFilters={false}
/>
```

---

## Database Schema

The `next_best_actions` table stores all recommendations:

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `client_id` | UUID | Foreign key to client |
| `client_name` | TEXT | Client display name |
| `cse_name` | TEXT | Assigned CSE |
| `cam_name` | TEXT | Optional CAM |
| `action_type` | TEXT | Category enum |
| `title` | TEXT | Action title |
| `description` | TEXT | Detailed description |
| `priority_score` | DECIMAL | Calculated score |
| `impact_category` | TEXT | health/revenue/relationship/meddpicc/compliance |
| `estimated_impact` | INTEGER | Points improvement |
| `urgency_level` | TEXT | immediate/this_week/this_month |
| `trigger_reason` | TEXT | Why recommended |
| `trigger_data` | JSONB | Supporting data |
| `status` | TEXT | pending/accepted/completed/dismissed |
| `accepted_at` | TIMESTAMPTZ | When accepted |
| `completed_at` | TIMESTAMPTZ | When completed |
| `dismissed_at` | TIMESTAMPTZ | When dismissed |
| `dismissed_reason` | TEXT | Why dismissed |
| `expires_at` | TIMESTAMPTZ | Optional expiry |
| `created_at` | TIMESTAMPTZ | Creation time |
| `updated_at` | TIMESTAMPTZ | Last update |

---

## Data Sources

The engine aggregates data from multiple tables:

| Data Point | Source Table | Column(s) |
|------------|--------------|-----------|
| Client info | `client_segmentation` | `client_name`, `cse_name`, `tier_id` |
| Health scores | `client_health_history` | `health_score`, `snapshot_date` |
| NPS data | `nps_responses` | `score`, `feedback`, `contact_name` |
| Last meeting | `unified_meetings` | `meeting_date` |
| Overdue actions | `actions` | `Status`, `Due_Date` |
| Aging data | `aging_accounts` | `days_*` columns |

---

## Feedback Loop

The dismissal workflow captures reasons for unused recommendations, enabling:
- Pattern analysis to improve future suggestions
- Threshold tuning based on dismiss patterns
- Category refinement based on acceptance rates

---

## Integration Points

1. **Planning Hub**: Full panel on territory/account planning pages
2. **Client Profile**: Compact widget showing client-specific actions
3. **Dashboard**: Summary widget with urgent action count
4. **ChaSen AI**: NBA data available for conversational queries

---

## Future Enhancements

1. **Machine Learning**: Train on completed/dismissed patterns
2. **Proactive Notifications**: Push alerts for critical actions
3. **Calendar Integration**: Auto-suggest meeting times
4. **Team Collaboration**: Multi-CSE action handoff

---

## Files Created

| Path | Description |
|------|-------------|
| `/src/lib/next-best-action.ts` | Core NBA engine library |
| `/src/components/planning/NextBestActionsPanel.tsx` | UI panel component |
| `/docs/features/FEATURE-20260109-next-best-action-engine.md` | This documentation |

---

## Testing

To test the NBA engine:

1. Navigate to any planning page
2. Verify actions are fetched from `next_best_actions` table
3. Test Accept, Complete, and Dismiss workflows
4. Verify status updates persist to database
5. Test filtering by category and urgency
