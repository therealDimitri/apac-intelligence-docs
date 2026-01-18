# Bug Report: Plan Coverage Table UI Improvements

**Date:** 2026-01-18
**Status:** Fixed
**Severity:** Medium
**Component:** Strategic Planning Wizard - OpportunityStrategyStep

---

## Issues Reported

### 1. Overlapping Text in Plan Coverage Table
**Symptom:** Financial values (ACV, Weighted ACV) and status badges were overlapping, making data unreadable.

**Screenshot Evidence:** Status badges ("Pipeline", "Best Case") overlapped with ACV values showing garbled text like "P$1500k" and "Pi$945k".

### 2. Opportunity Names Truncated
**Symptom:** Long opportunity names were being cut off with ellipsis, hiding important information.

### 3. Client Logos Too Large
**Symptom:** Client logos (64px) consumed too much horizontal space, contributing to cramped layout.

### 4. Plain Text Notes Without Rich Text
**Symptom:** Opportunity notes used plain textarea, no support for formatting or @mentions.

### 5. AI Suggestions Missing Client Names
**Symptom:** AI-generated suggestions used generic "the client" instead of specific client names, causing confusion.

### 6. Incorrect Client Segments for John's Accounts
**Symptom:** All clients displayed "Maintain" segment regardless of actual ARR/NPS data.

---

## Root Cause Analysis

### Overlapping Text
- Grid column widths were too narrow for content
- Combined status badges (Forecast + Stage) in single 160px column
- Combined financial values (ACV + Weighted) in single 120px column

### Truncated Names
- CSS `truncate` class applied to opportunity names
- `min-w-0` container constraint preventing text wrap

### Large Logos
- Using `size="sm"` (64x64px) instead of smaller variant

### Plain Text Notes
- Using basic `<textarea>` instead of RichTextEditor component

### Missing Client Names
- AI prompt templates used generic language without client context

### Incorrect Segments
- Database records had outdated segment values not matching ARR/NPS criteria

---

## Fixes Applied

### 1. Grid Layout Overhaul
**File:** `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`

**Before:**
```typescript
grid-cols-[auto_1fr_160px_120px_100px_80px_50px_90px_40px]
```

**After:**
```typescript
grid-cols-[24px_minmax(200px,1fr)_100px_70px_100px_70px_50px_24px_70px_32px]
```

Changes:
- Separated Forecast and Stage badges into individual columns (100px + 70px)
- Separated ACV and Weighted ACV into individual columns (100px + 70px)
- Added `minmax(200px,1fr)` for flexible opportunity name column
- Removed Quarter column to save space
- Removed opportunity name truncation

### 2. Smaller Client Logos
**Change:** `size="sm"` → `size="xs"` (40x40px instead of 64x64px)

### 3. Rich Text Notes with @Mentions
**Implementation:**
- Integrated Tiptap RichTextEditor with dynamic import (SSR-safe)
- Added @mentions support via existing MentionSuggestion component
- HTML rendering in display mode with styled mentions
- Added hint text: "Use @ to mention"

### 4. AI Prompt Updates
**File:** `src/lib/planning/wizard-ai-prompts.ts`

Added to BASE_SYSTEM_PROMPT:
```typescript
- CRITICAL: Always include the client name in EVERY suggestedValue for clarity.
  Never use generic phrases like "the client" or "they" - always name the specific client
```

### 5. Database Segment Corrections
Updated client segments in `client_arr_summary` table:
- WA Health: Maintain → Sleeping Giant ($2.86M ARR, NPS -53)
- Western Health: Maintain → Nurture ($486K ARR, NPS -67)
- RVEEH: Maintain → Leverage ($100K ARR, NPS +100)
- GHA: Leverage → Collaboration ($1.4M ARR, NPS 7-9)

### 6. Type Definition Update
**File:** `src/app/(dashboard)/planning/strategic/new/steps/types.ts`

Added `notes?: string` field to PipelineOpportunity interface.

---

## Files Modified

| File | Changes |
|------|---------|
| `OpportunityStrategyStep.tsx` | Grid layout, logos, rich text notes |
| `types.ts` | Added notes field to PipelineOpportunity |
| `wizard-ai-prompts.ts` | Client name requirement in AI prompts |

## Database Changes

| Table | Field | Records Updated |
|-------|-------|-----------------|
| client_arr_summary | segment | 4 clients |

---

## Testing Verification

1. **Build Verification:** `npm run build` - Zero TypeScript errors
2. **Visual Verification:** No overlapping text in Plan Coverage table
3. **Rich Text:** @mentions dropdown appears when typing @
4. **Client Logos:** Smaller size (40x40px) displays correctly
5. **Full Names:** Opportunity names display without truncation

---

## Commits

1. `03d4639a` - Fix Plan Coverage table layout and overlapping text
2. `d880b02d` - Add rich text notes with @mentions to opportunity comments

---

## Related Issues

- AI suggestions clarity (client names)
- Client segmentation accuracy
- Save error logging improvements
