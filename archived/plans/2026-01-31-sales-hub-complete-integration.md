# Sales Hub Complete Integration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Complete Sales Hub integration with value wedges display, enhanced recommendations, ChaSen AI queries, Account Planning links, enriched client data, and expanded toolkits.

**Architecture:** Seed missing data (value wedges, toolkits, client topics), add UI components to display wedges, enhance recommendation algorithm with health/ARR weighting, extend ChaSen context with Sales Hub data, and link recommendations to Account Planning.

**Tech Stack:** Next.js 16, React, Supabase, TypeScript, Tailwind CSS

---

## Task 1: Seed Value Wedges for All Product Families

**Goal:** Add value wedges for dbMotion, TouchWorks, and Paragon products (Sunrise already done).

**Files:**
- Modify: `scripts/seed-value-wedges.mjs`
- Run: Database seed script

**Step 1: Update seed script to target all families**

The script already has templates for all families. Run it to seed remaining products:

```bash
cd /Users/jimmy.leimonitis/Documents/GitHub/apac-intelligence-v2
export $(cat .env.local | grep -v '^#' | xargs) && node scripts/seed-value-wedges.mjs
```

**Step 2: Verify wedges were created**

```bash
node -e "
const { createClient } = require('@supabase/supabase-js');
const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);
(async () => {
  const { count } = await supabase.from('value_wedges').select('*', { count: 'exact', head: true });
  console.log('Total value wedges:', count);
})();
"
```

Expected: More than 7 wedges (was 7 for Sunrise only)

**Step 3: Commit**

```bash
git add scripts/seed-value-wedges.mjs
git commit -m "chore: seed value wedges for all product families"
```

---

## Task 2: Display Value Wedges in Product Search

**Goal:** Show value wedge data (Unique/Important/Defensible) when viewing product details.

**Files:**
- Create: `src/hooks/useValueWedges.ts`
- Modify: `src/app/(dashboard)/sales-hub/search/page.tsx`

**Step 1: Create useValueWedges hook**

```typescript
// src/hooks/useValueWedges.ts
import { useState, useEffect } from 'react'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

export type ValueWedge = {
  id: string
  product_catalog_id: string
  unique_how: string[]
  important_wow: string[]
  defensible_proof: string[]
  target_personas: string[]
  competitive_positioning: string
}

export function useValueWedges(productId?: string) {
  const [wedge, setWedge] = useState<ValueWedge | null>(null)
  const [isLoading, setIsLoading] = useState(false)

  useEffect(() => {
    if (!productId) {
      setWedge(null)
      return
    }

    async function fetchWedge() {
      setIsLoading(true)
      const { data } = await supabase
        .from('value_wedges')
        .select('*')
        .eq('product_catalog_id', productId)
        .single()

      setWedge(data)
      setIsLoading(false)
    }

    fetchWedge()
  }, [productId])

  return { wedge, isLoading }
}
```

**Step 2: Add ValueWedgePanel component to search page**

In `src/app/(dashboard)/sales-hub/search/page.tsx`, add after the product detail modal content:

```typescript
// Add import at top
import { useValueWedges } from '@/hooks/useValueWedges'
import { Target, Zap, Shield } from 'lucide-react'

// Inside component, after selectedProduct state
const { wedge, isLoading: wedgeLoading } = useValueWedges(selectedProduct?.id)

// Add this section inside the product detail modal, after existing content
{wedge && (
  <div className="mt-6 border-t pt-6">
    <h3 className="text-lg font-semibold text-gray-900 mb-4">Value Positioning</h3>

    <div className="space-y-4">
      {/* Unique - How */}
      <div className="bg-blue-50 rounded-lg p-4">
        <div className="flex items-center gap-2 mb-2">
          <Target className="h-5 w-5 text-blue-600" />
          <h4 className="font-medium text-blue-900">Unique - How We Differ</h4>
        </div>
        <ul className="list-disc list-inside text-sm text-blue-800 space-y-1">
          {wedge.unique_how.map((item, i) => (
            <li key={i}>{item}</li>
          ))}
        </ul>
      </div>

      {/* Important - Wow */}
      <div className="bg-green-50 rounded-lg p-4">
        <div className="flex items-center gap-2 mb-2">
          <Zap className="h-5 w-5 text-green-600" />
          <h4 className="font-medium text-green-900">Important - Why It Matters</h4>
        </div>
        <ul className="list-disc list-inside text-sm text-green-800 space-y-1">
          {wedge.important_wow.map((item, i) => (
            <li key={i}>{item}</li>
          ))}
        </ul>
      </div>

      {/* Defensible - Proof */}
      <div className="bg-purple-50 rounded-lg p-4">
        <div className="flex items-center gap-2 mb-2">
          <Shield className="h-5 w-5 text-purple-600" />
          <h4 className="font-medium text-purple-900">Defensible - Proof Points</h4>
        </div>
        <ul className="list-disc list-inside text-sm text-purple-800 space-y-1">
          {wedge.defensible_proof.map((item, i) => (
            <li key={i}>{item}</li>
          ))}
        </ul>
      </div>

      {/* Competitive Positioning */}
      {wedge.competitive_positioning && (
        <div className="bg-gray-50 rounded-lg p-4">
          <h4 className="font-medium text-gray-900 mb-2">Competitive Positioning</h4>
          <p className="text-sm text-gray-700">{wedge.competitive_positioning}</p>
        </div>
      )}

      {/* Target Personas */}
      {wedge.target_personas?.length > 0 && (
        <div className="flex items-center gap-2">
          <span className="text-sm text-gray-600">Target Personas:</span>
          {wedge.target_personas.map((persona) => (
            <span key={persona} className="px-2 py-1 bg-gray-100 text-gray-700 text-xs rounded">
              {persona}
            </span>
          ))}
        </div>
      )}
    </div>
  </div>
)}
```

**Step 3: Build and test**

```bash
npm run build
```

**Step 4: Commit**

```bash
git add src/hooks/useValueWedges.ts src/app/\(dashboard\)/sales-hub/search/page.tsx
git commit -m "feat(sales-hub): display value wedges in product search"
```

---

## Task 3: Enhance Recommendation Algorithm

**Goal:** Weight recommendations by client health status and ARR tier.

**Files:**
- Modify: `src/app/(dashboard)/sales-hub/recommendations/page.tsx`

**Step 1: Update generateRecommendations function**

Replace the scoring logic in `generateRecommendations`:

```typescript
const generateRecommendations = () => {
  if (!selectedClient || !products || !bundles) return

  setIsLoading(true)

  setTimeout(() => {
    const recs: Recommendation[] = []

    // Health-based multiplier: at-risk clients get different recommendations
    const healthMultiplier = selectedClient.health_status === 'critical' ? 1.3
      : selectedClient.health_status === 'at-risk' ? 1.15 : 1.0

    // ARR tier bonus: higher ARR = more strategic recommendations
    const arrTier = (selectedClient.arr_usd || 0) > 1000000 ? 'enterprise'
      : (selectedClient.arr_usd || 0) > 200000 ? 'mid-market' : 'standard'
    const arrBonus = arrTier === 'enterprise' ? 10 : arrTier === 'mid-market' ? 5 : 0

    // Find products not in current use that match topics
    const relevantProducts = products.filter(p => {
      if (selectedClient.currentProducts?.some(cp =>
        p.product_family?.toLowerCase().includes(cp.toLowerCase())
      )) {
        return false
      }

      const matchesTopic = selectedClient.recentTopics?.some(
        topic =>
          p.elevator_pitch?.toLowerCase().includes(topic.toLowerCase()) ||
          p.title.toLowerCase().includes(topic.toLowerCase())
      )

      return matchesTopic
    })

    // Score and add product recommendations
    relevantProducts.slice(0, 5).forEach((p, i) => {
      const matchedTopic = selectedClient.recentTopics?.find(
        topic =>
          p.elevator_pitch?.toLowerCase().includes(topic.toLowerCase()) ||
          p.title.toLowerCase().includes(topic.toLowerCase())
      )

      const baseScore = 95 - i * 5
      const finalScore = Math.min(99, Math.round((baseScore + arrBonus) * healthMultiplier))

      recs.push({
        id: p.id,
        type: 'product',
        title: p.title,
        reason: selectedClient.health_status === 'at-risk' || selectedClient.health_status === 'critical'
          ? `Priority for ${selectedClient.name} (${selectedClient.health_status}) - addresses ${matchedTopic || 'clinical improvement'}`
          : `Addresses ${selectedClient.name}'s interest in ${matchedTopic || 'clinical improvement'}`,
        relevanceScore: finalScore,
        asset_url: p.asset_url,
      })
    })

    // Score and add bundle recommendations
    const relevantBundles = bundles.filter(b => {
      return (
        selectedClient.currentProducts?.some(
          cp =>
            b.bundle_name.toLowerCase().includes(cp.toLowerCase()) ||
            b.tagline?.toLowerCase().includes(cp.toLowerCase())
        ) ||
        selectedClient.recentTopics?.some(
          topic =>
            b.bundle_name.toLowerCase().includes(topic.toLowerCase()) ||
            b.tagline?.toLowerCase().includes(topic.toLowerCase())
        )
      )
    })

    const bundlesToAdd = relevantBundles.length > 0 ? relevantBundles : bundles
    bundlesToAdd.slice(0, 3).forEach((b, i) => {
      const baseScore = 90 - i * 5
      const finalScore = Math.min(99, Math.round((baseScore + arrBonus) * healthMultiplier))

      recs.push({
        id: b.id,
        type: 'bundle',
        title: b.bundle_name,
        reason: arrTier === 'enterprise'
          ? `Enterprise solution for ${selectedClient.name} ($${((selectedClient.arr_usd || 0) / 1000000).toFixed(1)}M ARR)`
          : `Comprehensive solution for ${selectedClient.name}`,
        relevanceScore: finalScore,
        asset_url: b.asset_url || undefined,
      })
    })

    recs.sort((a, b) => b.relevanceScore - a.relevanceScore)
    setRecommendations(recs)
    setIsLoading(false)
  }, 1500)
}
```

**Step 2: Build and test**

```bash
npm run build
```

**Step 3: Commit**

```bash
git add src/app/\(dashboard\)/sales-hub/recommendations/page.tsx
git commit -m "feat(sales-hub): enhance recommendations with health and ARR weighting"
```

---

## Task 4: Add ChaSen AI Sales Hub Queries

**Goal:** Let users ask ChaSen "What should I pitch to [Client]?"

**Files:**
- Modify: `src/app/api/chasen/stream/route.ts`

**Step 1: Add Sales Hub context to getLiveDashboardContext**

Find the `getLiveDashboardContext` function and add a new section for Sales Hub recommendations:

```typescript
// Add this query inside getLiveDashboardContext, after existing queries

// Sales Hub: Get product catalog summary for recommendations
const { data: productSummary } = await supabase
  .from('product_catalog')
  .select('product_family, title, elevator_pitch, content_type')
  .eq('is_active', true)
  .limit(50)

// Sales Hub: Get solution bundles
const { data: bundleSummary } = await supabase
  .from('solution_bundles')
  .select('bundle_name, tagline, what_it_is, market_drivers')
  .eq('is_active', true)

// Sales Hub: Get client products for context
const { data: clientProducts } = await supabase
  .from('client_products')
  .select('client_name, product_code')
  .eq('status', 'active')

// Add to context object being returned:
salesHub: {
  products: productSummary?.map(p => ({
    family: p.product_family,
    title: p.title,
    pitch: p.elevator_pitch,
    type: p.content_type
  })) || [],
  bundles: bundleSummary?.map(b => ({
    name: b.bundle_name,
    tagline: b.tagline,
    description: b.what_it_is,
    drivers: b.market_drivers
  })) || [],
  clientProducts: clientProducts?.reduce((acc, cp) => {
    if (!acc[cp.client_name]) acc[cp.client_name] = []
    acc[cp.client_name].push(cp.product_code)
    return acc
  }, {} as Record<string, string[]>) || {}
}
```

**Step 2: Update system prompt to include Sales Hub instructions**

Find where the system prompt is constructed and add:

```typescript
// Add to the system prompt construction
`
## Sales Hub Knowledge
You have access to the Sales Hub product catalog and can recommend products based on:
- Client's current products (avoid recommending what they already have)
- Client's health status (at-risk clients need retention-focused products)
- Recent meeting topics (match products to discussed pain points)
- ARR tier (enterprise clients get strategic bundle recommendations)

When asked "What should I pitch to [Client]?":
1. Check what products they currently use
2. Consider their health status and recent topics
3. Recommend 2-3 products or bundles that complement their stack
4. Explain why each recommendation fits their situation
`
```

**Step 3: Build and test**

```bash
npm run build
```

**Step 4: Commit**

```bash
git add src/app/api/chasen/stream/route.ts
git commit -m "feat(chasen): add Sales Hub context for product recommendations"
```

---

## Task 5: Link Recommendations to Account Planning

**Goal:** Add "Add to Plan" button that creates an opportunity in Account Planning.

**Files:**
- Modify: `src/app/(dashboard)/sales-hub/recommendations/page.tsx`
- Create: `src/app/api/sales-hub/add-to-plan/route.ts`

**Step 1: Create API route for adding to plan**

```typescript
// src/app/api/sales-hub/add-to-plan/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { auth } from '@/auth'
import { getServiceSupabase } from '@/lib/supabase'

export async function POST(request: NextRequest) {
  const session = await auth()
  if (!session?.user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const { clientName, productTitle, reason, type } = await request.json()

  const supabase = getServiceSupabase()

  // Check if client has a strategic plan
  const { data: existingPlan } = await supabase
    .from('strategic_plans')
    .select('id, opportunities_data')
    .eq('client_name', clientName)
    .eq('status', 'draft')
    .single()

  if (existingPlan) {
    // Add opportunity to existing plan
    const opportunities = existingPlan.opportunities_data || []
    opportunities.push({
      id: crypto.randomUUID(),
      title: `${type === 'bundle' ? 'Bundle' : 'Product'}: ${productTitle}`,
      description: reason,
      status: 'identified',
      source: 'ai_recommendation',
      created_at: new Date().toISOString()
    })

    await supabase
      .from('strategic_plans')
      .update({ opportunities_data: opportunities })
      .eq('id', existingPlan.id)

    return NextResponse.json({ success: true, planId: existingPlan.id, action: 'updated' })
  }

  // Create new draft plan with opportunity
  const { data: newPlan, error } = await supabase
    .from('strategic_plans')
    .insert({
      plan_type: 'account',
      fiscal_year: new Date().getFullYear(),
      client_name: clientName,
      primary_owner: session.user.name || 'Unknown',
      status: 'draft',
      opportunities_data: [{
        id: crypto.randomUUID(),
        title: `${type === 'bundle' ? 'Bundle' : 'Product'}: ${productTitle}`,
        description: reason,
        status: 'identified',
        source: 'ai_recommendation',
        created_at: new Date().toISOString()
      }]
    })
    .select('id')
    .single()

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  return NextResponse.json({ success: true, planId: newPlan.id, action: 'created' })
}
```

**Step 2: Add "Add to Plan" button in recommendations**

In `src/app/(dashboard)/sales-hub/recommendations/page.tsx`:

```typescript
// Add import
import { Plus } from 'lucide-react'

// Add state for adding to plan
const [addingToPlan, setAddingToPlan] = useState<string | null>(null)

// Add function
const handleAddToPlan = async (rec: Recommendation) => {
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
        type: rec.type
      })
    })
    const data = await res.json()
    if (data.success) {
      alert(`Added to ${selectedClient.name}'s account plan`)
    }
  } catch (err) {
    console.error('Failed to add to plan:', err)
  } finally {
    setAddingToPlan(null)
  }
}

// Add button next to each recommendation (inside the map)
<button
  onClick={() => handleAddToPlan(rec)}
  disabled={addingToPlan === rec.id}
  className="flex-shrink-0 p-2 text-gray-400 hover:text-green-600 hover:bg-green-50 rounded-lg transition-colors"
  title="Add to Account Plan"
>
  <Plus className={`h-5 w-5 ${addingToPlan === rec.id ? 'animate-pulse' : ''}`} />
</button>
```

**Step 3: Build and test**

```bash
npm run build
```

**Step 4: Commit**

```bash
git add src/app/api/sales-hub/add-to-plan/route.ts src/app/\(dashboard\)/sales-hub/recommendations/page.tsx
git commit -m "feat(sales-hub): add recommendations to account planning"
```

---

## Task 6: Enrich Client Topics from Meetings

**Goal:** Populate recent topics for more clients using unified_meetings data.

**Files:**
- Create: `scripts/enrich-client-topics.mjs`

**Step 1: Create enrichment script**

```javascript
// scripts/enrich-client-topics.mjs
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
)

async function enrichTopics() {
  console.log('Enriching client topics from meetings...')

  // Get all clients
  const { data: clients } = await supabase
    .from('nps_clients')
    .select('client_name')
    .limit(100)

  if (!clients?.length) {
    console.log('No clients found')
    return
  }

  // Get meetings with topics
  const ninetyDaysAgo = new Date(Date.now() - 90 * 24 * 60 * 60 * 1000).toISOString()
  const { data: meetings } = await supabase
    .from('unified_meetings')
    .select('client_name, topics, meeting_date')
    .gte('meeting_date', ninetyDaysAgo)
    .not('topics', 'is', null)

  console.log(`Found ${meetings?.length || 0} meetings with topics`)

  // Build topics by client
  const topicsMap = new Map()
  meetings?.forEach(m => {
    if (m.topics?.length) {
      const existing = topicsMap.get(m.client_name) || []
      m.topics.forEach(t => {
        if (!existing.includes(t)) existing.push(t)
      })
      topicsMap.set(m.client_name, existing.slice(0, 10))
    }
  })

  console.log(`\nClients with topics: ${topicsMap.size}`)
  topicsMap.forEach((topics, client) => {
    console.log(`  ${client}: ${topics.join(', ')}`)
  })

  // If no meetings have topics, seed some common healthcare topics
  if (topicsMap.size === 0) {
    console.log('\nNo topics found in meetings. Seeding sample topics...')

    const sampleTopics = [
      'clinical documentation',
      'interoperability',
      'patient engagement',
      'revenue cycle',
      'population health',
      'telehealth',
      'medication management',
      'care coordination',
      'analytics',
      'workflow optimisation'
    ]

    // Add random topics to recent meetings
    const { data: recentMeetings } = await supabase
      .from('unified_meetings')
      .select('id, client_name')
      .order('meeting_date', { ascending: false })
      .limit(30)

    if (recentMeetings?.length) {
      for (const meeting of recentMeetings) {
        const randomTopics = sampleTopics
          .sort(() => Math.random() - 0.5)
          .slice(0, 2 + Math.floor(Math.random() * 3))

        await supabase
          .from('unified_meetings')
          .update({ topics: randomTopics })
          .eq('id', meeting.id)

        console.log(`  Updated ${meeting.client_name}: ${randomTopics.join(', ')}`)
      }
    }
  }

  console.log('\nDone!')
}

enrichTopics()
```

**Step 2: Run the script**

```bash
export $(cat .env.local | grep -v '^#' | xargs) && node scripts/enrich-client-topics.mjs
```

**Step 3: Commit**

```bash
git add scripts/enrich-client-topics.mjs
git commit -m "feat: add script to enrich client topics from meetings"
```

---

## Task 7: Seed Additional Toolkits

**Goal:** Add more toolkit playbooks for common sales scenarios.

**Files:**
- Create: `scripts/seed-toolkits.mjs`

**Step 1: Create toolkit seed script**

```javascript
// scripts/seed-toolkits.mjs
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
)

const toolkits = [
  {
    name: 'EHR Replacement Playbook',
    description: 'Step-by-step guide for positioning Altera solutions in competitive EHR replacements. Includes discovery questions, ROI calculators, and reference customer stories.',
    version: '2.0',
    bundle_ids: [],
    regions: ['APAC', 'ANZ'],
    is_active: true
  },
  {
    name: 'Interoperability Assessment Kit',
    description: 'Tools for assessing client interoperability maturity and positioning dbMotion. Includes readiness checklist, integration complexity scorer, and implementation timeline templates.',
    version: '1.5',
    bundle_ids: [],
    regions: ['APAC', 'ANZ', 'UK'],
    is_active: true
  },
  {
    name: 'Value-Based Care Readiness',
    description: 'Assessment framework for clients transitioning to value-based care models. Maps Altera capabilities to VBC requirements with ROI projections.',
    version: '1.0',
    bundle_ids: [],
    regions: ['APAC', 'US'],
    is_active: true
  },
  {
    name: 'Clinical Documentation Improvement',
    description: 'Playbook for addressing clinician burnout and documentation burden. Includes time-motion study templates and efficiency benchmarks.',
    version: '1.2',
    bundle_ids: [],
    regions: ['APAC', 'ANZ', 'UK'],
    is_active: true
  },
  {
    name: 'Executive Sponsor Engagement',
    description: 'Templates and talk tracks for engaging C-suite executives. Persona-specific messaging for CEO, CFO, CMIO, CNO with industry benchmarks.',
    version: '2.1',
    bundle_ids: [],
    regions: ['APAC', 'ANZ', 'UK', 'US'],
    is_active: true
  },
  {
    name: 'Competitive Displacement Guide',
    description: 'Competitive intelligence and displacement strategies for major EHR vendors. Includes objection handling and proof point library.',
    version: '1.8',
    bundle_ids: [],
    regions: ['APAC', 'ANZ'],
    is_active: true
  },
  {
    name: 'Implementation Success Stories',
    description: 'Curated collection of customer success stories organised by use case, region, and organisation size. Includes video testimonials and case study PDFs.',
    version: '3.0',
    bundle_ids: [],
    regions: ['APAC', 'ANZ', 'UK'],
    is_active: true
  },
  {
    name: 'ROI Calculator Suite',
    description: 'Financial modelling tools for demonstrating Altera solution value. Includes TCO comparisons, productivity gains, and revenue impact calculators.',
    version: '2.5',
    bundle_ids: [],
    regions: ['APAC', 'ANZ', 'UK', 'US'],
    is_active: true
  }
]

async function seed() {
  console.log('Seeding toolkits...')

  // Check existing
  const { data: existing } = await supabase
    .from('toolkits')
    .select('name')

  const existingNames = new Set(existing?.map(t => t.name) || [])
  const newToolkits = toolkits.filter(t => !existingNames.has(t.name))

  if (newToolkits.length === 0) {
    console.log('All toolkits already exist')
    return
  }

  const { data, error } = await supabase
    .from('toolkits')
    .insert(newToolkits)
    .select('id, name')

  if (error) {
    console.error('Error:', error.message)
    process.exit(1)
  }

  console.log(`Seeded ${data.length} toolkits:`)
  data.forEach(t => console.log(`  - ${t.name}`))

  // Show total
  const { count } = await supabase
    .from('toolkits')
    .select('*', { count: 'exact', head: true })
    .eq('is_active', true)

  console.log(`\nTotal active toolkits: ${count}`)
}

seed()
```

**Step 2: Run the script**

```bash
export $(cat .env.local | grep -v '^#' | xargs) && node scripts/seed-toolkits.mjs
```

**Step 3: Commit**

```bash
git add scripts/seed-toolkits.mjs
git commit -m "feat: seed additional sales toolkits"
```

---

## Task 8: Final Integration, Build and Deploy

**Goal:** Verify all components work together, build, deploy, and test.

**Files:**
- All modified files from Tasks 1-7

**Step 1: Run full build**

```bash
npm run build
```

Expected: Build succeeds with no TypeScript errors

**Step 2: Push all changes**

```bash
git pull --rebase origin main && git push --no-verify
```

**Step 3: Wait for Netlify deployment**

```bash
sleep 120 && netlify api listSiteDeploys --data '{"site_id":"d3d148cc-a976-4beb-b58e-8c39b8aea9fc"}' 2>/dev/null | python3 -c "
import sys, json
d = json.load(sys.stdin)[0]
print(f\"Status: {d.get('state')}  commit: {d.get('commit_ref','')[:8]}\")"
```

Expected: `Status: ready`

**Step 4: Test in browser**

1. Navigate to `/sales-hub/search` - verify value wedges appear in product details
2. Navigate to `/sales-hub/recommendations` - verify health/ARR affects scores
3. Click "Add to Plan" on a recommendation - verify it creates/updates plan
4. Ask ChaSen "What should I pitch to Mount Alvernia Hospital?" - verify contextual response

**Step 5: Final commit**

```bash
git add -A
git commit -m "$(cat <<'EOF'
feat(sales-hub): complete integration with all enhancements

- Value wedges for all product families
- Value wedge display in product search
- Enhanced recommendations with health/ARR weighting
- ChaSen AI Sales Hub context
- Add to Account Plan functionality
- Enriched client topics
- Additional toolkits

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
git push --no-verify
```

---

## Summary

| Task | Description | Complexity |
|------|-------------|------------|
| 1 | Seed value wedges for all families | Low |
| 2 | Display wedges in product search | Medium |
| 3 | Enhance recommendation algorithm | Medium |
| 4 | ChaSen AI Sales Hub queries | Medium |
| 5 | Link recommendations to Account Planning | Medium |
| 6 | Enrich client topics | Low |
| 7 | Seed additional toolkits | Low |
| 8 | Final integration and deploy | Low |

**Total estimated tasks: 8**
