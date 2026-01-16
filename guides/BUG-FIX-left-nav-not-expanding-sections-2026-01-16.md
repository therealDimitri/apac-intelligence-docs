# Bug Fix: Left Navigation Menu Not Expanding Collapsed Sections

**Date:** 2026-01-16
**Severity:** Medium (UX Issue)
**Status:** ✅ Fixed

## Problem Description

When clicking on section navigation buttons (AI Tips, Coverage, MEDDPICC, StoryBrand) in the left sidebar of the Opportunity Strategy step, the page would scroll to the section header but the section remained collapsed. Users couldn't see the section content.

### Symptoms
| Behaviour | Expected | Actual (Before Fix) |
|-----------|----------|---------------------|
| Click nav button | Section expands and scrolls into view | Only scrolls, section stays collapsed |
| Navigation feedback | Section is visible and active | Active state set but content hidden |
| User experience | One-click access to section | Required additional click to expand |

## Root Cause

The navigation button's `onClick` handler was calling `scrollToSection(section.id)` directly, which only scrolled to the element by ID. It did not check whether the section was collapsed or expand it before scrolling.

**Original Code:**
```typescript
<button
  key={section.id}
  onClick={() => scrollToSection(section.id)}
  ...
>
```

The `scrollToSection` function was defined outside the component and had no access to section expansion state:
```typescript
const scrollToSection = (sectionId: string) => {
  const element = document.getElementById(sectionId)
  if (element) {
    const offset = 120
    const elementPosition = element.getBoundingClientRect().top + window.scrollY
    window.scrollTo({ top: elementPosition - offset, behavior: 'smooth' })
  }
}
```

## Solution

Added a new `navigateToSection` function inside the component that:
1. Checks if the section is collapsed
2. Expands it if necessary
3. Waits 100ms for DOM to update
4. Then scrolls to the section

**New Code:**
```typescript
// Navigate to section: expand if collapsed, then scroll
const navigateToSection = useCallback(
  (sectionId: string) => {
    // Expand the section if it's collapsed
    if (!sectionExpanded[sectionId]) {
      setSectionExpanded(prev => ({
        ...prev,
        [sectionId]: true,
      }))
      // Wait for DOM to update before scrolling
      setTimeout(() => {
        scrollToSection(sectionId)
      }, 100)
    } else {
      // Already expanded, just scroll
      scrollToSection(sectionId)
    }
  },
  [sectionExpanded, setSectionExpanded]
)
```

**Updated button handler:**
```typescript
<button
  key={section.id}
  onClick={() => navigateToSection(section.id)}
  ...
>
```

## Files Modified

1. **`src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`**
   - Added `navigateToSection` callback function
   - Updated navigation button onClick to use `navigateToSection`

## Verification

### Playwright Automation Test
1. Navigate to `/planning/strategic/new?id=<plan-id>`
2. Click "Collapse All" to collapse all sections
3. Click "StoryBrand Draft" in left nav
4. Verify: StoryBrand section expands and scrolls into view
5. Click "MEDDPICC 70%" in left nav
6. Verify: MEDDPICC section expands and scrolls into view

### Results
| Action | Before Fix | After Fix |
|--------|------------|-----------|
| Click collapsed section | Scrolls only | Expands + scrolls |
| Active state | Set correctly | Set correctly |
| Section content | Hidden | Visible |
| User clicks needed | 2 (nav + expand) | 1 (nav only) |

## Related

- `OpportunityStrategyStep.tsx` - Main component with collapsible sections
- `scrollToSection` function - Utility for smooth scrolling
- `CollapsibleSection` component - Handles expand/collapse UI
- Previous fix: `BUG-FIX-ai-suggestions-not-loading-2026-01-16.md`
