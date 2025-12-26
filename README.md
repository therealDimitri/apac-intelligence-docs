# APAC Intelligence Documentation

This directory contains all technical documentation, standards, and reference materials for the APAC Intelligence application.

---

## 📋 Documentation Index

### Database Standards (MANDATORY)

| Document | Purpose | When to Read |
|----------|---------|--------------|
| [DATABASE_STANDARDS.md](./DATABASE_STANDARDS.md) | **MANDATORY** standards for all database interactions | Before ANY database work |
| [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) | Quick checklist for database queries | Keep visible while coding |
| [database-schema.md](./database-schema.md) | **Source of truth** for all table schemas | Before every query |
| [database-schema.json](./database-schema.json) | Machine-readable schema for tools | Used by validation scripts |

### Bug Reports

| Document | Date | Status |
|----------|------|--------|
| [BUG_20251201_database_column_mismatches_and_rls_issues.md](./bug-reports/BUG_20251201_database_column_mismatches_and_rls_issues.md) | 2025-12-01 | ✅ Resolved |

---

## 🚨 Critical Information

### For New Developers

**READ THESE FIRST** (in order):
1. [DATABASE_STANDARDS.md](./DATABASE_STANDARDS.md) - Mandatory compliance
2. [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) - Keep this visible
3. [database-schema.md](./database-schema.md) - Reference before every query

### For All Developers

**Before EVERY database query**:
1. ✋ STOP - Don't assume columns exist
2. 📖 READ - Open `docs/database-schema.md`
3. ✓ VERIFY - Confirm columns match schema
4. 🔍 VALIDATE - Run `npm run validate-schema`
5. ➡️ PROCEED - Only after validation passes

---

## 🛠️ Tools and Scripts

### Available npm Commands

```bash
# Regenerate schema documentation from database
npm run introspect-schema

# Validate all queries against schema
npm run validate-schema

# Run validation + production build
npm run precommit
```

### When to Run Each Command

| Command | Frequency | Mandatory? |
|---------|-----------|------------|
| `npm run introspect-schema` | After migrations, weekly | Yes (after migrations) |
| `npm run validate-schema` | Before every commit | Yes (pre-commit) |
| `npm run precommit` | Before every commit | Yes |
| `npm run build` | Before deployment | Yes |

---

## 📊 Schema Management

### Source of Truth

The **ONLY** authoritative source for database schemas:
- `docs/database-schema.md` (human-readable)
- `docs/database-schema.json` (machine-readable)
- `src/types/database.generated.ts` (TypeScript)

### Auto-Generated Files

**DO NOT EDIT MANUALLY**:
- `docs/database-schema.md`
- `docs/database-schema.json`
- `src/types/database.generated.ts`

These files are **auto-generated** by `npm run introspect-schema`.

### Updating Schema Documentation

```bash
# 1. Make database changes (migration)
npm run migrate:service-role

# 2. Regenerate schema docs
npm run introspect-schema

# 3. Commit both together
git add migrations/ docs/ src/types/
git commit -m "migration: Description with schema update"
```

---

## 🔍 Validation System

### What Gets Validated

The validation script checks:
- ✓ All `.from('table')` references
- ✓ All `.select('columns')` statements
- ✓ All `.insert({ columns })` operations
- ✓ All `.update({ columns })` operations

### Validation Rules

- Table must exist in schema
- ALL columns must exist exactly as written
- Column names are case-sensitive
- No assumptions allowed

### Handling Validation Errors

```bash
# Run validation
npm run validate-schema

# If errors found:
# 1. Open docs/database-schema.md
# 2. Find the correct column names
# 3. Update your queries
# 4. Re-run validation
# 5. Repeat until ✅ All queries are valid
```

---

## 📝 Common Patterns

### Reading Schema Documentation

```bash
# View entire schema
cat docs/database-schema.md

# Find specific table
grep -A 30 "Table: \`actions\`" docs/database-schema.md

# Search for column
grep "column_name" docs/database-schema.md
```

### Using Generated Types

```typescript
import type { ActionsRow } from '@/types/database.generated'

const { data } = await supabase
  .from('actions')
  .select('*')
  .returns<ActionsRow[]>()

// TypeScript will catch column errors at compile time
```

---

## ⚠️ Critical Rules

### The Golden Rule

> **NEVER assume a column exists. ALWAYS verify against the authoritative schema.**

### Zero Tolerance Policy

Changes made without verification that cause production failures will result in:
- Immediate rollback
- Incident report
- Mandatory standards review

### Pre-Commit Requirements

**ALL** of these must pass:
- [ ] `npm run validate-schema` shows zero errors
- [ ] `npm run build` succeeds without TypeScript errors
- [ ] All columns verified against schema documentation
- [ ] No assumptions made about column existence

---

## 📚 Learning Resources

### Essential Reading

1. **Database Standards** - [DATABASE_STANDARDS.md](./DATABASE_STANDARDS.md)
   - Mandatory compliance rules
   - Query writing standards
   - Common mistakes and fixes

2. **Quick Reference** - [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)
   - Checklist format
   - Common column mistakes
   - Emergency contacts

3. **Schema Documentation** - [database-schema.md](./database-schema.md)
   - All table definitions
   - Column names and types
   - Row counts

### Case Studies

- **2025-12-01 Incident**: [BUG_20251201](./bug-reports/BUG_20251201_database_column_mismatches_and_rls_issues.md)
  - What went wrong: Column name mismatches
  - Impact: 100% of features broken
  - Lesson: Always verify against schema

---

## 🆘 Getting Help

### Checklist Not Working?

1. Ensure schema docs are up to date: `npm run introspect-schema`
2. Check validation script runs: `npm run validate-schema`
3. Verify environment variables are set (`.env.local`)

### Found a Schema Error?

1. DO NOT fix manually in docs
2. Check actual database schema
3. Regenerate: `npm run introspect-schema`
4. Report discrepancy if regeneration doesn't fix it

### Production Failure?

1. Check this README for standards
2. Review [DATABASE_STANDARDS.md](./DATABASE_STANDARDS.md)
3. Run validation: `npm run validate-schema`
4. Create bug report in `docs/bug-reports/`

---

## 📅 Maintenance Schedule

| Task | Frequency | Command |
|------|-----------|---------|
| Schema regeneration | After every migration | `npm run introspect-schema` |
| Validation | Before every commit | `npm run validate-schema` |
| Full validation | Weekly | `npm run validate-schema` |
| Standards review | Quarterly | Read DATABASE_STANDARDS.md |

---

## 🎯 Quick Start

**For your first database query**:

```bash
# 1. Read the standards
cat docs/DATABASE_STANDARDS.md

# 2. Check your table schema
grep -A 30 "Table: \`your_table\`" docs/database-schema.md

# 3. Write your query using exact column names

# 4. Validate
npm run validate-schema

# 5. Build
npm run build

# 6. Only commit if both pass
```

---

**Remember**: These standards exist because of real production failures. Follow them strictly.

**Zero assumptions. Always verify.**
