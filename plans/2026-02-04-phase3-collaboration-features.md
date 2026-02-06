# Phase 3: Collaboration Features - Implementation Plan

**Date:** 4 February 2026
**Status:** In Progress
**Estimated Duration:** 1-2 weeks

---

## Current State Analysis

### Already Implemented (~70%)

| Component | Status | Notes |
|-----------|--------|-------|
| `usePlanPresence.ts` | ✅ 100% | Real-time presence with heartbeat |
| `usePlanComments.ts` | ✅ 100% | Full CRUD, threading, resolution |
| Comments API | ✅ 100% | GET/POST/PUT with activity logging |
| Presence API | ✅ 100% | Real-time with auto-cleanup |
| Approval API | ✅ 100% | Submit/approve/reject workflow |
| Database Schema | ✅ 100% | All tables, indexes, RLS policies |
| `PresenceIndicator.tsx` | ✅ Basic | Avatar stack with tooltips |
| `CollaborationPanel.tsx` | 🔶 50% | Comments display, needs @mention UI |

### Needs Implementation

| Component | Priority | Effort |
|-----------|----------|--------|
| Activity Timeline UI | P1 | Medium |
| @Mention Autocomplete | P1 | Medium |
| Notification Bell | P1 | Small |
| Approval Panel/Modal | P1 | Medium |
| Change Log Viewer | P2 | Medium |
| Email Notifications | P2 | Medium |
| Notification Preferences | P3 | Small |

---

## Implementation Tasks

### Sprint 1: Core UI Components

#### Task 1.1: Activity Timeline Component
**File:** `src/components/planning/collaboration/ActivityTimeline.tsx`

Display plan activity history from `plan_activity_log` table.

**Features:**
- Chronological feed with relative timestamps
- Action icons per type (commented, approved, updated, etc.)
- User avatars with role badges
- Filter by action type
- Filter by user
- Expandable details for complex actions
- "Load more" pagination

**Data Source:** `plan_activity_log` table via new hook `usePlanActivity.ts`

**UI Pattern:**
```
┌─────────────────────────────────────┐
│ Activity                    [Filter]│
├─────────────────────────────────────┤
│ 🔵 Laura Messing commented          │
│    "Great progress on the pipeline" │
│    2 minutes ago                    │
├─────────────────────────────────────┤
│ ✅ Anu Pradhan approved             │
│    "Ready for implementation"       │
│    1 hour ago                       │
├─────────────────────────────────────┤
│ ✏️ John Salisbury updated           │
│    Modified forecast bands          │
│    Yesterday                        │
└─────────────────────────────────────┘
```

---

#### Task 1.2: @Mention Autocomplete
**File:** `src/components/planning/collaboration/MentionInput.tsx`

Rich text input with @mention dropdown.

**Features:**
- Trigger on `@` character
- Dropdown with filtered CSE/CAM list
- Search by name
- Insert `@Name` into text
- Visual badge for mentions
- Extract mentions array for API

**Data Source:** Territory team from plan context

**UI Pattern:**
```
┌─────────────────────────────────────┐
│ Add a comment...                    │
│ Hey @An|                            │
│ ┌─────────────────────┐             │
│ │ 👤 Anu Pradhan (CAM)│             │
│ │ 👤 Andrew Smith     │             │
│ └─────────────────────┘             │
└─────────────────────────────────────┘
```

---

#### Task 1.3: Notification Bell Component
**File:** `src/components/planning/collaboration/NotificationBell.tsx`

Header notification icon with dropdown.

**Features:**
- Bell icon with unread count badge
- Dropdown with recent notifications
- Mark as read on view
- "Mark all as read" action
- Link to related plan/comment
- Empty state message

**Data Source:** `notifications` table via `useNotifications.ts` hook

---

#### Task 1.4: Approval Panel Component
**File:** `src/components/planning/collaboration/ApprovalPanel.tsx`

Modal/panel for approval workflow actions.

**Features:**
- Plan summary overview
- Approve button with confirmation
- Reject with required feedback textarea
- View change history during review
- Approver assignment (for submission)
- Status badge display

**API Integration:** `POST /api/planning/strategic/[id]/approve`

---

### Sprint 2: Enhanced Features

#### Task 2.1: Change Log Viewer
**File:** `src/components/planning/collaboration/ChangeLogViewer.tsx`

Display field-level changes from `plan_change_log`.

**Features:**
- Before/after value comparison
- Highlighted diff view
- Filter by field
- Filter by user
- Change reason display
- Timeline view

---

#### Task 2.2: Mention Highlighting
**File:** Update `CollaborationPanel.tsx`

Render @mentions as styled badges in comment text.

**Features:**
- Parse `@Name` in comment content
- Render as clickable badge
- Show user tooltip on hover
- Link to user profile (future)

---

#### Task 2.3: useNotifications Hook
**File:** `src/hooks/useNotifications.ts`

Hook for notification management.

**Features:**
- Fetch user notifications
- Real-time updates via Supabase
- Mark as read
- Delete notification
- Unread count

---

### Sprint 3: Polish & Integration

#### Task 3.1: Email Notifications
**Files:**
- `src/app/api/notifications/send/route.ts`
- `src/lib/email-templates/`

Send email on key events.

**Triggers:**
- @mentioned in comment
- Plan submitted for approval
- Plan approved/rejected
- Comment on your entity

---

#### Task 3.2: Notification Preferences
**File:** `src/components/settings/NotificationPreferences.tsx`

User settings for notification control.

**Options:**
- Email notifications on/off
- In-app notifications on/off
- Digest frequency (immediate/daily/weekly)
- Per-type toggles

---

## Component Architecture

```
src/components/planning/collaboration/
├── index.ts                    # Exports
├── ActivityTimeline.tsx        # Task 1.1
├── ActivityItem.tsx            # Sub-component
├── MentionInput.tsx            # Task 1.2
├── MentionDropdown.tsx         # Sub-component
├── NotificationBell.tsx        # Task 1.3
├── NotificationList.tsx        # Sub-component
├── ApprovalPanel.tsx           # Task 1.4
├── ApprovalConfirmDialog.tsx   # Sub-component
├── ChangeLogViewer.tsx         # Task 2.1
└── ChangeLogDiff.tsx           # Sub-component

src/hooks/
├── usePlanActivity.ts          # New hook for activity log
└── useNotifications.ts         # New hook for notifications
```

---

## Integration Points

### Strategic Plan Page (`/planning/strategic/[id]`)
- Add `NotificationBell` to header
- Add `ActivityTimeline` to CollaborationPanel tabs
- Replace comment input with `MentionInput`
- Add `ApprovalPanel` trigger button for reviewers

### Plan List Page (`/planning`)
- Show unread notification badge on plan cards
- Filter by "Needs my approval"

---

## Testing Plan

### Unit Tests
- [ ] ActivityTimeline renders correctly
- [ ] MentionInput extracts mentions array
- [ ] NotificationBell shows correct count
- [ ] ApprovalPanel validates rejection feedback

### Integration Tests
- [ ] Comment with @mention creates notification
- [ ] Approval workflow state transitions
- [ ] Real-time activity updates

### E2E Tests
- [ ] Full approval workflow
- [ ] Comment threading with mentions
- [ ] Notification mark as read

---

## Success Criteria

- [ ] Users can see who else is viewing/editing the plan
- [ ] Comments support @mentions with notifications
- [ ] Activity timeline shows all plan changes
- [ ] Approval workflow is fully functional in UI
- [ ] Change history is viewable during review
- [ ] Notifications appear in real-time

