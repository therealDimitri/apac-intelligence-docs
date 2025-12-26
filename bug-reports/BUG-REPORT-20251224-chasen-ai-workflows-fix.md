# Bug Report: ChaSen AI Workflows and Crews Failing

**Date:** 24 December 2025
**Status:** Fixed
**Severity:** High
**Affected Features:** AI Workflows, AI Crews in ChaSen AI page

---

## Summary

The AI Workflows and AI Crews features in the ChaSen AI page were failing with multiple errors. Users attempting to run Portfolio Analysis, Risk Assessment, Client Reports, or Meeting Prep workflows would receive error messages.

---

## Root Causes

### Issue 1: API Parameter Mismatch

**Location:** `src/app/(dashboard)/ai/page.tsx`

The client was sending incorrect parameter names to the API endpoints:

| Client Sent    | API Expected |
| -------------- | ------------ |
| `workflowType` | `workflow`   |
| `input`        | `query`      |
| `crewType`     | `crew`       |
| `objective`    | `input`      |

**Error:** 400 Bad Request - "Missing required parameters"

### Issue 2: React Rendering Error

**Location:** `src/app/(dashboard)/ai/page.tsx`

The API returns a structured object:

```json
{
  "response": "...",
  "recommendations": [...],
  "sources": [...],
  "confidence": 75
}
```

The client was trying to render this entire object as a React child, causing:

```
Error: Objects are not valid as a React child
```

### Issue 3: LangGraph Node Name Conflict

**Location:** `src/lib/agent-workflows.ts` (line 422)

LangGraph state annotation had:

```typescript
const AgentState = Annotation.Root({
  ...
  confidence: Annotation<number>(),  // State attribute
})
```

And the workflow graph had:

```typescript
.addNode('confidence', calculateConfidence)  // Node with same name
```

LangGraph does not allow a node to have the same name as a state attribute.

**Error:** `confidence is already being used as a state attribute...cannot also be used as a node name`

---

## Fixes Applied

### Fix 1: Corrected API Parameters

**File:** `src/app/(dashboard)/ai/page.tsx`

```typescript
// Before (workflows)
body: JSON.stringify({
  workflowType: workflowType,
  input: '...',
})

// After
body: JSON.stringify({
  workflow: workflowType,
  query: '...',
})

// Before (crews)
body: JSON.stringify({
  crewType: crewType,
  objective: '...',
})

// After
body: JSON.stringify({
  crew: crewType,
  input: '...',
})
```

### Fix 2: Extract Response from Result Object

**File:** `src/app/(dashboard)/ai/page.tsx`

```typescript
// Before
setWorkflowResult({
  output: data.result, // Object - causes React error
})

// After
const resultOutput =
  typeof data.result === 'object' && data.result?.response
    ? data.result.response
    : data.result || data.output || 'Workflow completed successfully'

setWorkflowResult({
  output: resultOutput, // String - renders correctly
})
```

### Fix 3: Renamed LangGraph Node

**File:** `src/lib/agent-workflows.ts`

```typescript
// Before (line 406)
return 'confidence'

// After
return (
  'calculate_confidence'

    // Before (line 422)
    .addNode('confidence', calculateConfidence)

    // After
    .addNode('calculate_confidence', calculateConfidence)

    // Before (line 427)
    .addEdge('confidence', END)

    // After
    .addEdge('calculate_confidence', END)
)
```

---

## Testing

### Workflow API Test

```bash
curl -X POST 'http://localhost:3002/api/chasen/workflow' \
  -H 'Content-Type: application/json' \
  -d '{"workflow": "portfolio-analysis", "query": "Analyse my portfolio health"}'
```

**Result:** 200 OK with full analysis response including:

- Detailed portfolio analysis
- 5 prioritised recommendations
- Sources used
- 75% confidence score

### Crew API Test

```bash
curl -X POST 'http://localhost:3002/api/chasen/crew' \
  -H 'Content-Type: application/json' \
  -d '{"crew": "client-report", "clientName": "Epworth", "input": "Generate a client report"}'
```

**Result:** 200 OK with multi-agent report including:

- Portfolio Analyst output
- Communication Specialist output
- Quality Reviewer output
- 44-second total duration

---

## Prevention

1. **API Contract Documentation:** Ensure API parameter names are documented and match between client and server
2. **Type Safety:** Use shared TypeScript interfaces for API request/response types
3. **LangGraph Naming Convention:** Prefix node names with action verbs (e.g., `calculate_`, `gather_`, `analyse_`) to avoid conflicts with state attributes

---

## Files Modified

1. `src/app/(dashboard)/ai/page.tsx` - Fixed API parameters and result extraction
2. `src/lib/agent-workflows.ts` - Renamed 'confidence' node to 'calculate_confidence'
