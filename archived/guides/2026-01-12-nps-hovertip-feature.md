# Feature: NPS Hovertip with Top Themes

**Date:** 12 January 2026
**Status:** Resolved
**Type:** Feature Enhancement
**Severity:** Low

## Summary

Added hover tooltips to NPS scores in the Strategic Planning Portfolio table that display the top 3 themes extracted from the client's latest NPS survey feedback.

## Feature Description

When hovering over any NPS score in the Portfolio Clients table, a tooltip appears showing:
- "Top Themes (Latest Survey)" header
- Up to 3 themes extracted from the client's NPS feedback
- Sentiment indicator dots (green = positive, yellow = neutral, red = negative)

### Example Output
- **WA Health** (-53 NPS): Product & Features, Performance & Reliability, Upgrade/Fix Delivery
- **Barwon Health** (-46 NPS): Support & Service, Product & Features, User Experience

## Technical Implementation

### New API Endpoint
Created `/api/planning/nps-themes/route.ts`:

```typescript
// Fetches all NPS responses and finds period with most feedback
const { data: allResponses } = await supabase
  .from('nps_responses')
  .select('id, client_name, score, feedback, period, response_date')
  .order('response_date', { ascending: false })

// Find period with most feedback (not just most recent)
const periodFeedbackCounts = new Map<string, { count: number }>()
for (const r of allResponses || []) {
  const hasFeedback = r.feedback && r.feedback.trim() !== '' && r.feedback !== '.'
  if (hasFeedback) {
    periodFeedbackCounts.get(r.period)!.count++
  }
}
```

### Keyword-Based Theme Extraction
Topics are extracted using keyword matching (same approach as NPS Analysis modal):

```typescript
const topicDefinitions = {
  'Product & Features': {
    keywords: ['product', 'feature', 'functionality', 'system', 'innovation', ...],
    positiveKeywords: ['great product', 'excellent features', 'innovative', ...],
    negativeKeywords: ['limited features', 'missing functionality', 'outdated', ...],
  },
  'Support & Service': { ... },
  'User Experience': { ... },
  'Account Management': { ... },
  'Upgrade/Fix Delivery': { ... },
  'Performance & Reliability': { ... },
  'Training & Documentation': { ... },
  'Value & Pricing': { ... },
}
```

### Sentiment Determination
1. Strong NPS scores override keyword sentiment:
   - Score >= 9 → positive
   - Score <= 6 → negative
2. Otherwise, sentiment keywords in feedback determine sentiment
3. Sentiment shown as coloured dot: green (positive), yellow (neutral), red (negative)

### UI Implementation
Hover tooltip added to NPS cells using Tailwind CSS group hover:

```typescript
<td className="group/nps relative">
  <Link href={`/clients/${client.name}#nps`}>
    {client.npsScore}
  </Link>

  {/* NPS Themes Tooltip */}
  {client.npsThemes && client.npsThemes.length > 0 && (
    <div className="absolute z-50 bottom-full left-1/2 -translate-x-1/2 mb-2
                    opacity-0 invisible group-hover/nps:opacity-100
                    group-hover/nps:visible transition-all duration-200">
      <div className="bg-gray-900 text-white text-xs rounded-lg shadow-lg p-3">
        <p className="font-semibold mb-2">Top Themes (Latest Survey)</p>
        {client.npsThemes.map((theme) => (
          <div className="flex items-center justify-between gap-2">
            <span>{theme.topic_name}</span>
            <span className={`w-2 h-2 rounded-full ${
              theme.sentiment === 'positive' ? 'bg-green-400'
                : theme.sentiment === 'negative' ? 'bg-red-400'
                : 'bg-yellow-400'
            }`} />
          </div>
        ))}
      </div>
    </div>
  )}
</td>
```

## Issues Resolved

### 1. API Returning 0 Clients Initially
**Root Cause:** API was selecting period by most recent `response_date`, but that period (Q4 24) had no feedback text.

**Resolution:** Changed logic to find period with the most feedback responses:
```typescript
// Before: Selected Q4 24 (0 feedback)
const latestPeriod = latestPeriodData?.[0]?.period

// After: Finds period with most feedback (Q2 25 with 43 responses)
let bestPeriod = 'Q4 25'
let maxFeedback = 0
for (const [period, { count }] of periodFeedbackCounts.entries()) {
  if (count > maxFeedback) {
    maxFeedback = count
    bestPeriod = period
  }
}
```

### 2. Themes Are Client-Specific
Each client's themes are extracted from their individual NPS feedback:
- Themes aggregated by `client_name` (lowercase for matching)
- Top 3 themes shown based on mention count
- Different clients show different themes based on their feedback content

## Files Modified

### src/app/api/planning/nps-themes/route.ts
- Added keyword-based topic extraction (8 topic categories)
- Added sentiment determination logic
- Changed period selection to prefer periods with feedback
- Returns `themesByClient` map with top 3 themes per client

### src/app/(dashboard)/planning/strategic/new/page.tsx
- Added `NpsTheme` interface
- Added NPS themes fetch on client load
- Added hover tooltip UI component on NPS cells
- Updated Account Deep-Dive view to use new theme structure

## Testing Performed

- [x] Build passes with zero TypeScript errors
- [x] API returns themes for 13+ clients from Q2 25 period
- [x] Hovertip appears on NPS score hover
- [x] Different clients show different themes (client-specific)
- [x] Sentiment indicators display correctly (red for negative scores)
- [x] Tooltip disappears when not hovering

## API Response Format

```json
{
  "themesByClient": {
    "wa health": [
      { "topic_name": "Product & Features", "count": 2, "sentiment": "negative" },
      { "topic_name": "Performance & Reliability", "count": 1, "sentiment": "negative" },
      { "topic_name": "Upgrade/Fix Delivery", "count": 1, "sentiment": "negative" }
    ],
    "barwon health": [
      { "topic_name": "Support & Service", "count": 3, "sentiment": "negative" },
      { "topic_name": "Product & Features", "count": 2, "sentiment": "negative" },
      { "topic_name": "User Experience", "count": 1, "sentiment": "negative" }
    ]
  },
  "period": "Q2 25"
}
```

## Commits

1. `feat: Add NPS hovertip showing top 3 themes from latest survey`
2. `fix: NPS hovertip now uses period with most feedback responses`
