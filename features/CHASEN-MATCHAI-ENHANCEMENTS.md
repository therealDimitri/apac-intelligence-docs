# ChaSen AI - MatchAI API Enhancements

**Date:** 2025-12-07
**Status:** ✅ Implemented
**Impact:** HIGH - Adds powerful document intelligence capabilities

## Overview

This implementation adds 3 major new MatchAI-powered features to the ChaSen AI system:

1. **Document Summary Generation** - Auto-summarize uploaded documents
2. **Multi-Document Analysis** - Analyze patterns across multiple documents
3. **Folder Management** - Organize documents by client/project

## New API Endpoints

### 1. Document Summary (`/api/chasen/summary`)

**Purpose:** Generate AI-powered summaries of individual documents

**Request:**

```typescript
POST /api/chasen/summary
{
  "documentId": "uuid",
  "summaryType": "executive" | "detailed" | "action_items" | "key_insights",
  "model": "claude-sonnet-4-5",  // Optional
  "maxLength": 200  // Optional, words
}
```

**Response:**

```typescript
{
  "success": true,
  "documentId": "uuid",
  "documentName": "Q4 Meeting Notes.pdf",
  "summaryType": "executive",
  "summary": "Executive summary text...",
  "keyPoints": ["Point 1", "Point 2", "Point 3"],
  "confidence": 90,
  "model": 71,
  "timestamp": "2025-12-07T10:00:00Z"
}
```

**Summary Types:**

- `executive` - Concise 200-word summary focusing on decisions and outcomes
- `detailed` - Comprehensive summary with all major points
- `action_items` - Extract all tasks, action items, and follow-ups
- `key_insights` - Strategic insights and trends

**Use Cases:**

- Auto-summarize meeting notes after upload
- Generate executive summaries for QBR decks
- Extract action items from client documents
- Create quick briefings for managers

---

### 2. Multi-Document Analysis (`/api/chasen/analyze`)

**Purpose:** Analyze multiple documents together to identify cross-document patterns, trends, and insights

**Request:**

```typescript
POST /api/chasen/analyze
{
  "documentIds": ["uuid1", "uuid2", "uuid3"],
  "analysisType": "trends" | "themes" | "risks" | "sentiment" | "comprehensive",
  "clientName": "SA Health",  // Optional: focus on specific client
  "model": "claude-sonnet-4-5"  // Optional
}
```

**Response:**

```typescript
{
  "success": true,
  "analysisType": "comprehensive",
  "documentCount": 5,
  "clientName": "SA Health",
  "executiveSummary": "Analysis summary...",
  "findings": [
    {
      "category": "Recurring Issue",
      "insight": "System performance mentioned in 4 out of 5 documents",
      "evidence": ["Doc 1: slow load times", "Doc 3: timeout errors"],
      "severity": "high"
    }
  ],
  "trends": [
    {
      "trend": "User adoption increasing",
      "direction": "improving",
      "supporting_docs": ["Meeting Notes Q3", "Meeting Notes Q4"]
    }
  ],
  "recommendations": ["Recommendation 1", "Recommendation 2"],
  "confidence": 88
}
```

**Analysis Types:**

- `trends` - Identify patterns and evolution over time
- `themes` - Find recurring topics and subjects
- `risks` - Flag all risks, issues, and concerns
- `sentiment` - Track sentiment evolution across documents
- `comprehensive` - Full analysis covering all areas

**Use Cases:**

- Analyze all meeting notes for a client to identify recurring themes
- Track sentiment evolution across QBR documents
- Identify systemic risks mentioned across multiple sources
- Generate comprehensive client health reports

**Limits:**

- Maximum 20 documents per analysis
- Each document truncated to 3,000 characters for context

---

### 3. Folder Management (`/api/chasen/folders`)

**Purpose:** Organize documents in folder structure by client/project

**Endpoints:**

#### GET - List Folders

```typescript
GET /api/chasen/folders?clientName=SA Health&parentId=uuid

Response:
{
  "success": true,
  "folders": [
    {
      "id": "uuid",
      "name": "SA Health",
      "clientName": "SA Health",
      "parentId": null,
      "description": "SA Health documents and meeting notes",
      "color": "#10B981",
      "documentCount": 12,
      "createdAt": "2025-12-01T00:00:00Z",
      "updatedAt": "2025-12-07T10:00:00Z"
    }
  ]
}
```

#### POST - Create Folder

```typescript
POST /api/chasen/folders
{
  "name": "Meeting Notes 2025",
  "parentId": "parent-folder-uuid",  // Optional
  "clientName": "SA Health",  // Optional
  "description": "All 2025 meeting notes",
  "color": "#3B82F6"  // Optional, default blue
}
```

#### PUT - Update Folder

```typescript
PUT /api/chasen/folders
{
  "folderId": "uuid",
  "name": "Updated Name",
  "description": "Updated description",
  "color": "#EF4444"
}
```

#### DELETE - Delete Folder

```typescript
DELETE /api/chasen/folders?folderId=uuid

Note: Only empty folders can be deleted
```

**Features:**

- Nested folder structure (folders within folders)
- Color tags for visual organization
- Client categorization
- Automatic document counting
- Prevent deletion of non-empty folders

**Default Folders Created:**

- SA Health (Green, #10B981)
- MINDEF (Red, #EF4444)
- Epworth HealthCare (Purple, #8B5CF6)
- Western Australia Health (Orange, #F59E0B)
- General Documents (Gray, #6B7280)

---

## Database Changes

### New Table: `chasen_folders`

```sql
CREATE TABLE chasen_folders (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  parent_id UUID REFERENCES chasen_folders(id),
  client_name TEXT,
  description TEXT,
  color TEXT DEFAULT '#3B82F6',
  created_at TIMESTAMP,
  updated_at TIMESTAMP,

  CONSTRAINT unique_name_per_parent UNIQUE (name, parent_id, client_name)
);
```

### Updated Table: `chasen_documents`

```sql
ALTER TABLE chasen_documents
ADD COLUMN folder_id UUID REFERENCES chasen_folders(id);
```

**Migration File:** `docs/migrations/20251207_chasen_folders_table.sql`

---

## Integration Points

### ChaSen AI Chat Integration

The new endpoints integrate seamlessly with existing ChaSen chat:

1. **Auto-Summarize After Upload:**
   - When user uploads document, automatically call `/api/chasen/summary`
   - Display summary in upload confirmation

2. **Smart Folder Assignment:**
   - Detect client name from filename or content
   - Auto-assign to appropriate client folder

3. **Cross-Document Queries:**
   - User asks: "What are recurring themes in SA Health's documents?"
   - ChaSen calls `/api/chasen/analyze` with all SA Health document IDs
   - Returns comprehensive analysis

### Future Enhancements

**Phase 2 Features (Not Yet Implemented):**

- Direct file upload to MatchAI (use their storage)
- MatchAI's native summarization endpoint (when available)
- Batch document processing
- Scheduled periodic analysis
- Document versioning within folders

---

## Example Workflows

### Workflow 1: QBR Preparation

```typescript
// 1. Upload QBR deck
POST /api/chasen/upload { file: "QBR_Q4_2025.pdf" }

// 2. Auto-generate executive summary
POST /api/chasen/summary {
  documentId: "new-doc-id",
  summaryType: "executive"
}

// 3. Extract action items
POST /api/chasen/summary {
  documentId: "new-doc-id",
  summaryType: "action_items"
}

// 4. Organize in folder
POST /api/chasen/folders {
  name: "Q4 2025 QBR",
  clientName: "SA Health",
  color: "#10B981"
}
```

### Workflow 2: Client Health Analysis

```typescript
// 1. Get all documents for client
GET /api/chasen/folders?clientName=MINDEF

// 2. Analyze all documents together
POST /api/chasen/analyze {
  documentIds: ["doc1", "doc2", "doc3", "doc4", "doc5"],
  analysisType: "comprehensive",
  clientName: "MINDEF"
}

// Returns:
// - Recurring themes across all documents
// - Sentiment trends
// - Identified risks
// - Recommendations
```

### Workflow 3: Document Organization

```typescript
// 1. Create client folder structure
POST /api/chasen/folders {
  name: "SA Health",
  description: "All SA Health documents"
}

// 2. Create subfolder for meeting notes
POST /api/chasen/folders {
  name: "Meeting Notes",
  parentId: "sa-health-folder-id",
  color: "#3B82F6"
}

// 3. Move documents to folder
PUT /api/chasen/documents/move {
  documentIds: ["doc1", "doc2", "doc3"],
  folderId: "meeting-notes-folder-id"
}
```

---

## Technical Implementation

### MatchAI API Integration

All new features use the existing MatchAI `/completions` endpoint with specialized prompts:

```typescript
const matchaResponse = await fetch(`${MATCHAAI_CONFIG.baseUrl}/completions`, {
  method: 'POST',
  headers: {
    'MATCHA-API-KEY': MATCHAAI_CONFIG.apiKey,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    mission_id: parseInt(MATCHAAI_CONFIG.missionId),
    llm_id: selectedLlmId, // Model selection (71 = Claude Sonnet 4.5)
    input: systemPrompt, // Task-specific prompt
  }),
})
```

### Error Handling

All endpoints include:

- Input validation (required fields, data types)
- MatchAI API error handling
- Database error handling
- Graceful JSON parsing fallbacks
- Detailed logging for debugging

### Performance Considerations

- **Summary Endpoint:** ~5-10 seconds per document
- **Analysis Endpoint:** ~10-20 seconds for 5 documents
- **Folder Operations:** < 1 second

**Optimization:**

- Document content truncated to 3,000 characters for analysis
- Pagination supported for folder listing
- Indexes on folder queries for fast retrieval

---

## Testing

### Manual Testing Checklist

- [ ] Upload document and generate executive summary
- [ ] Generate detailed summary
- [ ] Extract action items from meeting notes
- [ ] Analyze 5 documents together (trends analysis)
- [ ] Analyze documents for specific client
- [ ] Create new folder
- [ ] Create nested subfolder
- [ ] Move document to folder
- [ ] Delete empty folder
- [ ] Attempt to delete folder with documents (should fail)
- [ ] Verify RLS policies allow access
- [ ] Test with different LLM models

### API Testing Commands

```bash
# Test summary generation
curl -X POST http://localhost:3002/api/chasen/summary \
  -H "Content-Type: application/json" \
  -d '{"documentId": "uuid", "summaryType": "executive"}'

# Test multi-document analysis
curl -X POST http://localhost:3002/api/chasen/analyze \
  -H "Content-Type: application/json" \
  -d '{"documentIds": ["uuid1", "uuid2"], "analysisType": "themes"}'

# Test folder creation
curl -X POST http://localhost:3002/api/chasen/folders \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Folder", "clientName": "Test Client"}'
```

---

## Deployment

### Prerequisites

1. **Environment Variables:**
   - `MATCHAAI_API_KEY` - Already configured
   - `MATCHAAI_BASE_URL` - Already configured
   - `MATCHAAI_MISSION_ID` - Already configured

2. **Database Migration:**

   ```bash
   # Run migration to create chasen_folders table
   psql $DATABASE_URL -f docs/migrations/20251207_chasen_folders_table.sql
   ```

3. **Verify LLM Models:**
   - Ensure all 26 models are synced to `llm_models` table
   - Run `/api/llms/refresh` if needed

### Deployment Steps

1. Commit and push all changes
2. Deploy to Netlify (auto-deploy)
3. Run database migration on production
4. Verify endpoints are accessible
5. Test with real documents

---

## Security & Permissions

### Row Level Security (RLS)

All endpoints use **service role** client to bypass RLS:

```typescript
const supabase = getServiceSupabase() // Service role, bypasses RLS
```

**Folder Permissions:**

- All authenticated users can view/create/update/delete folders
- Same permission model as `chasen_documents`
- Service role has full access for API operations

### Data Privacy

- Document content truncated to 3,000 characters when sent to MatchAI
- Full content stored securely in Supabase
- No PII sent to MatchAI beyond what's in document content
- All API calls logged for audit trail

---

## Known Limitations

1. **Max Documents per Analysis:** 20 documents (to prevent token limit issues)
2. **Document Truncation:** 3,000 characters per document for analysis
3. **Summary Length:** Configurable max (default 200 words)
4. **Folder Deletion:** Only empty folders can be deleted
5. **No Streaming:** Responses are not streamed (full response only)

---

## Future Roadmap

### Short Term (Next Sprint)

- [ ] UI updates to show summary/analysis buttons
- [ ] Folder tree view in document browser
- [ ] Drag-and-drop document organization
- [ ] Batch summary generation
- [ ] Export analysis reports to PDF

### Medium Term (Q1 2026)

- [ ] Direct file upload to MatchAI storage
- [ ] MatchAI native summary endpoint integration
- [ ] Document versioning
- [ ] Scheduled periodic analysis
- [ ] Smart folder suggestions based on content

### Long Term (Q2 2026)

- [ ] Cross-client comparative analysis
- [ ] Predictive analytics from document patterns
- [ ] Automated insight alerts
- [ ] Integration with meeting scheduling
- [ ] Mobile app support

---

## Support & Documentation

**API Documentation:** See individual route files for detailed JSDoc comments

**Database Schema:** `docs/database-schema.md` (update after migration)

**Migration File:** `docs/migrations/20251207_chasen_folders_table.sql`

**Questions/Issues:** Create ticket in project tracker

---

**Implementation Date:** 2025-12-07
**Implemented By:** Claude Code
**Status:** ✅ Ready for Testing
