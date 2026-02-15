# Modal Design Standards & Recommendations
## Research-Based Guidelines for Unified Modal Design System

**Date:** 2026-01-07
**Status:** Research & Recommendations
**Scope:** Standardising modal/dialogue patterns across the APAC Intelligence dashboard

---

## Executive Summary

This document provides research-based recommendations for creating a unified, context-aware modal design system. Based on analysis of your current modals and industry best practices from Linear, Notion, Stripe, Salesforce, and Google, this guide proposes a single adaptive modal component that intelligently adjusts based on context whilst maintaining consistency.

### Current State Analysis

**Existing Modal Patterns Identified:**

1. **UniversalMeetingModal** (1480 lines)
   - Dual-tab architecture (Client/Internal meetings)
   - Complex form with conditional fields
   - Template system for saved configurations
   - Past meeting upload capabilities
   - Rich attendee management
   - AI-generated agenda items

2. **ScheduleEventModal** (384 lines)
   - AI-powered suggestions (compliance predictions)
   - Simpler, focused form
   - Dedicated event scheduling workflow
   - Urgency-based recommendation system

3. **LogEventModal** (650 lines)
   - Event attendance tracking
   - Bulk attendee upload (CSV)
   - Custom attendee management
   - Engagement level tracking
   - Event type selection with icons

4. **CreateActionModal** (684 lines)
   - Multi-select dropdowns
   - Rich text editor with @mentions
   - Natural language date input
   - Priority chips with keyboard shortcuts
   - Department/Activity type selectors
   - Teams integration toggle

5. **EditActionModal** (957 lines)
   - Similar structure to Create but with edit context
   - Microsoft 365 integration buttons
   - Delete functionality
   - Read-only information sections

### Key Inconsistencies Identified

1. **Visual Design Variance**
   - UniversalMeetingModal: Purple gradient header with tabs
   - ScheduleEventModal: White header, simpler design
   - LogEventModal: Grey header, different button styles
   - CreateActionModal: Blue accent vs purple accent

2. **Interaction Patterns**
   - Different approaches to multi-select (pills vs checkboxes vs dropdown)
   - Inconsistent button layouts (left vs right alignment)
   - Varying form field densities
   - Different validation feedback styles

3. **Structural Differences**
   - Fixed header heights vary
   - Scrollable content areas handled differently
   - Footer button arrangements inconsistent
   - Error/success message positioning varies

---

## Industry Research: 2025-2026 Modal Design Trends

### 1. **Linear** — The Gold Standard for Context-Aware Modals

**Key Patterns:**
- **Adaptive forms**: The "Create Issue" modal adjusts fields based on project type, priority, and user role
- **Keyboard-first design**: Every action has a keyboard shortcut (⌘K universal command palette)
- **Inline validation**: Real-time feedback as you type, not after submission
- **Smart defaults**: Pre-fills based on current context (e.g., current view, selected items)
- **Progressive disclosure**: Advanced fields appear only when needed
- **Micro-interactions**: Smooth animations, haptic-like feedback for selections

**What Linear Does Exceptionally Well:**
```
1. Single-field focus at a time (guided workflow)
2. Tab key moves logically through fields
3. Escape always closes (with unsaved changes warning)
4. Enter submits when appropriate
5. Dropdown suggestions appear instantly (< 100ms)
6. Field help text appears on hover/focus, not always visible
```

**Mobile Adaptations:**
- Full-screen takeover on mobile (not modal overlay)
- Bottom sheet for quick actions
- Touch-optimised target sizes (minimum 44×44px)
- Swipe-down to dismiss gesture

### 2. **Notion** — Database-Driven Adaptive Forms

**Key Patterns:**
- **Property-based forms**: Forms adapt based on database properties
- **Inline creation**: Can create related items without leaving context
- **Rich content blocks**: Drag-and-drop ordering of form sections
- **Templates**: Save common form configurations
- **AI assistance**: Suggests values based on similar entries

**Notion's Interaction Innovations:**
```
- @mention system works everywhere (dates, people, pages)
- Slash commands (/) for quick actions
- Double-bracket [[]] for page links
- Database views toggle (table, board, calendar) within modal
- Hover previews for linked content
```

**Visual Hierarchy:**
- Clear section dividers (subtle lines, not heavy borders)
- Icon + label combination for all inputs
- Muted colours for secondary actions
- Bold primary action (top-right or bottom-right)

### 3. **Stripe Dashboard** — Financial-Grade Form Design

**Key Patterns:**
- **Multi-step wizards**: Complex workflows broken into stages with progress indicator
- **Inline help**: Contextual documentation alongside fields
- **Real-time validation**: Format checking as you type (e.g., card numbers, IBANs)
- **Error prevention**: Disable submit until all required fields valid
- **Accessibility first**: WCAG AAA compliance, screen reader optimised

**Stripe's Validation Approach:**
```
1. Field-level validation on blur (when leaving field)
2. Form-level validation on submit attempt
3. Clear error messages with recovery instructions
4. Success states shown with checkmarks
5. Loading states on async operations (with skeleton screens)
```

**Mobile Considerations:**
- Native input types (tel, email, number) for better keyboards
- Autofill support for all fields
- Step-back navigation always available
- No horizontal scrolling, ever

### 4. **Salesforce Lightning** — Enterprise Modal Patterns

**Key Patterns:**
- **Record creation modals**: Highly configurable, admin-defined fields
- **Lookup relationships**: Inline search with create-new option
- **Related list integration**: Can add related records in same flow
- **Validation rules**: Server-side + client-side combined
- **Audit trail**: Shows who created, when, last modified

**Salesforce's Layout System:**
```
- Two-column layout for wide modals
- Single column for narrow/mobile
- Required fields marked with red asterisk
- Field help icons (?) with popovers
- Related items shown in tabs within modal
```

**Data Integrity Features:**
- Duplicate detection (warns before creating)
- Field dependencies (show/hide based on other values)
- Picklist cascading (region → country → city)
- Formula fields (auto-calculated, read-only)

### 5. **Google Workspace** — Collaborative Form Design

**Key Patterns:**
- **Real-time collaboration**: See others editing same form (presence avatars)
- **Smart Compose**: AI-powered suggestions for titles, descriptions
- **Quick actions**: Common tasks accessible from any context
- **Unified settings**: Consistent settings panel across all apps
- **Cross-app integration**: Create Calendar event → auto-creates Meet link → updates Doc

**Google's Interaction Philosophy:**
```
- Floating Action Button (FAB) for primary create action
- Material Design 3 components (filled buttons, outlined buttons)
- Consistent spacing (8dp grid system)
- Elevation for hierarchy (shadows indicate layers)
- Touch ripple effects on all interactive elements
```

---

## 2025-2026 Design Trends for Enterprise Modals

### Emerging Patterns

1. **AI-Powered Assistance**
   - Smart field suggestions (based on historical data)
   - Auto-categorisation (NLP analysis of titles)
   - Predictive scheduling (finds optimal meeting times)
   - Content generation (draft descriptions, agendas)

2. **Micro-Animations & Feedback**
   - Field focus animations (subtle glow)
   - Success confetti (delightful but professional)
   - Loading skeleton screens (better than spinners)
   - Progress bars for multi-step forms

3. **Voice & Accessibility**
   - Voice input for long-form fields
   - Dictation support
   - Screen reader announcements for state changes
   - High contrast mode support

4. **Mobile-First Responsive Design**
   - Bottom sheets for quick actions (iOS/Android native pattern)
   - Full-screen modals on small screens
   - Sticky headers with context (show what you're editing)
   - Swipe gestures (down to dismiss, left/right for multi-step)

5. **Dark Mode Considerations**
   - OLED-friendly true black (#000000)
   - Reduced contrast to avoid eye strain
   - Colour-blind safe palettes
   - System preference detection (auto-switch)

---

## Recommendations: Unified Modal Design System

### Proposed Architecture: `UnifiedModal` Component

A single, intelligent modal component that adapts based on context, rather than separate modals for each use case.

#### Core Principles

1. **Context-Aware Adaptation**
   - Single source component that adapts its fields, layout, and behaviour based on `mode` prop
   - Shared visual language across all variations
   - Consistent interaction patterns

2. **Progressive Disclosure**
   - Start with essential fields visible
   - Advanced/optional fields collapse into expandable sections
   - "Show more options" pattern

3. **Keyboard-First Navigation**
   - Tab through fields in logical order
   - Enter to submit (when appropriate)
   - Escape to close (with unsaved changes warning)
   - Keyboard shortcuts for common actions

4. **Mobile-Responsive**
   - Adaptive layout: 2-column desktop → 1-column mobile
   - Touch-optimised targets (minimum 44×44px)
   - Bottom sheet on mobile for quick actions
   - Full-screen takeover on small screens (<640px)

5. **Accessibility-First**
   - WCAG 2.2 Level AA compliance
   - Screen reader announcements
   - Keyboard navigation
   - Focus management (trap focus inside modal)
   - Colour contrast ratios (minimum 4.5:1)

---

### Component API Design

```typescript
interface UnifiedModalProps {
  // Core Configuration
  isOpen: boolean
  onClose: () => void
  onSuccess?: () => void

  // Context & Mode
  mode: 'create-meeting' | 'edit-meeting' | 'create-action' | 'edit-action' | 'log-event' | 'schedule-event'
  entityType?: 'client' | 'internal' | 'action' | 'event'

  // Pre-populated Data
  initialData?: Partial<EntityData>
  defaultClient?: string
  contextData?: Record<string, unknown> // For AI suggestions, related entities, etc.

  // Feature Flags (enable/disable specific sections)
  features?: {
    aiSuggestions?: boolean
    templateSystem?: boolean
    fileUpload?: boolean
    microsoftIntegration?: boolean
    teamsPosting?: boolean
    attendeeManagement?: boolean
    richTextEditor?: boolean
  }

  // Customisation
  headerVariant?: 'gradient' | 'solid' | 'minimal'
  primaryColour?: string // Accent colour for buttons, focus states
  size?: 'sm' | 'md' | 'lg' | 'xl' // Width of modal

  // Advanced
  validationSchema?: ZodSchema // For complex validation
  onFieldChange?: (field: string, value: unknown) => void
  customFields?: CustomField[] // For extensibility
}
```

---

### Visual Design Standards

#### 1. Layout Structure

```
┌─────────────────────────────────────────────────────┐
│ HEADER (Fixed)                                      │
│  ┌─ Icon  Title                           [X] ─┐   │
│  └─ Subtitle/Context                          ─┘   │
│  ┌─ Tab 1    Tab 2 ─────────────────────────────┐  │ ← Optional tabs
│  └──────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────┤
│ CONTENT (Scrollable)                                │
│                                                     │
│  ┌─ AI Suggestions (Collapsible) ────────────────┐ │ ← Optional
│  └──────────────────────────────────────────────┘ │
│                                                     │
│  ┌─ Field Label                                  ┐ │
│  │ [Input Field                                ] │ │
│  │  Help text appears here                      │ │
│  └──────────────────────────────────────────────┘ │
│                                                     │
│  ┌─ Advanced Options (Collapsed by default) ─────┐│
│  │  Click to expand                               ││
│  └───────────────────────────────────────────────┘│
│                                                     │
├─────────────────────────────────────────────────────┤
│ FOOTER (Fixed)                                      │
│  [Secondary Action]        [Cancel] [Primary Action]│
└─────────────────────────────────────────────────────┘
```

#### 2. Spacing System (8px Grid)

- **Modal padding**: 24px (3 units)
- **Field spacing**: 20px (2.5 units)
- **Section spacing**: 32px (4 units)
- **Inline gaps**: 12px (1.5 units)
- **Minimum touch target**: 44×44px

#### 3. Typography Hierarchy

```css
/* Header Title */
font-size: 20px (1.25rem)
font-weight: 600 (Semibold)
line-height: 1.2
colour: Gray 900

/* Header Subtitle */
font-size: 14px (0.875rem)
font-weight: 400 (Regular)
line-height: 1.4
colour: Gray 600

/* Field Labels */
font-size: 14px (0.875rem)
font-weight: 500 (Medium)
line-height: 1.5
colour: Gray 700

/* Input Text */
font-size: 14px (0.875rem)
font-weight: 400 (Regular)
line-height: 1.5
colour: Gray 900

/* Help Text */
font-size: 12px (0.75rem)
font-weight: 400 (Regular)
line-height: 1.4
colour: Gray 500

/* Error Messages */
font-size: 13px (0.8125rem)
font-weight: 500 (Medium)
line-height: 1.4
colour: Red 700
```

#### 4. Colour Palette (Based on Current Purple Theme)

**Primary Actions:**
- Default: `#7C3AED` (Purple 600)
- Hover: `#6D28D9` (Purple 700)
- Active: `#5B21B6` (Purple 800)
- Disabled: `#D8B4FE` (Purple 300, 50% opacity)

**Backgrounds:**
- Modal: `#FFFFFF`
- Input: `#FFFFFF`
- Input (Focus): `#F9FAFB` (Gray 50)
- Section highlight: `#F3F4F6` (Gray 100)
- Destructive action: `#FEF2F2` (Red 50)

**Borders:**
- Default: `#E5E7EB` (Gray 200)
- Focus: `#7C3AED` (Purple 600)
- Error: `#EF4444` (Red 500)
- Success: `#10B981` (Green 500)

**Text:**
- Primary: `#111827` (Gray 900)
- Secondary: `#6B7280` (Gray 600)
- Tertiary: `#9CA3AF` (Gray 500)
- Disabled: `#D1D5DB` (Gray 400)

#### 5. Elevation & Shadows

```css
/* Modal Backdrop */
background: rgba(0, 0, 0, 0.5)
backdrop-filter: blur(4px)

/* Modal Container */
box-shadow:
  0 20px 25px -5px rgba(0, 0, 0, 0.1),
  0 10px 10px -5px rgba(0, 0, 0, 0.04)
border-radius: 12px

/* Dropdown/Popover */
box-shadow:
  0 10px 15px -3px rgba(0, 0, 0, 0.1),
  0 4px 6px -2px rgba(0, 0, 0, 0.05)
border-radius: 8px

/* Focus Ring */
box-shadow:
  0 0 0 3px rgba(124, 58, 237, 0.1)
```

---

### Interaction Patterns

#### 1. Field Focus States

**Recommended Pattern (Linear/Stripe Approach):**

```
1. Idle State:
   - Border: Gray 300 (#D1D5DB)
   - Background: White (#FFFFFF)

2. Hover State:
   - Border: Gray 400 (#9CA3AF)
   - Background: White (#FFFFFF)
   - Cursor: pointer (for selects) or text (for inputs)

3. Focus State:
   - Border: Purple 600 (#7C3AED) 2px
   - Background: White (#FFFFFF)
   - Focus ring: Purple 600 at 10% opacity, 3px offset
   - Label: Animates to Purple 600

4. Error State:
   - Border: Red 500 (#EF4444) 2px
   - Background: Red 50 (#FEF2F2)
   - Icon: Red exclamation mark inside field
   - Message: Below field, Red 700 text

5. Success State:
   - Border: Green 500 (#10B981) 2px
   - Icon: Green checkmark inside field
   - Background: White (#FFFFFF)

6. Disabled State:
   - Border: Gray 200 (#E5E7EB)
   - Background: Gray 100 (#F3F4F6)
   - Text: Gray 400 (#9CA3AF)
   - Cursor: not-allowed
```

#### 2. Multi-Select Patterns

**Recommended: Hybrid Approach (Best of All Worlds)**

For **client/owner selection** (5-50 options):
```
┌─ Search or select clients...  [v] ────────────┐
│  Client Search Input                         │
└──────────────────────────────────────────────┘

Selected (3):
┌─ Epworth Healthcare [x] ─┐ ┌─ Royal Melbourne [x] ─┐
└───────────────────────────┘ └────────────────────────┘

Available:
☐ Alfred Health
☐ Austin Health
☐ Barwon Health
```

For **categories/tags** (10-30 options):
```
┌─ Type or select categories... ────────────────┐
└────────────────────────────────────────────────┘

Selected:
┌─ NPS [x] ─┐ ┌─ Meeting Follow-Up [x] ─┐
└────────────┘ └──────────────────────────┘

Suggestions: (appears on focus)
• Client Success
• Planning
• 360 Update
```

For **priority/status** (3-5 options):
```
Priority: ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐
          │ 🔴   │ │ 🟠   │ │ 🟡   │ │ ⚪  │
          │Critical│ │ High │ │Medium│ │ Low │
          └──────┘ └──────┘ └──────┘ └──────┘
                        ▲ Selected
```

#### 3. Date/Time Input Patterns

**Recommended: Natural Language + Calendar Picker (Notion Approach)**

```
Due Date:
┌─────────────────────────────────────────┐
│ tomorrow                          [📅] │ ← Parses "tomorrow" to actual date
└─────────────────────────────────────────┘
  Parsed as: Wednesday, 8 January 2026

Examples: today, tomorrow, next friday, in 2 weeks, 15 Jan
```

When calendar icon clicked:
```
┌─ January 2026 ──────────────────────────┐
│  Mo  Tu  We  Th  Fr  Sa  Su            │
│   6   7  【8】 9  10  11  12          │ ← Today highlighted
│  13  14  15  16  17  18  19            │
│  ...                                    │
└─────────────────────────────────────────┘
```

#### 4. Validation & Error Handling

**Real-Time Validation Strategy:**

1. **As-You-Type** (for format validation):
   - Email format
   - Phone number format
   - Date format
   - URL format

2. **On-Blur** (when leaving field):
   - Required field check
   - Uniqueness check (e.g., duplicate action title)
   - Business logic (e.g., due date must be future)

3. **On-Submit** (final validation):
   - Cross-field validation (e.g., end date > start date)
   - Server-side checks
   - Duplicate detection

**Error Message Patterns:**

```
❌ Bad: "Invalid input"
✅ Good: "Email must include @ symbol (e.g., user@company.com)"

❌ Bad: "Error"
✅ Good: "This action title already exists. Try: 'Schedule QBR - Q2 2026'"

❌ Bad: "Field required"
✅ Good: "Client name is required to create this action"
```

#### 5. Loading & Success States

**Loading States (Skeleton Screens):**

```
Instead of:                  Use:
┌──────────────┐            ┌──────────────┐
│              │            │ ▓▓▓▓▓        │ ← Animated shimmer
│   Loading... │            │ ▓▓▓▓▓▓▓      │
│              │            │ ▓▓▓          │
└──────────────┘            └──────────────┘
```

**Success States (Inline Confirmation):**

```
After successful save:

┌─────────────────────────────────────────────┐
│ ✅ Meeting scheduled successfully!          │
│                                             │
│ Next steps:                                 │
│ • Calendar invite sent to 4 attendees       │
│ • Teams meeting link created                │
│ • Reminder set for 30 minutes before        │
│                                             │
│ [View in Calendar]        [Schedule Another]│
└─────────────────────────────────────────────┘
```

---

### Responsive Breakpoints

```css
/* Mobile First Approach */

/* Small devices (phones, 0-639px) */
@media (max-width: 639px) {
  - Modal: 100% width, full height
  - Single column layout
  - Sticky header + footer
  - Bottom sheet for secondary actions
  - Large touch targets (min 44×44px)
}

/* Medium devices (tablets, 640-1023px) */
@media (min-width: 640px) and (max-width: 1023px) {
  - Modal: 90% width, max 600px
  - Single column layout
  - Standard touch targets (min 40×40px)
}

/* Large devices (desktops, 1024px+) */
@media (min-width: 1024px) {
  - Modal: Fixed width based on size prop
    - sm: 480px
    - md: 640px (default)
    - lg: 800px
    - xl: 1024px
  - Two-column layout for wide modals
  - Mouse-optimised interactions
}
```

---

### Accessibility Requirements

#### WCAG 2.2 Level AA Compliance

1. **Keyboard Navigation**
   - Tab order matches visual order
   - Focus visible indicator (3px purple ring)
   - Escape closes modal
   - Enter submits form (when appropriate)
   - Arrow keys navigate multi-selects

2. **Screen Reader Support**
   - Modal announced on open: "Dialog: Schedule Meeting"
   - Form fields have associated labels (explicit `<label for="id">`)
   - Error messages linked with `aria-describedby`
   - Loading states announced: "Saving, please wait"
   - Success announced: "Meeting created successfully"

3. **Colour Contrast**
   - Text: Minimum 4.5:1 (AA standard)
   - Interactive elements: Minimum 3:1
   - Error states: Don't rely on colour alone (use icons + text)

4. **Focus Management**
   - Focus trapped inside modal (can't tab to background)
   - Focus returns to trigger element on close
   - First focusable element focuses on open

5. **Alternative Text**
   - All icons have `aria-label` or text equivalent
   - Images have descriptive `alt` text

---

### Animation & Micro-Interactions

#### Recommended Motion Design

**Modal Open Animation:**
```css
- Backdrop: Fade in over 200ms
- Modal: Slide up from bottom + fade in over 250ms (easing: ease-out)
- Content: Stagger fade-in of fields (50ms delay between each)
```

**Modal Close Animation:**
```css
- Modal: Slide down + fade out over 200ms (easing: ease-in)
- Backdrop: Fade out over 150ms (after modal starts closing)
```

**Field Interactions:**
```css
- Focus ring: Expand from 0 to 3px over 150ms
- Validation icon: Pop-in scale from 0 to 1 over 200ms
- Error shake: Subtle 3px horizontal shake over 300ms
- Success checkmark: Draw animation over 400ms
```

**Button States:**
```css
- Hover: Scale 1.02, shadow increase over 150ms
- Active: Scale 0.98 over 100ms
- Loading: Spinner fade-in over 200ms, button width transition over 250ms
```

**Respect User Preferences:**
```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

### AI-Powered Features Integration

#### 1. Smart Suggestions (Linear/Notion Pattern)

```
┌─ AI Suggestions ──────────────────────────────────┐
│ 🤖 Based on similar meetings, we suggest:         │
│                                                    │
│ ┌─ QBR with Epworth Healthcare ─────────────────┐│
│ │ • Suggested date: Next Wednesday, 15 Jan       ││
│ │ • Duration: 60 minutes                         ││
│ │ • Attendees: John Smith, Sarah Lee             ││
│ │ • Agenda: Review Q4 metrics, discuss roadmap   ││
│ │                                                ││
│ │ [Use This Suggestion]                          ││
│ └────────────────────────────────────────────────┘│
│                                                    │
│ [Show More Suggestions] [Dismiss]                 │
└────────────────────────────────────────────────────┘
```

#### 2. Auto-Categorisation

```
Action Title:
┌─────────────────────────────────────────────────┐
│ Schedule follow-up demo for new features        │
└─────────────────────────────────────────────────┘

🤖 Suggested categories:
   ┌─ Meeting [+] ─┐ ┌─ Client Success [+] ─┐
   └────────────────┘ └─────────────────────────┘
```

#### 3. Smart Scheduling (Google Calendar Pattern)

```
When is this meeting?
┌─ Find a time ──────────────────────────────────┐
│                                                 │
│ Participants: You, John Smith, Sarah Lee       │
│                                                 │
│ 🤖 Smart suggestions:                          │
│ ┌─ Tomorrow 2:00 PM ─┐ ← All attendees free   │
│ ┌─ Friday 10:00 AM ──┐ ← Optimal time         │
│ ┌─ Next week Monday ─┐                        │
│                                                 │
│ [View Full Calendar]                           │
└─────────────────────────────────────────────────┘
```

---

### Implementation Priorities

#### 🔴 Critical (Must Have) — Phase 1

1. **Unified Visual Design**
   - Standardise header styles across all modals
   - Consistent spacing system (8px grid)
   - Unified colour palette
   - Standard button layouts

2. **Accessibility Foundation**
   - Keyboard navigation
   - Focus management
   - Screen reader support
   - ARIA labels

3. **Responsive Layout**
   - Mobile-first breakpoints
   - Touch-optimised targets
   - Bottom sheet for mobile

4. **Core Interactions**
   - Standardised multi-select pattern
   - Consistent validation approach
   - Unified error messaging

#### 🟡 Important (Should Have) — Phase 2

1. **Advanced Features**
   - AI suggestions framework
   - Template system
   - Smart defaults based on context

2. **Enhanced UX**
   - Skeleton loading states
   - Micro-animations
   - Success confirmations

3. **Integration**
   - Microsoft 365 integration
   - Teams posting
   - File upload

#### 🟢 Enhancement (Nice to Have) — Phase 3

1. **Delight Features**
   - Natural language date input
   - Voice input
   - Collaborative editing

2. **Optimisation**
   - Performance improvements
   - Reduced bundle size
   - Lazy loading for large forms

---

### Proposed Component Structure

```
src/
└── components/
    └── unified-modal/
        ├── UnifiedModal.tsx              ← Main container
        ├── UnifiedModalHeader.tsx        ← Reusable header
        ├── UnifiedModalFooter.tsx        ← Reusable footer
        ├── UnifiedModalContent.tsx       ← Scrollable content area
        ├── fields/
        │   ├── TextField.tsx
        │   ├── DateField.tsx
        │   ├── MultiSelect.tsx
        │   ├── RichTextArea.tsx
        │   ├── PrioritySelector.tsx
        │   └── AttendeeSelector.tsx
        ├── sections/
        │   ├── AISuggestions.tsx
        │   ├── AdvancedOptions.tsx
        │   └── FileUpload.tsx
        ├── modes/
        │   ├── CreateMeetingMode.tsx     ← Mode-specific field configs
        │   ├── EditMeetingMode.tsx
        │   ├── CreateActionMode.tsx
        │   ├── EditActionMode.tsx
        │   └── LogEventMode.tsx
        └── utils/
            ├── validation.ts
            ├── formatting.ts
            └── ai-suggestions.ts
```

---

### Migration Strategy

#### Step 1: Create Base UnifiedModal Component
- Build core structure (header, content, footer)
- Implement accessibility features
- Set up responsive breakpoints

#### Step 2: Migrate One Modal at a Time
1. Start with **CreateActionModal** (simplest)
2. Then **ScheduleEventModal** (AI suggestions)
3. Then **LogEventModal** (attendee management)
4. Finally **UniversalMeetingModal** (most complex)

#### Step 3: Deprecate Old Components
- Add deprecation warnings to old modals
- Update all usage to UnifiedModal
- Remove old components after migration complete

---

### Testing Checklist

- [ ] **Keyboard Navigation**: Tab through all fields, submit with Enter, close with Escape
- [ ] **Screen Reader**: Test with NVDA/JAWS on Windows, VoiceOver on Mac
- [ ] **Mobile**: Test on iOS Safari, Android Chrome (real devices)
- [ ] **Validation**: Test all error states, required fields, format validation
- [ ] **Performance**: Measure time-to-interactive (< 200ms)
- [ ] **Cross-Browser**: Test on Chrome, Firefox, Safari, Edge
- [ ] **Dark Mode**: If supported, test all visual states
- [ ] **RTL Languages**: Test with Arabic/Hebrew (if internationalisation planned)

---

## Conclusion

A unified modal design system will:

1. ✅ **Improve user experience** through consistency and predictability
2. ✅ **Reduce development time** by reusing components
3. ✅ **Enhance accessibility** with standardised patterns
4. ✅ **Simplify maintenance** with a single source of truth
5. ✅ **Enable innovation** with a flexible, extensible architecture

### Next Steps

1. **Review & Approve**: Discuss this proposal with the team
2. **Prototype**: Build a proof-of-concept for one mode (e.g., Create Action)
3. **User Test**: Validate with real users before full migration
4. **Iterate**: Refine based on feedback
5. **Migrate**: Gradually replace old modals with unified system
6. **Document**: Create component library documentation

---

**Document Maintained By:** Claude (AI UI/UX Analyst)
**Last Updated:** 2026-01-07
**Feedback:** Review comments welcome via pull request or discussion
