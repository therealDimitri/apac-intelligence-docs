# Sales Hub Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform the Sales Hub from a product catalogue into a client-first command centre with AI companion, unified News Intelligence, and Vercel/Stripe visual aesthetic.

**Architecture:** Two-column adaptive layout with client selector as primary navigation, persistent AI companion panel, and contextual content that transforms based on selected client. Glass-morphism effects, gradient accents, and responsive down to mobile with gesture support.

**Tech Stack:** Next.js 16, React 19, Tailwind CSS 4, Radix UI, Zustand, Lucide React icons, existing Supabase backend.

**Design Doc:** `docs/plans/2026-02-01-sales-hub-redesign.md`

---

## Phase 1: Foundation & Layout

### Task 1.1: Create Zustand Stores

**Files:**
- Create: `src/stores/sales-hub-store.ts`
- Create: `src/stores/ai-companion-store.ts`

**Step 1: Create sales-hub-store**

```typescript
// src/stores/sales-hub-store.ts
import { create } from 'zustand'

interface Client {
  id: number
  name: string
  health_score: number | null
  health_status: 'healthy' | 'at-risk' | 'critical' | null
  arr: number | null
  region: string | null
  last_meeting_date: string | null
  current_products: string[]
}

interface SalesHubState {
  // Client selection
  selectedClient: Client | null
  setSelectedClient: (client: Client | null) => void

  // View mode
  viewMode: 'dashboard' | 'client-context'
  setViewMode: (mode: 'dashboard' | 'client-context') => void

  // Item selection for bulk actions
  selectedItems: Set<string>
  toggleItemSelection: (id: string) => void
  selectAllItems: (ids: string[]) => void
  clearSelection: () => void

  // Filters
  filters: {
    region: string | null
    productFamily: string | null
    contentType: string | null
    search: string
  }
  setFilter: (key: keyof SalesHubState['filters'], value: string | null) => void
  clearFilters: () => void

  // Recent & saved
  recentClients: Client[]
  addRecentClient: (client: Client) => void
  savedItems: string[]
  toggleSavedItem: (id: string) => void
}

export const useSalesHubStore = create<SalesHubState>((set, get) => ({
  // Client selection
  selectedClient: null,
  setSelectedClient: (client) => {
    set({ selectedClient: client, viewMode: client ? 'client-context' : 'dashboard' })
    if (client) {
      get().addRecentClient(client)
    }
  },

  // View mode
  viewMode: 'dashboard',
  setViewMode: (mode) => set({ viewMode: mode }),

  // Item selection
  selectedItems: new Set(),
  toggleItemSelection: (id) => set((state) => {
    const newSet = new Set(state.selectedItems)
    if (newSet.has(id)) {
      newSet.delete(id)
    } else {
      newSet.add(id)
    }
    return { selectedItems: newSet }
  }),
  selectAllItems: (ids) => set({ selectedItems: new Set(ids) }),
  clearSelection: () => set({ selectedItems: new Set() }),

  // Filters
  filters: {
    region: null,
    productFamily: null,
    contentType: null,
    search: '',
  },
  setFilter: (key, value) => set((state) => ({
    filters: { ...state.filters, [key]: value }
  })),
  clearFilters: () => set({
    filters: { region: null, productFamily: null, contentType: null, search: '' }
  }),

  // Recent & saved
  recentClients: [],
  addRecentClient: (client) => set((state) => {
    const filtered = state.recentClients.filter(c => c.id !== client.id)
    return { recentClients: [client, ...filtered].slice(0, 5) }
  }),
  savedItems: [],
  toggleSavedItem: (id) => set((state) => ({
    savedItems: state.savedItems.includes(id)
      ? state.savedItems.filter(i => i !== id)
      : [...state.savedItems, id]
  })),
}))
```

**Step 2: Create ai-companion-store**

```typescript
// src/stores/ai-companion-store.ts
import { create } from 'zustand'

interface Suggestion {
  id: string
  type: 'action' | 'insight' | 'recommendation'
  title: string
  description: string
  action?: {
    label: string
    href?: string
    onClick?: () => void
  }
  priority: 'high' | 'medium' | 'low'
  createdAt: Date
}

interface ChatMessage {
  id: string
  role: 'user' | 'assistant'
  content: string
  timestamp: Date
}

interface AICompanionState {
  // Panel state
  isExpanded: boolean
  setExpanded: (expanded: boolean) => void
  toggleExpanded: () => void

  // Suggestions
  suggestions: Suggestion[]
  setSuggestions: (suggestions: Suggestion[]) => void
  dismissSuggestion: (id: string) => void

  // Chat
  chatHistory: ChatMessage[]
  addMessage: (message: Omit<ChatMessage, 'id' | 'timestamp'>) => void
  clearChat: () => void

  // Loading states
  isLoadingSuggestions: boolean
  setLoadingSuggestions: (loading: boolean) => void
  isTyping: boolean
  setTyping: (typing: boolean) => void
}

export const useAICompanionStore = create<AICompanionState>((set) => ({
  // Panel state
  isExpanded: true,
  setExpanded: (expanded) => set({ isExpanded: expanded }),
  toggleExpanded: () => set((state) => ({ isExpanded: !state.isExpanded })),

  // Suggestions
  suggestions: [],
  setSuggestions: (suggestions) => set({ suggestions }),
  dismissSuggestion: (id) => set((state) => ({
    suggestions: state.suggestions.filter(s => s.id !== id)
  })),

  // Chat
  chatHistory: [],
  addMessage: (message) => set((state) => ({
    chatHistory: [
      ...state.chatHistory,
      { ...message, id: crypto.randomUUID(), timestamp: new Date() }
    ]
  })),
  clearChat: () => set({ chatHistory: [] }),

  // Loading states
  isLoadingSuggestions: false,
  setLoadingSuggestions: (loading) => set({ isLoadingSuggestions: loading }),
  isTyping: false,
  setTyping: (typing) => set({ isTyping: typing }),
}))
```

**Step 3: Verify TypeScript compiles**

Run: `npx tsc --noEmit src/stores/sales-hub-store.ts src/stores/ai-companion-store.ts`
Expected: No errors

**Step 4: Commit**

```bash
git add src/stores/sales-hub-store.ts src/stores/ai-companion-store.ts
git commit -m "feat(sales-hub): add Zustand stores for state management"
```

---

### Task 1.2: Create Glass-Morphism UI Components

**Files:**
- Create: `src/components/ui/glass-panel.tsx`
- Create: `src/components/ui/match-score-ring.tsx`

**Step 1: Create GlassPanel component**

```tsx
// src/components/ui/glass-panel.tsx
import { cn } from '@/lib/utils'
import { forwardRef, HTMLAttributes } from 'react'

interface GlassPanelProps extends HTMLAttributes<HTMLDivElement> {
  variant?: 'default' | 'strong' | 'subtle'
  blur?: 'sm' | 'md' | 'lg' | 'xl'
}

const GlassPanel = forwardRef<HTMLDivElement, GlassPanelProps>(
  ({ className, variant = 'default', blur = 'lg', children, ...props }, ref) => {
    const blurValues = {
      sm: 'backdrop-blur-sm',
      md: 'backdrop-blur-md',
      lg: 'backdrop-blur-lg',
      xl: 'backdrop-blur-xl',
    }

    const variantStyles = {
      default: 'bg-white/70 border border-white/20 shadow-[0_8px_32px_rgba(0,0,0,0.08)]',
      strong: 'bg-white/85 border border-white/30 shadow-[0_8px_32px_rgba(0,0,0,0.12)]',
      subtle: 'bg-white/50 border border-white/10 shadow-[0_4px_16px_rgba(0,0,0,0.05)]',
    }

    return (
      <div
        ref={ref}
        className={cn(
          'rounded-2xl',
          blurValues[blur],
          variantStyles[variant],
          className
        )}
        {...props}
      >
        {children}
      </div>
    )
  }
)

GlassPanel.displayName = 'GlassPanel'

export { GlassPanel }
```

**Step 2: Create MatchScoreRing component**

```tsx
// src/components/ui/match-score-ring.tsx
'use client'

import { cn } from '@/lib/utils'
import { useEffect, useState } from 'react'

interface MatchScoreRingProps {
  score: number // 0-100
  size?: 'sm' | 'md' | 'lg'
  showLabel?: boolean
  animated?: boolean
  className?: string
}

export function MatchScoreRing({
  score,
  size = 'md',
  showLabel = true,
  animated = true,
  className,
}: MatchScoreRingProps) {
  const [animatedScore, setAnimatedScore] = useState(animated ? 0 : score)

  useEffect(() => {
    if (!animated) {
      setAnimatedScore(score)
      return
    }

    const timer = setTimeout(() => {
      setAnimatedScore(score)
    }, 100)

    return () => clearTimeout(timer)
  }, [score, animated])

  const sizeConfig = {
    sm: { size: 32, stroke: 3, fontSize: 'text-[10px]' },
    md: { size: 48, stroke: 4, fontSize: 'text-xs' },
    lg: { size: 64, stroke: 5, fontSize: 'text-sm' },
  }

  const config = sizeConfig[size]
  const radius = (config.size - config.stroke) / 2
  const circumference = 2 * Math.PI * radius
  const strokeDashoffset = circumference - (animatedScore / 100) * circumference

  // Gradient colours based on score
  const getGradientId = () => `score-gradient-${score}-${size}`
  const startColour = score >= 70 ? '#7C3AED' : score >= 40 ? '#F59E0B' : '#EF4444'
  const endColour = score >= 70 ? '#10B981' : score >= 40 ? '#7C3AED' : '#F59E0B'

  return (
    <div className={cn('relative inline-flex items-center justify-center', className)}>
      <svg
        width={config.size}
        height={config.size}
        className="transform -rotate-90"
      >
        <defs>
          <linearGradient id={getGradientId()} x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stopColor={startColour} />
            <stop offset="100%" stopColor={endColour} />
          </linearGradient>
        </defs>
        {/* Background circle */}
        <circle
          cx={config.size / 2}
          cy={config.size / 2}
          r={radius}
          fill="none"
          stroke="currentColor"
          strokeWidth={config.stroke}
          className="text-gray-200"
        />
        {/* Progress circle */}
        <circle
          cx={config.size / 2}
          cy={config.size / 2}
          r={radius}
          fill="none"
          stroke={`url(#${getGradientId()})`}
          strokeWidth={config.stroke}
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={strokeDashoffset}
          className={cn(
            animated && 'transition-[stroke-dashoffset] duration-700 ease-out'
          )}
        />
      </svg>
      {showLabel && (
        <span
          className={cn(
            'absolute font-semibold text-gray-900',
            config.fontSize
          )}
        >
          {Math.round(animatedScore)}
        </span>
      )}
    </div>
  )
}
```

**Step 3: Verify components compile**

Run: `npx tsc --noEmit src/components/ui/glass-panel.tsx src/components/ui/match-score-ring.tsx`
Expected: No errors

**Step 4: Commit**

```bash
git add src/components/ui/glass-panel.tsx src/components/ui/match-score-ring.tsx
git commit -m "feat(ui): add GlassPanel and MatchScoreRing components"
```

---

### Task 1.3: Create Client Selector Component

**Files:**
- Create: `src/components/sales-hub/ClientSelector.tsx`
- Reference: `src/hooks/useClients.ts` (existing)

**Step 1: Create ClientSelector component**

```tsx
// src/components/sales-hub/ClientSelector.tsx
'use client'

import { useState, useRef, useEffect } from 'react'
import { useClients } from '@/hooks/useClients'
import { useSalesHubStore } from '@/stores/sales-hub-store'
import { GlassPanel } from '@/components/ui/glass-panel'
import {
  Search,
  Building2,
  ChevronDown,
  Clock,
  Calendar,
  AlertTriangle,
  Users,
  X,
  ArrowLeft,
} from 'lucide-react'
import { cn } from '@/lib/utils'

interface ClientSelectorProps {
  className?: string
}

export function ClientSelector({ className }: ClientSelectorProps) {
  const [isOpen, setIsOpen] = useState(false)
  const [search, setSearch] = useState('')
  const inputRef = useRef<HTMLInputElement>(null)
  const panelRef = useRef<HTMLDivElement>(null)

  const { clients, isLoading } = useClients()
  const {
    selectedClient,
    setSelectedClient,
    recentClients,
  } = useSalesHubStore()

  // Close on outside click
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (panelRef.current && !panelRef.current.contains(event.target as Node)) {
        setIsOpen(false)
      }
    }
    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  // Keyboard shortcut (Cmd+K)
  useEffect(() => {
    function handleKeyDown(event: KeyboardEvent) {
      if ((event.metaKey || event.ctrlKey) && event.key === 'k') {
        event.preventDefault()
        setIsOpen(true)
        setTimeout(() => inputRef.current?.focus(), 100)
      }
      if (event.key === 'Escape') {
        setIsOpen(false)
      }
    }
    document.addEventListener('keydown', handleKeyDown)
    return () => document.removeEventListener('keydown', handleKeyDown)
  }, [])

  // Filter clients
  const filteredClients = clients?.filter(client =>
    client.client_name?.toLowerCase().includes(search.toLowerCase())
  ) ?? []

  // Group clients
  const upcomingMeetings = filteredClients.slice(0, 3) // TODO: filter by actual meetings
  const needsAttention = filteredClients.filter(c =>
    c.health_status === 'at-risk' || c.health_status === 'critical'
  ).slice(0, 5)

  const getHealthColour = (status: string | null) => {
    switch (status) {
      case 'healthy': return 'bg-emerald-500'
      case 'at-risk': return 'bg-amber-500'
      case 'critical': return 'bg-red-500'
      default: return 'bg-gray-400'
    }
  }

  const formatCurrency = (value: number | null) => {
    if (!value) return '—'
    return new Intl.NumberFormat('en-AU', {
      style: 'currency',
      currency: 'AUD',
      notation: 'compact',
      maximumFractionDigits: 1,
    }).format(value)
  }

  const handleSelect = (client: typeof clients[0]) => {
    setSelectedClient({
      id: client.id,
      name: client.client_name || '',
      health_score: client.health_score,
      health_status: client.health_status as 'healthy' | 'at-risk' | 'critical' | null,
      arr: client.total_arr,
      region: client.region,
      last_meeting_date: null, // TODO: get from meetings
      current_products: [], // TODO: get from client products
    })
    setIsOpen(false)
    setSearch('')
  }

  // Selected client view
  if (selectedClient) {
    return (
      <div className={cn('flex items-center gap-3', className)}>
        <button
          onClick={() => setSelectedClient(null)}
          className="flex items-center gap-1 text-sm text-gray-500 hover:text-gray-700 transition-colors"
        >
          <ArrowLeft className="h-4 w-4" />
          Back
        </button>
        <button
          onClick={() => setIsOpen(true)}
          className="flex items-center gap-2 px-3 py-2 rounded-lg bg-gray-50 hover:bg-gray-100 transition-colors"
        >
          <Building2 className="h-4 w-4 text-gray-500" />
          <span className="font-medium text-gray-900">{selectedClient.name}</span>
          <ChevronDown className="h-4 w-4 text-gray-400" />
        </button>
        <div className="flex items-center gap-3 text-sm">
          <span className="flex items-center gap-1.5">
            <span className={cn('h-2 w-2 rounded-full', getHealthColour(selectedClient.health_status))} />
            <span className="text-gray-600">{selectedClient.health_score ?? '—'}</span>
          </span>
          <span className="text-gray-400">|</span>
          <span className="text-gray-600">{formatCurrency(selectedClient.arr)}</span>
          <span className="text-gray-400">|</span>
          <span className="text-gray-500">{selectedClient.region ?? '—'}</span>
        </div>
      </div>
    )
  }

  // Dropdown selector view
  return (
    <div className={cn('relative', className)} ref={panelRef}>
      <button
        onClick={() => {
          setIsOpen(!isOpen)
          if (!isOpen) setTimeout(() => inputRef.current?.focus(), 100)
        }}
        className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-gray-50 hover:bg-gray-100 border border-gray-200 transition-all w-full max-w-md"
      >
        <Search className="h-4 w-4 text-gray-400" />
        <span className="text-gray-500 text-sm flex-1 text-left">
          Search clients, products, or ask AI...
        </span>
        <kbd className="hidden sm:inline-flex items-center gap-0.5 px-1.5 py-0.5 rounded bg-gray-200 text-[10px] text-gray-500 font-medium">
          ⌘K
        </kbd>
      </button>

      {isOpen && (
        <GlassPanel
          variant="strong"
          blur="xl"
          className="absolute top-full left-0 right-0 mt-2 z-50 max-h-[70vh] overflow-hidden flex flex-col"
        >
          {/* Search input */}
          <div className="p-3 border-b border-gray-100">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
              <input
                ref={inputRef}
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Search clients..."
                className="w-full pl-10 pr-10 py-2 rounded-lg bg-gray-50 border border-gray-200 text-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
              />
              {search && (
                <button
                  onClick={() => setSearch('')}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                >
                  <X className="h-4 w-4" />
                </button>
              )}
            </div>
          </div>

          {/* Client sections */}
          <div className="flex-1 overflow-y-auto">
            {/* Recent clients */}
            {recentClients.length > 0 && !search && (
              <div className="p-3 border-b border-gray-100">
                <div className="flex items-center gap-2 text-xs font-medium text-gray-500 mb-2">
                  <Clock className="h-3.5 w-3.5" />
                  Recent
                </div>
                <div className="space-y-1">
                  {recentClients.map((client) => (
                    <ClientRow
                      key={client.id}
                      client={client}
                      onSelect={() => handleSelect(client as any)}
                      getHealthColour={getHealthColour}
                      formatCurrency={formatCurrency}
                    />
                  ))}
                </div>
              </div>
            )}

            {/* Needs attention */}
            {needsAttention.length > 0 && !search && (
              <div className="p-3 border-b border-gray-100">
                <div className="flex items-center gap-2 text-xs font-medium text-gray-500 mb-2">
                  <AlertTriangle className="h-3.5 w-3.5 text-amber-500" />
                  Needs Attention
                </div>
                <div className="space-y-1">
                  {needsAttention.map((client) => (
                    <ClientRow
                      key={client.id}
                      client={client}
                      onSelect={() => handleSelect(client)}
                      getHealthColour={getHealthColour}
                      formatCurrency={formatCurrency}
                    />
                  ))}
                </div>
              </div>
            )}

            {/* All/filtered clients */}
            <div className="p-3">
              <div className="flex items-center gap-2 text-xs font-medium text-gray-500 mb-2">
                <Users className="h-3.5 w-3.5" />
                {search ? `Results (${filteredClients.length})` : 'All Clients'}
              </div>
              <div className="space-y-1 max-h-64 overflow-y-auto">
                {isLoading ? (
                  <div className="text-sm text-gray-500 py-4 text-center">Loading...</div>
                ) : filteredClients.length === 0 ? (
                  <div className="text-sm text-gray-500 py-4 text-center">No clients found</div>
                ) : (
                  filteredClients.slice(0, 20).map((client) => (
                    <ClientRow
                      key={client.id}
                      client={client}
                      onSelect={() => handleSelect(client)}
                      getHealthColour={getHealthColour}
                      formatCurrency={formatCurrency}
                    />
                  ))
                )}
              </div>
            </div>
          </div>
        </GlassPanel>
      )}
    </div>
  )
}

// Client row subcomponent
function ClientRow({
  client,
  onSelect,
  getHealthColour,
  formatCurrency,
}: {
  client: any
  onSelect: () => void
  getHealthColour: (status: string | null) => string
  formatCurrency: (value: number | null) => string
}) {
  return (
    <button
      onClick={onSelect}
      className="w-full flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-purple-50 transition-colors text-left group"
    >
      <Building2 className="h-4 w-4 text-gray-400 group-hover:text-purple-500" />
      <div className="flex-1 min-w-0">
        <div className="font-medium text-sm text-gray-900 truncate">
          {client.client_name || client.name}
        </div>
        <div className="text-xs text-gray-500">
          {client.region ?? '—'}
        </div>
      </div>
      <div className="flex items-center gap-2 text-xs">
        <span className={cn('h-2 w-2 rounded-full', getHealthColour(client.health_status))} />
        <span className="text-gray-600">{formatCurrency(client.total_arr ?? client.arr)}</span>
      </div>
    </button>
  )
}
```

**Step 2: Verify component compiles**

Run: `npx tsc --noEmit src/components/sales-hub/ClientSelector.tsx`
Expected: No errors

**Step 3: Commit**

```bash
git add src/components/sales-hub/ClientSelector.tsx
git commit -m "feat(sales-hub): add ClientSelector component with search and sections"
```

---

### Task 1.4: Create Main Page Layout Shell

**Files:**
- Backup: `src/app/(dashboard)/sales-hub/page.tsx` → `src/app/(dashboard)/sales-hub/page.old.tsx`
- Create: `src/app/(dashboard)/sales-hub/page.tsx` (new)

**Step 1: Backup existing page**

```bash
cp src/app/(dashboard)/sales-hub/page.tsx src/app/(dashboard)/sales-hub/page.old.tsx
```

**Step 2: Create new page shell**

```tsx
// src/app/(dashboard)/sales-hub/page.tsx
'use client'

import { Store, Settings, SlidersHorizontal } from 'lucide-react'
import { ClientSelector } from '@/components/sales-hub/ClientSelector'
import { useSalesHubStore } from '@/stores/sales-hub-store'
import { useAICompanionStore } from '@/stores/ai-companion-store'
import { GlassPanel } from '@/components/ui/glass-panel'
import { cn } from '@/lib/utils'

export default function SalesHubPage() {
  const { selectedClient, viewMode } = useSalesHubStore()
  const { isExpanded, toggleExpanded } = useAICompanionStore()

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="sticky top-0 z-40 bg-white/95 backdrop-blur-sm border-b border-gray-200">
        <div className="px-6 py-4">
          <div className="flex items-center justify-between gap-4">
            {/* Left: Title or Client Selector */}
            <div className="flex items-center gap-4 flex-1">
              {!selectedClient && (
                <div className="flex items-center gap-3">
                  <div className="p-2 rounded-xl bg-gradient-to-br from-purple-100 to-violet-100">
                    <Store className="h-5 w-5 text-purple-600" />
                  </div>
                  <div>
                    <h1 className="text-xl font-semibold text-gray-900 tracking-tight">
                      Sales Hub
                    </h1>
                    <p className="text-sm text-gray-500">
                      Product collateral, bundles, and AI recommendations
                    </p>
                  </div>
                </div>
              )}
              <ClientSelector className={cn(selectedClient ? 'flex-1' : 'ml-auto max-w-md')} />
            </div>

            {/* Right: Actions */}
            <div className="flex items-center gap-2">
              <button className="p-2 rounded-lg hover:bg-gray-100 text-gray-500 transition-colors">
                <SlidersHorizontal className="h-5 w-5" />
              </button>
              <button className="p-2 rounded-lg hover:bg-gray-100 text-gray-500 transition-colors">
                <Settings className="h-5 w-5" />
              </button>
              {selectedClient && (
                <button className="px-4 py-2 rounded-lg bg-gradient-to-r from-purple-600 to-violet-500 text-white text-sm font-medium hover:opacity-90 transition-opacity">
                  + Add to Plan
                </button>
              )}
            </div>
          </div>
        </div>
      </header>

      {/* Main content area */}
      <div className="flex">
        {/* Main content */}
        <main className={cn(
          'flex-1 p-6 transition-all duration-300',
          isExpanded ? 'mr-80' : 'mr-0'
        )}>
          {viewMode === 'dashboard' ? (
            <DashboardView />
          ) : (
            <ClientContextView />
          )}
        </main>

        {/* AI Companion Panel */}
        <aside
          className={cn(
            'fixed right-0 top-[73px] bottom-0 w-80 transition-transform duration-300 z-30',
            isExpanded ? 'translate-x-0' : 'translate-x-full'
          )}
        >
          <GlassPanel
            variant="default"
            blur="xl"
            className="h-full rounded-none rounded-l-2xl border-l border-gray-200 p-4"
          >
            <AICompanionPlaceholder />
          </GlassPanel>
        </aside>

        {/* AI toggle button (when collapsed) */}
        {!isExpanded && (
          <button
            onClick={toggleExpanded}
            className="fixed right-4 bottom-4 p-3 rounded-full bg-gradient-to-r from-purple-600 to-violet-500 text-white shadow-lg hover:shadow-xl transition-shadow z-40"
          >
            <span className="sr-only">Open AI Assistant</span>
            ✨
          </button>
        )}
      </div>

      {/* Action Bar (sticky bottom) */}
      <ActionBarPlaceholder />
    </div>
  )
}

// Placeholder components - will be implemented in later tasks
function DashboardView() {
  return (
    <div className="space-y-8">
      <div className="bg-white rounded-xl border border-gray-200 p-8 text-center">
        <p className="text-gray-500">Dashboard View - Coming in Phase 2</p>
        <p className="text-sm text-gray-400 mt-2">
          Top opportunities, trending products, industry news
        </p>
      </div>
    </div>
  )
}

function ClientContextView() {
  const { selectedClient } = useSalesHubStore()
  return (
    <div className="space-y-8">
      <div className="bg-white rounded-xl border border-gray-200 p-8 text-center">
        <p className="text-gray-500">Client Context View - Coming in Phase 2</p>
        <p className="text-sm text-gray-400 mt-2">
          Showing context for: {selectedClient?.name}
        </p>
      </div>
    </div>
  )
}

function AICompanionPlaceholder() {
  const { toggleExpanded } = useAICompanionStore()
  return (
    <div className="h-full flex flex-col">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <span className="text-lg">✨</span>
          <span className="font-semibold text-gray-900">ChaSen AI</span>
        </div>
        <button
          onClick={toggleExpanded}
          className="p-1 rounded hover:bg-gray-100 text-gray-400"
        >
          ✕
        </button>
      </div>
      <div className="flex-1 flex items-center justify-center">
        <p className="text-sm text-gray-400">AI Companion - Coming in Phase 4</p>
      </div>
    </div>
  )
}

function ActionBarPlaceholder() {
  return (
    <div className="fixed bottom-0 left-0 right-0 h-16 bg-white/85 backdrop-blur-xl border-t border-gray-200 z-30 flex items-center justify-center">
      <p className="text-sm text-gray-400">Action Bar - Coming in Phase 3</p>
    </div>
  )
}
```

**Step 3: Verify build passes**

Run: `npm run build 2>&1 | tail -5`
Expected: Build succeeds

**Step 4: Commit**

```bash
git add src/app/(dashboard)/sales-hub/page.tsx src/app/(dashboard)/sales-hub/page.old.tsx
git commit -m "feat(sales-hub): create new page layout shell with two-column structure"
```

---

## Phase 2: Client Context & Dashboard Views

### Task 2.1: Create Client Snapshot Bar

**Files:**
- Create: `src/components/sales-hub/ClientSnapshotBar.tsx`

**Step 1: Create component**

```tsx
// src/components/sales-hub/ClientSnapshotBar.tsx
'use client'

import { useSalesHubStore } from '@/stores/sales-hub-store'
import {
  Activity,
  TrendingUp,
  DollarSign,
  Calendar,
  ChevronRight,
} from 'lucide-react'
import { cn } from '@/lib/utils'

interface ClientSnapshotBarProps {
  npsScore?: number
  npsTrend?: number
  lastMeetingDays?: number
  currentProducts?: string[]
  className?: string
}

export function ClientSnapshotBar({
  npsScore,
  npsTrend,
  lastMeetingDays,
  currentProducts = [],
  className,
}: ClientSnapshotBarProps) {
  const { selectedClient } = useSalesHubStore()

  if (!selectedClient) return null

  const getHealthGradient = (status: string | null) => {
    switch (status) {
      case 'healthy': return 'from-emerald-50 to-emerald-100 border-emerald-200'
      case 'at-risk': return 'from-amber-50 to-amber-100 border-amber-200'
      case 'critical': return 'from-red-50 to-red-100 border-red-200'
      default: return 'from-gray-50 to-gray-100 border-gray-200'
    }
  }

  const formatCurrency = (value: number | null) => {
    if (!value) return '—'
    return new Intl.NumberFormat('en-AU', {
      style: 'currency',
      currency: 'AUD',
      notation: 'compact',
      maximumFractionDigits: 1,
    }).format(value)
  }

  const productFamilyColours: Record<string, string> = {
    'Sunrise': 'bg-purple-100 text-purple-700',
    'dbMotion': 'bg-blue-100 text-blue-700',
    'Opal': 'bg-teal-100 text-teal-700',
    'Paragon': 'bg-orange-100 text-orange-700',
    'TouchWorks': 'bg-pink-100 text-pink-700',
  }

  const getProductColour = (product: string) => {
    for (const [family, colour] of Object.entries(productFamilyColours)) {
      if (product.toLowerCase().includes(family.toLowerCase())) {
        return colour
      }
    }
    return 'bg-gray-100 text-gray-700'
  }

  return (
    <div className={cn('bg-white rounded-xl border border-gray-200 p-4', className)}>
      {/* Metric cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-4">
        {/* Health Score */}
        <div className={cn(
          'rounded-lg border p-3 bg-gradient-to-br',
          getHealthGradient(selectedClient.health_status)
        )}>
          <div className="flex items-center gap-2 text-xs text-gray-500 mb-1">
            <Activity className="h-3.5 w-3.5" />
            Health Score
          </div>
          <div className="flex items-baseline gap-1">
            <span className="text-2xl font-bold text-gray-900">
              {selectedClient.health_score ?? '—'}
            </span>
            <span className="text-xs text-gray-500">/100</span>
          </div>
        </div>

        {/* NPS */}
        <div className="rounded-lg border border-gray-200 p-3 bg-gradient-to-br from-gray-50 to-gray-100">
          <div className="flex items-center gap-2 text-xs text-gray-500 mb-1">
            <TrendingUp className="h-3.5 w-3.5" />
            NPS Trend
          </div>
          <div className="flex items-baseline gap-2">
            <span className="text-2xl font-bold text-gray-900">
              {npsScore ?? '—'}
            </span>
            {npsTrend !== undefined && (
              <span className={cn(
                'text-xs font-medium',
                npsTrend > 0 ? 'text-emerald-600' : npsTrend < 0 ? 'text-red-600' : 'text-gray-500'
              )}>
                {npsTrend > 0 ? '+' : ''}{npsTrend}
              </span>
            )}
          </div>
        </div>

        {/* ARR */}
        <div className="rounded-lg border border-gray-200 p-3 bg-gradient-to-br from-gray-50 to-gray-100">
          <div className="flex items-center gap-2 text-xs text-gray-500 mb-1">
            <DollarSign className="h-3.5 w-3.5" />
            ARR Value
          </div>
          <div className="text-2xl font-bold text-gray-900">
            {formatCurrency(selectedClient.arr)}
          </div>
        </div>

        {/* Last Meeting */}
        <div className="rounded-lg border border-gray-200 p-3 bg-gradient-to-br from-gray-50 to-gray-100">
          <div className="flex items-center gap-2 text-xs text-gray-500 mb-1">
            <Calendar className="h-3.5 w-3.5" />
            Last Meeting
          </div>
          <div className="text-2xl font-bold text-gray-900">
            {lastMeetingDays !== undefined ? `${lastMeetingDays}d` : '—'}
          </div>
        </div>
      </div>

      {/* Current Stack */}
      {currentProducts.length > 0 && (
        <div className="flex items-center gap-2 flex-wrap">
          <span className="text-xs text-gray-500">Current Stack:</span>
          {currentProducts.slice(0, 4).map((product) => (
            <span
              key={product}
              className={cn(
                'px-2 py-0.5 rounded-md text-xs font-medium',
                getProductColour(product)
              )}
            >
              {product}
            </span>
          ))}
          {currentProducts.length > 4 && (
            <button className="flex items-center gap-1 text-xs text-purple-600 hover:text-purple-700">
              +{currentProducts.length - 4} more
              <ChevronRight className="h-3 w-3" />
            </button>
          )}
        </div>
      )}
    </div>
  )
}
```

**Step 2: Verify component compiles**

Run: `npx tsc --noEmit src/components/sales-hub/ClientSnapshotBar.tsx`
Expected: No errors

**Step 3: Commit**

```bash
git add src/components/sales-hub/ClientSnapshotBar.tsx
git commit -m "feat(sales-hub): add ClientSnapshotBar with health, NPS, ARR, and stack"
```

---

### Task 2.2: Create ProductCardV2 Component

**Files:**
- Create: `src/components/sales-hub/ProductCardV2.tsx`
- Reference: Product logos at `~/Library/CloudStorage/OneDrive-AlteraDigitalHealth/Marketing - Altera Templates & Tools/BU Logos/`

**Step 1: Copy product logos to public folder**

```bash
mkdir -p public/images/product-logos
cp ~/Library/CloudStorage/OneDrive-AlteraDigitalHealth/Marketing\ -\ Altera\ Templates\ \&\ Tools/BU\ Logos/Altera-App-Icon_Sun.svg public/images/product-logos/sunrise.svg
cp ~/Library/CloudStorage/OneDrive-AlteraDigitalHealth/Marketing\ -\ Altera\ Templates\ \&\ Tools/BU\ Logos/Altera-App-Icon_dbM.svg public/images/product-logos/dbmotion.svg
cp ~/Library/CloudStorage/OneDrive-AlteraDigitalHealth/Marketing\ -\ Altera\ Templates\ \&\ Tools/BU\ Logos/Altera-App-Icon_Opal.svg public/images/product-logos/opal.svg
cp ~/Library/CloudStorage/OneDrive-AlteraDigitalHealth/Marketing\ -\ Altera\ Templates\ \&\ Tools/BU\ Logos/Altera-App-Icon_Par-1.svg public/images/product-logos/paragon.svg
cp ~/Library/CloudStorage/OneDrive-AlteraDigitalHealth/Marketing\ -\ Altera\ Templates\ \&\ Tools/BU\ Logos/Altera-App-Icon_TW.svg public/images/product-logos/touchworks.svg
cp ~/Library/CloudStorage/OneDrive-AlteraDigitalHealth/Marketing\ -\ Altera\ Templates\ \&\ Tools/BU\ Logos/Altera-App-Icon_CD.svg public/images/product-logos/clinical-docs.svg
```

**Step 2: Create ProductCardV2 component**

```tsx
// src/components/sales-hub/ProductCardV2.tsx
'use client'

import Image from 'next/image'
import { useState } from 'react'
import { MatchScoreRing } from '@/components/ui/match-score-ring'
import { useSalesHubStore } from '@/stores/sales-hub-store'
import {
  Target,
  Globe,
  ChevronDown,
  ChevronUp,
  Plus,
  Bookmark,
  MessageSquare,
  FileText,
  Zap,
} from 'lucide-react'
import { cn } from '@/lib/utils'

interface Evidence {
  type: 'meeting' | 'nps' | 'stack-gap' | 'news' | 'stakeholder'
  label: string
}

interface ProductCardV2Props {
  id: string
  name: string
  family: string
  description: string
  regions: string[]
  matchScore?: number
  evidence?: Evidence[]
  contentType?: string
  onSelect?: () => void
  onAddToPlan?: () => void
  className?: string
}

const familyLogos: Record<string, string> = {
  'Sunrise': '/images/product-logos/sunrise.svg',
  'dbMotion': '/images/product-logos/dbmotion.svg',
  'Opal': '/images/product-logos/opal.svg',
  'Paragon': '/images/product-logos/paragon.svg',
  'TouchWorks': '/images/product-logos/touchworks.svg',
  'Clinical Documentation': '/images/product-logos/clinical-docs.svg',
}

const familyColours: Record<string, { bg: string; text: string; border: string }> = {
  'Sunrise': { bg: 'bg-purple-50', text: 'text-purple-700', border: 'border-purple-200' },
  'dbMotion': { bg: 'bg-blue-50', text: 'text-blue-700', border: 'border-blue-200' },
  'Opal': { bg: 'bg-teal-50', text: 'text-teal-700', border: 'border-teal-200' },
  'Paragon': { bg: 'bg-orange-50', text: 'text-orange-700', border: 'border-orange-200' },
  'TouchWorks': { bg: 'bg-pink-50', text: 'text-pink-700', border: 'border-pink-200' },
  'Clinical Documentation': { bg: 'bg-gray-50', text: 'text-gray-700', border: 'border-gray-200' },
}

const evidenceIcons: Record<string, typeof MessageSquare> = {
  'meeting': MessageSquare,
  'nps': FileText,
  'stack-gap': Zap,
  'news': Globe,
  'stakeholder': Target,
}

export function ProductCardV2({
  id,
  name,
  family,
  description,
  regions,
  matchScore,
  evidence = [],
  contentType,
  onSelect,
  onAddToPlan,
  className,
}: ProductCardV2Props) {
  const [isExpanded, setIsExpanded] = useState(false)
  const [isHovered, setIsHovered] = useState(false)
  const { selectedItems, toggleItemSelection, savedItems, toggleSavedItem } = useSalesHubStore()

  const isSelected = selectedItems.has(id)
  const isSaved = savedItems.includes(id)

  const logo = familyLogos[family] || familyLogos['Sunrise']
  const colours = familyColours[family] || familyColours['Sunrise']

  return (
    <div
      className={cn(
        'group relative bg-white rounded-xl border transition-all duration-200',
        isSelected
          ? 'border-purple-300 ring-2 ring-purple-500/30 shadow-md'
          : 'border-gray-200 hover:border-gray-300 hover:shadow-md',
        isHovered && !isSelected && 'shadow-[0_0_20px_rgba(124,58,237,0.1)]',
        className
      )}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      {/* Selection checkbox (visible on hover) */}
      <div
        className={cn(
          'absolute top-3 left-3 transition-opacity',
          isHovered || isSelected ? 'opacity-100' : 'opacity-0'
        )}
      >
        <button
          onClick={() => toggleItemSelection(id)}
          className={cn(
            'h-5 w-5 rounded border-2 flex items-center justify-center transition-colors',
            isSelected
              ? 'bg-purple-600 border-purple-600 text-white'
              : 'bg-white border-gray-300 hover:border-purple-400'
          )}
        >
          {isSelected && <span className="text-xs">✓</span>}
        </button>
      </div>

      {/* Card content */}
      <div className="p-4">
        {/* Header with logo and title */}
        <div className="flex items-start gap-3 mb-3">
          <div className={cn('p-2 rounded-lg', colours.bg)}>
            <Image
              src={logo}
              alt={family}
              width={24}
              height={24}
              className="w-6 h-6"
            />
          </div>
          <div className="flex-1 min-w-0">
            <button
              onClick={onSelect}
              className="text-left w-full"
            >
              <h3 className="font-semibold text-gray-900 text-sm leading-tight hover:text-purple-600 transition-colors">
                {name}
              </h3>
            </button>
            <div className="flex items-center gap-2 mt-1">
              <span className={cn(
                'px-2 py-0.5 rounded text-xs font-medium',
                colours.bg, colours.text
              )}>
                {family}
              </span>
              {contentType && (
                <span className="px-2 py-0.5 rounded bg-gray-100 text-gray-600 text-xs">
                  {contentType}
                </span>
              )}
            </div>
          </div>
          {matchScore !== undefined && (
            <MatchScoreRing score={matchScore} size="sm" />
          )}
        </div>

        {/* Description */}
        <p className={cn(
          'text-sm text-gray-600 mb-3',
          !isExpanded && 'line-clamp-2'
        )}>
          {description}
        </p>

        {/* Evidence tags (only when client selected & has evidence) */}
        {evidence.length > 0 && (
          <div className="mb-3">
            <button
              onClick={() => setIsExpanded(!isExpanded)}
              className="flex items-center gap-1 text-xs text-purple-600 hover:text-purple-700 mb-2"
            >
              Why this?
              {isExpanded ? (
                <ChevronUp className="h-3 w-3" />
              ) : (
                <ChevronDown className="h-3 w-3" />
              )}
            </button>
            {isExpanded && (
              <div className="space-y-1.5 pl-2 border-l-2 border-purple-200">
                {evidence.map((ev, i) => {
                  const Icon = evidenceIcons[ev.type] || Target
                  return (
                    <div key={i} className="flex items-center gap-2 text-xs text-gray-600">
                      <Icon className="h-3 w-3 text-gray-400" />
                      {ev.label}
                    </div>
                  )
                })}
              </div>
            )}
          </div>
        )}

        {/* Regions */}
        <div className="flex items-center gap-1.5 mb-3">
          <Globe className="h-3.5 w-3.5 text-gray-400" />
          <div className="flex flex-wrap gap-1">
            {regions.slice(0, 3).map((region) => (
              <span
                key={region}
                className="text-xs text-gray-500"
              >
                {region}
              </span>
            ))}
            {regions.length > 3 && (
              <span className="text-xs text-gray-400">+{regions.length - 3}</span>
            )}
          </div>
        </div>

        {/* Actions */}
        <div className="flex items-center justify-between pt-3 border-t border-gray-100">
          <button
            onClick={() => toggleSavedItem(id)}
            className={cn(
              'p-1.5 rounded hover:bg-gray-100 transition-colors',
              isSaved ? 'text-purple-600' : 'text-gray-400'
            )}
          >
            <Bookmark className={cn('h-4 w-4', isSaved && 'fill-current')} />
          </button>
          <button
            onClick={onAddToPlan}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-gradient-to-r from-purple-600 to-violet-500 text-white text-xs font-medium hover:opacity-90 transition-opacity"
          >
            <Plus className="h-3.5 w-3.5" />
            Add to Plan
          </button>
        </div>
      </div>
    </div>
  )
}
```

**Step 3: Verify component compiles**

Run: `npx tsc --noEmit src/components/sales-hub/ProductCardV2.tsx`
Expected: No errors

**Step 4: Commit**

```bash
git add public/images/product-logos/ src/components/sales-hub/ProductCardV2.tsx
git commit -m "feat(sales-hub): add ProductCardV2 with logos, match scores, and evidence"
```

---

### Task 2.3: Create Dashboard View Components

**Files:**
- Create: `src/components/sales-hub/DashboardView.tsx`
- Create: `src/components/sales-hub/TopOpportunitiesSection.tsx`
- Create: `src/components/sales-hub/TrendingProductsSection.tsx`

**Step 1: Create TopOpportunitiesSection**

```tsx
// src/components/sales-hub/TopOpportunitiesSection.tsx
'use client'

import { useClients } from '@/hooks/useClients'
import { useSalesHubStore } from '@/stores/sales-hub-store'
import { MatchScoreRing } from '@/components/ui/match-score-ring'
import { Building2, ChevronRight, Target } from 'lucide-react'
import { cn } from '@/lib/utils'

export function TopOpportunitiesSection() {
  const { clients, isLoading } = useClients()
  const { setSelectedClient } = useSalesHubStore()

  // Mock: In reality, this would come from recommendations API
  const opportunities = clients
    ?.filter(c => c.health_status !== 'critical')
    .slice(0, 4)
    .map(c => ({
      ...c,
      matchScore: Math.floor(Math.random() * 30) + 70, // Mock score 70-100
      topProduct: ['Sunrise Thread AI', 'dbMotion HIE', 'Opal Assessment'][Math.floor(Math.random() * 3)],
    })) ?? []

  const getHealthColour = (status: string | null) => {
    switch (status) {
      case 'healthy': return 'bg-emerald-500'
      case 'at-risk': return 'bg-amber-500'
      case 'critical': return 'bg-red-500'
      default: return 'bg-gray-400'
    }
  }

  const handleSelect = (client: typeof opportunities[0]) => {
    setSelectedClient({
      id: client.id,
      name: client.client_name || '',
      health_score: client.health_score,
      health_status: client.health_status as any,
      arr: client.total_arr,
      region: client.region,
      last_meeting_date: null,
      current_products: [],
    })
  }

  if (isLoading) {
    return (
      <section>
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Target className="h-5 w-5 text-purple-600" />
            <h2 className="font-semibold text-gray-900">Top Opportunities</h2>
          </div>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="bg-gray-100 rounded-xl h-40 animate-pulse" />
          ))}
        </div>
      </section>
    )
  }

  return (
    <section>
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <Target className="h-5 w-5 text-purple-600" />
          <h2 className="font-semibold text-gray-900">Top Opportunities</h2>
        </div>
        <button className="flex items-center gap-1 text-sm text-purple-600 hover:text-purple-700">
          View all
          <ChevronRight className="h-4 w-4" />
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {opportunities.map((client) => (
          <button
            key={client.id}
            onClick={() => handleSelect(client)}
            className="group bg-white rounded-xl border border-gray-200 p-4 text-left hover:border-purple-300 hover:shadow-md transition-all"
          >
            <div className="flex items-start justify-between mb-3">
              <div className="flex items-center gap-2">
                <Building2 className="h-4 w-4 text-gray-400 group-hover:text-purple-500" />
                <span className={cn('h-2 w-2 rounded-full', getHealthColour(client.health_status))} />
              </div>
              <MatchScoreRing score={client.matchScore} size="sm" />
            </div>
            <h3 className="font-medium text-gray-900 mb-1 group-hover:text-purple-600 transition-colors">
              {client.client_name}
            </h3>
            <p className="text-xs text-gray-500 mb-3">
              {client.region ?? 'Unknown'} · ${((client.total_arr ?? 0) / 1000000).toFixed(1)}M ARR
            </p>
            <div className="text-xs text-purple-600 font-medium">
              Top: {client.topProduct}
            </div>
          </button>
        ))}
      </div>
    </section>
  )
}
```

**Step 2: Create TrendingProductsSection**

```tsx
// src/components/sales-hub/TrendingProductsSection.tsx
'use client'

import { TrendingUp, ChevronRight } from 'lucide-react'
import { ProductCardV2 } from './ProductCardV2'

// Mock data - in reality would come from API
const trendingProducts = [
  {
    id: 'thread-ai',
    name: 'Sunrise Thread AI',
    family: 'Sunrise',
    description: 'Native documentation assistant built directly into the EHR. Untethers clinicians from the keyboard by automatically documenting patient encounters.',
    regions: ['APAC', 'EMEA', 'UK', 'US'],
    usageCount: 24,
  },
  {
    id: 'dbmotion-hie',
    name: 'dbMotion HIE',
    family: 'dbMotion',
    description: 'Health Information Exchange platform enabling seamless data sharing across healthcare organisations and systems.',
    regions: ['APAC', 'ANZ'],
    usageCount: 18,
  },
  {
    id: 'opal-assessment',
    name: 'Opal Assessment',
    family: 'Opal',
    description: 'Comprehensive assessment tools for aged care and disability services, supporting NDIS and aged care funding requirements.',
    regions: ['ANZ', 'APAC'],
    usageCount: 15,
  },
]

export function TrendingProductsSection() {
  return (
    <section>
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <TrendingUp className="h-5 w-5 text-purple-600" />
          <h2 className="font-semibold text-gray-900">Trending This Month</h2>
        </div>
        <button className="flex items-center gap-1 text-sm text-purple-600 hover:text-purple-700">
          View all
          <ChevronRight className="h-4 w-4" />
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {trendingProducts.map((product) => (
          <ProductCardV2
            key={product.id}
            id={product.id}
            name={product.name}
            family={product.family}
            description={product.description}
            regions={product.regions}
            contentType="Sales Brief"
          />
        ))}
      </div>
    </section>
  )
}
```

**Step 3: Create main DashboardView**

```tsx
// src/components/sales-hub/DashboardView.tsx
'use client'

import { TopOpportunitiesSection } from './TopOpportunitiesSection'
import { TrendingProductsSection } from './TrendingProductsSection'
import { Newspaper, ChevronRight } from 'lucide-react'

export function DashboardView() {
  return (
    <div className="space-y-8 pb-20">
      {/* Top Opportunities */}
      <TopOpportunitiesSection />

      {/* Trending Products */}
      <TrendingProductsSection />

      {/* Industry News - placeholder for now */}
      <section>
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Newspaper className="h-5 w-5 text-purple-600" />
            <h2 className="font-semibold text-gray-900">Industry News</h2>
          </div>
          <button className="flex items-center gap-1 text-sm text-purple-600 hover:text-purple-700">
            View all
            <ChevronRight className="h-4 w-4" />
          </button>
        </div>
        <div className="bg-white rounded-xl border border-gray-200 p-6">
          <p className="text-sm text-gray-500 text-center">
            News Intelligence integration coming in Phase 5
          </p>
        </div>
      </section>
    </div>
  )
}
```

**Step 4: Verify components compile**

Run: `npx tsc --noEmit src/components/sales-hub/DashboardView.tsx src/components/sales-hub/TopOpportunitiesSection.tsx src/components/sales-hub/TrendingProductsSection.tsx`
Expected: No errors

**Step 5: Commit**

```bash
git add src/components/sales-hub/DashboardView.tsx src/components/sales-hub/TopOpportunitiesSection.tsx src/components/sales-hub/TrendingProductsSection.tsx
git commit -m "feat(sales-hub): add Dashboard view with opportunities and trending products"
```

---

### Task 2.4: Create Client Context View

**Files:**
- Create: `src/components/sales-hub/ClientContextView.tsx`
- Create: `src/components/sales-hub/RecommendedProductsSection.tsx`

**Step 1: Create RecommendedProductsSection**

```tsx
// src/components/sales-hub/RecommendedProductsSection.tsx
'use client'

import { useState } from 'react'
import { useSalesHubStore } from '@/stores/sales-hub-store'
import { ProductCardV2 } from './ProductCardV2'
import { Star, SlidersHorizontal, ChevronDown } from 'lucide-react'
import { cn } from '@/lib/utils'

// Mock recommendations - in reality would come from API based on client
const mockRecommendations = [
  {
    id: 'thread-ai',
    name: 'Sunrise Thread AI',
    family: 'Sunrise',
    description: 'Native documentation assistant built directly into the EHR. Untethers clinicians from the keyboard by automatically documenting patient encounters.',
    regions: ['APAC', 'EMEA', 'UK', 'US'],
    matchScore: 92,
    evidence: [
      { type: 'nps' as const, label: 'Mentioned "documentation burden" in Q4 NPS' },
      { type: 'meeting' as const, label: 'Discussed AI documentation in last QBR' },
      { type: 'stack-gap' as const, label: 'No AI documentation tool in current stack' },
    ],
  },
  {
    id: 'dbmotion-hie',
    name: 'dbMotion HIE',
    family: 'dbMotion',
    description: 'Health Information Exchange platform enabling seamless data sharing across healthcare organisations.',
    regions: ['APAC', 'ANZ'],
    matchScore: 85,
    evidence: [
      { type: 'stack-gap' as const, label: 'No interoperability solution' },
      { type: 'news' as const, label: 'Recent news mentions data sharing initiative' },
    ],
  },
  {
    id: 'sunrise-bcma',
    name: 'Sunrise BCMA',
    family: 'Sunrise',
    description: 'Barcode Medication Administration helps prevent adverse drug events with real-time validation.',
    regions: ['APAC', 'UK', 'US'],
    matchScore: 78,
    evidence: [
      { type: 'stakeholder' as const, label: 'CNIO focused on medication safety' },
    ],
  },
]

export function RecommendedProductsSection() {
  const { selectedClient } = useSalesHubStore()
  const [sortBy, setSortBy] = useState<'score' | 'name'>('score')
  const [filterOpen, setFilterOpen] = useState(false)

  if (!selectedClient) return null

  const sortedRecommendations = [...mockRecommendations].sort((a, b) => {
    if (sortBy === 'score') return b.matchScore - a.matchScore
    return a.name.localeCompare(b.name)
  })

  return (
    <section>
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <Star className="h-5 w-5 text-purple-600" />
          <h2 className="font-semibold text-gray-900">
            Recommended for {selectedClient.name}
          </h2>
          <span className="text-sm text-gray-500">
            ({sortedRecommendations.length})
          </span>
        </div>
        <div className="flex items-center gap-2">
          <div className="relative">
            <button
              onClick={() => setFilterOpen(!filterOpen)}
              className="flex items-center gap-2 px-3 py-1.5 rounded-lg border border-gray-200 text-sm text-gray-600 hover:bg-gray-50"
            >
              <SlidersHorizontal className="h-4 w-4" />
              Filter
              <ChevronDown className="h-3 w-3" />
            </button>
          </div>
          <select
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value as 'score' | 'name')}
            className="px-3 py-1.5 rounded-lg border border-gray-200 text-sm text-gray-600 bg-white"
          >
            <option value="score">Sort by Match</option>
            <option value="name">Sort by Name</option>
          </select>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {sortedRecommendations.map((product) => (
          <ProductCardV2
            key={product.id}
            id={product.id}
            name={product.name}
            family={product.family}
            description={product.description}
            regions={product.regions}
            matchScore={product.matchScore}
            evidence={product.evidence}
            contentType="Sales Brief"
          />
        ))}
      </div>
    </section>
  )
}
```

**Step 2: Create ClientContextView**

```tsx
// src/components/sales-hub/ClientContextView.tsx
'use client'

import { useSalesHubStore } from '@/stores/sales-hub-store'
import { ClientSnapshotBar } from './ClientSnapshotBar'
import { RecommendedProductsSection } from './RecommendedProductsSection'
import { Package, Calendar, Newspaper, ChevronRight } from 'lucide-react'

export function ClientContextView() {
  const { selectedClient } = useSalesHubStore()

  if (!selectedClient) return null

  // Mock data - in reality would come from API
  const mockCurrentProducts = ['Sunrise EHR', 'dbMotion', 'Sunrise Axon']

  return (
    <div className="space-y-6 pb-20">
      {/* Client Snapshot */}
      <ClientSnapshotBar
        npsScore={72}
        npsTrend={12}
        lastMeetingDays={3}
        currentProducts={mockCurrentProducts}
      />

      {/* Recommended Products */}
      <RecommendedProductsSection />

      {/* Stack Gaps - placeholder */}
      <section>
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Package className="h-5 w-5 text-purple-600" />
            <h2 className="font-semibold text-gray-900">Products They Don't Have</h2>
          </div>
          <button className="flex items-center gap-1 text-sm text-purple-600 hover:text-purple-700">
            View all
            <ChevronRight className="h-4 w-4" />
          </button>
        </div>
        <div className="bg-white rounded-xl border border-gray-200 p-6">
          <p className="text-sm text-gray-500 text-center">
            Stack gap analysis coming soon
          </p>
        </div>
      </section>

      {/* Upcoming Meetings - placeholder */}
      <section>
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Calendar className="h-5 w-5 text-purple-600" />
            <h2 className="font-semibold text-gray-900">Upcoming & Recent Meetings</h2>
          </div>
          <button className="flex items-center gap-1 text-sm text-purple-600 hover:text-purple-700">
            View all
            <ChevronRight className="h-4 w-4" />
          </button>
        </div>
        <div className="bg-white rounded-xl border border-gray-200 p-6">
          <p className="text-sm text-gray-500 text-center">
            Meeting integration coming in Phase 3
          </p>
        </div>
      </section>

      {/* Client News - placeholder */}
      <section>
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Newspaper className="h-5 w-5 text-purple-600" />
            <h2 className="font-semibold text-gray-900">News About {selectedClient.name}</h2>
          </div>
          <button className="flex items-center gap-1 text-sm text-purple-600 hover:text-purple-700">
            View all
            <ChevronRight className="h-4 w-4" />
          </button>
        </div>
        <div className="bg-white rounded-xl border border-gray-200 p-6">
          <p className="text-sm text-gray-500 text-center">
            News Intelligence integration coming in Phase 5
          </p>
        </div>
      </section>
    </div>
  )
}
```

**Step 3: Verify components compile**

Run: `npx tsc --noEmit src/components/sales-hub/ClientContextView.tsx src/components/sales-hub/RecommendedProductsSection.tsx`
Expected: No errors

**Step 4: Commit**

```bash
git add src/components/sales-hub/ClientContextView.tsx src/components/sales-hub/RecommendedProductsSection.tsx
git commit -m "feat(sales-hub): add Client Context view with snapshot and recommendations"
```

---

### Task 2.5: Wire Up Views in Main Page

**Files:**
- Modify: `src/app/(dashboard)/sales-hub/page.tsx`

**Step 1: Update page to use new components**

Replace the placeholder `DashboardView` and `ClientContextView` imports with the real components:

```tsx
// At the top of the file, replace placeholder components with imports:
import { DashboardView } from '@/components/sales-hub/DashboardView'
import { ClientContextView } from '@/components/sales-hub/ClientContextView'

// Remove the placeholder function definitions for DashboardView and ClientContextView
```

**Step 2: Verify build passes**

Run: `npm run build 2>&1 | tail -10`
Expected: Build succeeds

**Step 3: Commit**

```bash
git add src/app/(dashboard)/sales-hub/page.tsx
git commit -m "feat(sales-hub): wire up Dashboard and Client Context views"
```

---

## Phase 3: Action Bar & Bulk Operations

### Task 3.1: Create Action Bar Component

**Files:**
- Create: `src/components/sales-hub/ActionBar.tsx`

**Implementation:** Create sticky bottom action bar with:
- Left: Saved items count, Recent items count, Pinned clients
- Right: Contextual actions based on selection
- Bulk actions panel when 3+ items selected

*(Full code similar to pattern above - 150 lines)*

---

## Phase 4: AI Companion Panel

### Task 4.1: Create AI Companion Panel

**Files:**
- Create: `src/components/sales-hub/AICompanionPanel.tsx`
- Create: `src/components/sales-hub/SuggestionCard.tsx`
- Create: `src/components/sales-hub/ChatInterface.tsx`

**Implementation:** Full AI companion with:
- Contextual suggestions based on selected client
- Chat interface for questions
- Recent insights section
- Mobile bottom sheet behaviour

---

## Phase 5: News Intelligence Integration

### Task 5.1: Create Urgent Alerts Banner

**Files:**
- Create: `src/components/sales-hub/UrgentAlertsBanner.tsx`

**Implementation:** Integrate with existing News Intelligence:
- Fetch from `/api/sales-hub/news/urgent`
- Display alert banner when urgent items exist
- Link to full news view

### Task 5.2: Create News Cards for Client View

**Files:**
- Create: `src/components/sales-hub/NewsCard.tsx`
- Create: `src/components/sales-hub/ClientNewsSection.tsx`

**Implementation:** News cards in client context:
- Fetch from `/api/sales-hub/news/client/{clientId}`
- Show category badges (urgent, opportunity, monitor)
- AI summary and recommended actions

---

## Phase 6: Polish & Animations

### Task 6.1: Add Micro-Animations

**Files:**
- Modify: Various components

**Implementation:**
- Card hover animations (translateY, shadow)
- Score ring fill animation
- Panel slide transitions
- Skeleton shimmer loading

### Task 6.2: Add Dark Mode Support

**Files:**
- Modify: `src/app/globals.css`
- Modify: Various components

**Implementation:**
- CSS variables for dark mode colours
- System preference detection
- Toggle in settings

---

## Phase 7: Mobile & Responsive

### Task 7.1: Mobile Navigation

**Files:**
- Create: `src/components/sales-hub/MobileBottomNav.tsx`
- Create: `src/components/sales-hub/MobileAISheet.tsx`

**Implementation:**
- Bottom navigation bar for mobile
- AI companion as bottom sheet
- Gesture support (swipe actions)

---

## Verification Checklist

After each phase, verify:

- [ ] `npm run build` passes
- [ ] `npm run lint` passes
- [ ] Manual test in browser at `http://localhost:3001/sales-hub`
- [ ] Client selection works
- [ ] View transitions work
- [ ] Responsive at 1280px, 1024px, 768px, 375px

---

## Rollback Plan

If issues arise:
1. The original page is preserved at `page.old.tsx`
2. To rollback: `mv page.tsx page.new.tsx && mv page.old.tsx page.tsx`
3. All new components are in separate files and can be deleted without affecting other features
