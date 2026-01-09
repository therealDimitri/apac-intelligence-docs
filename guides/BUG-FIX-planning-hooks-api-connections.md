# Bug Fix: Planning Hooks API Connection Fixes

**Date:** 2026-01-09
**Severity:** High
**Status:** Fixed
**Files Modified:**
- `src/hooks/usePlanningFinancials.ts`
- `src/hooks/usePlanningAI.ts`

---

## Issue Summary

Several planning hooks were incorrectly connected to API routes, resulting in failed data fetches and incorrect client-side data aggregation instead of server-side processing.

---

## Issues Identified

### 1. useTerritoryFinancials - Incorrect API Endpoint

**File:** `src/hooks/usePlanningFinancials.ts`

**Problem:** The `useTerritoryFinancials` hook was fetching from `/api/planning/financials/account` instead of the dedicated `/api/planning/financials/territory` endpoint. This resulted in:
- Inefficient client-side data transformation
- Incorrect territory aggregation logic
- Missing quarterly performance data
- Loss of proper territory summary statistics

**Root Cause:** The hook was implemented before the territory endpoint was fully available, using account data as a fallback that was never updated.

**Fix:** Updated the hook to fetch directly from `/api/planning/financials/territory` endpoint, which provides:
- Pre-aggregated territory data
- Proper quarterly performance metrics
- Accurate territory summary statistics
- Fallback data indication

### 2. useAPACGoals - Client-Side Aggregation Instead of Server-Side

**File:** `src/hooks/usePlanningFinancials.ts`

**Problem:** The `useAPACGoals` hook was making multiple parallel requests to `/api/planning/financials/business-unit` for each BU (ANZ, SEA, Greater China) and aggregating the data client-side. This caused:
- Unnecessary network requests
- Incomplete data due to failed BU fetches
- Inconsistent aggregation logic
- Missing KPI summary, planning progress, and risk overview data

**Root Cause:** The hook was implemented before the APAC goals endpoint was created, using a workaround that was never replaced.

**Fix:** Updated the hook to fetch directly from `/api/planning/financials/apac` endpoint, which provides:
- Pre-aggregated APAC-wide financial data
- Complete KPI summary with status indicators
- Planning progress tracking
- Risk overview with at-risk ARR calculations
- Proper BU contributions data

### 3. usePlanningAI - Non-Existent API Endpoints

**File:** `src/hooks/usePlanningAI.ts`

**Problem:** The hook referenced API endpoints that did not exist:
- `/api/planning/ai/summary` (does not exist)
- `/api/planning/ai/risks` (does not exist)
- `/api/planning/ai/stakeholders` (does not exist)
- `/api/planning/ai/actions` (should be `/api/planning/ai/next-best-actions`)
- `/api/planning/ai/plan` (should be `/api/planning/ai/generate-plan`)

**Root Cause:** API endpoints were planned but implementation was changed to consolidate multiple functions into the insights endpoint with type parameters.

**Fix:** Updated endpoint mappings:
| Function | Old Endpoint | New Endpoint | Notes |
|----------|--------------|--------------|-------|
| accountSummary | `/api/planning/ai/summary` | `/api/planning/ai/insights` | Uses `type: 'summary'` |
| riskAnalysis | `/api/planning/ai/risks` | `/api/planning/ai/insights` | Uses `type: 'risks'` |
| stakeholders | `/api/planning/ai/stakeholders` | `/api/planning/ai/insights` | Uses `type: 'stakeholders'` |
| nextBestActions | `/api/planning/ai/actions` | `/api/planning/ai/next-best-actions` | Uses `scope: 'client'` |
| draftPlan | `/api/planning/ai/plan` | `/api/planning/ai/generate-plan` | Uses `planType: 'account'` |

---

## Verified Working Hooks

The following hooks were verified to be correctly connected:

### usePlanningInsights.ts
- `/api/planning/ai/insights` (GET and POST) - Correct
- `/api/planning/ai/next-best-actions` (GET, POST, PATCH) - Correct

### usePlanningCompliance.ts
- `/api/planning/compliance/account` - Correct
- `/api/planning/compliance/territory` - Correct

---

## Testing Verification

**Build Status:** Passed

All changes were verified with a successful `npm run build` execution.

---

## API Route Reference

### Financials API Routes
| Route | Methods | Purpose |
|-------|---------|---------|
| `/api/planning/financials/account` | GET | Account-level financials |
| `/api/planning/financials/territory` | GET | Territory-aggregated financials |
| `/api/planning/financials/business-unit` | GET | Business unit financials |
| `/api/planning/financials/apac` | GET | APAC-wide goals and KPIs |

### AI API Routes
| Route | Methods | Purpose |
|-------|---------|---------|
| `/api/planning/ai/insights` | GET, POST | AI-generated insights (summary, risks, stakeholders) |
| `/api/planning/ai/next-best-actions` | GET, POST, PATCH | Next best action recommendations |
| `/api/planning/ai/meddpicc` | GET, POST, PATCH | MEDDPICC analysis and scoring |
| `/api/planning/ai/generate-plan` | GET, POST | Account plan generation |

### Compliance API Routes
| Route | Methods | Purpose |
|-------|---------|---------|
| `/api/planning/compliance/account` | GET | Account compliance requirements |
| `/api/planning/compliance/territory` | GET | Territory compliance summary |

---

## Recommendations

1. **Code Review Practice:** When implementing hooks that consume API routes, verify the route exists and matches the expected parameters before merging.

2. **Integration Tests:** Add integration tests that verify hooks successfully connect to their API routes.

3. **API Documentation:** Keep the API route documentation in sync with implementation changes.

4. **Fallback Data:** When fallback/mock data is used during development, add TODO comments and track removal in the backlog.

---

## Related Files

- `src/app/api/planning/financials/territory/route.ts`
- `src/app/api/planning/financials/apac/route.ts`
- `src/app/api/planning/ai/insights/route.ts`
- `src/app/api/planning/ai/next-best-actions/route.ts`
- `src/app/api/planning/ai/generate-plan/route.ts`
- `src/app/api/planning/ai/meddpicc/route.ts`
- `src/lib/planning-ai.ts` (library functions)
