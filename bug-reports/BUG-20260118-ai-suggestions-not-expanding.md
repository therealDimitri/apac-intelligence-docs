# Bug Report: AI Suggestions Section Not Expanding on Opportunity Strategy Page

**Date:** 18 January 2026
**Status:** Fixed
**Severity:** Medium
**Component:** Strategic Planning > Opportunity Strategy > AI Suggestions

---

## Problem Description

The AI Suggestions section on the Opportunity Strategy page (Step 4) showed "7 suggestions available" in the navigation but clicking on the section header did not reveal the suggestions content. The section appeared to expand (collapse button changed to "Collapse section") but no content was visible.

### Observed Behaviour

1. Navigation shows "AI Tips: 7 tips"
2. Clicking the AI Suggestions section header changes button from "Expand" to "Collapse"
3. No AI suggestion content appears below the header
4. Users unable to view or apply AI-generated MEDDPICC and StoryBrand suggestions

---

## Root Cause Analysis

The issue was caused by conflicting collapse states between two nested components:

### Component Architecture

```
CollapsibleSection (parent)
  └── AIPrePopulation (child)
```

### The Problem

1. **`CollapsibleSection`** - Outer component with `isExpanded` state controlled by parent
2. **`AIPrePopulation`** - Inner component with its own `isCollapsed` state

The `AIPrePopulation` component at `/src/components/planning/methodology/AIPrePopulation.tsx` has:

```typescript
export default function AIPrePopulation({
  hideHeader = false,
  defaultCollapsed = true,  // Defaults to collapsed!
}: AIPrePopulationProps) {
  const [isCollapsed, setIsCollapsed] = useState(defaultCollapsed)

  // ...

  // Content only renders when NOT collapsed:
  {!isCollapsed && (
    <>
      {/* Suggestions content */}
    </>
  )}
}
```

When called from `OpportunityStrategyStep.tsx`:

```typescript
<AIPrePopulation
  suggestions={aiSuggestions}
  // ...
  hideHeader  // Hides the internal toggle button!
  // defaultCollapsed not specified, defaults to true
/>
```

**Result**: The `hideHeader` prop hid the internal toggle button, but `isCollapsed` still defaulted to `true`, preventing content from rendering.

---

## Solution Implemented

Added `defaultCollapsed={false}` to the `AIPrePopulation` component call in `/src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`:

```typescript
<AIPrePopulation
  suggestions={aiSuggestions}
  dataEvidence={aiDataEvidence}
  isLoading={aiSuggestionsLoading}
  onApply={handleApplyAISuggestion}
  onApplyAll={() =>
    aiSuggestions.forEach(s => handleApplyAISuggestion(s.fieldId, s.suggestedValue))
  }
  onRefresh={onLoadAISuggestions || (() => {})}
  appliedFields={appliedSuggestions}
  clientName={clientName}
  hideHeader
  defaultCollapsed={false}  // <-- Added this
/>
```

### Why This Fix Works

- When `hideHeader=true`, the internal toggle button is hidden
- Setting `defaultCollapsed={false}` ensures content renders immediately
- The outer `CollapsibleSection` now controls visibility as expected

---

## Files Affected

| File | Changes |
|------|---------|
| `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx` | Added `defaultCollapsed={false}` to AIPrePopulation component (line 1201) |

---

## Testing Steps

1. Navigate to Planning Hub
2. Open any strategic plan (e.g., Laura Messing's Account Plan 2026)
3. Go to Step 4 (Opportunities)
4. Verify the AI Suggestions section shows loading state, then displays suggestions
5. Verify all 7 suggestions are visible with:
   - Confidence badges (High/Medium/Low)
   - Apply/Copy buttons
   - Data Sources accordion

---

## Prevention Recommendations

1. **Avoid Nested Collapse States**: When a component has its own internal collapse state, consider whether `hideHeader` should automatically set `defaultCollapsed={false}`

2. **Component API Improvement**: The `AIPrePopulation` component could be modified to automatically expand when `hideHeader=true`:

   ```typescript
   const [isCollapsed, setIsCollapsed] = useState(
     hideHeader ? false : defaultCollapsed
   )
   ```

---

## Related Issues

- None

---

## Commit Reference

- `33ac6785` - fix: AI Suggestions section now expands correctly on Opportunity Strategy page
