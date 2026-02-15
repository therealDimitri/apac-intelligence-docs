# Feature Report: Opportunities Card-Based Selection Redesign

**Date:** 11 January 2026
**Component:** Planning Hub / Territory Strategy / Top Opportunities
**Status:** Implemented

---

## Summary

The Top Opportunities step in Territory Strategy planning has been redesigned with a modern card-based selection interface, inspired by best practices from Salesforce, Clari, HubSpot, and Gong. CSEs can now select up to 5 priority opportunities from their pipeline with visual feedback and expandable MEDDPICC scoring.

---

## Before vs After

### Before (List-Based Import)
- Table list view with Import buttons
- No selection limit
- MEDDPICC scoring always visible
- No visual indication of priority

### After (Card-Based Selection)
- Card grid with visual selection state
- Maximum 5 opportunities limit
- MEDDPICC scoring only for selected items (expandable)
- Progress bar showing selection count
- Sort controls for quick prioritisation

---

## New Features

### 1. Selection Summary (Sticky Header)
- **X/5 Selected** counter with visual progress bar
- **Total Selected Value** displaying sum of selected weighted ACV
- **Avg MEDDPICC Score** calculated across selected opportunities

### 2. Sort Controls
| Sort Option | Description |
|-------------|-------------|
| Highest Value | Default - sorts by weighted ACV descending |
| Closest to Close | Sorts by expected close date ascending |
| Stage | Groups by sales stage (Discover → Qualify → Develop → Prove → Negotiate → Implement) |

### 3. Opportunity Cards
Each card displays:
- Stage badge (colour-coded)
- Weighted ACV value
- Opportunity name
- Client/Account name
- Expected close date

**Selected State:**
- Blue border and subtle background
- Checkmark icon
- Expandable MEDDPICC scoring section

### 4. MEDDPICC Scoring (Selected Only)
Progressive disclosure pattern - scoring only shows for selected opportunities:
- M: Metrics (0-10)
- E: Economic Buyer (0-10)
- D: Decision Criteria (0-10)
- D: Decision Process (0-10)
- P: Paper Process (0-10)
- I: Identify Pain (0-10)
- C: Champion (0-10)
- C: Competition (0-10)

---

## Design Rationale

### Research Sources
- **Salesforce**: Pipeline inspection UI with card views
- **Clari**: Forecast grid with selection capabilities
- **HubSpot**: Deal board with drag-select functionality
- **Gong**: Deal qualification with progressive disclosure

### Key Principles Applied
1. **Visual Selection State** - Clear feedback when opportunity is selected
2. **Max Limit Enforcement** - 5 opportunity cap prevents scope creep
3. **Progressive Disclosure** - MEDDPICC only shows when relevant
4. **Sort Before Select** - Easy to find highest priority opportunities
5. **Sticky Summary** - Always visible selection progress

---

## User Experience Flow

```
Open Top Opportunities Step
     ↓
View opportunity cards sorted by Highest Value (default)
     ↓
Click card to select (max 5)
     ↓
Progress bar updates (e.g., "3/5 Selected")
     ↓
Click "Score MEDDPICC" on selected card
     ↓
Expand inline scoring form
     ↓
Continue to next step with top 5 prioritised
```

---

## Technical Implementation

### New State Variables
```typescript
const [opportunitySortBy, setOpportunitySortBy] = useState<'value' | 'date' | 'stage'>('value')
const [expandedOppId, setExpandedOppId] = useState<string | null>(null)
```

### Selection Logic
```typescript
const MAX_SELECTIONS = 5

const handleOpportunitySelect = (opp: PipelineOpportunity) => {
  const isSelected = selectedOpportunityIds.includes(opp.id)
  if (isSelected) {
    // Always allow deselection
    setSelectedOpportunityIds(prev => prev.filter(id => id !== opp.id))
  } else if (selectedOpportunityIds.length < MAX_SELECTIONS) {
    // Only allow selection if under limit
    setSelectedOpportunityIds(prev => [...prev, opp.id])
  }
}
```

### Stage Colour Mapping
```typescript
const stageColors: Record<string, string> = {
  'Discover': 'bg-gray-100 text-gray-700',
  'Qualify': 'bg-blue-100 text-blue-700',
  'Develop': 'bg-indigo-100 text-indigo-700',
  'Prove': 'bg-purple-100 text-purple-700',
  'Negotiate': 'bg-amber-100 text-amber-700',
  'Implement': 'bg-green-100 text-green-700',
}
```

---

## Files Changed

- `src/app/(dashboard)/planning/territory/new/page.tsx`
  - Added `ChevronDown` to lucide-react imports
  - Added `opportunitySortBy` and `expandedOppId` state variables
  - Replaced `renderOpportunitiesStep` function with card-based UI
  - Implemented sort controls
  - Added selection summary with progress bar
  - Added expandable MEDDPICC scoring

---

## Testing

1. Build verification: `npm run build` passes
2. Select up to 5 opportunities - 6th selection blocked
3. Sort by value, date, stage works correctly
4. MEDDPICC expand/collapse works
5. Selection summary updates in real-time
6. Deselection works from any state

---

## Commits

```
feat(planning): Redesign opportunities step with card-based selection UI
Commit: 3956a1a6
- Implement Salesforce/Clari-inspired card selection interface
- Add "Top 5 Opportunities" selection with max limit enforcement
- Create sticky selection summary with progress bar
- Add sort controls: Highest Value, Closest to Close, Stage
- Display opportunity cards with stage badge, value, client, close date
- Show visual selection state with blue border/background and checkmark
- Add expandable MEDDPICC scoring for selected opportunities only
- Replace Import button with toggle selection pattern
```
