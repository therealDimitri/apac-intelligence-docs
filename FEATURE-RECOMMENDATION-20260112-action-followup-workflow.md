# Feature Recommendation: Action-to-Followup Workflow

**Date:** 2026-01-12
**Type:** Feature Enhancement
**Status:** Recommendation

## Executive Summary

Users need an easy way to create follow-up actions from:
1. **Alert-driven actions** - When an alert becomes an action, the owner often needs to create multiple detailed follow-up tasks
2. **Existing actions** - Any action may spawn follow-up tasks during its lifecycle

The codebase already has the infrastructure to support this. This document recommends how to surface these capabilities in the UI.

---

## Current State Assessment

### ✅ What Already Exists

| Component | Status | Location |
|-----------|--------|----------|
| Parent-child action relations | Implemented | `action_relations` table |
| Relations API (CRUD) | Implemented | `/api/actions/[id]/relations` |
| Source tracking (alert → action) | Implemented | `source_alert_id`, `source_metadata` |
| Related actions UI | Implemented | `RelatedActions.tsx` |
| Activity logging | Implemented | `action_activity_log` table |
| Bidirectional alert sync | Implemented | Action status → Alert status |

### ❌ What's Missing

| Component | Status | Priority |
|-----------|--------|----------|
| "Create Follow-up" button in action detail | Not built | High |
| Follow-up indicator on parent action | Not built | High |
| Follow-up source type | Not defined | Medium |
| Follow-up chain visualisation | Not built | Low |
| Automatic follow-up scheduling | Not built | Low |

---

## Recommended Workflow

### Use Case 1: Alert-to-Action Follow-ups

```
┌─────────────────────────────────────────────────────────────────┐
│  Alert: "Health score dropped below 70 for ACME Corp"           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ Create Action
┌─────────────────────────────────────────────────────────────────┐
│  Action: "Investigate ACME Corp health decline"                 │
│  Source: Alert                                                   │
│  Status: In Progress                                             │
│  [+ Create Follow-up] button visible                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ User clicks "Create Follow-up"
┌─────────────────────────────────────────────────────────────────┐
│  Follow-up Action (pre-filled):                                 │
│  - Client: ACME Corp (inherited)                                │
│  - Owner: Current user (inherited)                              │
│  - Title: "Follow-up: Investigate ACME Corp health decline"     │
│  - Notes: Links to parent action                                │
│  - Source: action_followup                                       │
└─────────────────────────────────────────────────────────────────┘
```

### Use Case 2: Action-to-Action Follow-ups

```
┌─────────────────────────────────────────────────────────────────┐
│  Action: "Conduct quarterly review with ACME"                   │
│  Status: Completed ✓                                            │
│  [+ Create Follow-up] button visible                            │
│                                                                  │
│  Related Actions:                                                │
│  ├─ [Reminder] Schedule follow-up call in 2 weeks              │
│  └─ [Action Item] Send meeting notes to stakeholders           │
└─────────────────────────────────────────────────────────────────┘
```

---

## Recommended Implementation

### Phase 1: Add "Create Follow-up" Button (High Priority)

**Location:** Action Detail Modal / Panel

**Button Behaviour:**
1. Opens `ActionQuickCreate` modal
2. Pre-fills context from parent action:
   - Client (inherited)
   - Owner (inherited)
   - Title prefix: "Follow-up: [original title]"
   - Notes: "Follow-up from: [link to parent action]"
3. Sets source: `ActionSource.ACTION_FOLLOWUP` (new enum value)
4. Sets source_metadata:
   ```json
   {
     "parentActionId": "ACT-2025-001",
     "parentActionTitle": "Original action title",
     "followupReason": "user_initiated"
   }
   ```
5. On submit, automatically creates `child_of` relation

**Implementation Steps:**
```typescript
// 1. Add new source type to ActionSource enum
export enum ActionSource {
  // ...existing
  ACTION_FOLLOWUP = 'action_followup',
}

// 2. Add createFollowupContext helper
export function createFollowupContext(parentAction: Action): QuickCreateContext {
  return {
    title: `Follow-up: ${parentAction.title}`,
    client: parentAction.client,
    notes: `Follow-up from action: ${parentAction.title}`,
    owners: parentAction.owners,
    source: ActionSource.ACTION_FOLLOWUP,
    sourceMetadata: {
      parentActionId: parentAction.id,
      parentActionTitle: parentAction.title,
    },
  }
}

// 3. After creation, link as child
await linkActions(parentAction.id, newAction.id, 'child_of')
```

### Phase 2: Visual Indicators (High Priority)

**On Parent Action Card:**
- Badge: "Has 2 follow-ups" (count of child actions)
- Expandable section showing follow-up status

**On Follow-up Action Card:**
- Badge: "Follow-up" with link icon
- Source badge: Shows it came from another action
- Click "View Parent" to navigate

**Implementation:**
```typescript
// Add to action card component
{action.childActions?.length > 0 && (
  <Badge variant="info">
    {action.childActions.length} follow-up{action.childActions.length > 1 ? 's' : ''}
  </Badge>
)}

{action.parentActionId && (
  <Badge variant="secondary">
    <Link to={`/actions/${action.parentActionId}`}>
      ↑ View Parent
    </Link>
  </Badge>
)}
```

### Phase 3: Follow-up Templates (Medium Priority)

Common follow-up patterns:
- "Schedule follow-up call"
- "Send meeting notes"
- "Check on progress"
- "Escalate if unresolved"

```typescript
const FOLLOWUP_TEMPLATES = [
  {
    label: 'Schedule Follow-up Call',
    titlePrefix: 'Call: ',
    defaultDueDays: 7,
  },
  {
    label: 'Send Meeting Notes',
    titlePrefix: 'Notes: ',
    defaultDueDays: 1,
  },
  // ...
]
```

### Phase 4: Follow-up Chain Visualisation (Low Priority)

A visual timeline showing:
```
Alert → Action → Follow-up 1 → Follow-up 2
                      ↓
               Sub-task A
```

---

## Database Changes Required

### Option A: Use Existing Infrastructure (Recommended)
- No schema changes needed
- Use `action_relations` with `parent_of`/`child_of`
- Use `source_metadata` for context
- Add new `ActionSource.ACTION_FOLLOWUP` enum value

### Option B: Add Dedicated Column (Not Recommended)
```sql
-- Only if we need faster queries
ALTER TABLE actions ADD COLUMN parent_action_id TEXT REFERENCES actions(Action_ID);
```

**Recommendation:** Start with Option A. The existing relations table is designed for this use case and provides flexibility for multiple parent-child relationships.

---

## UI Mockup

### Action Detail Header with Follow-up Button
```
┌──────────────────────────────────────────────────────────────────────┐
│ ← Back                                                               │
│                                                                      │
│ ┌────────────────┬────────────────────────────────────────────────┐  │
│ │ 🎯 Action      │ Investigate ACME Corp health decline           │  │
│ │                │ ──────────────────────────────────────────────│  │
│ │ From Alert    │ Source: Health Alert • Created 2 days ago      │  │
│ └────────────────┴────────────────────────────────────────────────┘  │
│                                                                      │
│ [Edit] [+ Create Follow-up ▾]  [Complete] [Cancel]                  │
│              │                                                       │
│              ├── Quick Follow-up (same settings)                    │
│              ├── Schedule Reminder                                   │
│              └── Custom Follow-up...                                │
│                                                                      │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ 📋 Follow-ups (2)                                               │ │
│ │ ├─ ○ Schedule follow-up call (Due: 15 Jan)                     │ │
│ │ └─ ✓ Send meeting notes (Completed)                            │ │
│ └─────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Implementation Effort Estimate

| Phase | Effort | Dependencies |
|-------|--------|--------------|
| Phase 1: Create Follow-up Button | 2-3 hours | ActionQuickCreate, relations API |
| Phase 2: Visual Indicators | 2-3 hours | Action card components |
| Phase 3: Follow-up Templates | 3-4 hours | None |
| Phase 4: Chain Visualisation | 6-8 hours | D3.js or similar |

**Recommended starting point:** Phase 1 + Phase 2 (4-6 hours total)

---

## How to Identify Follow-up Scenarios

### On the Action Card/List

1. **From Alert Badge:** Show "From Alert" badge with alert ID
2. **Has Follow-ups Badge:** Show count of child actions
3. **Is Follow-up Badge:** Show "↑ Follow-up" with parent link

### In the Action Detail

1. **Source Section:** Show full source chain (Alert → Action → Follow-up)
2. **Related Actions:** Group by relationship type with "Follow-ups" as primary section
3. **Activity Log:** Show "Follow-up created" entries

---

## Next Steps

1. **Confirm approach** with stakeholders
2. **Implement Phase 1** - Add "Create Follow-up" button to action detail
3. **Implement Phase 2** - Add visual indicators for follow-up relationships
4. **User testing** - Validate the workflow meets user needs
5. **Iterate** - Add templates and visualisation based on feedback

---

## Related Documentation

- `/docs/design/UNIFIED-ACTIONS-SYSTEM-DESIGN.md` - Overall actions architecture
- `/docs/features/FEATURE-20251231-alert-to-action-automation.md` - Alert-to-action flow
- `/src/types/unified-actions.ts` - Type definitions
- `/src/hooks/useRelatedActions.ts` - Relations hook
