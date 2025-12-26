# Enhancement: Live Meeting Mode

**Date:** 2025-12-01
**Type:** Feature Enhancement
**Priority:** HIGH - Game-changing capability
**Status:** Design Phase

---

## Executive Summary

Transform the dashboard into a **Live Meeting Command Center** that meeting organisers can use **during** client calls to:

1. Present agenda and data visualisations
2. Review and update alerts/actions in real-time
3. Capture decisions and next steps
4. Auto-record and transcribe meetings
5. Generate post-meeting summaries

**Inspiration:** Gong.io, Fireflies.ai, Fellow.app, Zoom Team Chat

---

## User's Requirements

1. ✅ Present agenda and slides
2. ✅ Review key alerts, actions and auto-update the dashboard
3. ✅ Review and share new information
4. ✅ Auto-record meeting so transcript is ready after the call

---

## Proposed Features

### 1. Live Meeting Mode Toggle

**Feature:** "Start Live Meeting" button on Briefing Room

**What happens when activated:**

- Dashboard enters "Presentation Mode" (fullscreen, clean UI)
- All attendees can view the shared screen
- Real-time collaboration panel appears
- Meeting timer starts
- Auto-record begins (if enabled)

**UI Changes:**

```
┌─────────────────────────────────────────────────────────┐
│ 🔴 LIVE: SingHealth QBR - 00:14:32   [End Meeting]     │
├─────────────────────────────────────────────────────────┤
│ Tabs: [Agenda] [Alerts] [Actions] [Insights] [Notes]  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Current view (fullscreen, clean design)               │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Technical Implementation:**

- Toggle component state: `liveMeetingMode: boolean`
- Timer component with start/pause/stop
- Fullscreen API for presentation mode
- WebRTC or Zoom SDK integration for recording

---

### 2. Interactive Agenda with Progress Tracking

**Feature:** Live agenda that tracks progress through meeting topics

**Capabilities:**

- ✅ Check off agenda items as discussed
- ⏱️ Time allocation per topic (actual vs planned)
- 🎯 Focus mode (highlights current topic)
- ⚡ Quick jump to any agenda item

**UI Example:**

```
Agenda (14 min elapsed, 46 min remaining)

✅ 1. Welcome & Introductions (5 min) → 4 min actual
✅ 2. Q3 Performance Review (15 min) → 18 min actual  ⚠️ Over
→ 3. Platform Adoption Metrics (10 min) ← CURRENT
  4. Mobile App Concerns (15 min)
  5. Q4 Strategic Planning (15 min)
```

**Organiser Actions:**

- Click "Start" to begin a topic (sets timer)
- Click "Complete" to mark done and move to next
- Click "Skip" to defer a topic
- Drag to reorder topics mid-meeting

**Post-Meeting Value:**

- Time audit: Which topics took longer than planned?
- Agenda compliance: Did we cover everything?
- Next meeting: Suggest time adjustments based on actuals

---

### 3. Live Alert & Action Dashboard with Click-to-Update

**Feature:** Review alerts/actions and update them in real-time during the meeting

**Use Case:**

> **Organiser:** "Let's review the overdue actions..."
> _Clicks on Actions tab_
> **Dashboard:** Shows 3 overdue actions for this client
> **Organiser:** _Clicks action O23_
> **Client:** "Yes, we completed that last week"
> **Organiser:** _Click → Mark Complete_
> **Dashboard:** ✅ Action updated, removed from overdue list (instantly)

**UI Features:**

- **Quick Action Buttons:**
  - Mark Complete
  - Reassign Owner
  - Update Due Date
  - Add Note
  - Create Follow-up Action

- **Live Filtering:**
  - Show only this client's alerts/actions
  - Hide completed items (toggle)
  - Group by priority/category

**Keyboard Shortcuts:**

- `C` - Mark current item complete
- `E` - Edit item
- `N` - Add note
- `→` - Next item
- `←` - Previous item

---

### 4. Real-Time Collaborative Notes & Decisions Capture

**Feature:** Shared notes pane where meeting organiser captures key points LIVE

**Capabilities:**

1. **Decisions Made:**
   - Quick-add button: "Capture Decision"
   - Auto-numbered (Decision #1, #2, #3)
   - Tag with owner/due date

2. **Action Items Extraction:**
   - Type action in notes
   - Highlight text → "Convert to Action"
   - Auto-populate: Description, Owner (from attendees), Due Date

3. **Risk Flags:**
   - Type risk → Auto-detect keywords ("concern", "risk", "blocker")
   - Quick tag as risk item
   - Color-coded (Red = High, Yellow = Medium)

4. **Parking Lot:**
   - Off-topic items → Quick "Park for later"
   - Revisit at end of meeting

**UI Example:**

```
┌─ Real-Time Notes ────────────────────────────────────┐
│ [Decisions] [Actions] [Risks] [Parking Lot]         │
├──────────────────────────────────────────────────────┤
│ Decision #1: Approved Q4 mobile roadmap              │
│   Owner: John Doe                                    │
│   Due: 2025-12-15                                    │
│                                                      │
│ Decision #2: Defer chatbot feature to 2026          │
│   Reason: Resource constraints                      │
│                                                      │
│ [+ Add Decision]                                     │
└──────────────────────────────────────────────────────┘
```

**Auto-Save:**

- Notes saved every 10 seconds
- Sync to meeting record in database
- Available in post-meeting view

---

### 5. Auto-Record & Transcription

**Feature:** Automatic meeting recording with AI transcription

**Integration Options:**

#### Option A: Zoom SDK Integration

- Requires Zoom app installed
- Auto-start recording when "Start Live Meeting" clicked
- Auto-upload recording to Zoom cloud
- Fetch transcript via Zoom API
- Store in dashboard

**Zoom API Flow:**

```
1. Start Meeting → Zoom.startRecording()
2. End Meeting → Zoom.stopRecording()
3. Zoom processes → Generates transcript
4. Webhook → Dashboard receives transcript
5. Store in unified_meetings.transcript field
```

#### Option B: Microsoft Teams Integration

- Same flow as Zoom but via Teams API
- Stores recording in SharePoint
- Transcript via Teams AI

#### Option C: Fireflies.ai / Otter.ai Integration

- Meeting bot joins as participant
- Auto-transcribes and sends to dashboard
- Includes speaker identification
- Generates AI summary

**Recommended:** Start with **Zoom SDK** (most common in enterprise)

**Features:**

- ✅ Auto-start recording when Live Meeting begins
- ✅ Auto-stop when meeting ends
- ✅ AI transcription with speaker labels
- ✅ Searchable transcript
- ✅ Highlight key moments (decisions, action items)
- ✅ Download transcript (PDF/DOCX)

---

### 6. Live Data Visualisation & Screen Sharing

**Feature:** Share live dashboard data with clients on screen

**Capabilities:**

1. **Present Mode (Fullscreen Viz):**
   - NPS trend chart (last 12 months)
   - Action completion rate
   - Platform adoption metrics
   - Segmentation event compliance

2. **Interactive Charts:**
   - Click on data point → Drill down
   - Hover over chart → Show details
   - Toggle between views (line/bar/pie)

3. **Annotations:**
   - Draw on screen (like Zoom whiteboard)
   - Highlight key data points
   - Add arrows/text during presentation

4. **Snapshot & Export:**
   - Click "Snapshot" → Saves current view
   - Auto-attach to meeting notes
   - Export to PDF for client email

**UI Example:**

```
┌─ Presenting: NPS Trend (Last 12 Months) ─────────────┐
│                                                       │
│    90 ┼─────────────╮                                │
│       │             │                                │
│    80 ┤             ╰───╮                            │
│       │                 │                            │
│    70 ┤                 ╰───╮  ← "Dip due to..."     │
│       │                     │                        │
│    60 ┤                     ╰─                       │
│       └─────────────────────────────────            │
│        Q1   Q2   Q3   Q4                            │
│                                                       │
│  [📸 Snapshot] [📊 Switch View] [✏️ Annotate]        │
└───────────────────────────────────────────────────────┘
```

---

### 7. Post-Meeting Auto-Summary

**Feature:** AI generates meeting summary immediately after call ends

**Generated Content:**

1. **Executive Summary:**
   - Auto-generated from transcript + notes
   - 3-5 bullet points
   - Client sentiment score

2. **Decisions Made:**
   - Extracted from Real-Time Notes
   - Numbered list with owners

3. **Action Items:**
   - Auto-created in Actions & Tasks
   - Linked to meeting record
   - Assigned owners with due dates

4. **Key Topics Discussed:**
   - AI extracts from transcript
   - Topic frequency analysis
   - Time spent per topic

5. **Risk Items:**
   - Flagged concerns/blockers
   - Recommended follow-ups

6. **Next Meeting Suggestions:**
   - Recommended date (based on follow-up actions)
   - Suggested agenda (unfinished topics + action follow-ups)

**Email to Attendees:**

```
Subject: Meeting Summary: SingHealth QBR - 2025-12-01

Hi [Attendees],

Thank you for joining today's Quarterly Business Review. Here's a summary:

🎯 Decisions Made:
1. Approved Q4 mobile optimisation roadmap (Owner: John Doe, Due: Dec 15)
2. Defer chatbot feature to 2026 (Reason: Resource constraints)

✅ Action Items Created:
- Schedule mobile demo (Owner: Jane Smith, Due: Dec 10)
- Share Q4 product roadmap (Owner: Bob Lee, Due: Dec 8)

📊 Key Topics:
- Q3 Performance (18 min) - 35% adoption increase discussed
- Mobile App Concerns (12 min) - Optimization plan agreed

⚠️ Risks Flagged:
- None

📅 Next Steps:
- Follow-up meeting suggested: Dec 20, 2025
- Agenda: Mobile demo, Q4 planning

View full transcript and recording: [Link to Dashboard]

Best regards,
[Organiser Name]
```

---

### 8. Attendee Presence & Engagement Tracking

**Feature:** Track who attended and participation levels

**Capabilities:**

1. **Attendee List:**
   - Auto-populate from meeting invites
   - Mark present/absent
   - Track join/leave times

2. **Engagement Metrics:**
   - Speaking time per attendee (from transcript)
   - Questions asked
   - Action items assigned

3. **Participation Heatmap:**
   - Visual representation of engagement
   - Color-coded: Green (active), Yellow (moderate), Red (quiet)

**UI Example:**

```
Attendees (5/6 present)

✅ John Doe (Client)      Speaking: 18 min  🟢 Active
✅ Jane Smith (Client)    Speaking: 12 min  🟢 Active
✅ Bob Lee (Altera)       Speaking: 22 min  🟢 Active
✅ Sarah Chen (Altera)    Speaking: 4 min   🟡 Moderate
❌ Mike Brown (Client)    Absent
✅ Amy Li (Client)        Speaking: 2 min   🟡 Moderate
```

---

## Additional Functionality Ideas (Bonus)

### 9. Live Sentiment Analysis

**Feature:** Real-time sentiment tracking during meeting

- AI analyses transcript in real-time
- Sentiment gauge: 😊 Positive, 😐 Neutral, 😞 Negative
- Alert organiser if sentiment drops (e.g., client frustrated)

**Use Case:**

> Sentiment drops to "Negative" when discussing mobile app bugs
> → Dashboard alerts organiser: "⚠️ Sentiment alert: Client concerns about mobile app"
> → Organiser addresses concern immediately

### 10. Smart Meeting Pacing

**Feature:** AI assistant suggests pacing adjustments

**Examples:**

- "⚠️ You're 5 min over on this topic. Skip to next?"
- "✅ Agenda on track. 15 min buffer remaining."
- "⏰ 10 min left. Wrap up current topic?"

### 11. Live Q&A Panel

**Feature:** Clients submit questions during meeting

- Attendees type questions in sidebar
- Organiser sees questions in queue
- Click to address or defer to parking lot

### 12. Integration with Meeting Room Displays

**Feature:** Cast dashboard to conference room TV

- Wireless screen mirroring
- Large-format dashboard view
- Touch-enabled interaction (if smart display)

### 13. Virtual Breakout Rooms

**Feature:** Split into smaller groups mid-meeting

**Use Case:**

> Main meeting: Review overall performance
> Breakout 1: Technical team discusses mobile app
> Breakout 2: Business team discusses pricing
> Rejoin: Share outcomes from each breakout

### 14. AI Meeting Coach

**Feature:** Real-time coaching for meeting organiser

**Suggestions:**

- "You've been talking for 8 min straight. Ask a question."
- "John hasn't spoken in 15 min. Engage him?"
- "This topic is over time. Consider tabling it."

### 15. Client Sentiment Survey (End of Meeting)

**Feature:** Quick 2-question survey sent to clients

**Questions:**

1. How valuable was this meeting? (1-5 stars)
2. What should we improve for next time? (Free text)

**Results:**

- Stored in dashboard
- Trend over time (meeting quality improvement)
- Correlate with NPS scores

---

## Technical Architecture

### Frontend Components

```
src/components/live-meeting/
├── LiveMeetingMode.tsx           - Main container, fullscreen toggle
├── LiveAgenda.tsx                - Interactive agenda with timer
├── LiveActions.tsx               - Quick-update actions panel
├── LiveNotes.tsx                 - Real-time collaborative notes
├── LiveDataViz.tsx               - Presentation mode for charts
├── RecordingControls.tsx         - Start/stop recording
├── AttendeePanel.tsx             - Presence & engagement tracking
├── SentimentGauge.tsx            - Real-time sentiment display
├── PostMeetingSummary.tsx        - AI-generated summary
└── LiveMeetingToolbar.tsx        - Quick actions toolbar
```

### Backend Services

```
src/app/api/live-meeting/
├── start/route.ts                - Start live meeting session
├── end/route.ts                  - End session, generate summary
├── notes/route.ts                - Real-time notes sync
├── recording/route.ts            - Recording controls
├── transcript/route.ts           - Fetch/store transcript
└── summary/route.ts              - AI summary generation
```

### Database Schema

```sql
-- Add to unified_meetings table
ALTER TABLE unified_meetings
ADD COLUMN live_session_data JSONB DEFAULT '{}'::jsonb;

-- Structure:
{
  "session_id": "live_abc123",
  "started_at": "2025-12-01T10:00:00Z",
  "ended_at": "2025-12-01T11:00:00Z",
  "duration_minutes": 60,
  "attendee_presence": [
    {"name": "John Doe", "present": true, "speaking_time_min": 18}
  ],
  "agenda_progress": [
    {"topic": "Q3 Review", "planned_min": 15, "actual_min": 18, "completed": true}
  ],
  "sentiment_timeline": [
    {"time": "00:05:00", "sentiment": "positive", "score": 85},
    {"time": "00:25:00", "sentiment": "neutral", "score": 60}
  ],
  "recording_url": "https://zoom.us/rec/...",
  "transcript_url": "https://...",
  "live_notes": {
    "decisions": ["Approved Q4 roadmap", "Defer chatbot to 2026"],
    "risks": ["Mobile app performance concerns"],
    "parking_lot": ["Discuss pricing in Q1"]
  }
}
```

---

## Integration Requirements

### 1. Zoom SDK

```bash
npm install @zoom/meetingsdk
```

**Setup:**

- Register Zoom OAuth app
- Obtain API key/secret
- Implement OAuth flow for meeting hosts

### 2. Microsoft Teams SDK

```bash
npm install @microsoft/teams-js
```

### 3. AI Transcription (Fireflies.ai / Otter.ai)

- API key required
- Webhook setup for transcripts

### 4. WebRTC (for browser-based recording)

```bash
npm install recordrtc
```

---

## Implementation Roadmap

### Phase 1: Core Live Meeting Mode (Week 1)

- ✅ Live Meeting toggle
- ✅ Timer component
- ✅ Interactive agenda
- ✅ Live notes capture
- ✅ Quick-update actions

### Phase 2: Recording & Transcription (Week 2)

- ✅ Zoom SDK integration
- ✅ Auto-record functionality
- ✅ Transcript fetch & storage
- ✅ Post-meeting summary generation

### Phase 3: Advanced Features (Week 3)

- ✅ Live data visualizations
- ✅ Sentiment analysis
- ✅ Attendee engagement tracking
- ✅ AI meeting coach

### Phase 4: Integrations (Week 4)

- ✅ MS Teams integration
- ✅ Email auto-send summaries
- ✅ Calendar integration for next meeting
- ✅ Fireflies.ai / Otter.ai backup

---

## Success Metrics

**Adoption:**

- % of meetings using Live Mode
- Average time savings per meeting
- User satisfaction score

**Quality:**

- Action items captured per meeting (vs manual)
- Decisions documented (vs missed)
- Transcript accuracy
- Post-meeting summary quality

**Engagement:**

- Client participation improvement
- Meeting time reduced (better pacing)
- Action completion rate improvement

---

## Competitive Analysis

| Feature                 | Gong.io | Fireflies.ai | Fellow.app | **Our Dashboard** |
| ----------------------- | ------- | ------------ | ---------- | ----------------- |
| Auto-record             | ✅      | ✅           | ✅         | ✅ (Planned)      |
| AI Transcript           | ✅      | ✅           | ✅         | ✅ (Planned)      |
| Action Extraction       | ✅      | ✅           | ✅         | ✅ (Planned)      |
| Live Dashboard          | ❌      | ❌           | ✅         | ✅ **UNIQUE**     |
| Client Data Integration | ❌      | ❌           | ❌         | ✅ **UNIQUE**     |
| Real-time NPS/Alerts    | ❌      | ❌           | ❌         | ✅ **UNIQUE**     |
| Post-meeting Email      | ✅      | ✅           | ✅         | ✅ (Planned)      |

**Our Advantage:** Only solution that combines meeting management with live client health data.

---

## Next Steps

1. ✅ Review and approve this design
2. ⏳ Build Phase 1 prototype (Core Live Meeting Mode)
3. ⏳ User testing with CSE team
4. ⏳ Zoom SDK integration (Phase 2)
5. ⏳ Full rollout

---

**Document Version:** 1.0
**Last Updated:** 2025-12-01
**Author:** Claude Code
**Reviewers:** Jimmy Leimonitis
