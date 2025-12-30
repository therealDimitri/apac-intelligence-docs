# Bug Report: CSI Trend Analysis & AI Insights UI/UX Improvements

**Date:** 30 December 2025
**Severity:** Low (UI/UX)
**Status:** Fixed

## Issues Summary

Two UI/UX issues in the CSI Analysis tab:

1. **Stat cards displayed below trend charts**: The summary statistics (Improving, Stable, Declining, At Target) were positioned below the individual ratio trend cards, making them less prominent
2. **AI Insights section required excessive vertical scrolling**: Full-width stacked cards with large padding consumed significant vertical space

## Root Causes

### Issue 1: Stat Cards Position
In `TrendAnalysisPanel.tsx`, the summary stats div was rendered after the ratio cards grid, despite logically being a summary that should appear first.

### Issue 2: AI Insights Layout
In `AIInsightsPanel.tsx`:
- Insight cards were full-width and vertically stacked
- Narrative section used an expandable accordion taking additional height
- Card components had generous padding (p-4) and spacing

## Solutions

### Issue 1: Stat Cards Reordering
**File:** `src/components/csi/TrendAnalysisPanel.tsx`

Moved the summary stats grid to render BEFORE the ratio cards:

```tsx
export function TrendAnalysisPanel({ ratios, className }: TrendAnalysisPanelProps) {
  return (
    <div className={cn('space-y-4', className)}>
      <h3>Trend Analysis</h3>

      {/* Summary stats - NOW AT TOP */}
      <div className="grid grid-cols-4 gap-4 p-4 bg-gray-50 rounded-lg">
        <div className="text-center">
          <span className="block text-2xl font-bold text-green-600">
            {Object.values(ratios).filter(r => r.trend.direction === 'improving').length}
          </span>
          <span className="text-xs text-gray-500">Improving</span>
        </div>
        {/* ... Stable, Declining, At Target ... */}
      </div>

      {/* Ratio cards - NOW BELOW STATS */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-4">
        {ratioOrder.map(ratio => <RatioCard key={ratio} ... />)}
      </div>
    </div>
  )
}
```

### Issue 2: AI Insights Redesign
**File:** `src/components/csi/AIInsightsPanel.tsx`

Major changes:

1. **Compact insight cards** - Renamed to `CompactInsightCard`:
   - Reduced padding (p-4 → p-3)
   - Border-left colour coding for insight type
   - Smaller font sizes (text-sm → text-xs)
   - Ratios displayed inline (max 3, then "+N")
   - Evidence truncated to 2 items with "+N more"

2. **2-column grid layout** for insight cards:
   ```tsx
   <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
     {insights.map(insight => (
       <CompactInsightCard key={insight.id} ... />
     ))}
   </div>
   ```

3. **Critical vs Other separation**:
   - Priority 1-2 insights grouped under "Critical / High Priority" header
   - Remaining insights under "Other Insights" header

4. **Tabbed narrative section** instead of expandable accordion:
   - 5 tabs: Summary, Trend, Concerns, Opportunities, Next Steps
   - Each with icon and compact label
   - Fixed height, horizontal navigation

5. **Summary + Narrative side-by-side**:
   ```tsx
   <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
     {/* Summary card */}
     {/* Tabbed narrative */}
   </div>
   ```

## Files Modified

| File | Changes |
|------|---------|
| `src/components/csi/TrendAnalysisPanel.tsx` | Moved summary stats grid before ratio cards |
| `src/components/csi/AIInsightsPanel.tsx` | Complete redesign with compact cards, 2-col grid, tabbed narrative |

## Visual Impact

**Before:**
- Stats appeared below ratio trend cards
- AI Insights required 3-4 scroll lengths to view all cards
- Narrative expanded vertically adding more height

**After:**
- Stats prominently displayed at top of Trend Analysis
- AI Insights fits within 1-2 scroll lengths max
- Narrative uses horizontal tabs, fixed height
- Critical insights highlighted separately

## Technical Notes

New type and constant added:
```typescript
type NarrativeTab = 'summary' | 'trend' | 'concerns' | 'opportunities' | 'next'

const NARRATIVE_TABS: { id: NarrativeTab; label: string; icon: React.ElementType }[] = [
  { id: 'summary', label: 'Summary', icon: FileText },
  { id: 'trend', label: 'Trend', icon: TrendingUp },
  { id: 'concerns', label: 'Concerns', icon: AlertCircle },
  { id: 'opportunities', label: 'Opportunities', icon: Zap },
  { id: 'next', label: 'Next Steps', icon: Target },
]
```

New imports added:
- `ChevronUp` (replacing `ChevronRight`)
- `FileText`, `Target`, `AlertCircle`, `Zap`

## Testing

1. Navigate to BURC Financials > CSI Ratios > Analysis tab
2. Verify:
   - Summary stat cards appear above ratio trend cards
   - AI Insights section uses 2-column grid
   - Narrative section uses horizontal tabs
   - Critical insights are highlighted separately
   - Overall vertical scrolling is significantly reduced
