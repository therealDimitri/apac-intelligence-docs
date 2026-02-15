# Bug Report: Collaborator Name Not Displaying in Strategic Plan

**Date:** 12 January 2026
**Severity:** Medium
**Status:** Resolved

## Summary

When adding a collaborator to a strategic plan, the badge showed only the "x" (remove) button without displaying the collaborator's name.

## Symptoms

- Collaborator badge appeared as a small circular element with just "×"
- Name text was missing from the badge
- The collaborator was technically added but visually appeared empty

## Screenshot Reference

Badge displayed as: `[x]` instead of `[John Smith ×]`

## Root Cause

The collaborator selection handler did not properly validate for empty or whitespace-only strings:

1. **Whitespace-only names are truthy**: JavaScript considers `"   "` (spaces) as truthy, passing the `if (e.target.value)` check
2. **CSE profiles with empty names**: Some profiles in `cse_profiles` table may have null/empty/whitespace `full_name` values
3. **Index-based removal bug**: The removal logic used index which could mismatch when filtering

## Affected Component

`src/app/(dashboard)/planning/strategic/new/page.tsx` - Collaborators section (lines 876-922)

## Solution

Applied three defensive fixes:

### 1. Filter empty collaborators when rendering
```typescript
{formData.collaborators
  .filter(collab => collab && collab.trim()) // Filter out empty/whitespace names
  .map((collab, idx) => (
```

### 2. Trim values before adding
```typescript
onChange={e => {
  const value = e.target.value?.trim()
  if (value && !formData.collaborators.includes(value)) {
```

### 3. Filter profiles with valid names in dropdown
```typescript
{cseProfiles
  .filter(p => p.full_name && p.full_name.trim()) // Ensure profile has valid name
  .filter(p => p.full_name !== formData.owner_name)
```

### 4. Fixed removal logic
Changed from index-based to value-based filtering:
```typescript
// Before (could mismatch due to filtering)
collaborators: prev.collaborators.filter((_, i) => i !== idx)

// After (reliable matching)
collaborators: prev.collaborators.filter(c => c !== collab)
```

## Verification

1. Navigate to `/planning/strategic/new`
2. Select a CSE/CAM owner
3. Add a collaborator from the dropdown
4. Verify the collaborator's name displays in the badge
5. Click the "×" to remove and verify correct collaborator is removed

## Prevention

- Always trim string inputs before storing
- Use value-based filtering instead of index-based when the rendered list is filtered
- Add null/empty checks when iterating over database-sourced arrays

## Commit Reference

Included in commit: `6f4315ae`
