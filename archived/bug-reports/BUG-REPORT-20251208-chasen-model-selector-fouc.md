# Bug Report: ChaSen AI Model Selector FOUC (Flash of Unstyled Content)

**Date:** 2025-12-08
**Reporter:** User
**Priority:** Medium
**Status:** ✅ Fixed

---

## Summary

Fixed Flash of Unstyled Content (FOUC) issue in the ChaSen AI model selector dropdown located in the top right side of the floating chat interface. The selector was briefly showing "Loading models..." before switching to the actual model list, creating a jarring visual flash.

---

## Issue Identified

### Symptoms:

- Model selector in ChaSen AI floating chat window displayed "Loading models..." option initially
- After API call completed (~500-1000ms), selector content changed to actual model list
- Visual flash/jump as dropdown content changed from loading state to loaded state
- Poor user experience due to unstable UI during initial render

### Location:

`src/components/FloatingChaSenAI.tsx` - Lines 860-888 (Model Selector component)

### Root Cause:

**State Management Issue:**

1. Line 32: `const [isLoadingModels, setIsLoadingModels] = useState(true)` - Initial state is `true`
2. Lines 38-61: `useEffect` fetches models from `/api/llms` API asynchronously
3. Line 56: `setIsLoadingModels(false)` - Only set to false after fetch completes
4. Lines 869-870: While loading, dropdown shows `<option>Loading models...</option>`
5. Lines 871-886: After loading, dropdown switches to actual model options
6. This content switch causes visible FOUC

**Original Code (Lines 862-887):**

```typescript
<select
  value={selectedModel}
  onChange={(e) => setSelectedModel(e.target.value)}
  className="w-full text-[10px] border-0 rounded px-2 py-1 bg-gray-50 text-gray-600 focus:outline-none focus:ring-1 focus:ring-purple-300 focus:bg-white transition-colors"
  title="Select AI Model"
  disabled={isLoadingModels}  // ❌ Selector still renders while loading
>
  {isLoadingModels ? (
    <option>Loading models...</option>  // ❌ Shows loading text
  ) : availableModels.length > 0 ? (
    availableModels.map((model) => (
      <option key={model.model_key} value={model.model_key}>
        {model.model_name}
      </option>
    ))
  ) : (
    // Fallback options...
  )}
</select>
```

**Problem:** The selector was always visible but changed its content after loading, causing FOUC.

---

## Fix Applied

### Solution: Conditional Rendering

Hide the entire model selector until models are loaded, preventing any visual flash.

**File:** `src/components/FloatingChaSenAI.tsx`

**Changes (Lines 860-887):**

```typescript
{/* Model Selector - Compact (Dynamic) - Only render when loaded to prevent FOUC */}
{!isLoadingModels && (  // ✅ Only render after loading completes
  <div className="px-4 py-1.5 bg-white border-b border-gray-100 flex-shrink-0">
    <select
      value={selectedModel}
      onChange={(e) => setSelectedModel(e.target.value)}
      className="w-full text-[10px] border-0 rounded px-2 py-1 bg-gray-50 text-gray-600 focus:outline-none focus:ring-1 focus:ring-purple-300 focus:bg-white transition-colors"
      title="Select AI Model"
    >
      {availableModels.length > 0 ? (
        availableModels.map((model) => (
          <option key={model.model_key} value={model.model_key}>
            {model.model_name}
          </option>
        ))
      ) : (
        // Fallback to hardcoded models if API fails
        <>
          <option value="claude-3-7-sonnet">Claude 3.7 Sonnet</option>
          <option value="claude-3-5-sonnet">Claude 3.5 Sonnet</option>
          <option value="claude-3-opus-4-1">Claude Opus 4.1</option>
          <option value="gemini-2-5-flash-lite">Gemini 2.5 Flash-Lite</option>
          <option value="gpt-4o">GPT-4o</option>
        </>
      )}
    </select>
  </div>
)}
```

**Key Changes:**

1. ✅ Wrapped entire selector `div` in conditional render: `{!isLoadingModels && (...)}`
2. ✅ Removed `disabled={isLoadingModels}` prop (no longer needed)
3. ✅ Removed "Loading models..." option (no longer needed)
4. ✅ Selector only appears after API call completes and models are loaded

---

## Result

**Before Fix:**

1. User opens ChaSen chat → Model selector appears with "Loading models..."
2. API call completes (~500-1000ms) → Selector content changes to model list
3. ❌ Visible flash as dropdown options change

**After Fix:**

1. User opens ChaSen chat → Model selector hidden
2. API call completes (~500-1000ms) → Selector appears with final model list
3. ✅ No visual flash, clean appearance with final content

**Benefits:**

- ✅ Eliminates FOUC entirely
- ✅ Cleaner initial render (no loading text)
- ✅ Better user experience
- ✅ Model selector only appears when fully ready
- ✅ Maintains fallback to hardcoded models if API fails

---

## Testing Performed

### Test 1: Initial Load

- ✅ Open ChaSen chat window
- ✅ Model selector does not appear immediately
- ✅ After ~500-1000ms, selector appears with full model list
- ✅ No visual flash or content change

### Test 2: API Success

- ✅ Models loaded from `/api/llms` endpoint
- ✅ Selector shows dynamic model list from database
- ✅ No "Loading models..." text visible

### Test 3: API Failure Fallback

- ✅ If API fails, selector shows hardcoded fallback models
- ✅ No error state visible to user
- ✅ Graceful degradation

### Test 4: Compilation

- ✅ Code compiles without TypeScript errors
- ✅ No console warnings
- ✅ Development server running successfully

---

## Related Components

### FloatingChaSenAI Component Flow:

1. Component mounts → `isLoadingModels = true`
2. `useEffect` runs → Fetches from `/api/llms`
3. API responds → `setAvailableModels(data.models)`
4. Loading complete → `setIsLoadingModels(false)`
5. Model selector renders → Shows final model list

### Dynamic Import in Layout:

**File:** `src/app/(dashboard)/layout.tsx` (Lines 11-17)

```typescript
const FloatingChaSenAI = dynamic(() => import('@/components/FloatingChaSenAI'), {
  ssr: false, // Client-side only
  loading: () => null, // No loading indicator
})
```

This dynamic import already prevents SSR issues, and our fix eliminates the client-side FOUC.

---

## Future Enhancements

### Potential Improvements:

1. **Loading Skeleton:** Show subtle skeleton UI while models load (instead of hiding completely)
2. **Transition Animation:** Add smooth fade-in animation when selector appears
3. **Preload Models:** Fetch models earlier in app lifecycle to reduce loading time
4. **Local Caching:** Cache model list in localStorage to show immediately on return visits

---

## Files Modified

1. ✅ `src/components/FloatingChaSenAI.tsx`
   - Lines 860-887: Wrapped model selector in conditional render
   - Removed loading state from dropdown options
   - Removed disabled prop (no longer needed)

---

## Related Documentation

- `src/components/FloatingChaSenAI.tsx` - ChaSen AI floating assistant component
- `src/app/(dashboard)/layout.tsx` - Dashboard layout with dynamic import
- `/api/llms` - API endpoint for fetching available LLM models

---

## Notes

- Fix is minimal and non-invasive (single conditional wrapper)
- No breaking changes to component API or behaviour
- Maintains all existing functionality (fallback models, model selection, etc.)
- Component still fetches models asynchronously but hides selector until ready
- Users experience clean, stable UI without content flashing

---

**Sign-off:**
FOUC issue resolved. ChaSen AI model selector now renders smoothly without visual flashing.
