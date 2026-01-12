# Bug Report: Strategic Planning UI Optimisation

**Date:** 12 January 2026
**Status:** Resolved
**Type:** UI/UX Enhancement
**Severity:** Medium

## Summary

Comprehensive UI optimisation for the Strategic Planning wizard to improve display on 14" and 16" MacBook screens, fix overlapping elements, and enhance visual consistency.

## Issues Addressed

### 1. Delete Modal Showing "Unknown" for Plan Name

**Reported Behaviour:**
- Delete confirmation modal displayed "Unknown - Territory Strategy" instead of the actual plan owner name

**Root Cause:**
- `handleDeleteRequest` only checked `territoryStrategies` and `accountPlans` arrays
- Plans created with the new wizard are stored in `strategicPlans` array
- When plan not found, `cse_name` was undefined, falling back to "Unknown"

**Resolution:**
Added check for `strategicPlans` array and use `primary_owner` field:
```typescript
const strategicPlan = !plan ? strategicPlans.find(p => p.id === planId) : null
if (strategicPlan) {
  planTitle = `${strategicPlan.primary_owner || 'Unknown'} - ${strategicPlan.territory || 'Territory Strategy'}`
}
```

### 2. Footer Navigation Overlapping ChaSen Floating Icon

**Reported Behaviour:**
- "Next" button was hidden behind the ChaSen floating chat icon in bottom-right corner

**Resolution:**
- Added `pr-28` (112px) right padding to footer container
- Added step indicator in center: "Step X of Y • Step Name"
- Changed footer from `left-0` to `left-64` to account for sidebar width (256px)
- Added `z-20` for proper layering

### 3. Footer Overlapping Sidebar Navigation

**Reported Behaviour:**
- Fixed footer covered sidebar menu items (logout, settings icons)

**Resolution:**
Changed footer positioning from `left-0` to `left-64`:
```typescript
<div className="fixed bottom-0 left-64 right-0 bg-white border-t border-gray-200 z-20">
```

### 4. Stepper Step Numbers Squashed on Larger Displays

**Reported Behaviour:**
- Step workflow number icons were squashed/compressed on 16" and 14" displays
- Step labels were truncated ("Context & S...", "Portfolio & ...")

**Resolution:**
Complete stepper redesign:
- Removed `max-w-screen-2xl` constraint
- Set `maxWidth: 900px` with horizontal scroll if needed
- Full step labels always visible (no truncation)
- Flex-1 connectors for even spacing between steps
- Smaller step circles (w-7 h-7) with proper padding

### 5. Portfolio Clients Table Requiring Horizontal Scroll

**Reported Behaviour:**
- Table columns were too wide, requiring horizontal scrolling
- Column headers cut off ("Health Sc...")

**Resolution:**
Compact table redesign:
- Removed `min-w-max` and `overflow-x-auto` constraints
- Reduced cell padding from `px-4 py-3` to `px-2 py-2`
- Abbreviated headers: "Weighted ACV" → "Wtd ACV", "Health Score" → "Health", "Support Score" → "Support"
- Currency values formatted in thousands/millions ($486k, $7.1M)
- Right-aligned numeric columns with `tabular-nums`
- Segment shown as icon-only with tooltip

### 6. Client Names Truncated in Table

**Reported Behaviour:**
- "Epworth Healthcare" displayed as "Epworth Healt..."

**Resolution:**
Removed truncation from client name column:
```typescript
// Before
className="... truncate max-w-[140px]"

// After
className="... whitespace-nowrap"
```

### 7. Layout Width Too Narrow for Larger Screens

**Reported Behaviour:**
- Content felt cramped on 16" MacBook screens
- Content cut off at bottom due to fixed footer

**Resolution:**
- Increased max-width from `max-w-7xl` (1280px) to `max-w-screen-2xl` (1536px)
- Added bottom padding `pb-24` to main content for footer clearance
- Applied consistent max-width across header, stepper, content, and footer

### 8. Missing Role Badges in Header

**Reported Behaviour:**
- No visual distinction between CSE (plan owner) and CAM (collaborator) roles

**Resolution:**
Added role badges to header subtitle:
- CSE badge (indigo): `bg-indigo-100 text-indigo-700`
- CAM badge (purple): `bg-purple-100 text-purple-700`
- Order: Territory • Owner [CSE] • Collaborator [CAM]

## Files Modified

### src/app/(dashboard)/planning/page.tsx
- Updated `handleDeleteRequest` to check `strategicPlans` array
- Use `primary_owner` for strategic plan titles

### src/app/(dashboard)/planning/strategic/new/page.tsx
- Header: Added CSE/CAM badges, reordered to Territory • CSE • Collaborator
- Stepper: Complete redesign with full labels, flex connectors, 900px max-width
- Footer: Added `left-64` offset, `pr-28` right padding, step indicator
- Main content: Changed to `max-w-screen-2xl`, added `pb-24`
- Portfolio table: Compact design with abbreviated headers, formatted currency, icon-only segments

### src/app/(dashboard)/planning/territory/[id]/page.tsx
- Enhanced error logging for strategy loading failures

## Visual Changes Summary

| Element | Before | After |
|---------|--------|-------|
| Footer position | `left-0` | `left-64` (after sidebar) |
| Footer right padding | `px-6` | `pl-6 pr-28` |
| Max content width | 1280px | 1536px |
| Table cell padding | `px-4 py-3` | `px-2 py-2` |
| Currency format | $2,859,412 | $2,859k |
| Segment display | Full text badge | Icon with tooltip |
| Step labels | Truncated | Full text |
| Header subtitle | Name • Territory | Territory • Name [CSE] • Collab [CAM] |

## Testing Performed

- [x] Build passes with zero TypeScript errors
- [x] Delete modal shows correct plan owner name
- [x] Footer navigation doesn't overlap sidebar or floating icons
- [x] Stepper displays all step labels without truncation
- [x] Portfolio table fits without horizontal scrolling on 14"/16" screens
- [x] Client names display in full
- [x] CSE and CAM badges display correctly
- [x] Layout utilises available screen width on larger displays

## Browser/Device Testing

- [x] 14" MacBook Pro (1512px viewport)
- [x] 16" MacBook Pro (1728px viewport)
- [x] External monitor (1920px+ viewport)

## Commits

1. `fix: Show correct plan name in delete confirmation modal`
2. `fix: Redesign footer navigation to avoid ChaSen floating icon`
3. `fix: Position footer navigation to not overlap sidebar`
4. `fix: Optimize stepper layout for 14" and 16" displays`
5. `fix: Optimize Portfolio Clients table for 14"/16" displays`
6. `fix: Display full text for stepper labels and client names`
7. `feat: Add CSE and CAM badges to Strategic Plan header`
8. `fix: Reorder header to Territory • CSE • Collaborator`
