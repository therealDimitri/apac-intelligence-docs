# Bug Report: ChaSen NPS Calculation and Markdown Link Rendering

**Date:** 26 December 2025
**Status:** Fixed
**Commit:** `610b5ca`
**Severity:** High

---

## Summary

ChaSen AI was displaying incorrect NPS scores and client profile deep links were not rendering as clickable elements.

---

## Issues Identified

### Issue 1: Incorrect NPS Scores

**Symptoms:**

- ChaSen reported Epworth NPS as "0 points" when actual quarterly NPS was **-100**
- Individual response scores (0-10) were being confused with client-level NPS (-100 to +100)
- No differentiation between quarterly and overall NPS data

**Root Cause:**

- ChaSen was reading NPS from `client_health_history.nps_points` which contained stale/incorrect snapshot data
- The `nps_points` field was showing 0 for Epworth when the calculated quarterly NPS from `nps_responses` showed -100

**Evidence (Database Query):**

```
=== All Epworth NPS by Period ===
Q4 25: NPS = -100 (P:0 Pa:0 D:1 Total:1)
Q2 25: NPS = -100 (P:0 Pa:0 D:3 Total:3)
Q4 24: NPS = -100 (P:0 Pa:0 D:3 Total:3)
Q2 24: NPS = 0 (P:0 Pa:1 D:0 Total:1)

=== client_health_history nps_points for Epworth ===
[ { client_name: 'Epworth Healthcare', nps_points: 0, ... } ]  ← WRONG!
```

### Issue 2: Client Profile Deep Links Not Rendering

**Symptoms:**

- Client names like "Te Whatu Ora Waikato" appeared as plain text instead of clickable links
- Markdown links in H4 headers were not being processed
- Markdown links in table cells were not being processed

**Root Cause:**

- H4 header rendering (`#### Header`) was outputting raw text without calling `processInlineFormatting()`
- Table cell rendering was not processing markdown links `[text](url)`

---

## Fix Implementation

### Fix 1: NPS Calculation from Source Data

**File:** `src/app/api/chasen/stream/route.ts`

Added two new functions:

```typescript
/**
 * Calculate NPS score from individual responses
 * Returns NPS on -100 to +100 scale
 */
function calculateNPS(responses: Array<{ score: number }>): {
  nps: number
  promoters: number
  passives: number
  detractors: number
  total: number
} {
  if (!responses || responses.length === 0) {
    return { nps: 0, promoters: 0, passives: 0, detractors: 0, total: 0 }
  }

  let promoters = 0
  let passives = 0
  let detractors = 0

  for (const r of responses) {
    if (r.score >= 9) promoters++
    else if (r.score >= 7) passives++
    else detractors++
  }

  const total = responses.length
  const nps = Math.round(((promoters - detractors) / total) * 100)

  return { nps, promoters, passives, detractors, total }
}

/**
 * Get the latest quarter period string (e.g., "Q4 25")
 */
function getLatestQuarter(periods: string[]): string | null {
  // Sort periods in descending order (Q4 25 > Q3 25 > Q2 25 > Q1 25 > Q4 24...)
  const sorted = [...periods].sort((a, b) => {
    const [qA, yA] = a.split(' ')
    const [qB, yB] = b.split(' ')
    const yearA = parseInt(yA) + (parseInt(yA) < 50 ? 2000 : 1900)
    const yearB = parseInt(yB) + (parseInt(yB) < 50 ? 2000 : 1900)
    if (yearA !== yearB) return yearB - yearA
    return parseInt(qB.replace('Q', '')) - parseInt(qA.replace('Q', ''))
  })

  return sorted[0]
}
```

Modified `getLiveDashboardContext()` to:

1. Fetch all NPS responses from `nps_responses` table directly
2. Group by client and period
3. Calculate NPS per client for latest quarter AND overall
4. Use calculated NPS instead of stale `client_health_history.nps_points`

### Fix 2: Markdown Link Rendering

**File:** `src/lib/markdown-renderer.tsx`

**H4 Header Fix:**

```typescript
// H4 Headers (#### Header) - process inline formatting including links
if (trimmedLine.startsWith('#### ')) {
  const headerText = trimmedLine.substring(5)
  const processedHeader = processInlineFormatting(headerText)
  elements.push(
    <h4
      key={i}
      className="text-sm font-medium text-gray-600 mt-3 mb-1.5"
      dangerouslySetInnerHTML={{ __html: processedHeader }}
    />
  )
  i++
  continue
}
```

**Table Cell Fix:**

```typescript
// Process markdown links in table cells [text](url)
const processTableCell = (cell: string): string => {
  return cell.replace(/\[([^\]]+)\]\(((?:[^()]|\([^)]*\))+)\)/g, (_, linkText, url) => {
    const isInternal = url.startsWith('/') && !url.startsWith('//')
    if (isInternal) {
      return `<a href="${url}" class="text-blue-600 hover:text-blue-800 hover:underline">${linkText}</a>`
    } else {
      return `<a href="${url}" target="_blank" rel="noopener noreferrer" class="text-blue-600 hover:text-blue-800 hover:underline">${linkText}</a>`
    }
  })
}
```

---

## Verification

### NPS Verification

Query: "What is Epworth's NPS?"

- **Before:** "0 points"
- **After:** "-100 points for Q4 2025"

### Link Rendering Verification

Query: "Show me all my clients NPS scores"

- **Before:** Client names appeared as plain text
- **After:** All client names render as clickable blue links navigating to `/clients/{clientName}/v2`

---

## Files Changed

| File                                 | Lines Changed | Description                                         |
| ------------------------------------ | ------------- | --------------------------------------------------- |
| `src/app/api/chasen/stream/route.ts` | +141/-4       | NPS calculation functions, data context enhancement |
| `src/lib/markdown-renderer.tsx`      | +27/-2        | H4 header and table cell link processing            |

---

## Key Learnings

1. **Data Source Validation:** Snapshot data (like `client_health_history`) can become stale. For real-time accuracy, calculate from source tables (`nps_responses`)

2. **NPS Scale Clarity:** Individual NPS response scores (0-10) are fundamentally different from client-level NPS (-100 to +100). System prompts and data context must clearly differentiate these

3. **Markdown Processing Consistency:** All elements that may contain markdown links (headers, table cells, list items) need consistent link processing

---

## Related Issues

- Previous NPS fix attempt: Commit `2be2418` - Added NPS data guidance to system prompt (insufficient fix)
- Related markdown rendering: `BUG-REPORT-20251219-chasen-markdown-rendering.md`
