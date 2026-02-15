# Bug Report: ChaSen AI Markdown Links Not Rendering

**Date:** 2026-01-02
**Severity:** Medium
**Status:** Fixed
**Commit:** cc44bd5

## Summary

Markdown links in ChaSen AI responses were displaying as raw text (e.g., `[WA Health](/clients/WA%20Health/v2)`) instead of rendering as clickable hyperlinks.

## Symptoms

- Client profile links shown as plain text: `[WA Health](/clients/WA%20Health/v2)`
- Users could not click to navigate directly to client profiles
- Issue appeared specifically in section headers (bold text like `**[Client Name] - Client Overview**`)
- Links in regular paragraph text rendered correctly

## Root Cause

The markdown renderer (`src/lib/markdown-renderer.tsx`) had a bug in three header processing sections:

1. **Section Headers** (lines 707-721): Bold text patterns like `**Header Text**`
2. **H2 Headers** (lines 551-566): Patterns like `## Header`
3. **H3 Headers** (lines 568-595): Patterns like `### Header`

Each of these handlers stripped the markdown markers (`**`, `##`, `###`) but then output the header text directly **without** calling `processInlineFormatting()`. This meant any inline markdown (links, bold, italic) within headers was not converted to HTML.

The ChaSen API generates responses with format:
```
**[WA Health](/clients/WA%20Health/v2) - Client Overview**
```

This was captured by the section header handler which stripped `**` but left `[WA Health](/clients/WA%20Health/v2)` as raw text.

## Fix Applied

Modified all three header handlers to:
1. Call `processInlineFormatting(headerText)` to convert markdown to HTML
2. Use `dangerouslySetInnerHTML={{ __html: processedHeader }}` to render the HTML

### Section Headers Fix (lines 707-721):
```typescript
if (trimmedLine.match(/^\*\*[^*]+\*\*\s*$/)) {
  const headerText = trimmedLine.replace(/\*\*/g, '').trim()
  const processedHeader = processInlineFormatting(headerText)
  elements.push(
    <h4
      key={i}
      className="font-semibold text-base text-gray-800 mb-2 mt-3"
      dangerouslySetInnerHTML={{ __html: processedHeader }}
    />
  )
  // ...
}
```

### H2 Headers Fix (lines 551-566):
```typescript
if (trimmedLine.startsWith('## ')) {
  const headerText = trimmedLine.substring(3)
  const processedHeader = processInlineFormatting(headerText)
  elements.push(
    <div key={i} className="mt-5 mb-3">
      <h2
        className="text-lg font-bold text-gray-900 pb-2"
        dangerouslySetInnerHTML={{ __html: processedHeader }}
      />
      {/* ... */}
    </div>
  )
  // ...
}
```

### H3 Headers Fix (lines 568-595):
```typescript
if (trimmedLine.startsWith('### ')) {
  const headerText = trimmedLine.substring(4)
  const processedHeader = processInlineFormatting(headerText)
  elements.push(
    <h3
      key={i}
      className="..."
    >
      <span className="text-base">{getHeaderIcon(headerText)}</span>
      <span dangerouslySetInnerHTML={{ __html: processedHeader }} />
    </h3>
  )
  // ...
}
```

## Files Modified

| File | Changes |
|------|---------|
| `src/lib/markdown-renderer.tsx` | Added `processInlineFormatting()` calls to section, H2, and H3 header handlers |

## Verification

1. Started dev server on port 3002
2. Navigated to ChaSen AI page
3. Asked "Tell me about WA Health"
4. Verified in accessibility tree: `link "WA Health" [cursor=pointer]: /url: /clients/WA%20Health/v2`
5. Clicked link - successfully navigated to client profile page

## Prevention

- The `processInlineFormatting` function should be called for ANY text content that might contain markdown syntax
- When adding new header or section handlers, always process the content for inline formatting
- Consider adding automated tests for markdown rendering edge cases

## Related

- Shared markdown renderer is used by both `/ai` page and `FloatingChaSenAI` component
- The `processInlineFormatting` function handles: links, bold, italic, code, and strikethrough
