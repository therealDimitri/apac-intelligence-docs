# Enhanced UI Components Implementation Plan

This document outlines the phased approach for transitioning the APAC Intelligence v2 dashboard to use the new enhanced UI component library.

---

## Phase 1: Low-Risk Quick Wins (Immediate)

**Estimated effort: 1-2 days**

These changes can be made immediately with minimal risk as they don't affect core functionality.

### 1.1 Replace window.confirm() with ConfirmDialog

**Files to update:**

- `src/app/(dashboard)/actions/page.tsx` - Delete action confirmations
- `src/app/(dashboard)/meetings/page.tsx` - Delete meeting confirmations
- `src/components/ActionDetailModal.tsx` - Status change confirmations
- `src/components/EditActionModal.tsx` - Cancel edit confirmations

**Pattern:**

```tsx
// Before
if (window.confirm('Delete this action?')) { ... }

// After
<DeleteConfirmDialog
  trigger={<button>Delete</button>}
  itemName={action.title}
  onConfirm={() => deleteAction(action.id)}
/>
```

### 1.2 Replace alert() with Toast Notifications

**Files to update:**

- `src/app/(dashboard)/actions/page.tsx`
- `src/app/(dashboard)/meetings/page.tsx`
- `src/app/(dashboard)/aging-accounts/page.tsx`
- `src/components/CreateActionModal.tsx`
- `src/components/EditActionModal.tsx`

**Pattern:**

```tsx
// Before
alert('Saved successfully!')

// After
import { toast } from 'sonner'
toast.success('Saved successfully!')
```

### 1.3 Add Tooltips to Icon Buttons

**Files to update:**

- `src/components/ActionDetailModal.tsx` - Edit, delete, close buttons
- `src/components/ActionItemRow.tsx` - Quick action buttons
- `src/app/(dashboard)/layout.tsx` - Sidebar navigation icons

**Pattern:**

```tsx
// Before
<button title="Refresh"><RefreshCw /></button>

// After
<TooltipButton tooltip="Refresh data" onClick={handleRefresh}>
  <RefreshCw className="h-4 w-4" />
</TooltipButton>
```

---

## Phase 2: Component Standardisation (Week 1-2)

**Estimated effort: 3-5 days**

### 2.1 Replace Native Selects with EnhancedSelect

**Priority files:**

1. `src/app/(dashboard)/actions/page.tsx` - CSE filter, status filter, priority filter
2. `src/app/(dashboard)/meetings/page.tsx` - CSE filter
3. `src/app/(dashboard)/aging-accounts/page.tsx` - Department filter, CSE filter
4. `src/app/(dashboard)/nps/page.tsx` - CSE filter, date range

**Implementation:**

```tsx
// CSE dropdowns → CSESelect
<CSESelect
  value={selectedCse}
  onValueChange={setSelectedCse}
  cses={cseProfiles}
  includeAll
/>

// Status dropdowns → StatusSelect
<StatusSelect
  value={statusFilter}
  onValueChange={setStatusFilter}
  statuses={statusOptions}
/>
```

### 2.2 Implement FilterPopover for Complex Filtering

**Target pages:**

1. `src/app/(dashboard)/actions/page.tsx` - Replace filter row with FilterPopover
2. `src/app/(dashboard)/client-profiles/page.tsx` - Multi-criteria filtering

**Benefits:**

- Cleaner header design
- More filter options without clutter
- Active filter count badge
- Mobile-friendly collapsible filters

### 2.3 Add QuickFilter Chips

**Target pages:**

1. `src/app/(dashboard)/actions/page.tsx` - Status quick filters (All, Overdue, In Progress)
2. `src/app/(dashboard)/meetings/page.tsx` - Time period filters (This Week, This Month)

---

## Phase 3: Enhanced Data Display (Week 2-3)

**Estimated effort: 4-6 days**

### 3.1 Implement DataTable for Large Lists

**Priority pages:**

1. `src/app/(dashboard)/nps/page.tsx` - NPS responses table (potential 1000+ rows)
2. `src/app/(dashboard)/aging-accounts/page.tsx` - Accounts table with many columns
3. `src/app/(dashboard)/client-profiles/page.tsx` - Client list

**Implementation approach:**

```tsx
import { DataTable } from '@/components/ui/enhanced'

const columns = [
  { key: 'client_name', header: 'Client', width: 200, truncate: true, sortable: true },
  { key: 'nps_score', header: 'NPS', width: 80, align: 'right', sortable: true },
  // ...
]

const rowActions = [
  { label: 'View Details', onClick: (row) => openDetail(row.id) },
  { label: 'Export', onClick: (row) => exportRow(row.id) },
]

<DataTable
  data={responses}
  columns={columns}
  height={600}
  getRowKey={(row) => row.id}
  onRowClick={handleRowClick}
  rowActions={rowActions}
  sortBy={sortBy}
  onSortChange={handleSort}
  isLoading={loading}
/>
```

### 3.2 Add AnimatedListContainer to Dynamic Lists

**Target components:**

1. `src/components/KanbanBoard.tsx` - Animate card movements
2. `src/app/(dashboard)/actions/page.tsx` - Action list animations
3. `src/app/(dashboard)/ai/page.tsx` - Chat message animations

**Implementation:**

```tsx
<AnimatedListContainer animation="spring">
  {actions.map(action => (
    <AnimatedListItem key={action.id}>
      <ActionCard action={action} />
    </AnimatedListItem>
  ))}
</AnimatedListContainer>
```

---

## Phase 4: Enhanced User Experience (Week 3-4)

**Estimated effort: 3-4 days**

### 4.1 Implement EnhancedTabs with Keyboard Shortcuts

**Target pages:**

1. `src/app/(dashboard)/clients/[clientId]/v2/page.tsx` - Client profile tabs
2. `src/app/(dashboard)/aging-accounts/compliance/page.tsx` - Dashboard tabs
3. `src/app/(dashboard)/nps/page.tsx` - Analysis tabs

**Benefits:**

- Alt+1, Alt+2 keyboard navigation
- Tab badges showing counts
- Visual indicators for active state

### 4.2 Add EnhancedAvatar and AvatarGroup

**Target areas:**

1. CSE displays throughout the application
2. Team member lists in meeting details
3. Assignment displays in actions

**Implementation:**

```tsx
// Single CSE display
<EnhancedAvatar
  src={cse.photoUrl}
  name={cse.name}
  status="online"
  showTooltip
  role={cse.title}
/>

// Multiple assignees
<AvatarGroup
  users={assignees}
  max={3}
  onOverflowClick={() => setShowAllAssignees(true)}
/>
```

### 4.3 Add MetricTooltip to KPIs

**Target components:**

1. Client health score displays
2. NPS score indicators
3. Compliance percentages
4. Dashboard stat cards

---

## Phase 5: Testing and Refinement (Ongoing)

### 5.1 Accessibility Testing

- Verify keyboard navigation works correctly
- Test with screen readers
- Ensure proper ARIA labels

### 5.2 Performance Testing

- Measure render times with DataTable on large datasets
- Verify animations don't cause frame drops
- Test on mobile devices

### 5.3 User Feedback

- Collect feedback on new interactions
- Adjust animation speeds if needed
- Fine-tune tooltip delays

---

## Implementation Checklist

### Phase 1 Checklist

- [ ] Replace all `window.confirm()` calls with `ConfirmDialog`
- [ ] Replace all `alert()` calls with `toast` notifications
- [ ] Add `TooltipButton` to all icon-only buttons
- [ ] Test all replaced functionality
- [ ] Update any unit tests affected

### Phase 2 Checklist

- [ ] Migrate CSE dropdowns to `CSESelect`
- [ ] Migrate status dropdowns to `StatusSelect`
- [ ] Implement `FilterPopover` on actions page
- [ ] Add `QuickFilter` chips where appropriate
- [ ] Verify filter functionality matches previous behaviour

### Phase 3 Checklist

- [ ] Implement `DataTable` on NPS page
- [ ] Implement `DataTable` on aging accounts page
- [ ] Add `AnimatedListContainer` to Kanban board
- [ ] Test performance with large datasets
- [ ] Ensure sort and filter functionality works

### Phase 4 Checklist

- [ ] Migrate tabs to `EnhancedTabs`
- [ ] Implement `AvatarGroup` for team displays
- [ ] Add `MetricTooltip` to dashboard KPIs
- [ ] Test keyboard shortcuts
- [ ] Verify mobile responsiveness

---

## Risk Mitigation

### Low Risk

- Toast notifications (additive, no replacement of UI elements)
- Tooltips (enhances existing buttons)
- AnimatedListContainer (wraps existing content)

### Medium Risk

- Select replacements (must maintain same value handling)
- ConfirmDialog (async behaviour differs from window.confirm)
- FilterPopover (consolidating multiple UI elements)

### Higher Risk

- DataTable migration (complete table replacement)
- Tab migration (affects routing and state management)

### Rollback Strategy

Each phase should be:

1. Implemented on a feature branch
2. Tested thoroughly before merge
3. Deployed incrementally with monitoring
4. Feature-flagged if needed for A/B testing

---

## Estimated Timeline

| Phase   | Duration | Dependencies     |
| ------- | -------- | ---------------- |
| Phase 1 | 1-2 days | None             |
| Phase 2 | 3-5 days | Phase 1 complete |
| Phase 3 | 4-6 days | Phase 2 complete |
| Phase 4 | 3-4 days | Phase 3 complete |
| Phase 5 | Ongoing  | All phases       |

**Total estimated effort: 11-17 days**

---

## Success Metrics

1. **User Experience**
   - Reduced time to complete common tasks
   - Improved user satisfaction scores
   - Fewer support tickets about UI confusion

2. **Performance**
   - Page load times maintained or improved
   - Smooth 60fps animations
   - Reduced bundle size through tree-shaking

3. **Developer Experience**
   - Faster implementation of new features
   - Consistent component patterns
   - Reduced custom CSS

4. **Accessibility**
   - WCAG 2.1 AA compliance
   - Full keyboard navigation
   - Screen reader compatibility
