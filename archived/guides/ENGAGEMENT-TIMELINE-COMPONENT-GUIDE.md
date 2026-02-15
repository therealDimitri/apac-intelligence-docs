# Engagement Timeline Component Guide

**Created**: 2026-01-09
**Component Type**: Planning/Account Management
**Status**: New Feature

## Overview

The Engagement Timeline component provides a comprehensive visual timeline showing all client touchpoints. It aggregates data from multiple sources into a chronological view, helping CSEs understand the full history of client engagement.

## Files Created

### 1. API Route
**Path**: `/src/app/api/planning/timeline/route.ts`

A comprehensive API endpoint that aggregates timeline data from multiple sources:
- Unified meetings
- NPS responses
- Actions
- Health score changes
- Segmentation/compliance events

**Query Parameters**:
- `clientId` (optional): Client UUID for lookup
- `clientName` (optional): Client name (at least one required)
- `months` (optional): Number of months of history (default: 12)
- `types` (optional): Comma-separated list of event types to include
- `startDate` (optional): Start of date range (ISO format)
- `endDate` (optional): End of date range (ISO format)

### 2. Hook
**Path**: `/src/hooks/useEngagementTimeline.ts`

React hook that manages fetching and caching timeline data.

**Features**:
- 5-minute client-side caching
- Background data refresh
- Type filtering helper function
- Month-based event grouping
- Sorted months array for rendering

**Exported Types**:
- `TimelineEventType`: 'meeting' | 'nps' | 'action' | 'health' | 'event'
- `Sentiment`: 'positive' | 'neutral' | 'negative'
- `TimelineEvent`: Base event interface
- `MeetingMetadata`, `NPSMetadata`, `ActionMetadata`, `HealthMetadata`, `ComplianceEventMetadata`
- `TimelineSummary`: Aggregate statistics
- `EngagementVelocity`: Meetings per month trend data

**Helper Functions**:
- `getSentimentEmoji(sentiment)`: Returns emoji for sentiment
- `formatMonthDisplay(monthKey)`: Formats YYYY-MM to human-readable

### 3. Component
**Path**: `/src/components/planning/EngagementTimeline.tsx`

Visual React component for displaying the timeline.

**Features**:
1. **Chronological grouping by month** - Collapsible month sections
2. **Event type icons and colours**:
   - Meeting: Blue, Calendar icon
   - NPS: Purple, MessageSquare icon
   - Action: Green, CheckCircle icon
   - Health: Amber, Heart icon
   - Compliance: Cyan, Activity icon
3. **Sentiment indicators** - Emoji display (happy/neutral/sad)
4. **Event-specific detail cards**:
   - Meetings: Attendees, topics, decisions count
   - NPS: Score badge, category, feedback excerpt
   - Actions: Status, on-time/late indicator
   - Health: Direction arrow, status transition
   - Compliance: Status, event code, effectiveness score
5. **Filter by event type** - Toggle chips for each type
6. **Engagement velocity summary** - Meetings/month trend at bottom
7. **"Compare to Peers" placeholder** - Coming soon button

## Usage

```tsx
import EngagementTimeline from '@/components/planning/EngagementTimeline'

// With client UUID
<EngagementTimeline clientId="abc-123-uuid" months={12} />

// With client name
<EngagementTimeline clientName="Acme Corp" months={6} />

// Both can be provided (clientId takes precedence for matching)
<EngagementTimeline
  clientId="abc-123-uuid"
  clientName="Acme Corp"
  className="mt-4"
/>
```

## Data Flow

1. Component calls `useEngagementTimeline` hook with client identifier
2. Hook checks client-side cache (5 min TTL)
3. If cache miss, calls `/api/planning/timeline` endpoint
4. API executes parallel queries to all data sources
5. Results are processed into unified `TimelineEvent` format
6. Events sorted by date and grouped by month
7. Velocity metrics calculated from meeting frequency
8. Response cached and returned to component

## Design Decisions

### Why Parallel Queries
The API executes all data source queries in parallel using `Promise.all()` to minimise response time. Each query is independent and can run concurrently.

### Why Client-Side Caching
Timeline data changes infrequently and can be relatively large. A 5-minute cache prevents redundant API calls when navigating between views.

### Why Month-Based Grouping
Grouping by month provides a natural chronological structure that:
- Allows easy scanning of recent vs historical activity
- Reduces visual clutter with collapsible sections
- Enables quick identification of engagement patterns

### Sentiment Calculation
- **Meetings**: Based on AI sentiment analysis score (0-1 scale)
- **NPS**: Score >= 9 positive, <= 6 negative, else neutral
- **Actions**: Completed = positive, overdue = negative, else neutral
- **Health**: Status improvement = positive, decline = negative
- **Events**: Completed = positive, overdue = negative, else neutral

## Schema Dependencies

This component queries the following tables (verified against docs/database-schema.md):

| Table | Columns Used |
|-------|-------------|
| `unified_meetings` | id, meeting_id, title, meeting_date, meeting_time, meeting_type, attendees, ai_summary, topics, decisions, sentiment_score, status |
| `nps_responses` | id, score, feedback, contact_name, response_date, period, category |
| `actions` | id, Action_ID, Action_Description, Status, Priority, Due_Date, Completed_At, Owners, Category, created_at |
| `client_health_history` | id, snapshot_date, health_score, status, previous_status, status_changed, nps_points, compliance_points, working_capital_points |
| `segmentation_events` | id, event_date, event_year, completed, completed_by, completed_date, notes, effectiveness_score |

## Styling

Uses Tailwind CSS with the project's established colour palette:
- Blue for meetings/primary actions
- Purple for NPS
- Green for completed/positive
- Amber for warnings/health
- Cyan for compliance events
- Red for negative/overdue states

## Future Enhancements

1. **Compare to Peers** - Button placeholder exists, needs peer data implementation
2. **Export Timeline** - PDF/CSV export functionality
3. **Event Details Modal** - Click to expand full event details
4. **Real-time Updates** - WebSocket subscription for live updates
5. **Search Within Timeline** - Filter events by keyword
