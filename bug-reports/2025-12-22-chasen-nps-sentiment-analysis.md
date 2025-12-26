# Feature: ChaSen AI NPS Sentiment Analysis

**Date**: 2025-12-22
**Type**: Feature Implementation
**Status**: COMPLETE

---

## Feature Summary

Added AI-powered sentiment analysis to the NPS Trends Modal using ChaSen (via MatchaAI API). The feature analyses NPS feedback comments, groups sentiment by survey cycle, and provides cross-cycle comparison insights.

## Implementation Details

### New API Endpoint

**File**: `src/app/api/chasen/nps-sentiment/route.ts`

A new POST endpoint that:

- Accepts client name and NPS feedback data
- Filters feedbacks that have written comments
- Sends prompt to MatchaAI for AI-powered sentiment analysis
- Returns structured sentiment data including:
  - Overall sentiment score (-1 to 1 scale)
  - Sentiment by NPS cycle with distribution charts
  - Individual comment-level sentiment scoring
  - Key themes and insights
  - Cross-cycle comparison summary

### UI Updates

**File**: `src/components/ClientNPSTrendsModal.tsx`

Updated the "Sentiment Analysis" tab to:

- Fetch sentiment analysis from ChaSen when tab is selected (lazy loading)
- Display ChaSen branding badge
- Show overall sentiment score with visual progress bar
- Display sentiment trend indicator (improving/stable/declining)
- Show cycle-by-cycle sentiment breakdown with:
  - Distribution bars (positive/neutral/negative)
  - Response counts
  - Top themes
  - Summary text
- Display individual comment sentiments with colour-coding
- Show key insights from AI analysis
- Display cross-cycle comparison summary
- **Export PDF button** for detailed sentiment reports

### PDF Export Utility

**File**: `src/lib/sentiment-export.ts`

A comprehensive PDF export module that generates detailed sentiment reports:

- ChaSen AI branded header with orange colour scheme
- Executive summary with overall sentiment score, trend, and category
- NPS context section (current NPS, promoters, passives, detractors)
- Key insights from AI analysis with numbered list
- Cycle-by-cycle breakdown with:
  - Sentiment distribution bars (positive/neutral/negative)
  - Response counts and percentages
  - Top themes for each cycle
  - Summary text
- Detailed comment-level analysis with:
  - Individual sentiment scoring
  - Colour-coded comment cards
  - Key themes per comment
- Professional footer with page numbers and confidentiality notice

## Technical Details

### Sentiment Scoring Guidelines

| Category | Score Range  | Indicators                                         |
| -------- | ------------ | -------------------------------------------------- |
| Positive | 0.3 to 1.0   | Praise, satisfaction, gratitude, enthusiasm        |
| Neutral  | -0.3 to 0.3  | Mixed feedback, factual statements, mild concerns  |
| Negative | -1.0 to -0.3 | Complaints, frustration, disappointment, criticism |

### Key Themes Identified

- Support Quality
- Response Time
- Product Functionality
- Communication
- Training/Onboarding
- Value/ROI
- Staff/Team Experience
- Implementation Issues

### API Response Structure

```typescript
interface SentimentResponse {
  overallSentiment: number // -1 to 1
  overallCategory: 'positive' | 'neutral' | 'negative'
  totalAnalysed: number
  commentSentiments: CommentSentiment[]
  cycleSentiments: CycleSentiment[]
  sentimentTrend: 'improving' | 'declining' | 'stable'
  keyInsights: string[]
  comparisonSummary: string
}
```

## Files Modified

1. **`src/app/api/chasen/nps-sentiment/route.ts`** (NEW)
   - ChaSen sentiment analysis API endpoint
   - MatchaAI integration with Claude Sonnet 4 model

2. **`src/components/ClientNPSTrendsModal.tsx`** (UPDATED)
   - Added ChaSen sentiment types and state management
   - Lazy-loading of sentiment analysis on tab selection
   - New sentiment visualisation UI components
   - Export PDF button with loading state

3. **`src/lib/sentiment-export.ts`** (NEW)
   - PDF generation for sentiment analysis reports
   - Uses jsPDF for dynamic PDF creation
   - Includes all sentiment data in professional layout

## Commits

1. **Hash**: `bef3c09`
   **Message**: "Add ChaSen AI sentiment analysis to NPS modal"

2. **Hash**: `f2d7262`
   **Message**: "Add sentiment analysis PDF export function"

## Usage

1. Navigate to any client's NPS data (from dashboard or client profile)
2. Click to open the NPS Trends Modal
3. Select the "Sentiment Analysis" tab
4. ChaSen will automatically analyse all feedback comments
5. View sentiment by cycle, individual comments, and key insights
6. Click **Export PDF** to download a detailed sentiment report

## Notes

- Sentiment analysis only works when feedback comments are available
- The API uses MatchaAI with mission ID 1397 and Claude Sonnet 4 (model ID 28)
- Analysis is performed once per modal open (cached in component state)
- British/Australian English is used in AI responses
