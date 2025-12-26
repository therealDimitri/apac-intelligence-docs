# Database Standards and Rules

**Last Updated**: 2025-12-01
**Status**: 🔒 Mandatory Compliance
**Severity**: Critical

---

## Overview

This document establishes **mandatory standards** for all database interactions in the APAC Intelligence application. These rules were created in response to critical production failures caused by database column mismatches (see [BUG_20251201](./bug-reports/BUG_20251201_database_column_mismatches_and_rls_issues.md)).

**Failure to follow these standards WILL cause production failures.**

---

## 🚨 STRICT VERIFICATION RULE

### ⚠️ MANDATORY PRE-CHANGE VERIFICATION

**BEFORE making ANY changes to database queries, table structures, or column references:**

#### 1. STOP ✋

Do not proceed until you complete the verification steps below.

#### 2. READ 📖

Open and review the authoritative schema documentation:

```bash
cat docs/database-schema.md
# Or for specific table:
grep -A 30 "Table: \`your_table\`" docs/database-schema.md
```

#### 3. VERIFY ✓

Confirm the following against documentation:

- [ ] Table name exists and is spelled correctly
- [ ] ALL column names exist and match exactly (case-sensitive)
- [ ] Data types are compatible with your changes
- [ ] Nullable columns are handled appropriately
- [ ] No columns are assumed to exist without verification

#### 4. VALIDATE 🔍

Run validation against actual database:

```bash
npm run validate-schema
```

#### 5. ONLY THEN PROCEED ➡️

After verification passes, you may make your changes.

### Violation Consequences

**Zero tolerance**: Changes made without verification that break production will result in:

- Immediate rollback required
- Incident report documentation
- Mandatory review of this standards document

### Quick Verification Checklist

Every time you type `.from('table_name')`:

```
□ Opened docs/database-schema.md
□ Found the exact table section
□ Verified ALL columns exist in schema
□ Matched column names exactly (including case)
□ Ran npm run validate-schema
□ Zero validation errors
```

**No shortcuts. No exceptions. No assumptions.**

---

## Golden Rule

> **NEVER assume a column exists. ALWAYS verify against the authoritative schema.**

The single source of truth for all database schemas is:

- **Markdown**: `docs/database-schema.md`
- **JSON**: `docs/database-schema.json`
- **TypeScript**: `src/types/database.generated.ts`

---

## Mandatory Workflow

### Before Writing ANY Database Query

```
1. Check schema documentation → 2. Write query → 3. Validate → 4. Test → 5. Commit
```

#### Step 1: Check Schema Documentation

```bash
# Open the schema docs
cat docs/database-schema.md

# Or search for your table
grep -A 20 "Table: \`your_table_name\`" docs/database-schema.md
```

**NEVER:**

- Guess column names
- Assume columns exist based on other tables
- Trust outdated documentation
- Use columns that "should" exist

**ALWAYS:**

- Verify column names are exact matches (case-sensitive)
- Check the data type
- Verify the column is not nullable if you rely on it

#### Step 2: Write Query

Use the **auto-generated TypeScript types** as your interface definition:

```typescript
import type { ActionsRow, UnifiedMeetingsRow } from '@/types/database.generated'

// CORRECT: Using generated types ensures compile-time validation
const { data, error } = await supabase
  .from('actions')
  .select('Action_ID, Action_Description, Owners, client')
  .returns<ActionsRow[]>()

// INCORRECT: Guessing columns
const { data, error } = await supabase.from('actions').select('id, description, Owner, Client') // ❌ Wrong column names!
```

#### Step 3: Validate

**Before committing**, run validation:

```bash
npm run validate-schema
```

This script checks **all** `.select()`, `.insert()`, and `.update()` queries against the actual database schema.

**Zero tolerance policy**: Fix ALL validation errors before committing.

#### Step 4: Test

Run production build to catch TypeScript errors:

```bash
npm run build
```

**Build must succeed** before deployment.

#### Step 5: Commit

Run pre-commit checks:

```bash
npm run precommit
```

This runs both validation and build checks.

---

## Schema Management Rules

### Rule 1: Schema is Read-Only

The schema files in `docs/` and `src/types/` are **auto-generated**.

**NEVER:**

- Edit `docs/database-schema.md` manually
- Edit `docs/database-schema.json` manually
- Edit `src/types/database.generated.ts` manually

**ALWAYS:**

- Regenerate schema after database migrations
- Commit schema files with migration code

### Rule 2: Introspection After Migrations

**Every time** you modify the database schema (add tables, add columns, alter types):

```bash
# 1. Run your migration
npm run migrate:service-role

# 2. Regenerate schema documentation
npm run introspect-schema

# 3. Commit both migration and schema files together
git add migrations/ docs/ src/types/
git commit -m "migration: Add new table with schema update"
```

### Rule 3: Weekly Schema Validation

Run full validation **at least once per week**:

```bash
npm run validate-schema
```

Schedule this in your calendar or CI/CD pipeline.

---

## Query Writing Standards

### Column Names

#### ✅ DO:

```typescript
// Use exact column names from schema
.select('Action_ID, Action_Description, Owners, client, Due_Date')

// Use aliases only after selecting correct columns
.select('Action_ID as id, Action_Description as description')
```

#### ❌ DON'T:

```typescript
// Guess column names
.select('id, description, Owner, Client')  // ❌ Wrong case!

// Use columns that don't exist
.select('client_id, notes, title')  // ❌ Not in schema!
```

### Case Sensitivity

**PostgreSQL column names are case-sensitive.**

```typescript
// CORRECT
.select('client')      // ✅ Lowercase in database
.select('Action_ID')   // ✅ Mixed case in database

// INCORRECT
.select('Client')      // ❌ Wrong case
.select('action_id')   // ❌ Wrong case
```

**Rule**: Match the schema **EXACTLY** - including capitalization.

### Pluralization

Common mistake: confusing singular vs plural column names.

```typescript
// actions table
.select('Owners')    // ✅ CORRECT (plural)
.select('Owner')     // ❌ WRONG (doesn't exist)

// Always check the schema for exact column name
```

### SELECT Statements

#### ✅ DO:

```typescript
// Explicit column selection (recommended)
.select('Action_ID, Owners, client, Due_Date, Status')

// Use * only when you need ALL columns
.select('*')

// Use generated types
.select('*').returns<ActionsRow[]>()
```

#### ❌ DON'T:

```typescript
// Mix valid and invalid columns
.select('Action_ID, Owner, client_id')  // ❌ Owner and client_id don't exist

// SELECT * and assume columns exist
const owner = action.Owner  // ❌ Column doesn't exist
```

### INSERT Statements

#### ✅ DO:

```typescript
// Use exact column names from schema
.insert({
  Action_Description: 'New action',
  Owners: 'John, Jane',
  client: 'ABC Corp',
  Due_Date: '2025-12-01',
  Status: 'Open'
})
```

#### ❌ DON'T:

```typescript
// Use wrong column names
.insert({
  description: 'New action',  // ❌ Should be Action_Description
  Owner: 'John',              // ❌ Should be Owners
  Client: 'ABC Corp'          // ❌ Should be client (lowercase)
})
```

### UPDATE Statements

#### ✅ DO:

```typescript
// Update with correct column names
.update({
  Status: 'Completed',
  Owners: 'John, Jane'
})
```

#### ❌ DON'T:

```typescript
// Update non-existent columns
.update({
  Owner: 'John',     // ❌ Column doesn't exist
  Client: 'ABC'      // ❌ Wrong case
})
```

---

## TypeScript Integration

### Use Auto-Generated Types

**Always import and use** the generated database types:

```typescript
import type { ActionsRow, UnifiedMeetingsRow, NpsResponsesRow } from '@/types/database.generated'

// Use in function signatures
async function getActions(): Promise<ActionsRow[]> {
  const { data } = await supabase.from('actions').select('*').returns<ActionsRow[]>()

  return data || []
}

// TypeScript will catch column errors at compile time
const owner = data[0].Owner // ❌ TypeScript error: Property 'Owner' does not exist
const owners = data[0].Owners // ✅ TypeScript allows this
```

### Custom Interfaces

If you need a **subset** of columns, extend the generated type:

```typescript
import type { ActionsRow } from '@/types/database.generated'

// ✅ CORRECT: Extend generated type
interface ActionSummary extends Pick<ActionsRow, 'Action_ID' | 'Action_Description' | 'Status'> {
  formattedDate: string
}

// ❌ INCORRECT: Creating new interface from scratch
interface ActionSummary {
  id: string // ❌ Column is Action_ID
  description: string // ❌ Column is Action_Description
  Owner: string // ❌ Column doesn't exist
}
```

---

## Common Mistakes and Fixes

### Mistake 1: Wrong Column Case

**Error**: `column actions."Client" does not exist`

**Cause**: Used `Client` (capital C) instead of `client` (lowercase)

**Fix**:

```typescript
// BEFORE (WRONG)
.select('Client')

// AFTER (CORRECT)
.select('client')
```

### Mistake 2: Non-Existent Column

**Error**: `column actions."Owner" does not exist`

**Cause**: Table has `Owners` (plural), not `Owner` (singular)

**Fix**:

```typescript
// BEFORE (WRONG)
.select('Owner')

// AFTER (CORRECT)
.select('Owners')
```

### Mistake 3: Column from Different Table

**Error**: `column unified_meetings."notes" does not exist`

**Cause**: Assumed `notes` exists because other tables have it

**Fix**: Check schema - the column is actually `meeting_notes`

```typescript
// BEFORE (WRONG)
.select('notes')

// AFTER (CORRECT)
.select('meeting_notes')
```

### Mistake 4: Development Works, Production Fails

**Cause**: TypeScript type errors don't fail in `npm run dev` but fail in `npm run build`

**Fix**: Always run `npm run build` before committing

```bash
npm run build
```

### Mistake 5: RLS Blocks Data Access

**Symptoms**: Query returns 0 rows with ANON key, but many rows with SERVICE key

**Fix**: Check RLS policies exist for the table

```sql
-- View existing policies
SELECT * FROM pg_policies WHERE tablename = 'your_table';

-- Create missing SELECT policy
CREATE POLICY "Allow users to view data"
  ON your_table
  FOR SELECT
  TO anon, authenticated
  USING (true);
```

---

## Pre-Deployment Checklist

Before **every** deployment, complete this checklist:

- [ ] Run `npm run validate-schema` - All queries validated
- [ ] Run `npm run build` - Production build succeeds
- [ ] No TypeScript errors related to database columns
- [ ] All queries tested with ANON key (not just SERVICE key)
- [ ] Schema documentation is up to date
- [ ] RLS policies exist for all new tables

---

## CI/CD Integration

Add these checks to your CI/CD pipeline:

```yaml
# Example GitHub Actions workflow
- name: Validate Database Schema
  run: npm run validate-schema

- name: Build Production
  run: npm run build
```

**Deployment should fail** if either check fails.

---

## Tools Reference

### npm Scripts

| Command                     | Description                                 | When to Run              |
| --------------------------- | ------------------------------------------- | ------------------------ |
| `npm run introspect-schema` | Generate schema documentation from database | After migrations, weekly |
| `npm run validate-schema`   | Validate all queries against schema         | Before commits, in CI/CD |
| `npm run precommit`         | Run validation + build checks               | Before every commit      |
| `npm run build`             | Production TypeScript build                 | Before deployment        |

### Generated Files

| File                              | Purpose                         | Edit Manually?         |
| --------------------------------- | ------------------------------- | ---------------------- |
| `docs/database-schema.md`         | Human-readable schema reference | ❌ No (auto-generated) |
| `docs/database-schema.json`       | Machine-readable schema         | ❌ No (auto-generated) |
| `src/types/database.generated.ts` | TypeScript type definitions     | ❌ No (auto-generated) |

### Manual Verification

```bash
# Check actual database columns
node -e "
import { createClient } from '@supabase/supabase-js';
const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);
const { data } = await supabase.from('your_table').select('*').limit(1);
console.log(Object.keys(data[0]));
"
```

---

## Troubleshooting

### Validation Script Shows Errors

1. **Missing tables**: Table doesn't exist yet - either create it or remove queries
2. **Invalid columns**: Check `docs/database-schema.md` for correct column names
3. **Case mismatch**: Match column names exactly (case-sensitive)

### Production Build Fails

1. Check error message for column reference
2. Find file and line number in error
3. Check `src/types/database.generated.ts` for correct column name
4. Update query to match schema

### Query Returns 0 Rows

1. Test with SERVICE role key first to rule out RLS
2. Check `pg_policies` table for missing policies
3. Create appropriate RLS policy using service worker

---

## Historical Context

This standard was created after the **2025-12-01 Database Column Mismatch Incident** which caused:

- 100% of core features broken
- 3 critical production failures
- Multiple emergency hotfixes required

Details: [BUG_20251201](./bug-reports/BUG_20251201_database_column_mismatches_and_rls_issues.md)

**This must never happen again.**

---

## Enforcement

- **Mandatory**: All developers must follow these standards
- **Code Review**: Reviewers must verify schema validation passes
- **CI/CD**: Automated checks must pass before deployment
- **Weekly Audit**: Run validation weekly and fix all errors

---

## Questions?

If unsure about column names:

1. Check `docs/database-schema.md`
2. Run `npm run introspect-schema` to regenerate
3. Use `src/types/database.generated.ts` for TypeScript validation
4. Test query with actual database before committing

**When in doubt, validate.**

---

**Document Version**: 1.0
**Created**: 2025-12-01
**Author**: Claude Code (Automated System)
