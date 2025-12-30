# Unified Actions System

**Version:** 1.0
**Last Updated:** 30 December 2025
**Status:** Production Ready

---

## Overview

The Unified Actions System provides a consistent, modern task management experience across the APAC Intelligence Hub. It consolidates actions from multiple sources (meetings, AI insights, manual creation) into a single, unified interface with real-time updates, keyboard shortcuts, and multiple view modes.

---

## Architecture

### Core Files

```
src/
├── types/
│   └── unified-actions.ts          # Type definitions, enums, interfaces
├── lib/actions/
│   └── unified-action-service.ts   # Business logic, API interactions
├── hooks/
│   └── useUnifiedActions.ts        # React hook for state management
│   └── useOptimisticActions.ts     # Optimistic updates hook
└── components/unified-actions/
    ├── index.ts                    # Barrel exports
    ├── ActionProvider.tsx          # Context provider
    ├── ActionInbox.tsx             # Main inbox view
    ├── ActionDetailPanel.tsx       # Side panel detail view
    ├── ActionQuickCreate.tsx       # Quick create modal
    ├── UnifiedActionCard.tsx       # Action card component
    ├── UnifiedContextMenu.tsx      # Right-click context menu
    ├── ActionBadges.tsx            # Status/priority badges
    ├── ActionViewSwitcher.tsx      # View mode toggle
    ├── VirtualisedActionList.tsx   # Performance-optimised list
    ├── KeyboardShortcuts.tsx       # Keyboard shortcuts handler
    ├── InsightActionButton.tsx     # Create action from insight
    └── UnifiedToast.tsx            # Toast notifications
```

---

## Features

### 1. Action Sources

Actions can be created from multiple sources:

| Source | Description | Auto-populated Fields |
|--------|-------------|----------------------|
| `MANUAL` | User-created via quick create | None |
| `MEETING` | Extracted from meeting notes | Client, meeting reference |
| `INSIGHT_ML` | ML-generated recommendations | Confidence, rationale |
| `INSIGHT_AI` | AI-powered insights | Source context, priority |
| `CHASEN` | ChaSen AI suggestions | Conversation context |
| `OUTLOOK` | Imported from Outlook | Calendar details |
| `EMAIL` | Email-derived actions | Sender, subject |

### 2. Action Status Workflow

```
NOT_STARTED → IN_PROGRESS → COMPLETED
                    ↓
               CANCELLED
```

### 3. Priority Levels

| Priority | Colour | Use Case |
|----------|--------|----------|
| Critical | Red | Urgent, time-sensitive |
| High | Orange | Important, needs attention |
| Medium | Blue | Standard priority |
| Low | Grey | Can be deferred |

### 4. View Modes

- **Inbox View**: Traditional list with grouping
- **Kanban View**: Board with status columns
- **Calendar View**: Timeline-based view
- **Priority Matrix**: Urgency vs importance grid

---

## Usage

### Basic Usage

```tsx
import { ActionProvider, ActionInbox } from '@/components/unified-actions'

function ActionsPage() {
  return (
    <ActionProvider>
      <ActionInbox />
    </ActionProvider>
  )
}
```

### Using the Hook

```tsx
import { useUnifiedActions } from '@/hooks/useUnifiedActions'

function MyComponent() {
  const {
    actions,
    create,
    update,
    complete,
    isLoading
  } = useUnifiedActions()

  const handleCreate = async () => {
    await create({
      title: 'Follow up with client',
      client: 'Epworth Healthcare',
      priority: ActionPriority.HIGH,
      source: ActionSource.MANUAL,
    })
  }

  return <button onClick={handleCreate}>Create Action</button>
}
```

### Creating from Insights

```tsx
import { InsightActionButton } from '@/components/unified-actions'

function InsightCard({ insight }) {
  return (
    <div>
      <h3>{insight.title}</h3>
      <InsightActionButton
        source={ActionSource.INSIGHT_ML}
        title={insight.title}
        description={insight.description}
        client={insight.client}
        suggestedPriority={ActionPriority.HIGH}
        variant="compact"
      />
    </div>
  )
}
```

---

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `N` | Create new action |
| `Enter` | Open selected action |
| `E` | Edit selected action |
| `C` | Mark as completed |
| `I` | Mark as in progress |
| `1-4` | Set priority (1=Critical) |
| `D` | Delete (with confirm) |
| `↑/↓` | Navigate list |
| `Esc` | Close panel/modal |
| `?` | Show shortcuts help |

---

## API Endpoints

### Actions CRUD

```
GET    /api/actions                    # List all actions
POST   /api/actions                    # Create action
GET    /api/actions/:id               # Get single action
PATCH  /api/actions/:id               # Update action
DELETE /api/actions/:id               # Delete action
```

### Bulk Operations

```
POST   /api/actions/bulk              # Bulk status update
DELETE /api/actions/bulk              # Bulk delete
```

### Filters & Search

```
GET /api/actions?status=in_progress
GET /api/actions?priority=high
GET /api/actions?client=Epworth
GET /api/actions?source=meeting
GET /api/actions?assignee=user@email.com
GET /api/actions?q=search+term
```

---

## Database Schema

### `actions` Table

| Column | Type | Description |
|--------|------|-------------|
| `id` | uuid | Primary key |
| `title` | text | Action title |
| `notes` | text | Detailed notes |
| `client` | text | Client name |
| `client_id` | int4 | Client FK (optional) |
| `status` | text | Status enum |
| `priority` | text | Priority enum |
| `source` | text | Source enum |
| `source_metadata` | jsonb | Source-specific data |
| `due_date` | timestamptz | Due date |
| `completed_at` | timestamptz | Completion timestamp |
| `Owners` | text[] | Assigned users |
| `created_at` | timestamptz | Creation timestamp |
| `updated_at` | timestamptz | Last update |
| `created_by` | text | Creator email |

---

## Context Menu

Right-click any action to access:

1. **Quick Actions Bar**: Start, Complete, Duplicate
2. **Status Submenu**: Change status
3. **Priority Submenu**: Change priority
4. **Assign to...**: Assign to team member
5. **Set Reminder**: Add reminder
6. **Link to Meeting**: Associate with meeting
7. **Add to Initiative**: Link to portfolio initiative
8. **Delete**: Remove action

---

## Integration Points

### With ChaSen AI

```tsx
// ChaSen can create actions via conversation
const { createFromChaSen } = useInsightActionCreation()

createFromChaSen({
  title: 'Schedule QBR with client',
  client: 'Epworth Healthcare',
  conversationId: 'conv-123',
  notes: 'Discussed in ChaSen session',
})
```

### With Priority Matrix

Actions integrate with the Priority Matrix for visual prioritisation:

```tsx
// Actions appear in appropriate quadrant based on priority
const quadrant = getMatrixQuadrant(action.priority, action.dueDate)
```

### With Meeting Notes

Meeting transcripts can automatically extract action items:

```tsx
// Extracted actions are pre-populated with context
const meetingActions = extractActionsFromTranscript(transcript)
```

---

## Performance Optimisations

1. **Virtualised Lists**: `VirtualisedActionList` renders only visible items
2. **Optimistic Updates**: Immediate UI feedback, background sync
3. **Debounced Search**: 300ms debounce on search input
4. **Memoised Components**: React.memo on expensive renders
5. **Lazy Loading**: Detail panel loads on demand

---

## Error Handling

```tsx
const { error, retry } = useUnifiedActions()

if (error) {
  return (
    <ErrorState
      message={error.message}
      onRetry={retry}
    />
  )
}
```

---

## Related Documentation

- [Database Schema](../database-schema.md)
- [API Reference](../api/actions.md)
- [Component Library](../components/unified-actions.md)
- [Priority Matrix](./PRIORITY-MATRIX.md)
