# Bug Report: Territory Strategy Page Ternary Operator Syntax Errors

**Date**: 2026-01-09
**Severity**: Critical (Build Blocking)
**Component**: `/src/app/(dashboard)/planning/territory/[id]/page.tsx`
**Status**: FIXED

## Summary

The territory strategy detail page contained multiple JSX syntax errors related to ternary operator formatting. These errors prevented the Next.js build from completing successfully.

## Root Cause

In four locations within the file, ternary operators for conditional rendering had incorrect indentation, causing the parser to interpret `) : (` as an unterminated regular expression literal rather than a ternary continuation.

**Error Pattern:**
```tsx
// INCORRECT - causes "Unterminated regexp literal" error
                  </>
                  ) : (
                    <p>No data</p>
                  )}
```

**Correct Pattern:**
```tsx
// CORRECT - proper indentation alignment
                  </>
                ) : (
                  <p>No data</p>
                )}
```

## Affected Lines

The following lines were fixed:

1. **Lines 645-648** - Portfolio Overview ternary
2. **Lines 746-748** - Revenue Targets ternary
3. **Lines 803-805** - Opportunities ternary
4. **Lines 867-869** - Risks ternary

## Fix Applied

Corrected the indentation of ternary operator continuations to align with their opening conditions. Each `) : (` was moved 2 spaces to the left to properly match the corresponding conditional expression.

## Verification

- TypeScript compilation passes without errors for the fixed file
- All JSX ternary operators now have consistent and correct formatting

## Prevention

- Enable ESLint rules for JSX formatting consistency
- Consider using Prettier for automatic code formatting
- Review ternary operators during code review for proper alignment

## Related Changes

This fix was discovered while implementing the APAC Planning Command Centre dashboard. No functionality was changed - only whitespace formatting was corrected.
