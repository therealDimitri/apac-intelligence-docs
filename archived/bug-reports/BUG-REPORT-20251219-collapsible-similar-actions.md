# Feature Report: Collapsible Similar Actions

## Date

19 December 2025

## Issue Summary

The Actions page displayed many duplicate action types assigned to different clients, taking up significant vertical space. For example, "Schedule engagement meetings" appeared 7 times for different clients, each taking ~56px of height.

## Symptoms

- Similar actions repeated for different clients (e.g., "Schedule engagement meetings - [Client]")
- 7+ rows for what is essentially the same action type
- Difficult to see the variety of action types at a glance
- Scrolling required to see all action categories

## Analysis

Common repeated action patterns identified:

- "Schedule engagement meetings" - 7 instances
- "Schedule Insight Touch Point events" - 4 instances
- "Health Check (Opal) - opportunity to accelerate progress" - 2 instances

## Solution

Implemented collapsible similar action groups that automatically detect and group actions with similar titles.

### Features Added

1. **Action Type Extraction**
   - Extracts base action type from titles by splitting on common separators (`-`, `–`, `—`, `: `)
   - e.g., "Schedule engagement meetings - Barwon Health Australia" → "Schedule engagement meetings"

2. **Smart Grouping**
   - Only groups actions with 2+ similar titles
   - Unique actions remain as individual rows
   - Groups sorted by earliest due date

3. **Collapsible Group Headers**
   - Shows action type, client count, owner count, completion progress
   - Purple left border indicates grouped actions
   - Red/orange indicator for critical or overdue items
   - Click to expand/collapse

4. **Group Similar Toggle**
   - New "Group Similar" toggle button in toolbar
   - Enabled by default for space savings
   - Can be disabled to see flat list

### UI Components

**Collapsed Group Row:**

```
┌──────────────────────────────────────────────────────────────────────┐
│ ▶ ● Schedule engagement meetings           🎯 7 clients  👤 3  ✓ 2/7 │
└──────────────────────────────────────────────────────────────────────┘
```

**Expanded Group:**

```
┌──────────────────────────────────────────────────────────────────────┐
│ ▼ ● Schedule engagement meetings           🎯 7 clients  👤 3  ✓ 2/7 │
├──────────────────────────────────────────────────────────────────────┤
│     ☐ ○ Schedule engagement meetings - SA Health     📅 12/31  open  │
│     ☐ ○ Schedule engagement meetings - Barwon He..   📅 12/31  open  │
│     ☐ ○ Schedule engagement meetings - Epworth ..    📅 12/31  open  │
│     ... (more items)                                                  │
└──────────────────────────────────────────────────────────────────────┘
```

## Files Modified

1. `src/app/(dashboard)/actions/page.tsx`
   - Added imports: `ChevronDown`, `Layers`
   - Added `extractActionType()` helper function
   - Added `ActionGroup` interface
   - Added `groupSimilarActions()` function
   - Added `getUngroupedActions()` function
   - Added `groupSimilar` and `expandedGroups` state
   - Added `toggleGroupExpanded()` function
   - Added `CollapsibleActionGroup` component
   - Added "Group Similar" toggle button in toolbar
   - Updated Outstanding, Completed, Cancelled, and List view sections to use grouped rendering

## Technical Details

### Action Type Extraction Logic

```typescript
const extractActionType = (title: string): string => {
  const separators = [' - ', ' – ', ' — ', ': ']
  for (const sep of separators) {
    const idx = title.indexOf(sep)
    if (idx > 0) {
      return title.substring(0, idx).trim()
    }
  }
  return title
}
```

### Grouping Threshold

- Minimum 2 actions required to form a group
- Single-occurrence action types remain as individual rows

### Group Metadata

Each group calculates:

- `totalOwners`: Unique owners across all actions in group
- `earliestDueDate`: Soonest due date in the group
- `hasOverdue`: Boolean if any action is overdue
- `hasCritical`: Boolean if any action is critical priority

## Testing

- Build passes with no TypeScript errors
- Grouping toggle works correctly
- Groups expand and collapse properly
- Individual actions remain accessible within groups
- Works in both Status View and List View

## Space Savings

| Scenario           | Before           | After (Collapsed) |
| ------------------ | ---------------- | ----------------- |
| 7 similar actions  | 7 rows (~392px)  | 1 row (~56px)     |
| 4 similar actions  | 4 rows (~224px)  | 1 row (~56px)     |
| Total screen usage | ~20 rows visible | ~40+ rows visible |

## Prevention

- Consider grouping/consolidation patterns when displaying repetitive data
- Provide toggle options for users who prefer different views
- Use progressive disclosure to balance information density with clarity

## Commits

- Pending commit for collapsible similar actions feature
