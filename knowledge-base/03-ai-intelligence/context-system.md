# ChaSen Context System

## Domain-Based Context Loading

ChaSen loads context dynamically based on detected user intent, avoiding loading unnecessary data.

### Detection

**File**: `src/lib/chasen/context/detect-context-domains.ts`

Analyses user message for keywords to determine which context domains to load.

### Domains

| Domain | Loader | Data Sources | Always Loaded? |
|--------|--------|-------------|----------------|
| `dashboard` | Built-in | Portfolio health, NPS, meetings, actions | Yes |
| `goals` | `goals-context.ts` | Company/team goals, initiatives, check-ins, approvals | On keyword |
| `sentiment` | `sentiment-context.ts` | Sentiment snapshots, alerts, topic analysis | On keyword |
| `automation` | `automation-context.ts` | Autopilot rules, touchpoints, recognition, drafts | On keyword |

### Context Module Files

```
src/lib/chasen/context/
  detect-context-domains.ts    -- Keyword-based domain detection
  goals-context.ts             -- Goal hierarchy with progress rollup
  sentiment-context.ts         -- Sentiment snapshots and alerts
  automation-context.ts        -- Autopilot and recognition data
  full-context.ts              -- Combined loader for detected domains
```

## Ambient Awareness (F1)

`useAmbientAwareness` tracks user behaviour and feeds it into ChaSen:

- **Focus areas**: Which page section the user is looking at
- **Inferred intent**: What the user might be considering
- **Engagement level**: How actively the user is interacting (0-100)
- **Dwell time**: How long spent on current view

When `inferredIntent === 'considering'` and `engagementLevel > 60`, ChaSen generates proactive nudges.

## Knowledge Graph RAG (F3)

5 data sources synced to the knowledge graph for retrieval-augmented generation:

| Source | Table | Node Type | Key Edges |
|--------|-------|-----------|-----------|
| Products | `product_catalog` | `product` | sold_to -> client |
| Deals | `pipeline_deals` | `deal` | for_client -> client |
| Emails | `communication_drafts` | `communication` | about -> client |
| Contracts | `burc_annual_financials` | `contract` | with -> client |
| News | `news_articles` | `news` | mentions -> client |

**Incremental sync**: `graph_sync_status` table tracks `last_synced_at` per source. Delta queries with `WHERE updated_at > since`.

**Cron**: `/api/cron/graph-embed` runs daily.

## Learning Loop (F4)

Dismissal patterns and feedback improve future responses:

1. `useDismissalLearning()` tracks which suggestions users dismiss
2. `filterSuggestions()` removes topics the user has repeatedly dismissed
3. Stream route accepts `feedbackContext` with suppressed/preferred topics
4. `chasen-prompts.ts` tracks `clickCount` and `lastClicked` per prompt

## Operating Rhythm Context

**File**: `src/lib/chasen-operating-rhythm-context.ts`

Provides segmentation event compliance data to ChaSen:
- YTD event completion rates per client
- Upcoming/overdue events
- Compliance gaps and at-risk clients

## Memory System

**File**: `src/lib/chasen-memories.ts`

Extracts and stores memories from conversations:
- Key facts mentioned by the user
- Client preferences and context
- Action items and commitments
- Used to provide continuity across chat sessions

## Silent Query Failure Warning

ChaSen context queries use try/catch blocks that fail silently. If a query returns empty data:
1. Check column names against `docs/database-schema.md`
2. Common trap: `actions` table uses capitalized columns (`Status`, `Due_Date`)
3. UI labels may not match DB column names
