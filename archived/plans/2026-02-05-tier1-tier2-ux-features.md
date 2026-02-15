# Tier 1 & 2 UX Features Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement 5 high-impact UX features for the Strategic Planning wizard: animated numbers, orbital minimap, split-screen pinning, AI confidence indicators, and voice input integration.

**Architecture:** Create reusable UI components in appropriate directories, integrate with existing wizard infrastructure. All features follow existing patterns and use Tailwind CSS for styling.

**Tech Stack:** React 18, TypeScript, Tailwind CSS, existing hooks (useVoiceInput, useSwipeGesture)

---

## Pre-Implementation Notes

The gap analysis identified 11 Tier 1/2 features. Investigation revealed 6 already exist:
- ✅ `useSwipeGesture` - already wired in planning page
- ✅ `useWizardKeyboardNav` - keyboard shortcuts working
- ✅ `SemanticBreadcrumbs.tsx` - component exists
- ✅ `forecast-calculator.ts` - complete with coverage calculation
- ✅ `useVoiceInput` - hook ready (needs UI)

**Actual scope: 5 features to build**

---

## Task 1: AnimatedNumber Component

**Files:**
- Create: `src/components/ui/AnimatedNumber.tsx`

**Step 1: Create the component**

```typescript
'use client'

import { useEffect, useRef, useState } from 'react'
import { cn } from '@/lib/utils'

export interface AnimatedNumberProps {
  value: number
  format?: 'currency' | 'percent' | 'number' | 'compact'
  duration?: number
  className?: string
  pulseOnChange?: boolean
}

export function AnimatedNumber({
  value,
  format = 'number',
  duration = 600,
  className,
  pulseOnChange = true,
}: AnimatedNumberProps) {
  const [displayValue, setDisplayValue] = useState(value)
  const [isPulsing, setIsPulsing] = useState(false)
  const prevValue = useRef(value)
  const frameRef = useRef<number>()

  useEffect(() => {
    if (prevValue.current !== value) {
      if (pulseOnChange) setIsPulsing(true)

      const startValue = prevValue.current
      const startTime = performance.now()

      const animate = (currentTime: number) => {
        const elapsed = currentTime - startTime
        const progress = Math.min(elapsed / duration, 1)
        // easeOutCubic for smooth deceleration
        const eased = 1 - Math.pow(1 - progress, 3)

        setDisplayValue(startValue + (value - startValue) * eased)

        if (progress < 1) {
          frameRef.current = requestAnimationFrame(animate)
        } else {
          setIsPulsing(false)
          prevValue.current = value
        }
      }

      frameRef.current = requestAnimationFrame(animate)

      return () => {
        if (frameRef.current) cancelAnimationFrame(frameRef.current)
      }
    }
  }, [value, duration, pulseOnChange])

  const formatted = (() => {
    switch (format) {
      case 'currency':
        if (Math.abs(displayValue) >= 1_000_000) {
          return `$${(displayValue / 1_000_000).toFixed(2)}M`
        } else if (Math.abs(displayValue) >= 1_000) {
          return `$${(displayValue / 1_000).toFixed(0)}K`
        }
        return `$${displayValue.toFixed(0)}`
      case 'percent':
        return `${displayValue.toFixed(1)}%`
      case 'compact':
        if (Math.abs(displayValue) >= 1_000_000) {
          return `${(displayValue / 1_000_000).toFixed(1)}M`
        } else if (Math.abs(displayValue) >= 1_000) {
          return `${(displayValue / 1_000).toFixed(0)}K`
        }
        return displayValue.toFixed(0)
      default:
        return displayValue.toFixed(0)
    }
  })()

  return (
    <span
      className={cn(
        'inline-block transition-all duration-200',
        isPulsing && 'text-blue-600 dark:text-blue-400 scale-105',
        className
      )}
    >
      {formatted}
    </span>
  )
}

export default AnimatedNumber
```

**Step 2: Add to UI index**

Add export to `src/components/ui/index.ts` if it exists, or import directly.

**Step 3: Commit**

```bash
git add src/components/ui/AnimatedNumber.tsx
git commit -m "feat: add AnimatedNumber component for live data pulse"
```

---

## Task 2: WizardMinimap Component

**Files:**
- Create: `src/components/planning/wizard/WizardMinimap.tsx`
- Modify: `src/app/(dashboard)/planning/strategic/new/page.tsx`

**Step 1: Create the minimap component**

```typescript
'use client'

import { cn } from '@/lib/utils'

export interface WizardMinimapProps {
  currentStep: number
  totalSteps: number
  completedSteps: number[]
  stepLabels: string[]
  onStepClick?: (step: number) => void
  className?: string
}

export function WizardMinimap({
  currentStep,
  totalSteps,
  completedSteps,
  stepLabels,
  onStepClick,
  className,
}: WizardMinimapProps) {
  const radius = 32
  const dotRadius = 6
  const center = 44

  return (
    <div
      className={cn(
        'fixed bottom-6 right-6 z-40 hidden lg:block',
        'bg-white/90 dark:bg-slate-800/90 backdrop-blur-sm',
        'rounded-2xl shadow-lg border border-slate-200 dark:border-slate-700 p-2',
        className
      )}
    >
      <svg viewBox="0 0 88 88" className="w-20 h-20">
        {/* Orbit ring */}
        <circle
          cx={center}
          cy={center}
          r={radius}
          className="fill-none stroke-slate-200 dark:stroke-slate-700"
          strokeWidth="2"
          strokeDasharray="4 2"
        />

        {/* Connection lines */}
        {Array.from({ length: totalSteps }).map((_, i) => {
          const angle = (i / totalSteps) * 2 * Math.PI - Math.PI / 2
          const nextAngle = ((i + 1) / totalSteps) * 2 * Math.PI - Math.PI / 2
          const x1 = center + radius * Math.cos(angle)
          const y1 = center + radius * Math.sin(angle)
          const x2 = center + radius * Math.cos(nextAngle)
          const y2 = center + radius * Math.sin(nextAngle)
          const isCompleted = completedSteps.includes(i) && completedSteps.includes(i + 1)

          if (i === totalSteps - 1) return null

          return (
            <line
              key={`line-${i}`}
              x1={x1}
              y1={y1}
              x2={x2}
              y2={y2}
              className={cn(
                'transition-all',
                isCompleted ? 'stroke-green-400' : 'stroke-slate-300 dark:stroke-slate-600'
              )}
              strokeWidth="2"
            />
          )
        })}

        {/* Step dots */}
        {Array.from({ length: totalSteps }).map((_, i) => {
          const angle = (i / totalSteps) * 2 * Math.PI - Math.PI / 2
          const x = center + radius * Math.cos(angle)
          const y = center + radius * Math.sin(angle)
          const isActive = i === currentStep
          const isCompleted = completedSteps.includes(i)

          return (
            <g key={i} className="cursor-pointer" onClick={() => onStepClick?.(i)}>
              {/* Pulse ring for active */}
              {isActive && (
                <circle
                  cx={x}
                  cy={y}
                  r={dotRadius + 4}
                  className="fill-none stroke-blue-400 animate-ping opacity-50"
                  strokeWidth="2"
                />
              )}
              {/* Main dot */}
              <circle
                cx={x}
                cy={y}
                r={isActive ? dotRadius + 2 : dotRadius}
                className={cn(
                  'transition-all',
                  isActive && 'fill-blue-500 stroke-blue-300 stroke-2',
                  isCompleted && !isActive && 'fill-green-500',
                  !isCompleted && !isActive && 'fill-slate-300 dark:fill-slate-600 hover:fill-slate-400'
                )}
              />
              {/* Step number */}
              <text
                x={x}
                y={y + 1}
                textAnchor="middle"
                dominantBaseline="middle"
                className={cn(
                  'text-[8px] font-bold pointer-events-none',
                  isActive || isCompleted ? 'fill-white' : 'fill-slate-600 dark:fill-slate-300'
                )}
              >
                {i + 1}
              </text>
            </g>
          )
        })}

        {/* Center info */}
        <text
          x={center}
          y={center - 4}
          textAnchor="middle"
          className="fill-slate-700 dark:fill-slate-200 text-sm font-semibold"
        >
          {currentStep + 1}/{totalSteps}
        </text>
        <text
          x={center}
          y={center + 8}
          textAnchor="middle"
          className="fill-slate-400 text-[7px]"
        >
          {completedSteps.length} done
        </text>
      </svg>

      {/* Current step label */}
      <div className="text-center mt-1">
        <span className="text-[10px] text-slate-500 dark:text-slate-400 line-clamp-1">
          {stepLabels[currentStep]}
        </span>
      </div>
    </div>
  )
}

export default WizardMinimap
```

**Step 2: Integrate into planning page**

In `page.tsx`, add the minimap component with wizard state.

**Step 3: Commit**

```bash
git add src/components/planning/wizard/WizardMinimap.tsx
git commit -m "feat: add WizardMinimap orbital navigation component"
```

---

## Task 3: PinnedPanel and usePinnedContent

**Files:**
- Create: `src/hooks/usePinnedContent.ts`
- Create: `src/components/planning/wizard/PinnedPanel.tsx`

**Step 1: Create the hook**

```typescript
'use client'

import { useState, useCallback } from 'react'

export type PinnableContentType = 'health' | 'forecast' | 'stakeholders' | 'opportunities' | 'custom'

export interface PinnedContent {
  id: string
  type: PinnableContentType
  title: string
  data: Record<string, unknown>
  pinnedAt: Date
  sourceStep: number
}

export interface UsePinnedContentReturn {
  pinnedItems: PinnedContent[]
  pin: (content: Omit<PinnedContent, 'id' | 'pinnedAt'>) => void
  unpin: (id: string) => void
  unpinByIndex: (index: number) => void
  clearAll: () => void
  isPinned: (type: PinnableContentType, dataId?: string) => boolean
}

export function usePinnedContent(maxItems = 5): UsePinnedContentReturn {
  const [pinnedItems, setPinnedItems] = useState<PinnedContent[]>([])

  const pin = useCallback((content: Omit<PinnedContent, 'id' | 'pinnedAt'>) => {
    setPinnedItems(prev => {
      // Check for duplicate
      const exists = prev.some(
        item => item.type === content.type && JSON.stringify(item.data) === JSON.stringify(content.data)
      )
      if (exists) return prev

      const newItem: PinnedContent = {
        ...content,
        id: `${content.type}-${Date.now()}`,
        pinnedAt: new Date(),
      }

      // Limit to maxItems, remove oldest if needed
      const updated = [newItem, ...prev]
      return updated.slice(0, maxItems)
    })
  }, [maxItems])

  const unpin = useCallback((id: string) => {
    setPinnedItems(prev => prev.filter(item => item.id !== id))
  }, [])

  const unpinByIndex = useCallback((index: number) => {
    setPinnedItems(prev => prev.filter((_, i) => i !== index))
  }, [])

  const clearAll = useCallback(() => {
    setPinnedItems([])
  }, [])

  const isPinned = useCallback((type: PinnableContentType, dataId?: string) => {
    return pinnedItems.some(item => {
      if (item.type !== type) return false
      if (dataId && item.data.id !== dataId) return false
      return true
    })
  }, [pinnedItems])

  return {
    pinnedItems,
    pin,
    unpin,
    unpinByIndex,
    clearAll,
    isPinned,
  }
}

export default usePinnedContent
```

**Step 2: Create the panel component**

```typescript
'use client'

import { useState } from 'react'
import { X, Pin, ChevronLeft, ChevronRight, Trash2 } from 'lucide-react'
import { cn } from '@/lib/utils'
import { type PinnedContent } from '@/hooks/usePinnedContent'

export interface PinnedPanelProps {
  pinnedItems: PinnedContent[]
  onUnpin: (id: string) => void
  onClear: () => void
  className?: string
}

export function PinnedPanel({ pinnedItems, onUnpin, onClear, className }: PinnedPanelProps) {
  const [isCollapsed, setIsCollapsed] = useState(false)

  if (pinnedItems.length === 0) return null

  return (
    <div
      className={cn(
        'fixed right-0 top-20 z-40 transition-all duration-300',
        'hidden lg:block',
        isCollapsed ? 'w-10' : 'w-72',
        className
      )}
    >
      {/* Toggle button */}
      <button
        onClick={() => setIsCollapsed(!isCollapsed)}
        className={cn(
          'absolute -left-4 top-4 z-50',
          'w-8 h-8 rounded-full bg-white dark:bg-slate-800',
          'border border-slate-200 dark:border-slate-700 shadow-md',
          'flex items-center justify-center',
          'hover:bg-slate-50 dark:hover:bg-slate-700 transition-colors'
        )}
      >
        {isCollapsed ? (
          <ChevronLeft className="h-4 w-4 text-slate-600 dark:text-slate-400" />
        ) : (
          <ChevronRight className="h-4 w-4 text-slate-600 dark:text-slate-400" />
        )}
      </button>

      {/* Panel content */}
      <div
        className={cn(
          'h-[calc(100vh-10rem)] bg-white dark:bg-slate-800',
          'border-l border-slate-200 dark:border-slate-700 shadow-xl',
          'transition-opacity duration-200',
          isCollapsed && 'opacity-0 pointer-events-none'
        )}
      >
        {/* Header */}
        <div className="flex items-center justify-between px-3 py-2 border-b border-slate-200 dark:border-slate-700">
          <div className="flex items-center gap-2">
            <Pin className="h-4 w-4 text-blue-500" />
            <span className="font-medium text-sm text-slate-900 dark:text-slate-100">
              Pinned ({pinnedItems.length})
            </span>
          </div>
          <button
            onClick={onClear}
            className="p-1 text-slate-400 hover:text-red-500 transition-colors"
            title="Clear all"
          >
            <Trash2 className="h-4 w-4" />
          </button>
        </div>

        {/* Items */}
        <div className="overflow-y-auto h-[calc(100%-3rem)]">
          {pinnedItems.map(item => (
            <PinnedItem key={item.id} item={item} onUnpin={() => onUnpin(item.id)} />
          ))}
        </div>
      </div>
    </div>
  )
}

interface PinnedItemProps {
  item: PinnedContent
  onUnpin: () => void
}

function PinnedItem({ item, onUnpin }: PinnedItemProps) {
  const typeColors: Record<string, string> = {
    health: 'border-l-green-500',
    forecast: 'border-l-blue-500',
    stakeholders: 'border-l-purple-500',
    opportunities: 'border-l-amber-500',
    custom: 'border-l-slate-500',
  }

  return (
    <div
      className={cn(
        'p-3 border-b border-slate-100 dark:border-slate-700',
        'border-l-4 group',
        typeColors[item.type] || typeColors.custom
      )}
    >
      <div className="flex items-start justify-between gap-2">
        <div className="flex-1 min-w-0">
          <span className="text-[10px] font-medium text-slate-400 uppercase tracking-wide">
            {item.type}
          </span>
          <p className="text-sm font-medium text-slate-900 dark:text-slate-100 truncate">
            {item.title}
          </p>
        </div>
        <button
          onClick={onUnpin}
          className="opacity-0 group-hover:opacity-100 p-1 text-slate-400 hover:text-red-500 transition-all"
        >
          <X className="h-3 w-3" />
        </button>
      </div>

      {/* Render data based on type */}
      <div className="mt-2 text-xs text-slate-600 dark:text-slate-400">
        {item.type === 'health' && item.data.score && (
          <div className="flex items-center gap-2">
            <span>Health Score:</span>
            <span className="font-bold text-lg">{String(item.data.score)}</span>
          </div>
        )}
        {item.type === 'forecast' && (
          <div className="space-y-1">
            {item.data.committed && (
              <div className="flex justify-between">
                <span>Committed</span>
                <span className="font-medium">${(Number(item.data.committed) / 1e6).toFixed(2)}M</span>
              </div>
            )}
            {item.data.gap && (
              <div className="flex justify-between">
                <span>Gap</span>
                <span className="font-medium text-amber-600">${(Number(item.data.gap) / 1e6).toFixed(2)}M</span>
              </div>
            )}
          </div>
        )}
        {item.type === 'stakeholders' && Array.isArray(item.data.contacts) && (
          <div>
            {(item.data.contacts as Array<{ name: string }>).slice(0, 3).map((c, i) => (
              <div key={i} className="truncate">{c.name}</div>
            ))}
            {(item.data.contacts as Array<unknown>).length > 3 && (
              <div className="text-slate-400">+{(item.data.contacts as Array<unknown>).length - 3} more</div>
            )}
          </div>
        )}
      </div>
    </div>
  )
}

export default PinnedPanel
```

**Step 3: Commit**

```bash
git add src/hooks/usePinnedContent.ts src/components/planning/wizard/PinnedPanel.tsx
git commit -m "feat: add PinnedPanel for split-screen continuity"
```

---

## Task 4: AI Confidence Indicators

**Files:**
- Create: `src/components/ai/ConfidenceIndicator.tsx`
- Modify: `src/app/api/ai/field-suggestions/route.ts`

**Step 1: Create the component**

```typescript
'use client'

import { useState } from 'react'
import { ChevronDown, ChevronUp, Sparkles, Info, HelpCircle } from 'lucide-react'
import { cn } from '@/lib/utils'

export interface ConfidenceBasis {
  type: 'similar_deals' | 'historical_data' | 'pattern_match' | 'client_history' | 'industry_benchmark'
  count: number
  description?: string
}

export interface ConfidenceIndicatorProps {
  confidence: number
  basis?: ConfidenceBasis[]
  reasoning?: string
  compact?: boolean
  className?: string
}

export function ConfidenceIndicator({
  confidence,
  basis = [],
  reasoning,
  compact = false,
  className,
}: ConfidenceIndicatorProps) {
  const [showDetails, setShowDetails] = useState(false)

  const getConfidenceColor = (score: number) => {
    if (score >= 80) return 'text-green-600 bg-green-50 border-green-200 dark:bg-green-900/20 dark:border-green-800'
    if (score >= 60) return 'text-blue-600 bg-blue-50 border-blue-200 dark:bg-blue-900/20 dark:border-blue-800'
    if (score >= 40) return 'text-amber-600 bg-amber-50 border-amber-200 dark:bg-amber-900/20 dark:border-amber-800'
    return 'text-slate-500 bg-slate-50 border-slate-200 dark:bg-slate-800 dark:border-slate-700'
  }

  const getBasisLabel = (b: ConfidenceBasis): string => {
    switch (b.type) {
      case 'similar_deals': return `${b.count} similar deals`
      case 'historical_data': return `${b.count} historical data points`
      case 'pattern_match': return `${b.count} pattern matches`
      case 'client_history': return `${b.count} past interactions`
      case 'industry_benchmark': return `${b.count} industry benchmarks`
      default: return b.description || `${b.count} references`
    }
  }

  const basisSummary = basis.map(getBasisLabel).join(', ')

  if (compact) {
    return (
      <span className={cn('inline-flex items-center gap-1', className)} title={`${confidence}% confidence${basisSummary ? ` based on ${basisSummary}` : ''}`}>
        <Sparkles className="h-3 w-3 text-blue-500" />
        <span className={cn('px-1.5 py-0.5 rounded-full text-[10px] font-medium border', getConfidenceColor(confidence))}>
          {confidence}%
        </span>
      </span>
    )
  }

  return (
    <div className={cn('rounded-lg border p-3', getConfidenceColor(confidence), className)}>
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Sparkles className="h-4 w-4" />
          <span className="font-medium text-sm">{confidence}% confidence</span>
        </div>
        {reasoning && (
          <button
            onClick={() => setShowDetails(!showDetails)}
            className="p-1 hover:bg-white/50 dark:hover:bg-black/20 rounded transition-colors"
          >
            {showDetails ? <ChevronUp className="h-4 w-4" /> : <ChevronDown className="h-4 w-4" />}
          </button>
        )}
      </div>

      {basis.length > 0 && (
        <p className="text-xs mt-1 opacity-80">Based on {basisSummary}</p>
      )}

      {showDetails && reasoning && (
        <div className="mt-3 pt-3 border-t border-current/20">
          <div className="flex items-start gap-2 text-xs">
            <Info className="h-3 w-3 mt-0.5 flex-shrink-0" />
            <p className="leading-relaxed">{reasoning}</p>
          </div>
        </div>
      )}
    </div>
  )
}

export interface AISuggestionCardProps {
  suggestion: string
  confidence: number
  basis?: ConfidenceBasis[]
  reasoning?: string
  onAccept?: () => void
  onDismiss?: () => void
  children?: React.ReactNode
  className?: string
}

export function AISuggestionCard({
  suggestion,
  confidence,
  basis,
  reasoning,
  onAccept,
  onDismiss,
  children,
  className,
}: AISuggestionCardProps) {
  return (
    <div className={cn('border border-blue-200 dark:border-blue-800 rounded-lg overflow-hidden', className)}>
      <div className="p-3 bg-blue-50/50 dark:bg-blue-900/20">
        {children || <p className="text-sm text-slate-700 dark:text-slate-300">{suggestion}</p>}
      </div>
      <div className="px-3 py-2 bg-white dark:bg-slate-800 flex items-center justify-between border-t border-blue-100 dark:border-blue-900">
        <ConfidenceIndicator confidence={confidence} basis={basis} reasoning={reasoning} compact />
        <div className="flex gap-2">
          {onDismiss && (
            <button
              onClick={onDismiss}
              className="text-xs text-slate-500 hover:text-slate-700 dark:hover:text-slate-300 px-2 py-1 rounded hover:bg-slate-100 dark:hover:bg-slate-700 transition-colors"
            >
              Dismiss
            </button>
          )}
          {onAccept && (
            <button
              onClick={onAccept}
              className="text-xs bg-blue-600 text-white px-3 py-1 rounded hover:bg-blue-700 transition-colors"
            >
              Apply
            </button>
          )}
        </div>
      </div>
    </div>
  )
}

export default ConfidenceIndicator
```

**Step 2: Update field-suggestions API to return confidence**

In `/api/ai/field-suggestions/route.ts`, add confidence calculation based on:
- Number of similar client contexts in database
- Historical suggestion acceptance rate
- Data completeness of the current context

**Step 3: Commit**

```bash
git add src/components/ai/ConfidenceIndicator.tsx
git commit -m "feat: add AI ConfidenceIndicator with explainability"
```

---

## Task 5: VoiceInputButton Component

**Files:**
- Create: `src/components/ui/VoiceInputButton.tsx`
- Modify: `src/components/ai/PredictiveInput.tsx`

**Step 1: Create the button component**

```typescript
'use client'

import { useEffect, useCallback } from 'react'
import { Mic, MicOff, Loader2 } from 'lucide-react'
import { cn } from '@/lib/utils'
import { useVoiceInput } from '@/hooks/useVoiceInput'

export interface VoiceInputButtonProps {
  onTranscript: (text: string) => void
  onInterim?: (text: string) => void
  disabled?: boolean
  className?: string
}

export function VoiceInputButton({
  onTranscript,
  onInterim,
  disabled = false,
  className,
}: VoiceInputButtonProps) {
  const {
    isListening,
    isSupported,
    transcript,
    interimTranscript,
    toggleListening,
    stopListening,
    error,
  } = useVoiceInput({
    continuous: false,
    lang: 'en-AU',
  })

  // Handle final transcript
  useEffect(() => {
    if (transcript && !isListening) {
      onTranscript(transcript)
    }
  }, [transcript, isListening, onTranscript])

  // Handle interim transcript
  useEffect(() => {
    if (interimTranscript && onInterim) {
      onInterim(interimTranscript)
    }
  }, [interimTranscript, onInterim])

  const handleClick = useCallback(() => {
    if (disabled) return
    toggleListening()
  }, [disabled, toggleListening])

  if (!isSupported) return null

  return (
    <button
      type="button"
      onClick={handleClick}
      disabled={disabled}
      className={cn(
        'p-2 rounded-lg transition-all duration-200',
        'focus:outline-none focus:ring-2 focus:ring-offset-2',
        isListening
          ? 'bg-red-100 dark:bg-red-900/30 text-red-600 dark:text-red-400 focus:ring-red-500'
          : 'bg-slate-100 dark:bg-slate-700 text-slate-500 dark:text-slate-400 hover:bg-slate-200 dark:hover:bg-slate-600 focus:ring-slate-500',
        disabled && 'opacity-50 cursor-not-allowed',
        className
      )}
      title={isListening ? 'Stop recording' : 'Voice input (Australian English)'}
      aria-label={isListening ? 'Stop voice recording' : 'Start voice recording'}
    >
      {isListening ? (
        <div className="relative">
          <Mic className="h-4 w-4" />
          <span className="absolute -top-1 -right-1 w-2 h-2 bg-red-500 rounded-full animate-pulse" />
        </div>
      ) : (
        <MicOff className="h-4 w-4" />
      )}
    </button>
  )
}

export default VoiceInputButton
```

**Step 2: Add to PredictiveInput**

Update `src/components/ai/PredictiveInput.tsx` to include an optional voice input button:

```typescript
// Add prop
enableVoice?: boolean

// Add in component JSX, next to the input
{enableVoice && (
  <VoiceInputButton
    onTranscript={(text) => {
      setValue(prev => prev + (prev ? ' ' : '') + text)
    }}
    className="absolute right-2 top-1/2 -translate-y-1/2"
  />
)}
```

**Step 3: Commit**

```bash
git add src/components/ui/VoiceInputButton.tsx src/components/ai/PredictiveInput.tsx
git commit -m "feat: add VoiceInputButton and wire into PredictiveInput"
```

---

## Task 6: Integration and Wiring

**Files to modify:**
- `src/app/(dashboard)/planning/strategic/new/page.tsx` - Add WizardMinimap, PinnedPanel
- `src/components/planning/ForecastSummary.tsx` - Use AnimatedNumber
- Step components - Add pin buttons to data cards

**Step 1: Update page.tsx**

Add imports and component instances:
- WizardMinimap with step state
- PinnedPanel with usePinnedContent hook

**Step 2: Update ForecastSummary.tsx**

Replace static number displays with AnimatedNumber components.

**Step 3: Add pin buttons to data cards**

In step components, add small "Pin" buttons to key data displays (health scores, forecast cards, stakeholder lists).

**Step 4: Commit**

```bash
git add -A
git commit -m "feat: integrate Tier 1 & 2 UX features into planning wizard"
```

---

## Task 7: Verification

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
- [ ] AnimatedNumber - Values animate on change
- [ ] WizardMinimap - Visible in bottom-right, clickable steps
- [ ] PinnedPanel - Pin button works, panel shows pinned content
- [ ] ConfidenceIndicator - AI suggestions show confidence
- [ ] VoiceInputButton - Microphone appears, records speech

**Step 4: Final commit**

```bash
git add -A
git commit -m "test: verify Tier 1 & 2 UX features working"
```

---

## Summary

| Task | Component | Effort | Dependencies |
|------|-----------|--------|--------------|
| 1 | AnimatedNumber | Small | None |
| 2 | WizardMinimap | Medium | None |
| 3 | PinnedPanel + hook | Medium | None |
| 4 | ConfidenceIndicator | Medium | API update |
| 5 | VoiceInputButton | Small | useVoiceInput |
| 6 | Integration | Medium | Tasks 1-5 |
| 7 | Verification | Small | Task 6 |

**Total commits:** 7
**Estimated effort:** 1-2 days
