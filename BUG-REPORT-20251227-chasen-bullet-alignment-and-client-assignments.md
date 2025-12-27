# Bug Report: ChaSen Markdown Rendering and Client Assignments

**Date:** 27 December 2025
**Severity:** Medium
**Status:** Fixed
**Commits:** `d062e1e`, `4f59894`, `464f3a8`, `ac274a2`, `e48b4bf`

## Summary

Multiple issues with ChaSen response formatting:
1. Bullet points were misaligned (appearing too low relative to text)
2. Team member client assignments were not included in org context
3. Section headers had same bullet style as list items (unprofessional)
4. Labeled items (e.g., "Key Responsibilities: content") not styled distinctly
5. Plain text labels without bold markers not detected

## Issue 1: Bullet Alignment

### Symptoms

Bullet points (`•`) appeared below the text baseline, making the formatting look inconsistent.

### Root Cause

The bullet rendering in `markdown-renderer.tsx` used `items-start` with `mt-1.5`, which pushed bullets down too far.

**Location:** `src/lib/markdown-renderer.tsx:632-633`

**Before:**
```tsx
<div key={i} className="ml-2 text-[15px] leading-relaxed mb-2 flex items-start">
  <span className="mr-2 mt-1.5 text-purple-500 flex-shrink-0">•</span>
```

**After:**
```tsx
<div key={i} className="ml-2 text-[15px] leading-relaxed mb-2 flex items-baseline">
  <span className="mr-2 text-purple-500 flex-shrink-0">•</span>
```

### Fix

- Changed `items-start` to `items-baseline` for proper vertical alignment
- Removed `mt-1.5` margin that was pushing bullets down

---

## Issue 2: Missing Client Assignments

### Symptoms

When asking about a team member like Gilbert So, only one of his assigned clients was shown instead of all of them.

### Root Cause

The stream endpoint (`/api/chasen/stream/route.ts`) did not include client assignment data in the org context. The LLM had no information about which clients each team member was responsible for.

**Location:** `src/app/api/chasen/stream/route.ts:1364-1403`

### Fix

Added query to fetch client assignments for all team members:

```typescript
// Fetch client assignments for all team members
const { data: clientAssignments } = await supabase
  .from('client_segmentation')
  .select('client_name, cse_name')
  .in('cse_name', directReports.map(dr => dr.full_name))

// Create a map of CSE name to their assigned clients
const assignmentMap = new Map<string, string[]>()
clientAssignments?.forEach(ca => {
  if (!assignmentMap.has(ca.cse_name)) {
    assignmentMap.set(ca.cse_name, [])
  }
  assignmentMap.get(ca.cse_name)!.push(ca.client_name)
})

// Include in each team member's context line
const assignedClients = assignmentMap.get(dr.full_name) || []
const clientsInfo = assignedClients.length > 0
  ? ` | Assigned Clients: ${assignedClients.join(', ')}`
  : ''
```

Also added instruction to LLM to always include ALL clients:
```typescript
parts.push(
  `• IMPORTANT: When listing a team member's assigned clients, include ALL their clients, not just a subset`
)
```

---

## Files Modified

| File | Changes |
|------|---------|
| `src/lib/markdown-renderer.tsx` | Changed bullet alignment from `items-start` + `mt-1.5` to `items-baseline`; added section header and labeled item detection |
| `src/app/api/chasen/stream/route.ts` | Added client_segmentation query, included assigned clients in team member context; added bidirectional alias lookup for NPS data |

## Verification

After the fix, responses correctly show:
1. Bullets aligned with text baseline
2. All assigned clients for each team member (e.g., Gilbert So: SLMC + GRMC)

## Testing

1. Navigate to `/ai` (ChaSen AI page)
2. Ask "Tell me about Gilbert So. What clients is he assigned to?"
3. Verify:
   - Bullet points align with text (not below)
   - Both SLMC and GRMC are listed as assigned clients
   - Profile photo displays correctly

---

## Issue 3: Section Headers Same as List Items

### Symptoms

Section headers like "**Assigned Clients:**" rendered with the same bullet style as list items beneath them, making it hard to distinguish hierarchy.

### Fix (Commit `464f3a8`)

Added detection for section headers (bold text ending with colon) to render without bullets:

```typescript
const isSectionHeader = /^\*\*[^*]+:\*\*$/.test(content) || /^\*\*[^*]+\*\*:$/.test(content)

if (isSectionHeader) {
  const headerText = content.replace(/\*\*/g, '').replace(/:$/, '')
  elements.push(
    <div key={i} className="mt-4 mb-2 text-[15px] font-semibold text-gray-800">
      {headerText}
    </div>
  )
}
```

---

## Issue 4: Labeled Items Not Styled Distinctly

### Symptoms

Bullet items starting with bold labels like `• **Key responsibilities**: content` rendered with same bullet style as regular items.

### Fix (Commit `ac274a2`)

Added detection for labeled items (bold label + colon + content) to render without bullets:

```typescript
const labeledItemMatch = content.match(/^\*\*([^*]+)\*\*:\s*(.*)$|^\*\*([^*]+):\*\*\s*(.*)$/)

if (labeledItemMatch) {
  const label = labeledItemMatch[1] || labeledItemMatch[3]
  const itemContent = labeledItemMatch[2] || labeledItemMatch[4] || ''
  elements.push(
    <div key={i} className="mt-3 mb-1.5 text-[15px] leading-relaxed">
      <span className="font-semibold text-gray-800">{label}</span>
      <span className="text-gray-500">: </span>
      <span className="text-gray-700">{processedContent}</span>
    </div>
  )
}
```

---

## Issue 5: Plain Text Labels Not Detected

### Symptoms

LLM sometimes generates labeled items without bold markers (e.g., "Key responsibilities: content") which rendered as plain paragraphs.

### Fix (Commit `e48b4bf`)

Added detection for plain text labels (capitalized phrase followed by colon):

```typescript
const plainLabelMatch = trimmedLine.match(/^([A-Z][a-zA-Z\s]+):\s*(.+)$/)
if (plainLabelMatch && plainLabelMatch[1].length <= 30) {
  const label = plainLabelMatch[1]
  const content = plainLabelMatch[2]
  elements.push(
    <div key={i} className="mt-3 mb-2 text-[15px] leading-relaxed">
      <span className="font-semibold text-gray-800">{label}</span>
      <span className="text-gray-500">: </span>
      <span className="text-gray-700">{processedContent}</span>
    </div>
  )
}
```

---

## Issue 6: NPS Data Shows N/A (Fixed)

### Symptoms

NPS scores showed "N/A" for clients like GRMC even though NPS data existed in the database.

### Root Cause

Client names in `nps_responses` table don't match names in `client_segmentation`:
- Segmentation: "Guam Regional Medical City (GRMC)"
- NPS: "Guam Regional Medical Centre"

The `formatClientNps` function did a direct lookup without considering aliases.

### Fix

Added bidirectional alias lookup to the stream route:

```typescript
/**
 * Build a bidirectional alias map for client name lookups
 */
async function buildClientAliasMap(supabase): Promise<Map<string, Set<string>>> {
  const aliasGroups = new Map<string, Set<string>>()
  const { data: aliases } = await supabase
    .from('client_name_aliases')
    .select('canonical_name, display_name')
    .eq('is_active', true)

  // Build groups of related names and create bidirectional lookup
  // ...
  return aliasGroups
}

// In formatClientNps:
const formatClientNps = (clientName: string): string => {
  let npsData = clientNpsMap.get(clientName)

  // If not found, try alias lookup
  if (!npsData) {
    const aliases = aliasMap.get(clientName)
    if (aliases) {
      for (const alias of aliases) {
        npsData = clientNpsMap.get(alias)
        if (npsData) break
      }
    }
  }
  // ...
}
```

---

## Issue 7: Table Links Showing Raw URLs (Fixed)

### Symptoms

The "Open Actions" and "Recent Meetings" rows in the Client Health Card table displayed raw URL syntax like `(/actions?client=...)` instead of proper clickable links.

### Root Cause

The LLM prompt template showed placeholders `[X]` for these cells without demonstrating proper markdown link format in table context.

### Fix

Updated the table template in the system prompt to show proper link syntax:

```markdown
| Open Actions | [View X Actions](/actions?client=URL_ENCODED_CLIENT_NAME) |
| Recent Meetings | [View Meetings](/meetings?client=URL_ENCODED_CLIENT_NAME) |
```

**Location:** `src/app/api/chasen/stream/route.ts:1590-1591`

---

## Related

- [Profile Photos Bug](./BUG-REPORT-20251227-chasen-profile-photos-not-rendering.md)
- [Stream Org Context Bug](./BUG-REPORT-20251227-chasen-stream-missing-org-context.md)
