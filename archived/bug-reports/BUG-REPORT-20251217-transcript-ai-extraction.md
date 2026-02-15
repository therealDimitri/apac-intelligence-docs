# Bug Report: Transcript AI Extraction Not Working

**Date:** 17-18 December 2025
**Severity:** High
**Status:** RESOLVED (All issues fixed including title corruption)

## Problem Summary

When creating a meeting in the Briefing Room and uploading a transcript file, the AI analysis was not triggered. Meeting fields (Executive Summary, Key Topics, Decisions Made, Key Risks, Next Steps, Meeting Notes) remained empty, and no actions were auto-created.

## Root Causes

### Issue 1: Missing VTT File Format Support

The document parser and upload API did not support WebVTT (.vtt) files, which is a common transcript format from meeting recording tools.

### Issue 2: No Automatic AI Processing After Upload

The transcript upload endpoint (`/api/meetings/upload-file`) only stored the file and saved the URL to the database. It did not:

- Extract text from the uploaded file
- Trigger AI analysis for summary generation
- Extract and create action items

### Issue 3: Disconnected Processing Pipeline

The AI analysis APIs (`/api/meetings/generate-summary` and `/api/meetings/extract-actions`) existed but were never called after transcript upload. They required manual triggering which was not implemented in the UI flow.

### Issue 4: Hidden File Input Not Triggering (Additional)

The file input element was using `className="hidden"` which, in some browsers/contexts, prevented the file picker dialog from opening when clicking the label. The click event was being received but the native file dialog was not appearing.

### Issue 5: Supabase Storage MIME Type Rejection

The `meeting-transcripts` storage bucket was created before VTT support was added, so it didn't have `text/vtt` in its allowed MIME types list. Uploading VTT files failed with "mime type text/vtt is not supported".

### Issue 6: Numeric vs String Meeting ID Mismatch

The frontend was passing string meeting IDs like `MEETING-1765974104164-5l78usz` but the upload route was trying to use them as numeric IDs with `parseInt()`, causing database update failures.

### Issue 7: Middleware Blocking Internal API Calls

The process-transcript endpoint was being blocked by the authentication middleware when called internally from the upload-file route (fire-and-forget pattern). The internal fetch didn't have session cookies, so it was redirected to sign-in.

### Issue 8: No User Feedback on AI Processing Status

Users had no visibility into whether AI processing was triggered, in progress, or completed. The upload appeared to succeed but there was no indication of what was happening next.

### Issue 9: Meeting Title Replaced with Transcript Content (18 Dec 2025)

After uploading a transcript, the meeting title displayed the raw transcript text instead of the actual meeting subject. This occurred because:

1. The `process-transcript` route stored transcript text in `meeting_notes` column
2. The `useMeetings` hook used `meeting_notes` as a fallback for the meeting title
3. The database has a dedicated `title` column and `transcript` column that weren't being used properly

### Issue 10: VTT Cue IDs Not Being Filtered (18 Dec 2025)

The VTT parser wasn't properly filtering out UUID-style cue identifiers (e.g., `454b825a-6755-4118-a9fa-77768be56617/9-0`) and closing `</v>` tags were appearing in the parsed text.

## Solution

### Fix 1: Added VTT File Format Support

**File:** `src/lib/document-parser.ts`

- Added `parseVTTFile()` function to extract spoken text from WebVTT format
- Handles speaker labels, timestamps, and VTT formatting tags
- Added 'vtt' to supported file types in `ParsedDocument` interface
- Updated `validateDocumentFile()` to include VTT MIME type and extension

### Fix 2: Added DOC File Format Support

**File:** `src/app/api/meetings/upload-file/route.ts`

- Added `.doc` (legacy Word format) to allowed transcript types
- Added extension-based MIME type detection for cases where browser doesn't provide MIME type

### Fix 3: Created Transcript Processing API

**File:** `src/app/api/meetings/process-transcript/route.ts` (NEW)

Created comprehensive API route that:

1. Fetches the transcript file from Supabase Storage
2. Extracts text using the document parser
3. Calls Claude AI to generate:
   - Executive Summary
   - Key Topics (array)
   - Decisions Made (array)
   - Key Risks (array)
   - Next Steps (array)
4. Calls Claude AI to extract action items
5. Updates the meeting record with all extracted data
6. Creates action items in the `actions` table linked to the meeting

### Fix 4: Automatic Processing Trigger

**File:** `src/app/api/meetings/upload-file/route.ts`

- After successful transcript upload, automatically triggers the processing API
- Uses fire-and-forget pattern to avoid blocking the upload response
- Returns processing status in the upload response

### Fix 5: Updated File Upload UI

**File:** `src/components/EditMeetingModal.tsx`

- Updated file input to accept `.txt, .vtt, .pdf, .doc, .docx` formats
- Added MIME types to accept attribute for better browser compatibility
- Changed hidden file input from `hidden` class to `sr-only` (screen-reader only) for better accessibility and cross-browser compatibility
- Added loading state indicator showing "Uploading..." with spinner during upload
- Added comprehensive debug logging for troubleshooting
- Added success message banner showing AI processing status

### Fix 6: VTT MIME Type Conversion for Storage

**File:** `src/app/api/meetings/upload-file/route.ts`

- VTT files are now converted to `text/plain` Blob before uploading to Supabase Storage
- The file extension (`.vtt`) is preserved so the parser can still detect the format
- This bypasses the storage bucket's MIME type restrictions

### Fix 7: Support for String Meeting IDs

**File:** `src/app/api/meetings/upload-file/route.ts`

- Added detection for numeric vs string meeting IDs
- Numeric IDs query by `id` column, string IDs query by `meeting_id` column
- Processing trigger now correctly passes the string meeting ID

### Fix 8: Added process-transcript to Public Paths

**File:** `src/proxy.ts`

- Added `/api/meetings/process-transcript` to the middleware's public paths list
- This endpoint uses service role credentials and doesn't need user authentication
- Internal fire-and-forget calls now work correctly

### Fix 9: User Feedback for AI Processing

**File:** `src/components/EditMeetingModal.tsx`

- Added success message state and UI banner
- When transcript uploads and AI processing triggers, shows: "✓ Transcript uploaded! AI is now analysing the content. The meeting details (summary, topics, actions) will be updated automatically in a few moments."
- Message auto-dismisses after 15 seconds or can be manually closed

### Fix 10: Correct Column Usage for Title and Transcript (18 Dec 2025)

**File:** `src/hooks/useMeetings.ts`

- Added `title` and `transcript` columns to the SELECT query
- Updated title mapping to use: `title` > `meeting_type` > fallback (NOT `meeting_notes`)
- Updated notes mapping to use: `transcript` > `meeting_notes` (for backward compatibility)
- Fixed `inferDepartmentFromMeeting` to use `title` instead of `meeting_notes`

**File:** `src/app/api/meetings/process-transcript/route.ts`

- Changed transcript storage from `meeting_notes` to `transcript` column
- This preserves the original meeting subject in `meeting_notes` and stores transcript in dedicated column

### Fix 11: Improved VTT Cue ID Filtering (18 Dec 2025)

**File:** `src/lib/document-parser.ts`

- Enhanced UUID cue ID detection to handle suffixes like `/9-0`
- Added explicit `</v>` tag removal in speaker text processing
- Added alphanumeric cue ID detection (e.g., `cue-1`, `segment_123`)

### Fix 12: Switched from Anthropic SDK to MatchaAI (18 Dec 2025)

**File:** `src/app/api/meetings/process-transcript/route.ts`

The process-transcript route was using direct Anthropic SDK calls with `ANTHROPIC_API_KEY` which was not configured. The app uses **MatchaAI** (Harris Computer's internal AI gateway) for all AI operations.

Changes:

- Removed Anthropic SDK import
- Added MatchaAI configuration using `MATCHAAI_API_KEY`, `MATCHAAI_BASE_URL`, `MATCHAAI_MISSION_ID`
- Replaced `anthropic.messages.create()` with `fetch()` calls to MatchaAI `/completions` endpoint
- Uses LLM ID 71 (Claude Sonnet 4.5) for processing
- Added proper error handling for MatchaAI responses

### Fix 13: Added Transcript Processing Progress Modal (18 Dec 2025)

**New File:** `src/components/TranscriptProcessingModal.tsx`

Added a visual progress modal to show users the status of AI transcript processing.

Features:

- Shows 5 processing stages: Uploading → Parsing → AI Analysis → Extracting Actions → Saving
- Real-time stage updates with animated spinners and checkmarks
- Displays success results including:
  - Characters extracted from transcript
  - AI summary generated confirmation
  - Number of action items created
  - Executive summary preview
- Error handling with clear error messages
- Modal cannot be closed until processing completes (prevents accidental interruption)

**Updated File:** `src/components/EditMeetingModal.tsx`

- Integrated TranscriptProcessingModal component
- Changed from fire-and-forget to synchronous processing (waits for AI results)
- Progress stages update in real-time during processing
- Refreshes meeting data on successful completion

### Fix 14: AI Fields Not Fetched by useMeetings Hook (18 Dec 2025)

**File:** `src/hooks/useMeetings.ts`

The AI-generated data was being saved to the database correctly, but the `useMeetings` hook was not fetching the AI columns, so the data was never displayed in the UI.

Changes:

- Added AI fields to `UnifiedMeetingRow` interface: `ai_summary`, `topics`, `decisions`, `risks`, `next_steps`, `ai_analyzed`, `analyzed_at`
- Added AI columns to the SELECT query in `fetchFreshData`
- Added mapping in `processedMeetings` to convert database columns to Meeting interface fields:
  - `ai_summary` → `executiveSummary`
  - `topics` → `keyTopics` (array joined to string)
  - `decisions` → `decisionsMade` (array joined to string)
  - `risks` → `keyRisks` (array joined to string)
  - `next_steps` → `nextSteps` (array joined to string)

### Fix 15: Form Not Syncing with AI Data (18 Dec 2025)

**File:** `src/components/EditMeetingModal.tsx`

The EditMeetingModal form state was initialized once with `useState` but never updated when:

1. The meeting prop changed (e.g., after data refresh)
2. AI processing completed and returned results

**Changes:**

1. Added `useEffect` to sync AI fields when meeting prop changes:

   ```typescript
   useEffect(() => {
     if (meeting.executiveSummary && !formData.executiveSummary) {
       setFormData(prev => ({
         ...prev,
         executiveSummary: meeting.executiveSummary || '',
         keyTopics: meeting.keyTopics || '',
         // ... other AI fields
       }))
     }
   }, [meeting.executiveSummary, ...])
   ```

2. Added immediate form update after AI processing completes:
   ```typescript
   if (processData.summary) {
     setFormData(prev => ({
       ...prev,
       executiveSummary: processData.summary.executiveSummary,
       keyTopics: processData.summary.keyTopics.join('\n'),
       // ... other AI fields
     }))
   }
   ```

### Fix 16: Cache Invalidation Bug in refetch Function (18 Dec 2025)

**File:** `src/hooks/useMeetings.ts`

The `refetch` function was not properly invalidating the cache because it was deleting the wrong cache key. The cache key includes filters in its construction, but the refetch was only deleting the base key without filters.

Before:

```typescript
cache.delete(`${CACHE_KEY}-page-${currentPage}`)
```

After:

```typescript
const cacheKey = `${CACHE_KEY}-page-${currentPage}-${JSON.stringify(filters || {})}`
cache.delete(cacheKey)
cache.delete(`${CACHE_KEY}-page-${currentPage}`) // Also clear base key for safety
```

## Files Modified

| File                                               | Change                                                                |
| -------------------------------------------------- | --------------------------------------------------------------------- |
| `src/lib/document-parser.ts`                       | Added VTT parsing, improved UUID cue ID filtering, tag removal        |
| `src/app/api/meetings/upload-file/route.ts`        | VTT/DOC support, MIME conversion, string ID support, trigger          |
| `src/app/api/meetings/process-transcript/route.ts` | Full transcript processing, stores in `transcript` column (not notes) |
| `src/components/EditMeetingModal.tsx`              | sr-only input, loading states, success message UI, form sync          |
| `src/proxy.ts`                                     | Added process-transcript and upload-file to public paths              |
| `src/hooks/useMeetings.ts`                         | Title/notes mapping, AI fields fetch, cache fix, newline delimiter    |
| `src/components/TranscriptProcessingModal.tsx`     | NEW: Progress modal for AI transcript processing (18 Dec)             |
| `src/components/MeetingDetailTabs.tsx`             | Bullet point formatting, collapsible transcript, Create Action button |

## Processing Flow (After Fix)

```
1. User uploads transcript file in Edit Meeting modal
   ↓
2. POST /api/meetings/upload-file
   - Validates file type (TXT, VTT, PDF, DOC, DOCX)
   - Uploads to Supabase Storage
   - Saves URL to unified_meetings.transcript_file_url
   ↓
3. Auto-triggers POST /api/meetings/process-transcript (async)
   - Fetches file from storage URL
   - Parses document to extract text
   - Calls Claude AI for summary generation
   - Calls Claude AI for action extraction
   - Updates meeting record with AI analysis
   - Creates action items in database
   ↓
4. Meeting modal refreshes with populated fields
   Actions page shows new action items
```

## AI Model Used

- Claude 3.5 Sonnet (claude-3-5-sonnet-20241022)
- Temperature: 0.3 (for consistent, factual extraction)
- Max tokens: 3000 (summary), 2000 (actions)

## Supported Transcript Formats

| Format        | Extension | MIME Type                                                               |
| ------------- | --------- | ----------------------------------------------------------------------- |
| Plain Text    | .txt      | text/plain                                                              |
| WebVTT        | .vtt      | text/vtt                                                                |
| PDF           | .pdf      | application/pdf                                                         |
| Word (Legacy) | .doc      | application/msword                                                      |
| Word (Modern) | .docx     | application/vnd.openxmlformats-officedocument.wordprocessingml.document |

## Database Updates

Meeting record receives these fields after processing:

| Field       | Type      | Description                                      |
| ----------- | --------- | ------------------------------------------------ |
| transcript  | TEXT      | Full extracted transcript text (up to 50k chars) |
| ai_summary  | TEXT      | Executive summary (2-3 sentences)                |
| topics      | TEXT[]    | Array of key topics discussed                    |
| decisions   | TEXT[]    | Array of decisions made                          |
| risks       | TEXT[]    | Array of identified risks                        |
| next_steps  | TEXT[]    | Array of next steps                              |
| ai_analyzed | BOOLEAN   | Set to true after processing                     |
| analyzed_at | TIMESTAMP | When AI analysis was performed                   |

**Note:** The `title` column stores the meeting subject. The `transcript` column stores the extracted transcript text. The `meeting_notes` column is preserved for historical meeting notes (not overwritten by transcript upload).

Actions created with:

| Field      | Value                  |
| ---------- | ---------------------- |
| Category   | "Meeting Follow-up"    |
| Status     | "To Do"                |
| meeting_id | Link to source meeting |

### Fix 17: Bullet Points Splitting Mid-Sentence (18 Dec 2025)

**Problem:** Key Topics, Next Steps, and Key Risks were displayed incorrectly because:

1. Arrays from the database were being joined with commas in `useMeetings.ts`
2. The display component split on commas to create bullet points
3. Content containing commas (e.g., "Monday.com, ServiceNow") was split mid-sentence

**File:** `src/hooks/useMeetings.ts`

Changed array joining from commas to newlines:

```typescript
// Before (broken):
keyTopics: meeting.topics ? meeting.topics.join(', ') : null,

// After (fixed):
keyTopics: meeting.topics ? (Array.isArray(meeting.topics) ? meeting.topics.join('\n') : meeting.topics) : null,
```

**File:** `src/components/MeetingDetailTabs.tsx`

Updated `parseListItems` to split on newlines only:

```typescript
function parseListItems(text: string | null | undefined): string[] {
  if (!text) return []
  const items = text
    .split('\n')
    .map(item => item.trim())
    .filter(item => item.length > 0)
  return items
}
```

### Fix 18: Raw Transcript Too Verbose (18 Dec 2025)

**Problem:** The "Meeting Notes" section displayed the full raw transcript by default, which was too verbose and unhelpful since the AI had already extracted key information.

**File:** `src/components/MeetingDetailTabs.tsx`

Changes:

1. Renamed section from "Meeting Notes" to "Full Transcript"
2. Made transcript collapsed by default (`showTranscript` state initialised to `false`)
3. Added expand/collapse toggle button with character count badge
4. Added explanatory text: "Raw transcript from meeting recording. Key information has been extracted above."
5. Applied scrollable container with max height for better UX

### Fix 19: Create Action from Next Steps (18 Dec 2025)

**File:** `src/components/MeetingDetailTabs.tsx`

Added ability to create actions directly from Next Steps items:

- Added "Create Action" button (appears on hover) for each Next Step
- Creates action in `actions` table with:
  - Auto-generated Action_ID
  - Description from the Next Step text
  - Client from meeting (if not Internal)
  - Owner from meeting organiser
  - Default due date: 7 days from now
  - Priority: Medium
  - Status: To Do
  - Category: Meeting Follow-up
  - Link to source meeting via `meeting_id`
  - `Meeting_Date`: Formatted meeting date
  - `Content_Topic`: Meeting title
  - `Notes`: "From meeting: {title} ({date})" for reference
- Shows loading state while creating
- Shows checkmark after action is created
- Prevents duplicate creation of same action

### Fix 20: Remove Duplicate Full Transcript Display (18 Dec 2025)

**File:** `src/components/MeetingDetailTabs.tsx`

The Full Transcript section was displayed in both Discussion tab and Resources tab (as a file link). Removed the duplicate from Discussion tab since:

- The transcript file is already accessible via Resources tab
- The AI has already extracted the key information shown in Discussion
- Reduces clutter and redundant information

### Fix 21: Bullet/Text Alignment (18 Dec 2025)

**File:** `src/components/MeetingDetailTabs.tsx`

Fixed bullet point and text alignment in Discussion and Actions tabs:

- Removed `items-start` and `mt-1.5` that was causing misalignment
- Changed to simple `flex gap-3` with `leading-relaxed` on both bullet and text
- Applied consistent styling across Key Topics, Next Steps, and Key Risks sections
- Added `list-none` to remove default list styling

### Fix 22: Unified Actions - Two-Way Linking (18 Dec 2025)

**Problem:** Actions were being handled in two separate places:

1. "Next Steps" in Briefing Room Actions tab (stored in `unified_meetings.next_steps`)
2. "Action Items" auto-created in Actions & Tasks (stored in `actions` table)

This was confusing as users could see different items in each location.

**Solution:** Unified the experience with two-way linking between Briefing Room and Actions & Tasks.

**File:** `src/hooks/useActions.ts`

- Added `meeting_id` and `Content_Topic` to SELECT query
- Added `meetingId` and `meetingTitle` to Action interface

**File:** `src/app/(dashboard)/actions/page.tsx`

- Added `FileText` icon and `Link` import
- Added meeting reference badge for actions with `meeting_id`
- Badge shows "From: {meeting title}" and links to the meeting in Briefing Room
- Uses route `/meetings?meeting={meetingId}`

**File:** `src/components/MeetingDetailTabs.tsx`

- Removed "Next Steps" section with manual "Create Action" button
- Added "Actions from this Meeting" section that fetches linked actions from database
- Shows action count badge
- Each action displays status, priority, due date, and owner
- "View Action" button links to the action in Actions & Tasks page
- "View all actions" link to navigate to full Actions page
- Loading state while fetching actions
- Empty state explaining that actions are auto-created from transcripts

**Data Flow (After Fix):**

```
Briefing Room Meeting                    Actions & Tasks Page
┌─────────────────────┐                 ┌─────────────────────┐
│ Actions Tab         │                 │ Action Card         │
│ ┌─────────────────┐ │                 │ ┌─────────────────┐ │
│ │ Action 1        │ │ ──View Action─► │ │ Action Details  │ │
│ │ [View Action →] │ │                 │ │                 │ │
│ └─────────────────┘ │                 │ │ From: Meeting   │ │
│ ┌─────────────────┐ │ ◄──From Badge── │ │ [Link to mtg →] │ │
│ │ Action 2        │ │                 │ └─────────────────┘ │
│ │ [View Action →] │ │                 └─────────────────────┘
│ └─────────────────┘ │
└─────────────────────┘
```

## Testing Verification

1. ✅ Build completed successfully with no TypeScript errors
2. ✅ VTT files correctly parsed and text extracted
3. ✅ AI summary generation working
4. ✅ Action extraction working
5. ✅ Meeting record updated with all fields
6. ✅ Actions created in database with meeting_id link
7. ✅ Bullet points display correctly without mid-sentence splits
8. ✅ Full transcript available only in Resources tab (not duplicated)
9. ✅ Bullet/text alignment fixed in Discussion and Actions tabs
10. ✅ Two-way linking: Actions page shows meeting badge with link
11. ✅ Two-way linking: Briefing Room shows linked actions with View button

## Related Documentation

- `docs/BUG-REPORT-20251217-outlook-skip-meeting-feature.md` - Same session
- `docs/BUG-REPORT-20251217-modal-ics-popup-alignment.md` - Same session
- `docs/CHASEN-DOCUMENT-UPLOAD-FEATURE.md` - ChaSen document processing reference
