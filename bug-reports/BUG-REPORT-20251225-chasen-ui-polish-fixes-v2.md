# Bug Report: ChaSen UI Polish Fixes - Part 2

**Date:** 25 December 2025
**Status:** FIXED
**Component:** ChaSen AI Page (`src/app/(dashboard)/ai/page.tsx`)

## Issues Fixed

### 1. Client Links with Parentheses Breaking

**Problem:** Client links containing parentheses (e.g., `SA Health (Sunrise)`, `Gippsland Health Alliance (GHA)`) were not rendering correctly. The URL was being truncated at the first `)`, leaving `/v2)` as plain text after the link.

**Root Cause:** The markdown link regex `/\[([^\]]+)\]\(([^)]+)\)/g` used `[^)]+` which stopped matching at the first `)` character in the URL.

**Fix:** Changed to balanced parentheses matching regex:

```javascript
// Old regex - fails on URLs with parentheses
/\[([^\]]+)\]\(([^)]+)\)/g

// New regex - handles balanced parentheses
/\[([^\]]+)\]\(((?:[^()]|\([^)]*\))+)\)/g
```

The pattern `((?:[^()]|\([^)]*\))+)` matches either:

- `[^()]` - any character except parentheses, OR
- `\([^)]*\)` - a balanced pair of parentheses with content

**File:** `src/app/(dashboard)/ai/page.tsx` (line ~469 in `processInlineFormatting`)

---

### 2. Explore Further Questions Not Clickable

**Problem:** The "Explore Further" follow-up questions at the end of ChaSen responses were rendering as paragraphs instead of clickable buttons.

**Root Cause:** Empty lines between the "💡 Explore Further" header and the numbered questions were resetting the `inExploreFurther` flag to `false`, preventing question detection.

**Fix:** Changed the section-end detection to only trigger on headers (`#`) or horizontal rules (`---`), not empty lines:

```javascript
// Old logic - empty lines ended the section
if (trimmedLine === '' || trimmedLine.startsWith('#') || trimmedLine.startsWith('---')) {
  inExploreFurther = false
}

// New logic - only headers and rules end the section
if (trimmedLine.startsWith('#') || trimmedLine === '---') {
  inExploreFurther = false
}

// Skip empty lines within Explore Further section
if (trimmedLine === '') {
  i++
  continue
}
```

**File:** `src/app/(dashboard)/ai/page.tsx` (lines ~249-256)

---

### 3. Markdown Links Showing in Question Button Text

**Problem:** When Explore Further questions contained markdown links like `[SA Health (Sunrise)](/clients/...)`, the raw markdown was displayed in the button text instead of just the display text.

**Fix:** Added `stripMarkdownLinks()` helper function that strips markdown link syntax for display while preserving the raw question for the click handler:

```typescript
function stripMarkdownLinks(text: string): string {
  // Use balanced parentheses matching to handle URLs with parentheses
  return text.replace(/\[([^\]]+)\]\(((?:[^()]|\([^)]*\))+)\)/g, '$1')
}

// Usage in button rendering
const displayText = stripMarkdownLinks(question)
<button onClick={() => onQuestionClick(question)}>
  <span className="flex-1">{displayText}</span>
</button>
```

**File:** `src/app/(dashboard)/ai/page.tsx` (lines ~163-166, ~231)

---

### 4. Section Heading Styling Enhancement

**Problem:** Response section headings were described as "dry and simple" - lacking visual hierarchy and professional polish.

**Changes Made:**

#### H2 Headers (Main Sections)

- Added gradient underline (purple to light purple)
- Increased spacing

#### H3 Headers (Subsections)

- Added context-aware icons based on header text:
  - `📊` for "Analysis"
  - `✅` for "Recommendations"
  - `📚` for "Resources"
  - `🎯` for "Action"
  - `📋` for "Summary"
  - `👁️` for "Overview"
  - `💡` for "Insight"
- Uppercase tracking for professional appearance

#### List Items

- Bullets changed from purple dots to en-dash (`–`)
- Numbers displayed in gray rounded badges

**File:** `src/app/(dashboard)/ai/page.tsx` (lines ~276-340)

---

## Files Changed

| File                              | Changes                                                                                         |
| --------------------------------- | ----------------------------------------------------------------------------------------------- |
| `src/app/(dashboard)/ai/page.tsx` | Balanced parentheses regex, empty line handling, `stripMarkdownLinks()` helper, section styling |

## Testing

1. Navigate to ChaSen AI page (http://localhost:3002/ai)
2. Ask any question (e.g., "Which clients need attention?")
3. Verify:
   - Client links with parentheses work (e.g., "Gippsland Health Alliance (GHA)" links to `/clients/Gippsland%20Health%20Alliance%20(GHA)/v2`)
   - "Explore Further" questions render as clickable buttons
   - Button text shows clean display text without markdown syntax
   - Section headers have icons and styled format
   - Clicking a question sends it as a new message

## Technical Notes

### Balanced Parentheses Regex Pattern

The pattern `((?:[^()]|\([^)]*\))+)` is a non-capturing group that matches:

1. `[^()]` - Any character that is NOT a parenthesis
2. `|` - OR
3. `\([^)]*\)` - A complete balanced pair: open paren, any non-close-paren chars, close paren

This allows URLs like `/clients/SA%20Health%20(Sunrise)/v2` to be fully captured because the `(Sunrise)` part is treated as a balanced pair within the larger URL match.

## Related Documentation

- `docs/BUG-REPORT-20251225-chasen-ui-polish-fixes.md` - Previous UI fixes (empty message bubble, initial Explore Further fix)
- `docs/FEATURE-20251225-chasen-rich-response-protocol.md` - Full rich response protocol
