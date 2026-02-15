# Bug Report: Unified Notes System and @Mentions

**Date:** 23 December 2025
**Status:** Fixed
**Severity:** High
**Component:** Client Profile, Notes, Actions, Meetings

---

## Problem Description

Multiple issues were identified with the notes and @mention system:

1. **Notes not unified** - "Add Note" created meeting records while "Notes & Discussion" used comments - confusing and fragmented
2. **@Mentions not working** - Plain textareas didn't support @mention functionality
3. **Raw HTML displayed** - Timeline cards showed raw HTML instead of rendered content
4. **No mention notifications** - @mentions in notes didn't trigger notifications

---

## Solution Implemented

### 1. Unified Notes System

Changed "Add Note" to create comments instead of meeting records. This unifies notes with the "Notes & Discussion" system.

**AddNoteModal.tsx:**

```tsx
// Now creates a comment instead of a meeting
const response = await fetch('/api/comments', {
  method: 'POST',
  body: JSON.stringify({
    entity_type: 'client',
    entity_id: clientName,
    client_name: clientName,
    content: formData.title
      ? `<p><strong>${formData.title}</strong></p>${noteContent}`
      : noteContent,
    ...
  }),
})
```

### 2. Timeline Display Updates

**CenterColumn.tsx:**

- Client-level comments now display as "Note" instead of "Comment on [Client]"
- Notes filter includes both client-level comments AND meetings with notes
- Comments filter excludes client-level comments (they're notes)
- Descriptions render as HTML with @mention styling

```tsx
// Notes filter now includes client-level comments
if (activeFilter === 'notes') {
  return timeline.filter(item => {
    if (item.type === 'comment' && item.data) {
      const comment = item.data as { entity_type?: string }
      return comment.entity_type === 'client'
    }
    if (item.type === 'meeting' && item.data) {
      const meeting = item.data as Meeting
      return meeting.notes && meeting.notes.trim().length > 0
    }
    return false
  })
}
```

### 3. @Mention Support in All Modals

Added RichTextEditor with @mention support to:

- **AddNoteModal** - For creating notes
- **EditMeetingModal** - For meeting notes
- **CreateActionModal** - For action descriptions
- **EditActionModal** - For action descriptions

Each modal now:

- Uses `RichTextEditor` instead of `<textarea>`
- Extracts HTML content via `editorRef.current?.getHTML()`
- Stores HTML content (including @mentions) in the database

---

## Files Changed

| File                                                                    | Changes                                         |
| ----------------------------------------------------------------------- | ----------------------------------------------- |
| `src/components/AddNoteModal.tsx`                                       | Uses comments API, RichTextEditor               |
| `src/components/EditMeetingModal.tsx`                                   | RichTextEditor for notes field                  |
| `src/components/CreateActionModal.tsx`                                  | RichTextEditor for description                  |
| `src/components/EditActionModal.tsx`                                    | RichTextEditor for description                  |
| `src/app/(dashboard)/clients/[clientId]/components/v2/CenterColumn.tsx` | Timeline filtering, HTML rendering, Note titles |
| `src/app/api/notes/route.ts`                                            | Added notification support                      |
| `src/lib/email-service.ts`                                              | Added 'note' entity type                        |

---

## Architecture Summary

### Where Notes Are Stored

- **Client Notes** → `comments` table (entity_type='client')
- **Meeting Notes** → `unified_meetings.meeting_notes`
- **Action Notes** → `actions.Notes`

### Where Notes Appear

- **Timeline** (CenterColumn) - All notes visible, filter by "Notes"
- **Right Panel "Notes & Discussion"** - Client-level comments
- **Meeting/Action modals** - Inline editing

### @Mention Flow

1. User types `@` in RichTextEditor
2. TipTap Mention extension shows suggestions
3. Selected mention stored as HTML: `<span data-type="mention" ...>`
4. For comments: `/api/comments` sends notifications
5. For notes: `/api/notes` sends notifications
6. Email sent via `sendMentionNotificationEmail`

---

## Testing Steps

1. **Create a Note:**
   - Go to Client Profile
   - Right-click > Add Note
   - Type @ and select a team member
   - Save and verify it appears in timeline AND right-side Notes tab

2. **Edit a Meeting:**
   - Click on a meeting in timeline
   - Use @ in the Notes field
   - Save and verify HTML is stored correctly

3. **Create/Edit an Action:**
   - Use @ in Description field
   - Verify mentions are saved and displayed correctly

4. **Timeline Filters:**
   - "Notes" filter shows client-level notes + meetings with content
   - "Comments" filter shows comments on actions/meetings only
   - "All" shows everything

---

## Display Examples

### Timeline Card (Note)

```
📝 Note
Just now • Dimitri Leimonitis

@Tracey Bland please review the compliance requirements
for next quarter.
```

### Timeline Card (Comment)

```
💬 Comment on Weekly Review Meeting
2 hours ago • Jane Smith

Great discussion points @John Doe!
```
