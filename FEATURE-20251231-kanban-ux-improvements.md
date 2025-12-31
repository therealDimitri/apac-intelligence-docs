# Feature: Kanban Board & Action Modal UX Improvements

**Date:** 31 December 2025
**Version:** 1.1
**Status:** Implemented
**Components:** KanbanBoard.tsx, actions/page.tsx, actionUtils.ts, useActions.ts, CreateActionModal.tsx, EditActionModal.tsx

## Overview

A comprehensive set of UX improvements to the Actions & Tasks system, including Kanban board interaction patterns, visual consistency, data display quality, and streamlined action modal layouts.

## Changes Implemented

### 1. Drag Handle & Checkbox Coexistence

**Problem:** The batch selection checkbox completely replaced the drag handle on hover, making it impossible to drag cards between columns.

**Solution:** Implemented a side-by-side layout pattern (following Linear/Asana conventions):

```
Before:                          After:
┌──────────────────┐            ┌──────────────────┐
│ ⋮⋮  Title        │  (normal)  │    ⋮⋮  Title     │  (drag handle 40% opacity)
└──────────────────┘            └──────────────────┘

┌──────────────────┐            ┌──────────────────┐
│ ☐   Title        │  (hover)   │ ⋮⋮ ☐  Title      │  (both visible, handle 100%)
└──────────────────┘            └──────────────────┘
```

**Technical Implementation:**
- Drag handle always rendered with variable opacity (`opacity-40` → `opacity-100` on hover)
- Checkbox conditionally rendered alongside (not replacing) the drag handle
- Container uses `flex items-center gap-1` for horizontal alignment

### 2. Smooth Transitions Without Layout Shift

**Problem:** `transition-all` CSS class caused the entire card to animate when elements appeared/disappeared, creating visual jitter.

**Solution:** Replaced with specific transition properties:

```typescript
// Before
className="... transition-all ..."

// After
className="... transition-shadow transition-colors ..."
```

Also removed `scale-105` from the dragging state to prevent card size animation.

### 3. Full Owner Names with Profile Photos

**Problem:** Cards only displayed first names for owners, making it difficult to identify team members.

**Solution:**
- Display full owner names using `getDisplayOwnerName()` instead of `getFirstName()`
- Added `EnhancedAvatar` component with CSE profile photos
- Falls back to initials when no photo available
- Increased owner column width from 70px to 140px

**Component Integration:**
```typescript
// Props passed through component chain
KanbanBoard → DroppableColumn → DraggableCard
  - getPhotoURL: (name: string) => string | null
  - getDisplayName: (canonicalName: string) => string
```

### 4. Done Count Shows Total Completed

**Problem:** "Completed This Week" stat showed 0 when no actions were completed in the current week, confusing users expecting to see total completed.

**Solution:** Changed stat display to show total completed:

```typescript
// Before
{ label: 'Completed This Week', value: stats.completedThisWeek }

// After
{ label: 'Done', value: stats.completed }
```

**Changes to ActionStats interface:**
```typescript
export interface ActionStats {
  open: number
  inProgress: number
  overdue: number
  completed: number      // Added
  completedThisWeek: number
}
```

### 5. HTML Markup Stripping in Descriptions

**Problem:** Some action descriptions contained raw HTML tags (`<p>`, `<br>`, `<div>`) that displayed as literal text.

**Solution:** Enhanced `cleanDescription()` utility to:
- Strip all HTML tags: `/<[^>]*>/g`
- Decode common HTML entities: `&nbsp;`, `&amp;`, `&lt;`, `&gt;`, `&quot;`, `&#39;`
- Collapse multiple spaces to single space

### 6. Removed Duplicate Toast Notifications

**Problem:** Toast notifications appeared at both top-right and bottom-right of the screen.

**Solution:** Removed `<Toaster />` from dashboard layout, keeping only the root layout instance.

### 7. Removed Bulk "Select All" Prompt

**Problem:** A permanent "Select all 157 actions" button was displayed, risking accidental bulk operations.

**Solution:** Removed the always-visible bulk select prompt from the actions page. Users can still use column-level "select all" in Kanban view.

### 8. Action Modal Layout Cleanup

**Problem:** Both Create and Edit action modals had cluttered layouts with:
- Dynamic categories dropdown pulling from database (inconsistent options)
- "Internal Operations" section heading taking up space
- "Internal Operations Work" checkbox rarely used
- Fields in suboptimal order for typical workflow
- Due Date and Priority on separate lines

**Solution:** Streamlined both modals with identical layouts:

```
New Field Order:
┌─────────────────────────────────────────────────┐
│ Title *                                         │
├─────────────────────────────────────────────────┤
│ Description / Notes (with @mentions)            │
├───────────────┬───────────────┬─────────────────┤
│ Due Date *    │ Priority *    │ Status *        │  ← 3-column grid
├───────────────┴───────────────┴─────────────────┤
│ Department                                      │
├─────────────────────────────────────────────────┤
│ Clients                                         │
├─────────────────────────────────────────────────┤
│ Owners                                          │
├─────────────────────────────────────────────────┤
│ Activity Type                                   │
├─────────────────────────────────────────────────┤
│ Categories (multi-select pills)                 │
├─────────────────────────────────────────────────┤
│ ☐ Cross-Functional Collaboration               │
└─────────────────────────────────────────────────┘
```

**Technical Implementation:**

1. **Fixed Categories List:**
```typescript
const CATEGORY_OPTIONS = [
  '360 Update',
  'Client Success',
  'Meeting',
  'Meeting Follow-Up',
  'NPS',
  'NPS Actions',
  'Planning',
]
```

2. **Removed Components:**
   - `useCategoryDropdown()` hook (replaced with static list)
   - `ClientImpactSelector` component
   - `Briefcase` and `Users2` icons
   - "Internal Operations" section heading
   - "Internal Operations Work" checkbox

3. **Layout Changes:**
   - Due Date, Priority, Status in `grid grid-cols-3 gap-4`
   - Department moved above Clients
   - Activity Type moved before Categories
   - Cross-Functional toggle at end (kept as useful feature)

## Files Modified

| File | Changes |
|------|---------|
| `src/components/KanbanBoard.tsx` | Drag/checkbox layout, transitions, owner display |
| `src/app/(dashboard)/actions/page.tsx` | Stats display, bulk select removal, owner display |
| `src/app/(dashboard)/layout.tsx` | Removed duplicate Toaster |
| `src/hooks/useActions.ts` | Added `completed` to ActionStats |
| `src/utils/actionUtils.ts` | HTML stripping in cleanDescription() and stripHtml() |
| `src/components/CreateActionModal.tsx` | Layout reorganisation, fixed categories, removed Internal Ops section |
| `src/components/EditActionModal.tsx` | Layout reorganisation, fixed categories, removed Internal Ops section |

## UX Patterns Applied

1. **Side-by-side controls** - Following Linear/Asana pattern for drag + select
2. **Opacity transitions** - Subtle visual feedback without layout disruption
3. **Progressive disclosure** - Checkbox appears on hover, not always visible
4. **Fixed-width containers** - Prevent layout shift when elements appear

## Testing Checklist

- [x] Cards can be dragged while checkbox is visible
- [x] No layout shift when hovering over cards
- [x] Full owner names display with profile photos
- [x] "Done" shows total completed count
- [x] HTML tags stripped from descriptions
- [x] Single toast notification location
- [x] No accidental bulk selection prompt
- [x] Create modal shows fixed category list
- [x] Edit modal shows fixed category list
- [x] Both modals have identical field order
- [x] Due Date, Priority, Status display on one row
- [x] No "Internal Operations" section heading
- [x] No "Internal Operations Work" checkbox

## Related Bug Reports

- `docs/bug-reports/BUG-REPORT-20251231-kanban-drag-checkbox-conflict.md`
- `docs/bug-reports/BUG-REPORT-20251231-done-count-and-html-markup.md`

## Future Modernisation Recommendations

Based on analysis of leading task management tools (Linear, Notion, Asana), these improvements could further enhance the action modal UX:

### Quick Wins (Low Effort)
1. **Inline Editing** - Click-to-edit fields instead of always-editable inputs
2. **Keyboard Shortcuts** - `⌘+Enter` to save, `Esc` to cancel
3. **Auto-save Draft** - Persist form state to localStorage on input
4. **Smart Defaults** - Pre-fill Priority based on client health score

### Medium Effort
1. **Slide-over Panel** - Replace modal with slide-in panel (no viewport blocking)
2. **Quick Actions Bar** - Common actions (duplicate, archive) in header
3. **Activity Timeline** - Show recent changes/comments inline
4. **Related Actions** - Link to other actions for same client

### Larger Initiatives
1. **Command Palette** - `⌘+K` to create/search actions from anywhere
2. **AI Suggestions** - ChaSen recommends owners, due dates, categories
3. **Templates** - Save common action patterns as reusable templates
4. **Bulk Quick-Edit** - Edit multiple selected actions at once
