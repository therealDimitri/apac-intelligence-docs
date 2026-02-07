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

## Structured Output System (F5)

Replaces regex JSON parsing with Anthropic `tool_use` structured outputs:

```typescript
const result = await callWithStructuredOutput<T>(messages, toolSchema, options)
// Uses tool_choice: { type: 'tool', name: schema.name }
// Returns parsed tool_use result directly
```

**Schemas**: meetingSummarySchema, extractActionsSchema, sentimentSchema, parsedCommandSchema, briefingSectionSchema, digestSummarySchema

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
