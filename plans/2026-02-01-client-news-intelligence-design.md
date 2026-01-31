# Client News Intelligence System - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Enable Sales Hub to display news articles that specifically mention clients, helping sales teams prepare for client conversations with current context.

**Architecture:** Hybrid RSS fetching (free) with ChaSen AI verification (already paid). Daily automated sync plus on-demand refresh. Client name aliases handle variations like "RMH" for "Royal Melbourne Hospital".

**Tech Stack:** Next.js API routes, Supabase, Google News RSS, ChaSen AI (callMatchaAI), rss-parser npm package

---

## Task 1: Create Database Migration

**Files:**
- Create: `supabase/migrations/20260201_client_news_tables.sql`

**Step 1: Write the migration file**

```sql
-- Client News Intelligence Tables
-- Stores news articles mentioning specific clients and their name aliases

-- Client name aliases for search variations
CREATE TABLE IF NOT EXISTS client_name_aliases (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id INTEGER REFERENCES nps_clients(id) ON DELETE CASCADE,
  client_name TEXT NOT NULL,
  alias TEXT NOT NULL,
  alias_type TEXT DEFAULT 'manual',  -- 'manual', 'abbreviation', 'ai-suggested'
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_id, alias)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_client_aliases_client ON client_name_aliases(client_id);
CREATE INDEX IF NOT EXISTS idx_client_aliases_active ON client_name_aliases(is_active);

-- RLS
ALTER TABLE client_name_aliases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "client_aliases_read_policy" ON client_name_aliases FOR SELECT USING (true);
CREATE POLICY "client_aliases_write_policy" ON client_name_aliases FOR ALL USING (auth.role() = 'service_role');

-- Client news articles
CREATE TABLE IF NOT EXISTS client_news (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id INTEGER REFERENCES nps_clients(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  summary TEXT,
  source TEXT,
  source_url TEXT,
  published_date DATE,
  matched_alias TEXT,
  confidence_score INTEGER DEFAULT 100,
  news_type TEXT DEFAULT 'mention',  -- 'mention', 'announcement', 'award', 'leadership'
  is_verified BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  fetched_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_id, title)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_client_news_client ON client_news(client_id);
CREATE INDEX IF NOT EXISTS idx_client_news_published ON client_news(published_date DESC);
CREATE INDEX IF NOT EXISTS idx_client_news_active ON client_news(is_active, client_id);

-- RLS
ALTER TABLE client_news ENABLE ROW LEVEL SECURITY;
CREATE POLICY "client_news_read_policy" ON client_news FOR SELECT USING (true);
CREATE POLICY "client_news_write_policy" ON client_news FOR ALL USING (auth.role() = 'service_role');

COMMENT ON TABLE client_name_aliases IS 'Search aliases for client names (e.g., RMH for Royal Melbourne Hospital)';
COMMENT ON TABLE client_news IS 'News articles mentioning specific clients';
```

**Step 2: Run migration**

```bash
npx supabase db push
```

**Step 3: Verify tables created**

```bash
npx supabase db dump --schema public | grep -E "client_news|client_name_aliases"
```

**Step 4: Commit**

```bash
git add supabase/migrations/20260201_client_news_tables.sql
git commit -m "feat(db): add client_news and client_name_aliases tables"
```

---

## Task 2: Create Alias Seed Script

**Files:**
- Create: `scripts/seed-client-aliases.mjs`

**Step 1: Write the seed script**

```javascript
#!/usr/bin/env node
/**
 * Seed client_name_aliases table with initial aliases
 * Generates abbreviations and common variations from client names
 */

import { createClient } from '@supabase/supabase-js'
import dotenv from 'dotenv'
dotenv.config({ path: '.env.local' })

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
)

// Generate abbreviation from name (e.g., "Royal Melbourne Hospital" -> "RMH")
function generateAbbreviation(name) {
  const words = name.split(/\s+/).filter(w =>
    !['the', 'of', 'and', 'for', 'in', 'at'].includes(w.toLowerCase())
  )
  if (words.length < 2) return null
  return words.map(w => w[0]).join('').toUpperCase()
}

// Generate common variations
function generateVariations(name) {
  const variations = []

  // Abbreviation
  const abbrev = generateAbbreviation(name)
  if (abbrev && abbrev.length >= 2 && abbrev.length <= 6) {
    variations.push({ alias: abbrev, type: 'abbreviation' })
  }

  // Without "The"
  if (name.toLowerCase().startsWith('the ')) {
    variations.push({ alias: name.slice(4), type: 'manual' })
  }

  // Hospital -> Health variations
  if (name.includes('Hospital')) {
    variations.push({ alias: name.replace('Hospital', 'Health'), type: 'manual' })
  }

  // Saint -> St variations
  if (name.includes('Saint')) {
    variations.push({ alias: name.replace('Saint', 'St'), type: 'manual' })
  }
  if (name.includes("St ") || name.includes("St.")) {
    variations.push({ alias: name.replace(/St\.?\s/, 'Saint '), type: 'manual' })
  }

  return variations
}

async function seedAliases() {
  console.log('Fetching clients...')

  const { data: clients, error } = await supabase
    .from('nps_clients')
    .select('id, client_name')
    .order('client_name')

  if (error) {
    console.error('Error fetching clients:', error)
    process.exit(1)
  }

  console.log(`Found ${clients.length} clients`)

  const aliases = []

  for (const client of clients) {
    const variations = generateVariations(client.client_name)

    for (const v of variations) {
      aliases.push({
        client_id: client.id,
        client_name: client.client_name,
        alias: v.alias,
        alias_type: v.type,
        is_active: true,
      })
    }
  }

  console.log(`Generated ${aliases.length} aliases`)

  if (aliases.length > 0) {
    const { error: insertError } = await supabase
      .from('client_name_aliases')
      .upsert(aliases, { onConflict: 'client_id,alias', ignoreDuplicates: true })

    if (insertError) {
      console.error('Error inserting aliases:', insertError)
      process.exit(1)
    }

    console.log('Aliases seeded successfully')
  }

  // Show sample
  const { data: sample } = await supabase
    .from('client_name_aliases')
    .select('client_name, alias, alias_type')
    .limit(10)

  console.log('\nSample aliases:')
  console.table(sample)
}

seedAliases()
```

**Step 2: Run the seed script**

```bash
node scripts/seed-client-aliases.mjs
```

**Step 3: Verify aliases created**

```bash
# Check count
node -e "..." # Query to count aliases
```

**Step 4: Commit**

```bash
git add scripts/seed-client-aliases.mjs
git commit -m "feat(scripts): add client alias seed script"
```

---

## Task 3: Create useClientNews Hook

**Files:**
- Create: `src/hooks/useClientNews.ts`

**Step 1: Write the hook**

```typescript
/**
 * Hook for fetching client-specific news articles
 */

import { useState, useEffect, useCallback } from 'react'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

export type ClientNews = {
  id: string
  client_id: number
  title: string
  summary: string | null
  source: string | null
  source_url: string | null
  published_date: string | null
  matched_alias: string | null
  confidence_score: number
  news_type: string
  is_verified: boolean
}

export function useClientNews(clientId: number | null) {
  const [news, setNews] = useState<ClientNews[]>([])
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<Error | null>(null)

  const fetchNews = useCallback(async () => {
    if (!clientId) {
      setNews([])
      return
    }

    setIsLoading(true)
    setError(null)

    try {
      const { data, error: fetchError } = await supabase
        .from('client_news')
        .select('*')
        .eq('client_id', clientId)
        .eq('is_active', true)
        .gte('confidence_score', 70)
        .order('published_date', { ascending: false })
        .limit(10)

      if (fetchError) throw new Error(fetchError.message)
      setNews(data || [])
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to fetch client news'))
    } finally {
      setIsLoading(false)
    }
  }, [clientId])

  useEffect(() => {
    fetchNews()
  }, [fetchNews])

  const refresh = useCallback(async () => {
    if (!clientId) return

    setIsLoading(true)
    try {
      // Trigger on-demand refresh
      const res = await fetch('/api/sales-hub/client-news/refresh', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ clientId }),
      })

      if (!res.ok) throw new Error('Refresh failed')

      // Refetch after refresh
      await fetchNews()
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Refresh failed'))
    } finally {
      setIsLoading(false)
    }
  }, [clientId, fetchNews])

  return { news, isLoading, error, refresh }
}

/**
 * Get news counts for multiple clients (for badges)
 */
export async function getClientNewsCounts(
  clientIds: number[]
): Promise<Record<number, number>> {
  if (clientIds.length === 0) return {}

  const { data, error } = await supabase
    .from('client_news')
    .select('client_id')
    .in('client_id', clientIds)
    .eq('is_active', true)
    .gte('confidence_score', 70)

  if (error) {
    console.error('Failed to fetch news counts:', error)
    return {}
  }

  const counts: Record<number, number> = {}
  data?.forEach(row => {
    counts[row.client_id] = (counts[row.client_id] || 0) + 1
  })

  return counts
}
```

**Step 2: Verify TypeScript compiles**

```bash
npm run build
```

**Step 3: Commit**

```bash
git add src/hooks/useClientNews.ts
git commit -m "feat(hooks): add useClientNews hook for client-specific news"
```

---

## Task 4: Create News Fetch Pipeline (Cron API)

**Files:**
- Create: `src/app/api/cron/client-news-sync/route.ts`

**Step 1: Install rss-parser**

```bash
npm install rss-parser
```

**Step 2: Write the cron endpoint**

```typescript
/**
 * Daily cron job for syncing client-specific news
 * Fetches from Google News RSS, verifies with ChaSen AI
 *
 * Schedule: 0 6 * * * (6am daily)
 */

import { NextRequest, NextResponse } from 'next/server'
import { getServiceSupabase } from '@/lib/supabase'
import { callMatchaAI } from '@/lib/ai-providers'
import Parser from 'rss-parser'

const parser = new Parser()

type ClientWithAliases = {
  id: number
  client_name: string
  country: string | null
  aliases: string[]
}

// Country to Google News region mapping
const COUNTRY_TO_GOOGLE_REGION: Record<string, { hl: string; gl: string; ceid: string }> = {
  Australia: { hl: 'en-AU', gl: 'AU', ceid: 'AU:en' },
  'New Zealand': { hl: 'en-NZ', gl: 'NZ', ceid: 'NZ:en' },
  Singapore: { hl: 'en-SG', gl: 'SG', ceid: 'SG:en' },
  Philippines: { hl: 'en-PH', gl: 'PH', ceid: 'PH:en' },
  Guam: { hl: 'en-US', gl: 'US', ceid: 'US:en' },
}

async function fetchGoogleNewsRSS(
  query: string,
  region: { hl: string; gl: string; ceid: string }
): Promise<Array<{ title: string; summary: string; link: string; pubDate: string }>> {
  const url = `https://news.google.com/rss/search?q=${encodeURIComponent(query)}&hl=${region.hl}&gl=${region.gl}&ceid=${region.ceid}`

  try {
    const feed = await parser.parseURL(url)
    return feed.items.slice(0, 5).map(item => ({
      title: item.title || '',
      summary: item.contentSnippet || item.content || '',
      link: item.link || '',
      pubDate: item.pubDate || '',
    }))
  } catch (err) {
    console.error(`[News Sync] RSS fetch failed for query "${query}":`, err)
    return []
  }
}

async function verifyClientMention(
  article: { title: string; summary: string },
  clientName: string,
  aliases: string[]
): Promise<{ isMatch: boolean; confidence: number }> {
  try {
    const { text } = await callMatchaAI(
      [{
        role: 'user',
        content: `Does this news article specifically mention "${clientName}" (a healthcare organisation, also known as: ${aliases.join(', ')})?

Title: ${article.title}
Summary: ${article.summary}

Reply ONLY in JSON format: {"isMatch": true/false, "confidence": 0-100}`
      }],
      { model: 'claude-sonnet-4-5', maxTokens: 100, temperature: 0 }
    )

    const result = JSON.parse(text.trim())
    return { isMatch: result.isMatch, confidence: result.confidence }
  } catch (err) {
    console.error('[News Sync] AI verification failed:', err)
    return { isMatch: false, confidence: 0 }
  }
}

export async function POST(request: NextRequest) {
  try {
    // Verify cron secret
    const authHeader = request.headers.get('authorization')
    const cronSecret = process.env.CRON_SECRET
    if (cronSecret && authHeader !== `Bearer ${cronSecret}`) {
      console.log('[Client News Sync] Called without cron secret')
    }

    const supabase = getServiceSupabase()

    // Fetch clients with their aliases
    const { data: clients } = await supabase
      .from('nps_clients')
      .select('id, client_name, country')
      .limit(50)

    const { data: aliases } = await supabase
      .from('client_name_aliases')
      .select('client_id, alias')
      .eq('is_active', true)

    // Group aliases by client
    const aliasMap = new Map<number, string[]>()
    aliases?.forEach(a => {
      const existing = aliasMap.get(a.client_id) || []
      existing.push(a.alias)
      aliasMap.set(a.client_id, existing)
    })

    const clientsWithAliases: ClientWithAliases[] = (clients || []).map(c => ({
      id: c.id,
      client_name: c.client_name,
      country: c.country,
      aliases: aliasMap.get(c.id) || [],
    }))

    let totalArticles = 0
    let verifiedArticles = 0

    // Process each client
    for (const client of clientsWithAliases) {
      const region = COUNTRY_TO_GOOGLE_REGION[client.country || 'Australia'] ||
                     COUNTRY_TO_GOOGLE_REGION.Australia

      // Search for client name + healthcare context
      const query = `"${client.client_name}" healthcare OR hospital`
      const articles = await fetchGoogleNewsRSS(query, region)

      for (const article of articles) {
        totalArticles++

        // AI verification
        const verification = await verifyClientMention(
          article,
          client.client_name,
          client.aliases
        )

        if (verification.isMatch && verification.confidence >= 70) {
          verifiedArticles++

          // Upsert article
          await supabase.from('client_news').upsert({
            client_id: client.id,
            title: article.title,
            summary: article.summary.slice(0, 500),
            source: 'Google News',
            source_url: article.link,
            published_date: article.pubDate ? new Date(article.pubDate).toISOString().split('T')[0] : null,
            matched_alias: client.client_name,
            confidence_score: verification.confidence,
            is_verified: true,
            is_active: true,
            fetched_at: new Date().toISOString(),
          }, { onConflict: 'client_id,title' })
        }
      }

      // Rate limiting - small delay between clients
      await new Promise(r => setTimeout(r, 500))
    }

    // Deactivate old news (older than 30 days)
    const thirtyDaysAgo = new Date()
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)
    await supabase
      .from('client_news')
      .update({ is_active: false })
      .lt('published_date', thirtyDaysAgo.toISOString().split('T')[0])

    return NextResponse.json({
      success: true,
      message: 'Client news sync completed',
      clientsProcessed: clientsWithAliases.length,
      articlesFound: totalArticles,
      articlesVerified: verifiedArticles,
      syncedAt: new Date().toISOString(),
    })
  } catch (error) {
    console.error('[Client News Sync] Error:', error)
    return NextResponse.json(
      { error: error instanceof Error ? error.message : 'Sync failed' },
      { status: 500 }
    )
  }
}

// GET for status check
export async function GET() {
  const supabase = getServiceSupabase()

  const { count } = await supabase
    .from('client_news')
    .select('*', { count: 'exact', head: true })
    .eq('is_active', true)

  return NextResponse.json({
    status: 'ok',
    activeArticles: count || 0,
    endpoint: '/api/cron/client-news-sync (POST to trigger sync)',
  })
}
```

**Step 3: Build and verify**

```bash
npm run build
```

**Step 4: Commit**

```bash
git add package.json package-lock.json src/app/api/cron/client-news-sync/route.ts
git commit -m "feat(api): add client news sync cron endpoint"
```

---

## Task 5: Create On-Demand Refresh Endpoint

**Files:**
- Create: `src/app/api/sales-hub/client-news/refresh/route.ts`

**Step 1: Write the refresh endpoint**

```typescript
/**
 * On-demand refresh for a single client's news
 */

import { NextRequest, NextResponse } from 'next/server'
import { getServiceSupabase } from '@/lib/supabase'
import { callMatchaAI } from '@/lib/ai-providers'
import Parser from 'rss-parser'

const parser = new Parser()

export async function POST(request: NextRequest) {
  try {
    const { clientId } = await request.json()

    if (!clientId) {
      return NextResponse.json({ error: 'clientId required' }, { status: 400 })
    }

    const supabase = getServiceSupabase()

    // Get client details
    const { data: client } = await supabase
      .from('nps_clients')
      .select('id, client_name, country')
      .eq('id', clientId)
      .single()

    if (!client) {
      return NextResponse.json({ error: 'Client not found' }, { status: 404 })
    }

    // Get aliases
    const { data: aliases } = await supabase
      .from('client_name_aliases')
      .select('alias')
      .eq('client_id', clientId)
      .eq('is_active', true)

    const aliasList = aliases?.map(a => a.alias) || []

    // Fetch news from Google RSS
    const region = { hl: 'en-AU', gl: 'AU', ceid: 'AU:en' } // Default to AU
    const query = `"${client.client_name}" healthcare OR hospital`
    const url = `https://news.google.com/rss/search?q=${encodeURIComponent(query)}&hl=${region.hl}&gl=${region.gl}&ceid=${region.ceid}`

    const feed = await parser.parseURL(url)
    const articles = feed.items.slice(0, 5)

    let addedCount = 0

    for (const article of articles) {
      // AI verification
      const { text } = await callMatchaAI(
        [{
          role: 'user',
          content: `Does this news article specifically mention "${client.client_name}" (also known as: ${aliasList.join(', ')})?

Title: ${article.title}
Summary: ${article.contentSnippet || ''}

Reply ONLY in JSON format: {"isMatch": true/false, "confidence": 0-100}`
        }],
        { model: 'claude-sonnet-4-5', maxTokens: 100, temperature: 0 }
      )

      try {
        const result = JSON.parse(text.trim())
        if (result.isMatch && result.confidence >= 70) {
          await supabase.from('client_news').upsert({
            client_id: clientId,
            title: article.title || '',
            summary: (article.contentSnippet || '').slice(0, 500),
            source: 'Google News',
            source_url: article.link || '',
            published_date: article.pubDate ? new Date(article.pubDate).toISOString().split('T')[0] : null,
            matched_alias: client.client_name,
            confidence_score: result.confidence,
            is_verified: true,
            is_active: true,
            fetched_at: new Date().toISOString(),
          }, { onConflict: 'client_id,title' })
          addedCount++
        }
      } catch {
        // Skip articles with parse errors
      }
    }

    return NextResponse.json({
      success: true,
      clientName: client.client_name,
      articlesChecked: articles.length,
      articlesAdded: addedCount,
    })
  } catch (error) {
    console.error('[Client News Refresh] Error:', error)
    return NextResponse.json(
      { error: error instanceof Error ? error.message : 'Refresh failed' },
      { status: 500 }
    )
  }
}
```

**Step 2: Build and verify**

```bash
npm run build
```

**Step 3: Commit**

```bash
git add src/app/api/sales-hub/client-news/refresh/route.ts
git commit -m "feat(api): add on-demand client news refresh endpoint"
```

---

## Task 6: Update RecommendationsTab UI

**Files:**
- Modify: `src/app/(dashboard)/sales-hub/components/RecommendationsTab.tsx`

**Changes:**
1. Import useClientNews hook
2. Add newsCount to client context fetching
3. Add news badge to client selection cards
4. Add Client News section above Industry News
5. Add refresh button for client news

**Step 1: Add imports and hook usage**

Add to imports:
```typescript
import { useClientNews } from '@/hooks/useClientNews'
```

Add hook in component:
```typescript
const { news: clientSpecificNews, isLoading: clientNewsLoading, refresh: refreshClientNews } = useClientNews(selectedClient?.id ?? null)
```

**Step 2: Add news badge to client cards**

In the client selection grid, add badge next to health badge.

**Step 3: Add Client News section**

Add new section between recommendations and industry news.

**Step 4: Build and verify**

```bash
npm run build
```

**Step 5: Commit**

```bash
git add src/app/(dashboard)/sales-hub/components/RecommendationsTab.tsx
git commit -m "feat(ui): add client news badge and section to RecommendationsTab"
```

---

## Task 7: Update useClientContext for News Counts

**Files:**
- Modify: `src/hooks/useClientContext.ts`

**Changes:**
- Add newsCount field to ClientContext type
- Fetch news counts in useEffect
- Include in returned client objects

**Step 1: Update type and fetch logic**

**Step 2: Build and verify**

```bash
npm run build
```

**Step 3: Commit**

```bash
git add src/hooks/useClientContext.ts
git commit -m "feat(hooks): add newsCount to client context"
```

---

## Task 8: Configure Netlify Cron

**Files:**
- Modify: `netlify.toml`

**Step 1: Add cron schedule**

```toml
[functions."cron-client-news-sync"]
  schedule = "0 6 * * *"
```

**Step 2: Commit**

```bash
git add netlify.toml
git commit -m "chore(netlify): add daily client news sync cron schedule"
```

---

## Verification Checklist

- [ ] Database tables created (`client_news`, `client_name_aliases`)
- [ ] Aliases seeded for existing clients
- [ ] useClientNews hook fetches correctly
- [ ] Cron endpoint syncs news from Google RSS
- [ ] ChaSen AI verification filters false positives
- [ ] On-demand refresh works from UI
- [ ] News badge shows on client cards
- [ ] Client News section displays above Industry News
- [ ] Build passes with zero TypeScript errors
- [ ] Netlify deploy succeeds
