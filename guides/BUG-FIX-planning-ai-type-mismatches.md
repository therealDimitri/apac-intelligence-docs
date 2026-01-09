# Bug Fix: Planning AI Type Mismatches in Account Plan Page

## Date
2025-01-09

## Issue Description
When integrating the `usePlanningAI` hook into the Account Plan page (`/planning/account/new`), several TypeScript type mismatches were discovered between the UI code and the actual Planning AI type definitions.

## Root Cause
The Planning AI library (`src/lib/planning-ai.ts`) defines specific type interfaces that differ from what was assumed in the UI implementation:

1. **MEDDPICCAnalysis**: Has `overallCompleteness` (not `overallScore`)
2. **MEDDPICCElement**: Has `status: 'identified' | 'partial' | 'unknown'` (not a numeric `score`)
3. **StakeholderSuggestion**: Has `suggestedStakeholders` array (not `stakeholders`)
4. **Stakeholder (Planning AI)**: Different properties than the local `Stakeholder` interface

## Files Affected
- `src/app/(dashboard)/planning/account/new/page.tsx`

## Fix Applied

### 1. MEDDPICC Tab - Fixed property names
**Before:**
```typescript
{planningAI.meddpicc.data && (
  <p>{planningAI.meddpicc.data.overallScore}% Complete</p>
  {Object.entries(elements).map(([key, element]) => (
    <span>{element.score}%</span>
  ))}
)}
```

**After:**
```typescript
{planningAI.meddpicc.data && (
  <p>{planningAI.meddpicc.data.overallCompleteness}% Complete</p>
  {Object.entries(elements).map(([key, element]) => (
    <span className={statusColors[element.status]}>
      {statusIcons[element.status]} {/* ✓, ~, or ? */}
    </span>
  ))}
)}
```

### 2. Stakeholders Tab - Fixed array name and property mapping
**Before:**
```typescript
{planningAI.stakeholders.data.stakeholders?.slice(0, 5).map((s) => (
  <p>{s.role} • {s.influence}</p>
  const newStakeholder = {
    title: s.title || '',
    notes: s.context || '',
  }
))}
```

**After:**
```typescript
{planningAI.stakeholders.data.suggestedStakeholders?.slice(0, 5).map((s) => (
  <p>{s.role || 'Unknown role'} • {s.influence}</p>
  const roleMap = {
    'decision-maker': 'economic_buyer',
    'influencer': 'influencer',
    'user': 'user',
    'unknown': 'influencer',
  }
  const newStakeholder = {
    title: s.role || '',  // Using role as title
    role: roleMap[s.influence] || 'influencer',  // Map influence to local role
    notes: s.notes || '',  // Using notes (not context)
  }
))}
```

## Prevention
- Always verify type definitions in `src/lib/planning-ai.ts` before implementing UI code
- Run `npm run build` after making changes to catch type errors early
- Consider using IDE hover-for-types to inspect actual interface properties

## Testing
- Build passes: `npm run build` ✓
- Type checking passes: No TypeScript errors
- Pre-commit hooks pass: ESLint, Prettier, TypeScript check all successful

## Related Commits
- `8ac5130b`: feat: Integrate usePlanningAI hook into Account Plan page
