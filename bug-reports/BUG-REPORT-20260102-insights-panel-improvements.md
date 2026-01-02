# Bug Report: Unified Insights Panel Improvements

**Date**: 2 January 2026
**Status**: Resolved
**Priority**: Medium
**Component**: BURC Performance > CSI Ratios > Analysis > Unified Insights Panel

## Issues Reported

### 1. Analysis Section Text Parsing
**Problem**: The "Analysis" section displayed poorly formatted text with items like:
- "2) Check for one-time events (acquisitions"
- "Restructuring)"

The numbered items were being split incorrectly at commas and parentheses, breaking mid-sentence.

**Root Cause**: The `extractReasoning` function in `utils.ts` used a regex pattern `[^,;)]+` that stopped at the first comma, semicolon, or closing parenthesis, breaking sentences with parenthetical content.

### 2. Technical Jargon in Anomaly Descriptions
**Problem**: Anomaly descriptions used technical language like:
- "GA spike (~32% deviation at index 5)"
- "Unusually high PS ratio (+15.2% from average)"

Users couldn't understand what "index 5" or "deviation" meant without technical knowledge.

### 3. Non-Functional Buttons
**Problem**: The "Investigate", "Create Task", and "More Info" buttons only showed toast notifications but didn't perform any actual actions. The callbacks weren't wired up in `CSITabsContainer.tsx`.

## Fixes Applied

### 1. Improved Text Parsing (`src/components/insights/utils.ts`)
- Replaced regex pattern to properly handle parenthetical content
- Changed from `[^,;)]+` to `[^.!?]*(?:\([^)]*\))?[^.!?]*[.!?]?`
- Added deduplication of extracted reasoning items
- Proper sentence boundary detection

### 2. User-Friendly Anomaly Descriptions

**Added `humaniseAnomalyDescription()` function** that transforms:
- "GA spike (~32% deviation at index 5)" → "General & Administrative expenses was 32% higher than expected in Q1 2026"
- "Unusually high PS ratio (+15.2% from average)" → "Professional Services revenue is 15.2% above the typical range"

**Added `RATIO_DISPLAY_NAMES` mapping**:
```typescript
const RATIO_DISPLAY_NAMES = {
  GA: 'General & Administrative expenses',
  PS: 'Professional Services revenue',
  RD: 'Research & Development spend',
  SALES: 'Sales performance',
  MAINTENANCE: 'Maintenance revenue',
}
```

**Updated source files**:
- `src/lib/csi-analytics.ts` - Uses friendly names at anomaly generation
- `src/lib/forecasting-engine.ts` - Uses friendly descriptions
- `src/components/insights/utils.ts` - Updated hardcoded reasoning text

**Before**:
> "Isolation Forest algorithm detected significant outliers"
> "Values exceed 3 standard deviations from mean"

**After**:
> "These values are significantly different from historical patterns"
> "This could indicate data entry errors, system issues, or genuine business changes"

### 3. Implemented Button Actions (`src/components/csi/CSITabsContainer.tsx`)

**Added `handleAddToActions` callback**:
- Creates a real action in the database via `createAction()`
- Maps insight severity to action priority
- Includes reasoning in the action description
- Shows toast with "View Tasks" button to navigate to Actions page

**Added `handleQuickAction` callback** with specific behaviours:
| Action ID | Behaviour |
|-----------|-----------|
| `investigate`, `investigate-critical`, `investigate-warning` | Switches to Analysis tab with info toast |
| `schedule-review` | Shows toast about scheduling (future: Outlook integration) |
| `monitor` | Adds to watch list with success toast |
| `review-renewals`, `review-pipeline`, etc. | Creates a task for follow-up |
| `add-note` | Shows "coming soon" info toast |

**Wired up callbacks** to `UnifiedInsightsPanel`:
```tsx
<UnifiedInsightsPanel
  ...
  onAddToActions={handleAddToActions}
  onQuickAction={handleQuickAction}
/>
```

## Files Modified

1. **`src/components/insights/utils.ts`**
   - Added `humaniseAnomalyDescription()` function
   - Added `getPeriodLabel()` for quarter labelling
   - Added `RATIO_DISPLAY_NAMES` constant
   - Improved `extractReasoning()` regex and logic
   - Updated `createAnomalyInsights()` with friendly text

2. **`src/lib/csi-analytics.ts`**
   - Added `RATIO_DISPLAY_NAMES` constant
   - Added `getRatioDisplayName()` function
   - Updated anomaly description generation (line 164)
   - Updated recommendation text generation (lines 1206-1219)

3. **`src/lib/forecasting-engine.ts`**
   - Updated anomaly description format (line 813)

4. **`src/components/csi/CSITabsContainer.tsx`**
   - Added imports: `useRouter`, `toast`, `createAction`, `MLInsight`
   - Added `handleAddToActions` callback
   - Added `handleQuickAction` callback
   - Wired callbacks to `UnifiedInsightsPanel`

## Testing

1. Navigate to BURC Performance > CSI Ratios > Analysis tab
2. Expand any insight card
3. Verify "Analysis" section shows complete, readable sentences
4. Verify anomaly descriptions use plain language (no "index 5" or "deviation")
5. Click "Create Task" → verify task is created and toast shows "View Tasks" button
6. Click "Investigate" → verify tab switches to Analysis with info toast
7. Click "Add to Watch List" → verify success toast appears

## Notes

- The "Schedule Review" action currently shows a toast but doesn't integrate with Outlook calendar. This is a future enhancement.
- The "Add Note" feature is marked as "coming soon" pending notes infrastructure.
- Period labels assume quarterly data with 8 quarters of history.
