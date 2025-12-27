# unified_meetings Normalisation Plan

**Status:** PLANNED (Not Executed)
**Risk Level:** High
**Estimated Effort:** 4-6 hours

---

## Current State

The `unified_meetings` table has **54 columns**, making it difficult to:
- Query efficiently
- Add new fields logically
- Maintain data consistency

---

## Proposed Normalisation

### Keep in unified_meetings (16 columns)
```sql
id, meeting_id, title, client_name, client_uuid, client_id, cse_name,
meeting_date, meeting_time, duration, meeting_type, status,
is_internal, deleted, created_at, updated_at
```

### New Tables

#### 1. meeting_content (5 columns)
```sql
CREATE TABLE meeting_content (
  meeting_id UUID PRIMARY KEY REFERENCES unified_meetings(id),
  meeting_notes TEXT,
  transcript TEXT,
  transcript_file_url TEXT,
  recording_url TEXT,
  recording_file_url TEXT
);
```

#### 2. meeting_ai_analysis (6 columns)
```sql
CREATE TABLE meeting_ai_analysis (
  meeting_id UUID PRIMARY KEY REFERENCES unified_meetings(id),
  ai_analyzed BOOLEAN,
  ai_summary TEXT,
  ai_confidence_score DECIMAL,
  ai_tokens_used INTEGER,
  ai_cost DECIMAL,
  analyzed_at TIMESTAMPTZ
);
```

#### 3. meeting_sentiment (4 columns)
```sql
CREATE TABLE meeting_sentiment (
  meeting_id UUID PRIMARY KEY REFERENCES unified_meetings(id),
  sentiment_overall TEXT,
  sentiment_score DECIMAL,
  sentiment_client TEXT,
  sentiment_cse TEXT
);
```

#### 4. meeting_effectiveness (7 columns)
```sql
CREATE TABLE meeting_effectiveness (
  meeting_id UUID PRIMARY KEY REFERENCES unified_meetings(id),
  effectiveness_overall DECIMAL,
  effectiveness_preparation DECIMAL,
  effectiveness_participation DECIMAL,
  effectiveness_clarity DECIMAL,
  effectiveness_outcomes DECIMAL,
  effectiveness_follow_up DECIMAL,
  effectiveness_time_management DECIMAL
);
```

#### 5. meeting_insights (6 columns)
```sql
CREATE TABLE meeting_insights (
  meeting_id UUID PRIMARY KEY REFERENCES unified_meetings(id),
  topics JSONB,
  risks JSONB,
  highlights JSONB,
  next_steps JSONB,
  decisions JSONB,
  resources JSONB
);
```

#### 6. meeting_sync (5 columns)
```sql
CREATE TABLE meeting_sync (
  meeting_id UUID PRIMARY KEY REFERENCES unified_meetings(id),
  outlook_event_id TEXT,
  teams_meeting_id TEXT,
  synced_to_outlook BOOLEAN,
  attendees JSONB,
  organizer TEXT
);
```

#### 7. meeting_classification (5 columns)
```sql
CREATE TABLE meeting_classification (
  meeting_id UUID PRIMARY KEY REFERENCES unified_meetings(id),
  meeting_dept TEXT,
  department_code TEXT,
  activity_type_code TEXT,
  cross_functional BOOLEAN,
  linked_initiative_id UUID
);
```

---

## Backward Compatibility View

Create a view that joins all tables for backward compatibility:

```sql
CREATE OR REPLACE VIEW unified_meetings_full AS
SELECT
  m.*,
  c.meeting_notes, c.transcript, c.transcript_file_url, c.recording_url, c.recording_file_url,
  a.ai_analyzed, a.ai_summary, a.ai_confidence_score, a.ai_tokens_used, a.ai_cost, a.analyzed_at,
  s.sentiment_overall, s.sentiment_score, s.sentiment_client, s.sentiment_cse,
  e.effectiveness_overall, e.effectiveness_preparation, e.effectiveness_participation,
  e.effectiveness_clarity, e.effectiveness_outcomes, e.effectiveness_follow_up, e.effectiveness_time_management,
  i.topics, i.risks, i.highlights, i.next_steps, i.decisions, i.resources,
  sy.outlook_event_id, sy.teams_meeting_id, sy.synced_to_outlook, sy.attendees, sy.organizer,
  cl.meeting_dept, cl.department_code, cl.activity_type_code, cl.cross_functional, cl.linked_initiative_id
FROM unified_meetings m
LEFT JOIN meeting_content c ON m.id = c.meeting_id
LEFT JOIN meeting_ai_analysis a ON m.id = a.meeting_id
LEFT JOIN meeting_sentiment s ON m.id = s.meeting_id
LEFT JOIN meeting_effectiveness e ON m.id = e.meeting_id
LEFT JOIN meeting_insights i ON m.id = i.meeting_id
LEFT JOIN meeting_sync sy ON m.id = sy.meeting_id
LEFT JOIN meeting_classification cl ON m.id = cl.meeting_id;
```

---

## Migration Steps

1. Create new tables
2. Migrate data from unified_meetings to new tables
3. Create backward-compatibility view
4. Update application code to use specific tables where possible
5. Drop columns from unified_meetings
6. Add RLS policies to new tables

---

## Why Not Executed Now

- High risk of breaking production
- Requires extensive application code updates
- Need thorough testing environment
- Should be done during maintenance window

---

*Plan created by Claude Code on 2025-12-27*
