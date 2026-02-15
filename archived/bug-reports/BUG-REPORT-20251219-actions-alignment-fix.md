# Bug Report: Actions Page Alignment and Logo Size Fix

## Date

19 December 2025

## Issue Summary

The Actions page displayed misaligned metadata on the right side of each action row. Client logos were too small and metadata columns (client, date, owner, status) did not align consistently between grouped action rows and individual action rows.

## Symptoms

- Metadata columns appeared messy and unaligned
- Client logos too small (w-5/w-6) to be easily recognisable
- Grouped action rows and single action rows had inconsistent column widths
- No fixed widths on metadata columns caused variable spacing

## Root Cause Analysis

1. **Logo Sizes Too Small**: CollapsibleActionGroup used `w-6 h-6` (24px) and ActionCard used `w-5 h-5` (20px) for client logos, making them hard to identify at a glance.

2. **Variable Column Widths**: Metadata columns used only `gap-4` spacing with no fixed widths, causing columns to shift based on content length:
   - Client names of varying lengths shifted other columns
   - Owner names (full names vs counts) created inconsistent widths
   - Status badges varied in width ("open" vs "In Progress")

3. **Inconsistent Structure**: Grouped rows showed different metadata (client count, owner count, progress) than individual rows (client name, date, owner, status), but without fixed widths they didn't align.

## Solution

### 1. Increased Logo Sizes

**CollapsibleActionGroup** (grouped action rows):

- From: `w-6 h-6` (24px)
- To: `w-8 h-8` (32px)
- Added fixed container width: `w-[140px] justify-end`

**ActionCard** (individual action rows):

- From: `w-5 h-5` (20px)
- To: `w-7 h-7` (28px)
- Improved fallback for clients without logos (circular initial badge)

### 2. Fixed-Width Metadata Columns

**CollapsibleActionGroup metadata:**

```tsx
<div className="hidden sm:flex items-center gap-3 text-xs text-gray-500 flex-shrink-0">
  <span className="... w-[85px] justify-center">  {/* Client count */}
  <span className="... w-[50px]">                  {/* Owner count */}
  <span className="... w-[50px]">                  {/* Progress */}
</div>
```

**ActionCard metadata:**

```tsx
<div className="hidden sm:flex items-center gap-3 text-xs text-gray-500 flex-shrink-0">
  <span className="... w-[140px]">  {/* Client with logo */}
  <span className="... w-[85px]">   {/* Due date */}
  <span className="... w-[80px]">   {/* Owner */}
  <span className="... w-[75px]">   {/* Status badge */}
</div>
```

### 3. Improved Fallback Display

For clients without logos, changed from a simple icon to a circular badge with the client's initial:

```tsx
// Before
<Target className="h-3.5 w-3.5 text-gray-400 flex-shrink-0" />

// After
<div className="w-7 h-7 rounded-full bg-gray-100 flex items-center justify-center text-xs font-medium text-gray-500 flex-shrink-0 border border-gray-200">
  {action.client.charAt(0)}
</div>
```

## Files Modified

- `src/app/(dashboard)/actions/page.tsx`
  - Lines 770-797: CollapsibleActionGroup logo section
  - Lines 799-827: CollapsibleActionGroup metadata section
  - Lines 945-1001: ActionCard metadata section

## Testing

- Build passes with no TypeScript errors
- Grouped action rows have consistent column alignment
- Individual action rows have consistent column alignment
- Client logos are larger and more visible
- Clients without logos display a fallback initial badge
- All metadata columns align vertically across different row types

## Visual Comparison

### Before

```
┌──────────────────────────────────────────────────────────────────────────┐
│ ● Schedule engagement meetings    [●●●●●] 7 clients  👤 3  ✓ 2/7         │
│ ● Health Check - SA Health    [●] SA Health  📅 12/31  Dimitri  open     │
│ ● Review compliance - Epworth [●] Epworth Healthcare  📅 1/15  Jimmy  in │
└──────────────────────────────────────────────────────────────────────────┘
```

(Columns misaligned, small logos, inconsistent widths)

### After

```
┌──────────────────────────────────────────────────────────────────────────┐
│ ● Schedule engagement meetings    [●●●●●●]   7 clients   👤 3    ✓ 2/7   │
│ ● Health Check - SA Health     [●●] SA Health   📅 12/31   Dimitri   open│
│ ● Review compliance - Epworth  [●●] Epworth..   📅 1/15    Jimmy   in prg│
└──────────────────────────────────────────────────────────────────────────┘
```

(Columns aligned, larger logos, fixed widths)

## Prevention

- Use fixed-width containers for tabular data displays
- Ensure consistent column widths across different row types in the same list
- Consider minimum logo sizes of 28-32px for recognisability
- Always provide fallback displays that match the dimensions of primary displays

## Related Bug Reports

- `BUG-REPORT-20251219-actions-page-fixes.md` - Dropdown z-index and logo import fixes
- `BUG-REPORT-20251219-collapsible-similar-actions.md` - Collapsible grouping feature
- `BUG-REPORT-20251219-actions-page-ux-redesign.md` - Compact view implementation

## Commits

- Pending commit for alignment and logo size fix
