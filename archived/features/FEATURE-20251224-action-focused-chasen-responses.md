# Feature: Action-Focused ChaSen AI Responses

**Date:** 2024-12-24
**Status:** Implemented
**Commits:** c2e740a, 3fe5824, d2c7ad0

## Overview

Enhanced ChaSen AI streaming responses to be action-focused with rich UI components that enable users to take immediate action on insights.

## Problem Statement

ChaSen AI responses were plain markdown text with no actionable elements. Users had to manually navigate to other pages after receiving insights, creating friction and reducing engagement.

## Solution

### Backend Changes (`src/app/api/chasen/stream/route.ts`)

1. **Client Detection** - `extractMentionedClients()`
   - Parses AI response text to identify client names
   - Enriches with health score and NPS data from database
   - Assigns status: `critical` (<50%), `at-risk` (50-69%), `healthy` (>=70%)
   - Returns top 5 most critical clients

2. **Action Generation** - `generateSuggestedActions()`
   - Creates contextual quick action buttons based on query type
   - Client-specific: "Schedule meeting with [Client]" for at-risk clients
   - Query-based: Risk queries → "View all at-risk clients"
   - Always includes: Briefing Room, Actions & Tasks links

3. **Follow-up Questions** - `generateFollowUpQuestions()`
   - Generates 3 contextual follow-up questions
   - Client-specific: "What actions are planned for [Client]?"
   - Query-based: Risk → "Which clients have improving health scores?"

4. **Metadata Streaming**
   - Modified `createChunkedStream()` to send metadata as final SSE event
   - Format: `data: {"metadata": {...}}\n\n`

### Frontend Changes (`src/components/FloatingChaSenAI.tsx`)

1. **Metadata Handling**
   - Captures `data.metadata` event at end of stream
   - Stores in message's `metadata` field

2. **Rich UI Components**

   **Client Cards:**

   ```
   ┌─────────────────────────────────────────────┐
   │ 🔴 CRITICAL | Saint Luke's Medical Centre  │
   │ Health: 37% • NPS: 1pts                     │
   │ [View Profile] [Schedule Meeting] [Action]  │
   └─────────────────────────────────────────────┘
   ```

   - Status badges with colour coding (red/amber/green)
   - Inline metrics display
   - Three action buttons per client

   **Quick Actions Bar:**
   - Gradient purple background
   - Icon + label buttons
   - Links to: Briefing Room, Actions & Tasks, Client Profiles

   **Follow-up Questions:**
   - Clickable buttons with arrow prefix
   - Hover state with purple background
   - Triggers new query when clicked

### Type Updates (`src/types/chasen.ts`)

```typescript
interface MentionedClient {
  name: string
  status?: 'critical' | 'at-risk' | 'healthy'
  healthScore?: number
  npsScore?: number
}

interface SuggestedAction {
  label: string
  description: string
  href: string
  icon: 'calendar' | 'task' | 'profile' | 'chart'
  clientName?: string
}
```

## Visual Design

### Response Structure

```
┌──────────────────────────────────────────────────────┐
│ [AI Response Text - Markdown]                        │
├──────────────────────────────────────────────────────┤
│ 👤 Clients Mentioned                                 │
│ ┌────────────────────────────────────────────────┐  │
│ │ 🔴 CRITICAL | Client Name                      │  │
│ │ Health: X% • NPS: Xpts                         │  │
│ │ [View Profile] [Schedule Meeting] [Action]     │  │
│ └────────────────────────────────────────────────┘  │
├──────────────────────────────────────────────────────┤
│ ⚡ Quick Actions                                     │
│ [📅 Briefing Room] [✅ Actions & Tasks] [📊 View]   │
├──────────────────────────────────────────────────────┤
│ 💬 You might also ask:                               │
│ → What actions are planned for [Client]?             │
│ → Which clients have improving health scores?        │
└──────────────────────────────────────────────────────┘
```

## Navigation Links

| Button           | Destination                                     |
| ---------------- | ----------------------------------------------- |
| View Profile     | `/client-profiles?search={clientName}`          |
| Schedule Meeting | `/meetings?action=schedule&client={clientName}` |
| Create Action    | `/actions?client={clientName}`                  |
| Briefing Room    | `/meetings`                                     |
| Actions & Tasks  | `/actions`                                      |
| View at-risk     | `/client-profiles?filter=at-risk`               |

## Performance Considerations

- Metadata extraction has 3-second timeout to not block response
- Client lookup uses single database query with deduplication
- Metadata sent after text stream completes (no delay to initial response)

## Testing

1. Ask "What are the top 3 risks in my portfolio?"
2. Verify client cards appear with correct status badges
3. Click "View Profile" → navigates to Client Profiles with search
4. Click "Schedule Meeting" → navigates to Briefing Room with client pre-filled
5. Click follow-up question → sends new query

## Files Modified

- `src/app/api/chasen/stream/route.ts` - Backend metadata generation
- `src/components/FloatingChaSenAI.tsx` - Frontend rendering
- `src/types/chasen.ts` - Type definitions

## Bug Fix: Response Modal Not Showing Rich UI (3fe5824)

**Issue:** After initial deployment, the rich UI (client cards, quick actions, follow-up questions) was not appearing in the Response Modal view.

**Root Cause:** The initial implementation only added rich UI rendering to the full-chat message history view. The Response Modal uses a separate `response` state object that wasn't receiving the metadata.

**Fix:**

1. Added `streamMetadata` variable to capture metadata during SSE streaming
2. Updated `ChaSenResponse` interface to include `mentionedClients` and `suggestedActions`
3. Updated `setResponse()` call to include the captured metadata
4. Added rich UI rendering JSX to the Response Modal section

**Two Rendering Paths:**

- **Full-Chat Mode:** Renders from `conversationHistory` array → metadata in `message.metadata`
- **Response Modal:** Renders from `response` state object → metadata now stored directly on response object

## Bug Fix: Main AI Page Not Showing Rich UI (d2c7ad0)

**Issue:** After fixing the FloatingChaSenAI Response Modal, the main ChaSen AI page at `/ai` still wasn't displaying the rich UI components (client cards, quick actions, follow-up questions).

**Root Cause:** The initial implementation only added rich UI to `FloatingChaSenAI.tsx`, but the user was testing on the main AI page which is a completely separate component (`src/app/(dashboard)/ai/page.tsx`).

**Fix:**

1. Added imports for `MentionedClient`, `SuggestedAction` types from `@/types/chasen`
2. Added `Link` from `next/link` and `User`, `BarChart3`, `CheckSquare` icons
3. Updated `ChatMessage` interface to include `mentionedClients` and `suggestedActions`
4. Added `streamMetadata` variable to track metadata during SSE streaming
5. Added `data.metadata` handling in SSE parser
6. Updated final `setChatHistory` call to include captured metadata
7. Added rich UI rendering (client cards, quick actions bar) to message display

**Two Separate Components:**

- **FloatingChaSenAI** (`src/components/FloatingChaSenAI.tsx`) - The floating assistant widget
- **Main AI Page** (`src/app/(dashboard)/ai/page.tsx`) - The full-page ChaSen interface

Both components needed the same metadata handling and rendering code.
