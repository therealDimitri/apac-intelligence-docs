# Enhancement: Deep Link Comment Notifications

**Date:** 2026-01-25
**Type:** Enhancement
**Status:** Completed
**Component:** Comments System

## Summary

Implemented deep linking functionality so that clicking "View Comment" in email notifications navigates directly to the specific comment, opens the comments panel, scrolls to the comment, and highlights it with a visual animation.

## Changes Made

### API Route (`src/app/api/comments/route.ts`)
- Updated `buildEntityLink` function to accept optional `commentId` parameter
- Added URL routes for all entity types:
  - compliance: `/compliance`
  - nps: `/nps`
  - financials: `/financials`
  - segmentation: `/segmentation`
  - support: `/support`
  - aging_accounts: `/internal-ops`
  - benchmarking: `/benchmarking`
  - team_performance: `/team-performance`
  - priority_matrix: `/priority-matrix`
- Appends `?comment=xxx` query parameter to URLs when commentId is provided

### FloatingPageComments (`src/components/comments/FloatingPageComments.tsx`)
- Added imports for `useSearchParams`, `useRouter`, and `useRef`
- Added `highlightedCommentId` state and `hasProcessedDeepLink` ref
- Added useEffect to check URL for `?comment=xxx` parameter on mount:
  - Auto-opens the comments sheet
  - Sets the highlighted comment ID
  - Cleans the URL by removing the comment parameter
- Passes `highlightedCommentId` and `onHighlightComplete` to UnifiedComments

### UnifiedComments (`src/components/comments/UnifiedComments.tsx`)
- Added `highlightedCommentId` and `onHighlightComplete` props
- Added `activeHighlight` state for animation control
- Added useEffect to scroll to and highlight specified comment:
  - Uses `scrollIntoView({ behavior: 'smooth', block: 'center' })`
  - Applies highlight for 3 seconds then fades
- Removed unused `containerRef`

### CommentThread (`src/components/comments/CommentThread.tsx`)
- Added `highlightedCommentId` prop to interface
- Passes `isHighlighted={highlightedCommentId === comment.id}` to CommentItem
- Passes `highlightedCommentId` to recursive CommentThread calls for nested replies

### CommentItem (`src/components/comments/CommentItem.tsx`)
- Added `isHighlighted` prop to interface
- Added `id="comment-{comment.id}"` attribute for scroll targeting
- Added highlight styling when isHighlighted is true:
  - `ring-2 ring-purple-500 ring-offset-2 rounded-lg bg-purple-50/50`
  - `transition-all duration-500` for smooth animation

## User Flow

1. User receives email notification about being @mentioned in a comment
2. User clicks "View Comment" button in email
3. URL opens with `?comment=xxx` parameter
4. FloatingPageComments detects the parameter and:
   - Opens the comments sheet automatically
   - Passes the comment ID to UnifiedComments
5. UnifiedComments scrolls to the comment and highlights it
6. Highlight fades after 3 seconds
7. URL is cleaned (comment parameter removed)

## Testing

- Build passes with zero TypeScript errors
- ESLint checks pass
- Pre-commit hooks pass

## Files Changed

- `src/app/api/comments/route.ts`
- `src/components/comments/FloatingPageComments.tsx`
- `src/components/comments/UnifiedComments.tsx`
- `src/components/comments/CommentThread.tsx`
- `src/components/comments/CommentItem.tsx`
