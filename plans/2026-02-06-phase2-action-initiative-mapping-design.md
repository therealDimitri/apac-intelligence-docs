# Phase 2: Bulk Action-to-Initiative Mapping — Design Specification

**Date:** 2026-02-06
**Status:** Approved
**Depends on:** Phase 1 Goals & Initiatives (complete)

## Executive Summary

Phase 2 consolidates the two initiative tables (`initiatives` and `portfolio_initiatives`) into a single `portfolio_initiatives` table, then adds a "Link to Initiative" tab on the Actions page for mapping orphaned actions to initiatives. Users create initiatives manually and receive AI-assisted suggestions from ChaSen when linking actions.

**Current state:** 95 actions, 0 linked. `initiatives` table is empty. `portfolio_initiatives` has 6 records.

---

## 1. Data Migration

### 1.1 Add Columns to `portfolio_initiatives`

Add the following nullable columns to consolidate both tables:

**Goal hierarchy columns (from Phase 1 `initiatives` enhancements):**
- `team_goal_id` UUID REFERENCES team_goals(id)
- `progress_method` TEXT CHECK (IN 'auto', 'manual', 'target_value', 'boolean')
- `progress_percentage` NUMERIC(5,2) DEFAULT 0
- `target_value` NUMERIC
- `current_value` NUMERIC
- `is_achieved` BOOLEAN DEFAULT false
- `goal_status` TEXT CHECK (IN 'not_started', 'on_track', 'at_risk', 'off_track', 'completed')

**Internal ops columns (from `initiatives` table):**
- `owner_department` VARCHAR(100)
- `involved_departments` TEXT[]
- `priority` VARCHAR(20)
- `actual_completion_date` DATE
- `impacts_clients` BOOLEAN DEFAULT false
- `client_impact_description` TEXT

### 1.2 Change `actions.linked_initiative_id`

- Drop existing integer column `linked_initiative_id`
- Add new column `linked_initiative_id` UUID REFERENCES portfolio_initiatives(id)
- No data migration needed (0 actions are currently linked)

### 1.3 Update Phase 1 API Routes

All Phase 1 goals API routes that reference the `initiatives` table must be updated to query `portfolio_initiatives` instead:

- `/api/goals/route.ts` — GET/POST for initiatives
- `/api/goals/[id]/route.ts` — GET/PATCH/DELETE for initiatives
- `/api/goals/[id]/hierarchy/route.ts` — hierarchy traversal
- `src/lib/goals/hierarchy.ts` — `getTableName('initiative')` → `'portfolio_initiatives'`

### 1.4 Column Mapping

| Generic field | `portfolio_initiatives` column |
|---|---|
| title | `name` |
| status | `goal_status` |
| owner_id | `owner_department` |
| target_date | `completion_date` |
| parent_id | `team_goal_id` |

### 1.5 RLS Policies

Copy Phase 1 RLS policies from `initiatives` to `portfolio_initiatives`:
- `anon` SELECT access
- `authenticated` full CRUD

### 1.6 Deprecate `initiatives` Table

Keep the table but stop writing to it. Add a comment: `-- DEPRECATED: Use portfolio_initiatives instead. Kept for reference.`

---

## 2. UI Design: "Link to Initiative" Tab

### 2.1 Location

New tab on the existing `/actions` page, alongside the current Kanban/Matrix/List views.

### 2.2 Layout

```
┌─────────────────────────────────────────────────────┐
│  ██████████████░░░░░░░░░░  23 of 95 linked (24%)   │
└─────────────────────────────────────────────────────┘

Group by: [Client ▾]  [Search actions...]  [Refresh ↻]

── Saint Luke's Medical Centre (12 actions) ──────────
┌──────────────────────────────────────────────────────┐
│ ACT-2025-023 | Migrate SLMC to cloud hosting         │
│ Owner: Gilbert So | Priority: High | Due: 15/03/2026 │
│                                                      │
│ 🤖 Cloud Migration — 87%  |  SLMC Upgrade — 62%     │
│                                                      │
│ [Link to Initiative ▾]              [☐ Select]       │
└──────────────────────────────────────────────────────┘

── Internal (37 actions) ─────────────────────────────
┌──────────────────────────────────────────────────────┐
│ ACT-2025-041 | Finalise Q2 reporting templates       │
│ ...                                                  │
└──────────────────────────────────────────────────────┘
```

### 2.3 Components

**Progress Banner**
- Horizontal progress bar with fraction text ("23 of 95 linked")
- Percentage display
- Colour transitions: red (0-25%) → amber (25-75%) → green (75-100%)

**Action Card (orphaned)**
- Action description, owner, client, priority badge, due date
- ChaSen suggestion chips (1-3 initiatives with confidence %)
- Initiative picker dropdown (searchable, filtered by client)
- Bulk select checkbox

**Initiative Picker Dropdown**
- Searchable combobox
- Filtered to initiatives matching the action's `client_name`
- Shows: initiative name, status badge, category
- Footer: "+ Create Initiative" quick-add option
- On select: immediately links the action via PATCH

**Quick Create Initiative**
- Inline form within the picker: name, client, category, status
- Creates via POST then auto-links the action
- Pre-fills client from the action context

**Bulk Actions Bar**
- Appears when 1+ actions are checked
- "Link N selected to..." button → opens initiative picker
- "Select all in group" shortcut

**Completion State**
- When all actions are linked: success banner with confetti-style icon
- Link to /goals-initiatives to review hierarchy

### 2.4 Grouping Options

- **By Client** (default): Groups actions by `client` field
- **By Owner**: Groups by `Owners` field
- **By Category**: Groups by `Category` field
- **None**: Flat list sorted by created date

---

## 3. API Endpoints

### 3.1 New Endpoints

**`GET /api/actions/link-progress`**
Returns mapping progress stats.
```json
{ "total": 95, "linked": 23, "orphaned": 72, "percentage": 24.2 }
```

**`POST /api/actions/bulk-link`**
Links multiple actions to one initiative.
```json
// Request
{ "action_ids": [1, 5, 12], "initiative_id": "uuid-here" }
// Response
{ "success": true, "data": { "updated": 3 } }
```

**`POST /api/chasen/suggest-initiative`**
AI-assisted initiative matching for a single action.
```json
// Request
{ "action_id": 23 }
// Response
{
  "suggestions": [
    { "initiative_id": "uuid", "name": "Cloud Migration", "confidence": 0.87, "reason": "Client and description match" },
    { "initiative_id": "uuid", "name": "SLMC Upgrade", "confidence": 0.62, "reason": "Same client, related category" }
  ]
}
```

**`GET /api/goals/initiatives`**
Convenience endpoint for the initiative picker. Lists `portfolio_initiatives` with search and client filtering.
```
GET /api/goals/initiatives?client_name=SLMC&search=cloud
```

### 3.2 Modified Endpoints

**`GET /api/actions`** — Add `linked` query param:
- `?linked=false` → WHERE `linked_initiative_id IS NULL`
- `?linked=true` → WHERE `linked_initiative_id IS NOT NULL`

**`PATCH /api/actions/[id]`** — Support setting `linked_initiative_id` (UUID). Validate initiative exists.

---

## 4. ChaSen AI Matching

### 4.1 Matching Strategy

ChaSen analyses the action's context to suggest matching initiatives:

1. **Client match** (highest weight): Same `client_name` between action and initiative
2. **Description semantic similarity**: Compare action description with initiative name/description
3. **Owner match**: Same CSE/owner across action and initiative
4. **Category/topic overlap**: Match action category/tags with initiative category
5. **Meeting context**: If action has `ai_context` from a meeting, use topic overlap

### 4.2 Confidence Scoring

- 80-100%: Strong match (same client + semantic match)
- 50-79%: Moderate match (partial context overlap)
- Below 50%: Not shown as suggestion

### 4.3 Implementation

Uses the existing ChaSen streaming API pattern. The suggestion endpoint calls Claude with:
- The action's full context (description, client, owner, AI context)
- A list of all initiatives (name, client, category, description)
- Instructions to return top 3 matches with confidence scores and reasoning

---

## 5. Implementation Batches

### Batch 1: Data Migration (foundation)

| # | Task | Description |
|---|------|-------------|
| 1 | Add columns to portfolio_initiatives | Goal hierarchy + internal ops columns via migration |
| 2 | Change actions.linked_initiative_id | Drop integer, add UUID FK to portfolio_initiatives |
| 3 | Copy RLS policies to portfolio_initiatives | anon SELECT + authenticated full CRUD |
| 4 | Update Phase 1 API routes | Change `initiatives` → `portfolio_initiatives` in all goals routes |
| 5 | Update TypeScript types and utilities | hierarchy.ts, goals.ts types, database.generated.ts |
| 6 | Verify build | npm run build passes cleanly |

### Batch 2: Core Linking UI

| # | Task | Description |
|---|------|-------------|
| 7 | Create GET /api/goals/initiatives | Initiative picker data source with client filter |
| 8 | Add linked filter to actions API | `?linked=false` filter param |
| 9 | Create GET /api/actions/link-progress | Progress stats endpoint |
| 10 | Create POST /api/actions/bulk-link | Bulk link endpoint |
| 11 | Build "Link to Initiative" tab | Progress banner, grouped list, picker, bulk select |
| 12 | Build Quick Create Initiative form | Inline form in picker dropdown |

### Batch 3: ChaSen AI + Polish

| # | Task | Description |
|---|------|-------------|
| 13 | Create POST /api/chasen/suggest-initiative | AI matching endpoint |
| 14 | Add suggestion chips to action cards | Display AI suggestions with confidence scores |
| 15 | Update CLAUDE.md and regenerate schema docs | Document new endpoints and migration |
| 16 | Verify build and browser test | End-to-end validation |

---

## 6. Key Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Single initiative table | `portfolio_initiatives` | Consolidate data model, UUID-based, already has client context |
| UI location | Tab on Actions page | Users already manage actions there |
| AI approach | Suggestion chips (not bulk) | Manual-first keeps users in control |
| Tab scope | Orphaned actions only | Clear focus on the mapping task |
| Grouping default | By Client | Initiatives are client-scoped |
