# Feature: SharePoint Document Search Integration

**Date:** 26 December 2025
**Status:** Disabled (Pending Admin Consent)
**Component:** ChaSen AI - SharePoint Integration

> ⚠️ **IMPORTANT**: This feature is currently disabled. The required OAuth scopes
> (`Sites.Read.All`, `Files.Read.All`) require Azure AD admin consent, which was
> blocking all user sign-ins. The scopes have been removed from auth.ts until
> admin consent is obtained. The code is in place and will work once scopes are re-added.

---

## Summary

ChaSen AI now automatically searches SharePoint for relevant documents when users ask questions about policies, procedures, templates, guides, and other internal documentation. Matching documents are displayed with direct links to open them in SharePoint.

---

## How It Works

### Automatic Detection

ChaSen detects document-related queries by looking for keywords such as:

- `document`, `file`, `template`, `guide`, `playbook`, `handbook`
- `policy`, `procedure`, `process`, `sop`, `standard`
- `training`, `onboarding`, `escalation`
- `contract`, `agreement`, `sla`
- `presentation`, `deck`, `report`, `quarterly`, `review`, `qbr`
- `implementation`, `migration`, `go-live`, `cutover`
- `best practice`, `case study`, `success story`, `reference`

### Search Flow

1. User asks a question containing document keywords
2. ChaSen extracts relevant search terms from the query
3. Microsoft Graph Search API is called with the user's access token
4. Top 3 matching documents (DOCX, PDF, PPTX, XLSX) are returned
5. Documents are included in ChaSen's context and displayed in responses

### Example Queries

- "Find the escalation process document"
- "Where's the QBR template?"
- "Show me the client onboarding guide"
- "What's our SLA policy for enterprise clients?"
- "Search SharePoint for implementation playbook"

---

## Technical Implementation

### Files Modified

| File                                 | Changes                                                                                                                                             |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `src/lib/microsoft-graph.ts`         | Added `searchSharePointDocuments()`, `getSharePointSites()`, `formatSharePointDocumentsForPrompt()`, `formatSharePointDocumentsAsLinks()` functions |
| `src/auth.ts`                        | Added `Sites.Read.All` and `Files.Read.All` OAuth scopes (lines 170, 259)                                                                           |
| `src/app/api/chasen/stream/route.ts` | Added SharePoint context fetching in parallel with dashboard data                                                                                   |

### New Functions

#### `searchSharePointDocuments(accessToken, query, options)`

Searches SharePoint using Microsoft Graph Search API (`/search/query` endpoint).

```typescript
const documents = await searchSharePointDocuments(accessToken, 'escalation process', {
  maxResults: 3,
  fileTypes: ['docx', 'pdf', 'pptx', 'xlsx'],
})
```

Returns:

```typescript
interface SharePointDocument {
  id: string
  name: string
  webUrl: string // Direct link to open in SharePoint
  fileType: string // e.g., 'docx', 'pdf'
  size: number
  lastModified: string
  lastModifiedBy: string
  sitePath: string // Folder path in SharePoint
}
```

#### `formatSharePointDocumentsForPrompt(documents)`

Formats documents as markdown for inclusion in the system prompt:

```markdown
## Relevant SharePoint Documents:

- **[Escalation Process Guide.docx](https://sharepoint.com/...)** (DOCX, 45KB)
  - Location: Client Success/Guides
  - Modified: 15 Nov 2025 by John Smith
```

#### `formatSharePointDocumentsAsLinks(documents)`

Formats documents as a link list for response footers:

```markdown
### 📎 Related Documents

- 📝 [Escalation Process Guide.docx](https://sharepoint.com/...)
- 📄 [SLA Policy 2025.pdf](https://sharepoint.com/...)
```

---

## OAuth Permissions Required

The following Microsoft Graph permissions are now requested:

| Permission       | Type      | Purpose                                      |
| ---------------- | --------- | -------------------------------------------- |
| `Sites.Read.All` | Delegated | Read SharePoint sites and document libraries |
| `Files.Read.All` | Delegated | Search and read files across SharePoint      |

### User Action Required

**Existing users must sign out and sign back in** to grant the new SharePoint permissions. The consent prompt will show the additional permissions being requested.

---

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  ChaSen AI      │────▶│ /api/chasen/     │────▶│ Microsoft Graph │
│  User Query     │     │    stream        │     │ POST /search/   │
│                 │     │                  │     │      query      │
└─────────────────┘     └──────────────────┘     └─────────────────┘
        │                        │                        │
        │                        ▼                        ▼
        │               ┌──────────────────┐     ┌─────────────────┐
        │               │ getSharePoint    │     │ SharePoint      │
        │               │ Context()        │     │ Documents       │
        │               └──────────────────┘     └─────────────────┘
        │                        │                        │
        ▼                        ▼                        ▼
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│ Response with   │◀────│ formatSharePoint │◀────│ Top 3 matching  │
│ Document Links  │     │ DocumentsFor...  │     │ documents       │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

---

## Error Handling

| Scenario                             | Behaviour                                |
| ------------------------------------ | ---------------------------------------- |
| No access token                      | SharePoint search skipped silently       |
| Token missing SharePoint permissions | Returns 403, search skipped              |
| No matching documents                | No documents shown in response           |
| Search timeout (4s)                  | Falls back to response without documents |
| Graph API error                      | Logged, search skipped                   |

---

## Performance Considerations

- SharePoint search runs in parallel with dashboard context fetching
- 4-second timeout prevents blocking the response
- Only top 3 documents returned to keep context concise
- File type filter reduces irrelevant results (only DOCX, PDF, PPTX, XLSX)

---

## Future Enhancements

1. **Semantic search**: Use document content embeddings for better relevance
2. **Document preview**: Show document snippets/excerpts in responses
3. **Specific site filtering**: Allow searching within specific SharePoint sites
4. **Document content extraction**: Read document contents for RAG-style answers
5. **Caching**: Cache recent searches to reduce API calls

---

## Testing

To test the SharePoint integration:

1. Sign out of the application
2. Sign back in with Microsoft (consent to new permissions)
3. Navigate to ChaSen AI (`/ai`)
4. Ask a document-related question, e.g., "Find the QBR template"
5. Check server logs for `[ChaSen Stream] Searching SharePoint for:` messages
6. Verify documents appear in the response with clickable links

---

## Related Files

- `src/lib/microsoft-graph.ts` - SharePoint search functions
- `src/auth.ts` - OAuth configuration with SharePoint scopes
- `src/app/api/chasen/stream/route.ts` - Integration with ChaSen
- `docs/FEATURE-20251226-outlook-email-draft-clickable-links.md` - Related Microsoft Graph feature
