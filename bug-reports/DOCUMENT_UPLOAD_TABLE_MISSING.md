# Bug Report: Document Upload - Missing Database Table

**Title:** Document Upload Fails - chasen_documents Table Not Created
**Status:** OPEN
**Severity:** HIGH
**Date Reported:** 2025-12-01
**Component:** Document Upload Feature (ChaSen AI)

---

## Problem Description

When users attempt to upload documents in the ChaSen AI chat interface, the upload fails with error:

```
"error": "Failed to store document",
"details": "Could not find the table 'public.chasen_documents' in the schema cache"
```

## Root Cause

The SQL migration script `scripts/create_chasen_documents_table.sql` was created but **never executed in the Supabase database**. The `chasen_documents` table does not exist in the Supabase `public` schema.

## Error Details

**API Endpoint:** `POST /api/chasen/upload`
**Error Location:** `src/app/api/chasen/upload/route.ts:63-94`
**Database Error:** Supabase cannot find table 'public.chasen_documents'

## Solution

Run the SQL migration in Supabase to create the required table.

### Step-by-Step Instructions

#### Option 1: Using Supabase Dashboard (Recommended for Non-Technical Users)

1. Go to [Supabase Console](https://supabase.com)
2. Sign in and select the **apac-intelligence-v2** project
3. Navigate to **SQL Editor**
4. Create a new query
5. Copy the entire contents of `scripts/create_chasen_documents_table.sql`
6. Paste into the SQL editor
7. Click **Run**
8. Wait for confirmation message

#### Option 2: Using Supabase CLI

```bash
# If you have Supabase CLI installed
cd /path/to/apac-intelligence-v2

# Push the migration
supabase migration new create_chasen_documents_table

# Copy SQL to the generated migration file
cat scripts/create_chasen_documents_table.sql > supabase/migrations/[timestamp]_create_chasen_documents_table.sql

# Deploy
supabase db push
```

#### Option 3: Direct SQL Execution

1. In Supabase console, go to **SQL Editor**
2. Paste and execute the SQL from `scripts/create_chasen_documents_table.sql`

### SQL Migration Content

The migration creates:

- `chasen_documents` table with columns:
  - `id` (UUID, primary key)
  - `conversation_id` (FK to chasen_conversations)
  - `file_name`, `file_type`, `mime_type`, `file_size`
  - `extracted_text`, `page_count`, `summary`, `key_points`
  - `user_email`, `client_name`
  - `uploaded_at`, `metadata`, `created_at`, `updated_at`

- Indexes for query performance:
  - `idx_chasen_documents_conversation_id`
  - `idx_chasen_documents_user_email`
  - `idx_chasen_documents_uploaded_at`
  - `idx_chasen_documents_file_type`

## Verification Steps

After running the migration, verify the table exists:

### In Supabase Console:

1. Go to **Tables**
2. Look for `chasen_documents` in the list
3. Click to view the schema

### Via SQL Query:

```sql
SELECT COUNT(*) FROM information_schema.tables
WHERE table_name = 'chasen_documents';
-- Should return: 1
```

### Test the Upload:

1. Navigate to ChaSen AI page: http://localhost:3002/ai
2. Upload a test document (TXT, CSV, PDF, DOCX, or XLSX)
3. Should see success message: "Document uploaded and processed successfully"

## Files Involved

- `scripts/create_chasen_documents_table.sql` - SQL migration (NEEDS TO BE EXECUTED)
- `src/app/api/chasen/upload/route.ts` - Upload API endpoint
- `src/components/DocumentUpload.tsx` - React upload component
- `src/app/(dashboard)/ai/page.tsx` - ChaSen AI chat page (integrated)

## Environment

- Project: apac-intelligence-v2
- Environment: Supabase (production database)
- Feature: ChaSen AI Document Upload
- Status: Implemented (pending database migration)

## Related Issues

- Feature Implementation: Document Upload integration complete
- Backend: ✅ API endpoint ready
- Frontend: ✅ React component integrated
- Database: ❌ **TABLE NOT CREATED** (requires SQL migration execution)

## Next Steps

1. **Execute the SQL migration** in Supabase (see Solution section)
2. Verify table creation (see Verification section)
3. Test document upload in ChaSen AI UI
4. Confirm error resolves

## Additional Notes

- The feature is **fully implemented** and ready to use
- Only the database table creation was not performed
- This is a **one-time setup** task
- Once the table is created, uploads will work immediately

---

**Reported By:** Claude Code
**Last Updated:** 2025-12-01 02:30 UTC
