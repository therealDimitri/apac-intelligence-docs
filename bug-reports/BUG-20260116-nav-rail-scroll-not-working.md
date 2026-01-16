# Bug Report: Nav Rail Scroll Not Working on Opportunity Strategy Page

**Date**: 16 January 2026
**Status**: Fixed
**Severity**: Medium
**Component**: Strategic Planning Wizard - Opportunity Strategy Step

## Issue Description

Clicking on nav rail items (AI Tips, Coverage, MEDDPICC, StoryBrand) on the Opportunity Strategy step did not navigate to the corresponding sections. The active state would change but the page would not scroll.

## Root Cause Analysis

### Problem 1: Wrong Scroll Container
The dashboard layout uses `<main className="flex-1 overflow-y-auto">` as the scroll container, but the scroll functions were using `window.scrollTo()` and `window.scrollY` which target the window/body.

```typescript
// Before - targeting window (wrong)
window.scrollTo({ top: elementPosition - offset, behavior: 'smooth' })
window.addEventListener('scroll', handleScroll)
```

### Problem 2: Collapsed Sections
When sections are collapsed, there's minimal content height - often fitting entirely within the viewport (`scrollHeight === clientHeight`). Clicking a nav item only changed the active state but couldn't scroll because there was nothing to scroll to.

## Fix Applied

**File**: `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`

### Changes

1. **Added `getScrollContainer()` helper**
   ```typescript
   const getScrollContainer = (): HTMLElement | null => {
     return document.querySelector('main.overflow-y-auto') as HTMLElement | null
   }
   ```

2. **Updated `useScrollSpy` hook**
   - Changed from `window.scrollY` to `scrollContainer.scrollTop`
   - Changed from `window.addEventListener` to `scrollContainer.addEventListener`

3. **Updated `scrollToSection` function**
   - Now scrolls the main container element instead of window
   - Added fallback to `scrollIntoView` if container not found

4. **Updated `navigateToSection` function**
   - Now expands the target section before scrolling
   - Uses double `requestAnimationFrame` to wait for DOM update after expansion
   ```typescript
   const navigateToSection = useCallback((sectionId: string) => {
     setSectionExpanded(prev => ({
       ...prev,
       [sectionId]: true,
     }))
     requestAnimationFrame(() => {
       requestAnimationFrame(() => {
         scrollToSection(sectionId)
       })
     })
   }, [setSectionExpanded])
   ```

## Testing

- TypeScript compilation: Passed
- Build compilation: Passed
- Manual testing: All 4 nav items (AI Tips, Coverage, MEDDPICC, StoryBrand) now correctly expand and scroll to their sections

## Verification

After clicking MEDDPICC nav button:
- `mainScrollTop: 523` - Container scrolled
- `meddpiccVisible: 120` - Section visible at expected offset
- `aiSectionTop: -187` - Previous section scrolled off-screen

## Related Files

- `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx` - Opportunity Strategy component
- `src/app/(dashboard)/layout.tsx` - Dashboard layout with scroll container
