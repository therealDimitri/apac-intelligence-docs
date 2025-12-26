# Bug Report: Add Note Modal - Multiple Issues

**Date:** 23 December 2025
**Status:** Fixed
**Severity:** High
**Component:** Client Profile > Add Note Modal, Timeline

---

## Problem Description

Multiple issues were identified with the Add Note feature:

### Issue 1: Empty Error Object

```
Error adding note: {}
```

Note creation failed silently with an empty error.

### Issue 2: Date Format Error

```
date/time field value out of range: "23/12/2025"
```

### Issue 3: Raw HTML Displayed in Timeline

Timeline cards displayed raw HTML instead of rendered content:

```
<p><span data-type="mention" class="mention bg-purple-100...
```

### Issue 4: No @Mention Notifications

When users were @mentioned in notes, no email or in-app notifications were sent.

---

## Root Cause Analysis

### 1. @Mentions Not Working

The `AddNoteModal.tsx` was using a plain `<textarea>` instead of `RichTextEditor`.

### 2. RLS Policy Blocking Insert

Direct Supabase client (anon key) was blocked by RLS policies.

### 3. Date Format Incompatibility

Dates formatted as `DD/MM/YYYY` were rejected by PostgreSQL.

### 4. No HTML Rendering

Timeline used `{item.description}` (text) instead of `dangerouslySetInnerHTML`.

### 5. Missing Notification System

Notes API had no @mention notification handling (unlike Comments API).

---

## Solution Implemented

### Phase 1: Rich Text Editor Integration

Updated `AddNoteModal.tsx` to use `RichTextEditor` with @mention support.

### Phase 2: API Endpoint Creation

Created `/api/notes/route.ts` using service role key to bypass RLS.

### Phase 3: Date Format Fix

Changed from `DD/MM/YYYY` to ISO format `YYYY-MM-DD`.

### Phase 4: HTML Rendering in Timeline

Updated `CenterColumn.tsx` to render descriptions as HTML:

```tsx
<div
  className="text-sm text-gray-600 mt-2 line-clamp-2 prose prose-sm max-w-none [&_.mention]:bg-purple-100 [&_.mention]:text-purple-700 [&_.mention]:rounded [&_.mention]:px-1 [&_.mention]:font-medium"
  dangerouslySetInnerHTML={{ __html: item.description }}
/>
```

### Phase 5: @Mention Notifications

Added notification support to Notes API:

- Creates in-app notifications in `notifications` table
- Sends email notifications via `sendMentionNotificationEmail`
- Added `'note'` entity type to email service

---

## Files Changed

| File                                                                    | Changes                                             |
| ----------------------------------------------------------------------- | --------------------------------------------------- |
| `src/components/AddNoteModal.tsx`                                       | RichTextEditor, API integration, mention extraction |
| `src/app/api/notes/route.ts`                                            | **NEW** - API with service role, notifications      |
| `src/app/(dashboard)/clients/[clientId]/components/v2/CenterColumn.tsx` | HTML rendering for descriptions                     |
| `src/lib/email-service.ts`                                              | Added 'note' entity type                            |

---

## Technical Details

### Note Storage

Notes stored in `unified_meetings` table with:

- `meeting_id`: `NOTE-{timestamp}-{random}` format
- `meeting_type`: `'Other'`
- `status`: `'completed'`
- `duration`: `0`
- `meeting_notes`: HTML content with @mentions

### Notification Flow

1. AddNoteModal extracts mentions via `editorRef.current?.getMentions()`
2. Mentions passed to `/api/notes` endpoint
3. API creates notification record for each mention
4. Email sent if mention has email address

---

## Testing Steps

1. Navigate to Client Profile
2. Right-click on timeline > Add Note
3. Type @ to verify mention suggestions appear
4. Select a team member and add note content
5. Click "Add Note"
6. Verify:
   - Note appears in timeline with proper HTML rendering
   - @mentions display with purple highlighting
   - Mentioned user receives notification
   - Check server logs for email notification status

---

## Known Limitations

- Notes are stored as meetings (type='Other') - this is by design
- Notes appear in timeline, not in the right-side "Notes & Discussion" tab (which shows comments)
- Editing notes uses the Meeting modal (future enhancement: dedicated Note modal)
