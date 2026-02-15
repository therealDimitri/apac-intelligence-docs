# Feature: Rich AI Responses for ChaSen Crews

**Date:** 24 December 2024
**Status:** IMPLEMENTED
**Component:** ChaSen AI - Multi-Agent Crews

## Overview

Enhanced all AI Crew responses to include rich, feature-rich UI components including:

- Client context cards with health badges
- Related actions, meetings, and NPS data with links
- Quick action buttons for navigation
- Follow-up question chips for conversation continuity

## Problem Statement

AI Crew responses (Meeting Prep, Client Report, Portfolio Analysis, Risk Assessment) were returning simple markdown text without:

- Links to client profiles or related data
- Visual health/NPS indicators
- Quick action buttons
- Suggested follow-up questions

This made the AI assistant feel disconnected from the rest of the platform.

## Solution Implemented

### 1. Rich Response Type System (`src/types/ai-response.ts`)

Created comprehensive type definitions for structured AI responses:

```typescript
export interface RichAIResponse {
  content: string // Main markdown content
  title?: string
  summary?: string
  clientContext?: {
    name: string
    id?: number
    profileUrl: string
    health?: HealthBadge
  }
  relatedActions?: RelatedAction[]
  relatedMeetings?: RelatedMeeting[]
  relatedNPS?: RelatedNPS[]
  quickActions?: QuickAction[]
  followUpQuestions?: FollowUpQuestion[]
  metadata?: { crewType; dataTimestamp; executionTime }
}
```

Helper functions for URL generation:

- `getClientProfileUrl()` - Generate client profile links
- `getActionsUrl()` - Actions page with optional client filter
- `getMeetingsUrl()` - Meetings page with optional client filter
- `getNPSUrl()` - NPS page with optional client filter
- `getHealthStatusColour()` - CSS classes for health status badges
- `getNPSSentimentColour()` - CSS classes for NPS score badges

### 2. Crew API Updates (`src/app/api/chasen/crew/route.ts`)

All four crew types now return `RichAIResponse` format:

| Crew Type            | Rich Data Returned                                                                  |
| -------------------- | ----------------------------------------------------------------------------------- |
| `portfolio-analysis` | Related actions, NPS, follow-up questions                                           |
| `client-report`      | Client context with health badge, actions, meetings, NPS, quick actions, follow-ups |
| `risk-assessment`    | Overdue/blocked actions, detractor NPS, follow-up questions                         |
| `meeting-prep`       | Client context, meeting history, open actions, quick actions, follow-ups            |

Example response structure:

```json
{
  "status": "ok",
  "result": {
    "crew": "meeting-prep",
    "success": true,
    "finalOutput": "## Meeting Prep: Epworth...",
    "title": "Meeting Prep: Epworth",
    "summary": "Health 85%, 3 actions to review",
    "clientContext": {
      "name": "Epworth",
      "id": 42,
      "profileUrl": "/clients/42/v2",
      "health": { "score": 85, "status": "Healthy", "npsScore": 8 }
    },
    "relatedActions": [...],
    "relatedMeetings": [...],
    "quickActions": [
      { "label": "View Profile", "type": "view-profile", "url": "/clients/42/v2" },
      { "label": "Schedule Meeting", "type": "schedule-meeting", "params": { "client": "Epworth" } }
    ],
    "followUpQuestions": [
      { "text": "Generate a client report for Epworth", "query": "Client report for Epworth" }
    ]
  }
}
```

### 3. Frontend Rendering (`src/app/(dashboard)/ai/page.tsx`)

Added rich UI components in the chat message rendering:

1. **Client Context Card**
   - Avatar with client name link
   - Health status badge (colour-coded)
   - Health Score / NPS / Compliance metrics grid

2. **Related Actions Section**
   - Status badges (Blocked, In Progress, Overdue)
   - Client name and due date
   - "View all X actions" link

3. **Recent Meetings Section**
   - Meeting subject and date
   - "Has Notes" badge if applicable

4. **Recent NPS Feedback Section**
   - NPS score with sentiment colour
   - Feedback preview text

5. **Quick Actions Bar**
   - Gradient purple buttons
   - Icons for action types (profile, calendar, tasks, etc.)
   - Navigation links or action triggers

6. **Follow-up Question Chips**
   - Rounded pill buttons
   - Click to send pre-filled query

## Files Modified

- `src/types/ai-response.ts` - NEW - Rich response type definitions
- `src/app/api/chasen/crew/route.ts` - Updated to return RichAIResponse
- `src/app/(dashboard)/ai/page.tsx` - Updated ChatMessage interface and rendering

## UI Components Added

```tsx
{/* Client Context Card */}
{chat.clientContext && (
  <div className="rounded-lg border p-4 bg-{status}-50">
    <User avatar /> <Link to profile>Name</Link> <HealthBadge />
    <Grid: Health Score | NPS | Compliance>
  </div>
)}

{/* Related Actions */}
{chat.relatedActions?.map(action => (
  <div className="bg-gray-50 rounded p-2">
    <p>{action.text}</p>
    <span className="badge">{action.status}</span>
  </div>
))}

{/* Quick Actions */}
{chat.quickActions?.map(action => (
  <Link className="gradient-button">{action.label}</Link>
))}

{/* Follow-up Chips */}
{chat.richFollowUpQuestions?.map(q => (
  <button className="rounded-full bg-purple-50">{q.text}</button>
))}
```

## Backwards Compatibility

The API response maintains backwards compatibility:

- `finalOutput` still contains the main text content
- `summary` still provides a brief summary
- New fields are additive and optional

## Next Steps

To extend this pattern to all AI responses (not just crews):

1. Update chat API (`/api/chasen/chat`) to return RichAIResponse
2. Update workflow functions to include rich data
3. Apply to Quick Start responses
4. Apply to semantic search results

## Testing

1. TypeScript compilation: PASSED
2. Build: PASSED
3. Manual testing: Test Client Report and Meeting Prep crews in the UI
