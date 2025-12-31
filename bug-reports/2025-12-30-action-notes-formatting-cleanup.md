# Bug Report: Action Notes Formatting Cleanup

**Date:** 30 December 2025
**Severity:** Low (UI/Display)
**Status:** Resolved

## Problem Description

Action cards in the Priority Matrix, Actions page, and Kanban board were displaying raw internal metadata in their descriptions and notes fields. This included:

- `📋 ASSIGNMENT INFO` blocks
- Triple-dash separators (`---`)
- Raw `Assigned by:`, `Assigned on:`, and `Source:` metadata lines
- Malformed concatenated strings from multiple assignment operations

### Example of Bad Formatting

```
📋 ASSIGNMENT INFO
---
Assigned by: Dimitri Leimonitis
Assigned on: Wed, 17 Dec 2025, 09:28 am
Source: Priority Matrix (Bulk)
Client: SA Health (iQemo)
---
Action created from action event assignment.
```

## Root Cause

1. The bulk assignment API (`/api/assignment/bulk/route.ts`) was storing detailed audit metadata directly in the `Notes` field
2. Over time, some actions accumulated multiple metadata blocks from re-assignments
3. The `cleanDescription()` utility was created but not retroactively applied to existing records

## Solution

### 1. Display Layer Fix (Already Applied)

Created `cleanDescription()` utility in `src/utils/actionUtils.ts` to strip metadata from display:

```typescript
export function cleanDescription(description: string | undefined | null): string | undefined {
  if (!description) return undefined

  const cleaned = description
    .replace(/📋\s*ASSIGNMENT INFO[\s\S]*?(?:Action created from.*?\.|\n-{3,})/gi, '')
    .replace(/^-{3,}$/gm, '')
    .replace(/Assigned by:.*$/gm, '')
    .replace(/Assigned on:.*$/gm, '')
    .replace(/Source:.*$/gm, '')
    .replace(/\n{3,}/g, '\n\n')
    .trim()

  return cleaned.length > 0 ? cleaned : undefined
}
```

### 2. Database Backfill (Applied 30 Dec 2025)

Created and ran `scripts/cleanup-action-notes-final.mjs` to update all 52 affected actions:

- **First pass:** 48 actions cleaned
- **Second pass:** 4 remaining actions with malformed data cleaned
- **Final state:** 0 actions with old formatting

New format: `Created from {Category} on {Date}.`

Example: `Created from Priority Matrix on Mon, 29 Dec 2025, 03:08 am.`

### 3. API Prevention

The bulk assignment API now generates clean notes from the start:

```typescript
Notes: `Created from ${eventType} event by ${assignedBy} on ${formattedDate}.`,
```

## Files Modified

| File | Change |
|------|--------|
| `src/utils/actionUtils.ts` | Added `cleanDescription()` utility |
| `src/components/unified-actions/UnifiedActionCard.tsx` | Uses cleaned description |
| `src/app/(dashboard)/actions/page.tsx` | Uses cleaned description |
| `src/components/KanbanBoard.tsx` | Uses cleaned description |
| `src/app/api/assignment/bulk/route.ts` | Generates clean notes format |
| Database: `actions.Notes` | 52 records backfilled |

## Testing

1. Priority Matrix - action cards show clean descriptions
2. Actions page - all actions display without metadata blocks
3. Kanban board - cards show clean format
4. New assignments - create clean notes format

## Prevention

- All new actions created via assignment API use clean format
- Display components use `cleanDescription()` as defensive fallback
- Script retained at `scripts/cleanup-action-notes-final.mjs` for future use if needed
