# Bug Report: Missing Add Risk Functionality in Risk & Recovery Step

**Date:** 2026-01-14
**Status:** Fixed
**Priority:** High
**Component:** Strategic Planning - Risk & Recovery Step

---

## Issue Description

**Problem:** The Risk & Recovery step displayed existing risks but had no UI to add new risks. Users could only view risks, not create them.

**User Report:** "There is no way to add risks in the risk and recovery step. Add the best UI/UX design to add risks by pipeline opportunity by client."

---

## Root Cause Analysis

The Risk & Recovery step was designed with:
1. Risk Overview section showing aggregate risk metrics
2. Risk cards displaying existing risks
3. Empty state when no risks exist

However, no input mechanism existed to create new risks.

---

## Solution Implemented

Added a comprehensive AddRiskForm component with client and pipeline opportunity selection, plus risk metadata fields.

### Features Added:

1. **Add Risk Button** - In Risk Overview section header
2. **Empty State CTA** - "Add Your First Risk" button when no risks exist
3. **AddRiskForm Component** - Full-featured risk input form

---

## Technical Changes

### File Modified
**`src/app/(dashboard)/planning/strategic/new/steps/RiskRecoveryStep.tsx`**

### Imports Added (Line ~10)
```tsx
import type { Risk, PortfolioClient, PipelineOpportunity } from './types'
```

### Props Added (Line ~30)
```tsx
interface RiskRecoveryStepProps {
  // ... existing props
  opportunities?: PipelineOpportunity[]
}
```

### State Added (Line ~80)
```tsx
const [showAddRiskForm, setShowAddRiskForm] = useState(false)
```

### Callbacks Added (Lines ~100-120)
```tsx
const addRisk = useCallback(
  (newRisk: Omit<Risk, 'id'>) => {
    const risk: Risk = { ...newRisk, id: `risk-${Date.now()}` }
    onUpdateRisks([...risks, risk])
    setShowAddRiskForm(false)
  },
  [risks, onUpdateRisks]
)

const deleteRisk = useCallback(
  (riskId: string) => {
    onUpdateRisks(risks.filter((r) => r.id !== riskId))
  },
  [risks, onUpdateRisks]
)
```

### UI Changes

#### Add Risk Button (In Risk Overview Header)
```tsx
<button
  onClick={() => setShowAddRiskForm(true)}
  className="flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
>
  <Plus className="w-4 h-4" />
  Add Risk
</button>
```

#### Empty State Update
```tsx
<button
  onClick={() => setShowAddRiskForm(true)}
  className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
>
  Add Your First Risk
</button>
```

### AddRiskForm Helper Component (~190 lines)

```tsx
function AddRiskForm({
  clients,
  opportunities,
  onAdd,
  onCancel,
}: {
  clients: PortfolioClient[]
  opportunities: PipelineOpportunity[]
  onAdd: (risk: Omit<Risk, 'id'>) => void
  onCancel: () => void
}) {
  // Form state
  const [selectedClientId, setSelectedClientId] = useState('')
  const [selectedOpportunityId, setSelectedOpportunityId] = useState('')
  const [description, setDescription] = useState('')
  const [severity, setSeverity] = useState<'critical' | 'high' | 'medium' | 'low'>('medium')
  const [competitiveThreat, setCompetitiveThreat] = useState<'none' | 'low' | 'medium' | 'high'>('none')
  const [relationshipStrength, setRelationshipStrength] = useState<'strong' | 'moderate' | 'weak'>('moderate')
  const [revenueAtRisk, setRevenueAtRisk] = useState('')

  // ... form implementation
}
```

### Form Fields:

1. **Client Selection** - Dropdown of portfolio clients
2. **Pipeline Opportunity** - Dropdown filtered by selected client
3. **Risk Description** - Textarea for detailed description
4. **Severity Level** - Critical/High/Medium/Low dropdown
5. **Competitive Threat** - None/Low/Medium/High dropdown
6. **Relationship Strength** - Strong/Moderate/Weak dropdown
7. **Revenue at Risk** - Currency input field

---

## Testing Checklist

- [x] Add Risk button appears in Risk Overview header
- [x] Add Risk button appears in empty state
- [x] AddRiskForm displays when button clicked
- [x] Client dropdown populates with portfolio clients
- [x] Opportunity dropdown filters by selected client
- [x] Form validation prevents empty submissions
- [x] Risk is added to list on submit
- [x] Form cancellation works
- [x] Build passes with no TypeScript errors
- [x] No console errors

---

## Design Considerations

### Why By Client/Opportunity?
1. **Contextual Risks** - Risks are tied to specific business contexts
2. **Revenue Impact** - Can calculate total revenue at risk per client
3. **Action Planning** - Easier to assign mitigation actions when risk is linked to opportunity
4. **Reporting** - Enables risk aggregation by client or opportunity

### Form UX Decisions
1. **Progressive Disclosure** - Client must be selected before opportunities shown
2. **Smart Defaults** - Medium severity, None competitive threat, Moderate relationship
3. **Clear Actions** - Cancel and Add Risk buttons clearly distinguished
4. **Inline Form** - Appears in context rather than modal for better flow

---

## Related Components

- Risk Overview section displays aggregate metrics
- Risk cards show individual risks with delete capability
- AI Suggestions section provides risk mitigation advice

---

## Notes

- Risks are stored in component state and passed via onUpdateRisks callback
- Future enhancement: Persist risks to database
- Revenue at Risk field accepts numeric input formatted as currency
