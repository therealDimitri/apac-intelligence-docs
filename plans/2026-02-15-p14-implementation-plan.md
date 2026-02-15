# P14 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Deliver 5 sequential workstreams — BURC financial tables, performance CI pipeline, ChaSen AI overhaul, E2E test expansion, and mobile UX audit/fixes — bringing the platform to production maturity.

**Architecture:** Sequential phases where each builds on the previous. BURC tables feed ChaSen context. Performance CI establishes baselines before ChaSen adds Transformers.js bundle weight. E2E tests validate all new features. Mobile audit runs last to catch regressions from earlier work.

**Tech Stack:** Supabase (PostgreSQL), Next.js 16, Playwright, Lighthouse CI, GitHub Actions, Transformers.js (ONNX), xlsx

---

## Phase 1: BURC Missing Tables

### Task 1.1: Create BURC Monthly Tables Migration

**Files:**
- Create: `supabase/migrations/20260215_burc_monthly_detail_tables.sql`

**Step 1: Write the migration SQL**

Create 4 tables mirroring `burc_ebita_monthly` structure with `source_row` for debugging:

```sql
-- Create burc_opex_monthly
CREATE TABLE IF NOT EXISTS burc_opex_monthly (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  fiscal_year TEXT NOT NULL,
  month TEXT NOT NULL,
  month_num INTEGER NOT NULL,
  category TEXT NOT NULL,
  actual NUMERIC DEFAULT 0,
  plan NUMERIC DEFAULT 0,
  variance NUMERIC GENERATED ALWAYS AS (actual - plan) STORED,
  source_row INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(fiscal_year, month_num, category)
);

-- Create burc_cogs_monthly
CREATE TABLE IF NOT EXISTS burc_cogs_monthly (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  fiscal_year TEXT NOT NULL,
  month TEXT NOT NULL,
  month_num INTEGER NOT NULL,
  category TEXT NOT NULL,
  actual NUMERIC DEFAULT 0,
  plan NUMERIC DEFAULT 0,
  variance NUMERIC GENERATED ALWAYS AS (actual - plan) STORED,
  source_row INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(fiscal_year, month_num, category)
);

-- Create burc_net_revenue_monthly
CREATE TABLE IF NOT EXISTS burc_net_revenue_monthly (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  fiscal_year TEXT NOT NULL,
  month TEXT NOT NULL,
  month_num INTEGER NOT NULL,
  category TEXT NOT NULL,
  actual NUMERIC DEFAULT 0,
  plan NUMERIC DEFAULT 0,
  variance NUMERIC GENERATED ALWAYS AS (actual - plan) STORED,
  source_row INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(fiscal_year, month_num, category)
);

-- Create burc_gross_revenue_monthly
CREATE TABLE IF NOT EXISTS burc_gross_revenue_monthly (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  fiscal_year TEXT NOT NULL,
  month TEXT NOT NULL,
  month_num INTEGER NOT NULL,
  category TEXT NOT NULL,
  actual NUMERIC DEFAULT 0,
  plan NUMERIC DEFAULT 0,
  variance NUMERIC GENERATED ALWAYS AS (actual - plan) STORED,
  source_row INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(fiscal_year, month_num, category)
);

-- RLS policies (anon read, service role write)
ALTER TABLE burc_opex_monthly ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_cogs_monthly ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_net_revenue_monthly ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_gross_revenue_monthly ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow anon read burc_opex_monthly" ON burc_opex_monthly FOR SELECT USING (true);
CREATE POLICY "Allow anon read burc_cogs_monthly" ON burc_cogs_monthly FOR SELECT USING (true);
CREATE POLICY "Allow anon read burc_net_revenue_monthly" ON burc_net_revenue_monthly FOR SELECT USING (true);
CREATE POLICY "Allow anon read burc_gross_revenue_monthly" ON burc_gross_revenue_monthly FOR SELECT USING (true);

-- Updated_at triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_burc_opex_monthly_updated_at BEFORE UPDATE ON burc_opex_monthly FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_burc_cogs_monthly_updated_at BEFORE UPDATE ON burc_cogs_monthly FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_burc_net_revenue_monthly_updated_at BEFORE UPDATE ON burc_net_revenue_monthly FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_burc_gross_revenue_monthly_updated_at BEFORE UPDATE ON burc_gross_revenue_monthly FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

**Step 2: Run migration against Supabase**

Use `migration-workflow` skill. Run via Supabase MCP `execute_sql` tool or direct pg connection.

**Step 3: Regenerate database types**

Run: `cd ~/GitHub/apac-intelligence-v2 && npm run db:refresh`

Expected: `src/types/database.generated.ts` updated with 4 new table types. `docs/database-schema.md` updated.

**Step 4: Commit**

```bash
cd ~/GitHub/apac-intelligence-v2
git add supabase/migrations/20260215_burc_monthly_detail_tables.sql src/types/database.generated.ts
git commit -m "feat: create 4 BURC monthly detail tables (opex, cogs, net/gross revenue)"
```

---

### Task 1.2: Add BURC Monthly Sync Parsers

**Files:**
- Modify: `scripts/sync-burc-all-worksheets.mjs`
- Read: `docs/knowledge-base/02-data-pipeline/burc-sync.md` (row map reference)

**Step 1: Read the BURC row map**

Reference rows from `burc-sync.md`:
- OPEX: rows 71 (PS), 76 (Maint), 83 (S&M), 89 (R&D), 96 (G&A), 99 (Total)
- COGS: rows 38, 40, 44, 47, 56 (Total)
- Net Revenue: rows 58 (License), 59 (PS), 60 (Maint), 61 (HW), 66 (Total)
- Gross Revenue: rows 10 (License), 12 (PS), 18 (Maint), 27 (HW), 36 (Total)

**Step 2: Add parser functions to sync script**

Add 4 functions following the existing pattern in `sync-burc-all-worksheets.mjs`. Each function:
1. Opens the APAC BURC worksheet
2. Reads column A to validate row labels (detect Finance restructures)
3. Parses monthly columns (Jan-Dec) for actual and plan values
4. Upserts into the target table using `ON CONFLICT (fiscal_year, month_num, category) DO UPDATE`

```javascript
// Pattern for each parser:
async function syncOpexMonthly(workbook, fiscalYear) {
  const sheet = workbook.Sheets['APAC BURC']
  if (!sheet) { console.warn('APAC BURC sheet not found'); return { synced: 0 } }

  const ROW_MAP = {
    'PS': 71, 'Maintenance': 76, 'Sales & Marketing': 83,
    'R&D': 89, 'G&A': 96, 'Total OPEX': 99
  }

  // Validate row labels (column A) before parsing
  for (const [label, row] of Object.entries(ROW_MAP)) {
    const cellRef = `A${row}`
    const cell = sheet[cellRef]
    if (!cell || !cell.v?.toString().includes(label.split(' ')[0])) {
      console.warn(`Row shift detected: expected "${label}" at row ${row}, got "${cell?.v}"`)
    }
  }

  const MONTH_COLS = ['B','C','D','E','F','G','H','I','J','K','L','M']
  const MONTH_NAMES = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
  const records = []

  for (const [category, row] of Object.entries(ROW_MAP)) {
    for (let i = 0; i < 12; i++) {
      const actualCell = sheet[`${MONTH_COLS[i]}${row}`]
      // Plan row is typically row+1 or in a separate plan section — verify from Excel
      records.push({
        fiscal_year: fiscalYear,
        month: MONTH_NAMES[i],
        month_num: i + 1,
        category,
        actual: actualCell?.v ?? 0,
        plan: 0, // populate from plan rows
        source_row: row
      })
    }
  }

  const { error } = await supabase.from('burc_opex_monthly').upsert(records, {
    onConflict: 'fiscal_year,month_num,category'
  })
  if (error) console.error('OPEX sync error:', error)
  return { synced: records.length }
}
```

Repeat pattern for `syncCogsMonthly()`, `syncNetRevenueMonthly()`, `syncGrossRevenueMonthly()`.

**Step 3: Wire parsers into orchestrator**

Add calls to the 4 new parsers in the `syncAllWorksheets()` function, after the existing EBITA sync.

**Step 4: Test sync**

Run: `cd ~/GitHub/apac-intelligence-v2 && npm run burc:sync:comprehensive`

Expected: All 4 tables populated. Verify with Supabase MCP `execute_sql`:
```sql
SELECT COUNT(*) FROM burc_opex_monthly;
SELECT COUNT(*) FROM burc_cogs_monthly;
SELECT COUNT(*) FROM burc_net_revenue_monthly;
SELECT COUNT(*) FROM burc_gross_revenue_monthly;
```

**Step 5: Commit**

```bash
cd ~/GitHub/apac-intelligence-v2/scripts
git add sync-burc-all-worksheets.mjs
git commit -m "feat: add sync parsers for opex, cogs, net/gross revenue monthly tables"
cd ~/GitHub/apac-intelligence-v2
git add scripts
git commit -m "chore: update scripts submodule (BURC monthly sync parsers)"
```

---

### Task 1.3: Add ChaSen Formatter Entries

**Files:**
- Modify: `src/lib/chasen-dynamic-context.ts`

**Step 1: Add formatters for 4 new tables**

Find the `formatRowForContext()` function and add entries for each new table. Follow the existing pattern (emoji prefix, key fields):

```typescript
// Inside formatRowForContext() switch/if-else:
case 'burc_opex_monthly':
  return `📊 OPEX ${row.category}: ${row.month} ${row.fiscal_year} — Actual: $${(row.actual / 1000).toFixed(0)}K, Plan: $${(row.plan / 1000).toFixed(0)}K, Variance: $${(row.variance / 1000).toFixed(0)}K`

case 'burc_cogs_monthly':
  return `💰 COGS ${row.category}: ${row.month} ${row.fiscal_year} — Actual: $${(row.actual / 1000).toFixed(0)}K, Plan: $${(row.plan / 1000).toFixed(0)}K`

case 'burc_net_revenue_monthly':
  return `📈 Net Revenue ${row.category}: ${row.month} ${row.fiscal_year} — Actual: $${(row.actual / 1000).toFixed(0)}K, Plan: $${(row.plan / 1000).toFixed(0)}K`

case 'burc_gross_revenue_monthly':
  return `📈 Gross Revenue ${row.category}: ${row.month} ${row.fiscal_year} — Actual: $${(row.actual / 1000).toFixed(0)}K, Plan: $${(row.plan / 1000).toFixed(0)}K`
```

**Step 2: Add data source configs in Supabase**

Insert 4 rows into `chasen_data_sources` table via Supabase MCP:

```sql
INSERT INTO chasen_data_sources (table_name, display_name, description, category, is_enabled, priority, select_columns, order_by, limit_rows, section_emoji)
VALUES
  ('burc_opex_monthly', 'OPEX Monthly', 'Monthly OPEX by department', 'analytics', true, 50, ARRAY['fiscal_year','month','month_num','category','actual','plan','variance'], 'month_num', 100, '📊'),
  ('burc_cogs_monthly', 'COGS Monthly', 'Monthly COGS breakdown', 'analytics', true, 51, ARRAY['fiscal_year','month','month_num','category','actual','plan','variance'], 'month_num', 100, '💰'),
  ('burc_net_revenue_monthly', 'Net Revenue Monthly', 'Monthly net revenue by type', 'analytics', true, 52, ARRAY['fiscal_year','month','month_num','category','actual','plan','variance'], 'month_num', 100, '📈'),
  ('burc_gross_revenue_monthly', 'Gross Revenue Monthly', 'Monthly gross revenue by type', 'analytics', true, 53, ARRAY['fiscal_year','month','month_num','category','actual','plan','variance'], 'month_num', 100, '📈');
```

**Step 3: Commit**

```bash
cd ~/GitHub/apac-intelligence-v2
git add src/lib/chasen-dynamic-context.ts
git commit -m "feat: add ChaSen formatters for BURC opex/cogs/revenue monthly tables"
```

---

### Task 1.4: Update Knowledge Base and MEMORY.md

**Files:**
- Modify: `docs/knowledge-base/06-database/tables.md` — add 4 new table entries
- Modify: `docs/knowledge-base/02-data-pipeline/burc-sync.md` — add sync status for new tables

**Step 1: Update tables.md with new table entries**

**Step 2: Update burc-sync.md to mark tables as synced**

**Step 3: Remove "BURC sync missing tables" note from MEMORY.md**

**Step 4: Commit in docs submodule**

```bash
cd ~/GitHub/apac-intelligence-v2/docs
git add knowledge-base/06-database/tables.md knowledge-base/02-data-pipeline/burc-sync.md
git commit -m "docs: add 4 BURC monthly detail tables to schema and sync docs"
```

---

## Phase 2: Performance CI Pipeline

### Task 2.1: Wire Up Bundle Analyzer

**Files:**
- Modify: `next.config.ts`
- Modify: `package.json` (add `analyze` script)

**Step 1: Add bundle analyzer wrapper to next.config.ts**

```typescript
// At top of next.config.ts:
import bundleAnalyzer from '@next/bundle-analyzer'

const withBundleAnalyzer = bundleAnalyzer({
  enabled: process.env.ANALYZE === 'true',
})

// At bottom, wrap export:
export default withBundleAnalyzer(nextConfig)
```

**Step 2: Add npm script**

In `package.json` scripts:
```json
"analyze": "ANALYZE=true next build"
```

**Step 3: Test it works**

Run: `cd ~/GitHub/apac-intelligence-v2 && npm run analyze`

Expected: Build completes and opens bundle analysis HTML reports in browser.

**Step 4: Commit**

```bash
cd ~/GitHub/apac-intelligence-v2
git add next.config.ts package.json
git commit -m "feat: wire up @next/bundle-analyzer with ANALYZE=true toggle"
```

---

### Task 2.2: Add Lighthouse CI Configuration

**Files:**
- Create: `.lighthouserc.js`
- Modify: `package.json` (add `@lhci/cli` devDependency and scripts)

**Step 1: Install Lighthouse CI**

Run: `cd ~/GitHub/apac-intelligence-v2 && npm install --save-dev @lhci/cli`

**Step 2: Create Lighthouse config**

```javascript
// .lighthouserc.js
module.exports = {
  ci: {
    collect: {
      url: ['http://localhost:3001/'],
      startServerCommand: 'npm run start -- -p 3001',
      startServerReadyPattern: 'Ready in',
      numberOfRuns: 3,
      settings: {
        preset: 'desktop',
      },
    },
    assert: {
      assertions: {
        'categories:performance': ['warn', { minScore: 0.8 }],
        'categories:accessibility': ['error', { minScore: 0.95 }],
        'categories:best-practices': ['warn', { minScore: 0.9 }],
        'categories:seo': ['warn', { minScore: 0.8 }],
        'largest-contentful-paint': ['warn', { maxNumericValue: 2500 }],
        'cumulative-layout-shift': ['warn', { maxNumericValue: 0.1 }],
        'total-blocking-time': ['warn', { maxNumericValue: 300 }],
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
}
```

**Step 3: Add npm scripts**

```json
"lighthouse": "lhci autorun",
"lighthouse:collect": "lhci collect",
"lighthouse:assert": "lhci assert"
```

**Step 4: Test locally**

Run: `cd ~/GitHub/apac-intelligence-v2 && npm run build && npm run lighthouse`

Expected: Lighthouse runs 3 times against localhost:3001, outputs scores, uploads to temporary storage.

**Step 5: Commit**

```bash
cd ~/GitHub/apac-intelligence-v2
git add .lighthouserc.js package.json package-lock.json
git commit -m "feat: add Lighthouse CI config with performance budgets"
```

---

### Task 2.3: Add Performance GitHub Actions Workflow

**Files:**
- Create: `.github/workflows/perf.yml`

**Step 1: Create the workflow**

```yaml
name: Performance Audit

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lighthouse:
    name: Lighthouse CI
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build application
        run: npm run build
        env:
          SKIP_ENV_VALIDATION: 'true'
          NEXT_PUBLIC_SUPABASE_URL: https://placeholder.supabase.co
          NEXT_PUBLIC_SUPABASE_ANON_KEY: placeholder-anon-key

      - name: Run Lighthouse CI
        run: npx @lhci/cli autorun
        env:
          LHCI_GITHUB_APP_TOKEN: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}

  bundle-size:
    name: Bundle Size Check
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build and capture bundle stats
        run: |
          npm run build 2>&1 | tee build-output.txt
          # Extract route sizes from Next.js build output
          grep -E '(○|●|ƒ|λ)\s+/' build-output.txt > route-sizes.txt || true
          cat route-sizes.txt
        env:
          SKIP_ENV_VALIDATION: 'true'
          NEXT_PUBLIC_SUPABASE_URL: https://placeholder.supabase.co
          NEXT_PUBLIC_SUPABASE_ANON_KEY: placeholder-anon-key

      - name: Check bundle size
        run: |
          # Extract First Load JS from build output
          FIRST_LOAD=$(grep 'First Load JS' build-output.txt | head -1 | grep -oE '[0-9.]+ [kM]B' | head -1)
          echo "First Load JS: $FIRST_LOAD"
          # Fail if over 500kB (adjust threshold as needed)
          SIZE_KB=$(echo "$FIRST_LOAD" | awk '{if ($2 == "MB") print $1 * 1024; else print $1}')
          if (( $(echo "$SIZE_KB > 500" | bc -l) )); then
            echo "::error::First Load JS ($FIRST_LOAD) exceeds 500kB budget"
            exit 1
          fi
```

**Step 2: Run baseline audit on current prod**

Run Lighthouse locally, save results to `docs/plans/p14-perf-baseline.md`:
- Current Performance score
- Current LCP, CLS, TBT values
- First Load JS bundle size
- Top 5 largest routes by bundle size

**Step 3: Commit**

```bash
cd ~/GitHub/apac-intelligence-v2
git add .github/workflows/perf.yml
git commit -m "feat: add performance CI pipeline with Lighthouse and bundle size checks"
```

---

## Phase 3: ChaSen AI Full Overhaul

### Task 3.1: Land Stashed Transformers.js Work

**Files:**
- Apply stash: `stash@{0}` (4 files: .gitignore, next.config.ts, package.json, src/lib/topic-extraction.ts)
- Create: `src/lib/local-inference.ts`
- Create: `src/lib/local-inference-nps.ts`

**Step 1: Apply the stash**

Run: `cd ~/GitHub/apac-intelligence-v2 && git stash pop`

Resolve any conflicts with the modified files (6 unstaged + stash overlap).

**Step 2: Create local-inference.ts**

Entry point for local ML inference availability check:

```typescript
// src/lib/local-inference.ts
let _available: boolean | null = null

export async function isLocalInferenceAvailable(): Promise<boolean> {
  if (_available !== null) return _available
  try {
    // Check if ONNX runtime is available (server-side only)
    if (typeof window !== 'undefined') {
      _available = false
      return false
    }
    await import('@huggingface/transformers')
    _available = process.env.ENABLE_LOCAL_INFERENCE === 'true'
    return _available
  } catch {
    _available = false
    return false
  }
}
```

**Step 3: Create local-inference-nps.ts**

NPS classification using Transformers.js:

```typescript
// src/lib/local-inference-nps.ts
import { pipeline } from '@huggingface/transformers'

interface NPSClassification {
  topic: string
  sentiment: 'positive' | 'negative' | 'neutral'
  confidence: number
}

let classifier: Awaited<ReturnType<typeof pipeline>> | null = null

async function getClassifier() {
  if (!classifier) {
    classifier = await pipeline('zero-shot-classification', 'Xenova/mobilebert-uncased-mnli')
  }
  return classifier
}

const NPS_TOPICS = [
  'product quality', 'customer support', 'implementation',
  'training', 'pricing', 'communication', 'reliability',
  'feature requests', 'upgrade experience', 'account management'
]

export async function classifyNPSComment(comment: string): Promise<NPSClassification> {
  const clf = await getClassifier()
  const result = await clf(comment, NPS_TOPICS)
  return {
    topic: result.labels[0],
    sentiment: result.scores[0] > 0.6 ? 'positive' : result.scores[0] < 0.4 ? 'negative' : 'neutral',
    confidence: result.scores[0]
  }
}

export async function classifyNPSBatch(comments: string[]): Promise<NPSClassification[]> {
  const results: NPSClassification[] = []
  for (const comment of comments) {
    results.push(await classifyNPSComment(comment))
  }
  return results
}
```

**Step 4: Add ENABLE_LOCAL_INFERENCE to .env.local**

```
ENABLE_LOCAL_INFERENCE=true
```

**Step 5: Install @huggingface/transformers if not already present**

Run: `cd ~/GitHub/apac-intelligence-v2 && npm install @huggingface/transformers`

**Step 6: Test local inference**

Write a quick test script to validate accuracy. Run `classifyNPSBatch()` on 20 known NPS comments, compare to existing API classifications.

**Step 7: Commit**

```bash
cd ~/GitHub/apac-intelligence-v2
git add .gitignore next.config.ts package.json package-lock.json src/lib/local-inference.ts src/lib/local-inference-nps.ts src/lib/topic-extraction.ts
git commit -m "feat: add local Transformers.js inference for NPS classification"
```

---

### Task 3.2: Refactor Context Formatter Registry

**Files:**
- Modify: `src/lib/chasen-dynamic-context.ts`

**Step 1: Extract formatter map**

Replace the 600-line if/else `formatRowForContext()` with a `Map<string, FormatterFn>`:

```typescript
type FormatterFn = (row: Record<string, unknown>) => string

const FORMATTER_REGISTRY = new Map<string, FormatterFn>([
  ['support_sla_metrics', (row) =>
    `🎯 SLA: ${row.resolution_sla_percent}% | CSAT: ${row.satisfaction_score} | Backlog: ${row.backlog} (${row.period})`
  ],
  ['health_status_alerts', (row) =>
    `⚠️ ${row.client_name}: ${row.alert_type} — ${row.description}`
  ],
  ['aging_accounts', (row) =>
    `💳 ${row.client_name}: $${Number(row.total_outstanding).toLocaleString()} outstanding (${row.aging_bucket})`
  ],
  // ... migrate ALL existing formatters from if/else into this map
])

// Default formatter for tables without a custom one
const defaultFormatter: FormatterFn = (row) =>
  Object.entries(row).map(([k, v]) => `${k}: ${v}`).join(' | ')

export function formatRowForContext(tableName: string, row: Record<string, unknown>): string {
  const formatter = FORMATTER_REGISTRY.get(tableName) ?? defaultFormatter
  return formatter(row)
}
```

**Step 2: Verify no formatters are lost**

Grep for all table names currently in the if/else, ensure each has a Map entry.

**Step 3: Run existing ChaSen tests**

Run: `cd ~/GitHub/apac-intelligence-v2 && npm test -- --testPathPattern chasen`

**Step 4: Commit**

```bash
cd ~/GitHub/apac-intelligence-v2
git add src/lib/chasen-dynamic-context.ts
git commit -m "refactor: extract ChaSen context formatters into registry map"
```

---

### Task 3.3: Add Context Window Budgeting

**Files:**
- Modify: `src/lib/chasen-dynamic-context.ts`
- Migration: `supabase/migrations/20260215_chasen_context_budgeting.sql`

**Step 1: Add max_tokens column to chasen_data_sources**

```sql
ALTER TABLE chasen_data_sources ADD COLUMN IF NOT EXISTS max_tokens INTEGER DEFAULT 500;
```

**Step 2: Implement token budgeting in getDynamicDashboardContext()**

After fetching data for each source, estimate token count (rough: chars / 4) and truncate if over budget. Total budget: 8000 tokens across all sources.

```typescript
const TOTAL_TOKEN_BUDGET = 8000

export async function getDynamicDashboardContext(): Promise<string> {
  const configs = await getDataSourceConfigs()
  const sections: string[] = []
  let tokensUsed = 0

  for (const config of configs.sort((a, b) => a.priority - b.priority)) {
    if (tokensUsed >= TOTAL_TOKEN_BUDGET) break

    const data = await buildSourceContext(config)
    const estimatedTokens = Math.ceil(data.length / 4)
    const maxTokens = config.max_tokens ?? 500
    const budgetRemaining = TOTAL_TOKEN_BUDGET - tokensUsed

    if (estimatedTokens > Math.min(maxTokens, budgetRemaining)) {
      // Truncate to fit budget
      const maxChars = Math.min(maxTokens, budgetRemaining) * 4
      sections.push(data.slice(0, maxChars) + '\n... (truncated)')
      tokensUsed += Math.min(maxTokens, budgetRemaining)
    } else {
      sections.push(data)
      tokensUsed += estimatedTokens
    }
  }

  return sections.join('\n\n')
}
```

**Step 3: Run migration and commit**

```bash
cd ~/GitHub/apac-intelligence-v2
git add src/lib/chasen-dynamic-context.ts supabase/migrations/20260215_chasen_context_budgeting.sql
git commit -m "feat: add context window budgeting to ChaSen dynamic context"
```

---

### Task 3.4: Implement Tiered Timeout Fallback

**Files:**
- Modify: `src/app/api/chasen/stream/route.ts`

**Step 1: Replace blanket 2.5s timeout with priority-ranked fetch**

Find the parallel context loading section (where graph RAG + memory + dynamic context are fetched) and implement tiered fallback:

```typescript
// Priority: 1=graph RAG, 2=dynamic context, 3=memory
const CONTEXT_TIMEOUT = 4000 // 4s total budget

async function loadContextWithPriority(): Promise<{
  graphContext: string
  dynamicContext: string
  memoryContext: string
}> {
  const start = Date.now()
  const result = { graphContext: '', dynamicContext: '', memoryContext: '' }

  // Priority 1: Graph RAG (most valuable)
  try {
    result.graphContext = await Promise.race([
      fetchGraphContext(),
      new Promise<string>((_, reject) => setTimeout(() => reject(new Error('timeout')), 2000))
    ])
  } catch { /* continue without graph context */ }

  const elapsed = Date.now() - start
  const remaining = CONTEXT_TIMEOUT - elapsed
  if (remaining <= 0) return result

  // Priority 2+3: Dynamic context + memory in parallel with remaining budget
  try {
    const [dynamic, memory] = await Promise.race([
      Promise.all([fetchDynamicContext(), fetchMemoryContext()]),
      new Promise<[string, string]>((_, reject) =>
        setTimeout(() => reject(new Error('timeout')), remaining)
      )
    ])
    result.dynamicContext = dynamic
    result.memoryContext = memory
  } catch { /* continue with whatever we have */ }

  return result
}
```

**Step 2: Test with slow network simulation**

Verify ChaSen still responds even when context loading times out.

**Step 3: Commit**

```bash
cd ~/GitHub/apac-intelligence-v2
git add src/app/api/chasen/stream/route.ts
git commit -m "feat: add tiered timeout fallback for ChaSen context loading"
```

---

### Task 3.5: Modularise Tool System

**Files:**
- Modify: `src/lib/chasen-tools.ts` (extract definitions)
- Create: `src/lib/chasen-tool-registry.ts`
- Create: `src/lib/chasen-tool-executors/read-tools.ts`
- Create: `src/lib/chasen-tool-executors/write-tools.ts`
- Create: `src/lib/chasen-tool-executors/workflow-tools.ts`
- Create: `src/lib/chasen-tool-executors/goal-tools.ts`
- Create: `src/lib/chasen-tool-executors/index.ts`

**Step 1: Create the registry**

```typescript
// src/lib/chasen-tool-registry.ts
import { ChaSenToolDef, ToolExecutor } from './chasen-tools'

const toolDefinitions: ChaSenToolDef[] = []
const toolExecutors = new Map<string, ToolExecutor>()

export function registerTool(def: ChaSenToolDef, executor: ToolExecutor) {
  toolDefinitions.push(def)
  toolExecutors.set(def.name, executor)
}

export function getToolDefinitions(): ChaSenToolDef[] {
  return toolDefinitions
}

export function getToolExecutor(name: string): ToolExecutor | undefined {
  return toolExecutors.get(name)
}
```

**Step 2: Split executors into category files**

Move each tool's executor function from the monolithic `chasen-tools.ts` into the appropriate category file. Each file calls `registerTool()` on import.

**Step 3: Create index that imports all categories**

```typescript
// src/lib/chasen-tool-executors/index.ts
import './read-tools'
import './write-tools'
import './workflow-tools'
import './goal-tools'
```

**Step 4: Update chasen-tools.ts to re-export from registry**

```typescript
// src/lib/chasen-tools.ts — becomes a thin re-export
import './chasen-tool-executors' // triggers all registrations
export { getToolDefinitions as CHASEN_TOOLS, getToolExecutor } from './chasen-tool-registry'
export type { ChaSenToolDef, ToolExecutionResult } from './chasen-tool-registry'
```

**Step 5: Create tool execution audit table**

```sql
-- supabase/migrations/20260215_chasen_tool_audit.sql
CREATE TABLE IF NOT EXISTS chasen_tool_executions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tool_name TEXT NOT NULL,
  params JSONB DEFAULT '{}',
  result_summary TEXT,
  duration_ms INTEGER,
  user_id TEXT,
  success BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE chasen_tool_executions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow anon read chasen_tool_executions" ON chasen_tool_executions FOR SELECT USING (true);
```

**Step 6: Run all tests to verify nothing breaks**

Run: `cd ~/GitHub/apac-intelligence-v2 && npm test`

**Step 7: Commit**

```bash
cd ~/GitHub/apac-intelligence-v2
git add src/lib/chasen-tools.ts src/lib/chasen-tool-registry.ts src/lib/chasen-tool-executors/ supabase/migrations/20260215_chasen_tool_audit.sql
git commit -m "refactor: modularise ChaSen tool system into registry + category executors"
```

---

### Task 3.6: Move Prompts to Database

**Files:**
- Migration: `supabase/migrations/20260215_chasen_prompts_table.sql`
- Modify: `src/lib/chasen-prompts.ts`
- Create: `src/app/(dashboard)/settings/chasen/prompts/page.tsx`

**Step 1: Create chasen_prompts table**

```sql
CREATE TABLE IF NOT EXISTS chasen_prompts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  page TEXT NOT NULL,
  prompt_text TEXT NOT NULL,
  category TEXT DEFAULT 'general',
  relevance_score NUMERIC DEFAULT 1.0,
  click_count INTEGER DEFAULT 0,
  is_enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE chasen_prompts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow anon full access chasen_prompts" ON chasen_prompts FOR ALL USING (true);
```

**Step 2: Seed migration with existing hardcoded prompts**

Extract all 150+ prompts from `chasen-prompts.ts` into INSERT statements.

**Step 3: Update chasen-prompts.ts to fetch from DB**

Replace hardcoded prompt arrays with Supabase queries. Keep click-through boosting logic but compute from DB `click_count`.

**Step 4: Create admin UI page**

Simple DataTable at `/settings/chasen/prompts` showing all prompts with enable/disable toggle, edit text, click count display. Use existing DataTable pattern from other settings pages.

**Step 5: Commit**

```bash
cd ~/GitHub/apac-intelligence-v2
git add supabase/migrations/20260215_chasen_prompts_table.sql src/lib/chasen-prompts.ts src/app/\(dashboard\)/settings/chasen/prompts/
git commit -m "feat: move ChaSen prompts to database with admin UI"
```

---

### Task 3.7: Add Proactive Insights + Planning Integration + Model Fallback

**Files:**
- Create: `netlify/functions/chasen-proactive-insights.mts`
- Modify: `src/app/api/chasen/stream/route.ts` (model fallback)
- Modify: `src/lib/chasen-agents.ts` (planning integration)
- Migration: `supabase/migrations/20260215_chasen_notifications.sql`

**Step 1: Create chasen_notifications table**

```sql
CREATE TABLE IF NOT EXISTS chasen_notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT,
  notification_type TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  client_name TEXT,
  severity TEXT DEFAULT 'info' CHECK (severity IN ('info', 'warning', 'critical')),
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE chasen_notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow anon full access chasen_notifications" ON chasen_notifications FOR ALL USING (true);
```

**Step 2: Create proactive insights scheduled function**

```typescript
// netlify/functions/chasen-proactive-insights.mts
import { Config } from '@netlify/functions'
import { createClient } from '@supabase/supabase-js'

export default async function handler() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
  )

  // Check for anomalies
  const anomalies: Array<{ type: string; title: string; body: string; client?: string; severity: string }> = []

  // 1. Health score drops (>10 points in 7 days)
  const { data: healthDrops } = await supabase.rpc('detect_health_drops', { threshold: 10, days: 7 })
  for (const drop of healthDrops ?? []) {
    anomalies.push({
      type: 'health_drop',
      title: `${drop.client_name} health score dropped ${drop.delta} points`,
      body: `Health score went from ${drop.prev_score} to ${drop.current_score} in the last 7 days.`,
      client: drop.client_name,
      severity: drop.delta > 20 ? 'critical' : 'warning'
    })
  }

  // 2. Overdue actions (>7 days past due)
  const { data: overdue } = await supabase
    .from('actions')
    .select('Action_ID, Action_Title, Due_Date, Owner')
    .lt('Due_Date', new Date().toISOString())
    .neq('Status', 'Completed')
  for (const action of overdue ?? []) {
    anomalies.push({
      type: 'overdue_action',
      title: `Overdue: ${action.Action_Title}`,
      body: `${action.Action_ID} was due ${action.Due_Date}. Owner: ${action.Owner}`,
      severity: 'warning'
    })
  }

  // 3. NPS decline (per-client, comparing last 2 periods)
  // ... similar pattern

  // Insert notifications
  if (anomalies.length > 0) {
    await supabase.from('chasen_notifications').insert(
      anomalies.map(a => ({
        notification_type: a.type,
        title: a.title,
        body: a.body,
        client_name: a.client,
        severity: a.severity
      }))
    )
  }

  return new Response(JSON.stringify({ notifications: anomalies.length }))
}

export const config: Config = {
  schedule: '0 20 * * *' // Daily at 20:00 UTC (6:00 AEST)
}
```

**Step 3: Add model fallback chain to stream route**

In `src/app/api/chasen/stream/route.ts`, wrap the LLM call with fallback:

```typescript
async function callLLMWithFallback(messages, tools, modelConfig) {
  const fallbackChain = [
    modelConfig,                          // Primary (user-selected or Gemini Flash)
    { provider: 'anthropic', model: 'claude-sonnet-4-20250514' },
    { provider: 'openai', model: 'gpt-4o' }
  ]

  for (const config of fallbackChain) {
    try {
      return await callLLM(messages, tools, config)
    } catch (error) {
      console.warn(`[ChaSen] ${config.model} failed, trying next:`, error.message)
      continue
    }
  }
  throw new Error('All LLM providers failed')
}
```

**Step 4: Add planning context to agent system**

In `chasen-agents.ts`, add a function that loads active account plans for the current client context:

```typescript
async function getPlanningContext(clientName?: string): Promise<string> {
  if (!clientName) return ''
  const { data: plans } = await supabase
    .from('account_plans')
    .select('id, plan_name, status, current_step, updated_at')
    .ilike('client_name', `%${clientName}%`)
    .in('status', ['draft', 'in_progress'])
    .order('updated_at', { ascending: false })
    .limit(3)

  if (!plans?.length) return ''
  return `\n\n📋 Active Account Plans:\n${plans.map(p =>
    `- ${p.plan_name} (${p.status}, step ${p.current_step}, updated ${p.updated_at})`
  ).join('\n')}`
}
```

Wire this into the agent's context-building flow.

**Step 5: Commit**

```bash
cd ~/GitHub/apac-intelligence-v2
git add netlify/functions/chasen-proactive-insights.mts src/app/api/chasen/stream/route.ts src/lib/chasen-agents.ts supabase/migrations/20260215_chasen_notifications.sql
git commit -m "feat: add ChaSen proactive insights, model fallback, and planning integration"
```

---

### Task 3.8: Commit All Unstaged ChaSen Changes

**Files:**
- The 6 files that were modified before P14 began (from git status)

**Step 1: Review each modified file**

Read the diff for each of the 6 pre-existing modified files:
- `src/app/(dashboard)/ai/page.tsx`
- `src/components/FloatingChaSenAI.tsx`
- `src/components/guides/ContextualHelpWidget.tsx`
- `src/app/globals.css`

Determine if these changes are part of the Transformers.js work or separate improvements.

**Step 2: Stage and commit related changes**

Group by logical change and commit separately.

**Step 3: Verify clean working tree**

Run: `git status` — should show no modified files.

---

## Phase 4: E2E Test Expansion

### Task 4.1: Write New Workflow E2E Tests

**Files:**
- Create: `tests/e2e/workflows/planning-wizard.spec.ts`
- Create: `tests/e2e/workflows/pipeline.spec.ts`
- Create: `tests/e2e/workflows/nps-analytics.spec.ts`
- Create: `tests/e2e/workflows/compliance.spec.ts`
- Create: `tests/e2e/workflows/briefing-room.spec.ts`
- Create: `tests/e2e/workflows/actions-kanban.spec.ts`
- Create: `tests/e2e/workflows/burc-renewals.spec.ts`

**Step 1: Create test directory**

```bash
mkdir -p ~/GitHub/apac-intelligence-v2/tests/e2e/workflows
```

**Step 2: Write each test file**

Follow the pattern from `critical-path.spec.ts`:
- Import `{ test, expect } from '@playwright/test'`
- `test.beforeEach` sets `dev-auth-session` cookie
- Navigate to the page, wait for `networkidle`
- Assert key elements are visible
- Perform user workflow (clicks, form fills, drags)
- Verify outcomes (UI state changes, data appears)
- Collect console errors and assert none unexpected

Example for planning wizard:

```typescript
// tests/e2e/workflows/planning-wizard.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Planning Wizard Workflow', () => {
  test.beforeEach(async ({ context }) => {
    await context.addCookies([{
      name: 'dev-auth-session',
      value: 'test-user@example.com',
      domain: 'localhost',
      path: '/',
    }])
  })

  test('can create and navigate through plan steps', async ({ page }) => {
    await page.goto('/planning', { waitUntil: 'networkidle' })
    await expect(page.locator('main')).toBeVisible({ timeout: 15000 })

    // Click "New Plan" button
    const newPlanBtn = page.getByRole('button', { name: /new plan/i })
    if (await newPlanBtn.isVisible()) {
      await newPlanBtn.click()
      await page.waitForURL(/\/planning\/new/)
    }

    // Verify step navigation renders
    await expect(page.getByText(/setup|discovery|stakeholders/i).first()).toBeVisible()
  })

  test('plan list loads without console errors', async ({ page }) => {
    const errors: string[] = []
    page.on('console', msg => {
      if (msg.type() === 'error' && !msg.text().includes('favicon')) {
        errors.push(msg.text())
      }
    })

    await page.goto('/planning', { waitUntil: 'networkidle' })
    await expect(page.locator('main')).toBeVisible({ timeout: 15000 })

    expect(errors).toHaveLength(0)
  })
})
```

**Step 3: Run tests**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx playwright test tests/e2e/workflows/ --project=chromium`

**Step 4: Commit**

```bash
cd ~/GitHub/apac-intelligence-v2
git add tests/e2e/workflows/
git commit -m "feat: add 7 new E2E workflow tests (planning, pipeline, NPS, compliance, meetings, kanban, BURC)"
```

---

### Task 4.2: Write API Contract Tests

**Files:**
- Create: `tests/e2e/api/api-contracts.spec.ts`

**Step 1: Write API contract tests**

```typescript
// tests/e2e/api/api-contracts.spec.ts
import { test, expect } from '@playwright/test'

const API_ROUTES = [
  { path: '/api/clients', expectKeys: ['success', 'data'] },
  { path: '/api/actions', expectKeys: ['success', 'data'] },
  { path: '/api/meetings', expectKeys: ['success', 'data'] },
  { path: '/api/nps', expectKeys: ['success', 'data'] },
  { path: '/api/pipeline', expectKeys: ['success', 'data'] },
  { path: '/api/segmentation-events', expectKeys: ['success', 'data'] },
  { path: '/api/support-metrics/trends', expectKeys: ['success', 'data'] },
  { path: '/api/burc/financials', expectKeys: ['success', 'data'] },
]

test.describe('API Contract Tests', () => {
  test.beforeEach(async ({ context }) => {
    await context.addCookies([{
      name: 'dev-auth-session',
      value: 'test-user@example.com',
      domain: 'localhost',
      path: '/',
    }])
  })

  for (const route of API_ROUTES) {
    test(`${route.path} returns correct response shape`, async ({ request }) => {
      const response = await request.get(`http://localhost:3001${route.path}`)
      expect(response.status()).toBeLessThan(500)

      if (response.status() === 200) {
        const json = await response.json()
        for (const key of route.expectKeys) {
          expect(json).toHaveProperty(key)
        }
        expect(json.success).toBe(true)
        expect(json.data).toBeDefined()
      }
    })
  }
})
```

**Step 2: Run tests**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx playwright test tests/e2e/api/ --project=chromium`

**Step 3: Commit**

```bash
cd ~/GitHub/apac-intelligence-v2
git add tests/e2e/api/
git commit -m "feat: add API contract tests for 8 critical endpoints"
```

---

### Task 4.3: Add Data Mutation Verification

**Files:**
- Modify: workflow test files from Task 4.1 (add Supabase verification steps)

**Step 1: Add mutation verification to workflow tests**

For tests that create/update data (e.g. actions kanban drag, planning wizard save), add a step that queries Supabase directly:

```typescript
// Inside a test that creates an action:
// After the UI action...
const response = await request.get('http://localhost:3001/api/actions?limit=1&sort=created_at:desc')
const json = await response.json()
expect(json.data.data[0].Status).toBe('In Progress') // Verify mutation persisted
```

**Step 2: Run full E2E suite**

Run: `cd ~/GitHub/apac-intelligence-v2 && npm run test:e2e`

**Step 3: Commit**

```bash
cd ~/GitHub/apac-intelligence-v2
git add tests/e2e/
git commit -m "feat: add data mutation verification to E2E workflow tests"
```

---

## Phase 5: Mobile UX Audit + Fixes

### Task 5.1: Run Systematic Mobile UX Audit

**Files:**
- Create: `tests/e2e/mobile/ux-audit.spec.ts`
- Create: `docs/plans/mobile-ux-audit-results.md` (output)

**Step 1: Write automated mobile UX audit test**

```typescript
// tests/e2e/mobile/ux-audit.spec.ts
import { test, expect } from '@playwright/test'

const PAGES_TO_AUDIT = [
  '/',
  '/client-profiles',
  '/planning',
  '/meetings',
  '/actions',
  '/nps',
  '/aging-accounts',
  '/burc',
  '/compliance',
  '/pipeline',
  '/team-performance',
  '/settings/chasen',
]

test.describe('Mobile UX Audit', () => {
  test.beforeEach(async ({ context }) => {
    await context.addCookies([{
      name: 'dev-auth-session',
      value: 'test-user@example.com',
      domain: 'localhost',
      path: '/',
    }])
  })

  for (const pagePath of PAGES_TO_AUDIT) {
    test(`${pagePath} — no horizontal overflow`, async ({ page }) => {
      await page.goto(pagePath, { waitUntil: 'networkidle' })
      await page.waitForTimeout(1000)

      const hasHorizontalScroll = await page.evaluate(() => {
        return document.documentElement.scrollWidth > document.documentElement.clientWidth
      })
      expect(hasHorizontalScroll, `Horizontal overflow on ${pagePath}`).toBe(false)
    })

    test(`${pagePath} — touch targets >= 44px`, async ({ page }) => {
      await page.goto(pagePath, { waitUntil: 'networkidle' })
      await page.waitForTimeout(1000)

      const smallTargets = await page.evaluate(() => {
        const interactive = document.querySelectorAll('button, a, input, select, [role="button"]')
        const small: string[] = []
        interactive.forEach(el => {
          const rect = el.getBoundingClientRect()
          if (rect.width > 0 && rect.height > 0 && (rect.width < 44 || rect.height < 44)) {
            small.push(`${el.tagName}[${el.textContent?.slice(0, 20)}] (${Math.round(rect.width)}x${Math.round(rect.height)})`)
          }
        })
        return small
      })

      // Log findings but don't fail — audit phase
      if (smallTargets.length > 0) {
        console.log(`[AUDIT] ${pagePath}: ${smallTargets.length} small touch targets:`)
        smallTargets.forEach(t => console.log(`  - ${t}`))
      }
    })

    test(`${pagePath} — screenshot for manual review`, async ({ page }) => {
      await page.goto(pagePath, { waitUntil: 'networkidle' })
      await page.waitForTimeout(2000)
      await page.screenshot({
        path: `test-results/mobile-audit/${pagePath.replace(/\//g, '_')}.png`,
        fullPage: true
      })
    })
  }
})
```

**Step 2: Run audit on mobile devices**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx playwright test tests/e2e/mobile/ux-audit.spec.ts --project=iphone-12 --project=iphone-se --project=pixel-7`

**Step 3: Compile audit results**

Review screenshots and test output. Create `docs/plans/mobile-ux-audit-results.md` with:
- Score per page (1-10)
- Screenshots of issues
- Prioritised fix list

**Step 4: Commit**

```bash
cd ~/GitHub/apac-intelligence-v2
git add tests/e2e/mobile/ux-audit.spec.ts
git commit -m "feat: add mobile UX audit test suite"
cd ~/GitHub/apac-intelligence-v2/docs
git add plans/mobile-ux-audit-results.md
git commit -m "docs: mobile UX audit results with prioritised fix list"
```

---

### Task 5.2: Implement Mobile UX Fixes

**Files:** Determined by audit results. Expected candidates:
- Various component files — increase touch target sizes
- `src/components/ui/data-table-mobile-card.tsx` — improve table mobile views
- Form components — add `inputmode` attributes
- Layout components — safe area insets

**Step 1: Work through prioritised fix list from audit**

For each fix:
1. Identify the component file
2. Make the change (increase padding, add inputmode, adjust sizing)
3. Re-run the specific audit test to verify
4. Commit incrementally

**Step 2: Re-run full mobile audit**

Run: `cd ~/GitHub/apac-intelligence-v2 && npx playwright test tests/e2e/mobile/ --project=iphone-12`

**Step 3: Update mobile UX score**

Update `docs/knowledge-base/08-roadmap/priorities.md` with new mobile UX score.

**Step 4: Final commit**

```bash
cd ~/GitHub/apac-intelligence-v2
git add -A
git commit -m "feat: mobile UX fixes — touch targets, form inputs, safe areas"
```

---

## Summary

| Phase | Tasks | Key Deliverables |
|-------|-------|-----------------|
| 1. BURC Tables | 1.1-1.4 | 4 tables, sync parsers, ChaSen formatters, docs |
| 2. Performance CI | 2.1-2.3 | Bundle analyzer, Lighthouse CI, GitHub Actions workflow |
| 3. ChaSen Overhaul | 3.1-3.8 | Local inference, formatter registry, context budgeting, timeout fallback, tool modularisation, prompts DB, proactive insights, model fallback |
| 4. E2E Tests | 4.1-4.3 | 7 workflow tests, API contracts, mutation verification |
| 5. Mobile UX | 5.1-5.2 | Automated audit suite, fixes based on findings |

**Total: 17 tasks across 5 phases.**
