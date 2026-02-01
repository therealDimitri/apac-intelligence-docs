# News Intelligence System v2 - Robust Filtering Algorithm

**Date:** 2026-02-01
**Status:** Design Complete
**Type:** Enhancement

## Problem Statement

The current News Intelligence System surfaces too much noise - articles about military appointments, Saudi oil, Apple products, and general business news that have no relevance to APAC healthcare clients.

### Current Issues

| Issue | Impact |
|-------|--------|
| 31/61 sources are "general" news | Bloomberg, CNA, SCMP cover military, oil, finance |
| Topic score defaults to 50 | Non-healthcare articles get "general healthcare" base score |
| Action triggers too broad | "appointed" fires for ANY appointment |
| No healthcare domain filtering | Military, finance, geopolitics pass through |
| No geographic filtering | Saudi Arabia, Israel, Europe articles appear |
| No negative signals | Algorithm only adds points, never subtracts |

### Current Stats

- 657 articles in system
- 0 articles with client matches
- 80%+ are noise (non-healthcare or non-APAC)
- Score distribution: 0 high (70+), 77 medium (50-69), 530 low (30-49)

## Solution: Three-Tier Filtering Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                     ARTICLE INGESTION                            │
│                    (RSS feeds, ~500/day)                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  TIER 1: PRE-FILTERS (Free, instant)                            │
│                                                                  │
│  1. Healthcare keyword check (must have ≥1)                      │
│  2. Job posting detection (discard if matches)                   │
│  3. Geographic filter (must be APAC region)                      │
│                                                                  │
│  Expected: ~70% discarded                                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  TIER 2: AI HEALTHCARE GATE (Haiku batch, ~$0.001/batch)        │
│                                                                  │
│  Batch 15 articles → single Haiku call                          │
│  Classifies: healthcare-related? Y/N                            │
│                                                                  │
│  Catches edge cases keywords miss                                │
│  Expected: ~30% of remaining discarded                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  TIER 3: FULL CHASEN SCORING (Sonnet, ~$0.01/article)           │
│                                                                  │
│  Only ~100 articles/day reach this stage                        │
│  Full relevance scoring + AI summary + actions                  │
│                                                                  │
│  Cost savings: ~80% reduction in Sonnet API calls               │
└─────────────────────────────────────────────────────────────────┘
```

---

## Tier 1: Pre-Filters

### 1.1 Healthcare Keyword Allowlist

Articles must contain at least one healthcare keyword to proceed.

```typescript
const HEALTHCARE_KEYWORDS = [
  // Core healthcare
  'health', 'hospital', 'medical', 'clinical', 'patient', 'healthcare',
  'clinic', 'physician', 'nurse', 'doctor', 'surgery', 'surgical',

  // Health IT
  'EMR', 'EHR', 'electronic health', 'electronic medical', 'health record',
  'FHIR', 'HL7', 'interoperability', 'health information', 'clinical system',

  // Adjacent sectors
  'pharmaceutical', 'biotech', 'aged care', 'mental health', 'disability',
  'health insurance', 'medicare', 'medicaid', 'NDIS', 'telehealth',

  // Organisations
  'ministry of health', 'department of health', 'health department',
  'health authority', 'health service', 'health district',

  // Vendors (Altera + competitors)
  'Altera', 'Sunrise', 'Epic', 'Cerner', 'Oracle Health', 'MEDITECH',
  'InterSystems', 'TrakCare', 'Orion Health',
]

function hasHealthcareKeyword(title: string, summary: string | null): boolean {
  const text = `${title} ${summary || ''}`.toLowerCase()
  return HEALTHCARE_KEYWORDS.some(kw => text.includes(kw.toLowerCase()))
}
```

### 1.2 Job Posting Filter

Job postings are excluded entirely - they are not actionable for sales.

```typescript
const JOB_POSTING_PATTERNS = [
  // Direct job indicators
  /\bGP wanted\b/i,
  /\bwe are (looking for|seeking|hiring)\b/i,
  /\b(permanent|fixed term|full.?time|part.?time) position\b/i,
  /\bapply now\b/i,
  /\bjob (opportunity|opening|vacancy)\b/i,
  /\bnow hiring\b/i,
  /\bjoin our team\b/i,
  /\bcareer opportunity\b/i,

  // Role + location patterns (NZ Doctor style)
  /\b(GP|General Practitioner|Nurse|NP)\s*[-–]\s*[A-Z][a-z]+/i,

  // Expressions of interest for positions
  /\bexpressions of interest.{0,20}position\b/i,
]

function isJobPosting(title: string, summary: string | null): boolean {
  const text = `${title} ${summary || ''}`
  return JOB_POSTING_PATTERNS.some(pattern => pattern.test(text))
}
```

### 1.3 Geographic Filter (APAC Only)

Only articles about APAC, Australia, New Zealand, Singapore, Philippines, or Guam.

```typescript
const APAC_REGIONS = {
  countries: [
    'Australia', 'New Zealand', 'Singapore', 'Philippines', 'Guam',
    'Malaysia', 'Indonesia', 'Thailand', 'Vietnam', 'Hong Kong',
    'Taiwan', 'Japan', 'South Korea', 'India', 'China',
  ],

  australia: [
    'NSW', 'New South Wales', 'Victoria', 'VIC', 'Queensland', 'QLD',
    'South Australia', 'SA', 'Western Australia', 'WA', 'Tasmania', 'TAS',
    'Northern Territory', 'NT', 'ACT', 'Canberra',
  ],

  new_zealand: [
    'Auckland', 'Wellington', 'Christchurch', 'Waikato', 'Canterbury',
    'Otago', 'Bay of Plenty', 'Hawke', 'Manawatu', 'Taranaki',
  ],

  cities: [
    'Sydney', 'Melbourne', 'Brisbane', 'Perth', 'Adelaide', 'Hobart',
    'Darwin', 'Geelong', 'Ballarat', 'Bendigo',
    'Singapore', 'Manila', 'Cebu',
    'Hagåtña', 'Tamuning', 'Dededo',
  ],

  health_specific: [
    'APAC', 'Asia Pacific', 'Asia-Pacific', 'Australasia', 'Oceania',
    'Te Whatu Ora', 'SingHealth', 'Synapxe', 'ADHA', 'Medicare Australia',
  ],
}

const NON_APAC_EXCLUSIONS = [
  'Saudi Arabia', 'Saudi', 'UAE', 'Dubai', 'Qatar', 'Kuwait',
  'Israel', 'Palestine', 'Iran', 'Iraq',
  'UK', 'United Kingdom', 'Britain', 'England', 'Scotland', 'Wales',
  'Germany', 'France', 'Italy', 'Spain', 'Netherlands',
  'USA', 'United States', 'America', 'Canada', 'Mexico',
  'Brazil', 'Argentina', 'Chile',
  'Nigeria', 'South Africa', 'Kenya', 'Egypt',
]

function passesGeographicFilter(
  title: string,
  summary: string | null,
  sourceRegions: string[] | null
): boolean {
  const text = `${title} ${summary || ''}`.toLowerCase()

  const allAPACTerms = [
    ...APAC_REGIONS.countries,
    ...APAC_REGIONS.australia,
    ...APAC_REGIONS.new_zealand,
    ...APAC_REGIONS.cities,
    ...APAC_REGIONS.health_specific,
  ]

  // If source is tagged with APAC region, pass
  if (sourceRegions?.some(r =>
    allAPACTerms.some(term => r.toLowerCase().includes(term.toLowerCase()))
  )) {
    return true
  }

  // Check for explicit non-APAC mentions
  for (const exclusion of NON_APAC_EXCLUSIONS) {
    if (text.includes(exclusion.toLowerCase())) {
      // Exception: if APAC region ALSO mentioned, keep it
      const hasAPAC = allAPACTerms.some(term => text.includes(term.toLowerCase()))
      if (!hasAPAC) return false
    }
  }

  // Must have at least one APAC mention
  return allAPACTerms.some(term => text.includes(term.toLowerCase()))
}
```

### 1.4 Combined Tier 1 Filter

```typescript
interface Tier1Result {
  passed: boolean
  reason?: 'no_healthcare_keyword' | 'job_posting' | 'non_apac_region'
}

function tier1Filter(
  title: string,
  summary: string | null,
  sourceRegions: string[] | null
): Tier1Result {
  // Check healthcare keywords
  if (!hasHealthcareKeyword(title, summary)) {
    return { passed: false, reason: 'no_healthcare_keyword' }
  }

  // Check job posting
  if (isJobPosting(title, summary)) {
    return { passed: false, reason: 'job_posting' }
  }

  // Check geographic region
  if (!passesGeographicFilter(title, summary, sourceRegions)) {
    return { passed: false, reason: 'non_apac_region' }
  }

  return { passed: true }
}
```

---

## Tier 2: AI Healthcare Gate

Batch classification using Claude Haiku to catch edge cases that keywords miss.

### 2.1 Classification Prompt

```typescript
const HEALTHCARE_GATE_PROMPT = `You are a healthcare news classifier. For each article, determine if it is
related to healthcare, health technology, or adjacent health sectors.

INCLUDE (answer Y):
- Hospitals, health systems, clinical care delivery
- Medical devices, health IT, EMR/EHR systems
- Pharmaceuticals, biotechnology, medical research
- Aged care, mental health services, disability services
- Health insurance, health funding, Medicare/Medicaid
- Health workforce, nursing, medical training
- Public health, epidemiology, health policy

EXCLUDE (answer N):
- General technology companies unless healthcare context
- Finance, banking, investment unless health sector funding
- Military, defence, geopolitics
- Oil, energy, mining, construction
- General government unless health ministry/department
- General business news unless healthcare company

Articles:
{articles}

Respond with ONLY a JSON array of Y/N values in order:
["Y", "N", "Y", ...]`
```

### 2.2 Batch Processing

```typescript
async function tier2HealthcareGate(
  articles: Array<{ id: number; title: string; summary: string | null }>
): Promise<Map<number, boolean>> {
  const anthropic = new Anthropic()
  const results = new Map<number, boolean>()

  // Process in batches of 15
  for (let i = 0; i < articles.length; i += 15) {
    const batch = articles.slice(i, i + 15)

    const articleList = batch
      .map((a, idx) => `${idx + 1}. "${a.title}" - ${a.summary?.slice(0, 200) || 'No summary'}`)
      .join('\n')

    const response = await anthropic.messages.create({
      model: 'claude-3-haiku-20240307',
      max_tokens: 100,
      messages: [{
        role: 'user',
        content: HEALTHCARE_GATE_PROMPT.replace('{articles}', articleList)
      }]
    })

    const text = response.content[0].type === 'text' ? response.content[0].text : '[]'
    const classifications = JSON.parse(text) as string[]

    batch.forEach((article, idx) => {
      results.set(article.id, classifications[idx] === 'Y')
    })
  }

  return results
}
```

---

## Tier 3: Improved ChaSen Scoring

### 3.1 Enhanced Topic Relevance Scores

Replace the flat "50 for general healthcare" with granular scoring:

```typescript
const TOPIC_SCORES = {
  // Direct relevance (100)
  altera_mention: 100,
  competitor_mention: 95,

  // High relevance (80-90)
  emr_ehr_project: 90,
  health_it_system: 85,
  digital_transformation: 80,

  // Medium relevance (50-70)
  health_funding_budget: 70,
  hospital_operations: 60,
  health_policy: 55,

  // Low relevance (20-40)
  clinical_research: 40,
  health_workforce: 35,
  event_announcement: 25,

  // Fallback
  general_healthcare: 30,
}
```

### 3.2 Context-Aware Action Triggers

Triggers only fire when healthcare context is nearby:

```typescript
const CONTEXTUAL_TRIGGERS = {
  leadership_change: {
    patterns: ['appointed', 'new CEO', 'new CIO', 'new CMIO', 'joins as', 'stepping down'],
    requires_context: ['hospital', 'health', 'medical', 'clinical', 'healthcare'],
    context_window: 100,
  },
  rfi_tender: {
    patterns: ['tender', 'RFP', 'RFI', 'procurement', 'expression of interest'],
    requires_context: ['health', 'hospital', 'medical', 'clinical', 'EMR', 'EHR'],
    context_window: 200,
  },
  it_project: {
    patterns: ['go-live', 'implementation', 'upgrade', 'digital transformation'],
    requires_context: ['EMR', 'EHR', 'hospital', 'health system', 'clinical'],
    context_window: 150,
  },
  budget_funding: {
    patterns: ['million', 'billion', 'funding', 'budget', 'investment'],
    requires_context: ['health', 'hospital', 'medical', 'IT', 'digital'],
    context_window: 100,
  },
}

function detectTriggersWithContext(text: string): { type: string; score: number }[] {
  const triggers: { type: string; score: number }[] = []
  const textLower = text.toLowerCase()

  for (const [triggerType, config] of Object.entries(CONTEXTUAL_TRIGGERS)) {
    for (const pattern of config.patterns) {
      const patternIndex = textLower.indexOf(pattern.toLowerCase())
      if (patternIndex === -1) continue

      // Extract context window around the pattern
      const start = Math.max(0, patternIndex - config.context_window)
      const end = Math.min(text.length, patternIndex + pattern.length + config.context_window)
      const context = textLower.slice(start, end)

      // Check if healthcare context exists nearby
      const hasContext = config.requires_context.some(ctx =>
        context.includes(ctx.toLowerCase())
      )

      if (hasContext) {
        triggers.push({ type: triggerType, score: TRIGGER_SCORES[triggerType] })
        break
      }
    }
  }

  return triggers
}
```

### 3.3 Revised Scoring Formula

Increased weight on client matching (primary value driver):

```
RELEVANCE = CLIENT×0.40 + TOPIC×0.25 + ACTION×0.20 + SOURCE×0.10 + RECENCY×0.05
```

| Factor | Old Weight | New Weight | Rationale |
|--------|------------|------------|-----------|
| Client Match | 0.30 | **0.40** | Primary value driver |
| Topic Relevance | 0.25 | 0.25 | Unchanged |
| Action Potential | 0.20 | 0.20 | Unchanged |
| Source Authority | 0.15 | **0.10** | Less important than content |
| Recency | 0.10 | **0.05** | Fresh is good but not critical |

### 3.4 Display Thresholds

| Category | Minimum Score | Display Location |
|----------|---------------|------------------|
| Urgent Action | ≥40 | Urgent banner + main feed |
| Opportunity | ≥35 | Main feed |
| Monitor | ≥30 | Main feed |
| FYI | ≥30 | Main feed (collapsed) |
| Below threshold | <30 | Hidden (stored but not shown) |

---

## Database Changes

### New Columns on news_articles

```sql
ALTER TABLE news_articles ADD COLUMN IF NOT EXISTS
  tier1_passed BOOLEAN,
  tier1_reject_reason TEXT,
  tier2_passed BOOLEAN,
  article_type TEXT; -- 'news', 'press_release', 'analysis', 'event', 'job_posting'
```

### Filter Statistics Table

```sql
CREATE TABLE IF NOT EXISTS news_filter_stats (
  id SERIAL PRIMARY KEY,
  run_date DATE NOT NULL,
  articles_ingested INT,
  tier1_rejected_no_keyword INT,
  tier1_rejected_job_posting INT,
  tier1_rejected_non_apac INT,
  tier2_rejected INT,
  tier3_scored INT,
  tier3_above_threshold INT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Implementation Plan

### Phase 1: Tier 1 Filters
- [ ] Create `src/lib/news-intelligence/article-filters.ts`
- [ ] Implement `hasHealthcareKeyword()`
- [ ] Implement `isJobPosting()`
- [ ] Implement `passesGeographicFilter()`
- [ ] Integrate into RSS fetcher (filter before insert)

### Phase 2: Tier 2 AI Gate
- [ ] Create `src/lib/news-intelligence/healthcare-gate.ts`
- [ ] Implement Haiku batch classification
- [ ] Add to scoring cron job (gate before full scoring)

### Phase 3: Improved Tier 3 Scoring
- [ ] Update `chasen-scorer.ts` with new topic scores
- [ ] Implement context-aware triggers
- [ ] Update scoring formula weights
- [ ] Add article type classification

### Phase 4: Cleanup & Monitoring
- [ ] Re-score existing articles with new algorithm
- [ ] Archive/deactivate noise articles
- [ ] Add filter statistics dashboard
- [ ] Update UI thresholds

---

## Expected Outcomes

| Metric | Current | Target |
|--------|---------|--------|
| Articles ingested/day | ~500 | ~500 |
| After Tier 1 | - | ~150 (70% filtered) |
| After Tier 2 | - | ~100 (80% filtered) |
| Displayed in UI | 657 | ~100 |
| Noise rate | ~80% | <10% |
| Sonnet API calls/day | ~500 | ~100 (80% reduction) |
| False positive rate | High | <10% target |

---

## Files to Create/Modify

```
src/lib/news-intelligence/
├── article-filters.ts        (NEW - Tier 1 filters)
├── healthcare-gate.ts        (NEW - Tier 2 AI gate)
├── chasen-scorer.ts          (MODIFY - improved scoring)
├── rss-fetcher.ts            (MODIFY - integrate Tier 1)
└── constants.ts              (NEW - keywords, regions, patterns)

src/app/api/cron/
├── news-fetch/route.ts       (MODIFY - filter before insert)
└── news-score/route.ts       (MODIFY - add Tier 2 gate)
```
