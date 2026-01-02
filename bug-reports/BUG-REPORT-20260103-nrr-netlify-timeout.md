# Bug Report: NRR Chart Not Displaying on Production

**Date:** 3 January 2026
**Severity:** High
**Status:** Resolved
**Affected Page:** Financials > Historical Analytics (2019-2025) tab

## Issue Description

The NRR/GRR Trends chart was showing "No NRR data available" on production (https://apac-cs-dashboards.com) but worked correctly on the development server.

## Root Cause Analysis

The NRR calculation required:
1. Fetching **84,932 records** from `burc_historical_revenue_detail`
2. Grouping by client and year
3. Calculating year-over-year retention metrics

Even with parallel pagination, this process took **44+ seconds** - well beyond Netlify's serverless function timeout limit of **10-26 seconds**.

### Timing Comparison
| Environment | Timeout Limit | Actual Time | Result |
|-------------|---------------|-------------|--------|
| Development (localhost) | No limit | 44 seconds | ✅ Works |
| Production (Netlify) | 10-26 seconds | 44 seconds | ❌ Timeout |

## Solution Implemented

Replaced on-the-fly calculation with **pre-computed NRR metrics**:

```typescript
const PRECOMPUTED_NRR_METRICS = [
  { year: 2019, nrr: 0, grr: 0, expansion: 0, contraction: 0, churn: 0, newBusiness: 14488880 },
  { year: 2020, nrr: 92.5, grr: 61.1, expansion: 4547262, contraction: 5631287, churn: 0, newBusiness: 211065 },
  { year: 2021, nrr: 164.8, grr: 82.8, expansion: 11165686, contraction: 2342726, churn: 0, newBusiness: 373845 },
  { year: 2022, nrr: 120.2, grr: 70.6, expansion: 11334457, contraction: 6716167, churn: 0, newBusiness: 0 },
  { year: 2023, nrr: 143.6, grr: 92.3, expansion: 16173658, contraction: 2434884, churn: 0, newBusiness: 9236645 },
  { year: 2024, nrr: 88.0, grr: 77.8, expansion: 5611738, contraction: 12268101, churn: 0, newBusiness: 828146 },
  { year: 2025, nrr: 92.8, grr: 72.2, expansion: 10533435, contraction: 11982538, churn: 2199919, newBusiness: 5084205 },
]
```

### Performance Improvement
| Metric | Before | After |
|--------|--------|-------|
| Response Time | 44+ seconds | <100ms |
| Database Queries | 85 pages | 0 |
| Netlify Compatible | ❌ No | ✅ Yes |

## Files Changed

- `src/app/api/analytics/burc/historical/route.ts`
  - Added `PRECOMPUTED_NRR_METRICS` constant with pre-calculated values
  - Simplified `getHistoricalNRR()` function to use pre-computed data

## How to Update NRR Values

When new BURC data is imported, refresh the pre-computed values:

1. Run the test script:
   ```bash
   node scripts/test-nrr-api.mjs
   ```

2. Update the `PRECOMPUTED_NRR_METRICS` constant in `route.ts` with the new values

3. Deploy to production

## Verification Steps

1. Navigate to https://apac-cs-dashboards.com/financials
2. Click on "Historical (2019-2025)" tab
3. Verify the NRR/GRR Trends chart displays with data
4. Check that Latest NRR shows 92.8% and Latest GRR shows 72.2%

## Related Commits

- `5dc3122` - fix: use pre-computed NRR metrics to avoid Netlify timeout

## Lessons Learned

1. **Serverless timeout limits** - Always consider function timeout limits when processing large datasets
2. **Pre-computation** - For stable, infrequently-changing data, pre-compute and store rather than calculate on each request
3. **Test on production-like environments** - Development servers have no timeout limits, so issues only appear in production

---

## Author

Claude AI - Bug fix and documentation
