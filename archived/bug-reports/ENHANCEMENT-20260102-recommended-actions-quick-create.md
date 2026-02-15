# Enhancement: Right-Click Quick Actions for Recommended Actions

**Date:** 2026-01-02
**Status:** Implemented
**Severity:** Low (Enhancement)
**Component:** Client Profile V2 - RightColumn, ActionSlideOutCreate

## User Request

> "Add right-click quick actions to Recommend Actions that open deeplinks to action creation. Auto-populate all relevant and available data."

## Implementation

Added right-click context menu functionality to the Recommended Actions card that allows users to quickly create actions with pre-populated data based on the recommendation type.

### Features Added

1. **Right-Click Context Menu**
   - Each recommendation item now responds to right-click
   - Displays a floating context menu at cursor position
   - Single option: "Create Action" with auto-fill indicator

2. **Auto-Population of Action Data**
   - Title: Contextual title based on recommendation type
   - Description: Detailed context with relevant data
   - Priority: Mapped from recommendation severity
   - Category: Based on recommendation domain (Compliance, Client Health, etc.)

3. **ActionSlideOutCreate Enhancement**
   - Added `initialData` prop for pre-filling form fields
   - Updated `getSmartDefaults` function to use initial data when provided
   - Form automatically populates with context when opened from recommendation

### Action Context Mapping

Each recommendation type now includes `actionContext` data:

| Recommendation Type | Priority | Category |
|---------------------|----------|----------|
| AI Compliance Recommendations | CRITICAL/HIGH/MEDIUM | Compliance |
| Critical Health Score | CRITICAL | Client Health |
| Poor NPS Score | HIGH | Client Health |
| No Recent Meetings | MEDIUM | Client Engagement |
| At-Risk Compliance Events | MEDIUM | Compliance |
| Critical Compliance (<50%) | CRITICAL | Compliance |
| Working Capital Issues | HIGH | Financials |
| Overdue Actions | CRITICAL | Follow-up |
| Portfolio Initiatives | HIGH | Portfolio |
| Upcoming Events | LOW | Compliance |

## Files Modified

### `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`

- Added imports: `Plus` icon, `ActionSlideOutCreate`, `createAction`, `ActionPriority`, `toast`, `addDays`
- Added state variables:
  - `contextMenu`: Tracks menu position and action context
  - `showActionCreate`: Controls slide-out visibility
  - `actionCreateContext`: Stores context for form pre-population
- Extended `ActionItem` type to include `actionContext` object
- Added `onContextMenu` handler to each recommendation button
- Added portal-rendered context menu with "Create Action" option
- Added `ActionSlideOutCreate` component with `initialData` prop
- Fixed property names: `event_type_name` for EventTypeCompliance, `event_type_id` for SegmentationEvent
- Fixed createAction call: `owners` (array), `category` (singular)

### `src/components/modern-actions/ActionSlideOutCreate.tsx`

- Added `initialData` prop to interface:
  ```typescript
  initialData?: {
    title?: string
    description?: string
    priority?: ActionPriority
    category?: string
  }
  ```
- Updated component to destructure `initialData` prop
- Modified `useEffect` to pass `initialData` to `getSmartDefaults`
- Updated `getSmartDefaults` function to use initial data when provided

## Code Examples

### Context Menu State
```typescript
const [contextMenu, setContextMenu] = useState<{
  x: number
  y: number
  actionContext: {
    title: string
    description: string
    priority: ActionPriority
    category: string
  }
} | null>(null)
```

### Action Item with Context
```typescript
{
  icon: AlertTriangle,
  text: "Critical health score (<40)",
  severity: 'critical',
  color: 'text-red-700',
  bgColor: 'bg-red-50',
  borderColor: 'border-red-200',
  actionContext: {
    title: `Urgent: Address critical health for ${client.name}`,
    description: `Health score is ${client.health_score}/100...`,
    priority: ActionPriority.CRITICAL,
    category: 'Client Health',
  },
  onClick: () => {},
}
```

### Context Menu Handler
```typescript
onContextMenu={(e) => {
  e.preventDefault()
  setContextMenu({
    x: e.clientX,
    y: e.clientY,
    actionContext: item.actionContext,
  })
}}
```

## Testing Verification

1. **TypeScript compilation**: Passes
2. **Right-click functionality**: Context menu appears at cursor position
3. **Form pre-population**: Action slide-out opens with correct data
4. **Action creation**: Successfully creates action with populated data
5. **Actions refresh**: List refreshes after creation

## UX Improvements

1. **Reduced friction**: One right-click to create action from recommendation
2. **Context preservation**: All relevant data auto-populates
3. **Smart defaults**: Priority and category automatically set
4. **Visual feedback**: Toast notification on successful creation

## Related Documentation

- `docs/bug-reports/ENHANCEMENT-20260102-consolidated-recommended-actions.md` - Consolidated recommendations into single card
- `docs/bug-reports/ENHANCEMENT-20260102-working-capital-navigation.md` - Working Capital navigation button
