# Unified Data Integration Design

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a unified data layer ensuring all tables are API-accessible, ChaSen AI has full context, and client names are consistent across the system.

**Architecture:** Modular context functions for ChaSen, canonical client name resolution, and targeted API routes for previously unexposed tables.

**Tech Stack:** Supabase (PostgreSQL), Next.js API routes, TypeScript

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        DATA LAYER                                │
├─────────────────────────────────────────────────────────────────┤
│  Supabase Tables (40+)                                          │
│  ├── Core: clients, actions, meetings, nps_responses            │
│  ├── Goals: company_goals, team_goals, portfolio_initiatives    │
│  ├── Phase 8: communication_drafts, scheduled_touchpoints       │
│  ├── Phase 9: digital_twins, deal_sandboxes, sentiment_*        │
│  └── System: chasen_*, notifications, audit_logs                │
├─────────────────────────────────────────────────────────────────┤
│                   DATA QUALITY LAYER                             │
│  ├── client_name_aliases (existing) - fuzzy matching            │
│  ├── client_canonical_lookup VIEW - single source of truth      │
│  └── data_reconciliation_log - track mismatches                 │
├─────────────────────────────────────────────────────────────────┤
│                      API LAYER                                   │
│  ├── Existing routes (~150 endpoints)                           │
│  └── New routes for goals/templates, audit, sentiment, etc.     │
├─────────────────────────────────────────────────────────────────┤
│                   CHASEN CONTEXT LAYER                           │
│  ├── getLiveDashboardContext() - existing (18 tables)           │
│  ├── getGoalsContext() - goals, check-ins, audit                │
│  ├── getSentimentContext() - sentiment snapshots, alerts        │
│  ├── getAutomationContext() - autopilot, recognition            │
│  └── getFullContext() - orchestrates all domain contexts        │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Data Quality Foundation

### Task 1.1: Create client_canonical_lookup VIEW

**Files:**
- Create: `supabase/migrations/20260207_data_quality_foundation.sql`

**SQL:**
```sql
-- Canonical client lookup VIEW (always fresh from source tables)
CREATE OR REPLACE VIEW client_canonical_lookup AS
SELECT
  c.id as client_id,
  c.canonical_name,
  c.display_name,
  COALESCE(a.alias, c.canonical_name) as lookup_name
FROM clients c
LEFT JOIN client_name_aliases a ON c.canonical_name = a.canonical_name
WHERE c.is_active = true;
```

### Task 1.2: Create resolve_client_name() function

**SQL (same migration file):**
```sql
-- Enable pg_trgm for similarity matching
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Function for fuzzy client matching
CREATE OR REPLACE FUNCTION resolve_client_name(input_name TEXT)
RETURNS TABLE(client_id UUID, canonical_name TEXT, confidence FLOAT) AS $$
BEGIN
  RETURN QUERY
  SELECT
    cl.client_id,
    cl.canonical_name,
    CASE
      WHEN LOWER(cl.lookup_name) = LOWER(input_name) THEN 1.0
      WHEN LOWER(cl.canonical_name) ILIKE '%' || LOWER(input_name) || '%' THEN 0.9
      WHEN LOWER(input_name) ILIKE '%' || LOWER(cl.canonical_name) || '%' THEN 0.8
      ELSE similarity(LOWER(cl.lookup_name), LOWER(input_name))::FLOAT
    END as confidence
  FROM client_canonical_lookup cl
  WHERE
    LOWER(cl.lookup_name) = LOWER(input_name)
    OR LOWER(cl.canonical_name) ILIKE '%' || LOWER(input_name) || '%'
    OR similarity(LOWER(cl.lookup_name), LOWER(input_name)) > 0.4
  ORDER BY confidence DESC
  LIMIT 5;
END;
$$ LANGUAGE plpgsql;
```

### Task 1.3: Create data_reconciliation_log table

**SQL (same migration file):**
```sql
CREATE TABLE IF NOT EXISTS data_reconciliation_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_table TEXT NOT NULL,
  source_column TEXT NOT NULL,
  original_value TEXT NOT NULL,
  resolved_client_id UUID,
  resolved_name TEXT,
  confidence FLOAT,
  status TEXT DEFAULT 'pending', -- pending, confirmed, rejected
  created_at TIMESTAMPTZ DEFAULT now(),
  reviewed_at TIMESTAMPTZ,
  reviewed_by TEXT,
  UNIQUE(source_table, source_column, original_value)
);

CREATE INDEX idx_reconciliation_status ON data_reconciliation_log(status);
ALTER TABLE data_reconciliation_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow anon all on data_reconciliation_log" ON data_reconciliation_log
  FOR ALL TO anon USING (true) WITH CHECK (true);
```

### Task 1.4: Create scan_client_name_mismatches() RPC

**SQL (same migration file):**
```sql
CREATE OR REPLACE FUNCTION scan_client_name_mismatches()
RETURNS TABLE(
  source_table TEXT,
  source_column TEXT,
  original_value TEXT,
  resolved_client_id UUID,
  resolved_name TEXT,
  confidence FLOAT
) AS $$
BEGIN
  RETURN QUERY
  WITH all_client_names AS (
    SELECT 'nps_responses' as src_table, 'client_name' as src_col, client_name as name FROM nps_responses WHERE client_name IS NOT NULL
    UNION
    SELECT 'unified_meetings', 'client_name', client_name FROM unified_meetings WHERE client_name IS NOT NULL
    UNION
    SELECT 'actions', 'client', client FROM actions WHERE client IS NOT NULL
    UNION
    SELECT 'aging_accounts', 'client_name', client_name FROM aging_accounts WHERE client_name IS NOT NULL
  ),
  unmatched AS (
    SELECT DISTINCT an.src_table, an.src_col, an.name
    FROM all_client_names an
    WHERE NOT EXISTS (
      SELECT 1 FROM clients c WHERE LOWER(c.canonical_name) = LOWER(an.name)
    )
    AND NOT EXISTS (
      SELECT 1 FROM client_name_aliases a WHERE LOWER(a.alias) = LOWER(an.name)
    )
  )
  SELECT
    u.src_table,
    u.src_col,
    u.name,
    r.client_id,
    r.canonical_name,
    r.confidence
  FROM unmatched u
  LEFT JOIN LATERAL resolve_client_name(u.name) r ON true
  WHERE r.confidence IS NULL OR r.confidence < 0.95;
END;
$$ LANGUAGE plpgsql;
```

### Task 1.5: Populate client_name_aliases

**One-time script to run after migration:**
```sql
-- Add missing aliases from existing data
INSERT INTO client_name_aliases (alias, canonical_name)
SELECT DISTINCT
  an.name as alias,
  c.canonical_name
FROM (
  SELECT DISTINCT client_name as name FROM nps_responses WHERE client_name IS NOT NULL
  UNION
  SELECT DISTINCT client_name FROM unified_meetings WHERE client_name IS NOT NULL
  UNION
  SELECT DISTINCT client FROM actions WHERE client IS NOT NULL
) an
CROSS JOIN LATERAL (
  SELECT canonical_name
  FROM clients
  WHERE canonical_name ILIKE '%' || REGEXP_REPLACE(an.name, '^(CONFIRMED,|Re,|FW:|RE:)\s*', '', 'gi') || '%'
  LIMIT 1
) c
WHERE c.canonical_name IS NOT NULL
  AND LOWER(an.name) != LOWER(c.canonical_name)
  AND NOT EXISTS (SELECT 1 FROM client_name_aliases WHERE alias = an.name)
ON CONFLICT (alias) DO NOTHING;
```

### Task 1.6: Create client-resolver.ts utility

**Files:**
- Create: `src/lib/client-resolver.ts`

```typescript
import { SupabaseClient } from '@supabase/supabase-js'

export interface ResolvedClient {
  clientId: string
  canonicalName: string
  confidence: number
}

export async function resolveClientName(
  supabase: SupabaseClient,
  inputName: string
): Promise<ResolvedClient | null> {
  const { data, error } = await supabase
    .rpc('resolve_client_name', { input_name: inputName })
    .limit(1)
    .maybeSingle()

  if (error || !data) return null

  return {
    clientId: data.client_id,
    canonicalName: data.canonical_name,
    confidence: data.confidence
  }
}

export async function resolveClientNames(
  supabase: SupabaseClient,
  inputNames: string[]
): Promise<Map<string, ResolvedClient>> {
  const results = new Map<string, ResolvedClient>()

  // Batch resolve - could be optimized with a single RPC call
  await Promise.all(
    inputNames.map(async (name) => {
      const resolved = await resolveClientName(supabase, name)
      if (resolved) {
        results.set(name, resolved)
      }
    })
  )

  return results
}
```

---

## Phase 2: ChaSen Context Expansion

### Task 2.1-2.2: Directory structure and extract dashboard context

**Files:**
- Create: `src/lib/chasen/context/dashboard-context.ts` (extract from existing)
- Create: `src/lib/chasen/context/index.ts`

### Task 2.3: Create goals-context.ts

**Files:**
- Create: `src/lib/chasen/context/goals-context.ts`

```typescript
import { SupabaseClient } from '@supabase/supabase-js'

export async function getGoalsContext(supabase: SupabaseClient) {
  const [
    companyGoals,
    teamGoals,
    initiatives,
    recentCheckIns,
    pendingApprovals,
    recentChanges
  ] = await Promise.all([
    supabase
      .from('company_goals')
      .select('id, title, status, progress_percentage, target_date, owner_name')
      .in('status', ['active', 'at_risk'])
      .order('target_date', { ascending: true })
      .limit(10),

    supabase
      .from('team_goals')
      .select('id, title, goal_status, progress_percentage, client_name, owner_name')
      .in('goal_status', ['active', 'at_risk', 'blocked'])
      .order('updated_at', { ascending: false })
      .limit(15),

    supabase
      .from('portfolio_initiatives')
      .select('id, name, client_name, goal_status, progress_percentage, category')
      .eq('year', new Date().getFullYear())
      .in('goal_status', ['active', 'at_risk'])
      .limit(20),

    supabase
      .from('goal_check_ins')
      .select('goal_id, progress_percentage, notes, created_at, goal_type')
      .gte('created_at', new Date(Date.now() - 14 * 24 * 60 * 60 * 1000).toISOString())
      .order('created_at', { ascending: false })
      .limit(25),

    supabase
      .from('goal_approvals')
      .select('goal_id, goal_type, requested_by, status, created_at')
      .eq('status', 'pending')
      .limit(10),

    supabase
      .from('goal_audit_log')
      .select('goal_id, field_changed, old_value, new_value, changed_by, changed_at')
      .gte('changed_at', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString())
      .order('changed_at', { ascending: false })
      .limit(20)
  ])

  return {
    goals: {
      company: companyGoals.data || [],
      team: teamGoals.data || [],
      initiatives: initiatives.data || [],
      summary: {
        total_active: (companyGoals.data?.length || 0) + (teamGoals.data?.length || 0),
        at_risk: [...(companyGoals.data || []), ...(teamGoals.data || [])]
          .filter(g => g.status === 'at_risk' || g.goal_status === 'at_risk').length,
        pending_approvals: pendingApprovals.data?.length || 0
      }
    },
    check_ins: {
      recent: recentCheckIns.data || [],
      goals_with_updates: [...new Set(recentCheckIns.data?.map(c => c.goal_id) || [])]
    },
    approvals: pendingApprovals.data || [],
    audit_trail: recentChanges.data || []
  }
}
```

### Task 2.4: Create sentiment-context.ts

**Files:**
- Create: `src/lib/chasen/context/sentiment-context.ts`

```typescript
import { SupabaseClient } from '@supabase/supabase-js'

export async function getSentimentContext(supabase: SupabaseClient) {
  const [sentimentSnapshots, sentimentAlerts, recentAnalysis] = await Promise.all([
    supabase
      .from('client_sentiment_snapshots')
      .select('client_id, client_name, sentiment_score, trend_direction, snapshot_date')
      .order('snapshot_date', { ascending: false })
      .limit(50),

    supabase
      .from('sentiment_alerts')
      .select('id, client_name, alert_type, severity, sentiment_score, created_at')
      .eq('status', 'pending')
      .order('severity', { ascending: false })
      .limit(15),

    supabase
      .from('nps_topic_classifications')
      .select('response_id, topic_name, sentiment, confidence_score')
      .gte('confidence_score', 0.7)
      .order('classified_at', { ascending: false })
      .limit(30)
  ])

  // Dedupe to latest per client
  const latestByClient = new Map()
  sentimentSnapshots.data?.forEach(s => {
    if (!latestByClient.has(s.client_name)) {
      latestByClient.set(s.client_name, s)
    }
  })

  const clientSentiments = Array.from(latestByClient.values())

  return {
    sentiment: {
      by_client: clientSentiments,
      alerts: sentimentAlerts.data || [],
      summary: {
        positive: clientSentiments.filter(s => s.sentiment_score > 0.3).length,
        neutral: clientSentiments.filter(s => s.sentiment_score >= -0.3 && s.sentiment_score <= 0.3).length,
        negative: clientSentiments.filter(s => s.sentiment_score < -0.3).length,
        alerts_pending: sentimentAlerts.data?.length || 0
      }
    },
    topic_analysis: recentAnalysis.data || []
  }
}
```

### Task 2.5: Create automation-context.ts

**Files:**
- Create: `src/lib/chasen/context/automation-context.ts`

```typescript
import { SupabaseClient } from '@supabase/supabase-js'

function groupBy<T>(arr: T[], key: keyof T): Record<string, T[]> {
  return arr.reduce((acc, item) => {
    const k = String(item[key])
    if (!acc[k]) acc[k] = []
    acc[k].push(item)
    return acc
  }, {} as Record<string, T[]>)
}

export async function getAutomationContext(supabase: SupabaseClient) {
  const [autopilotRules, pendingTouchpoints, recognitionOccasions, communicationDrafts] = await Promise.all([
    supabase
      .from('relationship_autopilot_rules')
      .select('id, name, tier_ids, touchpoint_type, enabled')
      .eq('enabled', true)
      .limit(20),

    supabase
      .from('scheduled_touchpoints')
      .select('id, client_name, cse_name, touchpoint_type, suggested_date, status')
      .eq('status', 'pending')
      .order('suggested_date', { ascending: true })
      .limit(25),

    supabase
      .from('recognition_occasions')
      .select('id, client_name, occasion_type, occasion_date, significance_score, status')
      .eq('status', 'pending')
      .gte('occasion_date', new Date().toISOString().split('T')[0])
      .order('occasion_date', { ascending: true })
      .limit(15),

    supabase
      .from('communication_drafts')
      .select('id, client_name, draft_type, subject, status, created_at')
      .eq('status', 'draft')
      .order('created_at', { ascending: false })
      .limit(10)
  ])

  return {
    autopilot: {
      rules_active: autopilotRules.data?.length || 0,
      pending_touchpoints: pendingTouchpoints.data || [],
      touchpoints_by_type: groupBy(pendingTouchpoints.data || [], 'touchpoint_type')
    },
    recognition: {
      upcoming: recognitionOccasions.data || [],
      by_type: groupBy(recognitionOccasions.data || [], 'occasion_type')
    },
    drafts: {
      pending: communicationDrafts.data || [],
      count: communicationDrafts.data?.length || 0
    }
  }
}
```

### Task 2.6: Create full-context.ts orchestrator

**Files:**
- Create: `src/lib/chasen/context/full-context.ts`

```typescript
import { SupabaseClient } from '@supabase/supabase-js'
import { getGoalsContext } from './goals-context'
import { getSentimentContext } from './sentiment-context'
import { getAutomationContext } from './automation-context'

export type ContextDomain = 'dashboard' | 'goals' | 'sentiment' | 'automation' | 'all'

export async function getFullContext(
  supabase: SupabaseClient,
  domains: ContextDomain[] = ['all'],
  existingDashboardContext?: Record<string, unknown>
) {
  const includeAll = domains.includes('all')

  const [goals, sentiment, automation] = await Promise.all([
    (includeAll || domains.includes('goals'))
      ? getGoalsContext(supabase) : null,
    (includeAll || domains.includes('sentiment'))
      ? getSentimentContext(supabase) : null,
    (includeAll || domains.includes('automation'))
      ? getAutomationContext(supabase) : null,
  ])

  return {
    ...(existingDashboardContext || {}),
    ...(goals || {}),
    ...(sentiment || {}),
    ...(automation || {}),
    _meta: {
      domains_loaded: domains,
      timestamp: new Date().toISOString()
    }
  }
}
```

### Task 2.7: Create detect-context-domains.ts

**Files:**
- Create: `src/lib/chasen/context/detect-context-domains.ts`

```typescript
import { ContextDomain } from './full-context'

const DOMAIN_KEYWORDS: Record<ContextDomain, string[]> = {
  dashboard: ['dashboard', 'overview', 'summary', 'portfolio', 'health', 'nps', 'meeting'],
  goals: ['goal', 'initiative', 'objective', 'okr', 'target', 'progress', 'check-in', 'approval'],
  sentiment: ['sentiment', 'feeling', 'mood', 'satisfaction', 'happy', 'unhappy', 'frustrated', 'emotion'],
  automation: ['autopilot', 'touchpoint', 'recognition', 'gift', 'draft', 'email', 'schedule', 'nurture'],
  all: []
}

export function detectContextDomains(userMessage: string): ContextDomain[] {
  const messageLower = userMessage.toLowerCase()
  const detectedDomains: ContextDomain[] = []

  // Always include dashboard for basic context
  detectedDomains.push('dashboard')

  // Check for domain-specific keywords
  for (const [domain, keywords] of Object.entries(DOMAIN_KEYWORDS)) {
    if (domain === 'all' || domain === 'dashboard') continue

    if (keywords.some(kw => messageLower.includes(kw))) {
      detectedDomains.push(domain as ContextDomain)
    }
  }

  // If asking about a specific client, include all domains for comprehensive view
  if (messageLower.includes('client') || messageLower.match(/\b(health|barwon|epworth|sa health|wa health)\b/i)) {
    return ['all']
  }

  return detectedDomains.length > 0 ? detectedDomains : ['dashboard']
}
```

### Task 2.8: Update ChaSen stream route

**Files:**
- Modify: `src/app/api/chasen/stream/route.ts`

Add import and replace context loading:
```typescript
import { getFullContext } from '@/lib/chasen/context/full-context'
import { detectContextDomains } from '@/lib/chasen/context/detect-context-domains'

// In the POST handler, after getting userMessage:
const domains = detectContextDomains(userMessage)
const dashboardContext = await getLiveDashboardContext(supabase)
const fullContext = await getFullContext(supabase, domains, dashboardContext)
```

### Task 2.9: Create index.ts barrel export

**Files:**
- Create: `src/lib/chasen/context/index.ts`

```typescript
export { getGoalsContext } from './goals-context'
export { getSentimentContext } from './sentiment-context'
export { getAutomationContext } from './automation-context'
export { getFullContext, type ContextDomain } from './full-context'
export { detectContextDomains } from './detect-context-domains'
```

---

## Phase 3: API Layer Expansion

### Task 3.1: Create /api/goals/templates/route.ts

**Files:**
- Create: `src/app/api/goals/templates/route.ts`

### Task 3.2: Create /api/goals/[id]/audit/route.ts

**Files:**
- Create: `src/app/api/goals/[id]/audit/route.ts`

### Task 3.3: Create /api/sentiment/client/[clientId]/route.ts

**Files:**
- Create: `src/app/api/sentiment/client/[clientId]/route.ts`

### Task 3.4: Create /api/sentiment/alerts/route.ts

**Files:**
- Create: `src/app/api/sentiment/alerts/route.ts`

### Task 3.5: Create /api/sentiment/alerts/[id]/route.ts

**Files:**
- Create: `src/app/api/sentiment/alerts/[id]/route.ts`

### Task 3.6: Create /api/admin/data-quality/reconciliation/route.ts

**Files:**
- Create: `src/app/api/admin/data-quality/reconciliation/route.ts`

### Task 3.7: Create /api/chasen/context/[domain]/route.ts

**Files:**
- Create: `src/app/api/chasen/context/[domain]/route.ts`

---

## Phase 4: Integration & Verification

### Task 4.1-4.6: Testing and verification

Manual testing of:
- Data reconciliation scan
- Client name alias population
- ChaSen context queries (goals, sentiment, automation)
- New API routes

### Task 4.7: Update CLAUDE.md

Add documentation for:
- New context domains
- New API routes
- Client resolver utility
- Data quality tooling

---

## Files Summary

### New Files (17)

| File | Purpose |
|------|---------|
| `supabase/migrations/20260207_data_quality_foundation.sql` | DB migration |
| `src/lib/client-resolver.ts` | Client name resolution utility |
| `src/lib/chasen/context/index.ts` | Barrel export |
| `src/lib/chasen/context/goals-context.ts` | Goals domain context |
| `src/lib/chasen/context/sentiment-context.ts` | Sentiment domain context |
| `src/lib/chasen/context/automation-context.ts` | Automation domain context |
| `src/lib/chasen/context/full-context.ts` | Context orchestrator |
| `src/lib/chasen/context/detect-context-domains.ts` | Intent detection |
| `src/app/api/goals/templates/route.ts` | Goal templates API |
| `src/app/api/goals/[id]/audit/route.ts` | Goal audit API |
| `src/app/api/sentiment/client/[clientId]/route.ts` | Client sentiment API |
| `src/app/api/sentiment/alerts/route.ts` | Sentiment alerts list |
| `src/app/api/sentiment/alerts/[id]/route.ts` | Sentiment alert detail |
| `src/app/api/admin/data-quality/reconciliation/route.ts` | Data quality API |
| `src/app/api/chasen/context/[domain]/route.ts` | Context domain API |

### Modified Files (2)

| File | Change |
|------|--------|
| `src/app/api/chasen/stream/route.ts` | Import and use modular contexts |
| `CLAUDE.md` | Document new features |
