# Enhancement: Consolidated Recommended Actions Card

**Date:** 2026-01-02
**Status:** Implemented
**Severity:** Medium (Enhancement)
**Component:** Client Profile V2 - RightColumn

## User Request

> "Consolidate unique actions into 1 card rather than duplicate actions over 2 cards for all clients."

## Issue Description

Previously, the client profile displayed multiple overlapping recommendation sections:

1. **AI Recommendations Card** (Standalone) - Shown for medium risk predictions (0.3 < risk_score <= 0.6)
2. **AI Recommendations inside Compliance Risk Alert** - Shown for high risk predictions (> 0.6)
3. **Recommended Actions Card** - System-generated actions that included prediction-based items duplicating the AI recommendations

This caused:
- Redundant information across multiple cards
- Confusion about which recommendations to prioritise
- Duplicate prediction-based actions (e.g., "High risk of compliance miss" appearing in both AI Recommendations and Recommended Actions)

## Solution Implemented

Consolidated all recommendations into a **single unified "Recommended Actions" card**:

### Changes Made

1. **Removed standalone AI Recommendations card** (lines 748-776)
   - This card was shown for medium risk clients
   - Content now integrated into Recommended Actions

2. **Removed AI Recommendations section from Compliance Risk Alert** (lines 822-836)
   - The alert still shows risk score, predicted year-end, and risk factors
   - Recommendations moved to unified card

3. **Added AI recommendations to Recommended Actions card** (lines 960-973)
   - AI recommendations now appear first with purple styling (Sparkles icon)
   - Severity based on risk score: critical (>0.6), warning (0.3-0.6), info (<0.3)

4. **Removed duplicate prediction-based items**
   - Item 5: "High risk of compliance miss" - now covered by AI recommendations
   - Item 12: "Moderate compliance risk" - now covered by AI recommendations

5. **Updated card header**
   - Changed subtitle from "Prioritised by severity & impact" to "AI insights & actions prioritised by severity"

### Visual Result

The Recommended Actions card now displays:
- **Purple items**: AI-generated recommendations (Sparkles icon)
- **Red items**: Critical system alerts (AlertTriangle, Clock icons)
- **Yellow items**: Warning-level actions (DollarSign, Calendar, CheckCircle icons)
- **Blue items**: Informational suggestions (Lightbulb, Target icons)

All items sorted by severity (critical → warning → info).

## Files Modified

- `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`
  - Removed standalone AI Recommendations card
  - Removed AI Recommendations from Compliance Risk Alert
  - Added AI recommendations to actionItems array
  - Removed duplicate prediction-based items
  - Updated Recommended Actions header

## Code Changes Summary

```typescript
// BEFORE: Multiple separate sections
- AI Recommendations (standalone card)
- Compliance Risk Alert with AI Recommendations inside
- Recommended Actions with prediction-based items

// AFTER: Single consolidated card
Recommended Actions:
  - AI recommendations (purple, from prediction.recommended_actions)
  - Critical actions (red)
  - Warning actions (yellow)
  - Info actions (blue)
```

## Testing Verification

1. **TypeScript compilation**: Passes
2. **Visual verification**: Single Recommended Actions card displays all items
3. **No duplicates**: AI recommendations no longer appear in multiple places

## Benefits

1. **Cleaner UI**: One consolidated card instead of 2-3 separate sections
2. **No duplicate information**: Each recommendation appears once
3. **Clear prioritisation**: All items sorted by severity in a single view
4. **Consistent styling**: Purple for AI, red/yellow/blue for system-generated
