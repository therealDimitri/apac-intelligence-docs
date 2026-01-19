# Bug Fix: Planning Hub Enhancements - Batch 2

**Date**: 2026-01-19
**Type**: Enhancement / UI Improvements
**Status**: RESOLVED

---

## Issues Fixed

### 1. Focus Deal Column Added to Plan Coverage and Opportunity Qualification
**Problem**: No way to identify focus deals in the Plan Coverage and Opportunity Qualification tables.

**Fix**: Added "Focus" column with orange badge after the Stage column in both tables.

```typescript
{/* Focus Deal Badge */}
<div className="flex justify-center">
  {opp.is_focus_deal && (
    <span className={`text-[10px] px-1.5 py-0.5 rounded font-semibold ${
      isIncluded ? 'bg-orange-100 text-orange-700' : 'bg-gray-100 text-gray-500'
    }`} title="Focus Deal">Focus</span>
  )}
</div>
```

### 2. Quarter and Close Date Column Order Swapped
**Problem**: Quarter column was after Close Date, making date comparisons harder.

**Fix**: Swapped column order so Quarter appears before Close Date for better readability.

**Column Order (new)**:
1. Name
2. Forecast
3. Stage
4. Focus
5. **Qtr** (moved before Close Date)
6. **Close Date** (moved after Qtr)
7. Total ACV
8. Weighted ACV
9. Probability

### 3. Opportunity Qualification Table Harmonised with Plan Coverage
**Problem**: Opportunity Qualification had different column headings and missing Qtr column.

**Fix**:
- Added Qtr column to Opportunity Qualification
- Updated column headings to match Plan Coverage table:
  - Stage → Stage (consistent)
  - Close → Close Date
  - ACV → Total ACV
  - Weighted → Weighted ACV

### 4. AI Suggestions Grouped by Methodology with Collapsible Sections
**Problem**: AI suggestions were a flat list, making it hard to navigate and causing cognitive overload.

**Fix**:
- Group suggestions by methodology (MEDDPICC, StoryBrand, Other)
- Add collapsible section headers for each methodology group
- Make field labels bold for better visibility
- Colour-coded headers (blue for MEDDPICC, purple for StoryBrand, grey for Other)

```typescript
const MEDDPICC_FIELDS = ['metrics', 'economic_buyer', 'decision_criteria', 'decision_process', 'paper_process', 'implicate_pain', 'champion', 'competition']

const STORYBRAND_FIELDS = ['problem', 'empathy', 'authority', 'plan', 'call_to_action', 'success', 'failure', 'guide', 'hero']

const METHODOLOGY_CONFIG = {
  MEDDPICC: { label: 'MEDDPICC', colour: 'text-blue-700', bgColour: 'bg-blue-50' },
  StoryBrand: { label: 'StoryBrand', colour: 'text-purple-700', bgColour: 'bg-purple-50' },
  Other: { label: 'General', colour: 'text-gray-700', bgColour: 'bg-gray-50' },
}
```

### 5. VOSS Tactical Empathy Training Added to Planning Education Centre
**Problem**: No training content for VOSS (Chris Voss) methodology.

**Fix**: Added comprehensive VOSS Tactical Empathy training section with:
- **Labeling**: Using "It seems like..." to acknowledge emotions
- **Mirroring**: Repeating last words to encourage elaboration
- **Calibrated Questions**: "How" and "What" questions for discovery
- **Accusation Audit**: Preempting negatives to build credibility
- **Getting to "That's Right"**: True understanding signals
- **Black Swan Hunting**: Finding hidden motivators

### 6. StoryBrand SB7 Framework Training Added
**Problem**: No training content for StoryBrand methodology.

**Fix**: Added StoryBrand SB7 Framework training section with:
- **The Client is the Hero**: Positioning guide vs hero
- **Problem, Empathy, Authority**: Core framework elements
- **The Plan**: Simple 3-step plan guidance
- **Call to Action & Stakes**: Clear next steps and consequences

## Files Modified

| File | Changes |
|------|---------|
| `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx` | Focus Deal column, Qtr/Close Date swap, Opportunity Qualification harmonisation |
| `src/components/planning/methodology/AIPrePopulation.tsx` | Methodology grouping, collapsible sections, bold labels |
| `src/app/(dashboard)/planning/page.tsx` | VOSS and StoryBrand training sections, amber/orange colour options |

## Testing

- [x] Build passes (`npm run build`)
- [x] TypeScript compilation successful
- [x] ESLint passes
- [x] Focus Deal badge displays correctly
- [x] Qtr column appears before Close Date
- [x] Opportunity Qualification headings match Plan Coverage
- [x] AI suggestions grouped by methodology
- [x] Methodology sections collapse/expand correctly
- [x] VOSS training section expands with correct content
- [x] StoryBrand training section expands with correct content

## Commits

- `17197bb1` - Improve AI suggestions with methodology grouping and collapsible sections
- `c6b2e3f7` - Add VOSS and StoryBrand methodology training to Planning Education Centre

## Related Commits (from earlier session)

- Focus Deal column, Qtr/Close Date swap, and Opportunity Qualification harmonisation were part of a previous commit
