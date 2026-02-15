# ChaSen Document Upload - Integration Setup

**Quick Start Guide for Integrating Document Upload into ChaSen AI**

---

## Quick Overview

The document upload feature for ChaSen AI has been implemented with:

- ✅ Backend API endpoint ready
- ✅ React UI component ready
- ✅ Database schema prepared
- ✅ Document parsing utilities ready
- ✅ Comprehensive documentation provided

---

## Integration Steps

### Step 1: Create Database Table

Run the SQL migration in Supabase:

```sql
-- Copy entire contents from:
-- scripts/create_chasen_documents_table.sql
-- Paste into Supabase SQL Editor and execute
```

**Verify:**

```sql
SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'chasen_documents';
-- Should return 1
```

### Step 2: Import Component in AI Page

In `src/app/(dashboard)/ai/page.tsx`:

```typescript
import DocumentUpload from '@/components/DocumentUpload'

// Inside your ChaSenPage component JSX:
<DocumentUpload
  conversationId={conversationId}
  clientName={selectedClient}
  onDocumentUploaded={(doc) => {
    console.log('Document uploaded:', doc)
    // Add to state or pass to chat system
    setUploadedDocuments(prev => [...prev, doc.id])
  }}
  onError={(error) => {
    console.error('Upload failed:', error)
    // Show error toast or notification
  }}
/>
```

### Step 3: Update Chat Request Format

When sending a message, include document IDs:

```typescript
const chatPayload = {
  question: userMessage,
  conversationHistory: messages,
  context: 'general',
  documentIds: uploadedDocuments, // Add this
  userContext: {
    email: user.email,
    name: user.name,
    // ... other fields ...
  },
}

const response = await fetch('/api/chasen/chat', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(chatPayload),
})
```

### Step 4: Update Backend to Use Document Context

In `src/app/api/chasen/chat/route.ts`, update the chat request interface:

```typescript
interface ChatRequest {
  question: string
  conversationHistory?: ChatMessage[]
  context?: 'portfolio' | 'client' | 'general'
  clientName?: string
  documentIds?: string[]  // Add this
  model?: number
  userContext?: { ... }
}
```

Then fetch and include document content in the system prompt:

```typescript
// After receiving documentIds
let documentContext = ''
if (request.body.documentIds && request.body.documentIds.length > 0) {
  const supabase = getServiceSupabase()
  const { data: documents } = await supabase
    .from('chasen_documents')
    .select('file_name, extracted_text')
    .in('id', request.body.documentIds)

  if (documents && documents.length > 0) {
    documentContext = `
## Uploaded Documents Available for Analysis:
${documents
  .map(
    doc => `
### ${doc.file_name}
${doc.extracted_text.substring(0, 2000)}...
`
  )
  .join('\n')}
`
  }
}

// Include in system prompt:
const systemPrompt = getSystemPrompt(context, portfolioData, userContext, documentContext)
```

### Step 5: Build and Test

```bash
# Build to check for TypeScript errors
npm run build

# Start development server
npm run dev

# Test at http://localhost:3002/ai
```

---

## Files Created

```
✅ src/types/chasen.ts
   - Added: DocumentMetadata interface
   - Added: ChaSenDocument interface
   - Updated: ChaSenMessage to include documentIds
   - Updated: ChaSenConversation to include documents

✅ src/lib/document-parser.ts
   - New file: Document parsing utilities
   - Functions: parseDocument(), validateDocumentFile(), truncateExtractedText()
   - Parsers: TXT, CSV (complete); PDF, DOCX, XLSX (framework ready)

✅ src/components/DocumentUpload.tsx
   - New component: React upload component
   - Features: Drag-and-drop, validation, progress, error handling
   - Props: conversationId, clientName, onDocumentUploaded, onError

✅ src/app/api/chasen/upload/route.ts
   - New endpoint: POST /api/chasen/upload
   - Features: File upload, parsing, storage, AI summary
   - Also: GET endpoint for document retrieval

✅ scripts/create_chasen_documents_table.sql
   - New migration: Database schema for documents
   - Includes: Indexes for performance

✅ docs/CHASEN-DOCUMENT-UPLOAD-FEATURE.md
   - Complete technical documentation
   - Architecture, API reference, troubleshooting

✅ docs/CHASEN-SETUP-INTEGRATION.md
   - This file: Integration guide
```

---

## Testing Checklist

### Basic Upload Test

```typescript
// In browser console while on /ai page
const file = new File(['test content'], 'test.txt', { type: 'text/plain' })
const formData = new FormData()
formData.append('file', file)
formData.append('conversationId', 'test-123')

fetch('/api/chasen/upload', {
  method: 'POST',
  body: formData,
})
  .then(r => r.json())
  .then(data => console.log('Upload result:', data))
```

### Component Test

1. Navigate to `/ai` page
2. Verify DocumentUpload component renders
3. Try dragging a text file to upload area
4. Confirm upload success message
5. Verify document appears in list
6. Check document in database:

```sql
SELECT id, file_name, file_type, file_size, uploaded_at
FROM chasen_documents
ORDER BY uploaded_at DESC
LIMIT 10;
```

### Full Integration Test

1. Upload document via UI
2. Type a question about the document
3. Verify ChaSen AI references the document
4. Check that document context was included in request
5. Verify response includes document-based insights

---

## Optional: Enhanced PDF Parsing

To enable PDF text extraction, install pdfjs:

```bash
npm install pdfjs-dist
```

Then update `src/lib/document-parser.ts`:

```typescript
import * as pdfjsLib from 'pdfjs-dist/legacy/build/pdf'

async function parsePDFFile(file: File): Promise<ParsedDocument> {
  const arrayBuffer = await file.arrayBuffer()
  const pdf = await pdfjsLib.getDocument(arrayBuffer).promise

  let fullText = ''
  for (let i = 0; i < pdf.numPages; i++) {
    const page = await pdf.getPage(i + 1)
    const content = await page.getTextContent()
    const pageText = content.items.map((item: any) => item.str).join(' ')
    fullText += pageText + '\n'
  }

  return {
    fileName: file.name,
    fileType: 'pdf',
    mimeType: 'application/pdf',
    fileSize: file.size,
    extractedText: fullText,
    pageCount: pdf.numPages,
  }
}
```

---

## Optional: Enhanced DOCX Parsing

To enable Word document parsing, install docx:

```bash
npm install docx
```

Then update `src/lib/document-parser.ts`:

```typescript
import { Document, Packer } from 'docx'
import * as mammoth from 'mammoth'

async function parseDOCXFile(file: File): Promise<ParsedDocument> {
  const arrayBuffer = await file.arrayBuffer()
  const result = await mammoth.extractRawText({ arrayBuffer })

  return {
    fileName: file.name,
    fileType: 'docx',
    mimeType: file.type,
    fileSize: file.size,
    extractedText: result.value,
    summary: generateTextPreview(result.value),
  }
}
```

---

## Common Integration Issues

### Issue: TypeScript errors after updating types

**Solution:**

```bash
npm run build  # Check full build
# Fix any type errors
# Restart dev server
npm run dev
```

### Issue: Document upload endpoint returns 404

**Solution:**

- Verify `/api/chasen/upload/route.ts` file exists
- Check file is in correct directory: `src/app/api/chasen/upload/`
- Restart dev server

### Issue: Database table doesn't exist

**Solution:**

1. Go to Supabase dashboard
2. SQL Editor
3. Copy contents of `scripts/create_chasen_documents_table.sql`
4. Paste and execute
5. Verify tables were created

### Issue: Documents not appearing in chat

**Solution:**

1. Verify documentIds are passed in chat request
2. Fetch and display document content in system prompt
3. Check ChatRequest type includes documentIds
4. Verify backend uses documentIds parameter

---

## Rollout Checklist

- [ ] Database migration executed in Supabase
- [ ] DocumentUpload component imported in AI page
- [ ] Chat request updated to include documentIds
- [ ] Backend chat endpoint updated to use documentIds
- [ ] Build passes without TypeScript errors
- [ ] Dev server starts without errors
- [ ] Manual testing completed:
  - [ ] File upload works
  - [ ] Documents stored in database
  - [ ] Document appears in list
  - [ ] Chat can reference documents
- [ ] Error handling tested:
  - [ ] Invalid file type rejected
  - [ ] File too large rejected
  - [ ] Network errors handled gracefully
- [ ] UI tested:
  - [ ] Drag-and-drop works
  - [ ] Click-to-browse works
  - [ ] Progress indicator shows
  - [ ] Success message displays
  - [ ] Error messages clear

---

## Production Considerations

### Before Going Live

1. **Security Audit**
   - Verify file validation is robust
   - Check access controls on document retrieval
   - Test with malicious files
   - Verify user data isolation

2. **Performance**
   - Test with large files (10MB)
   - Monitor API response times
   - Check database query performance
   - Load test upload endpoint

3. **Data Management**
   - Document retention policy
   - Backup strategy for uploaded files
   - Cleanup of old documents
   - Storage capacity planning

4. **Monitoring**
   - Track upload success rates
   - Monitor API errors
   - Track file types used
   - Monitor storage usage

### Monitoring Queries

```sql
-- Upload success rate (last 24 hours)
SELECT
  COUNT(*) as total_uploads,
  COUNT(CASE WHEN error IS NULL THEN 1 END) as successful,
  ROUND(100.0 * COUNT(CASE WHEN error IS NULL THEN 1 END) / COUNT(*), 2) as success_rate
FROM chasen_documents
WHERE uploaded_at > NOW() - INTERVAL '24 hours'

-- Storage usage by file type
SELECT
  file_type,
  COUNT(*) as count,
  ROUND(SUM(file_size) / 1024.0 / 1024.0, 2) as total_mb
FROM chasen_documents
GROUP BY file_type
ORDER BY total_mb DESC

-- Largest documents
SELECT file_name, file_type, file_size, uploaded_at
FROM chasen_documents
ORDER BY file_size DESC
LIMIT 10
```

---

## Rollback Plan

If issues arise:

1. **Disable Upload Component**

   ```typescript
   // In AI page, comment out DocumentUpload import/usage
   // Users can still view previous conversations
   ```

2. **Disable API Endpoint**

   ```typescript
   // In route.ts, return 503 Service Unavailable
   return NextResponse.json({ error: 'Document upload temporarily unavailable' }, { status: 503 })
   ```

3. **Restore Previous Version**
   ```bash
   git revert [commit-hash]
   npm run build
   npm run dev
   ```

---

## Support & Documentation

- 📖 Full documentation: `docs/CHASEN-DOCUMENT-UPLOAD-FEATURE.md`
- 🔧 API Reference: See documentation file
- 🐛 Issues: Check troubleshooting section in docs
- 💬 Questions: Review docs or contact team

---

**Status:** ✅ Ready for Integration
**Last Updated:** 2025-12-01
**Version:** 1.0
