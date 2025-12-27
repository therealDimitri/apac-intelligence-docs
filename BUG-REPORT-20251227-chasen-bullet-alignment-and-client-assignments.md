# Bug Report: ChaSen Bullet Alignment and Missing Client Assignments

**Date:** 27 December 2025
**Severity:** Low
**Status:** Fixed
**Commits:** `d062e1e`, `4f59894`

## Summary

Two issues with ChaSen responses:
1. Bullet points were misaligned (appearing too low relative to text)
2. Team member client assignments were not included in org context, causing incomplete responses

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
| `src/lib/markdown-renderer.tsx` | Changed bullet alignment from `items-start` + `mt-1.5` to `items-baseline` |
| `src/app/api/chasen/stream/route.ts` | Added client_segmentation query, included assigned clients in team member context |

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

## Related

- [Profile Photos Bug](./BUG-REPORT-20251227-chasen-profile-photos-not-rendering.md)
- [Stream Org Context Bug](./BUG-REPORT-20251227-chasen-stream-missing-org-context.md)
