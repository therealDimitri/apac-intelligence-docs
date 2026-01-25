# ChaSen Preferences - Feature Design

**Date:** 2025-01-25
**Status:** Approved
**Route:** `/settings/chasen`

## Overview

A dedicated preferences page allowing users to configure ChaSen's default tone, response style, and personalisation settings. The page uses card-based sections with auto-save functionality and live preview.

## Page Structure

**Route:** `/settings/chasen`
**Title:** "ChaSen Preferences"
**Subtitle:** "Configure how ChaSen communicates and assists you"

### Layout

Three card-based sections stacked vertically:
1. Response Style
2. AI Behaviour
3. Personalisation

Header includes:
- Back link to Settings
- Page title and description
- Reset to Defaults button

---

## Card 1: Response Style

**Title:** "Response Style"
**Description:** "Control how ChaSen writes and speaks to you"

### Controls

| Setting | Type | Options | Default |
|---------|------|---------|---------|
| Tone | Dropdown | Professional, Casual, Concise, Detailed, Encouraging | Professional |
| Formality | Dropdown | Formal, Balanced, Informal | Balanced |
| Verbosity | Dropdown | Brief (<150 words), Moderate (2-3 paragraphs), Comprehensive | Moderate |
| Response Length | Dropdown | Short, Medium, Long | Medium |

### Live Preview Panel

Displays a sample response that updates dynamically as settings change:

**Example Question:** "How is Acme Corp performing?"

**Professional + Formal + Brief:**
> "Acme Corp shows stable performance. Health score: 78/100. Key metric: NPS improved 12 points this quarter."

**Casual + Informal + Comprehensive:**
> "Hey! Acme Corp is doing pretty well actually. Their health score sits at 78 out of 100, which puts them in the healthy range. The really good news? Their NPS jumped 12 points this quarter..."

Footer note: "This is a sample. Actual responses vary by context."

---

## Card 2: AI Behaviour

**Title:** "AI Behaviour"
**Description:** "Control what ChaSen includes in responses"

### Controls

| Setting | Type | Description | Default |
|---------|------|-------------|---------|
| Include Recommendations | Toggle | Suggest next actions based on context | On |
| Include Follow-up Questions | Toggle | Offer related questions to explore | On |
| Include Data Highlights | Toggle | Surface key metrics and trends automatically | On |
| Proactive Suggestions | Toggle | ChaSen initiates suggestions based on your portfolio | Off |

**Note:** Proactive Suggestions toggle includes warning: "May increase notifications"

---

## Card 3: Personalisation

**Title:** "Personalisation"
**Description:** "Tailor ChaSen's focus to your workflow"

### Controls

| Setting | Type | Description | Default |
|---------|------|-------------|---------|
| Favourite Clients | Multi-select combobox | Clients ChaSen prioritises in suggestions and alerts | Empty |
| Excluded Clients | Multi-select combobox | Clients ChaSen won't mention unless asked directly | Empty |
| Default Context | Dropdown | Starting focus for new conversations (Portfolio, Client-specific, General) | Portfolio |

### Validation Rules

- Maximum 10 favourite clients
- Excluded clients cannot overlap with favourites
- Client selectors use searchable combobox with chips

---

## Data Structure

```typescript
interface ChasenPreferences {
  // Response Style
  preferredTone: 'professional' | 'casual' | 'concise' | 'detailed' | 'encouraging'
  preferredFormality: 'formal' | 'balanced' | 'informal'
  preferredVerbosity: 'brief' | 'moderate' | 'comprehensive'
  maxResponseLength: 'short' | 'medium' | 'long'

  // AI Behaviour
  includeRecommendations: boolean
  includeFollowUps: boolean
  includeDataHighlights: boolean
  proactiveSuggestions: boolean

  // Personalisation
  favouriteClients: string[]
  excludedClients: string[]
  defaultContext: 'portfolio' | 'client' | 'general'
}
```

---

## API Integration

**Endpoint:** `/api/chasen/preferences` (existing)
**Methods:** GET, POST, PATCH

### Save Behaviour

- Auto-save with 500ms debounce
- Optimistic UI updates
- Toast confirmation: "Preferences saved"
- Error handling with rollback and retry option

### Load Behaviour

- Fetch on page mount
- Skeleton cards while loading
- Fall back to defaults if fetch fails

---

## File Structure

```
src/app/(dashboard)/settings/chasen/
├── page.tsx                    # Main page component
└── loading.tsx                 # Skeleton loading state

src/components/chasen-preferences/
├── ChasenPreferencesPage.tsx   # Page layout with cards
├── ResponseStyleCard.tsx       # Tone, formality, verbosity controls
├── AIBehaviourCard.tsx         # Toggle switches for AI features
├── PersonalisationCard.tsx     # Client selectors, default context
├── ResponsePreview.tsx         # Live preview panel
└── index.ts                    # Barrel export

src/hooks/
└── useChasenPreferences.ts     # TanStack Query hook
```

---

## Reused Components

- `Select` from `@/components/ui/select`
- `Switch` from `@/components/ui/switch`
- `Card` from `@/components/ui/card`
- `ClientCombobox` pattern from existing filters
- `toast` from sonner

---

## Navigation

### Settings Menu

```
Settings
├── Profile
├── Notifications
├── ChaSen Preferences  ← NEW
└── ...
```

### Breadcrumb

```
Settings > ChaSen Preferences
```

### Future Enhancement

Gear icon in ChaSen chat header linking to `/settings/chasen`

---

## Mobile Responsiveness

- Cards stack vertically
- Preview panel moves below controls on narrow screens
- Client multi-selects use full-width

---

## Implementation Notes

### Existing Backend Support

The `chasen_user_preferences` table and `/api/chasen/preferences` endpoint already support all required fields. No database migrations needed.

### Tone Instructions

The backend already has `getToneInstructions()` function that maps preferences to system prompt instructions. The UI simply exposes these existing capabilities.

### Dependencies

- TanStack Query (existing)
- Radix UI components (existing)
- Sonner toast (existing)
