# LLM Refresh System

## Overview

The LLM Refresh System provides dynamic management of available AI models from the MatchAI API platform. Instead of hardcoding model options, the system automatically syncs available LLMs to the database and exposes them through API endpoints, allowing the frontend to display up-to-date model options.

## Architecture

### Database Schema

**Table:** `llm_models`

| Column         | Type        | Description                                              |
| -------------- | ----------- | -------------------------------------------------------- |
| id             | SERIAL      | Primary key                                              |
| matcha_llm_id  | INTEGER     | MatchAI's LLM ID (e.g., 28 for Claude Sonnet 4) - UNIQUE |
| model_name     | TEXT        | Human-readable name (e.g., "Claude 3.7 Sonnet")          |
| model_key      | TEXT        | Frontend identifier (e.g., "claude-3-7-sonnet")          |
| provider       | TEXT        | AI provider (e.g., "anthropic", "openai", "google")      |
| capabilities   | JSONB       | Model capabilities (context_window, features, etc.)      |
| is_active      | BOOLEAN     | Whether model is currently available                     |
| is_default     | BOOLEAN     | Default model for new conversations                      |
| display_order  | INTEGER     | Sort order in dropdown (lower = higher priority)         |
| created_at     | TIMESTAMPTZ | Creation timestamp                                       |
| updated_at     | TIMESTAMPTZ | Last update timestamp                                    |
| last_synced_at | TIMESTAMPTZ | Last sync from MatchAI API                               |

**Indexes:**

- `idx_llm_models_matcha_id` on `matcha_llm_id` - Fast lookups by MatchAI ID
- `idx_llm_models_active` on `is_active` - Fast filtering of active models

**RLS Policies:**

- Read access: All authenticated users can read active models
- Write access: Service role only (API management)

### API Endpoints

#### 1. GET /api/llms

Fetches list of active LLM models from database.

**Response:**

```json
{
  "models": [
    {
      "id": 1,
      "matcha_llm_id": 28,
      "model_name": "Claude 3.7 Sonnet",
      "model_key": "claude-3-7-sonnet",
      "provider": "anthropic",
      "capabilities": {
        "context_window": 200000,
        "supports_vision": false,
        "supports_tools": true
      },
      "is_active": true,
      "is_default": true,
      "display_order": 1
    }
  ],
  "defaultModel": "claude-3-7-sonnet",
  "count": 5,
  "lastSynced": "2025-12-07T10:30:00Z"
}
```

#### 2. POST /api/llms/refresh

Manually triggers LLM sync from MatchAI API (or updates from hardcoded mapping).

**Response:**

```json
{
  "success": true,
  "syncResults": {
    "added": 0,
    "updated": 5,
    "failed": 0,
    "errors": []
  },
  "models": [...],
  "timestamp": "2025-12-07T10:30:00Z"
}
```

### Frontend Integration

**FloatingChaSenAI.tsx** dynamically loads available models on component mount:

```typescript
// Fetch available LLM models on mount
useEffect(() => {
  const fetchModels = async () => {
    try {
      const res = await fetch('/api/llms')
      if (res.ok) {
        const data = await res.json()
        setAvailableModels(data.models || [])
        if (data.defaultModel && !selectedModel) {
          setSelectedModel(data.defaultModel)
        }
      }
    } catch (error) {
      console.error('[ChaSen] Error fetching LLM models:', error)
      // Fallback to default model if fetch fails
      setAvailableModels([])
    } finally {
      setIsLoadingModels(false)
    }
  }

  fetchModels()
}, [])
```

**Model Selector:**

```tsx
<select value={selectedModel} onChange={e => setSelectedModel(e.target.value)}>
  {isLoadingModels ? (
    <option>Loading models...</option>
  ) : availableModels.length > 0 ? (
    availableModels.map(model => (
      <option key={model.model_key} value={model.model_key}>
        {model.model_name}
      </option>
    ))
  ) : (
    // Fallback to hardcoded models if API fails
    <>
      <option value="claude-3-7-sonnet">Claude 3.7 Sonnet</option>
      ...
    </>
  )}
</select>
```

### Backend Integration

**ChaSen Chat API** (`src/app/api/chasen/chat/route.ts`) maps model_key to matcha_llm_id:

```typescript
// Map model key to MatchaAI LLM ID
let selectedLlmId = 28 // Default to Claude Sonnet 4
if (model) {
  try {
    // Look up model in database to get matcha_llm_id
    const supabase = getServiceSupabase()
    const { data: modelData } = await supabase
      .from('llm_models')
      .select('matcha_llm_id')
      .eq('model_key', model)
      .eq('is_active', true)
      .single()

    if (modelData?.matcha_llm_id) {
      selectedLlmId = modelData.matcha_llm_id
      console.log(`[ChaSen Chat] Using model: ${model} (MatchaAI LLM ID: ${selectedLlmId})`)
    } else {
      console.warn(`[ChaSen Chat] Model ${model} not found, using default (ID: ${selectedLlmId})`)
    }
  } catch (error) {
    console.error(`[ChaSen Chat] Error looking up model ${model}, using default:`, error)
  }
}

// Call MatchaAI API with mapped LLM ID
const matchaResponse = await fetch(`${MATCHAAI_CONFIG.baseUrl}/completions`, {
  method: 'POST',
  headers: {
    'MATCHA-API-KEY': MATCHAAI_CONFIG.apiKey,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    mission_id: parseInt(MATCHAAI_CONFIG.missionId),
    llm_id: selectedLlmId, // MatchaAI integer ID
    input: `${systemPrompt}\n\n${userPrompt}`,
  }),
})
```

## Deployment

### Step 1: Create Database Table

Run the SQL migration in Supabase SQL Editor:

```bash
# Location: docs/migrations/20251207_llm_models_table.sql
```

Or use the automated script:

```bash
node scripts/create-llm-models-table-simple.mjs
```

### Step 2: Initial Seed Data

The migration automatically seeds 5 default models:

1. Claude 3.7 Sonnet (ID: 28) - DEFAULT
2. Claude 3.5 Sonnet (ID: 25)
3. Claude Opus 4.1 (ID: 30)
4. Gemini 2.5 Flash-Lite (ID: 35)
5. GPT-4o (ID: 40)

### Step 3: Verify Installation

```bash
# Check table exists and has seed data
node scripts/create-llm-models-table-simple.mjs
```

Expected output:

```
✅ Found 5 LLM models in database:
   🟢 Claude 3.7 Sonnet (ID: 28, Key: claude-3-7-sonnet) [DEFAULT]
   🟢 Claude 3.5 Sonnet (ID: 25, Key: claude-3-5-sonnet)
   🟢 Claude Opus 4.1 (ID: 30, Key: claude-3-opus-4-1)
   🟢 Gemini 2.5 Flash-Lite (ID: 35, Key: gemini-2-5-flash-lite)
   🟢 GPT-4o (ID: 40, Key: gpt-4o)
```

## Model Mapping

The system maintains a mapping between frontend model_key and MatchAI LLM IDs:

| Model Name            | Model Key             | MatchaAI LLM ID | Provider  |
| --------------------- | --------------------- | --------------- | --------- |
| Claude 3.7 Sonnet     | claude-3-7-sonnet     | 28              | anthropic |
| Claude 3.5 Sonnet     | claude-3-5-sonnet     | 25              | anthropic |
| Claude Opus 4.1       | claude-3-opus-4-1     | 30              | anthropic |
| Gemini 2.5 Flash-Lite | gemini-2-5-flash-lite | 35              | google    |
| GPT-4o                | gpt-4o                | 40              | openai    |

**Note:** These IDs are specific to the MatchAI platform and may differ from other platforms.

## Future Enhancements

### 1. Automatic Refresh from MatchAI API

When MatchAI provides an endpoint to list available LLMs:

```typescript
// In /api/llms/refresh/route.ts
const matchaResponse = await fetch(`${MATCHAAI_CONFIG.baseUrl}/llms`, {
  method: 'GET',
  headers: {
    'MATCHA-API-KEY': MATCHAAI_CONFIG.apiKey,
    'Content-Type': 'application/json',
  },
})

const availableModels = await matchaResponse.json()
```

### 2. Periodic Automatic Refresh

**Option A: Cron Job (Vercel Cron)**

Add to `vercel.json`:

```json
{
  "crons": [
    {
      "path": "/api/llms/refresh",
      "schedule": "0 0 * * *"
    }
  ]
}
```

**Option B: Server-Side Scheduled Task**

Using node-cron or similar:

```typescript
import cron from 'node-cron'

// Refresh models daily at midnight
cron.schedule('0 0 * * *', async () => {
  console.log('[LLM Refresh] Running scheduled refresh...')
  await fetch('http://localhost:3002/api/llms/refresh', {
    method: 'POST',
  })
})
```

### 3. Model Capabilities UI

Display model capabilities in dropdown:

```tsx
<option value={model.model_key} title={JSON.stringify(model.capabilities)}>
  {model.model_name}
  {model.capabilities.supports_vision && ' 👁️'}
  {model.capabilities.supports_files && ' 📎'}
</option>
```

### 4. Model Usage Analytics

Track which models are most frequently used:

```sql
CREATE TABLE llm_usage_stats (
  id SERIAL PRIMARY KEY,
  model_key TEXT NOT NULL,
  request_count INTEGER DEFAULT 0,
  last_used TIMESTAMPTZ DEFAULT NOW()
);
```

## Troubleshooting

### Issue: Models not appearing in dropdown

**Diagnosis:**

1. Check browser console for errors
2. Verify `/api/llms` endpoint returns data
3. Check database table exists and has rows

**Solution:**

```bash
# Verify table exists
node scripts/create-llm-models-table-simple.mjs

# Check API endpoint
curl http://localhost:3002/api/llms
```

### Issue: Wrong model being used for chat

**Diagnosis:**

1. Check ChaSen Chat API logs for model mapping
2. Verify model_key matches database

**Solution:**

```sql
-- Check models in database
SELECT model_key, matcha_llm_id, is_active FROM llm_models;

-- Verify model is active
UPDATE llm_models SET is_active = true WHERE model_key = 'claude-3-7-sonnet';
```

### Issue: Model refresh fails

**Diagnosis:**

1. Check Supabase service role key is valid
2. Verify RLS policies allow service role to write

**Solution:**

```sql
-- Check RLS policies
SELECT * FROM pg_policies WHERE tablename = 'llm_models';

-- Grant service role access if needed
CREATE POLICY "Service role can manage models" ON llm_models
  FOR ALL
  USING (auth.jwt()->>'role' = 'service_role');
```

## Files Modified

### Database

- `docs/migrations/20251207_llm_models_table.sql` - Table schema and seed data
- `scripts/deploy-llm-models-table.mjs` - Automated deployment script
- `scripts/create-llm-models-table-simple.mjs` - Simple verification script

### API Routes

- `src/app/api/llms/route.ts` - GET endpoint for fetching models
- `src/app/api/llms/refresh/route.ts` - POST endpoint for syncing models
- `src/app/api/chasen/chat/route.ts` - Updated to map model_key → matcha_llm_id

### Frontend Components

- `src/components/FloatingChaSenAI.tsx` - Dynamic model loading and dropdown

## Testing

### Manual Testing

1. **Verify table creation:**

   ```bash
   node scripts/create-llm-models-table-simple.mjs
   ```

2. **Test GET /api/llms:**

   ```bash
   curl http://localhost:3002/api/llms | jq
   ```

3. **Test POST /api/llms/refresh:**

   ```bash
   curl -X POST http://localhost:3002/api/llms/refresh | jq
   ```

4. **Test model selection in UI:**
   - Open ChaSen AI modal
   - Verify 5 models appear in dropdown
   - Select different model
   - Send a message
   - Check console for "Using model: ... (MatchaAI LLM ID: ...)"

### Integration Testing

```typescript
// Test model mapping
const response = await fetch('/api/chasen/chat', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    question: 'Test question',
    model: 'claude-3-5-sonnet', // Should map to ID 25
  }),
})

// Verify correct model ID was used (check server logs)
```

## Performance Considerations

- **Database Query Optimization:** Model lookup uses indexed column (model_key)
- **Caching:** Consider adding Redis cache for frequently accessed models
- **Fallback Strategy:** Hardcoded models in dropdown if API fails
- **Loading State:** UI shows "Loading models..." during fetch

## Security

- **RLS Policies:** Only active models visible to authenticated users
- **Service Role:** Only API endpoints with service role can modify models
- **Input Validation:** model_key validated against database before use
- **Error Handling:** Failed lookups fall back to default model (ID: 28)

## Monitoring

**Key Metrics to Track:**

1. Model refresh success/failure rate
2. Model usage distribution
3. API response times for /api/llms
4. Failed model lookups (warnings in logs)

**Recommended Logging:**

```typescript
console.log(`[LLM Refresh] Synced ${syncResults.added + syncResults.updated} models`)
console.warn(`[ChaSen Chat] Model ${model} not found, using default`)
console.error(`[LLM Refresh] Failed to sync models:`, error)
```
