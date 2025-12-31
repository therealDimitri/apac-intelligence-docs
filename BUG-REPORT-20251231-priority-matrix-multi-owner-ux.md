# Bug Report: Priority Matrix Multi-Owner Display and Detail Panel Scroll

**Date:** 31 December 2025
**Status:** Fixed
**Severity:** Medium (UX/Usability)
**Component:** Priority Matrix

## Summary

Two UX issues were identified in the Priority Matrix component:

1. **Multi-owner cards displayed cryptic badges** - Cards with multiple CSE owners showed "2C 2 CSEs" badge instead of showing actual owner names
2. **Detail panel required scroll to view** - When users clicked on a card after scrolling down, the detail panel appeared at the top of the page, requiring users to scroll back up

## Issues Identified

### Issue 1: Multi-Owner Badge Display

**Problem:**
- Cards assigned to multiple CSEs showed a confusing badge format like "2C 2 CSEs"
- Users couldn't identify WHO owned the card at a glance
- Required clicking into the card to see owner names

**Expected Behaviour:**
- Show owner avatars with names visible
- Provide quick identification of owners without requiring clicks

### Issue 2: Detail Panel Scroll Position

**Problem:**
- SlideOverDetail panel is fixed to the right side of the viewport
- When user scrolled down in the matrix and clicked a card, they had to scroll back up to see the panel
- Poor UX for long lists

**Expected Behaviour:**
- Smart scrolling that brings the panel into view only when necessary
- Minimal disruption to user's scroll position

## Root Cause

### Issue 1
The existing implementation used a simple badge component that showed counts rather than actual names. No avatar group component existed to display multiple owners attractively.

### Issue 2
The SlideOverDetail component had no scroll-into-view logic. The panel was always rendered at the top-right, regardless of user's current scroll position.

## Solution Implemented

### Fix 1: OwnerAvatarGroup Component

Created new component `src/components/priority-matrix/OwnerAvatarGroup.tsx`:

```tsx
export interface OwnerInfo {
  name: string
  clientCount: number
}

export function OwnerAvatarGroup({
  owners,
  maxVisible = 2,
  size = 'xs',
  getPhotoURL,
}: OwnerAvatarGroupProps) {
  // Shows first N avatars overlapping with ring styling
  // +N overflow badge for additional owners
  // Tooltip shows: "Owner Name (X clients)"
}

export function getOwnersFromClientAssignments(
  assignments: Record<string, string> | null | undefined
): OwnerInfo[] {
  // Extracts unique owners from client assignments
  // Returns array sorted by client count (highest first)
}
```

**Features:**
- Overlapping avatar stack (Linear/Asana style)
- Shows first 2 avatars by default
- "+N" overflow indicator for additional owners
- Hover tooltip reveals all owners with client counts
- Supports profile photos via `getPhotoURL` prop

### Fix 2: Smart Scroll-into-View

Updated `src/components/priority-matrix/views/SlideOverDetail.tsx`:

```tsx
useEffect(() => {
  if (item && panelRef.current) {
    panelRef.current.focus()

    // Smart scroll: only scroll if panel is not fully visible
    const isMobile = window.innerWidth < 1024 // lg breakpoint

    if (isMobile) {
      // Mobile: Always scroll to top for full-screen experience
      window.scrollTo({ top: 0, behavior: 'smooth' })
    } else {
      // Desktop: Smart scroll only if panel is off-screen
      const rect = panelRef.current.getBoundingClientRect()
      const isInViewport = rect.top >= 0 && rect.bottom <= window.innerHeight

      if (!isInViewport) {
        panelRef.current.scrollIntoView({
          behavior: 'smooth',
          block: 'center',
        })
      }
    }
  }
}, [item])
```

**Behaviour:**
- Desktop: Only scrolls if panel is off-screen, uses `block: 'center'` for less jarring scroll
- Mobile: Always scrolls to top for full-screen experience
- Smooth scrolling animation

## Files Modified

| File | Change |
|------|--------|
| `src/components/priority-matrix/OwnerAvatarGroup.tsx` | **NEW** - Avatar group component with tooltips |
| `src/components/priority-matrix/MatrixContext.tsx` | Added `getItemClientAssignments()` function |
| `src/components/priority-matrix/MatrixItem.tsx` | Added `clientAssignments` prop, integrated OwnerAvatarGroup |
| `src/components/priority-matrix/MatrixItemCompact.tsx` | Added `clientAssignments` prop, integrated OwnerAvatarGroup |
| `src/components/priority-matrix/MatrixQuadrant.tsx` | Added `getItemClientAssignments` prop passthrough |
| `src/components/priority-matrix/PriorityMatrix.tsx` | Destructured and passed `getItemClientAssignments` |
| `src/components/priority-matrix/views/SlideOverDetail.tsx` | Added smart scroll-into-view logic |

## Testing Performed

1. Verified multi-owner cards now show avatar stack
2. Confirmed tooltip displays owner names and client counts on hover
3. Tested scroll behaviour - panel scrolls into view only when off-screen
4. Tested mobile behaviour - always scrolls to top
5. Build passes without TypeScript errors

## Deployment

- **Commit:** `d995176`
- **Message:** "feat: Add multi-owner avatar display and smart panel scrolling"
- **Deployed to:** https://apac-cs-dashboards.com

## UX Pattern References

- **Avatar Stack:** Inspired by Linear, Asana, and Jira team indicators
- **Progressive Disclosure:** Show avatars, reveal details on hover
- **Smart Scrolling:** Minimal disruption principle from Material Design

## Related Files

- Previous card truncation fix also applied to `MatrixItem.tsx` and `MatrixItemCompact.tsx`
- Removed restrictive `max-w-[120px]`, `max-w-[100px]`, `max-w-[80px]` constraints
