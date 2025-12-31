# Feature: Priority Matrix Card Redesign

**Date:** 31 December 2025
**Status:** Completed
**Type:** UI/UX Enhancement
**Component:** Priority Matrix

## Summary

Redesigned Priority Matrix cards with modern, clean UI/UX focused on readability and consistent visual hierarchy. The description is now the hero element, always visible with expandable content.

## Changes Implemented

### 1. Priority Triple-Encoding System

Cards now use three visual indicators for priority level:
- **Border colour**: Left border indicates priority (red, amber, blue, grey)
- **Background tint**: Subtle background colour reinforces priority
- **Label badge**: Explicit text label (CRITICAL, HIGH, MEDIUM, LOW)

```typescript
const PRIORITY_CONFIG = {
  critical: {
    border: 'border-l-red-500',
    bg: 'bg-red-50',
    labelBg: 'bg-red-100',
    labelText: 'text-red-700',
    label: 'CRITICAL',
  },
  high: {
    border: 'border-l-amber-500',
    bg: 'bg-amber-50',
    labelBg: 'bg-amber-100',
    labelText: 'text-amber-700',
    label: 'HIGH',
  },
  // ... medium, low
}
```

### 2. Description as Hero Element

- Description is always visible (not hidden behind expansion)
- Compact view: 3 lines with "Show more" expansion
- Comfortable view: 5 lines with "Show more" expansion
- Expand/collapse toggle for longer descriptions

### 3. Relative Due Date Formatting

- Only displays due dates within 14 days
- Uses relative language: "Due today", "Due tomorrow", "Due in 3 days", "2 days overdue"
- Urgent dates (within 7 days) shown in red

### 4. Standardised Card Structure

Clear visual hierarchy:
1. **Header**: Priority label + Type icon + Due date
2. **Title**: Max 2 lines with line-clamp
3. **Subtitle**: Optional secondary text
4. **Description**: Hero element, expandable
5. **Client Section**: Logo(s) + client name(s)
6. **Tags**: Up to 3 visible with "+N more"
7. **Footer**: Owner chip with avatar/department + badges

### 5. Type Icons with Colour Coding

```typescript
const TYPE_ICON_CONFIG = {
  critical: 'text-red-600',    // AlertTriangle
  action: 'text-blue-600',     // Calendar
  recommendation: 'text-amber-600', // TrendingUp
  insight: 'text-purple-600',  // Sparkles
}
```

### 6. Density Modes

**Compact Mode:**
- Padding: p-4
- Spacing: space-y-3
- Description: 3 lines
- Smaller text sizes
- Single-line owner display

**Comfortable Mode:**
- Padding: p-5
- Spacing: space-y-4
- Description: 5 lines
- Larger text sizes
- Two-line owner display (name + department)

## Files Modified

- `src/components/priority-matrix/MatrixItemCompact.tsx` - Complete rewrite
- `src/components/priority-matrix/MatrixItem.tsx` - Complete rewrite
- `src/components/priority-matrix/types.ts` - Added `cseCount` to metadata type

## Design Principles Applied

Based on UX research from Linear, Asana, Notion:

1. **Progressive disclosure**: Show essential info first, expand for details
2. **Visual hierarchy**: Priority → Title → Description → Context
3. **Consistent spacing**: Standardised padding and gaps
4. **Accessibility**: Triple-encoding for colour-blind users
5. **Information density**: Balance between content and whitespace

## Testing

1. Navigate to Command Centre (/priority-matrix)
2. Verify priority colours and labels display correctly
3. Toggle between Compact and Comfortable modes
4. Click "Show more" on long descriptions
5. Verify due dates show relative format
6. Verify client logos and owner chips display correctly
7. Test in Swimlane, Agenda, and List views

## Commits

- `002784a` - feat: Redesign Priority Matrix cards with modern UI/UX
