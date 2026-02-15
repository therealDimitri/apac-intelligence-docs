# Bug Report: CSI AI Insights Failing on Production (Netlify Timeout)

**Date:** 30 December 2025
**Severity:** Medium
**Status:** Resolved

---

## Summary

The CSI Operating Ratios AI-powered insights were not appearing on Production (Netlify deployment), showing fallback statistical insights instead of AI-generated analysis. The same feature worked correctly on local development. Investigation revealed the MatchaAI API call was timing out due to Netlify's serverless function time limits.

---

## Symptoms

1. On Production (`apac-cs-dashboards.com`), the Financials > CSI Ratios > Analysis tab showed insights but with `modelUsed: "fallback"` instead of `"Claude Sonnet 4.5"`
2. The same page on local development (`localhost:3002`) showed AI-generated insights correctly
3. Console logs showed `[csi-insights] AI generation failed, using fallback` errors
4. Processing time exceeded 45 seconds on Production

---

## Root Cause Analysis

**Netlify Function Timeout Exceeded**

The CSI insights API route (`/api/analytics/burc/csi-insights`) was configured with:
- MatchaAI timeout: **120 seconds** (2 minutes)
- No `maxDuration` export for Next.js route

However, Netlify serverless functions have strict timeout limits:
- Free tier: 10 seconds
- Pro tier: 26 seconds (can be extended to 60s)
- Enterprise: up to 300 seconds

The function was being terminated by Netlify before the MatchaAI response could be received, causing the error to be caught and fallback insights to be generated.

**Why it worked locally:**
Local development (Node.js server) has no function timeout limits, allowing the 120-second timeout to complete.

---

## Files Affected

- `src/app/api/analytics/burc/csi-insights/route.ts`

---

## Solution

### Fix 1: Add maxDuration Export

Added `maxDuration` export to extend function timeout to Netlify's maximum (60 seconds):

```typescript
export const dynamic = 'force-dynamic'

// Netlify function timeout (max 60s on Pro tier)
// This allows the AI call to complete within serverless limits
export const maxDuration = 60
```

### Fix 2: Reduce MatchaAI Timeout

Reduced the MatchaAI timeout from 120 seconds to 50 seconds to fit within the serverless limit (leaving 10 seconds buffer for database queries and processing):

```typescript
// Before
timeout: 120000, // 2 minute timeout for complex analysis

// After
timeout: 50000, // 50 second timeout (Netlify has 60s max function limit)
```

### Fix 3: Reduce Token Limits

Reduced max tokens to help AI respond faster:

```typescript
// Before
maxTokens: insightDepth === 'brief' ? 2000 : insightDepth === 'detailed' ? 6000 : 4000,

// After
maxTokens: insightDepth === 'brief' ? 2000 : insightDepth === 'detailed' ? 4000 : 3000,
```

---

## Verification

1. TypeScript compilation passed with no errors
2. Deploy to Production and verify:
   - CSI insights load within 60 seconds
   - `modelUsed` shows `"Claude Sonnet 4.5"` instead of `"fallback"`
   - AI-generated narrative and recommendations appear

---

## Prevention Recommendations

1. **Always consider serverless limits**: When using AI APIs in serverless functions, ensure timeouts fit within platform limits

2. **Add maxDuration to long-running routes**: For Next.js routes that call external APIs, explicitly set `maxDuration`:
   ```typescript
   export const maxDuration = 60 // seconds
   ```

3. **Implement streaming**: For AI responses that may exceed timeout limits, consider implementing streaming responses instead of waiting for complete responses

4. **Cache aggressively**: The existing 1-hour cache for AI insights is good - ensures most requests are served from cache

5. **Monitor function execution times**: Set up alerts for functions approaching timeout limits

---

## Related Documentation

- Netlify Function Limits: https://docs.netlify.com/functions/overview/#default-deployment-options
- Next.js maxDuration: https://nextjs.org/docs/app/api-reference/file-conventions/route-segment-config#maxduration
- MatchaAI API: https://matcha.harriscomputer.com
- Previous MatchaAI bug: `docs/bug-reports/BUG-REPORT-20251226-email-assist-matchaai-api-errors.md`

---

## Configuration Reference

### Current Timeout Settings

| Setting | Value | Notes |
|---------|-------|-------|
| Netlify maxDuration | 60s | Maximum for Pro tier |
| MatchaAI timeout | 50s | Leaves 10s buffer |
| Response cache | 1 hour | Reduces AI calls |
| Max tokens (standard) | 3000 | Reduced from 4000 |
| Max tokens (detailed) | 4000 | Reduced from 6000 |
