# Bug Fix: Gap Discovery Confidence Scores Not Saving

**Date:** 2026-01-15
**Status:** Resolved
**Commit:** af0b2498

## Problem

Gap Discovery Confidence scores (the 5-point self-assessment questions in Step 2) were not persisting:
- User would set scores (1-5) for each question
- Scores would reset to 0 when navigating away and returning
- Auto-save every 30 seconds was not preserving the scores

Additionally, navigating between steps by clicking step icons did not trigger a save, potentially causing data loss.

## Root Cause

1. **Missing Database Column**: The `strategic_plans` table did not have a `methodology_data` column. The confidence scores were stored in React state (`formData.methodologyData`) but never persisted to the database.

2. **No Save on Step Change**: Clicking step icons or Previous/Next buttons called `setCurrentStep()` directly without triggering a save first.

## Solution

### 1. Database Migration

Added `methodology_data` JSONB column to store all methodology questionnaire data:

```sql
ALTER TABLE strategic_plans
ADD COLUMN IF NOT EXISTS methodology_data JSONB DEFAULT '{}';
```

### 2. Code Changes

**File:** `src/app/(dashboard)/planning/strategic/new/page.tsx`

1. **Save functions now include methodology_data**:
   ```typescript
   // In saveProgress() and handleSubmit()
   methodology_data: formData.methodologyData || {},
   ```

2. **Load function restores methodology_data**:
   ```typescript
   // In loadExistingPlan()
   methodologyData: data.methodology_data || undefined,
   ```

3. **New handleStepChange() function** saves before navigating:
   ```typescript
   const handleStepChange = async (newStep: number) => {
     if (formData.owner_name && planId) {
       saveProgress(true) // Silent auto-save
     }
     setCurrentStep(newStep)
   }
   ```

4. **Updated all step navigation** to use `handleStepChange()`:
   - Step icons in header
   - Previous button
   - Next button

## Data Structure

The `methodology_data` JSONB column stores:

```typescript
interface QuestionnaireDataV2 {
  discoveryDiagnosis?: {
    clients: ClientDiscoveryData[]
    confidenceScores: {
      understandProblems: number      // 0-5
      articulateFutureState: number   // 0-5
      quantifiedImpact: number        // 0-5
      understandRootCause: number     // 0-5
      knowCostOfInaction: number      // 0-5
    }
    totalScore: number               // Sum of above
    notes?: string
  }
  stakeholderIntelligence?: { ... }
  opportunityStrategy?: { ... }
  riskRecovery?: { ... }
  actionNarrative?: { ... }
}
```

## Testing

1. Navigate to `/planning/strategic/new`
2. Select an owner to enable saving
3. Go to Step 2 (Discovery & Diagnosis)
4. Set confidence scores for the 5 questions
5. Navigate to a different step by clicking step icon
6. Return to Step 2
7. Verify scores are preserved

## Files Changed

- `src/app/(dashboard)/planning/strategic/new/page.tsx` - Save/load/navigate logic
- `supabase/migrations/20260115_add_methodology_data_column.sql` - Database migration
