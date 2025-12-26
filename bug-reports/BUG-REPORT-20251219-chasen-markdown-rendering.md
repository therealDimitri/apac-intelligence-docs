# Bug Report: ChaSen Markdown Not Rendering in Response Modal

**Date**: 2025-12-19
**Status**: RESOLVED
**Severity**: Low
**Component**: ChaSen AI - Response Modal

---

## Issue Summary

ChaSen AI responses displayed raw markdown syntax (e.g., `**SingHealth**`) instead of rendered bold text in the Response Modal popup. The full-chat mode rendered markdown correctly, but the Response Modal did not.

## Symptoms

- Bold text showing as `**text**` instead of **text**
- Italic text showing as `*text*` instead of _text_
- Bullet points and numbered lists not formatted correctly
- Response Modal looked unprofessional with raw markup visible

## Root Cause

The Response Modal section in `FloatingChaSenAI.tsx` used a simple text display without markdown processing:

**Before (lines 1129-1133):**

```tsx
{
  /* Main Answer */
}
;<div className="prose prose-sm max-w-none">
  <div className="text-gray-800 leading-relaxed whitespace-pre-wrap">{response.answer}</div>
</div>
```

Meanwhile, the full-chat mode (lines 1608-1664) had proper markdown parsing using regex to convert `**text**` to `<strong>` tags and other formatting.

## Solution

Applied the same markdown rendering logic from full-chat mode to the Response Modal:

**After:**

```tsx
{
  /* Main Answer */
}
;<div className="prose prose-sm max-w-none">
  <div className="text-gray-800 leading-relaxed text-sm space-y-1.5">
    {response.answer?.split('\n').map((line, index) => {
      // Handle bold text with **
      let processedLine = line.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')

      // Handle italic text with single *
      processedLine = processedLine.replace(/\*([^*]+)\*/g, '<em>$1</em>')

      // Full line bold, bullet lists, numbered lists, empty lines handling...
      // Return properly formatted JSX with dangerouslySetInnerHTML
    })}
  </div>
</div>
```

## Markdown Features Supported

| Syntax     | Rendered As             |
| ---------- | ----------------------- |
| `**bold**` | **bold**                |
| `*italic*` | _italic_                |
| `- item`   | • item (bullet list)    |
| `1. item`  | 1. item (numbered list) |
| Empty line | Spacing                 |

## Files Modified

1. `src/components/FloatingChaSenAI.tsx` - Added markdown rendering to Response Modal section

## Impact

- ChaSen responses now display properly formatted text in all views
- Consistent rendering between Response Modal and full-chat mode
- Improved readability and professional appearance

## Verification

After fix:

- Bold text renders as bold (not `**text**`)
- Italic text renders as italic (not `*text*`)
- Lists display with proper bullets/numbers
- Both Response Modal and full-chat mode render identically

---

## Lessons Learned

1. **Consistency across components** - When the same content is displayed in multiple places, ensure formatting is applied consistently
2. **Test all display modes** - The full-chat mode was working but the Response Modal was not - both should be verified
3. **Centralise formatting logic** - Consider extracting markdown rendering to a shared utility function to avoid duplication
