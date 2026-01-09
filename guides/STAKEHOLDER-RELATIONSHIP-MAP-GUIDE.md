# Stakeholder Relationship Map Component

**Date Created:** 2026-01-09
**Component Location:** `/src/components/planning/StakeholderRelationshipMap.tsx`
**Related Components:**
- `/src/components/planning/StakeholderCard.tsx`
- `/src/components/planning/AddStakeholderModal.tsx`

---

## Overview

The Visual Stakeholder Relationship Map is an interactive org chart component that helps Customer Success teams map key contacts at client accounts. It provides:

- Hierarchical visualisation of stakeholders by influence level
- MEDDPICC role classification and coverage tracking
- Relationship strength indicators (sentiment)
- Drag-and-drop reordering in edit mode
- Auto-detect suggestions from meeting attendees

---

## Features

### 1. Stakeholder Cards
Each stakeholder is displayed as a card showing:
- Name and job title
- MEDDPICC role badge (EB, CH, DM, TB, CO, ES, IN, EU, BL)
- Sentiment/relationship strength indicator (green/amber/red dot)
- Contact information (email, phone)
- Last contact date
- Reports-to relationship

### 2. Hierarchical Layout
Stakeholders are automatically grouped into tiers:
- **Executive Level:** Economic Buyers, Executive Sponsors
- **Key Players:** Champions, Decision Makers, Technical Buyers, Coaches
- **Influencers & Users:** Influencers, End Users
- **Blockers/Risks:** Stakeholders identified as blockers

### 3. MEDDPICC Role Coverage
A summary panel at the bottom shows:
- Which MEDDPICC roles are filled
- Number of stakeholders per role
- Percentage of required roles covered
- Helpful tips for incomplete coverage

### 4. Edit Mode
Toggle edit mode to:
- Drag and drop stakeholders to reorder
- Add new stakeholders via modal
- Edit existing stakeholder details
- Delete stakeholders

### 5. Auto-Detect from Meeting Attendees
If meeting attendees are provided:
- Component suggests unmapped attendees
- One-click to add suggested stakeholders
- Pre-fills name, email, and title

---

## Usage

### Basic Usage

```tsx
import StakeholderRelationshipMap from '@/components/planning/StakeholderRelationshipMap'

function MyComponent() {
  const [stakeholders, setStakeholders] = useState<Stakeholder[]>([])

  return (
    <StakeholderRelationshipMap
      stakeholders={stakeholders}
      onChange={setStakeholders}
      clientName="Austin Health"
    />
  )
}
```

### With Meeting Attendee Suggestions

```tsx
const meetingAttendees = [
  { name: 'Sarah Johnson', email: 'sarah@client.com', title: 'Director of IT' },
  { name: 'Mike Chen', email: 'mike@client.com', title: 'CIO' },
]

<StakeholderRelationshipMap
  stakeholders={stakeholders}
  onChange={setStakeholders}
  meetingAttendees={meetingAttendees}
  clientName="Austin Health"
/>
```

### Read-Only Mode

```tsx
<StakeholderRelationshipMap
  stakeholders={stakeholders}
  onChange={() => {}}
  clientName="Austin Health"
  readOnly={true}
/>
```

---

## Props Reference

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `stakeholders` | `Stakeholder[]` | Yes | Array of stakeholder objects |
| `onChange` | `(stakeholders: Stakeholder[]) => void` | Yes | Callback when stakeholders are modified |
| `meetingAttendees` | `MeetingAttendee[]` | No | Optional array of meeting attendees for auto-detect |
| `clientName` | `string` | No | Client name for display (default: "this account") |
| `readOnly` | `boolean` | No | Disable editing capabilities |

---

## Type Definitions

### Stakeholder

```typescript
interface Stakeholder {
  id: string
  name: string
  title?: string
  role: StakeholderRole
  sentiment: RelationshipStrength
  email?: string
  phone?: string
  lastContact?: string
  frequency?: string
  notes?: string
  reportsTo?: string
  influenceLevel?: 'high' | 'medium' | 'low'
  department?: string
}
```

### StakeholderRole

```typescript
type StakeholderRole =
  | 'economic_buyer'    // EB - Final budget authority
  | 'champion'          // CH - Internal advocate
  | 'coach'             // CO - Provides insider guidance
  | 'decision_maker'    // DM - Part of buying decision
  | 'influencer'        // IN - Shapes opinion/direction
  | 'technical_buyer'   // TB - Evaluates technical fit
  | 'user'              // EU - End User
  | 'blocker'           // BL - Opposes the initiative
  | 'sponsor'           // ES - Executive Sponsor
```

### RelationshipStrength

```typescript
type RelationshipStrength =
  | 'strong'    // Green - Excellent relationship
  | 'positive'  // Light green - Good relationship
  | 'neutral'   // Amber - Neutral/developing
  | 'weak'      // Orange - Needs attention
  | 'negative'  // Red - Poor relationship
  | 'unknown'   // Grey - Not yet established
```

### MeetingAttendee

```typescript
interface MeetingAttendee {
  name: string
  email?: string
  title?: string
}
```

---

## MEDDPICC Role Definitions

| Role | Abbreviation | Description |
|------|--------------|-------------|
| Economic Buyer | EB | Person with final budget authority - **Required** |
| Champion | CH | Internal advocate who sells on your behalf - **Required** |
| Decision Maker | DM | Key part of the decision process |
| Technical Buyer | TB | Evaluates technical requirements |
| Coach | CO | Provides insider guidance |
| Executive Sponsor | ES | Senior leadership support |
| Influencer | IN | Shapes opinion/direction |
| End User | EU | Uses the solution |
| Blocker | BL | Opposes the initiative |

---

## Dependencies

- `@dnd-kit/core` - Drag and drop functionality
- `@dnd-kit/sortable` - Sortable behaviour
- `@dnd-kit/utilities` - CSS transform utilities
- `lucide-react` - Icons
- Tailwind CSS - Styling

---

## Integration with Account Plans

This component is designed to integrate with the Account Planning workflow:

```tsx
// In your account plan form
const [formData, setFormData] = useState<FormData>({
  // ... other fields
  stakeholders: [],
})

<StakeholderRelationshipMap
  stakeholders={formData.stakeholders}
  onChange={(stakeholders) => setFormData(prev => ({
    ...prev,
    stakeholders
  }))}
  clientName={formData.client_name}
/>
```

---

## Accessibility

- Keyboard navigation support via @dnd-kit
- ARIA labels on interactive elements
- Focus management in modals
- Colour-coded indicators have text labels for colour-blind users

---

## Future Enhancements

1. **Relationship Lines:** Visual connection lines between stakeholders showing reporting and influence relationships
2. **Stakeholder Import:** Bulk import from CRM or external sources
3. **Engagement History:** Timeline of interactions per stakeholder
4. **Influence Network Analysis:** AI-powered suggestions for relationship building
5. **Print/Export:** Generate stakeholder map as PDF or image

---

## Changelog

### v1.0.0 (2026-01-09)
- Initial implementation
- Hierarchical card layout
- MEDDPICC role coverage tracking
- Drag-and-drop reordering
- Add/Edit/Delete stakeholder modal
- Auto-detect from meeting attendees
- Sentiment/relationship strength indicators
