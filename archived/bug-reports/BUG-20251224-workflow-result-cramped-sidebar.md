# Bug Report: AI Workflow Results Cramped in Sidebar

**Date:** 24 December 2025
**Status:** Fixed
**Severity:** Low
**Component:** ChaSen AI > AI Workflows

---

## Problem Description

When running an AI Workflow (Portfolio Analysis or Risk Assessment) in ChaSen AI, the result was displayed in a cramped sidebar panel with only 3 lines visible (`line-clamp-3`). Users could not view the full analysis output, which often contains multiple paragraphs of insights and recommendations.

### User Experience Issue

- Full workflow analysis truncated to ~50-100 characters
- No way to expand or view complete results
- Only option was "Clear result" which discarded the analysis
- Valuable AI-generated insights were effectively hidden

---

## Root Cause Analysis

The workflow result display in the sidebar used `line-clamp-3` CSS class to limit output to 3 lines, with no mechanism to view the full content.

### Affected Code (Before Fix)

**src/app/(dashboard)/ai/page.tsx (lines 1595-1601):**

```tsx
<p className="text-xs text-gray-700 line-clamp-3">{workflowResult.output}</p>
<button
  onClick={() => setWorkflowResult(null)}
  className="text-xs text-purple-600 hover:text-purple-800 mt-2"
>
  Clear result
</button>
```

---

## Solution Implemented

### 1. Added `sendWorkflowToChat` Function

Sends the complete workflow result to the main chat area as a properly formatted ChaSen message.

```tsx
const sendWorkflowToChat = (workflowType: 'portfolio-analysis' | 'risk-assessment') => {
  if (!workflowResult || !workflowResult.success) return

  const title =
    workflowType === 'portfolio-analysis'
      ? '📊 Portfolio Health Analysis'
      : '⚠️ Risk Assessment Report'

  const aiMessage: ChatMessage = {
    id: `workflow-${Date.now()}`,
    type: 'assistant',
    message: `## ${title}\n\n${workflowResult.output}`,
    timestamp: new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }),
    confidence: 85,
    keyInsights: [
      /* contextual insight based on workflow type */
    ],
  }

  setChatHistory(prev => [...prev, aiMessage])
  setWorkflowResult(null) // Clear from sidebar
  toast.success('Result sent to chat')
}
```

### 2. Added `lastWorkflowType` State

Tracks which workflow was run so the correct title/context can be applied when sending to chat.

### 3. Added "View in Chat" Button

New button with `MessageSquare` icon appears when workflow completes successfully.

---

## Files Changed

| File                              | Changes                                                                                                               |
| --------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| `src/app/(dashboard)/ai/page.tsx` | Added `MessageSquare` icon import, `lastWorkflowType` state, `sendWorkflowToChat` function, and "View in Chat" button |

---

## Behaviour Summary

| State                 | Before Fix             | After Fix                                 |
| --------------------- | ---------------------- | ----------------------------------------- |
| Workflow Complete     | Truncated preview only | Preview + "View in Chat" button           |
| Full Result Access    | Not possible           | Sends to main chat with proper formatting |
| Workflow Type Context | Not tracked            | Tracked and used for title/insights       |

---

## Testing Steps

1. Navigate to ChaSen AI page (`/ai`)
2. Expand "AI Workflows" section in sidebar
3. Click "Portfolio Analysis" workflow
4. Wait for workflow to complete
5. Verify "View in Chat" button appears alongside "Clear"
6. Click "View in Chat"
7. Verify full result appears in main chat area with:
   - Proper heading (📊 Portfolio Health Analysis)
   - Complete markdown-formatted content
   - Confidence indicator
8. Verify sidebar result clears automatically

---

## Related Systems

- LangGraph Workflows: `src/lib/agent-workflows.ts`
- Workflow API: `/api/chasen/workflow`
- ChaSen Chat: Message display in main chat area
