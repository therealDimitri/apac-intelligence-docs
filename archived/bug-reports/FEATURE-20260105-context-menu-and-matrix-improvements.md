# Feature: Context Menu for AI Recommendations & Priority Matrix Improvements

**Date:** 5 January 2026
**Type:** Feature Enhancement
**Status:** Completed

---

## Summary

This update adds two key improvements:
1. Right-click "Create Action" context menu on all AI/ML recommendations across the dashboard
2. Auto-hide completed items from the Priority Matrix 2x2 view

---

## Changes Made

### 1. Right-Click Context Menu for AI/ML Recommendations

**Problem:** Users had to manually create actions from AI recommendations, requiring multiple clicks and copy-pasting of recommendation details.

**Solution:** Added a consistent right-click context menu to all AI/ML recommendation components, allowing users to instantly create an action pre-populated with the recommendation's title, description, priority, and client.

**Components Updated:**

| Component | File Location |
|-----------|---------------|
| MeetingRecommendations | `src/components/MeetingRecommendations.tsx` |
| AIRecommendationCards | `src/components/meeting-analytics/AIRecommendationCards.tsx` |
| ProactiveInsightsPanel | `src/components/ProactiveInsightsPanel.tsx` |
| PredictiveHealthInsights | `src/components/PredictiveHealthInsights.tsx` |
| AIInsightsSummary | `src/app/(dashboard)/aging-accounts/compliance/components/AIInsightsSummary.tsx` |

**New Shared Component:**
- `src/components/shared/RecommendationContextMenu.tsx` - Reusable context menu with `useRecommendationContextMenu` hook

**How It Works:**
1. User right-clicks on any AI recommendation
2. Context menu appears with "Create Action" option
3. Clicking opens the Action Slide-Out panel pre-filled with:
   - Title from recommendation
   - Description from recommendation
   - Priority mapped from recommendation severity
   - Client name (if applicable)

---

### 2. ADHI Reference Removed from CLV Page

**Problem:** Parent company (ADHI) was displayed for all clients on the Client Lifetime Value page, which was redundant information.

**Solution:** Removed the parent company display from `BURCClientLifetimeTable.tsx`.

**File:** `src/components/burc/BURCClientLifetimeTable.tsx`

---

### 3. Priority Matrix: Auto-Hide Completed Items

**Problem:** Completed actions remained visible in the Priority Matrix 2x2 view on Command Centre, cluttering the view with finished work.

**Solution:** Added automatic filtering to hide completed items from the Matrix view, consistent with Agenda and List views.

**Files Updated:**
- `src/components/priority-matrix/PriorityMatrix.tsx`
- `src/components/priority-matrix/PriorityMatrixMultiView.tsx`

**Behaviour After Change:**

| View | Completed Items |
|------|-----------------|
| Matrix (2x2) View | Hidden (NEW) |
| Agenda View | Hidden |
| List View | Hidden (toggle available) |
| Kanban View | Moved to "Done" column |

---

## Technical Details

### Context Menu Pattern

Each component follows this pattern:

```typescript
// Imports
import { RecommendationContextMenu, useRecommendationContextMenu, type RecommendationActionContext } from '@/components/shared/RecommendationContextMenu'
import { ActionSlideOutCreate, ActionPriority, type ActionFormData } from '@/components/modern-actions'
import { createAction } from '@/hooks/useActions'
import { toast } from 'sonner'

// Hook usage
const { menuPosition, actionContext, openMenu, closeMenu } = useRecommendationContextMenu()
const [showActionSlideOut, setShowActionSlideOut] = useState(false)
const [actionInitialData, setActionInitialData] = useState<RecommendationActionContext | null>(null)

// Priority conversion helper
const toActionPriority = (priority: RecommendationActionContext['priority']): ActionPriority => {
  switch (priority) {
    case 'critical': return ActionPriority.CRITICAL
    case 'high': return ActionPriority.HIGH
    case 'medium': return ActionPriority.MEDIUM
    case 'low': return ActionPriority.LOW
  }
}

// On recommendation item
onContextMenu={(e) => {
  const context: RecommendationActionContext = {
    title: recommendation.title,
    description: recommendation.description,
    priority: mapPriority(recommendation.priority),
    category: 'AI Recommendation',
    clientName: recommendation.clientName,
  }
  openMenu(e, context)
}}
```

### Completed Items Filter

```typescript
// In filteredItems useMemo
return items.filter(item => {
  // Hide completed items by default
  if (item.tags?.includes('completed')) {
    return false
  }
  // ... other filters
})
```

---

## Testing

1. **Context Menu:** Right-click on any AI recommendation → Menu appears → "Create Action" → Slide-out opens with pre-filled data
2. **CLV Page:** Navigate to Financials → Client Lifetime Value → Verify no parent company shown
3. **Priority Matrix:** Mark an action as complete → Verify it disappears from Matrix view

---

## Related Files

- `src/components/shared/RecommendationContextMenu.tsx` (new)
- `src/components/burc/BURCClientLifetimeTable.tsx`
- `src/components/priority-matrix/PriorityMatrix.tsx`
- `src/components/priority-matrix/PriorityMatrixMultiView.tsx`
- 5 recommendation components listed above
