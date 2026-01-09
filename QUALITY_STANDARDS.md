# Quality Standards

**Status**: MANDATORY for all code changes
**Last Updated**: 9 January 2026
**Enforcement**: All developers must complete checklist before committing

---

## Purpose

This document establishes non-negotiable quality standards for the APAC Intelligence project. These standards exist because of real production failures that could have been prevented with proper verification.

**Zero tolerance for shortcuts. Every standard exists because something broke.**

---

## Before Writing Any Code

### 1. Read and Understand FULL Context

- [ ] Read the entire file being modified, not just the function
- [ ] Read all imports and understand what they do
- [ ] Read all files that import the file being modified
- [ ] Understand the component/function's role in the broader system

### 2. Trace All Dependencies

- [ ] Identify all files that depend on the code being changed
- [ ] Map out the import/export chain
- [ ] Check for dynamic imports or lazy loading
- [ ] Review any shared utilities or hooks being used

### 3. Understand Data Flow End-to-End

- [ ] Trace where data originates (API, database, user input)
- [ ] Follow the data through all transformations
- [ ] Understand where data is consumed and displayed
- [ ] Identify all side effects (state changes, API calls, storage)

### 4. Check Existing Patterns

- [ ] Search codebase for similar implementations
- [ ] Follow established naming conventions
- [ ] Use existing utilities rather than creating duplicates
- [ ] Match the code style of surrounding files

### 5. Review Database Schema

For ANY database operations:

- [ ] Open `docs/database-schema.md` and verify table structure
- [ ] Confirm ALL column names match exactly (case-sensitive)
- [ ] Check column types and constraints
- [ ] Verify foreign key relationships

**Common Database Mistakes to Avoid:**
- `actions` table: Use `Owners` (not `Owner`), `client` (not `Client`)
- `unified_meetings` table: Use `meeting_notes` (not `notes`)
- `nps_responses` table: Use `client_name` (not `client_id`)

---

## Before Committing

### 1. Run Full Test Suite

```bash
npm test
```

- [ ] All tests pass (not just pre-commit hooks)
- [ ] No skipped tests without documented reason
- [ ] New code has appropriate test coverage

### 2. Verify TypeScript Compilation

```bash
npm run build
```

- [ ] Build completes without errors
- [ ] No TypeScript type errors
- [ ] No implicit `any` types introduced

### 3. Validate Database Schema

```bash
npm run validate-schema
```

- [ ] Zero schema validation errors
- [ ] All queries match documented schema
- [ ] Column names verified as correct

### 4. Manual End-to-End Testing

- [ ] Test the feature from start to finish
- [ ] Complete the full user journey
- [ ] Verify data persists correctly
- [ ] Confirm UI updates reflect changes

### 5. Check Browser Console

- [ ] Open DevTools Console
- [ ] No JavaScript errors
- [ ] No failed network requests
- [ ] No deprecation warnings affecting functionality

### 6. Verify Responsive Design (UI Changes)

Test on these screen sizes:
- [ ] Desktop (1920x1080)
- [ ] MacBook (1440x900)
- [ ] Laptop (1366x768)
- [ ] Tablet (768x1024)
- [ ] Mobile (375x667)

---

## After Every Change

### 1. Verify End-to-End Functionality

**Never assume it works. Always verify.**

- [ ] Feature works as expected
- [ ] Data flows correctly through the system
- [ ] UI reflects the correct state
- [ ] No console errors during operation

### 2. Test Edge Cases

- [ ] Empty states (no data)
- [ ] Error states (API failures, network issues)
- [ ] Authentication states (logged in, logged out, session expired)
- [ ] Boundary conditions (max values, special characters)
- [ ] Concurrent user scenarios

### 3. Regression Testing

- [ ] Existing features still work
- [ ] Related features unaffected
- [ ] Navigation flows unchanged
- [ ] No visual regressions

### 4. Monitor Server Logs

- [ ] Check for server-side errors
- [ ] Verify API responses are correct
- [ ] No unexpected database errors
- [ ] Authentication flows working

### 5. Fresh Session Testing

- [ ] Test in incognito/private browsing
- [ ] Clear cache and test again
- [ ] Verify service worker behaviour
- [ ] Test without cached credentials

---

## Quality Checklist

**Complete ALL items before any PR or commit:**

```markdown
## Pre-Commit Quality Checklist

### Code Understanding
- [ ] Read all related files, not just the one being modified
- [ ] Understood the full data flow
- [ ] Checked existing patterns in codebase
- [ ] Verified database schema (if applicable)

### Automated Checks
- [ ] `npm test` - All tests pass
- [ ] `npm run build` - No TypeScript errors
- [ ] `npm run validate-schema` - Zero errors (if database changes)

### Manual Verification
- [ ] Tested feature end-to-end manually
- [ ] Checked browser console for errors
- [ ] Tested edge cases (empty, error, auth states)
- [ ] Verified responsive design (if UI changes)
- [ ] Tested in incognito/fresh session

### Final Confirmation
- [ ] No incomplete features committed
- [ ] All related changes included in commit
- [ ] Commit message accurately describes changes
```

---

## Root Cause Analysis: Past Issues

These standards exist because of real production failures. Learn from these mistakes:

### 1. Auth Session Errors

**What happened**: JWT callback didn't handle the dev-login edge case, causing authentication failures.

**Root cause**:
- Code was written without understanding the full auth flow
- Edge case not considered during development
- No testing with dev-login scenario

**Prevention**:
- Always trace authentication flow end-to-end
- Test ALL auth scenarios: normal login, dev-login, session expiry, logout
- Understand NextAuth callbacks before modifying

### 2. Meetings Not Saving

**What happened**: The `schedule-quick` endpoint was incomplete, causing meeting data to fail silently.

**Root cause**:
- Endpoint implemented without full context of requirements
- No end-to-end testing before committing
- Assumed partial implementation would work

**Prevention**:
- Never commit incomplete features
- Test full data persistence cycle
- Verify database writes actually occur

### 3. Service Worker Caching Issues

**What happened**: Cached Next.js dev chunks caused 404 errors, breaking the application.

**Root cause**:
- Service worker caching not tested with fresh sessions
- Dev environment cache not cleared during testing
- No incognito testing performed

**Prevention**:
- Always test in incognito mode
- Clear service worker cache during development
- Test deployment scenarios before releasing

### 4. Dashboard Layout Breakage

**What happened**: Dashboard layout broke specifically on MacBook screen sizes.

**Root cause**:
- Only tested on one screen size
- Assumed responsive design was working
- No systematic responsive testing

**Prevention**:
- Test ALL specified screen sizes
- Use browser DevTools responsive mode
- Include MacBook (1440x900) in testing matrix

---

## Enforcement

### For Every Commit

1. Complete the Quality Checklist above
2. Include checklist completion in commit message if requested
3. Do not bypass pre-commit hooks

### For Every Pull Request

1. Reviewer must verify checklist was followed
2. PR description must include testing notes
3. Screenshots required for UI changes

### Consequences of Skipping Standards

- Production failures affecting all users
- Emergency rollbacks
- Loss of user trust
- Additional debugging time
- Technical debt accumulation

---

## Quick Reference Commands

```bash
# Before committing - run ALL of these
npm test                    # Full test suite
npm run build               # TypeScript compilation
npm run validate-schema     # Database schema validation

# If schema changes were made
npm run introspect-schema   # Regenerate schema docs

# Pre-commit hook (automatic but don't rely solely on this)
npm run precommit           # Runs validation + build
```

---

## Remember

> **"Move fast and break things" is NOT acceptable in production.**
>
> These standards exist because real users were affected by preventable bugs. Take the extra 5 minutes to verify your changes. It's always faster than debugging production issues.

**When in doubt, test again.**
