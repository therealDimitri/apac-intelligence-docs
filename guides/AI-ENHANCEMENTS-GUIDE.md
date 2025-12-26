# AI Enhancements Guide

This document describes the comprehensive AI enhancements implemented for the APAC Client Success Intelligence Hub.

## Overview

Six phases of AI improvements have been implemented:

| Phase | Feature                           | Status      |
| ----- | --------------------------------- | ----------- |
| 1     | Semantic Search with pgvector     | ✅ Complete |
| 2     | Streaming Chat with Vercel AI SDK | ✅ Complete |
| 3     | LLM Observability with Langfuse   | ✅ Complete |
| 4     | Agent Workflows with LangGraph    | ✅ Complete |
| 5     | AI Evaluation Framework           | ✅ Complete |
| 6     | Multi-Agent Team System           | ✅ Complete |

---

## Phase 1: Semantic Search with pgvector

### What it does

Enables vector similarity search for more accurate context retrieval in the RAG system.

### Key Files

- `src/lib/embeddings.ts` - Embedding generation utilities
- `src/lib/semantic-search.ts` - Semantic search module
- `src/app/api/chasen/index/route.ts` - Indexing API endpoint

### Database Tables

- `document_embeddings` - Stores document embeddings (1536 dimensions)
- `conversation_embeddings` - Stores conversation history embeddings

### Usage

```typescript
import { semanticSearch, CONTENT_TYPES } from '@/lib/semantic-search'

// Search for relevant documents
const results = await semanticSearch('client health analysis', {
  limit: 10,
  threshold: 0.7,
  contentTypes: [CONTENT_TYPES.MEETING_NOTES, CONTENT_TYPES.NPS_FEEDBACK],
  clientName: 'Example Client',
})
```

### Indexing Content

```bash
# Trigger full indexing via API
POST /api/chasen/index
```

---

## Phase 2: Streaming Chat with Vercel AI SDK

### What it does

Provides real-time streaming responses for a more responsive chat experience.

### Key Files

- `src/lib/ai-providers.ts` - AI provider configuration
- `src/app/api/chasen/stream/route.ts` - Streaming API endpoint
- `src/hooks/useStreamingChat.ts` - React hook for streaming chat

### Usage

```typescript
import { useStreamingChat } from '@/hooks/useStreamingChat'

function ChatComponent() {
  const { messages, isStreaming, sendMessage, stopStreaming } = useStreamingChat({
    model: 'claude-3-7-sonnet',
    context: 'portfolio',
    onFinish: (message) => console.log('Response:', message.content)
  })

  return (
    <div>
      {messages.map(msg => (
        <div key={msg.id}>{msg.content}</div>
      ))}
      <button onClick={() => sendMessage('Analyse my portfolio')}>Send</button>
    </div>
  )
}
```

---

## Phase 3: LLM Observability with Langfuse

### What it does

Provides tracing, logging, and analytics for all AI interactions.

### Key Files

- `src/lib/langfuse.ts` - Langfuse integration

### Configuration

Add to `.env.local`:

```
LANGFUSE_PUBLIC_KEY=pk-...
LANGFUSE_SECRET_KEY=sk-...
LANGFUSE_HOST=https://cloud.langfuse.com
```

### Usage

```typescript
import { createTrace, withTracing } from '@/lib/langfuse'

// Manual tracing
const trace = createTrace({
  name: 'portfolio-analysis',
  userId: 'user@example.com',
  tags: ['analysis'],
})

trace.generation({
  name: 'analyse',
  model: 'claude-3-7-sonnet',
  input: messages,
  output: response,
})

trace.score('quality', 0.9)

// Auto-tracing wrapper
const result = await withTracing({ name: 'my-operation' }, async trace => {
  // Your code here
  return result
})
```

---

## Phase 4: Agent Workflows with LangGraph

### What it does

Enables complex multi-step workflows with state management and conditional branching.

### Key Files

- `src/lib/agent-workflows.ts` - LangGraph workflow definitions
- `src/app/api/chasen/workflow/route.ts` - Workflow API endpoint

### Available Workflows

- `portfolio-analysis` - Comprehensive portfolio health analysis
- `risk-assessment` - Identify and prioritise at-risk clients
- `client-deep-dive` - Detailed single-client analysis
- `action-planning` - Generate action recommendations

### Usage

```typescript
import { runPortfolioAnalysis, runRiskAssessment } from '@/lib/agent-workflows'

// Run portfolio analysis
const result = await runPortfolioAnalysis('What clients need attention?', {
  userEmail: 'user@example.com',
})

console.log(result.response)
console.log(result.recommendations)
console.log(result.confidence)

// Run risk assessment
const risk = await runRiskAssessment('ClientName')
console.log(risk.riskLevel, risk.factors)
```

### API Usage

```bash
# List workflows
GET /api/chasen/workflow

# Execute workflow
POST /api/chasen/workflow
{
  "workflow": "portfolio-analysis",
  "query": "Which clients need attention?",
  "userEmail": "user@example.com"
}
```

---

## Phase 5: AI Evaluation Framework

### What it does

Provides DeepEval/RAGAS-style evaluation metrics for measuring AI output quality.

### Key Files

- `src/lib/ai-evaluation.ts` - Evaluation framework

### Available Metrics

| Metric               | Description                                | Default Threshold |
| -------------------- | ------------------------------------------ | ----------------- |
| `relevance`          | How relevant is the response to the query? | 0.7               |
| `faithfulness`       | Is the response grounded in the context?   | 0.7               |
| `coherence`          | Is the response logically structured?      | 0.7               |
| `completeness`       | Does the response fully address the query? | 0.6               |
| `toxicity`           | Is the response free from harmful content? | 0.9               |
| `answer_correctness` | Does it match the expected answer?         | 0.7               |

### Usage

```typescript
import { evaluate, batchEvaluate, getAvailableMetrics } from '@/lib/ai-evaluation'

// Evaluate a single response
const result = await evaluate({
  query: 'What is the client health score?',
  response: 'The health score is 85%.',
  context: 'Client X has NPS of 8 and good engagement.',
})

console.log(result.overallScore) // 0.85
console.log(result.passed) // true
console.log(result.metrics) // Individual metric scores

// Batch evaluation
const batchResult = await batchEvaluate(inputs, {
  metrics: ['relevance', 'faithfulness', 'coherence'],
})

console.log(batchResult.summary.averageScore)
```

---

## Phase 6: Multi-Agent Team System

### What it does

Provides CrewAI-style multi-agent collaboration for complex tasks.

### Key Files

- `src/lib/multi-agent.ts` - Multi-agent framework
- `src/app/api/chasen/crew/route.ts` - Crew API endpoint

### Pre-defined Agents

| Agent                    | Role          | Expertise                  |
| ------------------------ | ------------- | -------------------------- |
| Portfolio Analyst        | Data Analysis | Trends, patterns, metrics  |
| CS Strategist            | Strategy      | Retention, risk mitigation |
| Communication Specialist | Writing       | Reports, emails, summaries |
| Quality Reviewer         | QA            | Accuracy, completeness     |

### Pre-built Crews

| Crew               | Purpose                    | Agents Used               |
| ------------------ | -------------------------- | ------------------------- |
| Portfolio Analysis | Portfolio health analysis  | Analyst, Strategist       |
| Client Report      | Generate client report     | Analyst, Writer, Reviewer |
| Risk Assessment    | Identify at-risk clients   | Analyst, Strategist       |
| Meeting Prep       | Prepare for client meeting | Analyst, Writer           |

### Usage

```typescript
import { CREWS, createCrew } from '@/lib/multi-agent'

// Use pre-built crew
const crew = CREWS.portfolioAnalysis()
const result = await crew.kickoff('Analyse current portfolio health')

console.log(result.finalOutput)
console.log(result.tasks) // Individual task results

// Create custom crew
const customCrew = createCrew({
  name: 'Custom Analysis',
  agents: ['analyst', 'writer'],
  tasks: [
    { description: 'Analyse the data', agent: 'Portfolio Analyst' },
    { description: 'Write the summary', agent: 'Communication Specialist' },
  ],
})

await customCrew.kickoff()
```

### API Usage

```bash
# List available crews
GET /api/chasen/crew

# Execute crew
POST /api/chasen/crew
{
  "crew": "client-report",
  "clientName": "Example Client"
}
```

---

## Environment Variables

Add these to `.env.local`:

```bash
# MatchaAI (Required)
MATCHAAI_API_KEY=your-key
MATCHAAI_BASE_URL=https://matcha.harriscomputer.com/rest/api/v1
MATCHAAI_MISSION_ID=1397
MATCHAAI_DEFAULT_MODEL=claude-3-7-sonnet

# Optional - Direct AI Access (for native streaming)
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...

# Langfuse (Optional - for observability)
LANGFUSE_PUBLIC_KEY=pk-...
LANGFUSE_SECRET_KEY=sk-...
LANGFUSE_HOST=https://cloud.langfuse.com
```

---

## API Endpoints Summary

| Endpoint               | Method | Description               |
| ---------------------- | ------ | ------------------------- |
| `/api/chasen/stream`   | POST   | Streaming chat response   |
| `/api/chasen/index`    | GET    | Get indexing status       |
| `/api/chasen/index`    | POST   | Trigger document indexing |
| `/api/chasen/workflow` | GET    | List available workflows  |
| `/api/chasen/workflow` | POST   | Execute workflow          |
| `/api/chasen/crew`     | GET    | List available crews      |
| `/api/chasen/crew`     | POST   | Execute multi-agent crew  |

---

## Best Practices

1. **Indexing**: Run `/api/chasen/index` periodically to keep embeddings up-to-date
2. **Evaluation**: Use the evaluation framework to monitor AI quality over time
3. **Tracing**: Enable Langfuse for production to track costs and performance
4. **Workflows**: Use workflows for complex multi-step analyses
5. **Crews**: Use multi-agent crews when you need multiple perspectives

---

## Future Enhancements

- Real-time embedding updates on data changes
- Caching layer for frequently-asked questions
- A/B testing for different AI configurations
- Cost optimisation recommendations
- Automated quality monitoring dashboards
