# Tier 3 Strategic Features Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement 4 medium-impact strategic features: responsive tablet/mobile layouts, drag-to-prioritise opportunities, progress celebration confetti, and per-entity ChaSen chat threads.

**Architecture:** Leverage existing infrastructure - `@dnd-kit` (installed), `canvas-confetti` (installed), `useDeviceType` hook, and ChaSen conversation context. Focus on wiring, not new development.

**Tech Stack:** React 18, TypeScript, Tailwind CSS, @dnd-kit/sortable, canvas-confetti, existing ChaSen API

---

## Pre-Implementation Notes

**Infrastructure Already Available:**
- ✅ `@dnd-kit/core`, `@dnd-kit/sortable` - installed in package.json
- ✅ `DraggableList.tsx` - working component at `src/components/planning/`
- ✅ `canvas-confetti` - installed in package.json
- ✅ `ConfettiCelebration.tsx` - working component at `src/components/gamification/`
- ✅ `useDeviceType` hook with BREAKPOINTS constant
- ✅ ChaSen conversation API with `context` field supporting `'client'` type

**Actual Scope: Primarily wiring existing components**

---

## Task 1: Responsive Tablet/Mobile Layouts

**Files:**
- Modify: `src/app/(dashboard)/planning/strategic/new/page.tsx`
- Create: `src/components/planning/wizard/MobileStepNav.tsx`
- Modify: `src/components/planning/wizard/WizardMinimap.tsx`

**Step 1: Create mobile bottom navigation component**

```typescript
'use client'

import { cn } from '@/lib/utils'
import { Check } from 'lucide-react'

export interface MobileStepNavProps {
  currentStep: number
  totalSteps: number
  completedSteps: number[]
  stepLabels: string[]
  onStepClick: (step: number) => void
}

export function MobileStepNav({
  currentStep,
  totalSteps,
  completedSteps,
  stepLabels,
  onStepClick,
}: MobileStepNavProps) {
  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 lg:hidden">
      <div className="bg-white/95 dark:bg-slate-900/95 backdrop-blur-sm border-t border-slate-200 dark:border-slate-700 shadow-lg">
        {/* Progress bar */}
        <div className="h-1 bg-slate-100 dark:bg-slate-800">
          <div
            className="h-full bg-indigo-500 transition-all duration-300"
            style={{ width: `${((currentStep + 1) / totalSteps) * 100}%` }}
          />
        </div>

        {/* Step indicators */}
        <div className="flex justify-around px-2 py-3">
          {Array.from({ length: totalSteps }).map((_, i) => {
            const isActive = i === currentStep
            const isCompleted = completedSteps.includes(i)

            return (
              <button
                key={i}
                onClick={() => onStepClick(i)}
                className={cn(
                  'flex flex-col items-center gap-1 min-w-[48px] min-h-[48px] p-1',
                  'rounded-lg transition-colors',
                  isActive && 'bg-indigo-50 dark:bg-indigo-900/30'
                )}
              >
                <div
                  className={cn(
                    'w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium',
                    isActive && 'bg-indigo-500 text-white',
                    isCompleted && !isActive && 'bg-green-500 text-white',
                    !isActive && !isCompleted && 'bg-slate-200 dark:bg-slate-700 text-slate-600 dark:text-slate-400'
                  )}
                >
                  {isCompleted ? <Check className="h-4 w-4" /> : i + 1}
                </div>
                <span
                  className={cn(
                    'text-[10px] line-clamp-1 max-w-[60px] text-center',
                    isActive ? 'text-indigo-600 dark:text-indigo-400 font-medium' : 'text-slate-500 dark:text-slate-400'
                  )}
                >
                  {stepLabels[i]?.split(' ')[0]}
                </span>
              </button>
            )
          })}
        </div>

        {/* Safe area for iOS */}
        <div className="h-safe-area-inset-bottom bg-white dark:bg-slate-900" />
      </div>
    </nav>
  )
}

export default MobileStepNav
```

**Step 2: Update WizardMinimap for responsive hiding**

In `WizardMinimap.tsx`, ensure it's hidden on mobile (already has `hidden lg:block`).

**Step 3: Update page layout for mobile**

Add `MobileStepNav` to the strategic planning page, conditionally rendered for mobile/tablet:

```tsx
// Add import
import { MobileStepNav } from '@/components/planning/wizard/MobileStepNav'

// In component, add after WizardMinimap:
<MobileStepNav
  currentStep={currentStep}
  totalSteps={STEPS.length}
  completedSteps={completedSteps}
  stepLabels={STEPS.map(s => s.title)}
  onStepClick={goToStep}
/>

// Add bottom padding to main content to account for mobile nav
<main className="pb-24 lg:pb-0">
```

**Step 4: Commit**

```bash
git add src/components/planning/wizard/MobileStepNav.tsx src/app/\(dashboard\)/planning/strategic/new/page.tsx
git commit -m "feat: add MobileStepNav for responsive tablet/mobile layouts"
```

---

## Task 2: Drag-to-Prioritise Opportunities

**Files:**
- Modify: `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`

**Step 1: Wire DraggableList into opportunity cards**

The `DraggableList` component already exists. Wire it into the opportunity step:

```typescript
// Add import
import { DraggableList, type DraggableItem } from '@/components/planning/DraggableList'

// Transform opportunities to DraggableItems
const opportunityItems: DraggableItem[] = opportunities.map(opp => ({
  id: opp.id,
  title: opp.name,
  subtitle: `$${(opp.potential_value || 0).toLocaleString()} • ${opp.probability}% probability`,
}))

// Handle reorder
const handleReorder = (reordered: DraggableItem[]) => {
  const newOrder = reordered.map(item =>
    opportunities.find(o => o.id === item.id)!
  )
  setOpportunities(newOrder)
}

// Handle delete
const handleDelete = (id: string) => {
  setOpportunities(prev => prev.filter(o => o.id !== id))
}

// Render
<DraggableList
  items={opportunityItems}
  onReorder={handleReorder}
  onDelete={handleDelete}
  emptyMessage="No opportunities added yet"
/>
```

**Step 2: Commit**

```bash
git add src/app/\(dashboard\)/planning/strategic/new/steps/OpportunityStrategyStep.tsx
git commit -m "feat: add drag-to-prioritise for opportunities"
```

---

## Task 3: Progress Celebration Confetti

**Files:**
- Modify: `src/app/(dashboard)/planning/strategic/new/page.tsx`

**Step 1: Wire ConfettiCelebration into step completion**

```typescript
// Add import
import { ConfettiCelebration } from '@/components/gamification/ConfettiCelebration'

// Add state
const [showConfetti, setShowConfetti] = useState(false)
const [celebrationType, setCelebrationType] = useState<'milestone' | 'completion' | 'win'>('milestone')

// Trigger on step completion
const handleStepComplete = (stepIndex: number) => {
  if (!completedSteps.includes(stepIndex)) {
    setCompletedSteps(prev => [...prev, stepIndex])

    // Determine celebration type
    if (stepIndex === STEPS.length - 1) {
      // Final step - big celebration
      setCelebrationType('win')
    } else if (stepIndex === Math.floor(STEPS.length / 2)) {
      // Halfway - medium celebration
      setCelebrationType('completion')
    } else {
      // Regular step - small celebration
      setCelebrationType('milestone')
    }

    setShowConfetti(true)
  }
}

// Update goToStep to mark previous step complete when moving forward
const goToStep = (step: number) => {
  if (step > currentStep) {
    handleStepComplete(currentStep)
  }
  setCurrentStep(step)
}

// Render confetti
{showConfetti && (
  <ConfettiCelebration
    type={celebrationType}
    onComplete={() => setShowConfetti(false)}
  />
)}
```

**Step 2: Commit**

```bash
git add src/app/\(dashboard\)/planning/strategic/new/page.tsx
git commit -m "feat: add progress celebration confetti on step completion"
```

---

## Task 4: Per-Entity ChaSen Chat Threads

**Files:**
- Modify: `src/components/FloatingChaSenAI.tsx`
- Modify: `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx`
- Create: `src/components/ai/EntityChatButton.tsx`

**Step 1: Create EntityChatButton component**

```typescript
'use client'

import { useState } from 'react'
import { MessageSquare, Sparkles } from 'lucide-react'
import { cn } from '@/lib/utils'

export interface EntityChatButtonProps {
  entityType: 'opportunity' | 'stakeholder' | 'risk'
  entityId: string
  entityName: string
  clientName?: string
  onOpenChat?: (conversationId: string) => void
  className?: string
}

export function EntityChatButton({
  entityType,
  entityId,
  entityName,
  clientName,
  onOpenChat,
  className,
}: EntityChatButtonProps) {
  const [isCreating, setIsCreating] = useState(false)

  const handleClick = async () => {
    setIsCreating(true)
    try {
      // Create or get existing conversation for this entity
      const response = await fetch('/api/chasen/conversations', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: `${entityType}: ${entityName}`,
          context: 'client',
          client_name: clientName,
          metadata: {
            entity_type: entityType,
            entity_id: entityId,
          },
        }),
      })

      if (response.ok) {
        const { data } = await response.json()
        onOpenChat?.(data.id)

        // Trigger ChaSen floating panel to open with this conversation
        window.dispatchEvent(new CustomEvent('chasen:open', {
          detail: { conversationId: data.id }
        }))
      }
    } catch (error) {
      console.error('Failed to create chat thread:', error)
    } finally {
      setIsCreating(false)
    }
  }

  return (
    <button
      onClick={handleClick}
      disabled={isCreating}
      className={cn(
        'inline-flex items-center gap-1.5 px-2 py-1 rounded-md text-xs',
        'bg-indigo-50 dark:bg-indigo-900/30 text-indigo-600 dark:text-indigo-400',
        'hover:bg-indigo-100 dark:hover:bg-indigo-900/50 transition-colors',
        'disabled:opacity-50 disabled:cursor-not-allowed',
        className
      )}
      title={`Ask ChaSen about ${entityName}`}
    >
      {isCreating ? (
        <Sparkles className="h-3 w-3 animate-pulse" />
      ) : (
        <MessageSquare className="h-3 w-3" />
      )}
      Ask ChaSen
    </button>
  )
}

export default EntityChatButton
```

**Step 2: Wire into opportunity cards**

In `OpportunityStrategyStep.tsx`, add EntityChatButton to each opportunity card:

```tsx
// Add import
import { EntityChatButton } from '@/components/ai/EntityChatButton'

// In opportunity card render
<div className="flex items-center gap-2">
  <EntityChatButton
    entityType="opportunity"
    entityId={opportunity.id}
    entityName={opportunity.name}
    clientName={selectedClient?.name}
  />
  {/* existing buttons */}
</div>
```

**Step 3: Update FloatingChaSenAI to listen for open events**

In `FloatingChaSenAI.tsx`, add event listener:

```tsx
// In useEffect
useEffect(() => {
  const handleOpenRequest = (e: CustomEvent) => {
    if (e.detail?.conversationId) {
      setActiveConversationId(e.detail.conversationId)
      setIsOpen(true)
    }
  }

  window.addEventListener('chasen:open', handleOpenRequest as EventListener)
  return () => window.removeEventListener('chasen:open', handleOpenRequest as EventListener)
}, [])
```

**Step 4: Commit**

```bash
git add src/components/ai/EntityChatButton.tsx src/app/\(dashboard\)/planning/strategic/new/steps/OpportunityStrategyStep.tsx src/components/FloatingChaSenAI.tsx
git commit -m "feat: add per-entity ChaSen chat threads for opportunities"
```

---

## Task 5: Verification

**Step 1: Run TypeScript check**

```bash
npx tsc --noEmit
```

**Step 2: Run dev server**

```bash
npm run dev -- -p 3001
```

**Step 3: Test each feature**

Navigate to `/planning/strategic/new` and verify:
- [ ] **Mobile nav** - Resize to mobile, bottom nav appears with step indicators
- [ ] **Drag opportunities** - Drag handle visible, can reorder opportunities
- [ ] **Confetti** - Moving to next step triggers celebration
- [ ] **Entity chat** - "Ask ChaSen" button on opportunities opens chat thread

**Step 4: Final commit**

```bash
git add -A
git commit -m "test: verify Tier 3 strategic features working"
```

---

## Summary

| Task | Feature | Effort | Dependencies |
|------|---------|--------|--------------|
| 1 | MobileStepNav | Small | useDeviceType |
| 2 | Drag-to-Prioritise | Small | DraggableList (exists) |
| 3 | Progress Celebration | Small | ConfettiCelebration (exists) |
| 4 | Per-Entity Chat | Medium | ChaSen API |
| 5 | Verification | Small | Tasks 1-4 |

**Total commits:** 5
**Estimated effort:** 1 day (mostly wiring existing components)
