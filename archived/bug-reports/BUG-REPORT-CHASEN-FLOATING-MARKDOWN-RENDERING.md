# Bug Report: FloatingChaSenAI Markdown Rendering

**Date**: 2025-11-29
**Severity**: Medium
**Component**: FloatingChaSenAI (Floating Chat Bubble)
**Status**: ✅ FIXED
**Fix Commit**: 1dc26b0

---

## Issue Summary

The FloatingChaSenAI component (floating chat bubble) displayed markdown syntax literally instead of rendering it as HTML. Bold text markers like `**Parkway**` appeared with visible asterisks instead of being rendered as **bold** text.

## Visual Example

**Before Fix**:

```
1. **Parkway**: 0%
2. **WA Health**: 40%
3. **SA Health (iPro)**: 50%
```

**After Fix**:

```
1. Parkway: 0%      ← "Parkway" displays in bold
2. WA Health: 40%   ← "WA Health" displays in bold
3. SA Health (iPro)**: 50%  ← "SA Health (iPro)" displays in bold
```

## Root Cause Analysis

### 1. Missing Markdown Processing Logic

**File**: `src/components/FloatingChaSenAI.tsx`
**Line**: 820 (before fix)

The FloatingChaSenAI component rendered raw message content without any markdown processing:

```typescript
<p className="text-sm leading-relaxed whitespace-pre-wrap">{message.content}</p>
```

### 2. Comparison with Main AI Page

The main AI page (`src/app/(dashboard)/ai/page.tsx` lines 419-467) has comprehensive markdown processing:

- Converts `**text**` to `<strong>text</strong>`
- Handles bullet lists, numbered lists
- Processes line breaks and spacing
- Uses `dangerouslySetInnerHTML` to render HTML tags

The FloatingChaSenAI component lacked this logic entirely.

### 3. Discovery Path

1. User reported seeing `*declining*` displayed literally instead of as bold/italic
2. Investigated ChaSen API responses - found responses contain markdown (e.g., `**Parkway**`)
3. Checked main AI page - found it has proper markdown rendering
4. Checked FloatingChaSenAI - found it's just rendering raw text
5. Identified discrepancy between the two components

## Technical Details

### API Response Format

ChaSen API returns structured responses with markdown in the `answer` field:

```json
{
  "answer": "Based on the latest Client Success Intelligence Hub data, six clients are behind on Segmentation Event Compliance, with scores below the 70% at-risk threshold. These clients require immediate attention to mitigate potential risks.\n\nThe clients are ranked below by the severity of their compliance gap:\n1.  **Parkway**: 0%\n2.  **WA Health**: 40%\n3.  **SA Health (iPro)**: 50%\n4.  **Guam Regional Medical City (GRMC)**: 60%\n5.  **Te Whatu Ora Waikato**: 68%\n6.  **Western Health**: 69%",
  "keyInsights": [...],
  "dataHighlights": [...],
  "recommendedActions": [...],
  "confidence": 100
}
```

Note the double asterisks `**Client Name**` in the answer field.

### Markdown Patterns Used by ChaSen

From testing ChaSen API responses, the following markdown patterns appear:

- `**text**` - Bold text (client names, emphasis)
- `- item` - Bullet list items
- `1. item` - Numbered list items
- `\n` - Line breaks for paragraph separation

Single asterisks `*text*` for italics are less common but should be supported for completeness.

## Solution Implemented

### Code Changes

**File**: `src/components/FloatingChaSenAI.tsx`
**Lines**: 820-877

Replaced simple text rendering with comprehensive markdown processing:

```typescript
{message.type === 'user' ? (
  <p className="text-sm leading-relaxed whitespace-pre-wrap">{message.content}</p>
) : (
  <div className="text-sm space-y-1.5">
    {message.content.split('\n').map((line, index) => {
      // Handle bold text with **
      let processedLine = line.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')

      // Handle italic text with single *
      processedLine = processedLine.replace(/\*([^*]+)\*/g, '<em>$1</em>')

      // Full line bold (starts and ends with **)
      if (line.startsWith('**') && line.endsWith('**')) {
        return (
          <p key={index} className="font-bold leading-relaxed">
            {line.replace(/\*\*/g, '')}
          </p>
        )
      }

      // Bullet list items
      if (line.startsWith('- ')) {
        return (
          <p
            key={index}
            className="ml-3 leading-relaxed"
            dangerouslySetInnerHTML={{ __html: `• ${processedLine.substring(2)}` }}
          />
        )
      }

      // Numbered list items
      if (/^\d+\.\s/.test(line)) {
        return (
          <p
            key={index}
            className="ml-3 leading-relaxed"
            dangerouslySetInnerHTML={{ __html: processedLine }}
          />
        )
      }

      // Empty lines
      if (line.trim() === '') {
        return <div key={index} className="h-1.5" />
      }

      // Regular paragraphs with inline bold/italic support
      return (
        <p
          key={index}
          className="leading-relaxed"
          dangerouslySetInnerHTML={{ __html: processedLine }}
        />
      )
    })}
  </div>
)}
```

### Implementation Approach

1. **Conditional Rendering**: User messages keep simple text rendering (no markdown needed), assistant messages get full markdown processing

2. **Processing Order**:
   - Split message by newlines (`\n`)
   - Process each line individually
   - Convert `**text**` to `<strong>text</strong>` first
   - Then convert `*text*` to `<em>text</em>` (avoid conflicts)

3. **Pattern Matching**:
   - Full-line bold: `line.startsWith('**') && line.endsWith('**')`
   - Bullet lists: `line.startsWith('- ')`
   - Numbered lists: `/^\d+\.\s/.test(line)`
   - Empty lines: `line.trim() === ''`

4. **HTML Rendering**: Use `dangerouslySetInnerHTML` to inject processed HTML tags

5. **Spacing Adjustments**: Adjusted spacing for compact chat bubble context:
   - Left margin: `ml-3` (vs `ml-4` on main AI page)
   - Empty line spacing: `h-1.5` (vs `h-2` on main AI page)

## Testing Performed

### Test 1: Bold Text Rendering

**Input** (from ChaSen API):

```
1. **Parkway**: 0%
2. **WA Health**: 40%
```

**Expected Output**: "Parkway" and "WA Health" display in bold
**Result**: ✅ PASS - Text renders in bold correctly

### Test 2: Numbered List with Bold

**Input**:

```
The clients are ranked below by the severity of their compliance gap:
1.  **Parkway**: 0%
2.  **WA Health**: 40%
```

**Expected Output**: Numbered list with bold client names
**Result**: ✅ PASS - List formatting maintained, names in bold

### Test 3: Bullet Lists

**Input**:

```
- First insight
- Second insight
```

**Expected Output**: Bullet points with `•` symbol
**Result**: ✅ PASS - Bullets render correctly

### Test 4: Italic Text (Single Asterisks)

**Input**: `The portfolio is *declining*`

**Expected Output**: "declining" in italics
**Result**: ✅ PASS - Italic rendering works

### Test 5: Dev Server Hot Reload

**Action**: Saved file after changes
**Expected**: Dev server reloads without errors
**Result**: ✅ PASS - No compilation errors

## Impact Assessment

### Users Affected

All users using the FloatingChaSenAI component (floating chat bubble).

### Severity Justification: Medium

- **Not Critical**: Text was still readable, just unformatted
- **Significant UX Impact**: Markdown syntax visible was unprofessional
- **Affects All Responses**: Every AI response in floating chat was impacted
- **Medium Priority**: Important for UX but not breaking core functionality

### Workaround (Before Fix)

Users could still read responses, but had to mentally ignore markdown syntax. Alternatively, they could use the full ChaSen AI page at `/ai` which had proper markdown rendering.

## Prevention Strategies

### 1. Component Parity Checklist

When creating UI components that display AI responses:

- [ ] Check if existing components have similar rendering logic
- [ ] Copy markdown processing logic to maintain consistency
- [ ] Test with actual API responses containing markdown

### 2. Code Reuse Opportunity

**Recommendation**: Extract markdown rendering logic into a reusable utility function or custom hook:

```typescript
// Proposed: src/lib/markdown-renderer.ts
export function renderMarkdown(text: string): JSX.Element {
  // ... markdown processing logic
}

// Usage:
<div>{renderMarkdown(message.content)}</div>
```

This would prevent discrepancies between components.

### 3. Testing Checklist

For components displaying AI responses:

- [ ] Test with bold text (`**text**`)
- [ ] Test with italic text (`*text*`)
- [ ] Test with bullet lists (`- item`)
- [ ] Test with numbered lists (`1. item`)
- [ ] Test with mixed formatting
- [ ] Verify HTML tags render correctly (not displayed as text)

## Related Issues

### Similar Components to Review

Check if these components also need markdown rendering:

- [ ] Any modals displaying AI responses
- [ ] Email templates using AI-generated content
- [ ] Export/print functionality for AI responses
- [ ] Mobile views of AI chat

### Future Enhancements

- Support for additional markdown syntax (headers, code blocks, links)
- Syntax highlighting for code blocks
- Support for tables
- Support for blockquotes

## References

- **Fix Commit**: 1dc26b0
- **Main AI Page Markdown Rendering**: `src/app/(dashboard)/ai/page.tsx` lines 419-467
- **ChaSen API Endpoint**: `/api/chasen/chat`
- **MatchaAI Documentation**: Claude 3.7 Sonnet model (ID 71) returns markdown-formatted responses

---

**Report Author**: Claude Code Assistant
**Reviewed By**: Development Team
**Last Updated**: 2025-11-29
