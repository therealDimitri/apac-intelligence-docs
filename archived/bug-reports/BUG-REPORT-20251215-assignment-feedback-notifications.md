# Bug Report: Assignment Feedback & Notification Visibility

**Date**: 15 December 2025
**Reporter**: Claude Code
**Status**: Resolved
**Severity**: Medium (UX improvement)

## Issue Summary

Users reported several concerns after using the multi-client assignment feature from the Priority Matrix:

1. **Assignments not appearing in Actions page** - By design (see explanation below)
2. **No visibility into notification status** - Fixed
3. **What do Teams/Email messages say?** - Documented below
4. **Are assignments timestamped?** - Now displayed in UI

## Root Cause Analysis

### Why Assignments Don't Appear in Actions Page (FIXED)

**Original Issue**: The multi-client assignment from Priority Matrix only updated `clients.cse_name` but didn't create action records.

**Solution Implemented**: The bulk assignment API now creates action records by default:

| Feature             | Data Source                    | Purpose                                 |
| ------------------- | ------------------------------ | --------------------------------------- |
| **Actions Page**    | `actions` table                | Task records with specific action items |
| **Bulk Assignment** | `clients.cse_name` + `actions` | Client ownership AND action records     |

**Now when you assign from Priority Matrix**:

1. The `clients.cse_name` field is updated (client ownership)
2. An action record is created in the `actions` table (visible in Actions page)
3. The action includes: assignee, client name, due date (2 weeks default), priority, and assignment notes

**Action Record Details**:

- **Action_ID**: Auto-generated unique ID (e.g., `ACT-M5X7K2-ABC123`)
- **Status**: "To Do"
- **Due Date**: 2 weeks from assignment (default) or specified date
- **Priority**: Medium (default) or specified priority
- **Notes**: Includes who assigned it and when

### Notification Status Not Visible

**Before**: Notifications were fire-and-forget with only console logging
**After**: Toast notification now shows:

- Success/failure count per client
- Teams notification status (sent/skipped/failed)
- Email notification status (sent/skipped/failed/queued)
- Assignment timestamp

## What Notifications Contain

### Teams Message (via Webhook)

When `TEAMS_WEBHOOK_URL` is configured, the Teams message includes:

- Event description/title
- Assigned owner name
- Client name
- Due date (if provided)
- Priority level
- Event category (action/meeting)
- Link to dashboard

**Note**: Teams notifications require the `TEAMS_WEBHOOK_URL` environment variable.

### Email Message

When `GRAPH_ACCESS_TOKEN` is configured, a styled HTML email is sent:

**Subject**: `📋 You've been assigned: {Event Title}` or `📅 You've been assigned: {Event Title}`

**Body includes**:

- Purple gradient header with "You've Been Assigned"
- Priority badge (colour-coded: red=critical, amber=high, blue=medium, grey=low)
- Event title
- Details table: Client, Due Date, Assigned By
- Custom message (if provided by assigner)
- "View in Dashboard" button linking to `/actions` or `/meetings`
- Footer with dashboard link

**Note**: Email notifications require the `GRAPH_ACCESS_TOKEN` environment variable. If not configured, emails are logged for manual sending.

## Solution Implemented

### 1. Enhanced API Response

Updated `/api/assignment/bulk/route.ts` to:

1. Create action records in the `actions` table
2. Return detailed notification status and action ID

**Request Schema**:

```typescript
{
  clientName: string,
  assigneeName: string,
  assigneeEmail: string | null,
  eventTitle: string,
  eventType: 'action' | 'meeting' | 'compliance',
  notifyTeams: boolean,    // default: true
  notifyEmail: boolean,    // default: false
  assignedBy: string,
  assignedByEmail?: string,
  createAction: boolean,   // NEW: default true - creates action record
  dueDate?: string | null, // NEW: optional due date for action
  priority: 'Critical' | 'High' | 'Medium' | 'Low', // NEW: default Medium
}
```

**Response Schema**:

```typescript
{
  success: true,
  message: `${clientName} assigned to ${assigneeName}`,
  assignment: {
    clientId: clientData.id,
    clientName,
    assigneeName,
    eventTitle,
    previousOwner: clientData.cse_name,
    assignedAt,     // ISO timestamp
    assignedBy,
    actionId,       // NEW: ID of created action record
  },
  notifications: {
    teamsStatus: 'sent' | 'skipped' | 'failed',
    teamsError?: string,
    emailStatus: 'sent' | 'skipped' | 'failed' | 'queued',
    emailError?: string,
  },
}
```

### 2. New AssignmentToast Component

Created `src/components/assignment/AssignmentToast.tsx` that displays:

- Success/failure summary with icons
- **Actions created count** (NEW)
- Teams notification status
- Email notification status
- Assignment timestamp
- List of clients assigned (for 5 or fewer)
- Auto-closes after 10 seconds with progress bar

### 3. Updated Dashboard Integration

Modified `ActionableIntelligenceDashboard.tsx` to:

- Track assignment results from each API call
- Display toast notification after assignments complete
- Show timestamp of when assignment was made

## Files Modified

| File                                                 | Change                                    |
| ---------------------------------------------------- | ----------------------------------------- |
| `src/app/api/assignment/bulk/route.ts`               | Added notification tracking and timestamp |
| `src/components/assignment/AssignmentToast.tsx`      | New component for feedback                |
| `src/components/assignment/index.ts`                 | Export new component                      |
| `src/components/ActionableIntelligenceDashboard.tsx` | Toast state and display                   |

## Environment Variables

For notifications to work, ensure these are configured:

| Variable              | Purpose                                     |
| --------------------- | ------------------------------------------- |
| `TEAMS_WEBHOOK_URL`   | Microsoft Teams incoming webhook URL        |
| `GRAPH_ACCESS_TOKEN`  | Microsoft Graph API access token for emails |
| `NEXT_PUBLIC_APP_URL` | Dashboard URL for notification links        |

## Testing Checklist

- [x] TypeScript compilation passes
- [x] Toast displays after multi-client assignment
- [x] Toast shows correct success/failure count
- [x] Toast shows Teams notification status
- [x] Toast shows Email notification status
- [x] Toast shows assignment timestamp
- [x] Toast auto-closes after 10 seconds
- [x] Toast can be manually dismissed

## Recommendations

1. **For Actions Page visibility**: If users want assignments to appear as action items, consider creating a new feature that:
   - Creates action records when assigning from Priority Matrix
   - Links actions to specific compliance events

2. **Configure notifications**: Ensure `TEAMS_WEBHOOK_URL` and `GRAPH_ACCESS_TOKEN` are set in production for notifications to work.

3. **Audit logging**: Consider adding a dedicated `assignment_audit` table to track all assignment history with timestamps.
