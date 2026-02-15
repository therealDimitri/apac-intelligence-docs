# ChaSen AI Learning Enhancements Guide

This guide covers the learning and personalisation features implemented in ChaSen AI, enabling the system to improve over time based on user interactions and feedback.

## Overview

The learning system consists of four phases:

| Phase | Feature              | Purpose                                           |
| ----- | -------------------- | ------------------------------------------------- |
| 1     | Implicit Signals     | Track user engagement without explicit feedback   |
| 2     | User Preferences     | Remember personalisation settings across sessions |
| 3     | Self-Learning Q&A    | Build knowledge from positive feedback            |
| 4     | Cross-Session Memory | Learn facts about users over time                 |

---

## Phase 1: Implicit Signals Tracking

### What It Tracks

The system automatically tracks user behaviour signals that indicate satisfaction or dissatisfaction:

| Signal Type                | Indicates | Tracked When                        |
| -------------------------- | --------- | ----------------------------------- |
| `copy`                     | Positive  | User copies response content        |
| `export_pdf`               | Positive  | User exports to PDF                 |
| `export_word`              | Positive  | User exports to Word                |
| `follow_up`                | Positive  | User clicks a follow-up question    |
| `quick_insight_click`      | Positive  | User clicks a Quick Insight card    |
| `suggested_question_click` | Positive  | User clicks a suggested question    |
| `regenerate`               | Negative  | User regenerates a response         |
| `abandon`                  | Negative  | User abandons a conversation        |
| `new_chat`                 | Neutral   | User starts a new chat              |
| `conversation_load`        | Neutral   | User loads an existing conversation |

### Using the Hook

```typescript
import { useChaSenSignals } from '@/hooks/useChaSenSignals'

function MyComponent() {
  const {
    trackCopy,
    trackExportPdf,
    trackExportWord,
    trackFollowUp,
    trackQuickInsightClick,
    trackSuggestedQuestionClick,
    trackNewChat,
    trackAbandon,
    getSessionId,
  } = useChaSenSignals(userEmail)

  // Track when user copies content
  const handleCopy = (messageId: string, text: string) => {
    navigator.clipboard.writeText(text)
    trackCopy(messageId, text)
  }

  // Track PDF export
  const handleExportPdf = (messageId: string, reportType: string) => {
    trackExportPdf(messageId, reportType)
    // ... export logic
  }

  // Track follow-up question click
  const handleFollowUp = (originalQuery: string, question: string) => {
    trackFollowUp(originalQuery, question)
    sendMessage(question)
  }
}
```

### Database Table

```sql
-- chasen_implicit_signals
CREATE TABLE chasen_implicit_signals (
  id UUID PRIMARY KEY,
  session_id TEXT NOT NULL,
  user_email TEXT,
  message_id TEXT,
  signal_type TEXT NOT NULL,
  signal_value JSONB DEFAULT '{}',
  query_text TEXT,
  response_preview TEXT,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);
```

### API Endpoint

**POST** `/api/chasen/signals`

```json
{
  "sessionId": "session_1703318400000_abc123",
  "signalType": "copy",
  "userEmail": "user@example.com",
  "messageId": "msg_123",
  "signalValue": { "copiedLength": 250 }
}
```

---

## Phase 2: User Preferences Memory

### Preference Options

| Preference          | Options                          | Default      |
| ------------------- | -------------------------------- | ------------ |
| `preferred_tone`    | professional, casual, formal     | professional |
| `preferred_format`  | detailed, concise, bullet_points | detailed     |
| `detail_level`      | low, medium, high                | medium       |
| `favourite_clients` | Array of client names            | []           |
| `ai_preferences`    | JSON object with feature flags   | see below    |

**AI Preferences Structure:**

```json
{
  "includeRecommendations": true,
  "includeFollowUps": true,
  "includeDataHighlights": true,
  "maxResponseLength": "medium"
}
```

### Using the Hook

```typescript
import { useChaSenPreferences } from '@/hooks/useChaSenPreferences'

function SettingsComponent() {
  const {
    preferences,
    loading,
    updatePreferences,
    setPreferredTone,
    setPreferredFormat,
    setDetailLevel,
    addFavouriteClient,
    removeFavouriteClient,
  } = useChaSenPreferences(userEmail)

  // Update tone preference
  const handleToneChange = (tone: string) => {
    setPreferredTone(tone)
  }

  // Add favourite client
  const handleAddFavourite = (clientName: string) => {
    addFavouriteClient(clientName)
  }

  // Bulk update
  const handleSaveAll = () => {
    updatePreferences({
      preferred_tone: 'casual',
      preferred_format: 'bullet_points',
      detail_level: 'high',
    })
  }
}
```

### API Endpoints

**GET** `/api/chasen/preferences?userEmail=user@example.com`

**POST** `/api/chasen/preferences`

```json
{
  "userEmail": "user@example.com",
  "preferredTone": "professional",
  "preferredFormat": "detailed",
  "detailLevel": "medium"
}
```

**PATCH** `/api/chasen/preferences`

```json
{
  "userEmail": "user@example.com",
  "updates": {
    "preferred_tone": "casual"
  }
}
```

### How Preferences Affect Responses

When a user has preferences set, ChaSen automatically:

1. Adjusts response verbosity based on `detail_level`
2. Adapts tone based on `preferred_tone`
3. Formats output based on `preferred_format`
4. Prioritises favourite clients in portfolio summaries

---

## Phase 3: Self-Learning Q&A Pairs

### How It Works

1. User asks a question
2. ChaSen provides a response
3. User marks response as "Helpful" with confidence ≥ 0.7
4. System extracts question pattern and stores the Q&A pair
5. Future similar questions can reference learned responses

### Similarity Matching

The system uses Jaccard similarity to match new questions against learned patterns:

```typescript
// Example: If a user asks about "at-risk clients"
// and we have a learned Q&A for "which clients are at risk"
// The similarity score determines if we can use the learned response
```

### Database Table

```sql
-- chasen_learned_qa
CREATE TABLE chasen_learned_qa (
  id UUID PRIMARY KEY,
  question_pattern TEXT NOT NULL,
  ideal_response TEXT NOT NULL,
  detected_intent TEXT,
  category TEXT DEFAULT 'general',
  confidence_score DECIMAL(3,2) DEFAULT 0.70,
  use_count INTEGER DEFAULT 1,
  last_used_at TIMESTAMPTZ,
  is_approved BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  source_feedback_id UUID
);
```

### API Endpoint

**GET** `/api/chasen/learned-qa?query=at-risk clients&intent=risk_analysis`

Returns matching Q&A pairs ranked by similarity and confidence.

---

## Phase 4: Cross-Session Memory

### Memory Types

| Type           | Description                             | Example                            |
| -------------- | --------------------------------------- | ---------------------------------- |
| `preference`   | User preferences learned from behaviour | "Prefers concise responses"        |
| `context`      | Work context information                | "Focuses on enterprise clients"    |
| `fact`         | Factual information about the user      | "Based in Sydney office"           |
| `relationship` | Client/team relationships               | "Primary contact for Acme Corp"    |
| `behaviour`    | Usage patterns                          | "Frequently asks about NPS trends" |

### Automatic Memory Extraction

The system automatically extracts memories from conversations:

```typescript
// User says: "I'm working with Acme Corp on their renewal"
// System extracts:
{
  type: 'relationship',
  key: 'client_interest',
  value: 'Acme Corp',
  confidence: 0.7
}

// User says: "I prefer brief summaries"
// System extracts:
{
  type: 'preference',
  key: 'response_style',
  value: 'concise',
  confidence: 0.75
}
```

### Using the Hook

```typescript
import { useChaSenMemories } from '@/hooks/useChaSenMemories'

function MemoryComponent() {
  const {
    memories,
    byType,
    loading,
    addMemory,
    deleteMemory,
    getMemoryContext
  } = useChaSenMemories(userEmail)

  // Manually add a memory
  const handleAddMemory = () => {
    addMemory('preference', 'timezone', 'AEST', 0.9)
  }

  // Get formatted context for AI prompt
  const injectContext = async () => {
    const context = await getMemoryContext()
    // Returns formatted string for prompt injection
  }

  // Display memories by type
  return (
    <div>
      {byType.preference?.map(mem => (
        <div key={mem.id}>
          {mem.memory_key}: {mem.memory_value}
          <button onClick={() => deleteMemory(mem.id)}>Delete</button>
        </div>
      ))}
    </div>
  )
}
```

### API Endpoints

**GET** `/api/chasen/memories?userEmail=user@example.com`

**GET** `/api/chasen/memories?userEmail=user@example.com&forPrompt=true`
Returns formatted context string for prompt injection.

**POST** `/api/chasen/memories`

```json
{
  "userEmail": "user@example.com",
  "memoryType": "preference",
  "memoryKey": "response_style",
  "memoryValue": "detailed",
  "confidence": 0.8,
  "source": "explicit"
}
```

**DELETE** `/api/chasen/memories`

```json
{
  "memoryId": "uuid-here",
  "userEmail": "user@example.com"
}
```

---

## Analytics Dashboard

Access the learning analytics at: `/ai/analytics`

### Metrics Displayed

| Metric             | Description                         |
| ------------------ | ----------------------------------- |
| Health Score       | Overall system performance (0-100%) |
| Total Interactions | Combined feedback + signals         |
| Helpful Rate       | Percentage of helpful responses     |
| Avg Confidence     | Intent detection accuracy           |

### Visualisations

- **Feedback Breakdown**: Helpful vs Not Helpful vs Missing Info
- **Signal Engagement**: Copy, Export, Follow-up counts
- **Intent Distribution**: Query types and their confidence levels
- **Key Insights**: AI-generated observations about usage patterns

### API Endpoint

**GET** `/api/chasen/analytics?days=30`

Returns comprehensive analytics data for the specified period.

---

## Database Schema

### Tables Created

| Table                     | Purpose                       |
| ------------------------- | ----------------------------- |
| `chasen_implicit_signals` | User engagement tracking      |
| `chasen_user_preferences` | Personalisation settings      |
| `chasen_learned_qa`       | Self-learning Q&A pairs       |
| `chasen_user_memories`    | Cross-session facts           |
| `chasen_analytics_daily`  | Daily aggregated metrics      |
| `chasen_intent_logs`      | Intent classification history |

### Views Created

| View                         | Purpose                     |
| ---------------------------- | --------------------------- |
| `chasen_feedback_summary`    | Daily feedback aggregates   |
| `chasen_intent_distribution` | Intent breakdown by day     |
| `chasen_user_engagement`     | Per-user engagement metrics |

---

## Intent Classification

The system classifies user queries into intents for better routing and analytics:

| Intent              | Example Queries                   |
| ------------------- | --------------------------------- |
| `report_generation` | "Generate a portfolio report"     |
| `risk_analysis`     | "Which clients are at risk?"      |
| `action_management` | "Show overdue actions"            |
| `data_lookup`       | "What's the NPS for Acme?"        |
| `email_drafting`    | "Draft an email to the client"    |
| `trend_analysis`    | "Show NPS trends over time"       |
| `meeting_prep`      | "Prepare me for the Acme meeting" |
| `client_summary`    | "Give me a summary of Acme Corp"  |
| `general`           | Other queries                     |

---

## RAG Sufficiency Checking

Before responding, ChaSen checks if it has sufficient data to answer the query:

```typescript
// If user asks about a specific client's NPS
// but no NPS data exists for that client,
// ChaSen will acknowledge the knowledge gap
```

This prevents hallucination and provides transparent responses about data limitations.

---

## Best Practices

### For Developers

1. **Always track signals** when users interact with AI-generated content
2. **Use the hooks** rather than calling APIs directly for state management
3. **Check preferences** before generating responses for personalisation
4. **Log intents** for all queries to improve classification over time

### For Users

1. **Provide feedback** on responses to help the system learn
2. **Set preferences** in settings for personalised responses
3. **Use consistent phrasing** for better memory extraction
4. **Check analytics** to understand usage patterns

---

## Migration

The database migration file is located at:

```
supabase/migrations/20251223100000_chasen_learning_enhancements.sql
```

Apply via Supabase Dashboard SQL Editor or CLI:

```bash
npx supabase db push
```

---

## Related Files

### Hooks

- `src/hooks/useChaSenSignals.ts`
- `src/hooks/useChaSenPreferences.ts`
- `src/hooks/useChaSenMemories.ts`

### API Routes

- `src/app/api/chasen/signals/route.ts`
- `src/app/api/chasen/preferences/route.ts`
- `src/app/api/chasen/memories/route.ts`
- `src/app/api/chasen/learned-qa/route.ts`
- `src/app/api/chasen/analytics/route.ts`

### Libraries

- `src/lib/chasen-intent-classifier.ts`
- `src/lib/chasen-rag-sufficiency.ts`

### Pages

- `src/app/(dashboard)/ai/page.tsx` - Main ChaSen page with signal tracking
- `src/app/(dashboard)/ai/analytics/page.tsx` - Analytics dashboard
