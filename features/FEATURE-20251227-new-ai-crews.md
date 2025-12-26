# Feature: New AI Crews (5 Additions)

**Date:** 27 December 2025
**Type:** Enhancement
**Status:** Active
**Commit:** `9983cf3`

## Overview

Five new AI Crews have been added to ChaSen to provide deeper portfolio insights and actionable recommendations. Each crew is designed for a specific use case and can be triggered via the Command Palette (⌘K) or programmatically via the API.

## New Crews

### 1. Compliance Acceleration Crew

**Purpose:** Audit tier-based event compliance, identify scheduling gaps, and prioritise remediation actions.

**Data Sources:**
- `client_segmentation` - Client tier assignments
- `event_compliance_by_type` - Compliance status per event type
- `tier_requirements` - Tier-specific event requirements
- `unified_meetings` - Upcoming scheduled events

**Output Sections:**
1. Compliance Overview - Portfolio compliance health summary
2. Critical Interventions - Clients requiring immediate scheduling
3. Gap Analysis - Most common missing event types
4. Scheduling Priorities - Events to schedule this week
5. CSE Assignments - Who should action which clients

**Use When:** You need to catch up on compliance or prepare for an audit.

---

### 2. Meeting Intelligence Crew

**Purpose:** Analyse meeting engagement patterns, extract discussion themes, and measure action conversion effectiveness.

**Data Sources:**
- `unified_meetings` - Meeting history with notes and summaries
- `actions` - Actions created and completed
- `comments` - Recent comments/notes
- `client_health_summary` - Health context

**Output Sections:**
1. Engagement Overview - Meeting activity trends
2. Theme Analysis - Top discussion topics
3. Action Effectiveness - Meeting to action conversion rate
4. Engagement Gaps - Clients needing touchpoints
5. Recommendations - Improve meeting effectiveness

**Use When:** You want to understand meeting ROI or improve team productivity.

---

### 3. Executive Briefing Crew

**Purpose:** Generate board-ready summaries with key performance indicators, trends, and strategic recommendations.

**Data Sources:**
- `client_health_summary` - Portfolio health
- `nps_responses` - NPS metrics
- `aging_accounts` - Financial position
- `actions` - Operational metrics
- `unified_meetings` - Activity metrics
- `client_segmentation` - Segment distribution

**Output Sections:**
1. Executive Summary - 3-4 key takeaways
2. Portfolio Health - Overall health with trend indicators
3. Financial Position - AR summary and priorities
4. Risk Dashboard - Top risks requiring attention
5. Strategic Recommendations - Leadership actions

**Use When:** Preparing for leadership meetings or board presentations.

---

### 4. Product Expansion Crew

**Purpose:** Identify upsell, cross-sell, and expansion opportunities based on client health, sentiment, and engagement signals.

**Data Sources:**
- `client_health_summary` - Health scores and status
- `nps_responses` - Promoter identification
- `client_segmentation` - Current tier assignments
- `unified_meetings` - Expansion signal detection in notes
- `portfolio_initiatives` - Current initiatives
- `aging_accounts` - High-value account identification

**Output Sections:**
1. Expansion Opportunity Summary - Key opportunities
2. Top Expansion Candidates - Healthy promoters
3. Upgrade Pipeline - Tier upgrade candidates
4. Engagement Strategy - How to approach each opportunity
5. Quick Wins - Immediate actions for this quarter

**Use When:** Looking for revenue growth opportunities or preparing sales strategies.

---

### 5. Quick Wins Crew

**Purpose:** Identify easy, high-impact actions that can be completed quickly to improve portfolio metrics.

**Data Sources:**
- `client_health_summary` - Clients near upgrade thresholds
- `actions` - Recently overdue actions
- `nps_responses` - Recent detractors
- `unified_meetings` - Stale engagement detection
- `event_compliance_by_type` - One-event-from-compliance
- `aging_accounts` - Small overdue balances

**Output Sections:**
1. Quick Wins Summary - Top 5 actions for today
2. Health Score Boosts - Clients close to upgrade
3. Action Catch-Up - Overdue items to close
4. Engagement Quick Hits - Quick touchpoint opportunities
5. This Week's Momentum - Daily focus areas

**Use When:** Starting your day or week, need immediate wins.

---

## Access Methods

### Command Palette (⌘K)
Open the command palette and search for:
- "Compliance Acceleration"
- "Meeting Intelligence"
- "Executive Briefing" (⌘6)
- "Product Expansion"
- "Quick Wins" (⌘7)

### API Endpoint
```bash
POST /api/chasen/crew
Content-Type: application/json

{
  "crew": "compliance-acceleration" | "meeting-intelligence" | "executive-briefing" | "product-expansion" | "quick-wins"
}
```

### Response Format
All crews return a `RichAIResponse`:
```typescript
{
  content: string           // Markdown-formatted analysis
  title: string             // Crew name
  summary: string           // Brief summary for display
  relatedMeetings?: Array   // Relevant meetings
  relatedActions?: Array    // Relevant actions
  quickActions: Array       // Navigation shortcuts
  followUpQuestions: Array  // Suggested follow-up queries
  metadata: {
    crewType: string
    dataTimestamp: string
  }
}
```

## Technical Implementation

**Files Modified:**
- `src/app/api/chasen/crew/route.ts` - Added 5 new execution functions
- `src/lib/multi-agent.ts` - Registered crews in `getAvailableCrews()`
- `src/components/chasen/CommandPalette.tsx` - Added workflow triggers
- `src/app/(dashboard)/ai/page.tsx` - Extended WorkflowType

**Performance:**
- Each crew has a 20-25 second timeout
- Uses MatchaAI with Claude Sonnet 4.5
- Parallel database queries for speed
- Max 1800-2000 tokens per response

## Related Features

- [ChaSen Auto-Discovery](./FEATURE-20251227-chasen-auto-discovery.md) - Automatic data source integration
- [ChaSen Learning Enhancements](../guides/CHASEN_LEARNING_ENHANCEMENTS.md) - Preference memory
