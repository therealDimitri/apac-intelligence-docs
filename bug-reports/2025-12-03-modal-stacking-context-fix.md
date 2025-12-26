# Bug Report: Modal Visibility Issue - CSS Stacking Context

**Date**: 2025-12-03
**Severity**: Critical
**Status**: ✅ RESOLVED

---

## Issue Summary

Health Score and Compliance modals were not displaying when clicked, despite components rendering successfully in the DOM. Modals appeared to exist but were completely invisible to users.

## Symptoms

- Clicking Health Score circle: White screen, no modal visible
- Clicking "View Detailed Breakdown": White screen, no modal visible
- Console logs showed successful component renders and data loading
- No JavaScript errors in console
- DOM inspection revealed modals existed but were marked as `visible: false`

## Root Cause

**CSS Stacking Context Problem**

The modals were trapped in their parent component's stacking context:

```
Page Structure:
├── Layout Container (normal stacking context)
│   ├── LeftColumn
│   │   └── Health Modal (z-[9999]) ❌ Trapped here
│   └── RightColumn
│       └── Compliance Modal (z-[9999]) ❌ Trapped here
└── White Overlay (z-[100]) ✅ At page level
```

Despite modals having `z-index: 9999`, they couldn't escape their parent containers' stacking context. The white overlay at `z-index: 100` was at the document root level, creating a higher stacking context that covered the nested modals.

**Key CSS Rule**: A child element's z-index only compares within its parent's stacking context. It cannot "break out" to compete with siblings of its ancestors.

## Technical Details

### Before (Broken):
```tsx
// LeftColumn.tsx - Modal nested in component
export default function LeftColumn({ client }: Props) {
  return (
    <div className="space-y-4">
      {/* Modal rendered here - trapped in parent stacking context */}
      {showHealthModal && (
        <div className="fixed inset-0 z-[9999]">
          {/* Modal content */}
        </div>
      )}
    </div>
  )
}

// page.tsx - Overlay at page level
{isAnyModalOpen && (
  <div className="fixed inset-0 z-[100] bg-white" />
)}
```

**Problem**: Modal at z-[9999] inside LeftColumn vs Overlay at z-[100] at page root = Overlay wins

### After (Fixed):
```tsx
// LeftColumn.tsx - Using React Portal
import { createPortal } from 'react-dom'

export default function LeftColumn({ client }: Props) {
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  return (
    <div className="space-y-4">
      {/* Modal rendered to document.body via Portal */}
      {mounted && showHealthModal && createPortal(
        <div className="fixed inset-0 z-[9999]">
          {/* Modal content */}
        </div>,
        document.body
      )}
    </div>
  )
}
```

**Solution**: Both modal and overlay are now siblings at document.body level, z-index comparison works correctly.

## Files Modified

### 1. `/src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`
**Changes**:
- Added `createPortal` import from `react-dom`
- Added `mounted` state with useEffect for SSR safety
- Wrapped Health Score modal with `createPortal(modal, document.body)`
- Wrapped NPS Analysis modal with `createPortal(modal, document.body)`

**Lines**: 1-6, 47-55, 365-566, 567-720

### 2. `/src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`
**Changes**:
- Added `createPortal` import from `react-dom`
- Added `mounted` state with useEffect for SSR safety
- Wrapped Compliance Details modal with `createPortal(modal, document.body)`

**Lines**: 1-7, 50-73, 800-1283

## Solution Implementation

### React Portal Pattern

```tsx
// 1. Import Portal
import { createPortal } from 'react-dom'

// 2. Add mounted state (prevents SSR issues)
const [mounted, setMounted] = useState(false)

useEffect(() => {
  setMounted(true)
}, [])

// 3. Use Portal to render to document.body
{mounted && showModal && createPortal(
  <div className="fixed inset-0 z-[9999] flex items-center justify-center p-4 bg-gray-900/30 backdrop-blur-xl">
    {/* Modal content */}
  </div>,
  document.body
)}
```

### Why This Works

1. **Breaks out of stacking context**: Modal is no longer nested in parent components
2. **Renders at document root**: Modal becomes a direct child of `<body>`
3. **z-index now effective**: Modal at z-[9999] properly sits above overlay at z-[100]
4. **SSR safe**: `mounted` check prevents hydration mismatches

## Visual Styling Applied

### Modal Backdrop
- Changed from `bg-white/60` (invisible on white) to `bg-gray-900/30` (visible dark tint)
- Applied `backdrop-blur-xl` for glassy effect
- z-index: 9999

### White Overlay (Background Hide)
- Solid white: `bg-white`
- z-index: 100
- Purpose: Hide page content when modals open

## Testing & Verification

### Test Cases Passed ✅

1. **Health Score Modal**
   - Click Health Score circle → Modal appears
   - Background blurred with dark overlay
   - All components visible (Working Capital, NPS, Engagement, Events, Actions, Recency)
   - Close button works
   - Background content hidden

2. **Compliance Details Modal**
   - Click "View Detailed Breakdown" → Modal appears
   - Shows overall compliance score (78%)
   - Displays event type breakdown with progress bars
   - Shows monthly overview calendar
   - Export Report button functional
   - Background content hidden

3. **No Regressions**
   - Date headers no longer bleed through
   - Modals properly centered
   - Scrolling works within modals
   - Close buttons functional
   - Parent notification working (onModalChange callback)

## Browser Compatibility

Tested on Chrome. React Portal is supported in all modern browsers:
- Chrome/Edge: ✅
- Firefox: ✅
- Safari: ✅

## Lessons Learned

1. **Z-index is contextual**: A child's z-index only matters within its parent's stacking context
2. **React Portals solve this**: Use `createPortal` when you need to break out of DOM hierarchy
3. **SSR considerations**: Always check `mounted` state before rendering portals to prevent hydration issues
4. **Debugging z-index**: Inspect DOM hierarchy, not just z-index values

## References

- [MDN: CSS Stacking Context](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Positioning/Understanding_z_index/The_stacking_context)
- [React Portals Documentation](https://react.dev/reference/react-dom/createPortal)
- [Understanding z-index](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Positioning/Understanding_z_index)

---

## Resolution Timeline

| Time | Action |
|------|--------|
| Initial Report | User: "Modals are now completely GONE!!!!! FIX" |
| Investigation | Used Kapture to inspect DOM, found modals exist but `visible: false` |
| Root Cause | Identified CSS stacking context issue via DOM inspection |
| Solution | Implemented React Portal pattern for both modals |
| Verification | Tested both Health Score and Compliance modals - both working |
| Documentation | Created this bug report |
| Commit | Changes committed to git |

**Fix Verified**: Both modals now display perfectly with professional styling ✅
