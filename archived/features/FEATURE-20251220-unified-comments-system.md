# Feature Implementation: Unified Comments System

**Date**: 20 December 2024
**Status**: Complete
**Type**: New Feature

## Overview

Implemented a unified, threaded comments system across the dashboard replacing fragmented notes implementations with a modern, collaborative commenting experience similar to Linear, Notion, and Slack.

## Previous State

| Location        | Previous Implementation                 | Issue                            |
| --------------- | --------------------------------------- | -------------------------------- |
| Actions         | `Notes` field in `actions` table        | Simple text, no threads/mentions |
| Meetings        | `meeting_notes` in `unified_meetings`   | Simple text field                |
| Priority Matrix | `DetailComments.tsx` with MatrixContext | In-memory only, not persisted    |
| Client Profiles | `AddNoteModal` creates pseudo-meetings  | Workaround, not proper notes     |

## New Implementation

### Database

Created `comments` table in Supabase with:

- Polymorphic association (`entity_type` + `entity_id`) for Actions, Meetings, and Clients
- Threading support with `parent_id` and max depth of 3
- Rich text stored as HTML with plain text fallback for search
- @mentions stored as JSONB array
- Reactions (likes) with count and user tracking
- Resolution workflow (is_resolved, resolved_at, resolved_by)
- Client association for activity stream

**Migration file**: `supabase/migrations/20251220_create_comments_table.sql`

### Components Created

| File                                            | Purpose                         |
| ----------------------------------------------- | ------------------------------- |
| `src/components/comments/UnifiedComments.tsx`   | Main container component        |
| `src/components/comments/CommentItem.tsx`       | Individual comment with actions |
| `src/components/comments/CommentThread.tsx`     | Recursive threaded renderer     |
| `src/components/comments/RichTextEditor.tsx`    | TipTap WYSIWYG editor           |
| `src/components/comments/EditorToolbar.tsx`     | Formatting toolbar              |
| `src/components/comments/MentionSuggestion.tsx` | @mention autocomplete           |
| `src/components/comments/index.ts`              | Barrel exports                  |

### API Routes

| Endpoint                  | Method | Purpose                                      |
| ------------------------- | ------ | -------------------------------------------- |
| `/api/comments`           | GET    | Fetch comments for entity (threaded)         |
| `/api/comments`           | POST   | Create comment (with @mention notifications) |
| `/api/comments/[id]`      | PATCH  | Update comment                               |
| `/api/comments/[id]`      | DELETE | Soft delete comment                          |
| `/api/comments/[id]/like` | POST   | Toggle like                                  |
| `/api/comments/by-client` | GET    | Fetch all comments for a client              |

### Hooks

| File                       | Purpose                                |
| -------------------------- | -------------------------------------- |
| `src/hooks/useComments.ts` | CRUD operations with tree manipulation |

### Types

| File                    | Purpose                                                |
| ----------------------- | ------------------------------------------------------ |
| `src/types/comments.ts` | TypeScript interfaces for Comment, Mention, EntityType |

## Features

- **Threaded replies** with visual thread lines (left border, depth-based colours)
- **@mentions** with purple highlighting and team member autocomplete
- **Rich text editor** (TipTap) with formatting toolbar
- **Likes** with count display and toggle
- **Edit/Delete** own comments only (with confirmation)
- **Resolution workflow** - mark threads as resolved
- **Activity stream integration** - comments appear in client timeline

## Integration Points

### ActionDetailModal

- Replaced Notes section with `<UnifiedComments entityType="action" entityId={action.id} clientName={action.client} />`
- Comments now persist to database instead of actions.Notes field

### Client Profile (CenterColumn.tsx)

- Added comments to activity stream timeline
- Fetches from `/api/comments/by-client` endpoint
- Green comment icon with author name, likes count, replies count

## Notifications

When a user is @mentioned in a comment:

1. Notification inserted into `notifications` table
2. Appears in user's notification bell
3. Clicking navigates to the entity

**Note**: Email notifications require adding an email service (Resend/SendGrid) to the project.

## Files Modified

| File                                                                    | Change                             |
| ----------------------------------------------------------------------- | ---------------------------------- |
| `src/components/ActionDetailModal.tsx`                                  | Replace Notes with UnifiedComments |
| `src/app/(dashboard)/clients/[clientId]/components/v2/CenterColumn.tsx` | Add comments to activity stream    |
| `src/app/api/comments/route.ts`                                         | Create notification on @mention    |

## Dependencies Added

```json
{
  "@tiptap/react": "^3.14.0",
  "@tiptap/starter-kit": "^3.14.0",
  "@tiptap/extension-link": "^3.14.0",
  "@tiptap/extension-mention": "^3.14.0",
  "@tiptap/extension-placeholder": "^3.14.0",
  "@tiptap/pm": "^3.14.0",
  "@tiptap/suggestion": "^3.14.0",
  "tippy.js": "^6.3.7"
}
```

## Testing

Run build to verify:

```bash
npm run build
```

## Future Enhancements

1. **Email notifications** - Add email service for @mention alerts
2. **Real-time updates** - Add Supabase subscriptions for live comments
3. **Meeting integration** - Add UnifiedComments to EditMeetingModal
4. **Client profile notes** - Replace AddNoteModal with UnifiedComments for client entity type
5. **Migrate existing notes** - Script to convert existing Notes to comments

## Related Plan

See plan file: `/Users/jimmy.leimonitis/.claude/plans/squishy-enchanting-goose.md`
