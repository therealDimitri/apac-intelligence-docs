# Feature Report: ChaSen Community Detection Implementation

**Date:** 2026-01-08
**Status:** Implemented
**Priority:** Medium
**Component:** ChaSen GraphRAG (Phase 2)

---

## Feature Summary

Implemented community detection for the ChaSen knowledge graph, replacing the `// TODO: Community detection` placeholder with a working connected components algorithm.

---

## What Was Added

### 1. `detectCommunities()` Function

Detects communities across the entire graph using BFS-based connected component detection:

```typescript
export async function detectCommunities(options: {
  min_community_size?: number
  entity_types?: GraphEntityType[]
} = {}): Promise<GraphCommunity[]>
```

**Features:**
- Filters by entity types (clients, meetings, actions, etc.)
- Configurable minimum community size
- Generates descriptive names based on dominant entity type
- Uses efficient BFS traversal

### 2. `detectCommunitiesFromNodes()` Function

Detects communities within a specific set of nodes (used in hybrid RAG queries):

```typescript
export async function detectCommunitiesFromNodes(
  nodeIds: string[]
): Promise<GraphCommunity[]>
```

**Use Case:** When a user queries ChaSen, this function finds related groups within the search results.

### 3. `persistCommunities()` Function

Persists detected communities to the database for caching/analytics:

```typescript
export async function persistCommunities(
  communities: GraphCommunity[]
): Promise<number>
```

### 4. `getCommunitiesForNode()` Function

Retrieves all communities a specific node belongs to:

```typescript
export async function getCommunitiesForNode(
  nodeId: string
): Promise<GraphCommunity[]>
```

---

## Algorithm Used

**Connected Components via BFS**

1. Build adjacency list from graph edges
2. For each unvisited node, perform BFS to find all connected nodes
3. Group connected nodes into communities
4. Generate descriptive names based on node types
5. Filter by minimum size threshold

This is a simple but effective approach for finding closely related entities in the knowledge graph.

---

## Integration

The `hybridRAGQuery()` function now automatically detects communities within query results:

```typescript
// Step 4: Detect communities within the query results
const nodeIds = sortedNodes.slice(0, 20).map(n => n.id)
const communities = await detectCommunitiesFromNodes(nodeIds)

return {
  nodes: sortedNodes.slice(0, 20),
  edges: allEdges,
  communities,  // Now populated!
  context,
  confidence: avgScore,
}
```

---

## Database Schema

Uses the existing `chasen_graph_communities` table:

```sql
CREATE TABLE chasen_graph_communities (
  id UUID PRIMARY KEY,
  name TEXT,
  description TEXT,
  level INTEGER DEFAULT 0,
  parent_community_id UUID REFERENCES chasen_graph_communities(id),
  node_ids UUID[] DEFAULT '{}',
  summary TEXT,
  embedding VECTOR(1536),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Files Modified

| File | Change |
|------|--------|
| `src/lib/chasen-graph-rag.ts` | Added 4 community detection functions + updated hybridRAGQuery |

---

## Example Output

When querying "What are Epworth's recent issues?", communities might include:

```json
{
  "communities": [
    {
      "id": "query-community-1",
      "name": "Related Group 1",
      "description": "3 closely connected entities in your query results",
      "node_ids": ["node-epworth", "node-meeting-123", "node-action-456"]
    }
  ]
}
```

---

## Future Enhancements

1. **Hierarchical Communities**: Support multi-level community detection (currently flat)
2. **Community Summarisation**: Use AI to generate natural language summaries of each community
3. **Modularity Optimization**: Implement Louvain algorithm for better quality communities
4. **Community Embeddings**: Store vector embeddings for community-level similarity search
5. **Temporal Communities**: Detect communities that evolve over time

---

## Testing

The implementation can be tested by:

1. Syncing the graph: `await syncFullGraph()`
2. Detecting communities: `await detectCommunities({ min_community_size: 3 })`
3. Querying with communities: `await hybridRAGQuery("client issues", embedding)`
