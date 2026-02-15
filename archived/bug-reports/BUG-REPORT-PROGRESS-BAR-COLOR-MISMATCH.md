# Bug Report: Progress Bar Color Mismatch - Healthy Clients Showing Yellow Instead of Green

**Date:** 2025-11-27
**Severity:** High (Visual Consistency / UX)
**Status:** ✅ Fixed
**Affected Component:** Client Health Page (src/app/(dashboard)/clients/page.tsx)
**Related Commits:** 390f2c9

---

## User Report

**Original Report:**

> "[Image #1] Review and diagnose issue where clients with a Healthly health score are being displayed with a yellow progress bar on the Client Health page. Shouldnt it be green?"

**Context:**
User noticed that clients classified as "healthy" (with green status badges) were displaying yellow progress bars instead of green, creating visual inconsistency and confusion about client status.

**Screenshot Evidence:**
User provided screenshot showing:

- Client with "healthy" status badge (green)
- Same client with yellow progress bar
- Visual inconsistency between status indicator and progress bar colour

---

## Root Cause Analysis

### The Problem

**Visual Inconsistency:**
Client Health page displayed two status indicators per client:

1. **Status Badge** - Text label with coloured background (e.g., "healthy" in green)
2. **Progress Bar** - Horizontal bar showing health score fill with colour

These two indicators used DIFFERENT threshold values for colour assignment, causing misalignment.

### Health Score Classification System

**Source:** `src/hooks/useClients.ts` Lines 189-192

```typescript
// Determine status based on improved thresholds
let status: 'healthy' | 'at-risk' | 'critical' = 'at-risk'
if (healthScore >= 75) status = 'healthy'
else if (healthScore < 50) status = 'critical'
// 50-74 = at-risk
```

**Official Thresholds:**

- **Healthy:** ≥75
- **At-Risk:** 50-74
- **Critical:** <50

### Progress Bar Color Thresholds (BEFORE FIX)

**Source:** `src/app/(dashboard)/clients/page.tsx` Lines 333-335 (BEFORE)

```typescript
className={`h-full ${
  client.health_score >= 80 ? 'bg-green-500' :
  client.health_score >= 60 ? 'bg-yellow-500' :
  'bg-red-500'
}`}
```

**Incorrect Thresholds:**

- **Green:** ≥80
- **Yellow:** ≥60
- **Red:** <60

### The Discrepancy

| Health Score | Status (Correct) | Badge Color | Progress Bar (Before Fix) | Visual Mismatch? |
| ------------ | ---------------- | ----------- | ------------------------- | ---------------- |
| 75-79        | Healthy          | Green       | Yellow ❌                 | **YES - BUG**    |
| 80-100       | Healthy          | Green       | Green ✅                  | No               |
| 60-74        | At-Risk          | Yellow      | Yellow ✅                 | No (coincidence) |
| 50-59        | At-Risk          | Yellow      | Red ❌                    | **YES - BUG**    |
| <50          | Critical         | Red         | Red ✅                    | No               |

**Example of Bug:**

```
Client: Epworth Healthcare
Health Score: 77
Status: "healthy" (77 ≥ 75) ✅
Status Badge: Green background with "healthy" text ✅
Progress Bar: 77 < 80, so bg-yellow-500 ❌

Result: User sees GREEN badge but YELLOW bar - confusing!
```

---

## Impact Assessment

### User Experience Impact

**Before Fix:**

- ❌ Visual inconsistency between status badge and progress bar
- ❌ Healthy clients (scores 75-79) showed yellow bars, appearing "at-risk"
- ❌ At-risk clients (scores 50-59) showed red bars, appearing "critical"
- ❌ User confusion about what colours mean
- ❌ Reduced trust in dashboard data accuracy
- ❌ Misalignment with industry-standard green/yellow/red health indicators

**After Fix:**

- ✅ Visual consistency across all status indicators
- ✅ All healthy clients show green progress bars
- ✅ All at-risk clients show yellow progress bars
- ✅ All critical clients show red progress bars
- ✅ Intuitive colour coding matches user expectations
- ✅ Professional appearance aligned with dashboard design standards

### Data Accuracy Impact

**Important Note:** This was purely a visual/UX bug. The underlying health score calculations and status classifications were CORRECT. Only the progress bar colour assignment logic was wrong.

- ✅ Health scores were calculated correctly
- ✅ Status badges showed correct classification
- ❌ Progress bars showed incorrect colours

---

## Fix Applied

### Code Changes

**File:** `src/app/(dashboard)/clients/page.tsx`
**Lines:** 333-335

**BEFORE (INCORRECT):**

```typescript
<div
  className={`h-full ${
    client.health_score >= 80 ? 'bg-green-500' :
    client.health_score >= 60 ? 'bg-yellow-500' :
    'bg-red-500'
  }`}
  style={{ width: `${Math.min(100, Math.max(0, client.health_score))}%` }}
/>
```

**AFTER (CORRECT):**

```typescript
<div
  className={`h-full ${
    client.health_score >= 75 ? 'bg-green-500' :
    client.health_score >= 50 ? 'bg-yellow-500' :
    'bg-red-500'
  }`}
  style={{ width: `${Math.min(100, Math.max(0, client.health_score))}%` }}
/>
```

### Changes Summary

| Threshold | Before | After | Status                                    |
| --------- | ------ | ----- | ----------------------------------------- |
| Green     | ≥80    | ≥75   | ✅ Aligned with "healthy" classification  |
| Yellow    | ≥60    | ≥50   | ✅ Aligned with "at-risk" classification  |
| Red       | <60    | <50   | ✅ Aligned with "critical" classification |

---

## Testing Verification

### Test Cases

**Test 1: Healthy Client (Score 75)**

- Input: health_score = 75
- Expected: Green progress bar
- Before Fix: Yellow progress bar ❌
- After Fix: Green progress bar ✅

**Test 2: Healthy Client (Score 77)**

- Input: health_score = 77
- Expected: Green progress bar
- Before Fix: Yellow progress bar ❌
- After Fix: Green progress bar ✅

**Test 3: Healthy Client (Score 80)**

- Input: health_score = 80
- Expected: Green progress bar
- Before Fix: Green progress bar ✅ (coincidentally correct)
- After Fix: Green progress bar ✅

**Test 4: At-Risk Client (Score 50)**

- Input: health_score = 50
- Expected: Yellow progress bar
- Before Fix: Red progress bar ❌
- After Fix: Yellow progress bar ✅

**Test 5: At-Risk Client (Score 55)**

- Input: health_score = 55
- Expected: Yellow progress bar
- Before Fix: Red progress bar ❌
- After Fix: Yellow progress bar ✅

**Test 6: At-Risk Client (Score 65)**

- Input: health_score = 65
- Expected: Yellow progress bar
- Before Fix: Yellow progress bar ✅ (coincidentally correct)
- After Fix: Yellow progress bar ✅

**Test 7: Critical Client (Score 45)**

- Input: health_score = 45
- Expected: Red progress bar
- Before Fix: Red progress bar ✅
- After Fix: Red progress bar ✅

**Test 8: Critical Client (Score 25)**

- Input: health_score = 25
- Expected: Red progress bar
- Before Fix: Red progress bar ✅
- After Fix: Red progress bar ✅

### User Acceptance Testing

**Checklist for User:**

- [ ] Navigate to Client Health page (/clients)
- [ ] Locate clients with "healthy" status badge (green)
- [ ] Verify ALL healthy clients show GREEN progress bars
- [ ] Locate clients with "at-risk" status badge (yellow)
- [ ] Verify ALL at-risk clients show YELLOW progress bars
- [ ] Locate clients with "critical" status badge (red)
- [ ] Verify ALL critical clients show RED progress bars
- [ ] Verify visual consistency between badge and progress bar colours
- [ ] Confirm no yellow bars appear for healthy clients

---

## Build Verification

**Build Command:** `npm run build`

**Build Status:** ✅ PASSED

**TypeScript Compilation:** ✅ No errors

**Static Generation:** ✅ All 17 pages generated successfully

**Deployment:** ✅ Deployed to production (commit 390f2c9)

---

## Lessons Learned

### 1. Visual Consistency is Critical for UX

When multiple UI elements represent the same data (status badge + progress bar), they MUST use identical thresholds. Users rely on visual consistency to understand data at a glance.

### 2. Threshold Centralization

**Problem:** Thresholds were defined in two places:

- Health score classification: `useClients.ts`
- Progress bar colours: `clients/page.tsx`

**Future Improvement:** Consider creating a centralized constant:

```typescript
// src/constants/health-thresholds.ts
export const HEALTH_THRESHOLDS = {
  HEALTHY_MIN: 75,
  AT_RISK_MIN: 50,
  CRITICAL_MAX: 49,
} as const
```

Then import and use in both locations to ensure consistency.

### 3. Visual Testing is Essential

This bug would have been caught with visual regression testing or manual UX review. The status badge and progress bar should have been tested together as a unit.

### 4. Documentation of Design Decisions

The health score thresholds (75/50) should be documented in a design spec or README so developers implementing UI components know the exact values to use.

### 5. User Feedback is Invaluable

User quickly identified the visual inconsistency, demonstrating the importance of user testing and feedback channels.

---

## Prevention Strategy

### Short-Term (Implemented)

✅ Fixed progress bar thresholds to match health score classification
✅ Deployed fix to production
✅ Created bug report documentation

### Medium-Term (Recommended)

- [ ] Create centralized health threshold constants file
- [ ] Refactor both useClients.ts and clients/page.tsx to import constants
- [ ] Add visual regression tests for colour-coded UI elements
- [ ] Document health score thresholds in project README
- [ ] Add unit tests for colour threshold logic

### Long-Term (Ideal)

- [ ] Implement automated visual testing (e.g., Chromatic, Percy)
- [ ] Create design system documentation for colour usage
- [ ] Establish UI component library with standardized health indicators
- [ ] Add ESLint rule to prevent hardcoded threshold values
- [ ] Create Storybook stories for all status indicator variations

---

## Related Issues

### Related Fixes in This Session

- **Commit 8f5b603:** Fixed NPS calculation bug (averaging vs. proper NPS formula)
- **Commit dd1cddf:** Removed non-functional "Add Client" button
- **Commit 390f2c9:** Fixed progress bar colour thresholds (this bug)

### Related Documentation

- `docs/BUG-REPORT-NPS-METRICS-FINAL-FIX.md` - NPS calculation improvements
- `docs/FEATURE-AI-INSIGHTS-ACCORDION.md` - Health score breakdown accordion
- `src/hooks/useClients.ts` - Health score calculation algorithm (lines 116-193)

---

## Conclusion

This bug demonstrated the importance of visual consistency in dashboards. While the underlying data was correct, the misaligned colour thresholds created user confusion and undermined trust in the dashboard.

The fix was simple (2 line change) but critical for user experience. All status indicators now use consistent thresholds:

- **Healthy:** ≥75 → Green
- **At-Risk:** 50-74 → Yellow
- **Critical:** <50 → Red

**Status:** ✅ Fixed and deployed to production (commit 390f2c9)

---

**Documentation Completed:** 2025-11-27
**Bug Report Author:** Claude Code
