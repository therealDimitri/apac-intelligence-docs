# Bug Report: Done Count Mismatch & HTML Markup in Card Descriptions

**Date:** 31 December 2025
**Status:** RESOLVED
**Severity:** Medium
**Components:** Actions Page (page.tsx), KanbanBoard.tsx, actionUtils.ts

## Problem Summary

Two UX issues on the Actions & Tasks page:

1. **"Done" count showing 0** - The stat card labelled "Completed This Week" showed `stats.completedThisWeek` which was often 0, confusing users who expected to see total completed actions
2. **Raw HTML markup in card descriptions** - Some action descriptions contained HTML tags like `<p>...</p>` that were rendering as literal text instead of being stripped or rendered

## Root Causes

### Issue 1: Wrong Stats Property

The `actionStats` array was using `completedThisWeek` instead of total `completed`:

```typescript
// BEFORE - Showed only completions within the current week
{ label: 'Completed This Week', value: stats.completedThisWeek, icon: Target, colour: 'green' }
```

### Issue 2: No HTML Stripping in cleanDescription

The `cleanDescription()` function in `src/utils/actionUtils.ts` only removed internal metadata (ASSIGNMENT INFO blocks) but didn't strip HTML tags:

```typescript
// BEFORE - No HTML tag handling
const cleaned = description
  .replace(/📋\s*ASSIGNMENT INFO[\s\S]*?(?:Action created from.*?\.|\n-{3,})/gi, '')
  // ... other metadata removal, but no HTML stripping
```

## Solutions Applied

### Fix 1: Updated actionStats Display

Changed the stats array to show total completed count with clearer label:

```typescript
// AFTER - Shows total completed actions
{ label: 'Done', value: stats.completed, icon: Target, colour: 'green' }
```

**File:** `src/app/(dashboard)/actions/page.tsx:527`

### Fix 2: Added HTML Stripping to cleanDescription

Enhanced the function to strip HTML tags and decode common HTML entities:

```typescript
// AFTER - Full HTML handling
let cleaned = description
  // Strip HTML tags (e.g., <p>, <br>, <div>, etc.)
  .replace(/<[^>]*>/g, ' ')
  // Decode common HTML entities
  .replace(/&nbsp;/g, ' ')
  .replace(/&amp;/g, '&')
  .replace(/&lt;/g, '<')
  .replace(/&gt;/g, '>')
  .replace(/&quot;/g, '"')
  .replace(/&#39;/g, "'")
  // ... rest of metadata removal
  // Clean up multiple spaces
  .replace(/\s+/g, ' ')
```

**File:** `src/utils/actionUtils.ts:13-44`

## HTML Tags Now Handled

The following HTML elements and entities are now properly stripped/decoded:
- All HTML tags: `<p>`, `<br>`, `<div>`, `<span>`, etc.
- `&nbsp;` → space
- `&amp;` → `&`
- `&lt;` → `<`
- `&gt;` → `>`
- `&quot;` → `"`
- `&#39;` → `'`

## Files Modified

1. `src/app/(dashboard)/actions/page.tsx` - Updated actionStats array
2. `src/utils/actionUtils.ts` - Enhanced cleanDescription() function

## Testing Checklist

- [x] "Done" stat now shows total completed count (not just this week)
- [x] HTML tags like `<p>`, `<div>`, `<br>` are stripped from descriptions
- [x] HTML entities are decoded to readable characters
- [x] Multiple spaces collapsed to single space
- [x] Function still removes ASSIGNMENT INFO metadata blocks
- [x] Empty descriptions after cleaning return undefined

## Related Components

The `cleanDescription()` function is used by:
- `src/components/KanbanBoard.tsx` (line 472)
- Any other component displaying action descriptions

This fix applies globally wherever the utility is imported.
