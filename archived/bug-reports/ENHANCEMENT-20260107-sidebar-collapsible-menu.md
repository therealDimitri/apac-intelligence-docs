# Enhancement: Sidebar Collapsible Menu with Child Pages

**Date**: 7 January 2026
**Status**: Completed
**Severity**: Enhancement
**Component**: Navigation / Sidebar

## Overview

Restructured the main navigation sidebar from a flat list to a grouped, collapsible menu structure. This improves organisation and allows users to quickly navigate to related pages while keeping the sidebar clean and focused.

## Changes Made

### Desktop Sidebar (`src/components/layout/sidebar.tsx`)

1. **New Navigation Structure**:
   - Standalone items: Command Centre (home)
   - Grouped navigation with 5 collapsible sections

2. **Navigation Groups**:
   | Group | Icon | Child Pages |
   |-------|------|-------------|
   | Clients | Users | Client Profiles, Priority Matrix |
   | Engagement | Handshake | Briefing Room, Actions & Tasks, Segmentation Events |
   | Analytics | LineChart | NPS Analytics, Team Performance |
   | Financials | Wallet | BURC Performance, Working Capital |
   | Resources | Cog | Guides & Templates, Settings |

3. **Features**:
   - Click group header to expand/collapse children
   - Chevron rotates to indicate expanded state
   - Active child pages highlighted with emerald dot indicator
   - Group header highlights when any child is active
   - Expansion state persists to localStorage
   - Smooth CSS transitions for collapse animation
   - Border-left visual connector for child items

### Mobile Drawer (`src/components/layout/MobileDrawer.tsx`)

1. **Same grouped structure** as desktop for consistency
2. **Featured ChaSen AI** button with gradient styling
3. **Touch-optimised** with 44-48px minimum hit targets
4. **Collapsible groups** with ChevronDown indicator

## UI/UX Design

### Visual Hierarchy
```
Command Centre (standalone)
ChaSen AI (featured with gradient)
─────────────────────────────
▼ Clients
  │ Client Profiles
  │ Priority Matrix
▼ Engagement
  │ Briefing Room
  │ Actions & Tasks    ●
  │ Segmentation Events
▼ Analytics
  │ NPS Analytics
  │ Team Performance
▼ Financials
  │ BURC Performance
  │ Working Capital
▼ Resources
  │ Guides & Templates
  │ Settings
```

### Interaction Patterns
- **Click group header**: Toggle expand/collapse
- **Click child item**: Navigate to page
- **Active state**: White background + emerald dot indicator
- **Group active state**: Subtle background when any child is active
- **Persistence**: Expanded groups saved to localStorage

## Technical Implementation

### State Management
```typescript
// Expanded groups state with localStorage persistence
const [expandedGroups, setExpandedGroups] = useState<Set<string>>(() => {
  return new Set(navigationGroups.map(g => g.name))
})

useEffect(() => {
  const saved = localStorage.getItem('sidebar-expanded-groups')
  if (saved) {
    setExpandedGroups(new Set(JSON.parse(saved)))
  }
}, [])
```

### Active Detection
```typescript
const isGroupActive = (group: NavigationGroup) => {
  return group.children.some(child =>
    pathname === child.href || pathname.startsWith(child.href + '/')
  )
}
```

### Animation
```css
.overflow-hidden.transition-all.duration-200.ease-in-out {
  max-height: 0;
  opacity: 0;
}
.expanded {
  max-height: 384px; /* max-h-96 */
  opacity: 1;
}
```

## Files Modified

1. `src/components/layout/sidebar.tsx` - Desktop sidebar with collapsible groups
2. `src/components/layout/MobileDrawer.tsx` - Mobile drawer with matching structure

## Testing

1. Navigate to Command Centre - standalone item should highlight
2. Click "Clients" group header - should toggle children visibility
3. Click "Client Profiles" - should navigate and show active indicator
4. Refresh page - expanded state should persist
5. On mobile, open drawer and verify same grouping structure
6. Verify keyboard navigation works (Tab, Enter, Escape)

## Benefits

1. **Reduced Visual Clutter**: 10 top-level items reduced to 6 (1 standalone + 5 groups)
2. **Logical Grouping**: Related pages grouped together
3. **User Control**: Collapse unused groups to focus on relevant sections
4. **Consistency**: Desktop and mobile use same structure
5. **Discoverability**: Child pages visible at a glance when group is expanded
6. **Persistence**: User preferences remembered across sessions

## Future Enhancements

1. Add keyboard shortcuts for quick navigation (e.g., `g c` for Clients)
2. Add "Collapse All" / "Expand All" buttons
3. Add drag-and-drop to reorder groups
4. Add user-configurable pinned items
