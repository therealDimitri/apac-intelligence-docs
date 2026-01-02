# Bug Report: Client Status Summary Inconsistent Display

**Date:** 2026-01-02
**Status:** Fixed
**Severity:** Medium
**Component:** RightColumn - Client Status Summary

## Issue Description

The Client Status Summary section in the client profile Overview tab was displaying inconsistently across different client types:

- **Success type** (high performers): Showed "Key Achievements" bullet points only
- **Warning type** (at-risk clients): Showed "Areas Requiring Attention" bullet points only
- **Neutral type** (average performers): Showed metrics grid only

This inconsistency made it difficult to get a complete picture of client health at a glance, as users had to mentally piece together information from different sections.

## User Request

> "Why are the Overview summaries different for some clients. The display for WA Health is completely different to SA Health. Prefer the WA Health version but it needs to include a complete assessment of all client success metrics ie. Health Score, Segmentation Event Compliance progress, NPS Score, Working Capital performance and Actions Completion."

## Root Cause

The original implementation used mutually exclusive conditional rendering:
- `summaryType === 'success'` → show achievements only
- `summaryType === 'warning'` → show concerns only
- `summaryType === 'neutral'` → show metrics grid only

This meant users never saw both the metrics overview AND the contextual insights together.

## Solution Implemented

Modified the Client Status Summary to always display:

1. **AI Summary Text** - Contextual description of client status
2. **Comprehensive Metrics Grid** - Always shown for ALL summary types:
   - Health Score (with 3-tier colour coding: green ≥70, amber ≥50, red <50)
   - NPS Score (with 3-tier colour coding: green ≥50, amber ≥0, red <0)
   - Compliance % (with 3-tier colour coding: green ≥80%, amber ≥50%, red <50%)
   - Working Capital status (On Track / At Risk)
   - Actions completion % (with 3-tier colour coding: green ≥80%, amber ≥50%, red <50%)
3. **Key Achievements** (conditionally shown for `success` type)
4. **Areas Requiring Attention** (conditionally shown for `warning` type)

### Key Changes

```typescript
// BEFORE: Metrics grid only shown for neutral type
{summaryType === 'neutral' && (
  <div className="grid grid-cols-2 gap-2">
    {/* metrics */}
  </div>
)}

// AFTER: Metrics grid always shown
<div className="grid grid-cols-2 gap-2">
  {/* All 5 metrics always displayed */}
</div>

{/* Achievements/Concerns sections still conditional */}
{achievements.length > 0 && summaryType === 'success' && (...)}
{concerns.length > 0 && summaryType === 'warning' && (...)}
```

### Enhanced Colour Coding

Added 3-tier colour coding (green/amber/red) for all metrics instead of binary (green/red):

| Metric | Green | Amber | Red |
|--------|-------|-------|-----|
| Health Score | ≥70 | 50-69 | <50 |
| NPS | ≥50 | 0-49 | <0 |
| Compliance | ≥80% | 50-79% | <50% |
| Actions | ≥80% | 50-79% | <50% |
| Working Capital | On Track | - | At Risk |

## Files Modified

- `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`
  - Lines ~595-733: Restructured Summary Content section
  - Moved metrics grid outside conditional blocks
  - Added 3-tier colour coding for all metrics
  - Working Capital now always displays (defaults to "On Track" if no data)
  - Actions completion always displays (defaults to 100% if no actions)

## Testing Verification

1. **TypeScript compilation**: Passes
2. **Gippsland Health Alliance (success type)**:
   - Shows metrics grid: Health: 90, NPS: +100, Compliance: 100%, WC: On Track, Actions: 0%
   - Shows "Key Achievements" section below
3. **WA Health (warning type)**:
   - Shows metrics grid: Health: 36, Compliance: 25%, WC: On Track, Actions: 11%
   - Shows "Areas Requiring Attention" section below
   - Shows "AI Recommendations" section
4. **SA Health - Sunrise (neutral type)**:
   - Shows metrics grid with all 5 metrics
   - No additional achievements/concerns sections

## Expected Behaviour

All client profiles now display:
1. Contextual summary text describing overall status
2. Complete metrics grid with 5 KPIs (colour-coded by performance)
3. Relevant achievements OR concerns (based on client status)

This provides a consistent, comprehensive view of client health regardless of performance level.

## Prevention

Consider creating a design system component for "Metric Pills" that enforces consistent display across all dashboard sections. This would prevent similar inconsistencies in future features.
