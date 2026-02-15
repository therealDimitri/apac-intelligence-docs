# Bug Fix: Left Navigation Menu Not Scrolling to Sections

**Date:** 2026-01-16
**Severity:** Medium (UX Issue)
**Status:** ✅ Fixed

## Problem Description

When clicking on section navigation buttons (AI Tips, Coverage, MEDDPICC, StoryBrand) in the left sidebar of the Opportunity Strategy step, the page was not scrolling to the section header as expected.

### Symptoms
| Behaviour | Expected | Actual (Before Fix) |
|-----------|----------|---------------------|
| Click nav button | Page scrolls to section header | Scroll not working consistently |
| Navigation feedback | Active state highlights clicked section | Active state set correctly |
| User experience | Quick navigation to any section | Manual scrolling required |

## Root Cause

The navigation button's `onClick` handler was using a `navigateToSection` wrapper function that was previously modified to auto-expand sections. This added unnecessary complexity and dependencies that could interfere with the scroll behaviour.

## Solution

Simplified the `navigateToSection` function to directly call `scrollToSection` without any expand logic. The intended UX is for users to:
1. Click a nav button to scroll to that section's header
2. Manually expand/collapse sections as needed (preserving their preferences)

**Updated Code:**
```typescript
// Navigate to section: just scroll to it (don't auto-expand)
const navigateToSection = useCallback((sectionId: string) => {
  scrollToSection(sectionId)
}, [])
```

The `scrollToSection` function handles the actual scrolling:
```typescript
const scrollToSection = (sectionId: string) => {
  const element = document.getElementById(sectionId)
  if (element) {
    const offset = 120 // Account for sticky header
    const elementPosition = element.getBoundingClientRect().top + window.scrollY
    window.scrollTo({ top: elementPosition - offset, behavior: 'smooth' })
  }
}
```

## Files Modified

1. **`src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`**
   - Simplified `navigateToSection` to only scroll (no auto-expand)
   - Removed unnecessary state dependencies from the callback

## Verification

### Playwright Automation Test
1. Navigate to `/planning/strategic/new?id=<plan-id>`
2. Click "Collapse All" to collapse all sections
3. Click "StoryBrand Draft" in left nav
4. Verify: Page scrolls to StoryBrand section header (remains collapsed)
5. Click "AI Tips Ready" in left nav
6. Verify: Page scrolls to AI Suggestions section header

### Console Output (Debug)
```
[SCROLL] scrollToSection called: section-ai
[SCROLL] Element found: YES
[SCROLL] Scrolling to: 216 from current: 0
```

### Results
| Action | Before Fix | After Fix |
|--------|------------|-----------|
| Click nav button | Inconsistent scroll | Smooth scroll to section |
| Section state | May auto-expand | Preserves collapse/expand state |
| Active indicator | Set correctly | Set correctly |
| User control | Limited | Full control over expand/collapse |

## Related

- `OpportunityStrategyStep.tsx` - Main component with collapsible sections
- `scrollToSection` function - Utility for smooth scrolling with header offset
- `CollapsibleSection` component - Handles expand/collapse UI
- Previous fix: `BUG-FIX-ai-suggestions-not-loading-2026-01-16.md`
