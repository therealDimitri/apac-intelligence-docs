# Design Document: Briefing Room & Actions & Tasks Overhaul

**Date:** 2025-11-30
**Status:** Design Phase
**Priority:** HIGH

---

## Executive Summary

This document outlines comprehensive enhancements to two critical dashboard features:

1. **Briefing Room** - Enhanced meeting management with AI insights and action extraction
2. **Actions & Tasks** - Modern task management with multi-owner grouping and Microsoft integrations

Both features will be redesigned with modern UI/UX patterns from industry-leading tools (Linear, Notion, Asana, Monday.com).

---

## Part 1: Briefing Room Overhaul

### Current State Analysis

**Existing Features:**

- ✅ Search and filter (status, type)
- ✅ Pagination (25 meetings per page)
- ✅ Basic meeting details (client, CSE, date, time, type)
- ✅ AI-analysed summary, sentiment, effectiveness scores
- ✅ Topics, highlights, risks, next steps
- ✅ Transcript and recording file uploads
- ✅ Attendees modal
- ✅ Outlook import integration
- ✅ Schedule meeting modal

**Database Schema (`unified_meetings` table):**

```
Fields Available:
- Basic: meeting_id, client_name, cse_name, meeting_date, meeting_time, duration
- Organization: meeting_dept, meeting_type, status
- AI Analysis: ai_summary, topics[], highlights[], risks[], next_steps[]
- Sentiment: sentiment_overall, sentiment_score, sentiment_client, sentiment_cse
- Effectiveness: effectiveness_* (7 metrics)
- Files: transcript_file_url, recording_file_url, meeting_notes
- People: attendees (JSON/text field)
- Integration: outlook_event_id, teams_meeting_id, synced_to_outlook
- Timestamps: created_at, updated_at, analyzed_at
```

### Enhancement Requirements

#### 1. Enhanced Meeting Display

**New Fields to Add/Expose:**

- ✅ **Meeting Dept** - Already exists (meeting_dept: "Client Success")
- ✅ **Title** - Use meeting_type or add dedicated title field
- ✅ **Client Name** - Already exists (client_name)
- ✅ **Date/Time** - Already exists (meeting_date, meeting_time)
- ✅ **Duration** - Already exists (duration in minutes)
- ⚠️ **Organizer** - Clarify if cse_name or add organizer field
- ✅ **Attendees** - Already exists (attendees JSON field)
- ✅ **Status** - Already exists ("Completed" or "Scheduled")
- ✅ **Executive Summary** - Already exists (ai_summary)
- ✅ **Key Topics** - Already exists (topics array)
- ❌ **Decisions Made** - NEW: Add decisions[] array field
- ✅ **Key Risks** - Already exists (risks array)
- ✅ **Next Steps** - Already exists (next_steps array)
- ❌ **Related Actions** - NEW: Link to actions table via meeting_id
- ✅ **Transcript** - Already exists (transcript_file_url)
- ❌ **Resources** - NEW: Add resources[] array with URLs/Sharepoint links

#### 2. Action Extraction Feature

**Requirement:** Extract action items from meeting and create them in Actions & Tasks page

**Implementation Approach:**

1. Add "Extract Actions" button to expanded meeting view
2. Modal showing AI-detected action items from meeting notes/transcript
3. Each action has:
   - Action description (from next_steps or AI analysis)
   - Assigned owner (from attendees dropdown)
   - Due date (date picker, default: +2 weeks)
   - Priority (dropdown: Critical, High, Medium, Low)
   - Linked meeting_id for traceability
4. Batch create actions in actions table
5. Show success notification with link to Actions & Tasks page

**AI Integration:**

- Use existing next_steps[] array as starting point
- Optionally enhance with AI re-analysis to extract specific action items
- Parse owner mentions from notes (e.g., "@John will follow up on...")

#### 3. Edit/Delete Functions

**Edit Meeting:**

- Click "Edit" button on expanded meeting
- Inline editing or modal form
- Editable fields:
  - meeting_type, meeting_dept
  - attendees (multi-select dropdown)
  - meeting_notes (rich text editor)
  - status (Completed/Scheduled)
  - Custom fields: decisions[], resources[]
- Save updates to database with updated_at timestamp

**Delete Meeting:**

- Click "Delete" button (with confirmation modal)
- Soft delete (mark as deleted: true) or hard delete
- Show warning if meeting has related actions

#### 4. New Database Fields Needed

**Migration: Add to `unified_meetings` table**

```sql
ALTER TABLE unified_meetings
ADD COLUMN decisions TEXT[], -- Array of key decisions made
ADD COLUMN resources JSONB,   -- Array of {title, url, type} objects
ADD COLUMN organizer TEXT,    -- Meeting organizer (if different from cse_name)
ADD COLUMN title TEXT,         -- Custom meeting title (optional, fallback to meeting_type)
ADD COLUMN deleted BOOLEAN DEFAULT false; -- Soft delete flag
```

**Example resources structure:**

```json
{
  "resources": [
    { "title": "Q3 Performance Report", "url": "https://sharepoint.com/...", "type": "document" },
    { "title": "Product Roadmap", "url": "https://sharepoint.com/...", "type": "presentation" }
  ]
}
```

#### 5. UI/UX Enhancements

**Inspiration from Modern Tools:**

- **Linear**: Clean, fast filtering with keyboard shortcuts
- **Notion**: Expandable sections with smooth animations
- **Asana**: Color-coded status badges, priority indicators
- **Monday.com**: Visual timeline view option

**Proposed Changes:**

1. **Meeting Cards:**
   - Color-coded status: Green (Completed), Blue (Scheduled), Red (Overdue)
   - Show key metrics at a glance: sentiment score, effectiveness score
   - Quick action buttons: View, Edit, Extract Actions, Delete

2. **Expanded View:**
   - Tabbed interface:
     - Tab 1: Overview (Summary, Topics, Attendees)
     - Tab 2: Analysis (Sentiment, Effectiveness, AI Insights)
     - Tab 3: Actions & Decisions (Decisions, Next Steps, Related Actions)
     - Tab 4: Files & Resources (Transcripts, Recordings, Resources)
   - Sticky header with meeting title and status
   - Right sidebar: Timeline of updates, edit history

3. **Filter Enhancements:**
   - Date range picker (Last 7 days, Last 30 days, Custom)
   - Multi-select for CSE, Client, Meeting Type
   - Sentiment filter (Positive, Neutral, Negative)
   - Quick filters: "Needs Follow-up", "Has Actions", "Transcripts Available"

### Technical Implementation Plan

**Phase 1: Database Migration (Week 1)**

- Add new fields: decisions, resources, organizer, title, deleted
- Create index on meeting_id for faster action lookups
- Backfill existing data where applicable

**Phase 2: Edit/Delete Functionality (Week 1)**

- Create `EditMeetingModal` component
- Implement PATCH /api/meetings/[id] endpoint
- Implement DELETE /api/meetings/[id] endpoint
- Add confirmation dialogues

**Phase 3: Action Extraction (Week 2)**

- Create `ExtractActionsModal` component
- Implement AI action detection from next_steps
- Create POST /api/actions/batch endpoint
- Add meeting_id link to actions table

**Phase 4: UI/UX Redesign (Week 2)**

- Redesign meeting cards with modern styling
- Implement tabbed expanded view
- Add colour-coded status badges
- Enhanced filters with date range picker

**Phase 5: Resources & Decisions (Week 3)**

- Add resources upload/link functionality
- Add decisions input (rich text or simple text array)
- Display resources in Files & Resources tab
- Display decisions in Actions & Decisions tab

---

## Part 2: Actions & Tasks Overhaul

### Current State Analysis

**Existing Features:**

- ✅ Filter by: All, My Actions, Critical, Overdue
- ✅ Stats cards: Open, In Progress, Overdue, Completed This Week
- ✅ Action cards with client, owner, due date, priority, status
- ✅ Action detail modal

**Database Schema (`actions` table):**

```
Fields Available:
- Basic: Action_ID, Action_Description
- Ownership: Owners (comma-separated string)
- Due: Due_Date, Status, Priority
- Context: Content_Topic, Meeting_Date, Topic_Number
- Metadata: Notes, created_at, updated_at, Completed_At
- Sharing: Shared_Action_Id, Is_Shared
```

**Critical Issues Identified:**

1. **Multi-Owner Grouping Problem:**
   - O03-1, O03-2, O03-3 stored as SEPARATE rows
   - Should be ONE action with multiple owners
   - Owners field already supports comma-separated values

2. **Owner/Client Fields:**
   - Sample data shows Owners: "undefined"
   - Sample data shows Client: "undefined"
   - Need to investigate and fix data quality

### Enhancement Requirements

#### 1. Multi-Owner Action Grouping

**Problem:**

```
Current Database:
- O03-1: Owner: "John Doe", Description: "Monitor NPS bounces"
- O03-2: Owner: "Jane Smith", Description: "Monitor NPS bounces"
- O03-3: Owner: "Bob Lee", Description: "Monitor NPS bounces"

Current UI: Shows 3 separate actions ❌
Expected UI: Shows 1 action with 3 owners ✅
```

**Solution Approach:**

**Option A: Database Consolidation (Recommended)**

1. Identify all multi-owner action groups (same base Action_ID)
2. Consolidate into single row with comma-separated Owners field
3. Update useActions hook to query consolidated data
4. UI displays owner pills/badges

**SQL Migration:**

```sql
-- Example: Consolidate O03-1, O03-2, O03-3 into O03
UPDATE actions
SET Owners = 'John Doe, Jane Smith, Bob Lee',
    Action_ID = 'O03'
WHERE Action_ID IN ('O03-1', 'O03-2', 'O03-3')
AND id = (SELECT MIN(id) FROM actions WHERE Action_ID LIKE 'O03-%');

DELETE FROM actions
WHERE Action_ID IN ('O03-2', 'O03-3');
```

**Option B: UI Grouping Only**

1. Keep database as-is
2. Group in useActions hook by base Action_ID
3. Aggregate owners into array
4. Display as single action in UI

**UI Display:**

```tsx
<ActionCard>
  <ActionHeader>
    <ActionID>O03</ActionID>
    <OwnerPills>
      <Pill>John Doe</Pill>
      <Pill>Jane Smith</Pill>
      <Pill>Bob Lee</Pill>
      <Pill>+ 4 more</Pill>
    </OwnerPills>
  </ActionHeader>
  <Description>Monitor and manage NPS email bounces</Description>
</ActionCard>
```

**Recommendation:** Use Option A (Database Consolidation) for data integrity and simpler queries.

#### 2. Edit & Notes Functionality

**Edit Action:**

- Click "Edit" button on action card or detail modal
- Inline editing or side panel
- Editable fields:
  - Action_Description (rich text or plain text)
  - Owners (multi-select dropdown of CSEs)
  - Due_Date (date picker)
  - Priority (dropdown)
  - Status (dropdown)
  - Notes (rich text editor)
- Save updates with updated_at timestamp

**Notes Enhancement:**

- Notes field already exists in database
- Add rich text editor (Tiptap or Quill)
- Support markdown formatting
- Show notes in expanded view
- Track edit history

**UI Pattern (inspired by Linear):**

```
┌─────────────────────────────────────────┐
│ Action O03                        [Edit]│
│ Monitor and manage NPS email bounces    │
├─────────────────────────────────────────┤
│ Owners: [John] [Jane] [Bob] [+4]        │
│ Due: 19/12/2025  Priority: Medium       │
│ Status: [In Progress ▼]                 │
├─────────────────────────────────────────┤
│ Notes:                                  │
│ ┌─────────────────────────────────────┐ │
│ │ **Update 25/11:**                   │ │
│ │ Implemented new bounce monitoring   │ │
│ │ Added 3 new filters                 │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

#### 3. Modern UI/UX Features

**Inspiration from Leading Tools:**

**From Linear:**

- ⚡ Keyboard shortcuts (⌘K to quick search actions)
- 🎯 Priority icons (🔴 Critical, 🟠 High, 🟡 Medium, ⚪ Low)
- ⚙️ Status workflow (To Do → In Progress → Review → Done)
- 📅 Calendar view for due dates

**From Asana:**

- 📊 Board view (Kanban columns by status)
- 📈 Timeline view (Gantt chart)
- 🏷️ Custom tags/labels
- 👥 Team workload view

**From Notion:**

- 🔄 Drag and drop to change status
- 📝 Rich text descriptions
- 🔗 Linked actions (parent/child relationships)
- 💾 Auto-save (debounced updates)

**From Monday.com:**

- 🎨 Color-coded priorities
- 📊 Dashboard widgets (burn-down charts, completion rates)
- 🔔 Activity timeline
- 📧 Email notifications

**Proposed Features to Implement:**

1. **View Modes:**
   - List view (current, enhanced)
   - Board view (Kanban by status)
   - Calendar view (actions by due date)
   - Timeline view (Gantt chart)

2. **Quick Actions:**
   - Bulk operations (select multiple, change status/owner/priority)
   - Duplicate action
   - Convert to meeting agenda item
   - Link to related actions

3. **Smart Filters:**
   - Saved filter presets
   - Complex queries (Owner: John AND Priority: High AND Due: This Week)
   - Filter by meeting source
   - Filter by completion percentage

4. **Activity Feed:**
   - Real-time updates (who changed what, when)
   - Comment threads on actions
   - @mentions to notify owners
   - Edit history

5. **Dashboard Widgets:**
   - Completion rate trend (line chart)
   - Actions by priority (pie chart)
   - Overdue actions alert
   - My actions this week

#### 4. Microsoft Integration

**MS Outlook Integration:**

**Features:**

1. **Create Outlook Task from Action:**
   - Click "Send to Outlook" button
   - Creates task in Outlook with:
     - Subject: Action_Description
     - Due Date: Due_Date
     - Body: Notes + Link back to dashboard
     - Categories: Priority colour-coding

2. **Sync Action Status:**
   - Bidirectional sync (Outlook ↔ Dashboard)
   - When Outlook task marked complete → Update dashboard status
   - When dashboard action updated → Update Outlook task

3. **Email Reminders:**
   - Automatically send email reminders for:
     - Actions due tomorrow
     - Overdue actions
     - Weekly summary of my actions

**MS Teams Integration:**

**Features:**

1. **Teams Channel Integration:**
   - Post action updates to specific Teams channel
   - Example: "#client-success-actions" channel
   - Format:
     ```
     🔔 New Action Created
     O03: Monitor and manage NPS email bounces
     Owners: @John Doe, @Jane Smith, @Bob Lee
     Due: 19/12/2025
     Priority: Medium
     [View in Dashboard →]
     ```

2. **Teams Bot Commands:**
   - `/action list` - Show my actions
   - `/action create [description]` - Quick create action
   - `/action complete [id]` - Mark action complete

3. **Teams Meeting Integration:**
   - Create actions directly from Teams meeting chat
   - Link actions to Teams meeting recordings
   - Extract actions from meeting transcripts

**Technical Implementation:**

**Outlook API:**

```typescript
// Create Outlook task
const createOutlookTask = async (action: Action) => {
  const task = {
    subject: action.description,
    dueDateTime: {
      dateTime: action.dueDate,
      timeZone: 'AUS Eastern Standard Time',
    },
    body: {
      contentType: 'HTML',
      content: `
        <p>${action.description}</p>
        <p><strong>Priority:</strong> ${action.priority}</p>
        <p><strong>Notes:</strong> ${action.notes}</p>
        <p><a href="${dashboardUrl}/actions/${action.id}">View in Dashboard</a></p>
      `,
    },
    importance: action.priority === 'critical' ? 'high' : 'normal',
    categories: [getPriorityColor(action.priority)],
  }

  const response = await fetch('https://graph.microsoft.com/v1.0/me/outlook/tasks', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(task),
  })

  return response.json()
}
```

**Teams Webhook:**

```typescript
// Post to Teams channel
const postToTeams = async (action: Action, event: 'created' | 'updated' | 'completed') => {
  const card = {
    '@type': 'MessageCard',
    summary: `Action ${event}: ${action.id}`,
    sections: [
      {
        activityTitle: `🔔 Action ${event}`,
        activitySubtitle: action.id,
        facts: [
          { name: 'Description', value: action.description },
          { name: 'Owners', value: action.owners.join(', ') },
          { name: 'Due Date', value: formatDate(action.dueDate) },
          { name: 'Priority', value: action.priority },
        ],
      },
    ],
    potentialAction: [
      {
        '@type': 'OpenUri',
        name: 'View in Dashboard',
        targets: [
          {
            os: 'default',
            uri: `${dashboardUrl}/actions/${action.id}`,
          },
        ],
      },
    ],
  }

  await fetch(teamsWebhookUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(card),
  })
}
```

#### 5. Holistic Integration

**Link Actions Across Dashboard:**

1. **From Segmentation:**
   - High-risk client cards show related actions
   - Quick create action from client segment

2. **From Alerts:**
   - Alert actions link to Actions & Tasks
   - Convert alert to action with one click

3. **From Meetings (Briefing Room):**
   - Extract actions from meetings
   - Show related actions in meeting view
   - Link action back to originating meeting

4. **From NPS:**
   - Create follow-up action from low NPS score
   - Link action to specific NPS response

**Action Relationship Graph:**

```
Meeting (Briefing Room)
    ↓ Extract Actions
Action O03
    ↓ Linked to
Client: SingHealth
    ↓ Segment
Leverage Segment
    ↓ Related to
Alert: Low Engagement
```

### Technical Implementation Plan

**Phase 1: Multi-Owner Consolidation (Week 1)**

- Audit all actions for multi-owner patterns
- Write consolidation script
- Update useActions hook
- Update UI to display owner pills

**Phase 2: Edit & Notes UI (Week 1)**

- Create EditActionModal component
- Implement rich text editor for notes
- Add inline editing for quick updates
- PATCH /api/actions/[id] endpoint

**Phase 3: Modern UI/UX (Week 2)**

- Implement view modes (List, Board, Calendar)
- Add keyboard shortcuts
- Color-coded priorities and statuses
- Drag-and-drop status changes

**Phase 4: Microsoft Integrations (Week 2-3)**

- Set up Microsoft Graph API authentication
- Implement Outlook task sync
- Set up Teams webhook
- Create email reminder system

**Phase 5: Dashboard Integration (Week 3)**

- Link actions from Segmentation, Alerts, NPS
- Create action relationship API endpoints
- Build action timeline/history view

---

## Database Schema Changes

### New Fields for `unified_meetings`

```sql
ALTER TABLE unified_meetings
ADD COLUMN decisions TEXT[] DEFAULT '{}',
ADD COLUMN resources JSONB DEFAULT '[]',
ADD COLUMN organizer TEXT,
ADD COLUMN title TEXT,
ADD COLUMN deleted BOOLEAN DEFAULT false;

-- Add index for faster action lookups
CREATE INDEX idx_meetings_meeting_id ON unified_meetings(meeting_id);
```

### New Fields for `actions`

```sql
ALTER TABLE actions
ADD COLUMN meeting_id TEXT REFERENCES unified_meetings(meeting_id),
ADD COLUMN outlook_task_id TEXT,
ADD COLUMN teams_message_id TEXT,
ADD COLUMN last_synced_at TIMESTAMP,
ADD COLUMN edit_history JSONB DEFAULT '[]';

-- Add index for multi-owner queries
CREATE INDEX idx_actions_shared ON actions(Is_Shared, Shared_Action_Id);

-- Add index for meeting linkage
CREATE INDEX idx_actions_meeting ON actions(meeting_id);
```

### New Table: `action_comments`

```sql
CREATE TABLE action_comments (
  id SERIAL PRIMARY KEY,
  action_id INTEGER REFERENCES actions(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  comment TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_comments_action ON action_comments(action_id);
```

---

## API Endpoints to Create

### Meetings Endpoints

```
PATCH /api/meetings/[id]          - Update meeting details
DELETE /api/meetings/[id]         - Delete meeting (soft delete)
POST /api/meetings/[id]/actions   - Extract actions from meeting
GET /api/meetings/[id]/actions    - Get actions linked to meeting
```

### Actions Endpoints

```
PATCH /api/actions/[id]           - Update action
POST /api/actions/batch           - Create multiple actions at once
GET /api/actions/[id]/comments    - Get action comments
POST /api/actions/[id]/comments   - Add comment to action
POST /api/actions/[id]/outlook    - Sync action to Outlook
POST /api/actions/[id]/teams      - Post action update to Teams
GET /api/actions/consolidate      - Get multi-owner action groups
```

---

## UI Component Architecture

### New Components for Briefing Room

```
src/components/briefing-room/
├── EditMeetingModal.tsx          - Edit meeting form
├── ExtractActionsModal.tsx       - Extract actions from meeting
├── MeetingCardEnhanced.tsx       - Redesigned meeting card
├── MeetingExpandedView.tsx       - Tabbed expanded view
├── DecisionsSection.tsx          - Display/edit decisions
├── ResourcesSection.tsx          - Display/edit resources
└── RelatedActionsSection.tsx     - Show linked actions
```

### New Components for Actions & Tasks

```
src/components/actions/
├── EditActionModal.tsx           - Edit action form
├── ActionBoardView.tsx           - Kanban board by status
├── ActionCalendarView.tsx        - Calendar view by due date
├── ActionTimelineView.tsx        - Gantt chart view
├── OwnerPills.tsx                - Display multiple owners
├── ActionCommentsSection.tsx     - Comments thread
├── BulkActionsToolbar.tsx        - Bulk operations UI
└── OutlookSyncButton.tsx         - Sync to Outlook
```

---

## Success Metrics

### Briefing Room

- ✅ All meetings have complete metadata (dept, attendees, etc.)
- ✅ >80% of meetings have decisions documented
- ✅ Actions extracted from >50% of meetings
- ✅ Average time to edit meeting: <30 seconds
- ✅ Resources uploaded to >30% of meetings

### Actions & Tasks

- ✅ 0 multi-owner actions shown as duplicates
- ✅ >90% of actions have valid owner and client
- ✅ >50% of users use notes functionality
- ✅ >30% of actions synced to Outlook
- ✅ Average time to complete action workflow: <2 minutes

---

## Next Steps

1. ✅ **Design Document Approved** - Review and approve this design
2. ⏳ **Phase 1 Implementation** - Start with multi-owner consolidation and database migrations
3. ⏳ **UI Mockups** - Create Figma mockups for new UI components
4. ⏳ **API Development** - Build new API endpoints
5. ⏳ **Component Development** - Build React components
6. ⏳ **Integration Testing** - Test Microsoft integrations
7. ⏳ **User Acceptance Testing** - CSE team testing
8. ⏳ **Deployment** - Roll out to production

---

**Document Version:** 1.0
**Last Updated:** 2025-11-30
**Author:** Claude Code
**Reviewers:** Jimmy Leimonitis
