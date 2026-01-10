# Stakeholder Map Redesign - Drag-and-Drop Org Chart

**Date:** 2026-01-10
**Type:** Enhancement
**Status:** Resolved
**Priority:** Medium

---

## Feature Description

Redesigned the stakeholder mapping interface in the Account Plan wizard from a form-based list to an interactive drag-and-drop org chart visualisation using React Flow.

## Previous Implementation

- Simple form-based list of stakeholders
- Each stakeholder displayed as an expandable card with form fields
- No visual representation of hierarchy or relationships
- Manual ordering only

## New Implementation

### Technology Stack
- **@xyflow/react** (React Flow v12) - Node-based interactive canvas
- Custom StakeholderNode component with role-based styling
- Auto-layout algorithm for hierarchical organisation

### Features

1. **Visual Org Chart Canvas**
   - Stakeholders displayed as draggable cards on a canvas
   - Pan, zoom, and minimap navigation
   - Grid snap for alignment (20px)

2. **Role-Based Styling**
   | Role | Colour | Icon |
   |------|--------|------|
   | Decision Maker | Purple | Crown |
   | Champion | Green | Trophy |
   | Influencer | Blue | Lightbulb |
   | End User | Grey | User |
   | Blocker | Red | AlertTriangle |

3. **Relationship Strength Indicator**
   - Visual dots (1-5) showing relationship strength
   - Strong = Green, Neutral = Amber, Weak = Red

4. **Stakeholder Cards Display**
   - Name and title
   - Role badge with colour coding
   - Relationship strength dots
   - Last contact date (relative)
   - Email/phone links on selection

5. **Interactions**
   - **Click card**: Opens edit modal
   - **Drag card**: Repositions on canvas
   - **Connection handles**: Link stakeholders (relationships)
   - **Add button**: Opens add modal
   - **Layout button**: Auto-arrange by role hierarchy

6. **Auto-Layout**
   - Organises stakeholders in rows by role
   - Decision Makers at top, Blockers at bottom
   - Horizontally centred within each row

## Files Created

| File | Description |
|------|-------------|
| `src/components/planning/stakeholder-map/StakeholderNode.tsx` | Custom node component with role styling |
| `src/components/planning/stakeholder-map/StakeholderMapCanvas.tsx` | Main canvas with React Flow integration |
| `src/components/planning/stakeholder-map/index.ts` | Component exports |

## Files Modified

| File | Changes |
|------|---------|
| `src/app/(dashboard)/planning/account/new/page.tsx` | Replaced form-based stakeholder step with StakeholderMapCanvas |
| `package.json` | Added @xyflow/react dependency |

## Component Architecture

```
src/components/planning/stakeholder-map/
├── index.ts                    # Exports
├── StakeholderNode.tsx         # Custom node (role badges, relationship dots)
└── StakeholderMapCanvas.tsx    # React Flow canvas, toolbar, modal, layout
```

## Key Code Patterns

### Custom Node Type
```typescript
const nodeTypes = {
  stakeholder: StakeholderNode,
} as NodeTypes
```

### Auto-Layout Algorithm
```typescript
function autoLayout(nodes: Node[]): Node[] {
  const roleOrder = ['economic_buyer', 'champion', 'influencer', 'user', 'blocker']
  // Groups nodes by role and positions in horizontal rows
}
```

### Position Persistence
- Node positions saved to stakeholder data on drag end
- Positions restored when loading existing plans

## Testing Checklist

- [x] Build passes without TypeScript errors
- [x] Stakeholder cards display with correct role colours
- [x] Drag and drop repositioning works
- [x] Click to edit stakeholder opens modal
- [x] Add stakeholder creates new node
- [x] Delete stakeholder removes node
- [x] Auto-layout organises by role hierarchy
- [x] Relationship strength dots display correctly
- [x] Minimap shows node colours by role
- [x] Canvas controls (zoom, pan) work
- [x] Position data persists on save

## Dependencies Added

```json
{
  "@xyflow/react": "^12.0.0"
}
```

## Usage

Navigate to Account Plan → Stakeholder Map step:
1. Click "Add Stakeholder" to add contacts
2. Drag cards to arrange visually
3. Click "Layout" → "Auto-arrange by role" for automatic hierarchy
4. Click any card to edit details
5. Drag from connection handles to create relationship lines
6. Click the fullscreen icon (⛶) for expanded view

---

## Additional Updates (Session 2)

### Canvas Size Increased
- Default height increased from 500px to 650px for better visibility

### Fullscreen Mode Added
- Fullscreen toggle button added to toolbar (Maximize2/Minimize2 icons)
- Fullscreen expands canvas to fill viewport with dark backdrop
- Click backdrop or minimize icon to exit fullscreen
- Smooth transition animation (300ms)

### AI Planning Coach Renamed
- "AI Planning Coach" renamed to "Account Planning Coach" across:
  - `src/app/(dashboard)/planning/page.tsx`
  - `src/app/(dashboard)/planning/territory/new/page.tsx`

---

## Related Documentation

- [React Flow Documentation](https://reactflow.dev/)
- `src/hooks/useMEDDPICC.ts` - Related MEDDPICC scoring
- `docs/bug-reports/BUG-REPORT-20260110-meddpicc-guide-questions-and-nba-generation.md` - Recent MEDDPICC updates
