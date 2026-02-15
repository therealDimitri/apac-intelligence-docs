# Feature: CSI Recommendation Context Menu & Action Modal Integration

**Date:** 30 December 2025
**Type:** Enhancement
**Status:** Implemented

## Summary

Added right-click context menu functionality to CSI Recommended Actions and changed the "+ Create Action Item" button to open a pre-filled action modal instead of navigating to a separate page.

## Features Implemented

### 1. Context Menu on Recommendations

Right-click (or click the "more" button) on any recommendation card to access:

- **Create Action Item** - Opens the action modal with pre-filled data
- **Assign to Team Member** - (Coming soon) Opens team assignment
- **Schedule Review** - (Coming soon) Opens scheduling interface
- **Copy to Clipboard** - Copies the recommendation as formatted text

### 2. Pre-filled Action Modal

When creating an action from a recommendation, the modal pre-fills:

| Field | Source |
|-------|--------|
| Title | Recommendation title |
| Description | Recommendation description + action steps + expected impact |
| Priority | Maps P1→Critical, P2→High, P3→Medium |
| Categories | Pre-set to "Financial", "CSI" |
| Due Date | Calculated from timeframe (immediate=+7d, 30days=+30d, etc.) |

### 3. "More Options" Button

Each recommendation card now has a ⋯ (more) button in the header that triggers the context menu on click, as an alternative to right-clicking.

## Technical Implementation

### Files Modified

| File | Changes |
|------|---------|
| `src/components/CreateActionModal.tsx` | Added `InitialActionData` interface and `initialData` prop |
| `src/components/csi/ActionRecommendationsPanel.tsx` | Added context menu, modal integration, removed router navigation |

### New Types

```typescript
// In CreateActionModal.tsx
export interface InitialActionData {
  title?: string
  description?: string
  priority?: 'critical' | 'high' | 'medium' | 'low'
  categories?: string[]
  client?: string
  dueDate?: string
}

// In ActionRecommendationsPanel.tsx
interface ContextMenuState {
  isOpen: boolean
  position: { x: number; y: number }
  recommendation: ActionRecommendation | null
}
```

### Key Functions

```typescript
// Convert recommendation to initial action data
const getInitialActionData = (recommendation: ActionRecommendation): InitialActionData => {
  // Calculate due date based on timeframe
  const today = new Date()
  let dueDate: string

  switch (recommendation.timeframe) {
    case 'immediate':
      dueDate = new Date(today.setDate(today.getDate() + 7)).toISOString().split('T')[0]
      break
    case '30days':
      dueDate = new Date(today.setDate(today.getDate() + 30)).toISOString().split('T')[0]
      break
    // ... etc
  }

  return {
    title: recommendation.title,
    description: `${recommendation.description}\n\nAction Steps:\n${recommendation.steps.map((s, i) => `${i + 1}. ${s}`).join('\n')}\n\nExpected Impact: ${recommendation.expectedImpact}`,
    priority: recommendation.priority === 1 ? 'critical' : recommendation.priority === 2 ? 'high' : 'medium',
    categories: ['Financial', 'CSI'],
    dueDate,
  }
}
```

## User Experience

### Before
- Clicking "+ Create Action Item" navigated to `/actions?new=true&...` with query params
- No context menu options
- No quick access to additional actions

### After
- Clicking "+ Create Action Item" opens a modal overlay with pre-filled data
- Right-click opens context menu with multiple actions
- ⋯ button provides same context menu for non-right-click users
- User stays on the same page throughout the workflow

## Testing

1. Navigate to BURC Financials > CSI Ratios > Actions tab
2. Expand any recommendation card
3. Test "+ Create Action Item" button:
   - Should open modal with pre-filled title, description, priority, categories, due date
4. Test right-click on recommendation card:
   - Should show context menu with 4 options
5. Test ⋯ more button:
   - Should show same context menu
6. Test "Copy to Clipboard":
   - Should copy formatted text with all recommendation details
