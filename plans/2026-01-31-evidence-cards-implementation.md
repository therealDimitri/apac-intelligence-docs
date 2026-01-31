# Evidence Cards Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add transparent, data-backed Evidence Cards to recommendations showing why each product/bundle was suggested.

**Architecture:** Enhance `useClientContext` to fetch NPS verbatims and topic counts. Create new `RecommendationCard` component with expand/collapse behaviour. Update recommendation algorithm to return structured evidence breakdown.

**Tech Stack:** React, TypeScript, Supabase, Tailwind CSS, Lucide icons

---

## Task 1: Extend ClientContext Type and Hook

**Files:**
- Modify: `src/hooks/useClientContext.ts`

**Step 1: Add new fields to ClientContext type**

Add at line 20 (after `recentTopics: string[]`):

```typescript
export type ClientContext = {
  id: number
  name: string
  arr_usd: number | null
  health_score: number | null
  health_status: string | null
  currentProducts: string[]
  recentTopics: string[]
  // New fields for evidence
  npsVerbatims: Array<{
    feedback: string
    score: number
    period: string
  }>
  meetingTopicCounts: Record<string, number>
  arrTier: 'enterprise' | 'mid-market' | 'standard'
}
```

**Step 2: Fetch NPS verbatims in useClientContext**

Add after the health query (after line 57):

```typescript
// Fetch NPS verbatims (last 12 months)
const { data: npsResponses } = await supabase
  .from('nps_responses')
  .select('client_name, feedback, score, period')
  .not('feedback', 'is', null)
  .neq('feedback', '')
```

**Step 3: Build NPS verbatims map**

Add after healthMap construction (after line 87):

```typescript
// Build NPS verbatims map by client
const npsMap = new Map<string, Array<{ feedback: string; score: number; period: string }>>()
npsResponses?.forEach(n => {
  if (n.feedback && n.feedback.trim()) {
    const existing = npsMap.get(n.client_name) || []
    existing.push({ feedback: n.feedback, score: n.score, period: n.period })
    npsMap.set(n.client_name, existing)
  }
})
```

**Step 4: Build topic counts map**

Add after npsMap:

```typescript
// Build topic counts map by client
const topicCountsMap = new Map<string, Record<string, number>>()
meetings?.forEach(m => {
  if (m.topics?.length && m.client_name) {
    const existing = topicCountsMap.get(m.client_name) || {}
    m.topics.forEach((t: string) => {
      existing[t] = (existing[t] || 0) + 1
    })
    topicCountsMap.set(m.client_name, existing)
  }
})
```

**Step 5: Update enrichedClients mapping**

Update the map function (starting line 90) to include new fields:

```typescript
const enrichedClients: ClientContext[] = (npsClients || []).map(c => {
  const arr = c.arr_usd || 0
  const arrTier: 'enterprise' | 'mid-market' | 'standard' =
    arr > 1000000 ? 'enterprise' : arr > 200000 ? 'mid-market' : 'standard'

  return {
    id: c.id,
    name: c.client_name,
    arr_usd: c.arr_usd,
    health_score: healthMap.get(c.client_name)?.score || null,
    health_status: healthMap.get(c.client_name)?.status || null,
    currentProducts: productMap.get(c.client_name) || [],
    recentTopics: topicsMap.get(c.client_name) || [],
    npsVerbatims: npsMap.get(c.client_name) || [],
    meetingTopicCounts: topicCountsMap.get(c.client_name) || {},
    arrTier,
  }
})
```

**Step 6: Build and verify**

Run: `npm run build`
Expected: Build succeeds with no TypeScript errors

**Step 7: Commit**

```bash
git add src/hooks/useClientContext.ts
git commit -m "feat(sales-hub): extend ClientContext with NPS verbatims and topic counts"
```

---

## Task 2: Create Evidence Types

**Files:**
- Create: `src/types/recommendation-evidence.ts`

**Step 1: Create the types file**

```typescript
/**
 * Types for recommendation evidence and scoring breakdown
 */

export type EvidenceFactor = {
  name: string
  score: number
  maxScore: number
  detail: string
  matched?: boolean
}

export type RecommendationEvidence = {
  factors: {
    topicMatch: {
      matched: string[]
      meetingCount: number
      score: number
    }
    npsMatch: {
      verbatim: string | null
      period: string | null
      score: number
    }
    healthPriority: {
      status: string | null
      reason: string
      score: number
    }
    arrTier: {
      tier: 'enterprise' | 'mid-market' | 'standard'
      amount: number | null
      score: number
    }
    stackGap: {
      missing: boolean
      currentStack: string[]
      score: number
    }
  }
  proofPoints: string[]
  similarClientCount: number
  targetPersonas: string[]
  totalScore: number
}

export type EnrichedRecommendation = {
  id: string
  type: 'product' | 'bundle'
  title: string
  reason: string
  relevanceScore: number
  asset_url?: string
  evidence: RecommendationEvidence
}
```

**Step 2: Build and verify**

Run: `npm run build`
Expected: Build succeeds

**Step 3: Commit**

```bash
git add src/types/recommendation-evidence.ts
git commit -m "feat(sales-hub): add RecommendationEvidence types"
```

---

## Task 3: Create EvidenceCard Component

**Files:**
- Create: `src/components/sales-hub/EvidenceCard.tsx`

**Step 1: Create the component**

```tsx
'use client'

import { useState } from 'react'
import {
  ChevronDown,
  ChevronUp,
  CheckCircle2,
  Circle,
  MessageSquareQuote,
  Target,
  TrendingUp,
  ExternalLink,
  Plus,
  Loader2,
} from 'lucide-react'
import { EnrichedRecommendation } from '@/types/recommendation-evidence'

type Props = {
  recommendation: EnrichedRecommendation
  rank: number
  defaultExpanded?: boolean
  onAddToPlan?: () => void
  isAddingToPlan?: boolean
}

export function EvidenceCard({
  recommendation,
  rank,
  defaultExpanded = false,
  onAddToPlan,
  isAddingToPlan,
}: Props) {
  const [expanded, setExpanded] = useState(defaultExpanded)
  const { evidence } = recommendation

  const factorsList = [
    {
      name: 'Topic match',
      score: evidence.factors.topicMatch.score,
      max: 30,
      detail:
        evidence.factors.topicMatch.matched.length > 0
          ? `"${evidence.factors.topicMatch.matched[0]}" — ${evidence.factors.topicMatch.meetingCount} meetings`
          : 'No topic matches',
      matched: evidence.factors.topicMatch.score > 0,
    },
    {
      name: 'NPS feedback',
      score: evidence.factors.npsMatch.score,
      max: 20,
      detail: evidence.factors.npsMatch.verbatim
        ? 'Client mentioned relevant needs'
        : 'No relevant feedback',
      matched: evidence.factors.npsMatch.score > 0,
    },
    {
      name: 'Health priority',
      score: evidence.factors.healthPriority.score,
      max: 20,
      detail: evidence.factors.healthPriority.reason,
      matched: evidence.factors.healthPriority.score > 0,
    },
    {
      name: 'ARR tier',
      score: evidence.factors.arrTier.score,
      max: 10,
      detail: `${evidence.factors.arrTier.tier} client`,
      matched: evidence.factors.arrTier.score > 0,
    },
    {
      name: 'Stack gap',
      score: evidence.factors.stackGap.score,
      max: 10,
      detail: evidence.factors.stackGap.missing
        ? 'Not in current deployment'
        : 'Already deployed',
      matched: evidence.factors.stackGap.score > 0,
    },
  ]

  return (
    <div className="bg-white border rounded-lg overflow-hidden">
      {/* Header - Always visible */}
      <button
        onClick={() => setExpanded(!expanded)}
        className="w-full flex items-center gap-4 p-4 hover:bg-gray-50 transition-colors text-left"
      >
        <div className="flex-shrink-0 w-8 h-8 flex items-center justify-center bg-purple-100 text-purple-600 font-semibold rounded-full text-sm">
          {rank}
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2">
            <h3 className="font-medium text-gray-900">{recommendation.title}</h3>
            <span
              className={`px-2 py-0.5 text-xs rounded ${
                recommendation.type === 'bundle'
                  ? 'bg-green-100 text-green-700'
                  : 'bg-blue-100 text-blue-700'
              }`}
            >
              {recommendation.type === 'bundle' ? 'Bundle' : 'Product'}
            </span>
            <span className="px-2 py-0.5 text-xs bg-purple-100 text-purple-700 rounded">
              {recommendation.relevanceScore}% match
            </span>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {recommendation.asset_url && (
            <a
              href={recommendation.asset_url}
              target="_blank"
              rel="noopener noreferrer"
              onClick={e => e.stopPropagation()}
              className="p-2 text-gray-400 hover:text-purple-600 hover:bg-purple-50 rounded-lg transition-colors"
              title="Open Asset"
            >
              <ExternalLink className="h-4 w-4" />
            </a>
          )}
          {onAddToPlan && (
            <button
              onClick={e => {
                e.stopPropagation()
                onAddToPlan()
              }}
              disabled={isAddingToPlan}
              className="p-2 text-gray-400 hover:text-green-600 hover:bg-green-50 rounded-lg transition-colors disabled:opacity-50"
              title="Add to Account Plan"
            >
              {isAddingToPlan ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <Plus className="h-4 w-4" />
              )}
            </button>
          )}
          {expanded ? (
            <ChevronUp className="h-5 w-5 text-gray-400" />
          ) : (
            <ChevronDown className="h-5 w-5 text-gray-400" />
          )}
        </div>
      </button>

      {/* Expanded content */}
      {expanded && (
        <div className="border-t px-4 py-4 space-y-4 bg-gray-50">
          {/* WHY THIS MATCHES */}
          <div>
            <h4 className="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2 flex items-center gap-1">
              <Target className="h-3.5 w-3.5" />
              Why This Matches
            </h4>
            <div className="bg-white rounded-lg border p-3 space-y-2">
              {factorsList.map(factor => (
                <div key={factor.name} className="flex items-center gap-2 text-sm">
                  {factor.matched ? (
                    <CheckCircle2 className="h-4 w-4 text-green-600 flex-shrink-0" />
                  ) : (
                    <Circle className="h-4 w-4 text-gray-300 flex-shrink-0" />
                  )}
                  <span
                    className={factor.matched ? 'text-gray-900' : 'text-gray-400'}
                  >
                    {factor.name}
                  </span>
                  <span className="text-gray-400">—</span>
                  <span
                    className={factor.matched ? 'text-gray-600' : 'text-gray-400'}
                  >
                    {factor.detail}
                  </span>
                </div>
              ))}
            </div>
          </div>

          {/* SCORE BREAKDOWN */}
          <div>
            <h4 className="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2 flex items-center gap-1">
              <TrendingUp className="h-3.5 w-3.5" />
              Score Breakdown
            </h4>
            <div className="bg-white rounded-lg border p-3">
              <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                {factorsList.map(factor => (
                  <div key={factor.name} className="space-y-1">
                    <div className="flex justify-between text-xs">
                      <span className="text-gray-600">{factor.name}</span>
                      <span className="text-gray-900 font-medium">
                        {factor.score}/{factor.max}
                      </span>
                    </div>
                    <div className="h-2 bg-purple-100 rounded-full overflow-hidden">
                      <div
                        className="h-full bg-purple-600 rounded-full transition-all"
                        style={{ width: `${(factor.score / factor.max) * 100}%` }}
                      />
                    </div>
                  </div>
                ))}
              </div>
              <div className="mt-3 pt-3 border-t flex justify-between items-center">
                <span className="text-sm text-gray-600">Total Score</span>
                <span className="text-lg font-semibold text-purple-600">
                  {evidence.totalScore}/100
                </span>
              </div>
            </div>
          </div>

          {/* CLIENT FEEDBACK */}
          {evidence.factors.npsMatch.verbatim && (
            <div>
              <h4 className="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2 flex items-center gap-1">
                <MessageSquareQuote className="h-3.5 w-3.5" />
                Client Feedback
              </h4>
              <div className="bg-blue-50 border-l-4 border-blue-400 rounded-r-lg p-3">
                <p className="text-sm text-gray-700 italic">
                  &quot;{evidence.factors.npsMatch.verbatim}&quot;
                </p>
                {evidence.factors.npsMatch.period && (
                  <p className="text-xs text-gray-500 mt-1">
                    — {evidence.factors.npsMatch.period} NPS
                  </p>
                )}
              </div>
            </div>
          )}

          {/* EVIDENCE */}
          {(evidence.proofPoints.length > 0 ||
            evidence.similarClientCount > 0 ||
            evidence.targetPersonas.length > 0) && (
            <div>
              <h4 className="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2">
                💡 Evidence
              </h4>
              <ul className="text-sm text-gray-600 space-y-1">
                {evidence.proofPoints.slice(0, 2).map((point, i) => (
                  <li key={i} className="flex items-start gap-2">
                    <span className="text-gray-400">•</span>
                    <span>{point}</span>
                  </li>
                ))}
                {evidence.similarClientCount > 0 && (
                  <li className="flex items-start gap-2">
                    <span className="text-gray-400">•</span>
                    <span>
                      {evidence.similarClientCount} similar APAC clients using this
                      product
                    </span>
                  </li>
                )}
                {evidence.targetPersonas.length > 0 && (
                  <li className="flex items-start gap-2">
                    <span className="text-gray-400">•</span>
                    <span>
                      Target personas: {evidence.targetPersonas.join(', ')} — aligns
                      with your stakeholders
                    </span>
                  </li>
                )}
              </ul>
            </div>
          )}
        </div>
      )}
    </div>
  )
}
```

**Step 2: Build and verify**

Run: `npm run build`
Expected: Build succeeds

**Step 3: Commit**

```bash
git add src/components/sales-hub/EvidenceCard.tsx
git commit -m "feat(sales-hub): create EvidenceCard component"
```

---

## Task 4: Create Evidence Generation Logic

**Files:**
- Create: `src/lib/recommendation-evidence.ts`

**Step 1: Create the evidence generator**

```typescript
/**
 * Generate evidence breakdown for recommendations
 */

import { ClientContext } from '@/hooks/useClientContext'
import { RecommendationEvidence, EnrichedRecommendation } from '@/types/recommendation-evidence'
import { ValueWedge } from '@/hooks/useValueWedges'

type Product = {
  id: string
  title: string
  elevator_pitch?: string
  product_family?: string
  asset_url?: string
}

type Bundle = {
  id: string
  bundle_name: string
  tagline?: string
  what_it_does?: string
  what_it_is?: string
  market_drivers?: string[]
  asset_url?: string | null
}

/**
 * Calculate evidence-based score for a product recommendation
 */
export function calculateProductEvidence(
  product: Product,
  client: ClientContext,
  wedge: ValueWedge | null,
  similarClientCount: number
): RecommendationEvidence {
  const factors = {
    topicMatch: calculateTopicMatch(product, client),
    npsMatch: calculateNpsMatch(product, client),
    healthPriority: calculateHealthPriority(client),
    arrTier: calculateArrTier(client),
    stackGap: calculateStackGap(product, client),
  }

  const totalScore =
    factors.topicMatch.score +
    factors.npsMatch.score +
    factors.healthPriority.score +
    factors.arrTier.score +
    factors.stackGap.score +
    10 // Base score

  return {
    factors,
    proofPoints: wedge?.defensible_proof || [],
    similarClientCount,
    targetPersonas: wedge?.target_personas || [],
    totalScore: Math.min(totalScore, 100),
  }
}

/**
 * Calculate evidence-based score for a bundle recommendation
 */
export function calculateBundleEvidence(
  bundle: Bundle,
  client: ClientContext,
  similarClientCount: number
): RecommendationEvidence {
  const factors = {
    topicMatch: calculateBundleTopicMatch(bundle, client),
    npsMatch: calculateNpsMatch({ title: bundle.bundle_name, elevator_pitch: bundle.what_it_does }, client),
    healthPriority: calculateHealthPriority(client),
    arrTier: calculateArrTier(client),
    stackGap: { missing: true, currentStack: client.currentProducts, score: 10 }, // Bundles always count as gap
  }

  const totalScore =
    factors.topicMatch.score +
    factors.npsMatch.score +
    factors.healthPriority.score +
    factors.arrTier.score +
    factors.stackGap.score +
    10 // Base score

  return {
    factors,
    proofPoints: [],
    similarClientCount,
    targetPersonas: [],
    totalScore: Math.min(totalScore, 100),
  }
}

function calculateTopicMatch(
  product: Product,
  client: ClientContext
): RecommendationEvidence['factors']['topicMatch'] {
  const matched: string[] = []
  let meetingCount = 0

  const productText = `${product.title} ${product.elevator_pitch || ''}`.toLowerCase()

  Object.entries(client.meetingTopicCounts).forEach(([topic, count]) => {
    if (productText.includes(topic.toLowerCase())) {
      matched.push(topic)
      meetingCount += count
    }
  })

  // Score: up to 30 points based on matches
  const score = matched.length > 0 ? Math.min(30, matched.length * 10 + meetingCount * 2) : 0

  return { matched, meetingCount, score }
}

function calculateBundleTopicMatch(
  bundle: Bundle,
  client: ClientContext
): RecommendationEvidence['factors']['topicMatch'] {
  const matched: string[] = []
  let meetingCount = 0

  const bundleText =
    `${bundle.bundle_name} ${bundle.tagline || ''} ${bundle.what_it_does || ''} ${(bundle.market_drivers || []).join(' ')}`.toLowerCase()

  Object.entries(client.meetingTopicCounts).forEach(([topic, count]) => {
    if (bundleText.includes(topic.toLowerCase())) {
      matched.push(topic)
      meetingCount += count
    }
  })

  const score = matched.length > 0 ? Math.min(30, matched.length * 10 + meetingCount * 2) : 0

  return { matched, meetingCount, score }
}

function calculateNpsMatch(
  item: { title: string; elevator_pitch?: string },
  client: ClientContext
): RecommendationEvidence['factors']['npsMatch'] {
  const itemText = `${item.title} ${item.elevator_pitch || ''}`.toLowerCase()

  // Keywords to look for in NPS feedback that might indicate a need
  const keywords = [
    'documentation',
    'interoperability',
    'integration',
    'workflow',
    'efficiency',
    'time',
    'clinical',
    'patient',
    'data',
    'reporting',
    'analytics',
    'mobile',
    'remote',
  ]

  for (const nps of client.npsVerbatims) {
    const feedbackLower = nps.feedback.toLowerCase()
    // Check if feedback mentions relevant keywords
    const hasRelevantKeyword = keywords.some(
      kw => feedbackLower.includes(kw) && itemText.includes(kw)
    )
    if (hasRelevantKeyword) {
      return {
        verbatim: nps.feedback,
        period: nps.period,
        score: 20,
      }
    }
  }

  return { verbatim: null, period: null, score: 0 }
}

function calculateHealthPriority(
  client: ClientContext
): RecommendationEvidence['factors']['healthPriority'] {
  if (client.health_status === 'critical') {
    return {
      status: 'critical',
      reason: 'Critical client → retention focus',
      score: 20,
    }
  }
  if (client.health_status === 'at-risk') {
    return {
      status: 'at-risk',
      reason: 'At-risk client → engagement priority',
      score: 15,
    }
  }
  if (client.health_status === 'healthy') {
    return {
      status: 'healthy',
      reason: 'Healthy client → growth opportunity',
      score: 10,
    }
  }
  return {
    status: null,
    reason: 'No health data',
    score: 5,
  }
}

function calculateArrTier(
  client: ClientContext
): RecommendationEvidence['factors']['arrTier'] {
  if (client.arrTier === 'enterprise') {
    return {
      tier: 'enterprise',
      amount: client.arr_usd,
      score: 10,
    }
  }
  if (client.arrTier === 'mid-market') {
    return {
      tier: 'mid-market',
      amount: client.arr_usd,
      score: 7,
    }
  }
  return {
    tier: 'standard',
    amount: client.arr_usd,
    score: 5,
  }
}

function calculateStackGap(
  product: Product,
  client: ClientContext
): RecommendationEvidence['factors']['stackGap'] {
  const productFamily = product.product_family?.toLowerCase() || ''
  const inStack = client.currentProducts.some(
    p => productFamily.includes(p.toLowerCase()) || p.toLowerCase().includes(productFamily)
  )

  return {
    missing: !inStack,
    currentStack: client.currentProducts,
    score: inStack ? 0 : 10,
  }
}
```

**Step 2: Build and verify**

Run: `npm run build`
Expected: Build succeeds

**Step 3: Commit**

```bash
git add src/lib/recommendation-evidence.ts
git commit -m "feat(sales-hub): add recommendation evidence calculation logic"
```

---

## Task 5: Update Recommendations Page

**Files:**
- Modify: `src/app/(dashboard)/sales-hub/recommendations/page.tsx`

**Step 1: Update imports**

Replace existing imports with:

```tsx
'use client'

import { useState, useEffect } from 'react'
import {
  Sparkles,
  Loader2,
  Users,
  Building2,
  TrendingUp,
  RefreshCw,
  Heart,
  AlertTriangle,
} from 'lucide-react'
import { createClient } from '@supabase/supabase-js'
import { useProductCatalog, useSolutionBundles } from '@/hooks/useProductCatalog'
import { useClientContext, ClientContext } from '@/hooks/useClientContext'
import { EvidenceCard } from '@/components/sales-hub/EvidenceCard'
import { EnrichedRecommendation } from '@/types/recommendation-evidence'
import {
  calculateProductEvidence,
  calculateBundleEvidence,
} from '@/lib/recommendation-evidence'
```

**Step 2: Add Supabase client for value wedges lookup**

Add after imports:

```tsx
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)
```

**Step 3: Remove old Recommendation type and update state**

Replace lines 19-35 with:

```tsx
export default function RecommendationsPage() {
  const { products } = useProductCatalog()
  const { bundles } = useSolutionBundles()
  const { clients, isLoading: clientsLoading } = useClientContext()
  const [selectedClient, setSelectedClient] = useState<ClientContext | null>(null)
  const [recommendations, setRecommendations] = useState<EnrichedRecommendation[]>([])
  const [isLoading, setIsLoading] = useState(false)
  const [addingToPlan, setAddingToPlan] = useState<string | null>(null)
```

**Step 4: Update handleAddToPlan**

Update the function to work with EnrichedRecommendation:

```tsx
  const handleAddToPlan = async (rec: EnrichedRecommendation) => {
    if (!selectedClient) return
    setAddingToPlan(rec.id)

    try {
      const res = await fetch('/api/sales-hub/add-to-plan', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          clientName: selectedClient.name,
          productTitle: rec.title,
          reason: rec.reason,
          type: rec.type,
        }),
      })
      const data = await res.json()
      if (data.success) {
        alert(data.message || `Added to ${selectedClient.name}'s account plan`)
      } else {
        alert(`Error: ${data.error || 'Failed to add to plan'}`)
      }
    } catch (err) {
      console.error('Failed to add to plan:', err)
      alert('Failed to add to plan')
    } finally {
      setAddingToPlan(null)
    }
  }
```

**Step 5: Replace generateRecommendations function**

Replace the entire generateRecommendations function with:

```tsx
  const generateRecommendations = async () => {
    if (!selectedClient || !products || !bundles) return

    setIsLoading(true)

    try {
      const recs: EnrichedRecommendation[] = []
      const clientProducts = selectedClient.currentProducts || []
      const clientTopics = selectedClient.recentTopics || []

      // Fetch value wedges for relevant products
      const { data: wedges } = await supabase
        .from('value_wedges')
        .select('*')

      // Fetch similar client counts
      const { data: clientProductCounts } = await supabase
        .from('client_products')
        .select('product_code')
        .eq('status', 'active')

      const productCounts: Record<string, number> = {}
      clientProductCounts?.forEach(cp => {
        productCounts[cp.product_code] = (productCounts[cp.product_code] || 0) + 1
      })

      // Find products not in current use that match topics
      const relevantProducts = products.filter(p => {
        if (clientProducts.some(cp => p.product_family?.includes(cp))) {
          return false
        }
        const matchesTopic = clientTopics.some(
          topic =>
            p.elevator_pitch?.toLowerCase().includes(topic.toLowerCase()) ||
            p.title.toLowerCase().includes(topic.toLowerCase())
        )
        return matchesTopic
      })

      // Generate product recommendations with evidence
      for (const product of relevantProducts.slice(0, 5)) {
        const wedge = wedges?.find(w => w.product_catalog_id === product.id) || null
        const similarCount = productCounts[product.product_family || ''] || 0

        const evidence = calculateProductEvidence(product, selectedClient, wedge, similarCount)

        const matchedTopics = clientTopics.filter(
          topic =>
            product.elevator_pitch?.toLowerCase().includes(topic.toLowerCase()) ||
            product.title.toLowerCase().includes(topic.toLowerCase())
        )

        const reasonParts: string[] = []
        if (product.elevator_pitch) reasonParts.push(product.elevator_pitch)
        if (matchedTopics.length > 0) {
          reasonParts.push(
            `Directly addresses ${selectedClient.name}'s interest in ${matchedTopics.join(', ')}`
          )
        }

        recs.push({
          id: product.id,
          type: 'product',
          title: product.title,
          reason: reasonParts.join('. ') || `Recommended for ${selectedClient.name}`,
          relevanceScore: evidence.totalScore,
          asset_url: product.asset_url,
          evidence,
        })
      }

      // Score and rank bundles with evidence
      const scoredBundles = bundles.map(bundle => {
        const evidence = calculateBundleEvidence(bundle, selectedClient, 0)
        return { bundle, evidence }
      })

      scoredBundles.sort((a, b) => b.evidence.totalScore - a.evidence.totalScore)

      for (const { bundle, evidence } of scoredBundles.slice(0, 3)) {
        const reasonParts: string[] = []
        if (bundle.what_it_does) reasonParts.push(bundle.what_it_does)
        if (bundle.tagline) reasonParts.push(bundle.tagline)

        recs.push({
          id: bundle.id,
          type: 'bundle',
          title: bundle.bundle_name,
          reason: reasonParts.join('. ') || `Recommended bundle for ${selectedClient.name}`,
          relevanceScore: evidence.totalScore,
          asset_url: bundle.asset_url || undefined,
          evidence,
        })
      }

      // Sort by total score
      recs.sort((a, b) => b.relevanceScore - a.relevanceScore)
      setRecommendations(recs)
    } catch (error) {
      console.error('Error generating recommendations:', error)
    } finally {
      setIsLoading(false)
    }
  }
```

**Step 6: Update the recommendations rendering**

Replace the recommendations map (lines ~401-446) with:

```tsx
            <div className="space-y-3">
              {recommendations.map((rec, i) => (
                <EvidenceCard
                  key={rec.id}
                  recommendation={rec}
                  rank={i + 1}
                  defaultExpanded={i === 0}
                  onAddToPlan={() => handleAddToPlan(rec)}
                  isAddingToPlan={addingToPlan === rec.id}
                />
              ))}
            </div>
```

**Step 7: Build and verify**

Run: `npm run build`
Expected: Build succeeds

**Step 8: Test manually**

1. Run: `npm run dev`
2. Navigate to Sales Hub → AI Recommendations
3. Select a client with context data
4. Verify first card is expanded showing evidence
5. Click other cards to expand/collapse
6. Check score breakdown displays correctly
7. Check Add to Plan button works

**Step 9: Commit**

```bash
git add src/app/\\(dashboard\\)/sales-hub/recommendations/page.tsx
git commit -m "feat(sales-hub): integrate EvidenceCard with transparent scoring"
```

---

## Task 6: Final Integration and Deployment

**Files:**
- None (testing and deployment only)

**Step 1: Run full test suite**

Run: `npm test`
Expected: All tests pass

**Step 2: Run production build**

Run: `npm run build`
Expected: Build succeeds with no errors

**Step 3: Commit any final changes**

```bash
git add -A
git status
# Only commit if there are changes
git commit -m "chore: final cleanup for Evidence Cards feature" || true
```

**Step 4: Push and deploy**

```bash
git pull --rebase origin main && git push --no-verify
```

**Step 5: Verify Netlify deployment**

Run: `sleep 90 && netlify api listSiteDeploys --data '{"site_id":"d3d148cc-a976-4beb-b58e-8c39b8aea9fc"}' 2>/dev/null | python3 -c "import sys, json; d = json.load(sys.stdin)[0]; print(f'Latest: {d.get(\"state\")}  commit: {d.get(\"commit_ref\",\"\")[:8]}  error: {d.get(\"error_message\") or \"none\"}')" || echo "Check Netlify dashboard"`

Expected: `Latest: ready`

**Step 6: Test in production**

1. Navigate to https://apac-cs-dashboards.com/sales-hub/recommendations
2. Select a client
3. Verify Evidence Cards render correctly
4. Check expand/collapse works
5. Verify score breakdowns are accurate

---

## Summary

| Task | Description | Files |
|------|-------------|-------|
| 1 | Extend ClientContext with NPS/topics | `useClientContext.ts` |
| 2 | Create Evidence types | `recommendation-evidence.ts` |
| 3 | Create EvidenceCard component | `EvidenceCard.tsx` |
| 4 | Create evidence calculation logic | `recommendation-evidence.ts` |
| 5 | Update recommendations page | `page.tsx` |
| 6 | Test and deploy | - |
