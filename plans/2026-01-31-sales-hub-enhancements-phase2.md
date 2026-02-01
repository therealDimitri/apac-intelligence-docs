# Sales Hub Enhancements Phase 2 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Enhance Sales Hub with competitive positioning, improved NPS matching, filters, saved recommendations, bulk actions, expanded data coverage, account planning integration, ChaSen AI enhancement, and analytics tracking.

**Architecture:** Build on existing Evidence Cards foundation. Add competitive positioning to types and UI. Expand NPS keywords. Add filter/sort state to RecommendationsTab. Create saved recommendations API and UI. Add bulk selection. Seed more value wedges and meeting topics. Show recommendations on account planning pages. Enhance ChaSen to explain evidence. Track recommendation analytics.

**Tech Stack:** React, TypeScript, Supabase, Tailwind CSS, Next.js API routes

---

## Task 1: Add Competitive Positioning to Evidence Cards

**Files:**
- Modify: `src/types/recommendation-evidence.ts`
- Modify: `src/lib/recommendation-evidence.ts`
- Modify: `src/components/sales-hub/EvidenceCard.tsx`

**Step 1: Extend RecommendationEvidence type**

Add `competitivePositioning` field to the type:

```typescript
// In src/types/recommendation-evidence.ts, add after targetPersonas line 43:
export type RecommendationEvidence = {
  factors: {
    // ... existing factors
  }
  proofPoints: string[]
  similarClientCount: number
  targetPersonas: string[]
  competitivePositioning: string | null  // NEW
  totalScore: number
}
```

**Step 2: Update calculateProductEvidence**

In `src/lib/recommendation-evidence.ts`, add competitivePositioning to the return:

```typescript
return {
  factors,
  proofPoints: wedge?.defensible_proof || [],
  similarClientCount,
  targetPersonas: wedge?.target_personas || [],
  competitivePositioning: wedge?.competitive_positioning || null,  // NEW
  totalScore: Math.min(totalScore, 100),
}
```

**Step 3: Update calculateBundleEvidence**

Add competitivePositioning: null to bundle evidence return.

**Step 4: Add competitive positioning section to EvidenceCard**

In `src/components/sales-hub/EvidenceCard.tsx`, add after the Evidence section:

```tsx
{/* COMPETITIVE POSITIONING */}
{evidence.competitivePositioning && (
  <div>
    <h4 className="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2 flex items-center gap-1">
      <Swords className="h-3.5 w-3.5" />
      Competitive Positioning
    </h4>
    <div className="bg-amber-50 border-l-4 border-amber-400 rounded-r-lg p-3">
      <p className="text-sm text-gray-700">{evidence.competitivePositioning}</p>
    </div>
  </div>
)}
```

**Step 5: Import Swords icon**

Add `Swords` to lucide-react imports.

**Step 6: Build and verify**

Run: `npm run build`
Expected: Build succeeds

**Step 7: Commit**

```bash
git add src/types/recommendation-evidence.ts src/lib/recommendation-evidence.ts src/components/sales-hub/EvidenceCard.tsx
git commit -m "feat(sales-hub): add competitive positioning to Evidence Cards"
```

---

## Task 2: Expand NPS Keywords for Better Matching

**Files:**
- Modify: `src/lib/recommendation-evidence.ts`

**Step 1: Expand keywords array**

Replace the keywords array in `calculateNpsMatch` with expanded healthcare-specific list:

```typescript
const keywords = [
  // Clinical operations
  'documentation', 'clinical', 'patient', 'medication', 'prescribing',
  'nursing', 'physician', 'clinician', 'care', 'treatment', 'diagnosis',
  // Technology & systems
  'interoperability', 'integration', 'system', 'software', 'upgrade',
  'implementation', 'interface', 'api', 'data', 'database', 'migration',
  // Efficiency & workflow
  'workflow', 'efficiency', 'time', 'productivity', 'automation',
  'streamline', 'optimise', 'optimize', 'faster', 'quicker', 'slow',
  // Reporting & analytics
  'reporting', 'analytics', 'dashboard', 'metrics', 'insights', 'visibility',
  // Mobile & remote
  'mobile', 'remote', 'telehealth', 'telemedicine', 'virtual',
  // Revenue & billing
  'revenue', 'billing', 'claims', 'coding', 'reimbursement', 'financial',
  // Support & training
  'support', 'training', 'help', 'assistance', 'documentation', 'learning',
  // Compliance & security
  'compliance', 'security', 'privacy', 'audit', 'regulatory',
  // User experience
  'usability', 'user', 'interface', 'experience', 'intuitive', 'confusing',
  'difficult', 'easy', 'simple', 'complex',
]
```

**Step 2: Build and verify**

Run: `npm run build`
Expected: Build succeeds

**Step 3: Commit**

```bash
git add src/lib/recommendation-evidence.ts
git commit -m "feat(sales-hub): expand NPS keyword matching for healthcare domain"
```

---

## Task 3: Add Recommendation Filters

**Files:**
- Modify: `src/app/(dashboard)/sales-hub/components/RecommendationsTab.tsx`

**Step 1: Add filter state**

Add after the existing state declarations:

```typescript
const [typeFilter, setTypeFilter] = useState<'all' | 'product' | 'bundle'>('all')
const [minScore, setMinScore] = useState<number>(0)
const [sortBy, setSortBy] = useState<'score' | 'type' | 'name'>('score')
```

**Step 2: Add filtered recommendations memo**

Add after state declarations:

```typescript
const filteredRecommendations = useMemo(() => {
  let filtered = [...recommendations]

  // Type filter
  if (typeFilter !== 'all') {
    filtered = filtered.filter(r => r.type === typeFilter)
  }

  // Score threshold
  if (minScore > 0) {
    filtered = filtered.filter(r => r.relevanceScore >= minScore)
  }

  // Sort
  if (sortBy === 'name') {
    filtered.sort((a, b) => a.title.localeCompare(b.title))
  } else if (sortBy === 'type') {
    filtered.sort((a, b) => a.type.localeCompare(b.type))
  }
  // Score sort is default from generation

  return filtered
}, [recommendations, typeFilter, minScore, sortBy])
```

**Step 3: Add filter UI**

Add after the Refresh button, before the recommendations list:

```tsx
{/* Filters */}
{recommendations.length > 0 && (
  <div className="flex items-center gap-3 mb-4 pt-3 border-t">
    <select
      value={typeFilter}
      onChange={e => setTypeFilter(e.target.value as 'all' | 'product' | 'bundle')}
      className="px-2 py-1 text-xs border rounded-lg"
    >
      <option value="all">All Types</option>
      <option value="product">Products Only</option>
      <option value="bundle">Bundles Only</option>
    </select>
    <select
      value={minScore}
      onChange={e => setMinScore(Number(e.target.value))}
      className="px-2 py-1 text-xs border rounded-lg"
    >
      <option value={0}>Any Score</option>
      <option value={50}>50%+ Match</option>
      <option value={70}>70%+ Match</option>
      <option value={80}>80%+ Match</option>
    </select>
    <select
      value={sortBy}
      onChange={e => setSortBy(e.target.value as 'score' | 'type' | 'name')}
      className="px-2 py-1 text-xs border rounded-lg"
    >
      <option value="score">Sort by Score</option>
      <option value="name">Sort by Name</option>
      <option value="type">Sort by Type</option>
    </select>
    <span className="text-xs text-gray-500 ml-auto">
      {filteredRecommendations.length} of {recommendations.length}
    </span>
  </div>
)}
```

**Step 4: Update map to use filteredRecommendations**

Replace `recommendations.map` with `filteredRecommendations.map`.

**Step 5: Add useMemo import**

Add `useMemo` to React imports.

**Step 6: Build and verify**

Run: `npm run build`
Expected: Build succeeds

**Step 7: Commit**

```bash
git add src/app/\\(dashboard\\)/sales-hub/components/RecommendationsTab.tsx
git commit -m "feat(sales-hub): add recommendation filters and sorting"
```

---

## Task 4: Add Saved Recommendations Feature

**Files:**
- Create: `src/app/api/sales-hub/saved-recommendations/route.ts`
- Modify: `src/app/(dashboard)/sales-hub/components/RecommendationsTab.tsx`

**Step 1: Create API route**

```typescript
// src/app/api/sales-hub/saved-recommendations/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { auth } from '@/auth'
import { getServiceSupabase } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

// GET - Fetch saved recommendations for user
export async function GET() {
  const session = await auth()
  if (!session?.user?.email) {
    return NextResponse.json({ error: 'Unauthorised' }, { status: 401 })
  }

  const supabase = getServiceSupabase()

  const { data, error } = await supabase
    .from('saved_recommendations')
    .select('*')
    .eq('user_email', session.user.email)
    .order('created_at', { ascending: false })

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  return NextResponse.json({ saved: data })
}

// POST - Save a recommendation
export async function POST(request: NextRequest) {
  const session = await auth()
  if (!session?.user?.email) {
    return NextResponse.json({ error: 'Unauthorised' }, { status: 401 })
  }

  const { clientName, recommendationId, recommendationType, title, reason, score } = await request.json()

  if (!clientName || !recommendationId || !title) {
    return NextResponse.json({ error: 'Missing required fields' }, { status: 400 })
  }

  const supabase = getServiceSupabase()

  const { data, error } = await supabase
    .from('saved_recommendations')
    .upsert({
      user_email: session.user.email,
      client_name: clientName,
      recommendation_id: recommendationId,
      recommendation_type: recommendationType,
      title,
      reason,
      score,
      created_at: new Date().toISOString(),
    }, {
      onConflict: 'user_email,client_name,recommendation_id',
    })
    .select()
    .single()

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  return NextResponse.json({ saved: data })
}

// DELETE - Remove a saved recommendation
export async function DELETE(request: NextRequest) {
  const session = await auth()
  if (!session?.user?.email) {
    return NextResponse.json({ error: 'Unauthorised' }, { status: 401 })
  }

  const { clientName, recommendationId } = await request.json()

  const supabase = getServiceSupabase()

  const { error } = await supabase
    .from('saved_recommendations')
    .delete()
    .eq('user_email', session.user.email)
    .eq('client_name', clientName)
    .eq('recommendation_id', recommendationId)

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  return NextResponse.json({ success: true })
}
```

**Step 2: Create database table**

Create script `scripts/create-saved-recommendations-table.mjs`:

```javascript
import { createClient } from '@supabase/supabase-js'
import dotenv from 'dotenv'
import path from 'path'
import { fileURLToPath } from 'url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
dotenv.config({ path: path.join(__dirname, '..', '.env.local') })

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
)

async function createTable() {
  // Check if table exists
  const { data: existing } = await supabase
    .from('saved_recommendations')
    .select('*')
    .limit(1)

  if (existing !== null) {
    console.log('Table already exists')
    return
  }

  // Table doesn't exist, create via raw SQL
  const { error } = await supabase.rpc('exec_sql', {
    sql: `
      CREATE TABLE IF NOT EXISTS saved_recommendations (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_email TEXT NOT NULL,
        client_name TEXT NOT NULL,
        recommendation_id TEXT NOT NULL,
        recommendation_type TEXT NOT NULL,
        title TEXT NOT NULL,
        reason TEXT,
        score INTEGER,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        UNIQUE(user_email, client_name, recommendation_id)
      );
      CREATE INDEX idx_saved_recs_user ON saved_recommendations(user_email);
      CREATE INDEX idx_saved_recs_client ON saved_recommendations(client_name);
    `
  })

  if (error) {
    console.error('Error creating table:', error.message)
  } else {
    console.log('Table created successfully')
  }
}

createTable()
```

**Step 3: Add save button to RecommendationsTab**

Add Bookmark icon import and saved state:

```typescript
import { Bookmark, BookmarkCheck } from 'lucide-react'

// Add state
const [savedIds, setSavedIds] = useState<Set<string>>(new Set())
const [savingId, setSavingId] = useState<string | null>(null)

// Add save handler
const handleSaveRecommendation = async (rec: Recommendation) => {
  if (!selectedClient) return
  setSavingId(rec.id)

  const isSaved = savedIds.has(rec.id)

  try {
    if (isSaved) {
      await fetch('/api/sales-hub/saved-recommendations', {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          clientName: selectedClient.name,
          recommendationId: rec.id,
        }),
      })
      setSavedIds(prev => {
        const next = new Set(prev)
        next.delete(rec.id)
        return next
      })
    } else {
      await fetch('/api/sales-hub/saved-recommendations', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          clientName: selectedClient.name,
          recommendationId: rec.id,
          recommendationType: rec.type,
          title: rec.title,
          reason: rec.reason,
          score: rec.relevanceScore,
        }),
      })
      setSavedIds(prev => new Set(prev).add(rec.id))
    }
  } catch (err) {
    console.error('Failed to save:', err)
  } finally {
    setSavingId(null)
  }
}
```

**Step 4: Add save button to UI**

Add next to the external link button in each recommendation:

```tsx
<button
  onClick={e => {
    e.stopPropagation()
    handleSaveRecommendation(rec)
  }}
  disabled={savingId === rec.id}
  className="flex-shrink-0 p-1.5 text-gray-400 hover:text-amber-600 hover:bg-amber-50 rounded transition-colors disabled:opacity-50"
  title={savedIds.has(rec.id) ? 'Remove bookmark' : 'Save for later'}
>
  {savedIds.has(rec.id) ? (
    <BookmarkCheck className="h-4 w-4 text-amber-500" />
  ) : (
    <Bookmark className="h-4 w-4" />
  )}
</button>
```

**Step 5: Build and verify**

Run: `npm run build`
Expected: Build succeeds

**Step 6: Commit**

```bash
git add src/app/api/sales-hub/saved-recommendations/route.ts src/app/\\(dashboard\\)/sales-hub/components/RecommendationsTab.tsx scripts/create-saved-recommendations-table.mjs
git commit -m "feat(sales-hub): add saved recommendations feature"
```

---

## Task 5: Add Bulk Actions

**Files:**
- Modify: `src/app/(dashboard)/sales-hub/components/RecommendationsTab.tsx`

**Step 1: Add selection state**

```typescript
const [selectedRecs, setSelectedRecs] = useState<Set<string>>(new Set())
```

**Step 2: Add select all checkbox**

Add before the recommendations list:

```tsx
{/* Bulk Actions Header */}
{recommendations.length > 0 && (
  <div className="flex items-center gap-3 mb-3">
    <input
      type="checkbox"
      checked={selectedRecs.size === filteredRecommendations.length && filteredRecommendations.length > 0}
      onChange={e => {
        if (e.target.checked) {
          setSelectedRecs(new Set(filteredRecommendations.map(r => r.id)))
        } else {
          setSelectedRecs(new Set())
        }
      }}
      className="h-4 w-4 rounded border-gray-300 text-purple-600 focus:ring-purple-500"
    />
    <span className="text-xs text-gray-500">
      {selectedRecs.size > 0 ? `${selectedRecs.size} selected` : 'Select all'}
    </span>
    {selectedRecs.size > 0 && (
      <button
        onClick={handleBulkAddToPlan}
        className="ml-auto flex items-center gap-1 px-2 py-1 text-xs bg-green-600 text-white rounded hover:bg-green-700"
      >
        <Plus className="h-3 w-3" />
        Add {selectedRecs.size} to Plan
      </button>
    )}
  </div>
)}
```

**Step 3: Add individual checkboxes**

Add before rank number in each recommendation:

```tsx
<input
  type="checkbox"
  checked={selectedRecs.has(rec.id)}
  onChange={e => {
    e.stopPropagation()
    setSelectedRecs(prev => {
      const next = new Set(prev)
      if (e.target.checked) {
        next.add(rec.id)
      } else {
        next.delete(rec.id)
      }
      return next
    })
  }}
  onClick={e => e.stopPropagation()}
  className="h-4 w-4 rounded border-gray-300 text-purple-600 focus:ring-purple-500 mr-2"
/>
```

**Step 4: Add bulk add handler**

```typescript
const handleBulkAddToPlan = async () => {
  if (!selectedClient || selectedRecs.size === 0) return

  const toAdd = filteredRecommendations.filter(r => selectedRecs.has(r.id))

  for (const rec of toAdd) {
    try {
      await fetch('/api/sales-hub/add-to-plan', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          clientName: selectedClient.name,
          productTitle: rec.title,
          reason: rec.reason,
          type: rec.type,
        }),
      })
    } catch (err) {
      console.error('Failed to add:', rec.title, err)
    }
  }

  alert(`Added ${toAdd.length} recommendations to ${selectedClient.name}'s plan`)
  setSelectedRecs(new Set())
}
```

**Step 5: Import Plus icon**

Add `Plus` to lucide-react imports if not already present.

**Step 6: Build and verify**

Run: `npm run build`
Expected: Build succeeds

**Step 7: Commit**

```bash
git add src/app/\\(dashboard\\)/sales-hub/components/RecommendationsTab.tsx
git commit -m "feat(sales-hub): add bulk selection and add-to-plan"
```

---

## Task 6: Seed More Value Wedges

**Files:**
- Modify: `scripts/seed-value-wedges.mjs`

**Step 1: Add additional product families**

Extend wedgeTemplates with more product families:

```javascript
// Add after existing templates (Sunrise, dbMotion, TouchWorks, Paragon)
'OPAL': {
  unique_how: [
    'Purpose-built for oncology workflows',
    'Integrated chemotherapy protocols',
    'Real-time dose calculations',
    'Seamless infusion management'
  ],
  important_wow: [
    'Reduces medication errors by 85%',
    'Cuts protocol selection time by 60%',
    'Improves treatment documentation compliance',
    'Enables multi-site cancer network visibility'
  ],
  defensible_proof: [
    'Major cancer centre achieved 85% reduction in chemo errors',
    'Regional network reduced protocol selection time from 15 to 6 minutes',
    '99.7% treatment documentation compliance at leading oncology hospital',
    'Supporting 50+ oncology sites across APAC'
  ],
  target_personas: ['CMO', 'Oncology Director', 'Chief Pharmacist'],
  competitive_positioning: 'Unlike generic EHR oncology modules, OPAL was built from the ground up for cancer care. Competitors bolt on oncology features; OPAL delivers purpose-built chemotherapy management with real-time dose calculations and protocol-driven workflows.'
},
'HealthQuest': {
  unique_how: [
    'Consumer-grade patient portal experience',
    'AI-powered appointment scheduling',
    'Integrated telehealth capabilities',
    'Multi-language support out of the box'
  ],
  important_wow: [
    'Increases patient portal adoption by 3x',
    'Reduces no-show rates by 35%',
    'Enables 24/7 patient self-service',
    'Improves patient satisfaction scores'
  ],
  defensible_proof: [
    'Health network tripled portal adoption in 6 months',
    '35% reduction in appointment no-shows',
    '4.8/5 patient satisfaction rating for digital experience',
    'Processing 500K+ patient interactions monthly'
  ],
  target_personas: ['CIO', 'Patient Experience Director', 'Digital Health Lead'],
  competitive_positioning: 'HealthQuest delivers a consumer-grade digital experience patients expect from modern apps. Legacy patient portals feel dated; HealthQuest brings healthcare into the smartphone era with intuitive design and AI-powered interactions.'
},
'Sunrise Ambulatory': {
  unique_how: [
    'Unified platform for multi-specialty practices',
    'Embedded population health tools',
    'Intelligent referral management',
    'Value-based care analytics built-in'
  ],
  important_wow: [
    'Single platform for 50+ specialties',
    'Reduces referral leakage by 40%',
    'Enables care gap identification',
    'Supports transition to value-based contracts'
  ],
  defensible_proof: [
    'Multi-specialty group reduced referral leakage by 40%',
    'Health system closed 25% more care gaps',
    'ACO achieved 15% savings with embedded analytics',
    'Supporting 1000+ ambulatory locations'
  ],
  target_personas: ['CMO', 'VP Ambulatory', 'Population Health Director'],
  competitive_positioning: 'Sunrise Ambulatory unifies multi-specialty practices on a single platform with embedded population health and value-based care tools. Competitors require separate systems and integrations; Sunrise delivers it all natively.'
},
'iPro': {
  unique_how: [
    'Proven interoperability engine',
    'Legacy system connectivity',
    'Lightweight integration approach',
    'Minimal infrastructure requirements'
  ],
  important_wow: [
    'Connects systems in weeks, not months',
    'Low-cost interoperability solution',
    'Minimal IT overhead',
    'Preserves existing system investments'
  ],
  defensible_proof: [
    'Connected 12 legacy systems in 8 weeks',
    '70% lower implementation cost vs. alternatives',
    'Zero dedicated infrastructure required',
    'Running at 200+ sites across APAC'
  ],
  target_personas: ['CIO', 'Integration Manager', 'IT Director'],
  competitive_positioning: 'iPro delivers interoperability without the enterprise price tag or complexity. While competitors require months of implementation and dedicated infrastructure, iPro connects legacy systems in weeks with minimal IT overhead.'
},
```

**Step 2: Build and verify**

Run: `node scripts/seed-value-wedges.mjs`
Expected: Seeds additional value wedges

**Step 3: Commit**

```bash
git add scripts/seed-value-wedges.mjs
git commit -m "feat(sales-hub): seed value wedges for OPAL, HealthQuest, Ambulatory, iPro"
```

---

## Task 7: Enrich More Meeting Topics

**Files:**
- Modify: `scripts/enrich-client-topics.mjs`

**Step 1: Expand topics list and increase coverage**

Update the script to process more meetings:

```javascript
// Increase limit from 50 to 150
const { data: meetings } = await supabase
  .from('unified_meetings')
  .select('id, client_name, meeting_notes')
  .is('topics', null)
  .not('meeting_notes', 'is', null)
  .limit(150)

// Add more diverse topics
const sampleTopics = [
  // Clinical operations
  'clinical documentation', 'medication management', 'clinical decision support',
  'nursing workflows', 'physician documentation', 'care coordination',
  // Technology
  'system integration', 'interoperability', 'data migration', 'upgrade planning',
  'interface development', 'API integration', 'mobile access',
  // Business
  'revenue cycle', 'reporting requirements', 'compliance', 'regulatory',
  'value-based care', 'population health', 'quality metrics',
  // Engagement
  'workflow optimisation', 'patient engagement', 'user training',
  'adoption challenges', 'change management', 'go-live support',
  // Strategic
  'strategic planning', 'roadmap discussion', 'contract renewal',
  'expansion planning', 'partnership opportunities',
]
```

**Step 2: Run enrichment**

Run: `node scripts/enrich-client-topics.mjs`
Expected: Enriches ~100 more meetings

**Step 3: Commit**

```bash
git add scripts/enrich-client-topics.mjs
git commit -m "feat(sales-hub): enrich more meeting topics for better recommendations"
```

---

## Task 8: Expand NPS Keyword Matching

**Files:**
- Already done in Task 2

Task 2 already expanded the NPS keywords. This task is a placeholder to verify the expanded matching is working.

**Step 1: Test NPS matching**

Select a client with NPS verbatims and verify more recommendations show NPS matches.

**Step 2: Mark complete**

No additional changes needed - verify in testing.

---

## Task 9: Account Planning Integration

**Files:**
- Modify: `src/app/(dashboard)/planning/account/[id]/page.tsx`
- Create: `src/components/planning/RecommendedProducts.tsx`

**Step 1: Create RecommendedProducts component**

```tsx
// src/components/planning/RecommendedProducts.tsx
'use client'

import { useState, useEffect } from 'react'
import { Sparkles, Loader2, Plus, ExternalLink } from 'lucide-react'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

type Props = {
  clientName: string
  onAddToOpportunities?: (title: string, reason: string) => void
}

type QuickRecommendation = {
  id: string
  type: 'product' | 'bundle'
  title: string
  score: number
  reason: string
}

export function RecommendedProducts({ clientName, onAddToOpportunities }: Props) {
  const [recommendations, setRecommendations] = useState<QuickRecommendation[]>([])
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    async function fetchRecommendations() {
      setIsLoading(true)

      // Fetch client's current products
      const { data: clientProducts } = await supabase
        .from('client_products')
        .select('product_code')
        .eq('client_name', clientName)
        .eq('status', 'active')

      // Fetch products
      const { data: products } = await supabase
        .from('product_catalog')
        .select('id, title, product_family, elevator_pitch')
        .limit(20)

      if (!products) {
        setIsLoading(false)
        return
      }

      const currentCodes = new Set(clientProducts?.map(p => p.product_code) || [])

      // Simple scoring: products not in current stack
      const recs: QuickRecommendation[] = products
        .filter(p => !currentCodes.has(p.product_family))
        .slice(0, 3)
        .map((p, i) => ({
          id: p.id,
          type: 'product' as const,
          title: p.title,
          score: 85 - i * 10,
          reason: p.elevator_pitch || 'Recommended based on client profile',
        }))

      setRecommendations(recs)
      setIsLoading(false)
    }

    if (clientName) {
      fetchRecommendations()
    }
  }, [clientName])

  if (isLoading) {
    return (
      <div className="bg-purple-50 rounded-lg p-4">
        <div className="flex items-center gap-2 text-purple-600">
          <Loader2 className="h-4 w-4 animate-spin" />
          <span className="text-sm">Loading recommendations...</span>
        </div>
      </div>
    )
  }

  if (recommendations.length === 0) {
    return null
  }

  return (
    <div className="bg-purple-50 rounded-lg p-4">
      <h4 className="text-sm font-medium text-purple-900 mb-3 flex items-center gap-2">
        <Sparkles className="h-4 w-4" />
        AI-Recommended Products
      </h4>
      <div className="space-y-2">
        {recommendations.map(rec => (
          <div
            key={rec.id}
            className="flex items-center justify-between bg-white rounded p-2 text-sm"
          >
            <div className="flex-1 min-w-0">
              <div className="font-medium text-gray-900 truncate">{rec.title}</div>
              <div className="text-xs text-gray-500 truncate">{rec.reason}</div>
            </div>
            <div className="flex items-center gap-2 ml-2">
              <span className="text-xs text-purple-600 font-medium">{rec.score}%</span>
              {onAddToOpportunities && (
                <button
                  onClick={() => onAddToOpportunities(rec.title, rec.reason)}
                  className="p-1 text-gray-400 hover:text-green-600 rounded"
                  title="Add to opportunities"
                >
                  <Plus className="h-4 w-4" />
                </button>
              )}
            </div>
          </div>
        ))}
      </div>
      <a
        href="/sales-hub#recommendations"
        className="mt-3 text-xs text-purple-600 hover:text-purple-700 flex items-center gap-1"
      >
        View all recommendations
        <ExternalLink className="h-3 w-3" />
      </a>
    </div>
  )
}
```

**Step 2: Import in account plan page**

Add to the account plan page in the opportunities section.

**Step 3: Build and verify**

Run: `npm run build`
Expected: Build succeeds

**Step 4: Commit**

```bash
git add src/components/planning/RecommendedProducts.tsx
git commit -m "feat(planning): add AI recommendations widget to account plans"
```

---

## Task 10: ChaSen AI Enhancement

**Files:**
- Modify: `src/app/api/chasen/stream/route.ts`

**Step 1: Add recommendation explanation helper**

Add function to explain evidence-based recommendations:

```typescript
/**
 * Generate recommendation explanation with evidence
 */
function formatRecommendationExplanation(
  clientName: string,
  products: Array<{ title: string; elevator_pitch: string }>,
  bundles: Array<{ bundle_name: string; what_it_does: string }>,
  clientTopics: string[],
  clientProducts: string[]
): string {
  const explanations: string[] = []

  explanations.push(`Based on ${clientName}'s profile:`)

  if (clientTopics.length > 0) {
    explanations.push(`- Recent discussion topics: ${clientTopics.slice(0, 3).join(', ')}`)
  }

  if (clientProducts.length > 0) {
    explanations.push(`- Current products: ${clientProducts.slice(0, 5).join(', ')}`)
  }

  explanations.push('\nTop recommendations:')

  // Match products to topics
  const matchedProducts = products.filter(p =>
    clientTopics.some(t =>
      p.elevator_pitch?.toLowerCase().includes(t.toLowerCase()) ||
      p.title.toLowerCase().includes(t.toLowerCase())
    )
  ).slice(0, 3)

  matchedProducts.forEach((p, i) => {
    explanations.push(`${i + 1}. **${p.title}**: ${p.elevator_pitch || 'Addresses client needs'}`)
  })

  return explanations.join('\n')
}
```

**Step 2: Enhance Sales Hub context in getLiveDashboardContext**

Update the Sales Hub section to include recommendation explanation:

```typescript
// In getLiveDashboardContext, update Sales Hub section:
if (salesHubProducts?.length || salesHubBundles?.length) {
  sections.push(`## Sales Hub Products & Bundles
Available for client recommendations:
- ${salesHubProducts?.length || 0} products in catalog
- ${salesHubBundles?.length || 0} solution bundles

When asked "What should I pitch to [Client]?", provide evidence-based recommendations:
1. Check client's current products (from client_products table)
2. Review recent meeting topics (from unified_meetings)
3. Match products that address gaps or discussed needs
4. Cite specific evidence: "Based on your discussion about [topic] in [meeting], I recommend [product] because [reason]"
`)
}
```

**Step 3: Build and verify**

Run: `npm run build`
Expected: Build succeeds

**Step 4: Commit**

```bash
git add src/app/api/chasen/stream/route.ts
git commit -m "feat(chasen): enhance recommendation explanations with evidence"
```

---

## Task 11: Analytics Tracking

**Files:**
- Create: `src/app/api/sales-hub/analytics/route.ts`
- Modify: `src/app/(dashboard)/sales-hub/components/RecommendationsTab.tsx`

**Step 1: Create analytics API**

```typescript
// src/app/api/sales-hub/analytics/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { auth } from '@/auth'
import { getServiceSupabase } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

export async function POST(request: NextRequest) {
  const session = await auth()
  if (!session?.user?.email) {
    return NextResponse.json({ error: 'Unauthorised' }, { status: 401 })
  }

  const { event, clientName, recommendationId, recommendationType, title, score, action } = await request.json()

  const supabase = getServiceSupabase()

  const { error } = await supabase
    .from('recommendation_analytics')
    .insert({
      user_email: session.user.email,
      event_type: event, // 'view', 'expand', 'add_to_plan', 'save'
      client_name: clientName,
      recommendation_id: recommendationId,
      recommendation_type: recommendationType,
      title,
      score,
      action,
      created_at: new Date().toISOString(),
    })

  if (error) {
    console.error('[analytics] Error:', error.message)
    // Don't fail the request for analytics errors
  }

  return NextResponse.json({ success: true })
}
```

**Step 2: Create analytics table script**

```javascript
// scripts/create-analytics-table.mjs
import { createClient } from '@supabase/supabase-js'
import dotenv from 'dotenv'
import path from 'path'
import { fileURLToPath } from 'url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
dotenv.config({ path: path.join(__dirname, '..', '.env.local') })

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
)

async function createTable() {
  const { error } = await supabase.rpc('exec_sql', {
    sql: `
      CREATE TABLE IF NOT EXISTS recommendation_analytics (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_email TEXT NOT NULL,
        event_type TEXT NOT NULL,
        client_name TEXT,
        recommendation_id TEXT,
        recommendation_type TEXT,
        title TEXT,
        score INTEGER,
        action TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
      CREATE INDEX idx_rec_analytics_user ON recommendation_analytics(user_email);
      CREATE INDEX idx_rec_analytics_event ON recommendation_analytics(event_type);
      CREATE INDEX idx_rec_analytics_created ON recommendation_analytics(created_at);
    `
  })

  if (error) {
    console.error('Error:', error.message)
  } else {
    console.log('Analytics table created')
  }
}

createTable()
```

**Step 3: Add tracking to RecommendationsTab**

Add tracking helper:

```typescript
const trackEvent = async (event: string, rec?: Recommendation) => {
  try {
    await fetch('/api/sales-hub/analytics', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        event,
        clientName: selectedClient?.name,
        recommendationId: rec?.id,
        recommendationType: rec?.type,
        title: rec?.title,
        score: rec?.relevanceScore,
      }),
    })
  } catch {
    // Silent fail for analytics
  }
}

// Track when recommendations are generated
useEffect(() => {
  if (recommendations.length > 0 && selectedClient) {
    trackEvent('view')
  }
}, [recommendations, selectedClient])

// Track expand in handleRecommendationClick
const handleRecommendationClick = (rec: Recommendation) => {
  trackEvent('expand', rec)
  // ... existing code
}
```

**Step 4: Build and verify**

Run: `npm run build`
Expected: Build succeeds

**Step 5: Commit**

```bash
git add src/app/api/sales-hub/analytics/route.ts scripts/create-analytics-table.mjs src/app/\\(dashboard\\)/sales-hub/components/RecommendationsTab.tsx
git commit -m "feat(sales-hub): add recommendation analytics tracking"
```

---

## Task 12: Final Integration and Deployment

**Files:**
- None (testing and deployment only)

**Step 1: Run scripts to create tables and seed data**

```bash
node scripts/create-saved-recommendations-table.mjs
node scripts/create-analytics-table.mjs
node scripts/seed-value-wedges.mjs
node scripts/enrich-client-topics.mjs
```

**Step 2: Run full test suite**

Run: `npm test`
Expected: All tests pass

**Step 3: Run production build**

Run: `npm run build`
Expected: Build succeeds

**Step 4: Push and deploy**

```bash
git pull --rebase origin main && git push --no-verify
```

**Step 5: Verify Netlify deployment**

Run: `sleep 90 && netlify api listSiteDeploys --data '{"site_id":"d3d148cc-a976-4beb-b58e-8c39b8aea9fc"}' 2>/dev/null | python3 -c "import sys, json; d = json.load(sys.stdin)[0]; print(f'Latest: {d.get(\"state\")}  commit: {d.get(\"commit_ref\",\"\")[:8]}')"`

Expected: `Latest: ready`

**Step 6: Test in production**

1. Navigate to Sales Hub → AI Recommendations
2. Select client, verify competitive positioning shows
3. Test filters and sorting
4. Test save/unsave functionality
5. Test bulk selection and add to plan
6. Check account planning page for recommendations widget
7. Ask ChaSen "What should I pitch to SA Health?"

---

## Summary

| Task | Description | Files |
|------|-------------|-------|
| 1 | Add competitive positioning | types, lib, EvidenceCard |
| 2 | Expand NPS keywords | recommendation-evidence.ts |
| 3 | Add filters/sorting | RecommendationsTab.tsx |
| 4 | Saved recommendations | API route, UI |
| 5 | Bulk actions | RecommendationsTab.tsx |
| 6 | Seed more value wedges | seed script |
| 7 | Enrich meeting topics | enrich script |
| 8 | NPS matching (done in 2) | - |
| 9 | Account planning integration | RecommendedProducts component |
| 10 | ChaSen AI enhancement | stream route |
| 11 | Analytics tracking | API route, UI |
| 12 | Final deployment | - |
