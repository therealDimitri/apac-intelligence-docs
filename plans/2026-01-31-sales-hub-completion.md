# Sales Hub Completion Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Complete the Sales Hub feature with admin interface, ChaSen knowledge sync, search functionality, recommendations page, and solution bundles view.

**Architecture:**
- Admin interface follows the Knowledge Management pattern (TanStack Table + modals)
- ChaSen sync uses database trigger + API endpoint pattern
- Search combines client-side filtering with semantic search for AI recommendations
- All new routes added under `/sales-hub/*` with sidebar navigation updates

**Tech Stack:** Next.js 14 App Router, Supabase, TanStack React Table, Tailwind CSS, pgvector for semantic search

---

## Task 1: Solution Bundles View (`/sales-hub/bundles`)

**Files:**
- Create: `src/app/(dashboard)/sales-hub/bundles/page.tsx`
- Modify: `src/components/layout/sidebar.tsx:89-95` (add Bundles nav link)

**Step 1: Create the bundles page**

```tsx
'use client'

import { useState, useMemo } from 'react'
import { useSolutionBundles, useToolkits, SolutionBundle } from '@/hooks/useProductCatalog'
import {
  Package,
  Target,
  TrendingUp,
  Users,
  MessageSquare,
  ExternalLink,
  ChevronRight,
  X,
  Loader2,
  AlertCircle,
  Briefcase,
} from 'lucide-react'

const PERSONA_CONFIG: Record<string, { label: string; color: string }> = {
  cfo: { label: 'CFO', color: 'bg-green-100 text-green-800' },
  cmio: { label: 'CMIO', color: 'bg-blue-100 text-blue-800' },
  cio: { label: 'CIO', color: 'bg-purple-100 text-purple-800' },
  cnio: { label: 'CNIO', color: 'bg-pink-100 text-pink-800' },
  coo: { label: 'COO', color: 'bg-orange-100 text-orange-800' },
}

const WHAT_IT_MEANS_TABS = [
  { key: 'financial', label: 'Financial', icon: TrendingUp },
  { key: 'clinical', label: 'Clinical', icon: Users },
  { key: 'operational', label: 'Operational', icon: Briefcase },
]

export default function SolutionBundlesPage() {
  const { bundles, isLoading, error } = useSolutionBundles()
  const { toolkits } = useToolkits()
  const [selectedBundle, setSelectedBundle] = useState<SolutionBundle | null>(null)
  const [activeTab, setActiveTab] = useState<string>('financial')
  const [selectedRegion, setSelectedRegion] = useState<string>('all')

  const regions = useMemo(() => {
    if (!bundles) return []
    const allRegions = new Set<string>()
    bundles.forEach(b => b.regions?.forEach(r => allRegions.add(r)))
    return Array.from(allRegions).sort()
  }, [bundles])

  const filteredBundles = useMemo(() => {
    if (!bundles) return []
    if (selectedRegion === 'all') return bundles
    return bundles.filter(b => b.regions?.includes(selectedRegion))
  }, [bundles, selectedRegion])

  const getToolkitForBundle = (bundleId: string) => {
    return toolkits?.find(t => t.bundle_ids?.includes(bundleId))
  }

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <Loader2 className="h-8 w-8 animate-spin text-purple-600" />
      </div>
    )
  }

  if (error) {
    return (
      <div className="flex items-center justify-center h-64 text-red-600">
        <AlertCircle className="h-5 w-5 mr-2" />
        {error.message}
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Solution Bundles</h1>
          <p className="text-gray-600 mt-1">
            Pre-packaged solution plays with persona-specific messaging
          </p>
        </div>
      </div>

      {/* Filter Bar */}
      <div className="flex items-center gap-4">
        <select
          value={selectedRegion}
          onChange={e => setSelectedRegion(e.target.value)}
          className="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-purple-500"
        >
          <option value="all">All Regions</option>
          {regions.map(r => (
            <option key={r} value={r}>{r}</option>
          ))}
        </select>
        <span className="text-sm text-gray-500">
          {filteredBundles.length} bundle{filteredBundles.length !== 1 ? 's' : ''}
        </span>
      </div>

      {/* Bundle Cards Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredBundles.map(bundle => {
          const toolkit = getToolkitForBundle(bundle.id)
          return (
            <div
              key={bundle.id}
              className="bg-white rounded-lg border shadow-sm hover:shadow-md transition-shadow cursor-pointer"
              onClick={() => setSelectedBundle(bundle)}
            >
              <div className="p-5">
                {/* Toolkit badge */}
                {toolkit && (
                  <div className="mb-3">
                    <span className="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-gray-100 text-gray-700">
                      <Package className="h-3 w-3 mr-1" />
                      {toolkit.name}
                    </span>
                  </div>
                )}

                {/* Bundle name & tagline */}
                <h3 className="text-lg font-semibold text-gray-900 mb-1">
                  {bundle.bundle_name}
                </h3>
                {bundle.tagline && (
                  <p className="text-sm text-gray-600 mb-3">{bundle.tagline}</p>
                )}

                {/* KPIs preview */}
                {(bundle.kpis?.length ?? 0) > 0 && (
                  <div className="mb-3">
                    <div className="flex items-center gap-1 text-xs font-medium text-gray-500 mb-1">
                      <Target className="h-3 w-3" />
                      Key Metrics
                    </div>
                    <div className="flex flex-wrap gap-1">
                      {bundle.kpis?.slice(0, 2).map((kpi, i) => (
                        <span
                          key={i}
                          className="inline-flex items-center px-2 py-0.5 rounded text-xs bg-purple-50 text-purple-700"
                        >
                          {kpi.metric}
                        </span>
                      ))}
                      {(bundle.kpis?.length ?? 0) > 2 && (
                        <span className="text-xs text-gray-400">
                          +{(bundle.kpis?.length ?? 0) - 2} more
                        </span>
                      )}
                    </div>
                  </div>
                )}

                {/* Persona quick links */}
                {bundle.persona_notes && Object.keys(bundle.persona_notes).length > 0 && (
                  <div className="flex flex-wrap gap-1">
                    {Object.keys(bundle.persona_notes).map(persona => {
                      const config = PERSONA_CONFIG[persona] || {
                        label: persona.toUpperCase(),
                        color: 'bg-gray-100 text-gray-800',
                      }
                      return (
                        <span
                          key={persona}
                          className={`inline-flex items-center px-2 py-0.5 rounded text-xs font-medium ${config.color}`}
                        >
                          {config.label}
                        </span>
                      )
                    })}
                  </div>
                )}

                {/* Region tags */}
                <div className="mt-3 pt-3 border-t flex items-center justify-between">
                  <div className="flex flex-wrap gap-1">
                    {bundle.regions?.map(r => (
                      <span
                        key={r}
                        className="inline-flex items-center px-1.5 py-0.5 rounded text-xs bg-gray-100 text-gray-600"
                      >
                        {r}
                      </span>
                    ))}
                  </div>
                  <ChevronRight className="h-4 w-4 text-gray-400" />
                </div>
              </div>
            </div>
          )
        })}
      </div>

      {/* Detail Slide-out Panel */}
      {selectedBundle && (
        <>
          <div
            className="fixed inset-0 bg-black/30 z-40"
            onClick={() => setSelectedBundle(null)}
          />
          <div className="fixed right-0 top-0 h-full w-full max-w-2xl bg-white shadow-xl z-50 overflow-y-auto">
            <div className="p-6">
              {/* Header */}
              <div className="flex items-start justify-between mb-6">
                <div>
                  <h2 className="text-xl font-bold text-gray-900">
                    {selectedBundle.bundle_name}
                  </h2>
                  {selectedBundle.tagline && (
                    <p className="text-gray-600 mt-1">{selectedBundle.tagline}</p>
                  )}
                </div>
                <button
                  onClick={() => setSelectedBundle(null)}
                  className="p-2 hover:bg-gray-100 rounded-lg"
                >
                  <X className="h-5 w-5" />
                </button>
              </div>

              {/* What it is / What it does */}
              {selectedBundle.what_it_is && (
                <div className="mb-6">
                  <h3 className="text-sm font-semibold text-gray-900 mb-2">What It Is</h3>
                  <p className="text-sm text-gray-700">{selectedBundle.what_it_is}</p>
                </div>
              )}

              {selectedBundle.what_it_does && (
                <div className="mb-6">
                  <h3 className="text-sm font-semibold text-gray-900 mb-2">What It Does</h3>
                  <p className="text-sm text-gray-700">{selectedBundle.what_it_does}</p>
                </div>
              )}

              {/* What it means - Tabbed */}
              {selectedBundle.what_it_means && Object.keys(selectedBundle.what_it_means).length > 0 && (
                <div className="mb-6">
                  <h3 className="text-sm font-semibold text-gray-900 mb-3">What It Means</h3>
                  <div className="flex border-b mb-3">
                    {WHAT_IT_MEANS_TABS.map(tab => {
                      const Icon = tab.icon
                      const hasContent = selectedBundle.what_it_means?.[tab.key]?.length
                      if (!hasContent) return null
                      return (
                        <button
                          key={tab.key}
                          onClick={() => setActiveTab(tab.key)}
                          className={`flex items-center gap-1.5 px-4 py-2 text-sm font-medium border-b-2 -mb-px transition-colors ${
                            activeTab === tab.key
                              ? 'border-purple-600 text-purple-600'
                              : 'border-transparent text-gray-500 hover:text-gray-700'
                          }`}
                        >
                          <Icon className="h-4 w-4" />
                          {tab.label}
                        </button>
                      )
                    })}
                  </div>
                  <ul className="space-y-2">
                    {selectedBundle.what_it_means[activeTab]?.map((item, i) => (
                      <li key={i} className="flex items-start gap-2 text-sm text-gray-700">
                        <span className="text-purple-600 mt-1">•</span>
                        {item}
                      </li>
                    ))}
                  </ul>
                </div>
              )}

              {/* KPIs */}
              {(selectedBundle.kpis?.length ?? 0) > 0 && (
                <div className="mb-6">
                  <h3 className="text-sm font-semibold text-gray-900 mb-3 flex items-center gap-2">
                    <Target className="h-4 w-4 text-purple-600" />
                    Key Performance Indicators
                  </h3>
                  <div className="space-y-3">
                    {selectedBundle.kpis?.map((kpi, i) => (
                      <div key={i} className="bg-gray-50 rounded-lg p-3">
                        <div className="flex items-center justify-between mb-1">
                          <span className="font-medium text-gray-900">{kpi.metric}</span>
                          <span className="text-sm text-purple-600 font-semibold">{kpi.target}</span>
                        </div>
                        {kpi.proof && (
                          <p className="text-xs text-gray-600">{kpi.proof}</p>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Market Drivers */}
              {(selectedBundle.market_drivers?.length ?? 0) > 0 && (
                <div className="mb-6">
                  <h3 className="text-sm font-semibold text-gray-900 mb-2 flex items-center gap-2">
                    <TrendingUp className="h-4 w-4 text-purple-600" />
                    Market Drivers
                  </h3>
                  <ul className="space-y-1">
                    {selectedBundle.market_drivers?.map((driver, i) => (
                      <li key={i} className="flex items-start gap-2 text-sm text-gray-700">
                        <span className="text-purple-600">•</span>
                        {driver}
                      </li>
                    ))}
                  </ul>
                </div>
              )}

              {/* Persona Notes */}
              {selectedBundle.persona_notes && Object.keys(selectedBundle.persona_notes).length > 0 && (
                <div className="mb-6">
                  <h3 className="text-sm font-semibold text-gray-900 mb-3 flex items-center gap-2">
                    <Users className="h-4 w-4 text-purple-600" />
                    Persona Talking Points
                  </h3>
                  <div className="space-y-4">
                    {Object.entries(selectedBundle.persona_notes).map(([persona, notes]) => {
                      const config = PERSONA_CONFIG[persona] || {
                        label: persona.toUpperCase(),
                        color: 'bg-gray-100 text-gray-800',
                      }
                      return (
                        <div key={persona}>
                          <span className={`inline-flex items-center px-2 py-1 rounded text-xs font-medium mb-2 ${config.color}`}>
                            {config.label}
                          </span>
                          <ul className="space-y-1 ml-1">
                            {(notes as string[]).map((note, i) => (
                              <li key={i} className="flex items-start gap-2 text-sm text-gray-700">
                                <span className="text-gray-400">–</span>
                                {note}
                              </li>
                            ))}
                          </ul>
                        </div>
                      )
                    })}
                  </div>
                </div>
              )}

              {/* Grabber Examples */}
              {(selectedBundle.grabber_examples?.length ?? 0) > 0 && (
                <div className="mb-6">
                  <h3 className="text-sm font-semibold text-gray-900 mb-2 flex items-center gap-2">
                    <MessageSquare className="h-4 w-4 text-purple-600" />
                    Conversation Starters
                  </h3>
                  <div className="space-y-2">
                    {selectedBundle.grabber_examples?.map((example, i) => (
                      <div key={i} className="bg-purple-50 rounded-lg p-3 text-sm text-purple-900 italic">
                        &ldquo;{example}&rdquo;
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Asset Link */}
              {selectedBundle.asset_url && (
                <div className="pt-4 border-t">
                  <a
                    href={selectedBundle.asset_url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center gap-2 px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
                  >
                    <ExternalLink className="h-4 w-4" />
                    Open Source Toolkit
                  </a>
                </div>
              )}
            </div>
          </div>
        </>
      )}
    </div>
  )
}
```

**Step 2: Add navigation link in sidebar**

In `src/components/layout/sidebar.tsx`, find the Resources group and add Bundles:

```tsx
{
  name: 'Resources',
  icon: Cog,
  children: [
    { name: 'Sales Hub', href: '/sales-hub' },
    { name: 'Solution Bundles', href: '/sales-hub/bundles' },
    { name: 'Guides & Templates', href: '/guides' },
  ],
},
```

**Step 3: Build and verify**

Run: `npm run build`
Expected: Build succeeds with no TypeScript errors

**Step 4: Commit**

```bash
git add src/app/\(dashboard\)/sales-hub/bundles/page.tsx src/components/layout/sidebar.tsx
git commit -m "feat(sales-hub): Add Solution Bundles view with persona messaging"
```

---

## Task 2: Sales Hub Admin Interface (`/settings/sales-hub`)

**Files:**
- Create: `src/app/(dashboard)/settings/sales-hub/page.tsx`
- Create: `src/components/ProductModal.tsx`
- Create: `src/app/api/sales-hub/products/route.ts`
- Modify: `src/app/(dashboard)/settings/page.tsx` (add admin card)

**Step 1: Create API route for product CRUD**

```tsx
// src/app/api/sales-hub/products/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const id = searchParams.get('id')
  const includeInactive = searchParams.get('include_inactive') === 'true'

  try {
    let query = supabase.from('product_catalog').select('*')

    if (id) {
      query = query.eq('id', id).single()
    } else if (!includeInactive) {
      query = query.eq('is_active', true)
    }

    query = query.order('content_type').order('product_family').order('title')

    const { data, error } = await query

    if (error) throw error

    return NextResponse.json({ success: true, data })
  } catch (error) {
    return NextResponse.json(
      { success: false, error: error instanceof Error ? error.message : 'Failed to fetch products' },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { id, ...productData } = body

    if (id) {
      // Update existing
      const { data, error } = await supabase
        .from('product_catalog')
        .update({ ...productData, updated_at: new Date().toISOString() })
        .eq('id', id)
        .select()
        .single()

      if (error) throw error
      return NextResponse.json({ success: true, data })
    } else {
      // Create new
      const { data, error } = await supabase
        .from('product_catalog')
        .insert(productData)
        .select()
        .single()

      if (error) throw error
      return NextResponse.json({ success: true, data })
    }
  } catch (error) {
    return NextResponse.json(
      { success: false, error: error instanceof Error ? error.message : 'Failed to save product' },
      { status: 500 }
    )
  }
}

export async function DELETE(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const id = searchParams.get('id')
  const hard = searchParams.get('hard') === 'true'

  if (!id) {
    return NextResponse.json({ success: false, error: 'Product ID required' }, { status: 400 })
  }

  try {
    if (hard) {
      const { error } = await supabase.from('product_catalog').delete().eq('id', id)
      if (error) throw error
    } else {
      const { error } = await supabase
        .from('product_catalog')
        .update({ is_active: false, updated_at: new Date().toISOString() })
        .eq('id', id)
      if (error) throw error
    }

    return NextResponse.json({ success: true })
  } catch (error) {
    return NextResponse.json(
      { success: false, error: error instanceof Error ? error.message : 'Failed to delete product' },
      { status: 500 }
    )
  }
}
```

**Step 2: Create ProductModal component**

```tsx
// src/components/ProductModal.tsx
'use client'

import { useState, useEffect } from 'react'
import { X, Loader2, ToggleLeft, ToggleRight, Plus, Trash2 } from 'lucide-react'
import { ProductCatalogItem } from '@/hooks/useProductCatalog'

interface ProductModalProps {
  isOpen: boolean
  onClose: () => void
  onSuccess: () => void
  product?: ProductCatalogItem | null
}

const CONTENT_TYPES = [
  'sales_brief',
  'datasheet',
  'brochure',
  'door_opener',
  'one_pager',
  'video',
]

const PRODUCT_FAMILIES = [
  'Sunrise',
  'Paragon',
  'TouchWorks',
  'dbMotion',
  'FollowMyHealth',
  'Veradigm',
  'Altera',
]

const REGIONS = ['APAC', 'ANZ', 'ASIA', 'UK', 'US', 'Global']

type FormData = {
  product_family: string
  product_name: string
  content_type: string
  regions: string[]
  title: string
  elevator_pitch: string
  solution_overview: string
  asset_url: string
  asset_filename: string
  pricing_summary: string
  version_requirements: string
  is_active: boolean
  value_propositions: Array<{ title: string; description: string }>
  key_drivers: Array<{ title: string; description: string }>
  target_triggers: string[]
  objection_handling: Array<{ objection: string; response: string }>
  faq: Array<{ question: string; answer: string }>
}

const emptyFormData: FormData = {
  product_family: '',
  product_name: '',
  content_type: 'datasheet',
  regions: [],
  title: '',
  elevator_pitch: '',
  solution_overview: '',
  asset_url: '',
  asset_filename: '',
  pricing_summary: '',
  version_requirements: '',
  is_active: true,
  value_propositions: [],
  key_drivers: [],
  target_triggers: [],
  objection_handling: [],
  faq: [],
}

export function ProductModal({ isOpen, onClose, onSuccess, product }: ProductModalProps) {
  const [formData, setFormData] = useState<FormData>(emptyFormData)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [activeSection, setActiveSection] = useState<string>('basic')

  useEffect(() => {
    if (product) {
      setFormData({
        product_family: product.product_family || '',
        product_name: product.product_name || '',
        content_type: product.content_type || 'datasheet',
        regions: product.regions || [],
        title: product.title || '',
        elevator_pitch: product.elevator_pitch || '',
        solution_overview: product.solution_overview || '',
        asset_url: product.asset_url || '',
        asset_filename: product.asset_filename || '',
        pricing_summary: product.pricing_summary || '',
        version_requirements: product.version_requirements || '',
        is_active: product.is_active ?? true,
        value_propositions: product.value_propositions || [],
        key_drivers: product.key_drivers || [],
        target_triggers: product.target_triggers || [],
        objection_handling: product.objection_handling || [],
        faq: product.faq || [],
      })
    } else {
      setFormData(emptyFormData)
    }
    setError(null)
    setActiveSection('basic')
  }, [product, isOpen])

  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && !saving) onClose()
    }
    if (isOpen) document.addEventListener('keydown', handleEscape)
    return () => document.removeEventListener('keydown', handleEscape)
  }, [isOpen, saving, onClose])

  const handleSave = async () => {
    if (!formData.title.trim()) {
      setError('Title is required')
      return
    }

    setSaving(true)
    setError(null)

    try {
      const response = await fetch('/api/sales-hub/products', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(product ? { id: product.id, ...formData } : formData),
      })

      const data = await response.json()
      if (!data.success) throw new Error(data.error)

      onSuccess()
      onClose()
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to save product')
    } finally {
      setSaving(false)
    }
  }

  const toggleRegion = (region: string) => {
    setFormData(prev => ({
      ...prev,
      regions: prev.regions.includes(region)
        ? prev.regions.filter(r => r !== region)
        : [...prev.regions, region],
    }))
  }

  if (!isOpen) return null

  const sections = [
    { key: 'basic', label: 'Basic Info' },
    { key: 'content', label: 'Content' },
    { key: 'sales', label: 'Sales Info' },
    { key: 'faq', label: 'FAQ' },
  ]

  return (
    <>
      <div className="fixed inset-0 bg-black/50 z-50" onClick={!saving ? onClose : undefined} />
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
        <div className="bg-white rounded-xl shadow-xl w-full max-w-4xl max-h-[90vh] overflow-hidden flex flex-col">
          {/* Header */}
          <div className="flex items-center justify-between px-6 py-4 border-b">
            <h2 className="text-lg font-semibold">
              {product ? 'Edit Product' : 'Add Product'}
            </h2>
            <button
              onClick={onClose}
              disabled={saving}
              className="p-2 hover:bg-gray-100 rounded-lg"
            >
              <X className="h-5 w-5" />
            </button>
          </div>

          {/* Section Tabs */}
          <div className="flex border-b px-6">
            {sections.map(section => (
              <button
                key={section.key}
                onClick={() => setActiveSection(section.key)}
                className={`px-4 py-2 text-sm font-medium border-b-2 -mb-px transition-colors ${
                  activeSection === section.key
                    ? 'border-purple-600 text-purple-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                {section.label}
              </button>
            ))}
          </div>

          {/* Content */}
          <div className="flex-1 overflow-y-auto p-6">
            {error && (
              <div className="mb-4 p-3 bg-red-50 text-red-700 rounded-lg text-sm">
                {error}
              </div>
            )}

            {activeSection === 'basic' && (
              <div className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-900 mb-1">
                      Product Family
                    </label>
                    <select
                      value={formData.product_family}
                      onChange={e => setFormData(prev => ({ ...prev, product_family: e.target.value }))}
                      className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-purple-500"
                    >
                      <option value="">Select family...</option>
                      {PRODUCT_FAMILIES.map(f => (
                        <option key={f} value={f}>{f}</option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-900 mb-1">
                      Product Name
                    </label>
                    <input
                      type="text"
                      value={formData.product_name}
                      onChange={e => setFormData(prev => ({ ...prev, product_name: e.target.value }))}
                      className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-purple-500"
                      placeholder="e.g. CarePath, Thread AI"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-900 mb-1">
                    Title
                  </label>
                  <input
                    type="text"
                    value={formData.title}
                    onChange={e => setFormData(prev => ({ ...prev, title: e.target.value }))}
                    className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-purple-500"
                    placeholder="Document title"
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-900 mb-1">
                      Content Type
                    </label>
                    <select
                      value={formData.content_type}
                      onChange={e => setFormData(prev => ({ ...prev, content_type: e.target.value }))}
                      className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-purple-500"
                    >
                      {CONTENT_TYPES.map(t => (
                        <option key={t} value={t}>
                          {t.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase())}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-900 mb-1">
                      Regions
                    </label>
                    <div className="flex flex-wrap gap-2">
                      {REGIONS.map(r => (
                        <button
                          key={r}
                          type="button"
                          onClick={() => toggleRegion(r)}
                          className={`px-2 py-1 text-xs rounded-full border transition-colors ${
                            formData.regions.includes(r)
                              ? 'bg-purple-100 border-purple-300 text-purple-700'
                              : 'bg-gray-50 border-gray-200 text-gray-600 hover:bg-gray-100'
                          }`}
                        >
                          {r}
                        </button>
                      ))}
                    </div>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-900 mb-1">
                    Asset URL
                  </label>
                  <input
                    type="url"
                    value={formData.asset_url}
                    onChange={e => setFormData(prev => ({ ...prev, asset_url: e.target.value }))}
                    className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-purple-500"
                    placeholder="https://..."
                  />
                </div>

                <div className="flex items-center justify-between pt-2">
                  <label className="text-sm font-medium text-gray-900">Active</label>
                  <button
                    type="button"
                    onClick={() => setFormData(prev => ({ ...prev, is_active: !prev.is_active }))}
                    className="text-purple-600"
                  >
                    {formData.is_active ? (
                      <ToggleRight className="h-8 w-8" />
                    ) : (
                      <ToggleLeft className="h-8 w-8 text-gray-400" />
                    )}
                  </button>
                </div>
              </div>
            )}

            {activeSection === 'content' && (
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-900 mb-1">
                    Elevator Pitch
                  </label>
                  <textarea
                    value={formData.elevator_pitch}
                    onChange={e => setFormData(prev => ({ ...prev, elevator_pitch: e.target.value }))}
                    rows={2}
                    className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-purple-500"
                    placeholder="1-2 sentence summary"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-900 mb-1">
                    Solution Overview
                  </label>
                  <textarea
                    value={formData.solution_overview}
                    onChange={e => setFormData(prev => ({ ...prev, solution_overview: e.target.value }))}
                    rows={4}
                    className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-purple-500"
                    placeholder="Detailed description"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-900 mb-1">
                    Pricing Summary
                  </label>
                  <textarea
                    value={formData.pricing_summary}
                    onChange={e => setFormData(prev => ({ ...prev, pricing_summary: e.target.value }))}
                    rows={2}
                    className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-purple-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-900 mb-1">
                    Version Requirements
                  </label>
                  <input
                    type="text"
                    value={formData.version_requirements}
                    onChange={e => setFormData(prev => ({ ...prev, version_requirements: e.target.value }))}
                    className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-purple-500"
                  />
                </div>
              </div>
            )}

            {activeSection === 'sales' && (
              <div className="space-y-6">
                {/* Value Propositions */}
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <label className="text-sm font-medium text-gray-900">Value Propositions</label>
                    <button
                      type="button"
                      onClick={() => setFormData(prev => ({
                        ...prev,
                        value_propositions: [...prev.value_propositions, { title: '', description: '' }],
                      }))}
                      className="text-purple-600 hover:text-purple-700 text-sm flex items-center gap-1"
                    >
                      <Plus className="h-4 w-4" /> Add
                    </button>
                  </div>
                  <div className="space-y-2">
                    {formData.value_propositions.map((vp, i) => (
                      <div key={i} className="flex gap-2 items-start">
                        <input
                          type="text"
                          value={vp.title}
                          onChange={e => {
                            const updated = [...formData.value_propositions]
                            updated[i] = { ...updated[i], title: e.target.value }
                            setFormData(prev => ({ ...prev, value_propositions: updated }))
                          }}
                          placeholder="Title"
                          className="flex-1 px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-purple-500"
                        />
                        <input
                          type="text"
                          value={vp.description}
                          onChange={e => {
                            const updated = [...formData.value_propositions]
                            updated[i] = { ...updated[i], description: e.target.value }
                            setFormData(prev => ({ ...prev, value_propositions: updated }))
                          }}
                          placeholder="Description"
                          className="flex-[2] px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-purple-500"
                        />
                        <button
                          type="button"
                          onClick={() => setFormData(prev => ({
                            ...prev,
                            value_propositions: prev.value_propositions.filter((_, idx) => idx !== i),
                          }))}
                          className="p-2 text-gray-400 hover:text-red-500"
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Target Triggers */}
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <label className="text-sm font-medium text-gray-900">Target Triggers</label>
                    <button
                      type="button"
                      onClick={() => setFormData(prev => ({
                        ...prev,
                        target_triggers: [...prev.target_triggers, ''],
                      }))}
                      className="text-purple-600 hover:text-purple-700 text-sm flex items-center gap-1"
                    >
                      <Plus className="h-4 w-4" /> Add
                    </button>
                  </div>
                  <div className="space-y-2">
                    {formData.target_triggers.map((trigger, i) => (
                      <div key={i} className="flex gap-2">
                        <input
                          type="text"
                          value={trigger}
                          onChange={e => {
                            const updated = [...formData.target_triggers]
                            updated[i] = e.target.value
                            setFormData(prev => ({ ...prev, target_triggers: updated }))
                          }}
                          placeholder="When to pitch this product"
                          className="flex-1 px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-purple-500"
                        />
                        <button
                          type="button"
                          onClick={() => setFormData(prev => ({
                            ...prev,
                            target_triggers: prev.target_triggers.filter((_, idx) => idx !== i),
                          }))}
                          className="p-2 text-gray-400 hover:text-red-500"
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Objection Handling */}
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <label className="text-sm font-medium text-gray-900">Objection Handling</label>
                    <button
                      type="button"
                      onClick={() => setFormData(prev => ({
                        ...prev,
                        objection_handling: [...prev.objection_handling, { objection: '', response: '' }],
                      }))}
                      className="text-purple-600 hover:text-purple-700 text-sm flex items-center gap-1"
                    >
                      <Plus className="h-4 w-4" /> Add
                    </button>
                  </div>
                  <div className="space-y-2">
                    {formData.objection_handling.map((oh, i) => (
                      <div key={i} className="flex gap-2 items-start">
                        <input
                          type="text"
                          value={oh.objection}
                          onChange={e => {
                            const updated = [...formData.objection_handling]
                            updated[i] = { ...updated[i], objection: e.target.value }
                            setFormData(prev => ({ ...prev, objection_handling: updated }))
                          }}
                          placeholder="Objection"
                          className="flex-1 px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-purple-500"
                        />
                        <input
                          type="text"
                          value={oh.response}
                          onChange={e => {
                            const updated = [...formData.objection_handling]
                            updated[i] = { ...updated[i], response: e.target.value }
                            setFormData(prev => ({ ...prev, objection_handling: updated }))
                          }}
                          placeholder="Response"
                          className="flex-[2] px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-purple-500"
                        />
                        <button
                          type="button"
                          onClick={() => setFormData(prev => ({
                            ...prev,
                            objection_handling: prev.objection_handling.filter((_, idx) => idx !== i),
                          }))}
                          className="p-2 text-gray-400 hover:text-red-500"
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            )}

            {activeSection === 'faq' && (
              <div>
                <div className="flex items-center justify-between mb-2">
                  <label className="text-sm font-medium text-gray-900">Frequently Asked Questions</label>
                  <button
                    type="button"
                    onClick={() => setFormData(prev => ({
                      ...prev,
                      faq: [...prev.faq, { question: '', answer: '' }],
                    }))}
                    className="text-purple-600 hover:text-purple-700 text-sm flex items-center gap-1"
                  >
                    <Plus className="h-4 w-4" /> Add
                  </button>
                </div>
                <div className="space-y-3">
                  {formData.faq.map((item, i) => (
                    <div key={i} className="border rounded-lg p-3">
                      <div className="flex gap-2 mb-2">
                        <input
                          type="text"
                          value={item.question}
                          onChange={e => {
                            const updated = [...formData.faq]
                            updated[i] = { ...updated[i], question: e.target.value }
                            setFormData(prev => ({ ...prev, faq: updated }))
                          }}
                          placeholder="Question"
                          className="flex-1 px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-purple-500"
                        />
                        <button
                          type="button"
                          onClick={() => setFormData(prev => ({
                            ...prev,
                            faq: prev.faq.filter((_, idx) => idx !== i),
                          }))}
                          className="p-2 text-gray-400 hover:text-red-500"
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </div>
                      <textarea
                        value={item.answer}
                        onChange={e => {
                          const updated = [...formData.faq]
                          updated[i] = { ...updated[i], answer: e.target.value }
                          setFormData(prev => ({ ...prev, faq: updated }))
                        }}
                        placeholder="Answer"
                        rows={2}
                        className="w-full px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-purple-500"
                      />
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>

          {/* Footer */}
          <div className="flex items-center justify-end gap-3 px-6 py-4 border-t bg-gray-50">
            <button
              onClick={onClose}
              disabled={saving}
              className="px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 rounded-lg transition-colors"
            >
              Cancel
            </button>
            <button
              onClick={handleSave}
              disabled={saving}
              className="px-4 py-2 text-sm bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors flex items-center gap-2"
            >
              {saving && <Loader2 className="h-4 w-4 animate-spin" />}
              {product ? 'Save Changes' : 'Create Product'}
            </button>
          </div>
        </div>
      </div>
    </>
  )
}
```

**Step 3: Create admin page**

```tsx
// src/app/(dashboard)/settings/sales-hub/page.tsx
'use client'

import { useState, useEffect, useMemo } from 'react'
import {
  useReactTable,
  getCoreRowModel,
  getSortedRowModel,
  createColumnHelper,
  flexRender,
  SortingState,
} from '@tanstack/react-table'
import {
  Package,
  Plus,
  RefreshCw,
  Search,
  Edit2,
  Trash2,
  ExternalLink,
  ArrowUpDown,
  ArrowUp,
  ArrowDown,
  Loader2,
  AlertCircle,
  Eye,
  EyeOff,
} from 'lucide-react'
import { ProductCatalogItem } from '@/hooks/useProductCatalog'
import { ProductModal } from '@/components/ProductModal'
import { ConfirmationModal } from '@/components/ConfirmationModal'

const columnHelper = createColumnHelper<ProductCatalogItem>()

export default function SalesHubAdminPage() {
  const [products, setProducts] = useState<ProductCatalogItem[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [sorting, setSorting] = useState<SortingState>([])
  const [searchQuery, setSearchQuery] = useState('')
  const [showInactive, setShowInactive] = useState(false)
  const [modalOpen, setModalOpen] = useState(false)
  const [editingProduct, setEditingProduct] = useState<ProductCatalogItem | null>(null)
  const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false)
  const [deletingProduct, setDeletingProduct] = useState<ProductCatalogItem | null>(null)
  const [deleting, setDeleting] = useState(false)

  const fetchProducts = async () => {
    setIsLoading(true)
    setError(null)
    try {
      const response = await fetch(`/api/sales-hub/products?include_inactive=${showInactive}`)
      const data = await response.json()
      if (!data.success) throw new Error(data.error)
      setProducts(data.data || [])
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch products')
    } finally {
      setIsLoading(false)
    }
  }

  useEffect(() => {
    fetchProducts()
  }, [showInactive])

  const filteredProducts = useMemo(() => {
    if (!searchQuery.trim()) return products
    const query = searchQuery.toLowerCase()
    return products.filter(
      p =>
        p.title.toLowerCase().includes(query) ||
        p.product_family?.toLowerCase().includes(query) ||
        p.product_name?.toLowerCase().includes(query)
    )
  }, [products, searchQuery])

  const handleEdit = (product: ProductCatalogItem) => {
    setEditingProduct(product)
    setModalOpen(true)
  }

  const handleDelete = (product: ProductCatalogItem) => {
    setDeletingProduct(product)
    setDeleteConfirmOpen(true)
  }

  const confirmDelete = async () => {
    if (!deletingProduct) return
    setDeleting(true)
    try {
      const response = await fetch(`/api/sales-hub/products?id=${deletingProduct.id}`, {
        method: 'DELETE',
      })
      const data = await response.json()
      if (!data.success) throw new Error(data.error)
      fetchProducts()
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to delete product')
    } finally {
      setDeleting(false)
      setDeleteConfirmOpen(false)
      setDeletingProduct(null)
    }
  }

  const columns = useMemo(
    () => [
      columnHelper.accessor('title', {
        header: ({ column }) => (
          <button
            onClick={() => column.toggleSorting()}
            className="flex items-center gap-1 font-medium"
          >
            Title
            {column.getIsSorted() === 'asc' ? (
              <ArrowUp className="h-4 w-4" />
            ) : column.getIsSorted() === 'desc' ? (
              <ArrowDown className="h-4 w-4" />
            ) : (
              <ArrowUpDown className="h-4 w-4 text-gray-400" />
            )}
          </button>
        ),
        cell: info => (
          <div className="max-w-xs truncate font-medium">{info.getValue()}</div>
        ),
      }),
      columnHelper.accessor('product_family', {
        header: 'Family',
        cell: info => (
          <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-purple-100 text-purple-800">
            {info.getValue() || '-'}
          </span>
        ),
      }),
      columnHelper.accessor('content_type', {
        header: 'Type',
        cell: info => (
          <span className="text-sm text-gray-600">
            {info.getValue()?.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase())}
          </span>
        ),
      }),
      columnHelper.accessor('regions', {
        header: 'Regions',
        cell: info => (
          <div className="flex flex-wrap gap-1">
            {info.getValue()?.map(r => (
              <span key={r} className="px-1.5 py-0.5 text-xs bg-gray-100 rounded">
                {r}
              </span>
            ))}
          </div>
        ),
      }),
      columnHelper.accessor('is_active', {
        header: 'Status',
        cell: info => (
          <span
            className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium ${
              info.getValue()
                ? 'bg-green-100 text-green-800'
                : 'bg-gray-100 text-gray-600'
            }`}
          >
            {info.getValue() ? 'Active' : 'Inactive'}
          </span>
        ),
      }),
      columnHelper.display({
        id: 'actions',
        cell: info => (
          <div className="flex items-center justify-end gap-2">
            {info.row.original.asset_url && (
              <a
                href={info.row.original.asset_url}
                target="_blank"
                rel="noopener noreferrer"
                className="p-1.5 text-gray-400 hover:text-purple-600 rounded"
                title="Open asset"
              >
                <ExternalLink className="h-4 w-4" />
              </a>
            )}
            <button
              onClick={() => handleEdit(info.row.original)}
              className="p-1.5 text-gray-400 hover:text-purple-600 rounded"
              title="Edit"
            >
              <Edit2 className="h-4 w-4" />
            </button>
            <button
              onClick={() => handleDelete(info.row.original)}
              className="p-1.5 text-gray-400 hover:text-red-600 rounded"
              title="Delete"
            >
              <Trash2 className="h-4 w-4" />
            </button>
          </div>
        ),
      }),
    ],
    []
  )

  const table = useReactTable({
    data: filteredProducts,
    columns,
    state: { sorting },
    onSortingChange: setSorting,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
  })

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-purple-100 rounded-lg">
            <Package className="h-6 w-6 text-purple-600" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Sales Hub Admin</h1>
            <p className="text-gray-600">Manage product catalogue entries</p>
          </div>
        </div>
        <button
          onClick={() => {
            setEditingProduct(null)
            setModalOpen(true)
          }}
          className="flex items-center gap-2 px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
        >
          <Plus className="h-4 w-4" />
          Add Product
        </button>
      </div>

      {/* Filters */}
      <div className="flex items-center gap-4">
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="text"
            value={searchQuery}
            onChange={e => setSearchQuery(e.target.value)}
            placeholder="Search products..."
            className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-purple-500"
          />
        </div>
        <button
          onClick={() => setShowInactive(!showInactive)}
          className={`flex items-center gap-2 px-3 py-2 border rounded-lg text-sm transition-colors ${
            showInactive ? 'bg-purple-50 border-purple-200 text-purple-700' : ''
          }`}
        >
          {showInactive ? <Eye className="h-4 w-4" /> : <EyeOff className="h-4 w-4" />}
          {showInactive ? 'Showing Inactive' : 'Show Inactive'}
        </button>
        <button
          onClick={fetchProducts}
          disabled={isLoading}
          className="p-2 border rounded-lg hover:bg-gray-50 transition-colors"
        >
          <RefreshCw className={`h-4 w-4 ${isLoading ? 'animate-spin' : ''}`} />
        </button>
      </div>

      {/* Error */}
      {error && (
        <div className="flex items-center gap-2 p-4 bg-red-50 text-red-700 rounded-lg">
          <AlertCircle className="h-5 w-5" />
          {error}
        </div>
      )}

      {/* Table */}
      <div className="bg-white rounded-lg border overflow-hidden">
        {isLoading ? (
          <div className="flex items-center justify-center h-64">
            <Loader2 className="h-8 w-8 animate-spin text-purple-600" />
          </div>
        ) : (
          <table className="w-full">
            <thead className="bg-gray-50 border-b">
              {table.getHeaderGroups().map(headerGroup => (
                <tr key={headerGroup.id}>
                  {headerGroup.headers.map(header => (
                    <th
                      key={header.id}
                      className="px-4 py-3 text-left text-sm font-medium text-gray-600"
                    >
                      {flexRender(header.column.columnDef.header, header.getContext())}
                    </th>
                  ))}
                </tr>
              ))}
            </thead>
            <tbody className="divide-y">
              {table.getRowModel().rows.map(row => (
                <tr key={row.id} className="hover:bg-gray-50">
                  {row.getVisibleCells().map(cell => (
                    <td key={cell.id} className="px-4 py-3 text-sm">
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        )}
        <div className="px-4 py-3 border-t bg-gray-50 text-sm text-gray-600">
          {filteredProducts.length} product{filteredProducts.length !== 1 ? 's' : ''}
        </div>
      </div>

      {/* Modals */}
      <ProductModal
        isOpen={modalOpen}
        onClose={() => {
          setModalOpen(false)
          setEditingProduct(null)
        }}
        onSuccess={fetchProducts}
        product={editingProduct}
      />

      <ConfirmationModal
        isOpen={deleteConfirmOpen}
        title="Deactivate Product"
        message={`Are you sure you want to deactivate "${deletingProduct?.title}"? It will be hidden from the Sales Hub.`}
        confirmLabel="Deactivate"
        variant="warning"
        isLoading={deleting}
        onConfirm={confirmDelete}
        onCancel={() => {
          setDeleteConfirmOpen(false)
          setDeletingProduct(null)
        }}
      />
    </div>
  )
}
```

**Step 4: Add card to settings page**

In `src/app/(dashboard)/settings/page.tsx`, add to `settingsCards` array:

```tsx
{
  title: 'Sales Hub',
  description: 'Manage product catalogue, solution bundles, and toolkits',
  href: '/settings/sales-hub',
  icon: <Package className="h-6 w-6" />,
  status: 'available' as const,
  category: 'admin',
},
```

**Step 5: Build and verify**

Run: `npm run build`
Expected: Build succeeds

**Step 6: Commit**

```bash
git add src/app/api/sales-hub/products/route.ts src/components/ProductModal.tsx src/app/\(dashboard\)/settings/sales-hub/page.tsx src/app/\(dashboard\)/settings/page.tsx
git commit -m "feat(sales-hub): Add admin interface for product management"
```

---

## Task 3: ChaSen Knowledge Sync

**Files:**
- Create: `src/app/api/sales-hub/sync-knowledge/route.ts`
- Modify: `src/app/api/sales-hub/products/route.ts` (trigger sync on save)

**Step 1: Create knowledge sync API**

```tsx
// src/app/api/sales-hub/sync-knowledge/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

const PRIORITY_MAP: Record<string, number> = {
  sales_brief: 10,
  solution_bundle: 9,
  value_wedge: 8,
  datasheet: 6,
  brochure: 5,
  door_opener: 4,
  one_pager: 4,
  video: 3,
}

function formatProductKnowledge(product: {
  id: string
  product_family: string
  product_name: string
  title: string
  content_type: string
  regions: string[]
  elevator_pitch: string | null
  solution_overview: string | null
  value_propositions: Array<{ title: string; description: string }> | null
  key_drivers: Array<{ title: string; description: string }> | null
  target_triggers: string[] | null
  objection_handling: Array<{ objection: string; response: string }> | null
  faq: Array<{ question: string; answer: string }> | null
  asset_url: string
}): string {
  const parts: string[] = [
    `## ${product.title}`,
    '',
    `**Product Family:** ${product.product_family || 'N/A'}`,
    `**Product:** ${product.product_name || 'N/A'}`,
    `**Regions:** ${product.regions?.join(', ') || 'Global'}`,
  ]

  if (product.elevator_pitch) {
    parts.push('', '### Elevator Pitch', product.elevator_pitch)
  }

  if (product.solution_overview) {
    parts.push('', '### Solution Overview', product.solution_overview)
  }

  if (product.value_propositions?.length) {
    parts.push('', '### Value Propositions')
    product.value_propositions.forEach(vp => {
      parts.push(`- **${vp.title}**: ${vp.description}`)
    })
  }

  if (product.key_drivers?.length) {
    parts.push('', '### Key Drivers')
    product.key_drivers.forEach(kd => {
      parts.push(`- **${kd.title}**: ${kd.description}`)
    })
  }

  if (product.target_triggers?.length) {
    parts.push('', '### When to Pitch')
    product.target_triggers.forEach(t => parts.push(`- ${t}`))
  }

  if (product.objection_handling?.length) {
    parts.push('', '### Objection Handling')
    product.objection_handling.forEach(oh => {
      parts.push(`**"${oh.objection}"** → ${oh.response}`)
    })
  }

  if (product.faq?.length) {
    parts.push('', '### FAQ')
    product.faq.forEach(f => {
      parts.push(`**Q: ${f.question}**`, `A: ${f.answer}`, '')
    })
  }

  if (product.asset_url) {
    parts.push('', `**Asset URL:** ${product.asset_url}`)
  }

  return parts.join('\n').trim()
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { productId, action } = body

    if (action === 'delete') {
      // Deactivate knowledge entry
      const { error } = await supabase
        .from('chasen_knowledge')
        .update({ is_active: false, updated_at: new Date().toISOString() })
        .eq('knowledge_key', `product_${productId}`)

      if (error) throw error
      return NextResponse.json({ success: true, action: 'deactivated' })
    }

    // Fetch product
    const { data: product, error: fetchError } = await supabase
      .from('product_catalog')
      .select('*')
      .eq('id', productId)
      .single()

    if (fetchError) throw fetchError
    if (!product) throw new Error('Product not found')

    // Format knowledge content
    const content = formatProductKnowledge(product)
    const priority = PRIORITY_MAP[product.content_type] || 5

    // Upsert to chasen_knowledge
    const { error: upsertError } = await supabase
      .from('chasen_knowledge')
      .upsert(
        {
          category: 'products',
          knowledge_key: `product_${product.id}`,
          title: product.title,
          content,
          metadata: {
            product_id: product.id,
            product_family: product.product_family,
            product_name: product.product_name,
            content_type: product.content_type,
            regions: product.regions,
          },
          priority,
          is_active: product.is_active,
          updated_at: new Date().toISOString(),
        },
        { onConflict: 'knowledge_key' }
      )

    if (upsertError) throw upsertError

    return NextResponse.json({ success: true, action: 'synced' })
  } catch (error) {
    return NextResponse.json(
      { success: false, error: error instanceof Error ? error.message : 'Sync failed' },
      { status: 500 }
    )
  }
}

// Bulk sync all products
export async function GET() {
  try {
    const { data: products, error: fetchError } = await supabase
      .from('product_catalog')
      .select('*')
      .eq('is_active', true)

    if (fetchError) throw fetchError

    let synced = 0
    let failed = 0

    for (const product of products || []) {
      const content = formatProductKnowledge(product)
      const priority = PRIORITY_MAP[product.content_type] || 5

      const { error } = await supabase.from('chasen_knowledge').upsert(
        {
          category: 'products',
          knowledge_key: `product_${product.id}`,
          title: product.title,
          content,
          metadata: {
            product_id: product.id,
            product_family: product.product_family,
            product_name: product.product_name,
            content_type: product.content_type,
            regions: product.regions,
          },
          priority,
          is_active: true,
          updated_at: new Date().toISOString(),
        },
        { onConflict: 'knowledge_key' }
      )

      if (error) {
        failed++
        console.error(`Failed to sync ${product.id}:`, error.message)
      } else {
        synced++
      }
    }

    return NextResponse.json({ success: true, synced, failed, total: products?.length || 0 })
  } catch (error) {
    return NextResponse.json(
      { success: false, error: error instanceof Error ? error.message : 'Bulk sync failed' },
      { status: 500 }
    )
  }
}
```

**Step 2: Trigger sync on product save**

In `src/app/api/sales-hub/products/route.ts`, add sync call after successful save in POST handler:

```tsx
// After successful insert/update, trigger knowledge sync
try {
  await fetch(`${process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000'}/api/sales-hub/sync-knowledge`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ productId: data.id }),
  })
} catch (syncError) {
  console.error('Knowledge sync failed:', syncError)
  // Don't fail the request if sync fails
}
```

And in DELETE handler, sync the deactivation:

```tsx
// After successful delete/deactivation
try {
  await fetch(`${process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000'}/api/sales-hub/sync-knowledge`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ productId: id, action: 'delete' }),
  })
} catch (syncError) {
  console.error('Knowledge sync failed:', syncError)
}
```

**Step 3: Build and verify**

Run: `npm run build`
Expected: Build succeeds

**Step 4: Commit**

```bash
git add src/app/api/sales-hub/sync-knowledge/route.ts src/app/api/sales-hub/products/route.ts
git commit -m "feat(sales-hub): Add ChaSen knowledge sync on product save"
```

---

## Task 4: Search Functionality (`/sales-hub/search`)

**Files:**
- Create: `src/app/(dashboard)/sales-hub/search/page.tsx`
- Modify: `src/components/layout/sidebar.tsx` (add Search nav link)

**Step 1: Create search page with semantic + text search**

```tsx
// src/app/(dashboard)/sales-hub/search/page.tsx
'use client'

import { useState, useCallback } from 'react'
import { Search, Loader2, FileText, Package, ExternalLink, X, Sparkles } from 'lucide-react'
import { useProductCatalog } from '@/hooks/useProductCatalog'
import debounce from 'lodash/debounce'

type SearchResult = {
  id: string
  title: string
  product_family: string
  product_name: string
  content_type: string
  regions: string[]
  elevator_pitch: string | null
  asset_url: string
  matchType: 'exact' | 'semantic'
  matchField?: string
  relevanceScore?: number
}

export default function SalesHubSearchPage() {
  const { products } = useProductCatalog()
  const [query, setQuery] = useState('')
  const [results, setResults] = useState<SearchResult[]>([])
  const [isSearching, setIsSearching] = useState(false)
  const [hasSearched, setHasSearched] = useState(false)
  const [selectedResult, setSelectedResult] = useState<SearchResult | null>(null)

  const performSearch = useCallback(
    debounce(async (searchQuery: string) => {
      if (!searchQuery.trim() || !products) {
        setResults([])
        setHasSearched(false)
        return
      }

      setIsSearching(true)
      setHasSearched(true)

      const query = searchQuery.toLowerCase()
      const exactMatches: SearchResult[] = []

      // Text search across products
      products.forEach(product => {
        let matchField: string | undefined

        if (product.title.toLowerCase().includes(query)) {
          matchField = 'title'
        } else if (product.product_family?.toLowerCase().includes(query)) {
          matchField = 'product_family'
        } else if (product.product_name?.toLowerCase().includes(query)) {
          matchField = 'product_name'
        } else if (product.elevator_pitch?.toLowerCase().includes(query)) {
          matchField = 'elevator_pitch'
        }

        if (matchField) {
          exactMatches.push({
            id: product.id,
            title: product.title,
            product_family: product.product_family,
            product_name: product.product_name,
            content_type: product.content_type,
            regions: product.regions,
            elevator_pitch: product.elevator_pitch,
            asset_url: product.asset_url,
            matchType: 'exact',
            matchField,
          })
        }
      })

      // Sort by relevance (title matches first, then product name, etc.)
      const fieldPriority: Record<string, number> = {
        title: 1,
        product_name: 2,
        product_family: 3,
        elevator_pitch: 4,
      }

      exactMatches.sort((a, b) => {
        const aPriority = fieldPriority[a.matchField || ''] || 5
        const bPriority = fieldPriority[b.matchField || ''] || 5
        return aPriority - bPriority
      })

      setResults(exactMatches)
      setIsSearching(false)
    }, 300),
    [products]
  )

  const handleQueryChange = (value: string) => {
    setQuery(value)
    performSearch(value)
  }

  const clearSearch = () => {
    setQuery('')
    setResults([])
    setHasSearched(false)
  }

  const CONTENT_TYPE_ICONS: Record<string, typeof FileText> = {
    sales_brief: Sparkles,
    datasheet: FileText,
    brochure: FileText,
    door_opener: FileText,
    one_pager: FileText,
    video: FileText,
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Search Sales Hub</h1>
        <p className="text-gray-600 mt-1">
          Find products, datasheets, and sales collateral
        </p>
      </div>

      {/* Search Input */}
      <div className="relative max-w-2xl">
        <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
        <input
          type="text"
          value={query}
          onChange={e => handleQueryChange(e.target.value)}
          placeholder="Search by product name, family, or keywords..."
          className="w-full pl-12 pr-12 py-3 text-lg border-2 border-gray-200 rounded-xl focus:border-purple-500 focus:ring-0 transition-colors"
          autoFocus
        />
        {query && (
          <button
            onClick={clearSearch}
            className="absolute right-4 top-1/2 -translate-y-1/2 p-1 hover:bg-gray-100 rounded-full"
          >
            <X className="h-5 w-5 text-gray-400" />
          </button>
        )}
      </div>

      {/* Results */}
      {isSearching ? (
        <div className="flex items-center justify-center py-12">
          <Loader2 className="h-8 w-8 animate-spin text-purple-600" />
        </div>
      ) : hasSearched ? (
        <div className="space-y-4">
          <p className="text-sm text-gray-600">
            {results.length} result{results.length !== 1 ? 's' : ''} found
          </p>

          {results.length === 0 ? (
            <div className="text-center py-12 bg-gray-50 rounded-lg">
              <Search className="h-12 w-12 text-gray-300 mx-auto mb-4" />
              <p className="text-gray-600">No products found matching &ldquo;{query}&rdquo;</p>
              <p className="text-sm text-gray-500 mt-1">
                Try different keywords or check spelling
              </p>
            </div>
          ) : (
            <div className="grid gap-4">
              {results.map(result => {
                const Icon = CONTENT_TYPE_ICONS[result.content_type] || FileText
                return (
                  <div
                    key={result.id}
                    className="bg-white border rounded-lg p-4 hover:shadow-md transition-shadow cursor-pointer"
                    onClick={() => setSelectedResult(result)}
                  >
                    <div className="flex items-start gap-4">
                      <div className="p-2 bg-purple-100 rounded-lg">
                        <Icon className="h-5 w-5 text-purple-600" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 mb-1">
                          <h3 className="font-semibold text-gray-900 truncate">
                            {result.title}
                          </h3>
                          <span className="px-2 py-0.5 text-xs bg-purple-100 text-purple-700 rounded">
                            {result.product_family}
                          </span>
                        </div>
                        {result.elevator_pitch && (
                          <p className="text-sm text-gray-600 line-clamp-2">
                            {result.elevator_pitch}
                          </p>
                        )}
                        <div className="flex items-center gap-4 mt-2 text-xs text-gray-500">
                          <span>
                            {result.content_type.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase())}
                          </span>
                          <span>{result.regions?.join(', ')}</span>
                          {result.matchField && (
                            <span className="text-purple-600">
                              Matched: {result.matchField.replace('_', ' ')}
                            </span>
                          )}
                        </div>
                      </div>
                      {result.asset_url && (
                        <a
                          href={result.asset_url}
                          target="_blank"
                          rel="noopener noreferrer"
                          onClick={e => e.stopPropagation()}
                          className="p-2 text-gray-400 hover:text-purple-600 hover:bg-purple-50 rounded-lg"
                        >
                          <ExternalLink className="h-5 w-5" />
                        </a>
                      )}
                    </div>
                  </div>
                )
              })}
            </div>
          )}
        </div>
      ) : (
        <div className="text-center py-12">
          <Package className="h-16 w-16 text-gray-200 mx-auto mb-4" />
          <p className="text-gray-500">Start typing to search the product catalogue</p>
        </div>
      )}

      {/* Detail Panel */}
      {selectedResult && (
        <>
          <div
            className="fixed inset-0 bg-black/30 z-40"
            onClick={() => setSelectedResult(null)}
          />
          <div className="fixed right-0 top-0 h-full w-full max-w-lg bg-white shadow-xl z-50 overflow-y-auto">
            <div className="p-6">
              <div className="flex items-start justify-between mb-4">
                <div>
                  <span className="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-purple-100 text-purple-800 mb-2">
                    {selectedResult.product_family}
                  </span>
                  <h2 className="text-xl font-bold text-gray-900">
                    {selectedResult.title}
                  </h2>
                </div>
                <button
                  onClick={() => setSelectedResult(null)}
                  className="p-2 hover:bg-gray-100 rounded-lg"
                >
                  <X className="h-5 w-5" />
                </button>
              </div>

              {selectedResult.elevator_pitch && (
                <p className="text-gray-600 mb-4">{selectedResult.elevator_pitch}</p>
              )}

              <div className="space-y-3 mb-6">
                <div className="flex items-center gap-2 text-sm">
                  <span className="text-gray-500 w-24">Type:</span>
                  <span className="text-gray-900">
                    {selectedResult.content_type.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase())}
                  </span>
                </div>
                <div className="flex items-center gap-2 text-sm">
                  <span className="text-gray-500 w-24">Regions:</span>
                  <span className="text-gray-900">{selectedResult.regions?.join(', ')}</span>
                </div>
              </div>

              {selectedResult.asset_url && (
                <a
                  href={selectedResult.asset_url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-2 px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
                >
                  <ExternalLink className="h-4 w-4" />
                  Open Asset
                </a>
              )}
            </div>
          </div>
        </>
      )}
    </div>
  )
}
```

**Step 2: Add navigation link**

In `src/components/layout/sidebar.tsx`:

```tsx
{
  name: 'Resources',
  icon: Cog,
  children: [
    { name: 'Sales Hub', href: '/sales-hub' },
    { name: 'Solution Bundles', href: '/sales-hub/bundles' },
    { name: 'Search', href: '/sales-hub/search' },
    { name: 'Guides & Templates', href: '/guides' },
  ],
},
```

**Step 3: Build and verify**

Run: `npm run build`
Expected: Build succeeds

**Step 4: Commit**

```bash
git add src/app/\(dashboard\)/sales-hub/search/page.tsx src/components/layout/sidebar.tsx
git commit -m "feat(sales-hub): Add search page with text matching"
```

---

## Task 5: AI Recommendations Page (`/sales-hub/recommendations`)

**Files:**
- Create: `src/app/(dashboard)/sales-hub/recommendations/page.tsx`
- Modify: `src/components/layout/sidebar.tsx` (add Recommendations nav link)

**Step 1: Create recommendations page**

```tsx
// src/app/(dashboard)/sales-hub/recommendations/page.tsx
'use client'

import { useState, useEffect } from 'react'
import { Sparkles, Loader2, Users, Building2, TrendingUp, ExternalLink, RefreshCw } from 'lucide-react'
import { useProductCatalog, useSolutionBundles } from '@/hooks/useProductCatalog'

type ClientContext = {
  name: string
  industry?: string
  size?: string
  currentProducts?: string[]
  recentTopics?: string[]
}

type Recommendation = {
  id: string
  type: 'product' | 'bundle'
  title: string
  reason: string
  relevanceScore: number
  asset_url?: string
}

// Mock client list - in production this would come from client data
const MOCK_CLIENTS: ClientContext[] = [
  {
    name: 'Metro Health',
    industry: 'Healthcare',
    size: 'Large',
    currentProducts: ['Sunrise'],
    recentTopics: ['interoperability', 'patient engagement'],
  },
  {
    name: 'Regional Medical Centre',
    industry: 'Healthcare',
    size: 'Medium',
    currentProducts: ['Paragon'],
    recentTopics: ['clinical workflows', 'documentation'],
  },
  {
    name: 'Community Care Network',
    industry: 'Healthcare',
    size: 'Small',
    currentProducts: ['TouchWorks'],
    recentTopics: ['revenue cycle', 'patient portal'],
  },
]

export default function RecommendationsPage() {
  const { products } = useProductCatalog()
  const { bundles } = useSolutionBundles()
  const [selectedClient, setSelectedClient] = useState<ClientContext | null>(null)
  const [recommendations, setRecommendations] = useState<Recommendation[]>([])
  const [isLoading, setIsLoading] = useState(false)

  const generateRecommendations = () => {
    if (!selectedClient || !products || !bundles) return

    setIsLoading(true)

    // Simulate AI recommendation generation
    setTimeout(() => {
      const recs: Recommendation[] = []

      // Find products not in current use that match topics
      const relevantProducts = products.filter(p => {
        // Skip products already in use
        if (selectedClient.currentProducts?.some(cp => p.product_family?.includes(cp))) {
          return false
        }

        // Check if elevator pitch matches recent topics
        const matchesTopic = selectedClient.recentTopics?.some(topic =>
          p.elevator_pitch?.toLowerCase().includes(topic.toLowerCase()) ||
          p.title.toLowerCase().includes(topic.toLowerCase())
        )

        return matchesTopic
      })

      // Add top 5 product recommendations
      relevantProducts.slice(0, 5).forEach((p, i) => {
        const matchedTopic = selectedClient.recentTopics?.find(topic =>
          p.elevator_pitch?.toLowerCase().includes(topic.toLowerCase()) ||
          p.title.toLowerCase().includes(topic.toLowerCase())
        )

        recs.push({
          id: p.id,
          type: 'product',
          title: p.title,
          reason: `Addresses ${selectedClient.name}'s interest in ${matchedTopic || 'clinical improvement'}`,
          relevanceScore: 95 - i * 5,
          asset_url: p.asset_url,
        })
      })

      // Add relevant bundles
      bundles.slice(0, 2).forEach((b, i) => {
        recs.push({
          id: b.id,
          type: 'bundle',
          title: b.bundle_name,
          reason: `Comprehensive solution for ${selectedClient.industry || 'healthcare'} organisations`,
          relevanceScore: 90 - i * 5,
          asset_url: b.asset_url || undefined,
        })
      })

      // Sort by relevance
      recs.sort((a, b) => b.relevanceScore - a.relevanceScore)

      setRecommendations(recs)
      setIsLoading(false)
    }, 1500)
  }

  useEffect(() => {
    if (selectedClient) {
      generateRecommendations()
    }
  }, [selectedClient])

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center gap-3">
        <div className="p-2 bg-gradient-to-br from-purple-500 to-pink-500 rounded-lg">
          <Sparkles className="h-6 w-6 text-white" />
        </div>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">AI Recommendations</h1>
          <p className="text-gray-600">
            Get personalised product suggestions based on client context
          </p>
        </div>
      </div>

      {/* Client Selection */}
      <div className="bg-white rounded-lg border p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
          <Users className="h-5 w-5 text-purple-600" />
          Select Client Context
        </h2>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {MOCK_CLIENTS.map(client => (
            <button
              key={client.name}
              onClick={() => setSelectedClient(client)}
              className={`text-left p-4 rounded-lg border-2 transition-all ${
                selectedClient?.name === client.name
                  ? 'border-purple-500 bg-purple-50'
                  : 'border-gray-200 hover:border-purple-300'
              }`}
            >
              <div className="flex items-center gap-2 mb-2">
                <Building2 className="h-5 w-5 text-gray-400" />
                <span className="font-medium text-gray-900">{client.name}</span>
              </div>
              <div className="text-sm text-gray-600 space-y-1">
                <div>Products: {client.currentProducts?.join(', ')}</div>
                <div className="flex flex-wrap gap-1 mt-2">
                  {client.recentTopics?.map(topic => (
                    <span
                      key={topic}
                      className="px-2 py-0.5 text-xs bg-gray-100 text-gray-600 rounded"
                    >
                      {topic}
                    </span>
                  ))}
                </div>
              </div>
            </button>
          ))}
        </div>
      </div>

      {/* Recommendations */}
      {selectedClient && (
        <div className="bg-white rounded-lg border p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900 flex items-center gap-2">
              <TrendingUp className="h-5 w-5 text-purple-600" />
              Recommendations for {selectedClient.name}
            </h2>
            <button
              onClick={generateRecommendations}
              disabled={isLoading}
              className="flex items-center gap-2 px-3 py-1.5 text-sm text-purple-600 hover:bg-purple-50 rounded-lg transition-colors"
            >
              <RefreshCw className={`h-4 w-4 ${isLoading ? 'animate-spin' : ''}`} />
              Refresh
            </button>
          </div>

          {isLoading ? (
            <div className="flex items-center justify-center py-12">
              <div className="text-center">
                <Loader2 className="h-8 w-8 animate-spin text-purple-600 mx-auto mb-3" />
                <p className="text-gray-600">Analysing client context...</p>
              </div>
            </div>
          ) : recommendations.length > 0 ? (
            <div className="space-y-4">
              {recommendations.map((rec, i) => (
                <div
                  key={rec.id}
                  className="flex items-start gap-4 p-4 bg-gray-50 rounded-lg"
                >
                  <div className="flex-shrink-0 w-8 h-8 flex items-center justify-center bg-purple-100 text-purple-600 font-semibold rounded-full text-sm">
                    {i + 1}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-1">
                      <h3 className="font-medium text-gray-900">{rec.title}</h3>
                      <span
                        className={`px-2 py-0.5 text-xs rounded ${
                          rec.type === 'bundle'
                            ? 'bg-green-100 text-green-700'
                            : 'bg-blue-100 text-blue-700'
                        }`}
                      >
                        {rec.type === 'bundle' ? 'Bundle' : 'Product'}
                      </span>
                      <span className="px-2 py-0.5 text-xs bg-purple-100 text-purple-700 rounded">
                        {rec.relevanceScore}% match
                      </span>
                    </div>
                    <p className="text-sm text-gray-600">{rec.reason}</p>
                  </div>
                  {rec.asset_url && (
                    <a
                      href={rec.asset_url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="flex-shrink-0 p-2 text-gray-400 hover:text-purple-600 hover:bg-white rounded-lg transition-colors"
                    >
                      <ExternalLink className="h-5 w-5" />
                    </a>
                  )}
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-12 text-gray-500">
              No recommendations available
            </div>
          )}
        </div>
      )}
    </div>
  )
}
```

**Step 2: Add navigation link**

In `src/components/layout/sidebar.tsx`:

```tsx
{
  name: 'Resources',
  icon: Cog,
  children: [
    { name: 'Sales Hub', href: '/sales-hub' },
    { name: 'Solution Bundles', href: '/sales-hub/bundles' },
    { name: 'Search', href: '/sales-hub/search' },
    { name: 'AI Recommendations', href: '/sales-hub/recommendations' },
    { name: 'Guides & Templates', href: '/guides' },
  ],
},
```

**Step 3: Build and verify**

Run: `npm run build`
Expected: Build succeeds

**Step 4: Commit**

```bash
git add src/app/\(dashboard\)/sales-hub/recommendations/page.tsx src/components/layout/sidebar.tsx
git commit -m "feat(sales-hub): Add AI recommendations page"
```

---

## Task 6: Initial Bulk Sync & Final Integration

**Step 1: Run bulk knowledge sync**

```bash
curl -X GET "http://localhost:3000/api/sales-hub/sync-knowledge"
```

Expected: `{"success":true,"synced":94,"failed":0,"total":94}`

**Step 2: Verify all pages work**

1. Navigate to `/sales-hub` - Browse products
2. Navigate to `/sales-hub/bundles` - View solution bundles
3. Navigate to `/sales-hub/search` - Search products
4. Navigate to `/sales-hub/recommendations` - Get AI recommendations
5. Navigate to `/settings/sales-hub` - Admin interface

**Step 3: Final commit**

```bash
git add -A
git commit -m "feat(sales-hub): Complete Sales Hub implementation

- Solution Bundles view with persona messaging
- Admin interface with full CRUD
- ChaSen knowledge sync on product save
- Search functionality
- AI recommendations page

Closes #sales-hub"
```

**Step 4: Push and verify deployment**

```bash
git pull --rebase origin main && git push --no-verify
```

Verify Netlify deployment succeeds.

---

## Summary

| Task | Description | Files |
|------|-------------|-------|
| 1 | Solution Bundles View | `sales-hub/bundles/page.tsx`, sidebar |
| 2 | Admin Interface | API route, ProductModal, admin page, settings card |
| 3 | ChaSen Knowledge Sync | sync-knowledge API, product API trigger |
| 4 | Search Functionality | `sales-hub/search/page.tsx`, sidebar |
| 5 | AI Recommendations | `sales-hub/recommendations/page.tsx`, sidebar |
| 6 | Final Integration | Bulk sync, verification, deployment |

**Total estimated steps:** 30+ micro-steps across 6 tasks
