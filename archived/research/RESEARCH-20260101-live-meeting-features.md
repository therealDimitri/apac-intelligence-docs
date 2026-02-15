# Research: Live Meeting Dashboard Features

**Date:** 1 January 2026
**Status:** Research Complete
**Priority:** Enhancement

## Executive Summary
This document outlines proposed enhancements for the Briefing Room (meetings) feature, focusing on agenda management, recording integration, transcript capabilities, and live meeting status.

---

## Current State Analysis

### Existing Features (Already Implemented)

| Feature | Location | Status |
|---------|----------|--------|
| Meeting list with filters | `/meetings` | ✅ Active |
| Meeting detail page | `/meetings/[id]` | ✅ Active |
| AI Summary | `ai_summary` field | ✅ Active |
| Key Topics, Decisions, Risks, Next Steps | Parsed from arrays | ✅ Active |
| Meeting Notes | `meeting_notes` field | ✅ Active |
| Transcript link | `transcript_file_url` | ✅ Active (external link) |
| Recording link | `recording_file_url` | ✅ Active (external link) |
| Comments | `UnifiedComments` component | ✅ Active |
| Calendar view | `/meetings/calendar` | ✅ Active |
| Microsoft Graph integration | `src/lib/microsoft-graph.ts` | ✅ Active (Outlook sync) |

### Database Schema (unified_meetings)
```
- id, title, client_name, client_uuid
- meeting_date, meeting_time, duration
- meeting_type, meeting_notes, status
- organizer, cse_name, attendees
- ai_summary, topics, decisions, risks, next_steps
- transcript_file_url, recording_file_url
- teams_meeting_id, outlook_event_id
```

---

## Proposed Enhancements

### 1. Agenda Management System

**Purpose:** Allow CSEs to prepare structured agendas before meetings and track discussion items during.

**Features:**
- **Pre-meeting agenda builder** with drag-and-drop items
- **Time allocation** per agenda item
- **Carry-over items** from previous meetings
- **Agenda templates** for QBRs, Check-ins, Escalations
- **Real-time progress tracking** during meetings
- **Post-meeting comparison** (planned vs actual)

**Database Changes:**
```sql
CREATE TABLE meeting_agendas (
  id UUID PRIMARY KEY,
  meeting_id INTEGER REFERENCES unified_meetings(id),
  agenda_items JSONB, -- [{title, duration, notes, status, order}]
  template_id UUID,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE agenda_templates (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  meeting_type TEXT,
  items JSONB, -- [{title, default_duration, description}]
  created_by TEXT,
  is_default BOOLEAN DEFAULT false
);
```

**UI Components:**
- `AgendaBuilder.tsx` - Drag-and-drop agenda creation
- `AgendaProgress.tsx` - Live meeting agenda tracker
- `AgendaTemplates.tsx` - Template management

---

### 2. Recording Integration (Microsoft Teams)

**Purpose:** Embed Teams meeting recordings directly in the meeting detail page instead of external links.

**Microsoft Graph API Endpoints:**
```
GET /me/onlineMeetings/{meetingId}/recordings
GET /me/onlineMeetings/{meetingId}/transcripts
```

**Required Permissions:**
- `OnlineMeetings.Read`
- `OnlineMeetingRecording.Read.All`
- `OnlineMeetingTranscript.Read.All`

**Features:**
- **Embedded video player** for Teams recordings
- **Seek to timestamp** from transcript highlights
- **Chapter markers** based on agenda items
- **Recording metadata** (duration, file size, participants)
- **Download option** for offline access

**Implementation:**
```typescript
// src/lib/teams-recordings.ts
export async function getMeetingRecording(
  accessToken: string,
  meetingId: string
): Promise<RecordingInfo> {
  const response = await fetch(
    `https://graph.microsoft.com/v1.0/me/onlineMeetings/${meetingId}/recordings`,
    { headers: { Authorization: `Bearer ${accessToken}` } }
  );
  return response.json();
}
```

---

### 3. Transcript Integration

**Purpose:** Display and search meeting transcripts with speaker identification and AI-powered insights.

**Features:**
- **Full transcript viewer** with timestamps
- **Speaker identification** and colour coding
- **Search within transcript** with highlighting
- **Auto-generated action items** from transcript
- **Key quote extraction** for meeting summaries
- **Export as PDF/Word** with formatting

**Microsoft Graph API:**
```
GET /me/onlineMeetings/{meetingId}/transcripts
GET /me/onlineMeetings/{meetingId}/transcripts/{transcriptId}/content?$format=text/vtt
```

**Database Changes:**
```sql
ALTER TABLE unified_meetings ADD COLUMN transcript_content TEXT;
ALTER TABLE unified_meetings ADD COLUMN transcript_metadata JSONB;
-- metadata: {speakers: [], duration_seconds, word_count, key_quotes: []}
```

**AI Enhancement:**
- Use ChaSen AI to analyse transcripts
- Extract action items automatically
- Identify sentiment per speaker
- Summarise key discussion points

---

### 4. Live Meeting Status

**Purpose:** Show real-time status for ongoing meetings.

**Features:**
- **"In Progress" badge** for active meetings
- **Live attendee count** from Teams
- **Meeting duration timer**
- **Quick access** to join meeting link
- **Real-time notes sync** (collaborative)

**Implementation:**
- WebSocket connection for live updates
- Microsoft Graph webhooks for meeting status
- Presence API for attendee status

**Graph API:**
```
POST /subscriptions (webhook for meeting status)
GET /communications/onlineMeetings/{meetingId}
```

---

### 5. Meeting Analytics Dashboard

**Purpose:** Provide insights on meeting patterns and effectiveness.

**Metrics:**
- Meetings per client per quarter
- Average meeting duration by type
- Attendance rates
- Follow-up action completion rate
- Meeting-to-action conversion
- NPS correlation with meeting frequency

**Visualisations:**
- Meeting frequency heatmap
- Duration trends chart
- Meeting type breakdown
- CSE meeting load distribution

---

## Technical Implementation Roadmap

### Phase 1: Agenda System (2-3 weeks)
1. Create agenda database tables
2. Build AgendaBuilder component
3. Add agenda to meeting detail page
4. Create default templates (QBR, Check-in, Escalation)

### Phase 2: Transcript Enhancement (2-3 weeks)
1. Add transcript storage to database
2. Build transcript viewer component
3. Implement search functionality
4. Add AI-powered insights extraction

### Phase 3: Recording Embed (2-3 weeks)
1. Request OnlineMeetingRecording.Read permissions
2. Build video player component
3. Implement chapter markers
4. Add download functionality

### Phase 4: Live Features (3-4 weeks)
1. Set up Microsoft Graph webhooks
2. Build WebSocket infrastructure
3. Create live meeting indicator
4. Add collaborative notes

### Phase 5: Analytics (2 weeks)
1. Create analytics API endpoints
2. Build dashboard components
3. Add visualisation charts

---

## Required Microsoft Graph Permissions

| Permission | Type | Purpose |
|------------|------|---------|
| `Calendars.Read` | Delegated | ✅ Already have - Calendar sync |
| `OnlineMeetings.Read` | Delegated | Meeting details |
| `OnlineMeetingRecording.Read.All` | Application | Access recordings |
| `OnlineMeetingTranscript.Read.All` | Application | Access transcripts |

---

## Recommended Priority

1. **High Priority**: Agenda Management - Improves meeting preparation
2. **High Priority**: Transcript Enhancement - Better meeting documentation
3. **Medium Priority**: Recording Embed - Better user experience
4. **Medium Priority**: Meeting Analytics - Strategic insights
5. **Lower Priority**: Live Status - Nice-to-have for real-time tracking

---

## Next Steps

1. Review this research with stakeholders
2. Prioritise features based on user feedback
3. Request additional Graph API permissions if needed
4. Begin Phase 1 implementation (Agenda System)
