# UX Coherence 10/10 Design

> Date: 15 February 2026
> Status: Approved
> Current score: ~8.5/10 → Target: 10/10

## Audit Summary

| Area | Score | Key Gap |
|------|-------|---------|
| Empty States | 6.5 | No shared component — every page rolls its own |
| Spacing/Layout | 7.0 | Card padding varies (p-3 to p-5), modal padding inconsistent |
| Component Patterns | 7.5 | LayoutTokens.card unused, hand-rolled tables |
| Status Badges | 7.5 | 8+ duplicated getStatusColor() functions, no StatusBadge component |
| Typography | 8.0 | 20+ components hardcode heading sizes instead of TypographyClasses |
| Buttons | 8.0 | 15+ custom button components bypass shared Button |
| Design Tokens | 8.5 | Sidebars have 40+ hardcoded colour classes |
| Forms | 8.5 | FormRenderer underused; input border-radius/focus inconsistent |
| Colour Usage | 8.5 | Solid red/amber/green system, but financial chart colours hardcoded |
| Loading States | 9.0 | Already excellent — all pages use shared skeletons |

## Phase 1: New Shared Components

### 1a. StatusBadge (`src/components/ui/StatusBadge.tsx`)

Replaces 50+ inline badge implementations. Wraps existing BadgeStyles tokens with colour-aware variants.

**API:**
```tsx
<StatusBadge status="critical" />           // red pill
<StatusBadge status="In Progress" />        // blue pill (normalised)
<StatusBadge priority="high" />             // orange pill
<StatusBadge health={45} />                 // red pill "Critical"
<StatusBadge variant="tag" label="NPS +32" sentiment="promoter" /> // green tag
```

**Internals:**
- Uses `getActionStatusColor()`, `getPriorityColor()`, `getHealthColor()`, `getNPSColor()` from design-tokens
- Shape options: `pill` (default), `rect`, `tag` → maps to `BadgeStyles`
- Extends existing shadcn Badge component

### 1b. EmptyState (`src/components/ui/EmptyState.tsx`)

Generic empty state for the 20+ ad-hoc implementations. The existing `insights/EmptyState.tsx` stays (domain-specific).

**API:**
```tsx
<EmptyState
  icon={FileSearch}
  title="No actions found"
  description="Try adjusting your filters or creating a new action."
  action={{ label: "Create Action", onClick: handleCreate }}
/>
```

**Variants:**
- Standard: centred icon circle (purple-100 bg) + title + description + optional CTA
- Compact: smaller icon, no circle bg — for sidebar panels and card bodies

### 1c. CardContainer (`src/components/ui/CardContainer.tsx`)

Thin wrapper applying `LayoutTokens.card` + `LayoutTokens.cardPadding`.

**API:**
```tsx
<CardContainer>content</CardContainer>                    // standard (p-5)
<CardContainer padding="compact">sidebar</CardContainer>  // p-3
<CardContainer elevated>featured</CardContainer>          // shadow-md
<CardContainer noPadding>table</CardContainer>            // no padding
```

Replaces 100+ inline `rounded-lg border border-gray-200 bg-white shadow-sm` patterns.

## Phase 2: Codebase Migration Sweep

Seven workstreams applied across the codebase:

| # | Workstream | Scope | Files (~) |
|---|-----------|-------|-----------|
| 1 | Badge migration | Replace inline badge spans with StatusBadge | ~30 |
| 2 | Empty state migration | Replace ad-hoc empty states with EmptyState | ~15 |
| 3 | Card container migration | Replace inline card styling with CardContainer | ~40 |
| 4 | Typography token sweep | Replace hardcoded heading classes with TypographyClasses | ~20 |
| 5 | Duplicate colour function removal | Delete local getStatusColor/getPriorityColor, import from design-tokens | ~8 |
| 6 | Form input standardisation | Unify input rounded-md → rounded-lg, focus ring → InteractiveTokens | ~10 |
| 7 | Sidebar hardcoded colour cleanup | Replace 40+ hardcoded bg-gray/red/amber with token imports | ~5 |

## What We're NOT Changing

- No new design tokens — existing token system is comprehensive
- No changes to PageShell, DataTable, FormRenderer — already solid
- No modal unification — 30+ custom modals work fine; high effort, low return
- No dark mode audit — CSEs use light mode
- Backend/API routes — untouched
- Loading skeletons — already at 9/10

## Verification

- `npx tsc --noEmit` — zero type errors
- `npx next lint` — zero lint errors
- `npm run build` — successful build
- Visual spot-check: Dashboard, Clients, Actions, Goals, Digest
