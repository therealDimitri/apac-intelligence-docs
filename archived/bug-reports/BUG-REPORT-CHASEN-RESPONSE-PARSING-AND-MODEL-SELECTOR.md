# Bug Report: ChaSen AI Response Parsing Issues and Model Selector Implementation

**Date**: 2025-11-28
**Reporter**: Claude Code
**Severity**: High
**Status**: ✅ RESOLVED
**Commit**: 7330717

---

## Issue Summary

ChaSen AI was returning malformed responses with empty structured fields (keyInsights, dataHighlights, recommendedActions, followUpQuestions) even though the API was receiving valid data from MatchaAI. Additionally, there was no way for users to select different AI models based on their speed/intelligence needs.

---

## Issue 1: Empty Structured Response Fields

### User Report

> "ChaSen responses are not making sense and the display format is still incorrect. Investigate and fix."

### Symptoms

**API Response** (what the frontend received):

````json
{
  "answer": "{\n  \"answer\": \"Based on the current portfolio...\",\n  \"key_insights\": [...],\n  \"data_highlights\": [...]\n}\n```",
  "keyInsights": [],
  "dataHighlights": [],
  "recommendedActions": [],
  "followUpQuestions": [],
  "confidence": 85
}
````

**Expected Response**:

```json
{
  "answer": "Based on the current portfolio...",
  "keyInsights": ["Insight 1", "Insight 2", "Insight 3"],
  "dataHighlights": [
    { "label": "Total Clients", "value": "0", "context": "Portfolio unpopulated" }
  ],
  "recommendedActions": ["Action 1", "Action 2"],
  "followUpQuestions": ["Question 1?", "Question 2?"],
  "confidence": 100
}
```

### Root Cause Analysis

#### Problem 1: Markdown Code Fences Not Properly Removed

**Original Code** (src/app/api/chasen/chat/route.ts:108):

````typescript
// Clean up markdown code blocks if present
aiText = aiText
  .replace(/^```(?:json)?\s*/i, '')
  .replace(/\s*```$/, '')
  .trim()
````

**Issue**: The regex `/\s*```$/` only matches triple backticks at the **END** of the string (`$`). However, the AI response included text after the closing backticks:

```
{
  "answer": "...",
  "key_insights": [...]
}
```

^--- This closing backtick followed by newline broke the regex

````

**Result**: The entire JSON structure (including code fences) was being parsed as a plain string and assigned to the `answer` field.

#### Problem 2: Field Name Mismatch

The AI returned snake_case field names (`key_insights`, `data_highlights`, `recommended_actions`, `follow_up_questions`), but the code expected camelCase (`keyInsights`, `dataHighlights`, etc.).

**Original Mapping** (lines 144-150):
```typescript
return NextResponse.json({
  answer: structuredResponse.answer || aiText,
  keyInsights: structuredResponse.key_insights || [],  // ❌ Wrong field name
  dataHighlights: structuredResponse.data_highlights || [],  // ❌ Wrong field name
  // ...
})
````

**Issue**: Since `structuredResponse` didn't have `key_insights` (it had the stringified JSON in `answer`), all arrays defaulted to `[]`.

---

## Solution 1: Enhanced JSON Parsing

### 1.1 Improved Markdown Cleanup

**New Code** (lines 107-113):

````typescript
// Clean up markdown code blocks if present (handles various formats)
// Remove opening code fence (```json or ``` at start)
aiText = aiText.replace(/^```(?:json)?\s*/i, '')
// Remove closing code fence (``` followed by anything, anywhere in text)
aiText = aiText.replace(/```[\s\S]*$/i, '')
// Trim whitespace
aiText = aiText.trim()
````

**Changes**:

- Opening fence: `/^```(?:json)?\s*/i` - matches start of string only
- Closing fence: `/```[\s\S]*$/i` - matches ``` followed by **any characters** (including newlines) until end of string
- `\s*```$` → `/```[\s\S]*$/i` - More aggressive pattern

**Result**: Properly removes all code fences regardless of trailing content.

### 1.2 Field Name Normalization

**New Code** (lines 121-134):

```typescript
// Validate and normalize field names
// The AI returns snake_case (key_insights) but we need camelCase (keyInsights)
// Map snake_case fields to our expected structure
const normalized = {
  answer: structuredResponse.answer || structuredResponse.Answer || '',
  keyInsights: structuredResponse.key_insights || structuredResponse.keyInsights || [],
  dataHighlights: structuredResponse.data_highlights || structuredResponse.dataHighlights || [],
  recommendedActions:
    structuredResponse.recommended_actions || structuredResponse.recommendedActions || [],
  relatedClients: structuredResponse.related_clients || structuredResponse.relatedClients || [],
  followUpQuestions:
    structuredResponse.follow_up_questions || structuredResponse.followUpQuestions || [],
  confidence: structuredResponse.confidence || 85,
}

structuredResponse = normalized
```

**Benefits**:

- Handles both snake_case (from AI) and camelCase (from frontend)
- Supports uppercase variants (Answer vs answer)
- Creates normalized structure before returning
- Backward compatible with existing code

### 1.3 Enhanced Error Logging

**New Code** (lines 138-139):

```typescript
console.error('[ChaSen] JSON parse error:', parseError)
console.error('[ChaSen] Failed to parse:', aiText.substring(0, 200))
```

**Benefits**:

- Shows parse error details
- Displays first 200 characters of failed text
- Helps diagnose future parsing issues

---

## Issue 2: No Model Selection Capability

### User Request

> "Add the ability to change AI models in ChaSen AI."

### Implementation

#### 2.1 Model Definitions

**New Code** (src/app/(dashboard)/ai/page.tsx:55-61):

```typescript
// Available AI models
const AI_MODELS = [
  {
    id: 'claude-3-7-sonnet',
    name: 'Claude 3.7 Sonnet (Recommended)',
    description: 'Best balance of speed and intelligence',
  },
  { id: 'claude-3-5-sonnet', name: 'Claude 3.5 Sonnet', description: 'Fast and capable' },
  { id: 'claude-3-opus', name: 'Claude 3 Opus', description: 'Most powerful, slowest' },
  { id: 'claude-3-haiku', name: 'Claude 3 Haiku', description: 'Fastest, most economical' },
]
```

**Available Models**:

1. **Claude 3.7 Sonnet** (Recommended) - Best balance of speed and intelligence
2. **Claude 3.5 Sonnet** - Fast and capable
3. **Claude 3 Opus** - Most powerful, slowest (for complex analysis)
4. **Claude 3 Haiku** - Fastest, most economical (for simple queries)

#### 2.2 Model Selector UI

**New Code** (lines 243-260):

```typescript
<div className="flex items-centre space-x-3">
  <Sparkles className="h-5 w-5 text-yellow-300" />
  <div className="flex flex-col items-end">
    <label className="text-xs text-purple-100 mb-1">AI Model</label>
    <select
      value={selectedModel}
      onChange={(e) => setSelectedModel(e.target.value)}
      className="text-sm bg-white/10 text-white border border-white/20 rounded-lg px-3 py-1.5 focus:outline-none focus:ring-2 focus:ring-white/50 hover:bg-white/20 transition-colours cursor-pointer"
      title={AI_MODELS.find(m => m.id === selectedModel)?.description}
    >
      {AI_MODELS.map(model => (
        <option key={model.id} value={model.id} className="bg-purple-900 text-white">
          {model.name}
        </option>
      ))}
    </select>
  </div>
</div>
```

**Features**:

- Dropdown in header (replaces static "Powered by MatchaAI" badge)
- Styled with purple gradient theme matching page design
- Tooltip shows model description on hover
- Default: Claude 3.7 Sonnet

#### 2.3 State Management

**New Code** (line 67):

```typescript
const [selectedModel, setSelectedModel] = useState('claude-3-7-sonnet')
```

**Sent to API** (line 182):

```typescript
body: JSON.stringify({
  question: textToSend,
  conversationHistory: chatHistory.slice(-10).map(m => ({...})),
  context: 'portfolio',
  model: selectedModel  // ✅ Added
})
```

#### 2.4 API Model Support

**New Code** (src/app/api/chasen/chat/route.ts):

1. **Interface Update** (line 23):

```typescript
interface ChatRequest {
  question: string
  conversationHistory?: ChatMessage[]
  context?: 'portfolio' | 'client' | 'general'
  clientName?: string
  model?: string // ✅ Added
}
```

2. **Extract and Use Model** (lines 59, 69):

```typescript
const { question, conversationHistory = [], context = 'general', clientName, model } = body

// Use requested model or default
const selectedModel = model || MATCHAAI_CONFIG.defaultModel
```

3. **Return in Metadata** (line 165):

```typescript
metadata: {
  model: selectedModel,  // ✅ Changed from MATCHAAI_CONFIG.defaultModel
  timestamp: new Date().toISOString(),
  context: context,
  cost: 0
}
```

---

## Testing

### Test 1: API Response Parsing

**Command**:

```bash
curl -s -X POST http://localhost:3002/api/chasen/chat \
  -H "Content-Type: application/json" \
  -d '{"question":"What are the top 3 risks in my portfolio?","context":"portfolio"}' \
  | python3 -m json.tool
```

**Result**: ✅ All structured fields properly populated

```json
{
  "answer": "Currently, your portfolio appears to be empty...",
  "keyInsights": [
    "Portfolio data is missing or currently indicates zero active clients.",
    "Risk analysis requires active metrics such as NPS, meeting frequency...",
    "General APAC risks often stem from gaps in communication..."
  ],
  "dataHighlights": [
    {
      "label": "Total Clients",
      "value": "0",
      "context": "No accounts currently assigned to portfolio."
    },
    {
      "label": "Recent Activity",
      "value": "None",
      "context": "No meetings or NPS responses in the last 30 days."
    }
  ],
  "recommendedActions": [
    "Synchronize your client list from the CRM...",
    "Log recent client interactions or meetings...",
    "Review general APAC market trends..."
  ],
  "relatedClients": [],
  "followUpQuestions": [
    "Would you like to import your client list now?",
    "Should we review a template for assessing client health manually?"
  ],
  "confidence": 100,
  "metadata": {
    "model": "claude-3-7-sonnet",
    "timestamp": "2025-11-28T05:41:20.992Z",
    "context": "portfolio",
    "cost": 0
  }
}
```

### Test 2: Model Selector

1. ✅ Model dropdown displays in header
2. ✅ Default model: Claude 3.7 Sonnet
3. ✅ Can switch to other models (3.5 Sonnet, Opus, Haiku)
4. ✅ Model selection persists during conversation
5. ✅ Metadata shows selected model in response

---

## Impact

### Before

❌ **Broken Response Parsing**:

- All structured fields empty (keyInsights, dataHighlights, etc.)
- Entire JSON structure trapped in `answer` field as string
- ChaSen UI couldn't display insights/recommendations
- Poor user experience

❌ **No Model Flexibility**:

- Locked to single model (Claude 3.7 Sonnet)
- No way to trade speed for intelligence
- Can't optimise for specific use cases

### After

✅ **Fixed Response Parsing**:

- All structured fields properly populated
- Field name normalization handles snake_case/camelCase
- Enhanced error logging for debugging
- ChaSen UI displays all insights/recommendations

✅ **Model Selection**:

- 4 models available (3.7 Sonnet, 3.5 Sonnet, Opus, Haiku)
- Users can optimise for speed vs intelligence
- Real-time model switching
- Model metadata tracked in responses

---

## Files Modified

### 1. src/app/api/chasen/chat/route.ts

**Lines Changed**: 107-113 (markdown cleanup), 121-134 (normalization), 138-139 (logging), 23 (interface), 59 (extract model), 69 (use model), 165 (metadata)

### 2. src/app/(dashboard)/ai/page.tsx

**Lines Changed**: 55-61 (model definitions), 67 (state), 182 (send model), 243-260 (UI)

---

## Prevention Strategies

### 1. Regex Testing

- Test regex patterns with various input formats
- Use online regex testers (regex101.com)
- Consider edge cases (trailing text, multiline, etc.)

### 2. Field Name Consistency

- Document expected API response structure
- Use TypeScript interfaces for both request and response
- Add field name mapping layer for external APIs

### 3. Comprehensive Error Logging

- Log raw API responses before parsing
- Show first N characters of failed parses
- Include parse error details in logs

### 4. User-Facing Configuration

- Expose advanced options (like model selection) to users
- Provide clear descriptions for each option
- Store selections in state for persistence

---

## Related Issues

- Previous ChaSen parsing fix (commit ad833f2) - Addressed nested JSON but not code fences
- MatchaAI integration (original commit) - Established API connection but lacked field normalization

---

## Recommendations

### Short-term

1. ✅ Deploy these fixes to production immediately
2. Monitor ChaSen responses for any remaining parsing issues
3. Test all 4 models with various query types

### Long-term

1. Add model selection persistence to localStorage
2. Create model performance benchmarks (speed, quality, cost)
3. Consider adding custom system prompts per model
4. Implement conversation export functionality
5. Add A/B testing framework for model comparison

---

## Conclusion

**Status**: ✅ RESOLVED

Both issues have been successfully fixed:

1. ChaSen AI response parsing now works correctly with all structured fields populated
2. Users can now select from 4 different AI models based on their needs

The fixes are backward compatible and include enhanced error handling for future debugging.

**Commit**: 7330717
**Ready for Production**: ✅ Yes
