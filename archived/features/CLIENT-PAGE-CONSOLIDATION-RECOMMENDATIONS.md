# Client Health vs Client Segmentation Page Consolidation

**Date**: 2025-11-28
**Purpose**: Consolidate Client Health page functionality into Client Segmentation as the master client view
**Status**: Recommendations - Pending Implementation

---

## Executive Summary

After comprehensive analysis of both pages, I've identified significant overlap and unique features. The Client Segmentation page should become the master client view by incorporating the best features from Client Health page while maintaining its unique segment-based organisation and event compliance tracking.

**Key Recommendation**: Merge all unique Client Health features into Client Segmentation, then redirect `/clients` to `/segmentation` or repurpose Client Health page for a different view.

---

## Current State Analysis

### Client Health Page (`/clients`) - 742 lines

**Primary Features**:

1. **Search & Filtering**
   - Search by client name or CSE name
   - URL parameter filtering (`?filter=improving/declining`)
   - Specific client filtering (`?clients=ClientA,ClientB`)
   - Active filter banner with clear option

2. **Stats Overview** (4 cards)
   - Healthy clients count
   - At-Risk clients count
   - Critical clients count
   - Total clients count

3. **Client Table View**
   - Sortable columns (implicitly by health score - lowest first)
   - Columns: Client Logo, Name, Status Badge, NPS Score, Health Score (with progress bar), CSE, Last Meeting Date, Open Actions, View Details button
   - Hover effects on rows

4. **Client Detail Modal** (Unique - Most Valuable Feature)
   - **Header**: Client logo, name, close button
   - **Status Banner**: Current status with health score (colour-coded background)
   - **Metrics Grid**: 4 cards (NPS Score, Open Actions, CSE Owner, Last Meeting Date)
   - **Health Score Breakdown Accordion** (CRITICAL FEATURE):
     - Visual breakdown of 4 weighted components with progress bars:
       - NPS Score (40% weight) - shows current NPS value
       - Engagement (30% weight) - based on survey responses and meetings
       - Actions Risk (20% weight) - shows open actions count, loses 2 points per action
       - Recency (10% weight) - days since last interaction
     - Total Health Score display
     - Color-coded progress bars (purple, blue, orange, green)
     - Explanatory text for each component
   - **AI Insights Accordion** (CRITICAL FEATURE):
     - Key Issues Identified (with severity badges: high/medium/low)
     - Recommended Actions (numbered, prioritised list)
     - Context-aware suggestions based on:
       - NPS scores (negative, below 50, missing data)
       - Meeting frequency (90+ days, 60+ days, no history)
       - Open actions count (>5, >2)
       - Health score trends (<50, <75, ≥75)
   - **Footer**: Client ID, Last Updated timestamp, Close button, "View Full Profile" button

5. **AI Insight Generation** (Lines 79-142)
   - Dynamic issue detection based on:
     - NPS thresholds (negative, <50, null)
     - Days since last meeting (>90, >60, null)
     - Open actions count (>5, >2)
     - Health score ranges (<50, <75, ≥75)
   - Prioritized recommendations with actionable next steps

### Client Segmentation Page (`/segmentation`) - 895 lines

**Primary Features**:

1. **View Mode Toggle**
   - Client View (current analysis)
   - CSE View (CSE workload analysis)
   - APAC View button (navigates to /apac)

2. **Stats Overview** (4 cards)
   - Total Clients count
   - Healthy Clients count
   - At-Risk Clients count
   - Critical Clients count
   - **Note**: Identical to Client Health stats

3. **Search & Filtering**
   - Search by client name or CSE
   - Segment filter buttons (All Segments, Giant, Collaboration, Leverage, Maintain, Nurture, Sleeping Giant)
   - **Note**: No URL parameter filtering support

4. **Segment-Based Organization** (Unique - Core Feature)
   - Segment cards with icons, colours, descriptions
   - Segment header with icon, description, client count
   - Segment stats (Avg NPS, Avg Health, Healthy/At-Risk/Critical counts)
   - Official APAC Client Segmentation definitions (August 2024)
   - Client cards organized by segment priority (Giant → Sleeping Giant)

5. **Client Cards** (Within Segments)
   - Client logo, name, status badge
   - CSE, NPS, Health score display
   - Health Score progress bar (0-100%)
   - **Compliance Score progress bar** (Unique - not in Client Health)
   - Expandable detail panel (chevron indicator)

6. **Client Event Detail Panel** (Unique - Expanded View)
   - **Event Compliance Overview**:
     - Overall compliance score and status
     - Event types count, compliant count, remaining count
   - **AI Predictions & Insights**:
     - Predicted year-end score
     - Risk assessment with progress bar
     - Confidence score display
     - Risk factors list
     - Recommended actions (top 5)
   - **Event Type Breakdown**:
     - Event name, priority badge, status badge
     - Actual vs expected counts, remaining events
     - Compliance percentage with progress bar
     - Sorted by priority then compliance
   - **AI-Recommended Event Schedule**:
     - Suggested events with urgency, reason, date, compliance impact
     - "Schedule Event" button → ScheduleEventModal
   - **ScheduleEventModal Integration**:
     - Create new events for client
     - Refreshes compliance and predictions on save

7. **CSE Workload View** (Separate Component)
   - CSE-centric view of client portfolio
   - Workload metrics per CSE
   - Client assignments and compliance tracking

---

## Feature Comparison Matrix

| Feature                        | Client Health          | Client Segmentation      | Winner       | Action                             |
| ------------------------------ | ---------------------- | ------------------------ | ------------ | ---------------------------------- |
| **Search by name/CSE**         | ✅                     | ✅                       | Tie          | Keep                               |
| **URL parameter filtering**    | ✅ (?filter, ?clients) | ❌                       | Health       | **Add to Segmentation**            |
| **Active filter banner**       | ✅                     | ❌                       | Health       | **Add to Segmentation**            |
| **Stats Overview**             | ✅ (4 cards)           | ✅ (4 cards)             | Tie          | Keep                               |
| **Segment filtering**          | ❌                     | ✅                       | Segmentation | Keep                               |
| **Segment-based organisation** | ❌                     | ✅                       | Segmentation | **Core - Keep**                    |
| **Segment icons/colours**      | ❌                     | ✅                       | Segmentation | **Core - Keep**                    |
| **Segment stats**              | ❌                     | ✅ (Avg NPS, Avg Health) | Segmentation | **Core - Keep**                    |
| **Client table view**          | ✅                     | ❌ (card view)           | Health       | **Optional - Consider adding**     |
| **Client card view**           | ❌                     | ✅                       | Segmentation | **Core - Keep**                    |
| **Health Score display**       | ✅ (table)             | ✅ (card + progress bar) | Segmentation | Keep                               |
| **Compliance Score display**   | ❌                     | ✅                       | Segmentation | **Core - Keep**                    |
| **Client Detail Modal**        | ✅                     | ❌                       | Health       | **CRITICAL - Add to Segmentation** |
| **Health Score Breakdown**     | ✅ (4 components)      | ❌                       | Health       | **CRITICAL - Add to Segmentation** |
| **AI Insights (modal)**        | ✅                     | ❌                       | Health       | **CRITICAL - Add to Segmentation** |
| **Event Compliance Panel**     | ❌                     | ✅                       | Segmentation | **Core - Keep**                    |
| **AI Predictions Panel**       | ❌                     | ✅                       | Segmentation | **Core - Keep**                    |
| **Event Type Breakdown**       | ❌                     | ✅                       | Segmentation | **Core - Keep**                    |
| **Schedule Event Modal**       | ❌                     | ✅                       | Segmentation | **Core - Keep**                    |
| **CSE View toggle**            | ❌                     | ✅                       | Segmentation | **Core - Keep**                    |
| **Expandable client details**  | ❌ (modal)             | ✅ (inline)              | Both         | **Hybrid Approach**                |

---

## Overlap Analysis

### Duplicated Features (100% Overlap)

1. **Search functionality** - Identical implementation
2. **Stats Overview** - Identical 4-card layout with same metrics
3. **Health Score display** - Both show health scores with colour coding
4. **Status badges** - Both use healthy/at-risk/critical badges

### Partially Overlapping Features

1. **Client Details**:
   - **Health**: Modal-based with deep health score breakdown and AI insights
   - **Segmentation**: Inline expandable panel with event compliance and predictions
   - **Recommendation**: Hybrid approach - keep inline expansion but add modal for detailed health breakdown

2. **Filtering**:
   - **Health**: URL parameters + search
   - **Segmentation**: Segment buttons + search
   - **Recommendation**: Combine both - URL parameters + segment buttons + search

---

## Consolidation Strategy

### Phase 1: Add Missing Features to Client Segmentation (Priority Order)

#### 1.1 Add Client Detail Modal (CRITICAL)

**Impact**: High - Provides crucial health score breakdown and AI insights
**Effort**: Medium - 200-300 lines of code
**Location**: New modal component in `src/components/ClientDetailModal.tsx`

**Features to Include**:

- Reuse existing modal code from Client Health page
- Trigger: Add "View Details" button to client cards OR double-click client card
- Keep all 4 sections:
  - Status Banner
  - Metrics Grid
  - Health Score Breakdown Accordion
  - AI Insights Accordion
- Adapt for segment context (show segment badge in modal)

**Implementation Steps**:

1. Extract modal code from `/clients/page.tsx` lines 417-728
2. Create `src/components/ClientDetailModal.tsx`
3. Add prop: `client: Client` (from useClients hook)
4. Add prop: `segment: string` (from segmentation data)
5. Modify header to show segment badge
6. Keep all existing accordion functionality
7. Update footer buttons (close, view full profile)
8. Add to Client Segmentation page:
   - Import modal component
   - Add state: `selectedClient` and `setSelectedClient`
   - Add button/click handler to client cards
   - Render modal when client is selected

#### 1.2 Add URL Parameter Filtering (HIGH)

**Impact**: Medium - Enables deep linking and navigation from Command Centre
**Effort**: Low - 50-100 lines of code

**Features to Add**:

1. Support `?filter=improving/declining` parameter
2. Support `?clients=ClientA,ClientB` parameter
3. Support `?segment=Giant` parameter (new)
4. Add active filter banner (similar to Client Health page)
5. Add "Clear Filter" button in banner

**Implementation Steps**:

1. Import `useSearchParams` from next/navigation (already imported)
2. Parse URL parameters (lines 379-385 area)
3. Modify `filteredSegments` useMemo to apply URL filters
4. Add filter banner component (after header, before stats)
5. Add clear filter logic (redirect to `/segmentation`)

#### 1.3 Enhance AI Insights Generation (MEDIUM)

**Impact**: Medium - Improves client intelligence
**Effort**: Low - Already exists in Client Health, just import

**Features to Add**:

1. Import `generateAIInsights` function from Client Health page
2. Use in Client Detail Modal (when added in step 1.1)
3. Consider adding quick insights to inline expanded panel

**Implementation Steps**:

1. Create `src/lib/clientAIInsights.ts`
2. Move `generateAIInsights` function from Client Health page
3. Import in Client Segmentation page
4. Use in Client Detail Modal

#### 1.4 Add Health Score Breakdown Visualization (MEDIUM)

**Impact**: High - Critical for understanding health score calculation
**Effort**: Low - Already exists in Client Health, just import

**Features to Add**:

1. Import `calculateHealthBreakdown` function
2. Add accordion to Client Detail Modal (already included in step 1.1)

**Implementation Steps**:

1. Add `calculateHealthBreakdown` to `src/lib/clientAIInsights.ts`
2. Use in Client Detail Modal accordion

### Phase 2: UI/UX Enhancements

#### 2.1 Add "Quick View" Toggle (OPTIONAL)

**Impact**: Low - Convenience feature
**Effort**: Medium

**Feature**:

- Toggle between "Expanded" and "Compact" view modes
- Compact: Show only client cards (current)
- Expanded: Auto-expand all clients to show compliance panels

#### 2.2 Add Bulk Actions (OPTIONAL)

**Impact**: Low - Power user feature
**Effort**: High

**Features**:

- Multi-select clients
- Bulk schedule events
- Bulk export client reports

### Phase 3: Deprecate Client Health Page

#### 3.1 Option A: Redirect to Client Segmentation

**Approach**: Add redirect in `/clients/page.tsx`

```typescript
'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'

export default function ClientsPage() {
  const router = useRouter()

  useEffect(() => {
    router.replace('/segmentation')
  }, [router])

  return null
}
```

#### 3.2 Option B: Repurpose as "Client List View"

**Approach**: Keep Client Health page as a simple table view (no segments)

**Features to Keep**:

- Table view (no segments)
- Search and sort
- Quick stats overview
- Link to view client in segmentation page

**Use Case**: Users who prefer table view over card/segment view

#### 3.3 Option C: Update Sidebar Navigation

**Approach**: Remove "Client Health" from sidebar, keep only "Client Segmentation"

---

## Technical Implementation Guide

### Step 1: Create Shared Components

#### File: `src/components/ClientDetailModal.tsx`

```typescript
'use client'

import { useState } from 'react'
import { Client } from '@/hooks/useClients'
import ClientLogoDisplay from '@/components/ClientLogoDisplay'
import { generateAIInsights, calculateHealthBreakdown } from '@/lib/clientAIInsights'
import {
  X,
  ChevronDown,
  TrendingUp,
  Lightbulb,
  AlertCircle,
  CheckCircle2,
  XCircle,
  AlertTriangle,
} from 'lucide-react'

interface ClientDetailModalProps {
  client: Client
  segment: string
  onClose: () => void
}

export function ClientDetailModal({ client, segment, onClose }: ClientDetailModalProps) {
  const [showHealthBreakdown, setShowHealthBreakdown] = useState(false)
  const [showAIInsights, setShowAIInsights] = useState(false)

  const insights = generateAIInsights(client)
  const breakdown = calculateHealthBreakdown(client)

  // ... (rest of modal implementation from Client Health page)
}
```

#### File: `src/lib/clientAIInsights.ts`

```typescript
import { Client } from '@/hooks/useClients'

export function generateAIInsights(client: Client) {
  // ... (copy from Client Health page lines 79-142)
}

export function calculateHealthBreakdown(client: Client) {
  // ... (copy from Client Health page lines 144-176)
}
```

### Step 2: Update Client Segmentation Page

#### Add Modal State (after line 383)

```typescript
const [selectedClientForModal, setSelectedClientForModal] = useState<(typeof clients)[0] | null>(
  null
)
const [selectedClientSegment, setSelectedClientSegment] = useState<string>('')
```

#### Add View Details Button to Client Card (around line 806)

```typescript
<div className="flex items-centre gap-4">
  {/* ... existing health/compliance progress bars ... */}

  <button
    onClick={(e) => {
      e.stopPropagation()
      setSelectedClientForModal(client)
      setSelectedClientSegment(segment)
    }}
    className="px-3 py-1 text-sm font-medium text-purple-700 hover:text-purple-900 hover:bg-purple-50 rounded-lg transition-colours"
  >
    View Details
  </button>

  {/* ... existing chevron ... */}
</div>
```

#### Add Modal Render (before closing div, around line 893)

```typescript
{selectedClientForModal && (
  <ClientDetailModal
    client={selectedClientForModal}
    segment={selectedClientSegment}
    onClose={() => {
      setSelectedClientForModal(null)
      setSelectedClientSegment('')
    }}
  />
)}
```

### Step 3: Add URL Parameter Filtering

#### Parse URL Parameters (after line 383)

```typescript
const searchParams = useSearchParams()
const filterType = searchParams.get('filter') // improving/declining
const clientsParam = searchParams.get('clients') // ClientA,ClientB
const segmentParam = searchParams.get('segment') // Giant
```

#### Update Filtered Segments Logic (replace lines 518-537)

```typescript
const filteredSegments = useMemo(() => {
  let filtered = { ...segmentedClients }

  // Apply segment parameter from URL
  if (segmentParam && SEGMENT_CONFIG[segmentParam]) {
    setSelectedSegment(segmentParam)
    filtered = { [segmentParam]: segmentedClients[segmentParam] || [] }
  }
  // Apply manual segment selection
  else if (selectedSegment) {
    filtered = { [selectedSegment]: segmentedClients[selectedSegment] || [] }
  }

  // Apply filter type (improving/declining) from URL
  if (filterType === 'improving') {
    Object.keys(filtered).forEach(segment => {
      filtered[segment] = filtered[segment].filter(c => c.nps_score !== null && c.nps_score >= 50)
    })
  } else if (filterType === 'declining') {
    Object.keys(filtered).forEach(segment => {
      filtered[segment] = filtered[segment].filter(c => c.nps_score !== null && c.nps_score < 50)
    })
  }

  // Apply specific clients parameter from URL
  if (clientsParam) {
    const targetClients = clientsParam.split(',').map(c => c.trim())
    Object.keys(filtered).forEach(segment => {
      filtered[segment] = filtered[segment].filter(c => targetClients.includes(c.name))
    })
  }

  // Apply search term within each segment
  if (searchTerm) {
    Object.keys(filtered).forEach(segment => {
      filtered[segment] = filtered[segment].filter(
        client =>
          client.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
          client.cse_name?.toLowerCase().includes(searchTerm.toLowerCase())
      )
    })
  }

  return filtered
}, [segmentedClients, selectedSegment, segmentParam, filterType, clientsParam, searchTerm])
```

#### Add Active Filter Banner (after search section, around line 693)

```typescript
{/* Active Filter Banner */}
{(filterType || clientsParam || segmentParam) && (
  <div className="mb-6 flex items-centre justify-between bg-purple-50 border border-purple-200 rounded-lg px-4 py-3">
    <div className="flex items-centre space-x-2">
      <span className="text-sm font-medium text-purple-900">
        Active Filters:
        {filterType && ` ${filterType === 'improving' ? 'Improving' : 'Declining'} clients`}
        {segmentParam && ` in ${segmentParam} segment`}
        {clientsParam && ` (${clientsParam.split(',').length} specific client${clientsParam.split(',').length > 1 ? 's' : ''})`}
      </span>
    </div>
    <a
      href="/segmentation"
      className="text-sm font-medium text-purple-700 hover:text-purple-900 flex items-centre space-x-1"
    >
      <X className="h-4 w-4" />
      <span>Clear Filters</span>
    </a>
  </div>
)}
```

### Step 4: Update Command Centre Links

Update any links in Command Centre that currently point to `/clients` to use new URL parameters:

```typescript
// Instead of:
<a href="/clients?filter=declining">View Declining Clients</a>

// Use:
<a href="/segmentation?filter=declining">View Declining Clients</a>
```

---

## Migration Checklist

### Pre-Implementation

- [ ] Review all features in both pages
- [ ] Identify all navigation links to `/clients` across the app
- [ ] Backup current Client Health page implementation
- [ ] Create feature branch: `feature/consolidate-client-pages`

### Implementation (Phase 1)

- [ ] Create `src/lib/clientAIInsights.ts` with shared functions
- [ ] Create `src/components/ClientDetailModal.tsx`
- [ ] Add modal state to Client Segmentation page
- [ ] Add "View Details" button to client cards
- [ ] Test modal opening/closing
- [ ] Test health score breakdown display
- [ ] Test AI insights generation
- [ ] Add URL parameter parsing to Client Segmentation
- [ ] Update filtered segments logic
- [ ] Add active filter banner
- [ ] Test URL parameter filtering (`?filter`, `?clients`, `?segment`)
- [ ] Update Command Centre navigation links
- [ ] Test deep linking from Command Centre

### Testing

- [ ] Test all 6 segments display correctly
- [ ] Test client card expansion (inline panel)
- [ ] Test client detail modal (new)
- [ ] Test health score breakdown accordion
- [ ] Test AI insights accordion
- [ ] Test URL parameter filtering (all combinations)
- [ ] Test search functionality with filters
- [ ] Test segment filter buttons with URL parameters
- [ ] Test CSE View toggle still works
- [ ] Test APAC View button still works
- [ ] Test Schedule Event modal integration
- [ ] Test compliance data refresh after event creation
- [ ] Verify mobile responsiveness of new modal

### Post-Implementation

- [ ] Update sidebar navigation (remove or repurpose Client Health)
- [ ] Add redirect from `/clients` to `/segmentation` (if deprecating)
- [ ] Update documentation and user guides
- [ ] Notify users of new unified client view
- [ ] Monitor usage analytics for adoption

---

## Benefits of Consolidation

### For Users

1. **Single Source of Truth**: One page for all client information
2. **Richer Context**: Segment-based view + detailed health breakdown + event compliance
3. **Better Navigation**: Deep linking with URL parameters
4. **Comprehensive Insights**: AI predictions + health breakdown + compliance tracking
5. **Faster Workflows**: No need to switch between pages

### For Developers

1. **Reduced Maintenance**: One page to maintain instead of two
2. **Consistent UX**: Single design pattern for client views
3. **Code Reusability**: Shared components and functions
4. **Easier Testing**: One comprehensive test suite
5. **Simpler Navigation**: Fewer routes to manage

### For Product

1. **Clearer Value Proposition**: Segment-based client success management
2. **Stronger Differentiation**: Unique APAC segmentation approach
3. **Better Data Utilization**: Combines NPS, health, compliance in one view
4. **More Actionable**: Event scheduling + AI recommendations integrated

---

## Risks & Mitigation

### Risk 1: User Disruption

**Risk**: Users accustomed to Client Health page may be confused by redirect
**Mitigation**:

- Add banner on Client Health page announcing consolidation (2 weeks notice)
- Provide tutorial/tour on first visit to new unified page
- Maintain URL parameter compatibility for saved links

### Risk 2: Performance Impact

**Risk**: Unified page may load slower due to additional data
**Mitigation**:

- Lazy load modal component
- Use React.memo for client cards
- Implement pagination if >50 clients
- Consider virtual scrolling for large segments

### Risk 3: Feature Overload

**Risk**: Too many features may overwhelm users
**Mitigation**:

- Keep inline expansion minimal (compliance only)
- Use modal for deep dive (health breakdown, AI insights)
- Add "Guided Tour" for new users
- Implement progressive disclosure (accordion patterns)

### Risk 4: Mobile Experience

**Risk**: Modal and expanded panels may not work well on mobile
**Mitigation**:

- Use full-screen modal on mobile (<768px)
- Simplify inline expansion on mobile (fewer metrics)
- Test extensively on mobile devices
- Consider mobile-specific layout adjustments

---

## Timeline Estimate

### Phase 1: Core Consolidation (1-2 days)

- Create shared components: 2-3 hours
- Add modal to Client Segmentation: 2-3 hours
- Add URL parameter filtering: 1-2 hours
- Testing and bug fixes: 2-3 hours

### Phase 2: Polish & Testing (1 day)

- UI/UX refinements: 2-3 hours
- Comprehensive testing: 2-3 hours
- Mobile responsiveness: 1-2 hours
- Documentation: 1 hour

### Phase 3: Deployment & Migration (1 day)

- Update navigation links: 1 hour
- Add redirect/deprecation: 1 hour
- User communication: 1 hour
- Monitor and fix issues: 2-4 hours

**Total Estimate**: 3-4 days

---

## Success Metrics

### Adoption Metrics

- % of users visiting `/segmentation` vs `/clients` (target: 80/20 within 2 weeks)
- Average time spent on unified page (expect increase due to richer features)
- Bounce rate comparison (should decrease with better navigation)

### Engagement Metrics

- Client detail modal open rate (target: >50% of sessions)
- Health breakdown accordion expansion rate (target: >30% of modal opens)
- AI insights accordion expansion rate (target: >40% of modal opens)
- URL parameter usage (measure deep linking adoption)

### Performance Metrics

- Page load time (target: <2 seconds)
- Time to interactive (target: <3 seconds)
- Modal render time (target: <200ms)

---

## Future Enhancements

### Short-term (Next 1-2 months)

1. **Compliance Timeline View**: Show compliance trends over time
2. **Segment Benchmarking**: Compare client performance within segment
3. **Export Functionality**: Export segment reports to PDF/Excel
4. **Custom Segment Creation**: Allow users to create custom segments

### Medium-term (Next 3-6 months)

1. **Predictive Analytics**: Forecast client health trajectories
2. **Automated Recommendations**: AI-driven action recommendations
3. **Client Journey Mapping**: Visualize client lifecycle stages
4. **Integration Workflows**: Connect with CRM, ticketing systems

### Long-term (Next 6-12 months)

1. **Mobile App**: Native mobile experience
2. **Real-time Collaboration**: Multi-user editing and commenting
3. **Advanced Reporting**: Custom dashboards and KPI tracking
4. **API Access**: Allow third-party integrations

---

## Appendix: Code References

### Client Health Page Key Sections

- **Search & Filter**: Lines 204-235
- **Stats Overview**: Lines 237-283
- **Client Table**: Lines 285-414
- **Client Detail Modal**: Lines 417-728
- **AI Insights Generation**: Lines 79-142
- **Health Breakdown Calculation**: Lines 144-176

### Client Segmentation Page Key Sections

- **View Mode Toggle**: Lines 565-594
- **Stats Overview**: Lines 599-646
- **Search & Filter**: Lines 648-692
- **Segment Configuration**: Lines 34-79
- **Segment Cards**: Lines 694-883
- **Client Event Detail Panel**: Lines 87-375
- **Compliance Data Fetch**: Lines 387-450

---

**Document Created By**: Claude Code
**Last Updated**: 2025-11-28
**Status**: Ready for Implementation
