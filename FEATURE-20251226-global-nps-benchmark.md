# Feature: Global NPS Benchmark Comparison

**Date**: 2025-12-26
**Type**: New Feature
**Status**: Complete

## Summary

Added the ability to compare APAC NPS performance against global Altera benchmark data for Q4 2025.

## Key Findings

### NPS Score Comparison (Q4 2025)

| Metric | Global Altera | APAC | Difference |
|--------|---------------|------|------------|
| **NPS Score** | -5.3 | -18.6 | -13.3 points |
| **Total Responses** | 361 | 43 | - |
| **Promoters (9-10)** | 27.7% | 16.3% | -11.4% |
| **Detractors (0-6)** | 33.0% | 34.9% | +1.9% |

*Note: Global figures exclude all 43 APAC responses using conservative matching.*

### Key Insights

1. **APAC is performing 13.3 points below the global average**
2. **Lower promoter rate** - APAC has 11.4% fewer promoters than global (16.3% vs 27.7%)
3. **Higher passive rate** - APAC has more passives, indicating opportunity to convert to promoters
4. **Similar detractor rate** - Only slightly higher than global (+1.9%)

### Detractor Keyword Analysis

Top themes mentioned in negative feedback:

| Keyword | Global | APAC | Insight |
|---------|--------|------|---------|
| Support* | 28% | 9% | Less support/problem mentions in APAC |
| Issue | 22% | 36% | **Higher issue mentions in APAC** |
| Service | 16% | 36% | **Significantly higher service concerns in APAC** |
| Time | 21% | 9% | Less time-related complaints in APAC |
| Response | 8% | 18% | Higher response time concerns in APAC |

*Support category includes "problem" mentions (merged for clearer analysis)

## Technical Implementation

### Database

Created new table `global_nps_benchmark`:

```sql
CREATE TABLE global_nps_benchmark (
  id SERIAL PRIMARY KEY,
  score INTEGER NOT NULL CHECK (score >= 0 AND score <= 10),
  category TEXT NOT NULL CHECK (category IN ('Promoter', 'Passive', 'Detractor')),
  feedback TEXT,
  period TEXT NOT NULL DEFAULT 'Q4 25',
  region TEXT DEFAULT 'Global (excl. APAC)',
  is_apac_duplicate BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Duplicate Detection

Two-phase approach to ensure all APAC responses are excluded:

**Phase 1: Verbatim Matching**
- Used Jaccard similarity algorithm (80%+ threshold) to match responses with feedback
- 32 responses identified as duplicates

**Phase 2: Conservative Score Matching**
- 11 APAC responses had no feedback (can't match by verbatim)
- Applied conservative exclusion: matched by score for blank-feedback entries
- Additional 11 global responses marked as APAC duplicates

**Final Result:**
- 43 total APAC duplicates excluded (100% of APAC responses)
- 361 unique global (non-APAC) responses in benchmark

### API Endpoint

`GET /api/nps/global-benchmark?period=Q4 25`

Returns:
- Global and APAC NPS metrics
- Comparison statistics
- Keyword analysis for detractor feedback

### UI Component

`GlobalNPSBenchmark.tsx` - Collapsible comparison panel on NPS page showing:
- Side-by-side NPS score comparison
- Promoter/Passive/Detractor breakdown
- Keyword frequency analysis with visual bars
- Key insights summary

## Files Changed

### New Files
- `scripts/import-global-nps.mjs` - Import script
- `docs/migrations/20251226_global_nps_benchmark.sql` - Migration SQL
- `src/app/api/nps/global-benchmark/route.ts` - API endpoint
- `src/components/GlobalNPSBenchmark.tsx` - UI component

### Modified Files
- `src/app/(dashboard)/nps/page.tsx` - Added benchmark component

## Future Enhancements

1. **Period Selection** - Allow comparing different survey periods
2. **Trend Analysis** - Track APAC vs Global gap over time
3. **Regional Breakdown** - Break down global by region (Americas, EMEA, etc.)
4. **AI Recommendations** - ChaSen-powered suggestions based on gaps
