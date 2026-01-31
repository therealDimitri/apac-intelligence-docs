# Feature: ChaSen Operating Rhythm Integration

**Date:** 2026-01-31
**Status:** Completed
**Component:** ChaSen AI / Operating Rhythm

## Summary

Connected the CS Operating Rhythm data to ChaSen AI, enabling natural language queries about scheduled events, NPS surveys, account planning activities, and segment touchpoint workloads.

## What ChaSen Can Now Answer

### Event Schedule Queries
- "What's the next operating rhythm event?"
- "What events are scheduled for Q2?"
- "When is the next NPS survey?"
- "What's happening in March?"

### Workload & Activities Queries
- "What touchpoints are due this month?"
- "What's my segment activity workload?"
- "How many on-site visits are required for Giant clients?"

### Planning Queries
- "When is APAC Compass?"
- "What account planning events are coming up?"
- "What are the key milestones for 2026?"

## Technical Implementation

### New Files Created

**`src/lib/chasen-operating-rhythm-context.ts`** (390 lines)

Context builder that:
- Reads from hardcoded Operating Rhythm events (`data.ts`)
- Calculates segment activity workloads
- Generates structured context for AI prompts
- Includes query pattern handlers for common questions

Key functions:
- `getOperatingRhythmContext()` - Returns structured context object
- `getOperatingRhythmSystemContext()` - Formats context as markdown for system prompt
- `OPERATING_RHYTHM_QUERY_PATTERNS` - Pattern matchers for direct query handling

### Files Modified

**`src/app/api/chasen/stream/route.ts`**

- Added import for Operating Rhythm context
- Fetch Operating Rhythm context in parallel with dashboard/SharePoint
- Append to dashboard context (lightweight, no DB queries)
- Added internal app links for CS Operating Rhythm and Support Health

### Context Structure

```typescript
interface OperatingRhythmContext {
  upcomingEvents: OperatingRhythmEvent[]      // Next 90 days
  currentQuarterEvents: OperatingRhythmEvent[] // Current quarter
  nextEvent: OperatingRhythmEvent | null      // Immediate next event
  daysUntilNextEvent: number
  milestones: OperatingRhythmEvent[]          // Milestone events only
  monthlyActivities: MonthlyActivitySummary[] // Segment touchpoints
  annualActivityTotals: { activity, total }[] // Annual workload
  clientCounts: Record<SegmentTier, number>   // Portfolio by segment
  insights: string[]                          // Auto-generated insights
}
```

### System Prompt Addition

The Operating Rhythm context is appended to the dashboard context and includes:

1. **Current Status** - Today's date, current quarter, next event
2. **Upcoming Events (60 Days)** - Events with dates and objectives
3. **Quarter Overview** - Events grouped by category (NPS, Planning, Audit, MarCom)
4. **Client Touchpoint Activities** - Monthly workload and frequency requirements
5. **Client Portfolio by Segment** - Distribution across tiers
6. **Key Milestones** - Next 5 major events

## Data Source

Operating Rhythm data is **not stored in the database** - it's defined in TypeScript configuration files:

- **Events:** `src/components/operating-rhythm/data.ts` (34 events for 2026)
- **Segment Activities:** `src/components/operating-rhythm/segment-activities.ts` (4 activity types with frequency by tier)

This is by design - the Operating Rhythm is a static annual schedule that changes infrequently. Database storage would add unnecessary complexity.

## Performance

- Context generation is **lightweight** - no database queries
- Timeout: 2 seconds (typically completes in <10ms)
- Fetched in parallel with dashboard and SharePoint contexts

## Links Added to ChaSen

```
- CS Operating Rhythm: [CS Operating Rhythm](/operating-rhythm)
- Support Health: [Support Health](/support)
```

## Example Interaction

**User:** "What's the next operating rhythm event?"

**ChaSen:**
> The next Operating Rhythm event is "Q1 Account Plan Update" (planning) in 30 days on 2 Mar.
>
> **Objective:** Review Q1 learnings and re-align account plans for Q2. Assess progress against annual targets.
>
> **Participants:** EVP, VPs, AVPs, CSEs, CAMs, Marketing Lead
>
> [View CS Operating Rhythm](/operating-rhythm)

---

## Update: Account Planning AI Insights Integration

**Date:** 2026-01-31 (same day)
**Commit:** `449b826d`

### Summary

Added `account_plan_ai_insights` table to ChaSen's dashboard context, enabling ChaSen to surface AI-generated account planning recommendations when available.

### Technical Implementation

Added query #13 in `getLiveDashboardContext()` (stream route):
- Fetches latest 20 insights ordered by creation date
- Groups insights by client for organised presentation
- Shows priority (🔴 critical, 🟠 high, 🟡 medium, 🟢 low)
- Displays insight type, confidence score, and implementation status
- Links to Account Planning Coach (`/planning`)

### Current State

The `account_plan_ai_insights` table is **currently empty** (0 rows). This table is designed to store AI-generated recommendations from the Account Planning Coach feature, but these insights haven't been generated yet.

ChaSen compensates by using other relevant data sources to provide account planning guidance:
- Client Health scores and trends
- NPS responses and topic sentiment analysis
- Working Capital/Aged Accounts data
- Overdue Actions

### What ChaSen Can Now Answer (when data is populated)

- "What AI insights do you have for account planning?"
- "Which clients have critical priority recommendations?"
- "Show me the account plan insights for Western Health"

### Example Response (with current data)

Even without dedicated AI insights, ChaSen provides useful guidance:
> **Priority Focus Clients:**
> - SA Health: Health score 31%, NPS -60 points
> - Western Health: Health score 66%, NPS -100 points
> - Barwon Health Australia: NPS -75 points
>
> **Recommendations:**
> 1. Schedule Strategic Reviews for Priority Accounts
> 2. Share Product Sentiment with Leadership
> 3. Align on Commercial and Operational Follow-ups

---

## Update: Support Health Integration

**Date:** 2026-01-31 (same day)
**Commit:** `c478d3e8`

### Summary

Added `support_sla_metrics` table to ChaSen's dashboard context, enabling natural language queries about support health, open cases, SLA compliance, and CSAT scores.

### Bug Fix

Initial implementation used incorrect column names that caused silent query failure:

| Incorrect Column | Correct Column |
|------------------|----------------|
| `support_health_score` | Calculated from SLA, CSAT, backlog |
| `open_cases` | `backlog` |
| `sla_compliance_percent` | `resolution_sla_percent` |
| `csat_score` | `satisfaction_score` |
| `aging_30d_plus` | `aging_31_60d + aging_61_90d + aging_90d_plus` |
| `last_updated` | `updated_at` |

### Technical Implementation

Added query #14 in `getLiveDashboardContext()` (stream route):
- Fetches support metrics for up to 15 clients
- Calculates support health score: `(SLA% × 0.4) + (CSAT% × 0.3) + (backlog_factor × 0.3)`
- Identifies at-risk clients (health < 70%)
- Shows portfolio summary: total open, critical, aging 30d+
- Links to Support Health Dashboard (`/support`)

### Health Score Calculation

```typescript
const slaScore = m.resolution_sla_percent || 0
const csatScore = m.satisfaction_score ? (m.satisfaction_score / 5) * 100 : 80
const backlogFactor = openCases > 20 ? 50 : openCases > 10 ? 70 : openCases > 5 ? 85 : 100
const healthScore = Math.round(slaScore * 0.4 + csatScore * 0.3 + backlogFactor * 0.3)
```

### What ChaSen Can Now Answer

- "Which client has the lowest support health score?"
- "How many open support cases are there?"
- "Which clients have critical support cases?"
- "What's the support health overview?"

### Example Response

**User:** "Which client has the lowest support health score?"

**ChaSen:**
> Based on the latest data, the client with the lowest support health score is **Epworth Healthcare** at **57%**.
>
> | Metric | Value |
> |--------|-------|
> | Support Health Score | 57% |
> | CSAT | 4.5/5 |
> | Status | At-Risk Support |
>
> **Recommendations:**
> 1. Engage with the CSE (John Salisbury)
> 2. Review Support History
> 3. Schedule a Check-in

---

## Related

- Operating Rhythm Page: `src/app/(dashboard)/operating-rhythm/page.tsx`
- Orbit View Components: `src/components/operating-rhythm/`
- ChaSen BURC Context (similar pattern): `src/lib/chasen-burc-context.ts`
- Account Planning Coach: `src/app/(dashboard)/planning/page.tsx`
- Account Plan AI Insights Table: `account_plan_ai_insights` (currently empty)
- Support Health Page: `src/app/(dashboard)/support/page.tsx`
- Support SLA Metrics Table: `support_sla_metrics` (11 clients)
