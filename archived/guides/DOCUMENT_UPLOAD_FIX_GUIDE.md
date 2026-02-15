# Quick Fix Guide: Document Upload Database Migration

## The Error

```
Upload Failed
Failed to store document
```

**Root Cause:** The database table `chasen_documents` does not exist in Supabase.

---

## Quick Fix (2 Minutes)

### 1. Go to Supabase Console

- Open: https://supabase.com
- Select: **apac-intelligence-v2** project
- Navigate: **SQL Editor** (left sidebar)

### 2. Create New Query

- Click **New Query** button

### 3. Copy & Paste This SQL

```sql
-- ChaSen Documents Table
-- Stores uploaded documents for analysis in conversations

CREATE TABLE IF NOT EXISTS chasen_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES chasen_conversations(id) ON DELETE CASCADE,
  file_name TEXT NOT NULL,
  file_type VARCHAR(10) NOT NULL CHECK (file_type IN ('pdf', 'docx', 'csv', 'txt', 'xlsx')),
  mime_type VARCHAR(100),
  file_size INTEGER NOT NULL,
  extracted_text TEXT NOT NULL,
  page_count INTEGER,
  summary TEXT,
  key_points TEXT[], -- Array of key points
  user_email VARCHAR(255),
  client_name VARCHAR(255),
  uploaded_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_chasen_documents_conversation_id ON chasen_documents(conversation_id);
CREATE INDEX IF NOT EXISTS idx_chasen_documents_user_email ON chasen_documents(user_email);
CREATE INDEX IF NOT EXISTS idx_chasen_documents_uploaded_at ON chasen_documents(uploaded_at DESC);
CREATE INDEX IF NOT EXISTS idx_chasen_documents_file_type ON chasen_documents(file_type);

-- Update table comments
COMMENT ON TABLE chasen_documents IS 'Stores uploaded documents for ChaSen AI analysis';
COMMENT ON COLUMN chasen_documents.id IS 'Unique document identifier';
COMMENT ON COLUMN chasen_documents.conversation_id IS 'Foreign key to chasen_conversations';
COMMENT ON COLUMN chasen_documents.file_name IS 'Original file name';
COMMENT ON COLUMN chasen_documents.file_type IS 'File format (pdf, docx, csv, txt, xlsx)';
COMMENT ON COLUMN chasen_documents.extracted_text IS 'Full text extracted from document';
COMMENT ON COLUMN chasen_documents.summary IS 'AI-generated summary of document';
COMMENT ON COLUMN chasen_documents.key_points IS 'Array of extracted key points';
COMMENT ON COLUMN chasen_documents.metadata IS 'Additional document metadata (file hash, upload source, etc)';
```

### 4. Click "Run" Button

- Wait for success message

### 5. Verify (Optional)

Run this query to confirm the table exists:

```sql
SELECT COUNT(*) FROM information_schema.tables
WHERE table_name = 'chasen_documents';
-- Should return: 1
```

---

## Test the Fix

1. Go to: http://localhost:3002/ai
2. Upload a document (PDF, CSV, TXT, DOCX, or XLSX)
3. Document should upload successfully ✅

---

## Still Not Working?

Check:

- [ ] Supabase table created (verify step above)
- [ ] Dev server still running
- [ ] Try browser refresh (Cmd+Shift+R or Ctrl+Shift+R)
- [ ] Check browser console for errors (F12)

---

## What This Does

Creates a database table to store:

- Document metadata (name, type, size, upload date)
- Extracted text from documents
- AI-generated summaries
- User info (email, name)
- Conversation association

Once created, the ChaSen AI upload feature will work perfectly!

---

**Time to Fix:** ~2 minutes
**Difficulty:** Easy
**Status:** One-time setup
