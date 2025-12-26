# Enhanced UI Components Guide

This guide documents the enhanced UI components available for use throughout the APAC Intelligence v2 dashboard. These components combine multiple advanced libraries (Radix UI, TanStack Virtual, AutoAnimate, Sonner) to provide consistent, polished user experiences.

## Table of Contents

1. [Installation Status](#installation-status)
2. [Data Table](#data-table)
3. [Filter Components](#filter-components)
4. [Confirmation Dialogs](#confirmation-dialogs)
5. [Enhanced Select](#enhanced-select)
6. [Animated Lists](#animated-lists)
7. [Tooltips](#tooltips)
8. [Enhanced Tabs](#enhanced-tabs)
9. [Enhanced Avatars](#enhanced-avatars)
10. [Toast Notifications](#toast-notifications)
11. [Migration Examples](#migration-examples)

---

## Installation Status

All required packages are installed and configured:

- **Radix UI**: DropdownMenu, Tooltip, AlertDialog, Popover, Select, Switch, Avatar, Tabs
- **TanStack Virtual**: Virtual scrolling for large lists/tables
- **AutoAnimate**: Automatic DOM animations
- **Sonner**: Toast notifications

---

## Data Table

Location: `src/components/ui/enhanced/DataTable.tsx`

### Features

- Virtual scrolling for large datasets (1000+ rows)
- Sortable columns with visual indicators
- Row action dropdown menus
- Tooltips for truncated text
- Sticky header
- Loading and empty states
- Customisable row styling

### Usage

```tsx
import { DataTable, type DataTableColumn, type RowAction } from '@/components/ui/enhanced'

interface Client {
  id: string
  name: string
  health_score: number
  cse_name: string
}

const columns: DataTableColumn<Client>[] = [
  {
    key: 'name',
    header: 'Client Name',
    width: 250,
    truncate: true,
    sortable: true,
  },
  {
    key: 'health_score',
    header: 'Health',
    headerTooltip: 'Combined health score from NPS, engagement, and compliance',
    width: 120,
    align: 'right',
    sortable: true,
    cell: (row) => (
      <div className="flex items-center gap-2">
        <span>{row.health_score}</span>
        <div className="w-16 h-2 bg-gray-200 rounded-full">
          <div
            className={`h-full rounded-full ${
              row.health_score >= 75 ? 'bg-green-500' :
              row.health_score >= 50 ? 'bg-yellow-500' : 'bg-red-500'
            }`}
            style={{ width: `${row.health_score}%` }}
          />
        </div>
      </div>
    ),
  },
  {
    key: 'cse_name',
    header: 'CSE',
    width: 180,
  },
]

const rowActions: RowAction<Client>[] = [
  {
    label: 'View Profile',
    icon: <Eye className="h-4 w-4" />,
    onClick: (row) => router.push(`/clients/${row.id}`),
  },
  {
    label: 'Delete',
    icon: <Trash className="h-4 w-4" />,
    destructive: true,
    onClick: (row) => handleDelete(row.id),
    disabled: (row) => row.status === 'protected',
  },
]

<DataTable
  data={clients}
  columns={columns}
  height={600}
  rowHeight={52}
  getRowKey={(row) => row.id}
  onRowClick={(row) => setSelectedClient(row)}
  rowActions={rowActions}
  sortBy={sortBy}
  onSortChange={handleSortChange}
  isLoading={loading}
  emptyMessage="No clients found"
/>
```

---

## Filter Components

Location: `src/components/ui/enhanced/FilterPopover.tsx`

### FilterPopover

Full-featured filter panel with multiple filter types.

```tsx
import { FilterPopover, type FilterGroup } from '@/components/ui/enhanced'

const filterGroups: FilterGroup[] = [
  {
    key: 'status',
    label: 'Status',
    type: 'multiselect',
    options: [
      { value: 'healthy', label: 'Healthy', count: 15 },
      { value: 'at-risk', label: 'At Risk', count: 8 },
      { value: 'critical', label: 'Critical', count: 3 },
    ],
  },
  {
    key: 'cse',
    label: 'CSE Owner',
    type: 'select',
    searchable: true,
    options: cses.map(cse => ({ value: cse.id, label: cse.name })),
  },
  {
    key: 'showArchived',
    label: 'Show Archived',
    type: 'toggle',
  },
]

const [filterValues, setFilterValues] = useState({
  status: [],
  cse: 'all',
  showArchived: false,
})

<FilterPopover
  groups={filterGroups}
  values={filterValues}
  onChange={(key, value) => setFilterValues(prev => ({ ...prev, [key]: value }))}
  onClear={() => setFilterValues({ status: [], cse: 'all', showArchived: false })}
/>
```

### QuickFilter

Horizontal chip-based quick filters.

```tsx
import { QuickFilter } from '@/components/ui/enhanced'
;<QuickFilter
  options={[
    { value: 'all', label: 'All', count: 45 },
    { value: 'overdue', label: 'Overdue', count: 12 },
    { value: 'due-soon', label: 'Due Soon', count: 8 },
    { value: 'completed', label: 'Completed', count: 25 },
  ]}
  value={quickFilter}
  onChange={setQuickFilter}
/>
```

---

## Confirmation Dialogs

Location: `src/components/ui/enhanced/ConfirmDialog.tsx`

### ConfirmDialog Component

```tsx
import { ConfirmDialog } from '@/components/ui/enhanced'
;<ConfirmDialog
  trigger={<button>Delete Action</button>}
  title="Delete this action?"
  description="This will permanently remove the action and all associated data. This cannot be undone."
  variant="destructive" // or 'warning', 'info', 'success'
  confirmLabel="Delete"
  onConfirm={async () => {
    await deleteAction(actionId)
  }}
/>
```

### DeleteConfirmDialog (Pre-configured)

```tsx
import { DeleteConfirmDialog } from '@/components/ui/enhanced'
;<DeleteConfirmDialog
  trigger={
    <button>
      <Trash className="h-4 w-4" />
    </button>
  }
  itemName="Meeting with Barwon Health"
  onConfirm={() => deleteMeeting(meetingId)}
/>
```

### useConfirmDialog Hook (Programmatic)

```tsx
import { useConfirmDialog } from '@/components/ui/enhanced'

function MyComponent() {
  const { confirm, ConfirmDialogComponent } = useConfirmDialog()

  const handleDelete = async () => {
    const confirmed = await confirm({
      title: 'Delete all selected items?',
      description: `${selectedCount} items will be permanently deleted.`,
      variant: 'destructive',
      confirmLabel: 'Delete All',
    })

    if (confirmed) {
      await deleteItems(selectedIds)
    }
  }

  return (
    <>
      <button onClick={handleDelete}>Delete Selected</button>
      <ConfirmDialogComponent />
    </>
  )
}
```

### ConfirmDialogProvider (App-wide)

```tsx
// In layout.tsx
import { ConfirmDialogProvider } from '@/components/ui/enhanced'
;<ConfirmDialogProvider>{children}</ConfirmDialogProvider>

// In any component
import { useConfirm } from '@/components/ui/enhanced'

function MyComponent() {
  const confirm = useConfirm()

  const handleAction = async () => {
    if (await confirm({ title: 'Proceed?', description: 'This will update the record.' })) {
      // proceed
    }
  }
}
```

---

## Enhanced Select

Location: `src/components/ui/enhanced/EnhancedSelect.tsx`

### Basic Select with Search

```tsx
import { EnhancedSelect } from '@/components/ui/enhanced'
;<EnhancedSelect
  value={selectedValue}
  onValueChange={setSelectedValue}
  options={[
    { value: 'option1', label: 'Option 1', description: 'Description text' },
    { value: 'option2', label: 'Option 2' },
  ]}
  placeholder="Select an option..."
  searchable
  includeAll
/>
```

### CSE Select (with Avatars)

```tsx
import { CSESelect } from '@/components/ui/enhanced'
;<CSESelect
  value={selectedCse}
  onValueChange={setSelectedCse}
  cses={cseProfiles}
  placeholder="Select CSE..."
  includeAll
/>
```

### Status Select (with Colours)

```tsx
import { StatusSelect } from '@/components/ui/enhanced'
;<StatusSelect
  value={selectedStatus}
  onValueChange={setSelectedStatus}
  statuses={[
    { value: 'open', label: 'Open', color: '#3b82f6' },
    { value: 'in-progress', label: 'In Progress', color: '#f59e0b' },
    { value: 'completed', label: 'Completed', color: '#22c55e' },
  ]}
/>
```

---

## Animated Lists

Location: `src/components/ui/enhanced/AnimatedList.tsx`

### AnimatedListContainer

```tsx
import { AnimatedListContainer, AnimatedListItem } from '@/components/ui/enhanced'
;<AnimatedListContainer animation="spring">
  {items.map(item => (
    <AnimatedListItem
      key={item.id}
      isSelected={selectedId === item.id}
      onClick={() => setSelectedId(item.id)}
    >
      <ItemCard item={item} />
    </AnimatedListItem>
  ))}
</AnimatedListContainer>
```

### AnimatedGrid

```tsx
import { AnimatedGrid } from '@/components/ui/enhanced'
;<AnimatedGrid columns={3} gap="md" animation="default">
  {cards.map(card => (
    <Card key={card.id} {...card} />
  ))}
</AnimatedGrid>
```

### AnimatedCounter

```tsx
import { AnimatedCounter } from '@/components/ui/enhanced'
;<AnimatedCounter value={totalCount} prefix="$" suffix="k" />
```

### useAnimatedItems Hook

```tsx
import { useAnimatedItems } from '@/components/ui/enhanced'

const {
  items,
  addItem,
  removeItem,
  updateItem,
  moveItem,
  parentRef,
} = useAnimatedItems<Action>(initialActions)

<div ref={parentRef}>
  {items.map(item => (
    <ActionCard
      key={item.id}
      action={item}
      onDelete={() => removeItem(item.id)}
    />
  ))}
</div>
```

---

## Tooltips

Location: `src/components/ui/enhanced/IconTooltip.tsx`

### IconTooltip

```tsx
import { IconTooltip } from '@/components/ui/enhanced'
;<IconTooltip
  content="Health score is calculated from NPS, engagement, and compliance metrics"
  variant="help" // or 'info', 'warning', 'error', 'success'
/>
```

### TooltipButton

```tsx
import { TooltipButton } from '@/components/ui/enhanced'
;<TooltipButton tooltip="Refresh data" onClick={handleRefresh}>
  <RefreshCw className="h-4 w-4" />
</TooltipButton>
```

### TooltipBadge

```tsx
import { TooltipBadge } from '@/components/ui/enhanced'
;<TooltipBadge label="Overdue" tooltip="This action is 5 days past due" variant="error" />
```

### TruncatedText

```tsx
import { TruncatedText } from '@/components/ui/enhanced'
;<TruncatedText text={longDescription} maxLength={50} />
```

### MetricTooltip

```tsx
import { MetricTooltip } from '@/components/ui/enhanced'
;<MetricTooltip
  value={85}
  label="Health Score"
  explanation="Combined metric from NPS (40%), engagement (30%), actions (20%), recency (10%)"
  trend="up"
/>
```

---

## Enhanced Tabs

Location: `src/components/ui/enhanced/EnhancedTabs.tsx`

### EnhancedTabs with Keyboard Shortcuts

```tsx
import { EnhancedTabs, TabPanel } from '@/components/ui/enhanced'

const tabs = [
  { value: 'overview', label: 'Overview', icon: <LayoutGrid className="h-4 w-4" /> },
  { value: 'actions', label: 'Actions', badge: 12, badgeVariant: 'warning' },
  { value: 'meetings', label: 'Meetings', badge: 3 },
  { value: 'nps', label: 'NPS', disabled: true, tooltip: 'No NPS data available' },
]

<EnhancedTabs
  tabs={tabs}
  value={activeTab}
  onValueChange={setActiveTab}
  variant="underline" // or 'default', 'pills'
  enableKeyboardShortcuts // Alt+1, Alt+2, etc.
>
  <TabPanel value="overview"><OverviewContent /></TabPanel>
  <TabPanel value="actions"><ActionsContent /></TabPanel>
  <TabPanel value="meetings"><MeetingsContent /></TabPanel>
</EnhancedTabs>
```

### PageTabs

Full-width page-level tabs for section navigation.

```tsx
import { PageTabs } from '@/components/ui/enhanced'
;<PageTabs
  tabs={[
    { value: 'all', label: 'All Clients', badge: 45 },
    { value: 'critical', label: 'Critical', badge: 3, badgeVariant: 'error' },
    { value: 'at-risk', label: 'At Risk', badge: 8, badgeVariant: 'warning' },
  ]}
  value={viewMode}
  onValueChange={setViewMode}
/>
```

---

## Enhanced Avatars

Location: `src/components/ui/enhanced/EnhancedAvatar.tsx`

### EnhancedAvatar

```tsx
import { EnhancedAvatar } from '@/components/ui/enhanced'
;<EnhancedAvatar
  src={user.photoUrl}
  name={user.name}
  size="md" // 'xs', 'sm', 'md', 'lg', 'xl'
  status="online" // 'online', 'offline', 'busy', 'away', 'none'
  showTooltip
  role="Client Success Engineer"
/>
```

### AvatarGroup

```tsx
import { AvatarGroup } from '@/components/ui/enhanced'
;<AvatarGroup
  users={teamMembers.map(m => ({
    id: m.id,
    name: m.name,
    src: m.photoUrl,
    role: m.role,
  }))}
  max={4}
  size="sm"
  showTooltip
  onOverflowClick={() => setShowTeamModal(true)}
/>
```

### UserCard

```tsx
import { UserCard } from '@/components/ui/enhanced'
;<UserCard
  user={{
    name: 'Jane Smith',
    src: '/avatars/jane.jpg',
    email: 'jane@example.com',
    role: 'Senior CSE',
  }}
  status="online"
  showEmail
  showRole
  onClick={() => openUserProfile(user.id)}
/>
```

---

## Toast Notifications

Already configured in the layout. Use the `toast` function from Sonner.

```tsx
import { toast } from 'sonner'

// Success
toast.success('Action completed successfully')

// Error
toast.error('Failed to save changes')

// Warning
toast.warning('This action may take a while')

// Info
toast.info('New updates available')

// Loading with Promise
toast.promise(saveData(), {
  loading: 'Saving...',
  success: 'Changes saved!',
  error: 'Failed to save',
})

// Custom with action
toast('Meeting reminder', {
  description: 'Your meeting with Barwon Health starts in 15 minutes',
  action: {
    label: 'Join',
    onClick: () => window.open(meetingUrl),
  },
})
```

---

## Migration Examples

### Replace Native Select

**Before:**

```tsx
<select
  value={selectedCse}
  onChange={e => setSelectedCse(e.target.value)}
  className="border rounded-lg px-3 py-2"
>
  <option value="">All CSEs</option>
  {cses.map(cse => (
    <option key={cse.id} value={cse.id}>
      {cse.name}
    </option>
  ))}
</select>
```

**After:**

```tsx
import { CSESelect } from '@/components/ui/enhanced'
;<CSESelect value={selectedCse} onValueChange={setSelectedCse} cses={cses} includeAll />
```

### Replace window.confirm

**Before:**

```tsx
const handleDelete = () => {
  if (window.confirm('Are you sure you want to delete this?')) {
    deleteItem()
  }
}

;<button onClick={handleDelete}>Delete</button>
```

**After:**

```tsx
import { DeleteConfirmDialog } from '@/components/ui/enhanced'
;<DeleteConfirmDialog
  trigger={<button>Delete</button>}
  itemName={item.name}
  onConfirm={deleteItem}
/>
```

### Replace alert() with Toast

**Before:**

```tsx
try {
  await saveData()
  alert('Saved successfully!')
} catch (err) {
  alert('Error: ' + err.message)
}
```

**After:**

```tsx
import { toast } from 'sonner'

toast.promise(saveData(), {
  loading: 'Saving...',
  success: 'Saved successfully!',
  error: err => `Error: ${err.message}`,
})
```

### Add Tooltips to Icon Buttons

**Before:**

```tsx
<button onClick={handleRefresh} title="Refresh data">
  <RefreshCw className="h-4 w-4" />
</button>
```

**After:**

```tsx
import { TooltipButton } from '@/components/ui/enhanced'
;<TooltipButton tooltip="Refresh data" onClick={handleRefresh}>
  <RefreshCw className="h-4 w-4" />
</TooltipButton>
```

---

## Component Index

All enhanced components can be imported from `@/components/ui/enhanced`:

```tsx
import {
  // Data Display
  DataTable,

  // Filters
  FilterPopover,
  FilterButton,
  QuickFilter,

  // Dialogs
  ConfirmDialog,
  DeleteConfirmDialog,
  useConfirmDialog,
  ConfirmDialogProvider,
  useConfirm,

  // Selects
  EnhancedSelect,
  CSESelect,
  StatusSelect,

  // Animated Lists
  AnimatedListContainer,
  AnimatedListItem,
  AnimatedGrid,
  AnimatedTableBody,
  AnimatedCounter,
  useAnimatedItems,

  // Tooltips
  IconTooltip,
  TooltipButton,
  TooltipBadge,
  TruncatedText,
  MetricTooltip,

  // Tabs
  EnhancedTabs,
  TabPanel,
  PageTabs,

  // Avatars
  EnhancedAvatar,
  AvatarGroup,
  UserCard,
} from '@/components/ui/enhanced'
```

---

## Best Practices

1. **Use EnhancedSelect** instead of native `<select>` for consistent styling and better UX
2. **Replace window.confirm** with ConfirmDialog for proper modal confirmations
3. **Use toast notifications** instead of alert() for non-blocking feedback
4. **Add TooltipButton** to all icon-only buttons for accessibility
5. **Use DataTable** for any list with more than 50 rows for performance
6. **Wrap dynamic lists** with AnimatedListContainer for smooth transitions
7. **Use AvatarGroup** when displaying multiple team members
8. **Enable keyboard shortcuts** on tabs where appropriate (Alt+1, Alt+2, etc.)
