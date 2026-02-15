# Bug Report: Priority Matrix - Persistence, Duplicates, and Quadrant Labelling

**Date:** 2025-12-15
**Status:** RESOLVED
**Commit:** cb02984

## Issues Reported

### Issue 1: Drag-and-Drop Positions Not Persisting

**Symptom:** When users drag items to a new quadrant, the changes revert upon page refresh.

**Root Cause:** The MatrixContext only maintained item positions in React state, with no persistence layer.

**Solution:** Implemented localStorage-based persistence:

- Added `STORAGE_KEY` constant for localStorage key
- Created `loadPersistedPositions()` to retrieve saved positions
- Created `savePosition()` to save position changes
- Created `applyPersistedPositions()` to merge saved positions with initial items
- Updated `MatrixProvider` to apply persisted positions on initialisation
- Updated `moveItem` callback to persist position changes

### Issue 2: Duplicate Recommendation Cards in Delegate Quadrant

**Symptom:** AI recommendations appearing multiple times for different clients (e.g., "Leverage positive relationship for case study" shown twice, "Sustain improvement momentum" shown three times).

**Root Cause:** Each client with the same recommendation type generated a separate card, rather than consolidating into a single card with multiple clients.

**Solution:** Modified `aiRecommendationsToMatrixItems()` in utils.ts:

- Group recommendations by title using a Map
- Consolidate multiple clients into single cards
- Display client count in title (e.g., "Recommendation Title (3 clients)")
- Stack client logos using ClientLogoStack component
- Calculate average confidence across all grouped recommendations
- Combine rationales in description

### Issue 3: Misleading Quadrant Label

**Symptom:** The "Delegate" quadrant was labelled "Urgent, Not Important" which implied items should be deprioritised, when they actually represent valuable engagement opportunities.

**Root Cause:** Original Eisenhower Matrix terminology wasn't appropriate for the CS Connect use case.

**Solution:** Updated quadrant configuration in types.ts:

- Changed title from "DELEGATE" to "OPPORTUNITIES"
- Changed subtitle from "Urgent, Not Important" to "Relationship & Engagement"
- Updated `getQuadrantLabel()` in DetailHeader.tsx for consistency

## Files Modified

| File                                                     | Changes                                                    |
| -------------------------------------------------------- | ---------------------------------------------------------- |
| `src/components/priority-matrix/MatrixContext.tsx`       | Added localStorage persistence (47 lines added)            |
| `src/components/priority-matrix/utils.ts`                | Consolidated duplicate recommendations (68 lines modified) |
| `src/components/priority-matrix/types.ts`                | Renamed Delegate quadrant labels                           |
| `src/components/priority-matrix/detail/DetailHeader.tsx` | Updated getQuadrantLabel function                          |

## Testing Verification

1. **Persistence Test:**
   - Drag an item to a different quadrant
   - Refresh the page
   - Verify item remains in the new quadrant

2. **Consolidation Test:**
   - View the Opportunities (formerly Delegate) quadrant
   - Verify recommendations are consolidated by title
   - Verify client logos are stacked for multi-client items
   - Verify client count shows in title

3. **Label Test:**
   - Verify "OPPORTUNITIES" heading displays correctly
   - Verify "Relationship & Engagement" subtitle displays
   - Verify detail panel shows correct quadrant label

## Related Commits

- Previous: `394503c` - Added ClientLogoStack component and detail panel improvements
- Current: `cb02984` - Persistence, consolidation, and quadrant rename
