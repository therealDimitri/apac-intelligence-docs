# Bug Report: AI Recommendations Showing Generic Placeholder Text

**Date:** 31 January 2026
**Severity:** Medium
**Status:** Fixed
**Commit:** 3e8c4925

## Summary

The AI Recommendations page was displaying generic placeholder text instead of meaningful, context-aware reasoning for product and bundle recommendations.

## Problem

The recommendation reasons showed text like:

> "Comprehensive solution for healthcare organisations like Barwon Health Australia"

This generic text provided no insight into *why* the bundle or product was being recommended for the specific client.

## Root Cause

The `generateRecommendations()` function in the recommendations page was using a hardcoded template string instead of leveraging the rich metadata available in the `solution_bundles` and `product_catalog` data:

```typescript
// Before - generic placeholder text
reason: `Comprehensive solution for healthcare organisations like ${selectedClient.name}`,
```

## Fix Applied

Completely rewrote the recommendation logic to generate context-aware reasoning:

1. **Bundle recommendations** now include:
   - Bundle's `what_it_does` description or `tagline` for value proposition
   - Product-based reasoning ("Complements existing opal deployment")
   - Topic-based reasoning ("Addresses recent discussions about interoperability")
   - Health-status reasoning for at-risk clients
   - Market driver context ("Aligned with market trends: ED crowding crisis")

2. **Product recommendations** now include:
   - Product's elevator pitch
   - Topic match context ("Directly addresses interest in analytics")
   - Existing environment integration context

3. **Scoring algorithm** now considers:
   - Base score (50 points)
   - Product matches (+15 per match)
   - Topic matches (+10 per match)
   - Health status boost for at-risk clients (+10)

## Example Output

**Before:**
> "Comprehensive solution for healthcare organisations like Barwon Health Australia"

**After:**
> "Streamlines scheduling, documentation, billing, and referral management across ambulatory settings. Aligned with market trends: Shift to outpatient care."

## Files Changed

- `src/app/(dashboard)/sales-hub/recommendations/page.tsx` - Rewrote `generateRecommendations()` function with context-aware logic

## Testing

1. Navigated to `/sales-hub/recommendations`
2. Selected "Barwon Health Australia" client
3. Verified recommendations show detailed reasoning based on bundle metadata
4. Confirmed bundles display match percentages based on scoring algorithm

## Technical Notes

The recommendation engine now builds reasons from multiple data sources:

| Source | Usage |
|--------|-------|
| `bundle.what_it_does` | Primary value proposition |
| `bundle.tagline` | Fallback if no `what_it_does` |
| `bundle.market_drivers[]` | Market context alignment |
| `client.currentProducts[]` | Existing product integration |
| `client.recentTopics[]` | Discussion topic relevance |
| `client.health_status` | At-risk client suggestions |

## Prevention

When building recommendation or AI-assisted features:
- Never use placeholder text in production - always wire up to real data
- Leverage metadata fields (`what_it_does`, `tagline`, `elevator_pitch`) designed for this purpose
- Test with multiple client profiles to ensure context-awareness is visible
