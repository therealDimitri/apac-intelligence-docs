# ChaSen AI Architecture

## Overview

ChaSen is the AI assistant powering intelligent features across the platform. It uses Anthropic Claude API via a `callMatchaAI()` wrapper, with Vercel AI SDK for streaming, and native `tool_use` for structured interactions.

## Core Components

```
User Message
    |
    v
[FloatingChaSenAI.tsx] ── ambient context (focus, engagement, dwell time)
    |
    v
[/api/chasen/stream] ── streaming route (25s Netlify limit)
    |
    |-- Intent Classification (chasen-intent-classifier.ts)
    |-- Context Loading (chasen/context/*.ts)
    |-- Memory Extraction (chasen-memories.ts)
    |-- Operating Rhythm Context (chasen-operating-rhythm-context.ts)
    |-- Tool Definitions (chasen-tools.ts, 14 tools)
    |
    v
[streamText()] ── Vercel AI SDK with toolChoice: 'auto'
    |-- maxSteps: 5 (cap tool-call depth within 25s window)
    |-- Read tools: execute immediately
    |-- Write tools: require approval
    |
    v
[Streaming Response with metadata]
    |-- mentionedClients
    |-- suggestedActions
    |-- followUpQuestions
```

## Model Selection

| ID | Model | Use Case |
|----|-------|----------|
| 71 | gemini-2-flash | Default (fastest for Netlify) |
| 27 | claude-3-7-sonnet | Quality responses |
| 28 | claude-sonnet-4 | Advanced reasoning |
| 29 | claude-opus-4 | Complex analysis |
| 15 | gpt-4o | Alternative |

## Multi-Agent Architecture (Phase 3)

- `orchestrate()` from `src/lib/chasen-agents.ts` routes intents to specialised agents
- `classifyIntent()` determines query domain (dashboard, goals, sentiment, automation, etc.)

## Key Files

| File | Purpose |
|------|---------|
| `src/app/api/chasen/stream/route.ts` | Main streaming endpoint |
| `src/lib/chasen-tools.ts` | 14 tool definitions in Anthropic format |
| `src/lib/chasen-agents.ts` | Multi-agent orchestration |
| `src/lib/chasen-intent-classifier.ts` | Intent classification |
| `src/lib/chasen-memories.ts` | Memory extraction from conversations |
| `src/lib/chasen-workflows.ts` | NL workflow parsing/execution |
| `src/lib/chasen-graph-rag.ts` | Knowledge graph sync |
| `src/lib/chasen-operating-rhythm-context.ts` | Operating rhythm data |
| `src/lib/chasen-prompts.ts` | Prompt templates with usage tracking |
| `src/lib/ai-providers.ts` | `callMatchaAI()` and `getAIModel()` |
| `src/lib/structured-output.ts` | Structured output via tool_use |
| `src/components/FloatingChaSenAI.tsx` | Chat widget UI (1157 lines) |
| `src/hooks/usePlanAI.ts` | Planning AI hook — 6 specialised action types |
| `src/components/planning/unified/AIInsightsPanel.tsx` | Sub-step aware coaching panel with auto-suggestions |
| `src/components/planning/unified/AISuggestionCard.tsx` | Auto-generated suggestion card with feedback |
| `src/app/api/planning/strategic/new/ai/route.ts` | Planning AI endpoint — specialised prompt builders |
| `src/app/api/planning/strategic/[id]/ai/route.ts` | Same for existing plans |

## Document Upload System

Two separate upload implementations exist — both must be kept in sync:

| Surface | Handler | File |
|---------|---------|------|
| Full `/ai` page | `handleFileAttach()` | `src/app/(dashboard)/ai/page.tsx` |
| Floating widget | `handleFileUpload()` | `src/components/FloatingChaSenAI.tsx` |

**Size-based routing** (shipped 2026-02-09):

- **< 4MB**: Direct FormData POST → `/api/chasen/upload` (1 request, fast)
- **>= 4MB**: 3-step storage flow bypassing Netlify's ~6MB body limit:
  1. `POST /api/chasen/upload/init` → creates `chasen_documents` row (status: pending), returns signed URL
  2. XHR PUT to Supabase Storage signed URL (direct to storage, bypasses Netlify)
  3. `POST /api/chasen/upload/process` → downloads from storage, runs `parseDocument()`, generates AI summary

**Key files**:

| File | Purpose |
|------|---------|
| `src/app/api/chasen/upload/route.ts` | Direct upload (small files) |
| `src/app/api/chasen/upload/init/route.ts` | Init: validate, create DB row, signed URL |
| `src/app/api/chasen/upload/process/route.ts` | Process: download from storage, extract text, summarise |

**DB columns** on `chasen_documents`: `storage_path TEXT`, `processing_status TEXT` (pending/processing/completed/failed)

**Storage**: Bucket `chasen-documents`, path `{email}/{docId}/{sanitisedFileName}`

## Structured Output System (F5)

Replaces regex JSON parsing with Anthropic `tool_use` structured outputs:

```typescript
const result = await callWithStructuredOutput<T>(messages, toolSchema, options)
// Uses tool_choice: { type: 'tool', name: schema.name }
// Returns parsed tool_use result directly
```

**Schemas**: meetingSummarySchema, extractActionsSchema, sentimentSchema, parsedCommandSchema, briefingSectionSchema, digestSummarySchema

## Context Domains

ChaSen loads context based on detected intent:

- `dashboard` - Portfolio health, NPS, meetings, actions (always loaded)
- `goals` - Company/team goals, initiatives, check-ins, approvals, audit trail
- `sentiment` - Client sentiment snapshots, alerts, topic analysis
- `automation` - Autopilot rules, touchpoints, recognition, communication drafts

Detection keywords in `src/lib/chasen/context/detect-context-domains.ts`.

**Context Modules:**
- `src/lib/chasen/context/goals-context.ts` - Goal hierarchy with progress rollup
- `src/lib/chasen/context/sentiment-context.ts` - Sentiment snapshots and alerts
- `src/lib/chasen/context/automation-context.ts` - Autopilot and recognition data
- `src/lib/chasen/context/full-context.ts` - Combined loader for detected domains

## Client Name Resolution

Use `resolve_client_name()` RPC for fuzzy client matching:

| Confidence | Match Type |
|-----------|------------|
| 1.0 | Exact match |
| 0.9 | Contains match |
| 0.8 | Reverse contains |
| 0.4+ | Similarity match |

TypeScript utility: `src/lib/client-resolver.ts`

**Supporting Database Objects:**
- `client_name_aliases` - Display name to canonical name mappings
- `client_canonical_lookup` - Materialised view with 116+ lookup entries
- `scan_client_name_mismatches()` - RPC to detect unresolved names

**Data Quality APIs:**

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/admin/data-quality/reconciliation` | GET | List unresolved mismatches |
| `/api/admin/data-quality/reconciliation` | POST | Run reconciliation scan |
| `/api/admin/data-quality/reconciliation` | PUT | Bulk confirm/reject |
| `/api/chasen/context/[domain]` | GET | Get specific context domain |

**Last verified 2026-02-07:**
- `resolve_client_name('Barwon Health')` -> Barwon Health Australia (1.0)
- `resolve_client_name('GHA')` -> Gippsland Health Alliance (1.0)
- `resolve_client_name('CONFIRMED, SA Health')` strips prefix, matches SA Health variants
- `scan_client_name_mismatches()` returns 12 unresolved entries

## Constraint: Netlify Function Timeout

Netlify Functions have a 25-second timeout for streaming responses. `maxSteps: 5` caps tool-call depth to stay within this window. Each tool call must be a fast DB query (< 1s).

## Database Tables

| Table | Purpose |
|-------|---------|
| `chasen_knowledge` | Knowledge base for RAG (124 entries) |
| `chasen_knowledge_suggestions` | Auto-generated knowledge from feedback |
| `chasen_feedback` | User feedback on responses (24 entries) |
| `chasen_conversations` | Conversation history (183 entries) |
| `chasen_folders` | Folder organisation (7 folders) |
| `chasen_learning_patterns` | Learning from dismissals |
| `chasen_workflows` | NL automation rules |
