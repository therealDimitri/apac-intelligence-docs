# APAC CS Intelligence Hub
## Email Template Design Studio - Complete Feature Specification
### Version 2.0 | December 2025

---

# TABLE OF CONTENTS

1. [Overview & Objectives](#1-overview--objectives)
2. [Navigation & Information Architecture](#2-navigation--information-architecture)
3. [Library & Dependency Stack](#3-library--dependency-stack)
4. [UI Components & Layout](#4-ui-components--layout)
5. [Content Block System](#5-content-block-system)
6. [Personalisation & Merge Fields](#6-personalisation--merge-fields)
7. [MatchaAI Integration (Chasen)](#7-matchaai-integration-chasen)
8. [Template Management](#8-template-management)
9. [Preview & Testing](#9-preview--testing)
10. [Brand Kit & Design Assets](#10-brand-kit--design-assets)
11. [Analytics & Reporting](#11-analytics--reporting)
12. [Technical Implementation](#12-technical-implementation)
13. [Pre-Built Template Library](#13-pre-built-template-library)
14. [Chasen Response Enhancement Protocol](#14-chasen-response-enhancement-protocol)

---

# 1. OVERVIEW & OBJECTIVES

## 1.1 Purpose

Build a professional-grade email template builder within the Guides & Resources section of the APAC CS Intelligence Hub. The system should rival capabilities of leading marketing platforms (HubSpot, Mailchimp, Klaviyo) while being tailored for Client Success communications in healthcare.

## 1.2 Key Objectives

| Objective                  | Success Metric                     |
| -------------------------- | ---------------------------------- |
| Reduce email creation time | 60% reduction in time-to-send      |
| Improve email consistency  | 100% brand compliance              |
| Increase personalisation   | 3x increase in merge field usage   |
| Enable AI-assisted writing | 80% adoption of Chasen suggestions |
| Track template performance | Full analytics visibility          |

## 1.3 Target Users

- **Client Success Executives (CSEs)**: Day-to-day client communications
- **Client Account Managers (CAMs)**: Renewal and expansion communications
- **CS Leadership**: Executive communications and escalations
- **Marketing Collaboration**: Campaign and event communications

## 1.4 Design Principles

1. **Progressive Disclosure**: Show advanced features only when needed
2. **Instant Feedback**: Real-time preview updates as user types
3. **Undo/Redo**: Full history support (Cmd+Z / Ctrl+Z)
4. **Auto-Save**: Save drafts every 30 seconds
5. **Keyboard Shortcuts**: Power user efficiency
6. **Contextual Help**: Tooltips and inline guidance
7. **Empty States**: Helpful prompts when no content exists
8. **Error Prevention**: Validate before save, warn before delete

---

# 2. NAVIGATION & INFORMATION ARCHITECTURE

## 2.1 Location

**Path**: Guides & Resources → Email Templates

## 2.2 Primary Navigation Structure
```
📧 Email Templates
├── 📁 My Templates
│   ├── Drafts
│   ├── Published
│   └── Archived
├── 📚 Template Library
│   ├── By Category
│   │   ├── Client Onboarding
│   │   ├── QBR & Reviews
│   │   ├── NPS & Surveys
│   │   ├── Product Updates
│   │   ├── Risk & Escalation
│   │   ├── Renewal & Expansion
│   │   └── Event Invitations
│   ├── By Client Segment
│   │   ├── Giants
│   │   ├── Sleeping Giants
│   │   ├── Leverage
│   │   ├── Collaborate
│   │   ├── Nurture
│   │   └── Maintain
│   └── By Stakeholder Type
│       ├── C-Suite / Executive
│       ├── Clinical Leadership
│       ├── IT / Technical
│       └── Operational
├── 🎨 Design Assets
│   ├── Brand Kit
│   ├── Image Library
│   └── Signature Blocks
└── 📊 Analytics
    ├── Template Performance
    └── Usage Statistics
```

## 2.3 URL Structure
```
/guides-resources/email-templates                    # Library landing
/guides-resources/email-templates/new                # New template
/guides-resources/email-templates/:id/edit           # Edit template
/guides-resources/email-templates/:id/preview        # Preview mode
/guides-resources/email-templates/brand-kit          # Brand settings
/guides-resources/email-templates/analytics          # Performance dashboard
```

---

# 3. LIBRARY & DEPENDENCY STACK

## 3.1 Core Email Building

### Email Rendering & Generation
```bash
# Primary email rendering
npm install mjml mjml-react
npm install @react-email/components react-email

# Alternative/complementary
npm install maizzle
```

| Library         | Purpose                    | Why This One                                                 |
| --------------- | -------------------------- | ------------------------------------------------------------ |
| **MJML**        | Email markup language      | Industry standard for responsive emails; compiles to bulletproof HTML |
| **React Email** | React components for email | Modern, component-based email development                    |
| **Maizzle**     | Email framework            | Tailwind CSS for emails; great for custom designs            |

### Drag-and-Drop Builder
```bash
# Recommended primary choice
npm install @dnd-kit/core @dnd-kit/sortable @dnd-kit/utilities

# For grid layouts
npm install react-grid-layout

# Full page builder framework (most comprehensive)
npm install @craftjs/core
```

| Library               | Purpose                | Why This One                          |
| --------------------- | ---------------------- | ------------------------------------- |
| **@dnd-kit/core**     | Drag and drop          | Modern, accessible, highly performant |
| **react-grid-layout** | Grid-based layouts     | Excellent for email column structures |
| **@craftjs/core**     | Page builder framework | Full visual editor framework          |

## 3.2 Rich Text Editing

### TipTap (Recommended)
```bash
# Core TipTap
npm install @tiptap/react @tiptap/starter-kit @tiptap/pm
npm install @tiptap/extension-placeholder @tiptap/extension-text-align
npm install @tiptap/extension-color @tiptap/extension-text-style
npm install @tiptap/extension-link @tiptap/extension-image

# Tables
npm install @tiptap/extension-table @tiptap/extension-table-row
npm install @tiptap/extension-table-cell @tiptap/extension-table-header

# Additional formatting
npm install @tiptap/extension-highlight @tiptap/extension-underline
npm install @tiptap/extension-subscript @tiptap/extension-superscript
npm install @tiptap/extension-typography @tiptap/extension-character-count

# Merge fields
npm install @tiptap/extension-mention
```

| Library     | Pros                                | Best For              |
| ----------- | ----------------------------------- | --------------------- |
| **TipTap**  | Highly extensible, modern, great DX | Custom email editors  |
| **Lexical** | Facebook-backed, performant         | Complex editing needs |
| **Slate**   | Fully customizable                  | Maximum control       |

## 3.3 UI Component Libraries

### Primary UI Framework (shadcn/ui)
```bash
# Initialize shadcn/ui
npx shadcn-ui@latest init

# Essential components
npx shadcn-ui@latest add button card dialog dropdown-menu input label 
npx shadcn-ui@latest add popover select tabs tooltip accordion alert
npx shadcn-ui@latest add avatar badge checkbox collapsible command
npx shadcn-ui@latest add context-menu form hover-card menubar
npx shadcn-ui@latest add navigation-menu progress radio-group scroll-area
npx shadcn-ui@latest add separator sheet skeleton slider switch table
npx shadcn-ui@latest add textarea toggle
```

### Complementary UI Libraries
```bash
# Icons
npm install lucide-react
npm install @heroicons/react

# Color picker
npm install react-colorful
npm install @uiw/react-color

# Panels and layouts
npm install react-resizable-panels
npm install allotment

# Tooltips and popovers
npm install @floating-ui/react

# Modals and dialogs
npm install @radix-ui/react-dialog
npm install @radix-ui/react-alert-dialog

# Notifications
npm install sonner
npm install react-hot-toast
```

## 3.4 State Management & Data
```bash
# State management
npm install zustand immer

# Undo/redo
npm install use-undo temporal-state

# Data fetching
npm install @tanstack/react-query axios swr
```

## 3.5 Form Handling & Validation
```bash
# Form management
npm install react-hook-form @hookform/resolvers zod
```

## 3.6 Image & Media Handling
```bash
# Image upload and management
npm install react-dropzone browser-image-compression
npm install react-image-crop react-easy-crop

# Image optimization
npm install sharp blurhash

# Media library
npm install react-photo-album yet-another-react-lightbox
```

## 3.7 MatchaAI Integration
```bash
# MatchaAI SDK
npm install axios eventsource-parser ky

# AI Response Handling
npm install ai
npm install marked isomorphic-dompurify remark-gfm

# Streaming support
npm install use-sse
```

## 3.8 Email Preview & Testing
```bash
# Email HTML processing
npm install juice html-to-text sanitize-html

# Preview rendering
npm install react-frame-component srcdoc-polyfill

# Device mockups
npm install react-device-frameset
```

## 3.9 Template Management
```bash
# Template versioning
npm install json-diff deep-diff

# Template storage
npm install idb localforage

# Export/Import
npm install file-saver jszip

# Templating
npm install handlebars liquidjs
```

## 3.10 Analytics & Charts
```bash
# Charts
npm install recharts @tremor/react victory

# Data visualization
npm install d3 visx
```

## 3.11 Utilities
```bash
# General utilities
npm install lodash-es date-fns nanoid uuid

# Keyboard shortcuts
npm install hotkeys-js use-hotkeys

# Clipboard
npm install clipboard-polyfill use-clipboard-copy

# URL handling
npm install is-url normalize-url
```

## 3.12 Testing
```bash
# Unit testing
npm install -D vitest @testing-library/react @testing-library/jest-dom

# E2E testing
npm install -D playwright @playwright/test

# Visual regression
npm install -D @percy/cli @percy/playwright
```

## 3.13 Complete Installation Script
```bash
#!/bin/bash
# Email Template Builder - Complete Dependencies

echo "Installing Email Template Builder dependencies..."

# Email Building
npm install mjml mjml-react @react-email/components

# Drag and Drop
npm install @dnd-kit/core @dnd-kit/sortable @dnd-kit/utilities

# Rich Text Editor (TipTap)
npm install @tiptap/react @tiptap/starter-kit @tiptap/pm
npm install @tiptap/extension-placeholder @tiptap/extension-text-align
npm install @tiptap/extension-color @tiptap/extension-text-style
npm install @tiptap/extension-link @tiptap/extension-image
npm install @tiptap/extension-table @tiptap/extension-table-row
npm install @tiptap/extension-table-cell @tiptap/extension-table-header
npm install @tiptap/extension-highlight @tiptap/extension-underline
npm install @tiptap/extension-mention @tiptap/extension-typography
npm install @tiptap/extension-character-count

# UI Components
npm install lucide-react react-colorful react-resizable-panels
npm install @floating-ui/react sonner

# State Management
npm install zustand immer

# Forms
npm install react-hook-form @hookform/resolvers zod

# Data Fetching
npm install @tanstack/react-query axios

# File Handling
npm install react-dropzone browser-image-compression file-saver

# Email Processing
npm install juice html-to-text sanitize-html

# Templating
npm install handlebars

# MatchaAI Integration
npm install axios eventsource-parser ky ai marked isomorphic-dompurify

# Utilities
npm install lodash-es date-fns nanoid hotkeys-js

# Preview
npm install react-frame-component

# Charts
npm install recharts @tremor/react

echo "Installation complete!"
```

---

# 4. UI COMPONENTS & LAYOUT

## 4.1 Template Library View (Landing Page)
```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 📧 Email Template Studio                                    [+ New Template]│
├─────────────────────────────────────────────────────────────────────────────┤
│ 🔍 Search templates...                     │ Filter ▼ │ Sort: Recent ▼     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  [Quick Actions]                                                            │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│  │ 📝 Blank     │ │ 🚀 QBR      │ │ 📊 NPS       │ │ ⚠️ Risk      │       │
│  │ Template     │ │ Follow-up   │ │ Survey       │ │ Alert        │       │
│  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘       │
│                                                                             │
│  ─────────────────────────────────────────────────────────────────────────  │
│  📚 Template Library                                        View: Grid │ List│
│                                                                             │
│  ┌─────────────────────┐ ┌─────────────────────┐ ┌─────────────────────┐   │
│  │ ┌─────────────────┐ │ │ ┌─────────────────┐ │ │ ┌─────────────────┐ │   │
│  │ │   [Preview      │ │ │ │   [Preview      │ │ │ │   [Preview      │ │   │
│  │ │    Thumbnail]   │ │ │ │    Thumbnail]   │ │ │ │    Thumbnail]   │ │   │
│  │ └─────────────────┘ │ │ └─────────────────┘ │ │ └─────────────────┘ │   │
│  │ QBR Executive Summary│ │ NPS Follow-up      │ │ Renewal Notice      │   │
│  │ 📁 QBR & Reviews     │ │ 📁 NPS & Surveys   │ │ 📁 Renewal          │   │
│  │ Used: 24 times       │ │ Used: 18 times     │ │ Used: 12 times      │   │
│  │ ⭐ 4.8 │ Updated 2d  │ │ ⭐ 4.5 │ Updated 5d│ │ ⭐ 4.9 │ Updated 1w │   │
│  │ [Edit] [Duplicate]   │ │ [Edit] [Duplicate] │ │ [Edit] [Duplicate]  │   │
│  └─────────────────────┘ └─────────────────────┘ └─────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Card Information Display

- Visual thumbnail preview (auto-generated)
- Template name (editable)
- Category tag
- Usage count
- User rating
- Last modified date
- Quick action buttons

## 4.2 Email Editor Interface (Three-Panel Layout)
```
┌────────────────────────────────────────────────────────────────────────────────────┐
│ ← Back to Library    │ QBR Executive Summary - Draft    │ [Preview] [Test] [Save] │
├──────────────────────┴─────────────────────────────────────┴───────────────────────┤
│                                                                                    │
│ ┌─────────────────┐ ┌─────────────────────────────────────┐ ┌───────────────────┐ │
│ │                 │ │                                     │ │                   │ │
│ │   CONTENT       │ │         CANVAS / PREVIEW            │ │    PROPERTIES     │ │
│ │   BLOCKS        │ │                                     │ │    PANEL          │ │
│ │                 │ │  ┌─────────────────────────────┐    │ │                   │ │
│ │ ┌─────────────┐ │ │  │                             │    │ │ Selected Block:   │ │
│ │ │ 📝 Text     │ │ │  │    [Live Preview of        │    │ │ Text Block        │ │
│ │ └─────────────┘ │ │  │     Email Content]          │    │ │ ───────────────── │ │
│ │ ┌─────────────┐ │ │  │                             │    │ │ Font: Inter       │ │
│ │ │ 🖼️ Image    │ │ │  │                             │    │ │ Size: 16px        │ │
│ │ └─────────────┘ │ │  │                             │    │ │ Color: #333333    │ │
│ │ ┌─────────────┐ │ │  │                             │    │ │ Alignment: Left   │ │
│ │ │ 🔘 Button   │ │ │  │                             │    │ │ Padding: 16px     │ │
│ │ └─────────────┘ │ │  │                             │    │ │                   │ │
│ │ ┌─────────────┐ │ │  │                             │    │ │ ───────────────── │ │
│ │ │ ➗ Divider  │ │ │  │                             │    │ │ 🎨 Style Presets  │ │
│ │ └─────────────┘ │ │  │                             │    │ │ [Body] [Header]   │ │
│ │ ┌─────────────┐ │ │  │                             │    │ │ [Caption] [CTA]   │ │
│ │ │ 📊 Table    │ │ │  │                             │    │ │                   │ │
│ │ └─────────────┘ │ │  └─────────────────────────────┘    │ │                   │ │
│ │ ┌─────────────┐ │ │                                     │ │                   │ │
│ │ │ 📋 Columns  │ │ │  Device Preview:                    │ │                   │ │
│ │ └─────────────┘ │ │  [💻 Desktop] [📱 Mobile] [🌙 Dark] │ │                   │ │
│ │                 │ │                                     │ │                   │ │
│ │ ─ CS BLOCKS ─── │ │                                     │ │                   │ │
│ │                 │ │                                     │ │                   │ │
│ │ ┌─────────────┐ │ │                                     │ │                   │ │
│ │ │ 📈 Metrics  │ │ │                                     │ │                   │ │
│ │ └─────────────┘ │ │                                     │ │                   │ │
│ │ ┌─────────────┐ │ │                                     │ │                   │ │
│ │ │ 📅 Meeting  │ │ │                                     │ │                   │ │
│ │ └─────────────┘ │ │                                     │ │                   │ │
│ │ ┌─────────────┐ │ │                                     │ │                   │ │
│ │ │ 💬 Chasen   │ │ │                                     │ │                   │ │
│ │ │   AI Assist │ │ │                                     │ │                   │ │
│ │ └─────────────┘ │ │                                     │ │                   │ │
│ │                 │ │                                     │ │                   │ │
│ └─────────────────┘ └─────────────────────────────────────┘ └───────────────────┘ │
│                                                                                    │
└────────────────────────────────────────────────────────────────────────────────────┘
```

---

# 5. CONTENT BLOCK SYSTEM

## 5.1 Standard Blocks

| Block Type  | Description                    | Drag & Drop | Icon |
| ----------- | ------------------------------ | ----------- | ---- |
| **Text**    | Rich text with formatting      | ✅           | 📝    |
| **Image**   | Single image with alt text     | ✅           | 🖼️    |
| **Button**  | CTA button with link           | ✅           | 🔘    |
| **Divider** | Horizontal line/spacer         | ✅           | ➗    |
| **Table**   | Data table (responsive)        | ✅           | 📊    |
| **Columns** | 2-4 column layouts             | ✅           | 📋    |
| **Video**   | Video thumbnail with play link | ✅           | 📹    |
| **Social**  | Social media icons             | ✅           | 🔗    |
| **Footer**  | Unsubscribe, address, legal    | ✅           | 📍    |

## 5.2 Client Success-Specific Blocks
```
┌─────────────────────────────────────────────────────────────┐
│ 🏥 CLIENT SUCCESS BLOCKS                                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌───────────────────┐  ┌───────────────────┐               │
│ │ 📈 METRICS CARD   │  │ 📊 NPS SCORE      │               │
│ │                   │  │                   │               │
│ │ Shows client KPIs │  │ Visual NPS with   │               │
│ │ with trend arrows │  │ benchmark compare │               │
│ └───────────────────┘  └───────────────────┘               │
│                                                             │
│ ┌───────────────────┐  ┌───────────────────┐               │
│ │ 📅 MEETING LINK   │  │ 🎯 ACTION ITEMS   │               │
│ │                   │  │                   │               │
│ │ Calendar invite   │  │ Checklist with    │               │
│ │ with one-click    │  │ owner & due dates │               │
│ └───────────────────┘  └───────────────────┘               │
│                                                             │
│ ┌───────────────────┐  ┌───────────────────┐               │
│ │ 👤 TEAM CARD      │  │ 📋 HEALTH SUMMARY │               │
│ │                   │  │                   │               │
│ │ CSE/CAM contact   │  │ Mini client       │               │
│ │ with photo & info │  │ health scorecard  │               │
│ └───────────────────┘  └───────────────────┘               │
│                                                             │
│ ┌───────────────────┐  ┌───────────────────┐               │
│ │ 🔄 DYNAMIC DATA   │  │ 💬 AI CONTENT     │               │
│ │                   │  │                   │               │
│ │ Auto-populate     │  │ Generate content  │               │
│ │ from Salesforce   │  │ with Chasen AI    │               │
│ └───────────────────┘  └───────────────────┘               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 5.3 Block Type Definitions
```typescript
// types/blocks.ts

export type BlockType = 
  | 'text'
  | 'image'
  | 'button'
  | 'divider'
  | 'table'
  | 'columns'
  | 'video'
  | 'social'
  | 'footer'
  | 'metrics-card'
  | 'nps-score'
  | 'meeting-link'
  | 'action-items'
  | 'team-card'
  | 'health-summary'
  | 'dynamic-data'
  | 'ai-content';

export interface BaseBlock {
  id: string;
  type: BlockType;
  order: number;
  settings: BlockSettings;
}

export interface BlockSettings {
  padding?: { top: number; right: number; bottom: number; left: number };
  margin?: { top: number; right: number; bottom: number; left: number };
  backgroundColor?: string;
  borderRadius?: number;
  alignment?: 'left' | 'center' | 'right';
}

export interface TextBlock extends BaseBlock {
  type: 'text';
  content: {
    html: string;
    plainText: string;
  };
  style: {
    fontFamily: string;
    fontSize: number;
    fontWeight: number;
    color: string;
    lineHeight: number;
  };
}

export interface MetricsCardBlock extends BaseBlock {
  type: 'metrics-card';
  content: {
    title: string;
    metrics: Array<{
      label: string;
      value: string;
      trend?: 'up' | 'down' | 'neutral';
      trendValue?: string;
    }>;
  };
}

export interface NPSScoreBlock extends BaseBlock {
  type: 'nps-score';
  content: {
    score: number | string; // Can be merge field
    benchmark?: number;
    showBenchmark: boolean;
    label?: string;
  };
}

export interface MeetingLinkBlock extends BaseBlock {
  type: 'meeting-link';
  content: {
    title: string;
    date: string;
    time: string;
    duration: string;
    meetingUrl: string;
    addToCalendarEnabled: boolean;
  };
}
```

---

# 6. PERSONALISATION & MERGE FIELDS

## 6.1 Merge Field Categories
```typescript
// lib/merge-fields/fields.ts

export const MERGE_FIELDS = {
  
  // Recipient Fields
  recipient: {
    "{{recipient.first_name}}": "Contact first name",
    "{{recipient.last_name}}": "Contact last name",
    "{{recipient.full_name}}": "Contact full name",
    "{{recipient.title}}": "Job title",
    "{{recipient.email}}": "Email address"
  },
  
  // Client/Account Fields
  client: {
    "{{client.name}}": "Organisation name",
    "{{client.segment}}": "Client segment",
    "{{client.cse_name}}": "Assigned CSE name",
    "{{client.cse_email}}": "CSE email",
    "{{client.cse_phone}}": "CSE phone",
    "{{client.cam_name}}": "Assigned CAM name",
    "{{client.arr}}": "Annual Recurring Revenue",
    "{{client.contract_end}}": "Contract end date",
    "{{client.days_to_renewal}}": "Days until renewal"
  },
  
  // Metrics Fields (Auto-populated)
  metrics: {
    "{{metrics.nps_score}}": "Current NPS score",
    "{{metrics.nps_trend}}": "NPS trend (↑/↓/→)",
    "{{metrics.support_tickets}}": "Open support tickets",
    "{{metrics.adoption_rate}}": "Platform adoption %",
    "{{metrics.health_score}}": "Overall health score"
  },
  
  // Meeting Fields
  meeting: {
    "{{meeting.date}}": "Scheduled meeting date",
    "{{meeting.time}}": "Meeting time",
    "{{meeting.link}}": "Meeting URL",
    "{{meeting.agenda}}": "Meeting agenda"
  },
  
  // Dynamic Content
  dynamic: {
    "{{dynamic.recent_wins}}": "Recent client successes",
    "{{dynamic.open_actions}}": "Outstanding action items",
    "{{dynamic.product_updates}}": "Relevant product news"
  },
  
  // Sender Fields
  sender: {
    "{{sender.name}}": "Your name",
    "{{sender.title}}": "Your job title",
    "{{sender.email}}": "Your email",
    "{{sender.phone}}": "Your phone",
    "{{sender.signature}}": "Your email signature",
    "{{sender.calendar_link}}": "Your booking link"
  }
};
```

## 6.2 Merge Field Insertion UI
```
┌─────────────────────────────────────────────────────────┐
│ Insert Personalisation                              [X] │
├─────────────────────────────────────────────────────────┤
│ 🔍 Search fields...                                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ 👤 RECIPIENT                                            │
│   {{recipient.first_name}}     First Name               │
│   {{recipient.full_name}}      Full Name                │
│   {{recipient.title}}          Job Title                │
│                                                         │
│ 🏥 CLIENT                                               │
│   {{client.name}}              Organisation Name        │
│   {{client.segment}}           Segment                  │
│   {{client.cse_name}}          Your CSE                 │
│                                                         │
│ 📊 METRICS                                              │
│   {{metrics.nps_score}}        NPS Score                │
│   {{metrics.health_score}}     Health Score             │
│                                                         │
│ 📅 MEETING                                              │
│   {{meeting.date}}             Meeting Date             │
│   {{meeting.link}}             Meeting URL              │
│                                                         │
│ ─────────────────────────────────────────────────────── │
│ 💡 Tip: Click any field to insert at cursor position   │
└─────────────────────────────────────────────────────────┘
```

---

# 7. MATCHAAI INTEGRATION (CHASEN)

## 7.1 MatchaAI Client Configuration
```typescript
// lib/matcha-ai/client.ts

import axios from 'axios';

interface MatchaAIConfig {
  apiKey: string;
  baseUrl: string;
  model?: string;
  timeout?: number;
}

interface MatchaAIMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

interface MatchaAICompletionRequest {
  messages: MatchaAIMessage[];
  temperature?: number;
  maxTokens?: number;
  stream?: boolean;
  context?: Record<string, unknown>;
}

interface MatchaAICompletionResponse {
  id: string;
  content: string;
  usage: {
    promptTokens: number;
    completionTokens: number;
    totalTokens: number;
  };
  metadata?: Record<string, unknown>;
}

class MatchaAIClient {
  private config: MatchaAIConfig;
  private client: axios.AxiosInstance;

  constructor(config: MatchaAIConfig) {
    this.config = config;
    this.client = axios.create({
      baseURL: config.baseUrl,
      timeout: config.timeout || 30000,
      headers: {
        'Authorization': `Bearer ${config.apiKey}`,
        'Content-Type': 'application/json',
        'X-MatchaAI-Client': 'APAC-CS-Intelligence-Hub',
      },
    });
  }

  async complete(request: MatchaAICompletionRequest): Promise<MatchaAICompletionResponse> {
    const response = await this.client.post('/v1/completions', {
      model: this.config.model || 'chasen-v1',
      ...request,
    });
    return response.data;
  }

  async *streamComplete(request: MatchaAICompletionRequest): AsyncGenerator<string> {
    const response = await this.client.post('/v1/completions/stream', {
      model: this.config.model || 'chasen-v1',
      ...request,
      stream: true,
    }, {
      responseType: 'stream',
    });

    for await (const chunk of response.data) {
      const text = chunk.toString();
      yield text;
    }
  }
}

export const matchaAI = new MatchaAIClient({
  apiKey: process.env.MATCHA_AI_API_KEY!,
  baseUrl: process.env.MATCHA_AI_BASE_URL || 'https://api.matcha-ai.com',
  model: 'chasen-v1',
});

export type { 
  MatchaAIConfig, 
  MatchaAIMessage, 
  MatchaAICompletionRequest, 
  MatchaAICompletionResponse 
};
```

## 7.2 Chasen System Prompts
```typescript
// lib/matcha-ai/chasen-prompts.ts

export const CHASEN_SYSTEM_PROMPTS = {
  
  emailAssistant: `You are Chasen, the AI-powered email assistant for APAC Client Success at Altera Digital Health.

Your role is to help craft professional, empathetic, and effective client communications for healthcare technology stakeholders.

CONTEXT:
- You serve healthcare organisations across Australia, New Zealand, Singapore, Philippines, and Guam
- Clients include major health systems like SA Health, SingHealth, WA Health, and Epworth HealthCare
- Communications must be appropriate for clinical, IT, and executive stakeholders
- Tone should be professional yet warm, evidence-based, and action-oriented

GUIDELINES:
1. Use clear, concise language appropriate for busy healthcare executives
2. Lead with value and outcomes, not features
3. Include specific metrics and data points where relevant
4. Provide clear next steps and calls-to-action
5. Be mindful of healthcare compliance and sensitivity
6. Personalise based on client segment and stakeholder type`,

  contentImprover: `You are Chasen, helping to improve email content for Client Success communications.

When improving content:
- Enhance clarity and readability
- Strengthen calls-to-action
- Ensure professional tone appropriate for healthcare
- Maintain the original intent and key messages
- Suggest merge field opportunities for personalisation`,

  subjectLineGenerator: `You are Chasen, generating compelling email subject lines.

For each request, provide 3-5 subject line options:
1. Direct and clear (under 50 characters)
2. Value-focused (highlighting benefit)
3. Personalised (using merge fields)
4. Curiosity-driven (if appropriate)
5. Urgency-appropriate (only if genuinely time-sensitive)

Always consider healthcare context and executive audience.`,

  toneAdjuster: `You are Chasen, adjusting email tone while preserving core message.

Available tones:
- PROFESSIONAL: Formal, business-appropriate
- FRIENDLY: Warm, approachable, relationship-focused
- URGENT: Time-sensitive, action-required
- CELEBRATORY: Positive, achievement-focused
- EMPATHETIC: Understanding, supportive (for difficult situations)
- EXECUTIVE: Concise, high-level, strategic`,

};

export const EMAIL_TEMPLATE_PROMPTS = {
  
  qbrSummary: (clientData: Record<string, unknown>) => `
Generate a QBR executive summary email for ${clientData.clientName}.

Client Context:
- Segment: ${clientData.segment}
- NPS Score: ${clientData.npsScore} (${clientData.npsTrend})
- ARR: ${clientData.arr}
- Key Stakeholder: ${clientData.stakeholderName}, ${clientData.stakeholderTitle}
- Recent highlights: ${clientData.recentHighlights}
- Open actions: ${clientData.openActions}

Generate a professional summary that:
1. Opens with appreciation for the QBR session
2. Highlights 2-3 key achievements/metrics
3. Summarises agreed action items with owners
4. Sets expectations for next touchpoint
5. Ends with clear CTA for any questions`,

  npsFollowUp: (type: 'promoter' | 'passive' | 'detractor', context: Record<string, unknown>) => {
    const prompts = {
      promoter: `Generate a thank you email for a PROMOTER (NPS 9-10) response.
        - Express genuine appreciation
        - Reference specific feedback if provided
        - Invite to case study/reference opportunity
        - Ask for referral if appropriate`,
      passive: `Generate a follow-up email for a PASSIVE (NPS 7-8) response.
        - Acknowledge their feedback thoughtfully
        - Ask what would make their experience exceptional
        - Offer specific improvement commitments
        - Schedule follow-up discussion`,
      detractor: `Generate a response email for a DETRACTOR (NPS 0-6) response.
        - Lead with empathy and acknowledgment
        - Take ownership without being defensive
        - Outline specific remediation steps
        - Commit to personal follow-up from CSE/leadership
        - Set clear timeline for improvement actions`,
    };
    
    return `${prompts[type]}
    
Client: ${context.clientName}
NPS Score: ${context.npsScore}
Feedback: ${context.feedback}
Primary Contact: ${context.contactName}`;
  },

  riskMitigation: (riskLevel: 'high' | 'critical', context: Record<string, unknown>) => `
Generate a ${riskLevel === 'critical' ? 'urgent ' : ''}risk mitigation communication for ${context.clientName}.

Risk Context:
- Risk Level: ${riskLevel.toUpperCase()}
- Primary Issue: ${context.primaryIssue}
- Impact: ${context.impact}
- Days to Renewal: ${context.daysToRenewal}
- Escalation Status: ${context.escalationStatus}

The email should:
1. Acknowledge the situation directly
2. Take clear ownership
3. Present concrete mitigation plan with timeline
4. Identify executive sponsor/escalation path
5. Commit to regular status updates
6. End with confidence in resolution`,

  renewalOutreach: (context: Record<string, unknown>) => `
Generate a renewal conversation starter for ${context.clientName}.

Renewal Context:
- Days to Renewal: ${context.daysToRenewal}
- Current ARR: ${context.currentARR}
- Contract Term: ${context.contractTerm}
- Relationship Health: ${context.healthScore}
- Expansion Opportunities: ${context.expansionOpportunities}

The email should:
1. Reference the partnership journey and key achievements
2. Acknowledge upcoming renewal timeline
3. Express commitment to continued success
4. Propose a strategic planning discussion
5. Hint at value-add opportunities without being pushy`,

};
```

## 7.3 React Hook for MatchaAI
```typescript
// hooks/useMatchaAI.ts

import { useState, useCallback } from 'react';
import { matchaAI, MatchaAIMessage } from '@/lib/matcha-ai/client';
import { CHASEN_SYSTEM_PROMPTS } from '@/lib/matcha-ai/chasen-prompts';

interface UseMatchaAIOptions {
  systemPrompt?: string;
  temperature?: number;
  maxTokens?: number;
  onStream?: (chunk: string) => void;
}

interface UseMatchaAIReturn {
  generate: (prompt: string, context?: Record<string, unknown>) => Promise<string>;
  streamGenerate: (prompt: string, context?: Record<string, unknown>) => Promise<void>;
  isLoading: boolean;
  error: Error | null;
  response: string;
  clearResponse: () => void;
}

export function useMatchaAI(options: UseMatchaAIOptions = {}): UseMatchaAIReturn {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [response, setResponse] = useState('');

  const {
    systemPrompt = CHASEN_SYSTEM_PROMPTS.emailAssistant,
    temperature = 0.7,
    maxTokens = 2000,
    onStream,
  } = options;

  const generate = useCallback(async (
    prompt: string,
    context?: Record<string, unknown>
  ): Promise<string> => {
    setIsLoading(true);
    setError(null);

    try {
      const messages: MatchaAIMessage[] = [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: prompt },
      ];

      const result = await matchaAI.complete({
        messages,
        temperature,
        maxTokens,
        context,
      });

      setResponse(result.content);
      return result.content;
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Unknown error');
      setError(error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  }, [systemPrompt, temperature, maxTokens]);

  const streamGenerate = useCallback(async (
    prompt: string,
    context?: Record<string, unknown>
  ): Promise<void> => {
    setIsLoading(true);
    setError(null);
    setResponse('');

    try {
      const messages: MatchaAIMessage[] = [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: prompt },
      ];

      let fullResponse = '';

      for await (const chunk of matchaAI.streamComplete({
        messages,
        temperature,
        maxTokens,
        context,
        stream: true,
      })) {
        fullResponse += chunk;
        setResponse(fullResponse);
        onStream?.(chunk);
      }
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Unknown error');
      setError(error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  }, [systemPrompt, temperature, maxTokens, onStream]);

  const clearResponse = useCallback(() => {
    setResponse('');
    setError(null);
  }, []);

  return {
    generate,
    streamGenerate,
    isLoading,
    error,
    response,
    clearResponse,
  };
}
```

## 7.4 Chasen AI Assist Component
```typescript
// components/email-builder/AI/ChasenAssist.tsx

import React, { useState } from 'react';
import { useMatchaAI } from '@/hooks/useMatchaAI';
import { CHASEN_SYSTEM_PROMPTS, EMAIL_TEMPLATE_PROMPTS } from '@/lib/matcha-ai/chasen-prompts';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { 
  Sparkles, Wand2, MessageSquare, Loader2, RefreshCw,
  ThumbsUp, ThumbsDown, Copy, Check, Zap
} from 'lucide-react';

interface ChasenAssistProps {
  onInsertContent: (content: string) => void;
  currentContent?: string;
  clientContext?: Record<string, unknown>;
}

type QuickAction = 'improve' | 'simplify' | 'shorten' | 'expand' | 'add-cta' | 'rephrase';

const QUICK_ACTIONS: { id: QuickAction; label: string; icon: React.ReactNode; prompt: string }[] = [
  { 
    id: 'improve', 
    label: 'Improve Tone', 
    icon: <Sparkles className="h-4 w-4" />, 
    prompt: 'Improve the tone and professionalism of this content while maintaining the core message:' 
  },
  { 
    id: 'simplify', 
    label: 'Simplify', 
    icon: <Wand2 className="h-4 w-4" />, 
    prompt: 'Simplify this content for easier reading while keeping key information:' 
  },
  { 
    id: 'shorten', 
    label: 'Shorten', 
    icon: <MessageSquare className="h-4 w-4" />, 
    prompt: 'Make this content more concise without losing important details:' 
  },
  { 
    id: 'expand', 
    label: 'Expand', 
    icon: <MessageSquare className="h-4 w-4" />, 
    prompt: 'Expand this content with more detail and context:' 
  },
  { 
    id: 'add-cta', 
    label: 'Add CTA', 
    icon: <Zap className="h-4 w-4" />, 
    prompt: 'Add a clear, compelling call-to-action to this content:' 
  },
  { 
    id: 'rephrase', 
    label: 'Rephrase', 
    icon: <RefreshCw className="h-4 w-4" />, 
    prompt: 'Rephrase this content in a different way while maintaining the same meaning:' 
  },
];

export function ChasenAssist({ onInsertContent, currentContent, clientContext }: ChasenAssistProps) {
  const [customPrompt, setCustomPrompt] = useState('');
  const [copied, setCopied] = useState(false);
  
  const { generate, streamGenerate, isLoading, error, response, clearResponse } = useMatchaAI({
    systemPrompt: CHASEN_SYSTEM_PROMPTS.emailAssistant,
    temperature: 0.7,
  });

  const handleQuickAction = async (action: QuickAction) => {
    const actionConfig = QUICK_ACTIONS.find(a => a.id === action);
    if (!actionConfig || !currentContent) return;
    await streamGenerate(`${actionConfig.prompt}\n\n${currentContent}`, clientContext);
  };

  const handleCustomGenerate = async () => {
    if (!customPrompt.trim()) return;
    const fullPrompt = currentContent 
      ? `${customPrompt}\n\nCurrent content:\n${currentContent}`
      : customPrompt;
    await streamGenerate(fullPrompt, clientContext);
  };

  const handleInsert = () => {
    if (response) {
      onInsertContent(response);
      clearResponse();
    }
  };

  const handleCopy = async () => {
    if (response) {
      await navigator.clipboard.writeText(response);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  return (
    <Card className="w-full">
      <CardHeader className="pb-3">
        <CardTitle className="flex items-center gap-2 text-lg">
          <div className="h-8 w-8 rounded-full bg-gradient-to-br from-green-400 to-emerald-600 flex items-center justify-center">
            <Sparkles className="h-4 w-4 text-white" />
          </div>
          <span>Chasen AI Assist</span>
          <span className="text-xs font-normal text-muted-foreground ml-auto">
            Powered by MatchaAI
          </span>
        </CardTitle>
      </CardHeader>
      
      <CardContent className="space-y-4">
        {/* Custom Prompt Input */}
        <div className="space-y-2">
          <Textarea
            placeholder="Ask Chasen to help with your email... e.g., 'Write a follow-up email for SA Health after their QBR showing NPS improvement'"
            value={customPrompt}
            onChange={(e) => setCustomPrompt(e.target.value)}
            className="min-h-[80px] resize-none"
          />
          <Button 
            onClick={handleCustomGenerate}
            disabled={isLoading || !customPrompt.trim()}
            className="w-full bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700"
          >
            {isLoading ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Generating...
              </>
            ) : (
              <>
                <Sparkles className="mr-2 h-4 w-4" />
                Generate with Chasen
              </>
            )}
          </Button>
        </div>

        {/* Quick Actions */}
        {currentContent && (
          <div className="space-y-2">
            <p className="text-sm font-medium text-muted-foreground">Quick Actions</p>
            <div className="flex flex-wrap gap-2">
              {QUICK_ACTIONS.map((action) => (
                <Button
                  key={action.id}
                  variant="outline"
                  size="sm"
                  onClick={() => handleQuickAction(action.id)}
                  disabled={isLoading}
                >
                  {action.icon}
                  <span className="ml-1">{action.label}</span>
                </Button>
              ))}
            </div>
          </div>
        )}

        {/* Response Display */}
        {response && (
          <div className="space-y-2 pt-2 border-t">
            <div className="flex items-center justify-between">
              <p className="text-sm font-medium">Chasen's Suggestion</p>
              <div className="flex gap-1">
                <Button variant="ghost" size="icon" className="h-8 w-8">
                  <ThumbsUp className="h-4 w-4" />
                </Button>
                <Button variant="ghost" size="icon" className="h-8 w-8">
                  <ThumbsDown className="h-4 w-4" />
                </Button>
              </div>
            </div>
            
            <div className="bg-muted/50 rounded-lg p-3 text-sm whitespace-pre-wrap max-h-[200px] overflow-y-auto">
              {response}
            </div>
            
            <div className="flex gap-2">
              <Button onClick={handleInsert} className="flex-1">
                <Check className="mr-2 h-4 w-4" />
                Insert into Email
              </Button>
              <Button variant="outline" onClick={handleCopy}>
                {copied ? <Check className="h-4 w-4" /> : <Copy className="h-4 w-4" />}
              </Button>
              <Button variant="outline" onClick={clearResponse}>
                <RefreshCw className="h-4 w-4" />
              </Button>
            </div>
          </div>
        )}

        {/* Error Display */}
        {error && (
          <div className="bg-destructive/10 text-destructive rounded-lg p-3 text-sm">
            {error.message}
          </div>
        )}

        {/* Context-Aware Suggestions */}
        {clientContext && (
          <div className="space-y-2 pt-2 border-t">
            <p className="text-sm font-medium text-muted-foreground">Generate From Context</p>
            <div className="grid grid-cols-1 gap-2">
              <Button
                variant="secondary"
                size="sm"
                className="justify-start"
                onClick={() => generate(EMAIL_TEMPLATE_PROMPTS.qbrSummary(clientContext))}
                disabled={isLoading}
              >
                📊 Write QBR summary for {String(clientContext.clientName)}
              </Button>
              <Button
                variant="secondary"
                size="sm"
                className="justify-start"
                onClick={() => generate(EMAIL_TEMPLATE_PROMPTS.npsFollowUp('passive', clientContext))}
                disabled={isLoading}
              >
                📈 Create NPS follow-up based on feedback
              </Button>
              <Button
                variant="secondary"
                size="sm"
                className="justify-start"
                onClick={() => generate(EMAIL_TEMPLATE_PROMPTS.renewalOutreach(clientContext))}
                disabled={isLoading}
              >
                🔄 Draft renewal conversation starter
              </Button>
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  );
}

export default ChasenAssist;
```

---

# 8. TEMPLATE MANAGEMENT

## 8.1 Template Settings Panel
```
┌─────────────────────────────────────────────────────────┐
│ ⚙️ Template Settings                                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ BASIC INFORMATION                                       │
│ ─────────────────────────────────────────────────────── │
│ Template Name:                                          │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ QBR Executive Summary                               │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ Description:                                            │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ Post-QBR summary email for executive stakeholders   │ │
│ │ highlighting key metrics and action items.          │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ Category:           │ Stakeholder Type:                 │
│ [QBR & Reviews    ▼]│ [C-Suite / Executive          ▼] │
│                                                         │
│ Client Segments (select all that apply):                │
│ ☑️ Giants  ☑️ Sleeping Giants  ☑️ Leverage              │
│ ☐ Collaborate  ☐ Nurture  ☐ Maintain                   │
│                                                         │
│ ─────────────────────────────────────────────────────── │
│ EMAIL SETTINGS                                          │
│ ─────────────────────────────────────────────────────── │
│                                                         │
│ Default Subject Line:                                   │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ {{client.name}} Quarterly Business Review Summary   │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ Preview Text:                                           │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ Key highlights and action items from our Q{{quarter}}│ │
│ │ review session...                                   │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ From Name:          │ Reply-To:                         │
│ [{{sender.name}}  ▼]│ [{{sender.email}}              ▼] │
│                                                         │
│ ─────────────────────────────────────────────────────── │
│ SHARING & PERMISSIONS                                   │
│ ─────────────────────────────────────────────────────── │
│                                                         │
│ Visibility:                                             │
│ ○ Private (only me)                                     │
│ ● Team (all APAC CS)                                    │
│ ○ Organisation (all Altera)                             │
│                                                         │
│ Allow others to:                                        │
│ ☑️ View  ☑️ Duplicate  ☐ Edit                          │
│                                                         │
│                              [Cancel]  [Save Settings]  │
└─────────────────────────────────────────────────────────┘
```

## 8.2 Template Data Model
```typescript
// types/email.ts

export interface EmailTemplate {
  id: string;
  name: string;
  description: string;
  category: TemplateCategory;
  segments: ClientSegment[];
  stakeholderTypes: StakeholderType[];
  
  // Content
  subject: string;
  previewText: string;
  mjmlContent: string;
  htmlContent: string;
  plainTextContent: string;
  blocks: Block[];
  
  // Metadata
  createdBy: string;
  createdAt: Date;
  updatedAt: Date;
  version: number;
  status: 'draft' | 'published' | 'archived';
  
  // Sharing
  visibility: 'private' | 'team' | 'organization';
  permissions: Permission[];
  
  // Analytics
  usageCount: number;
  avgOpenRate: number;
  avgClickRate: number;
  avgReplyRate: number;
  rating: number;
  
  // AI Metadata
  aiGenerated: boolean;
  lastAiSuggestion?: string;
}

export type TemplateCategory = 
  | 'onboarding'
  | 'qbr'
  | 'nps'
  | 'product-updates'
  | 'risk'
  | 'renewal'
  | 'events';

export type ClientSegment = 
  | 'giants'
  | 'sleeping-giants'
  | 'leverage'
  | 'collaborate'
  | 'nurture'
  | 'maintain';

export type StakeholderType = 
  | 'c-suite'
  | 'clinical'
  | 'it-technical'
  | 'operational';

export interface Permission {
  userId: string;
  role: 'viewer' | 'editor' | 'admin';
}
```

---

# 9. PREVIEW & TESTING

## 9.1 Multi-Device Preview
```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 👁️ Preview & Test                                                    [X]   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│ Device Preview:  [💻 Desktop]  [📱 Mobile]  [🌙 Dark Mode]                 │
│                                                                             │
│ ┌─────────────────────────────────────────────────────────────────────────┐ │
│ │                                                                         │ │
│ │                    ┌───────────────────────┐                            │ │
│ │                    │                       │                            │ │
│ │                    │   📱                  │                            │ │
│ │                    │   Mobile Preview      │                            │ │
│ │                    │   375 x 667px         │                            │ │
│ │                    │                       │                            │ │
│ │                    │   [Email Content      │                            │ │
│ │                    │    Renders Here]      │                            │ │
│ │                    │                       │                            │ │
│ │                    │                       │                            │ │
│ │                    │                       │                            │ │
│ │                    └───────────────────────┘                            │ │
│ │                                                                         │ │
│ └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│ ─────────────────────────────────────────────────────────────────────────── │
│                                                                             │
│ TEST EMAIL                                                                  │
│                                                                             │
│ Preview with data from:  [Select Client...                              ▼] │
│                                                                             │
│ Send test to:                                                               │
│ ┌─────────────────────────────────────────────────────────────────────────┐ │
│ │ dimitri.leimonitis@altera.com                                           │ │
│ └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│                                                    [Send Test Email]        │
│                                                                             │
│ ─────────────────────────────────────────────────────────────────────────── │
│                                                                             │
│ ✅ QUALITY CHECKS                                                           │
│                                                                             │
│ ✅ All merge fields have fallback values                                    │
│ ✅ Images have alt text                                                     │
│ ✅ Links are valid                                                          │
│ ⚠️ Subject line is 68 characters (recommended: <50)                        │
│ ✅ Unsubscribe link present                                                 │
│ ✅ Plain text version generated                                             │
│                                                                             │
│ Spam Score: 🟢 2.1/10 (Low risk)                                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 9.2 Quality Check System
```typescript
// lib/email/quality-checks.ts

export interface QualityCheck {
  id: string;
  name: string;
  status: 'pass' | 'warning' | 'fail';
  message: string;
  severity: 'low' | 'medium' | 'high';
}

export function runQualityChecks(template: EmailTemplate): QualityCheck[] {
  const checks: QualityCheck[] = [];
  
  // Subject line length
  checks.push({
    id: 'subject-length',
    name: 'Subject Line Length',
    status: template.subject.length <= 50 ? 'pass' : 
            template.subject.length <= 70 ? 'warning' : 'fail',
    message: `Subject is ${template.subject.length} characters (recommended: <50)`,
    severity: 'medium',
  });
  
  // Merge field fallbacks
  const mergeFields = template.mjmlContent.match(/\{\{[^}]+\}\}/g) || [];
  const hasFallbacks = mergeFields.every(field => 
    template.mjmlContent.includes(`${field.slice(0, -2)} | default:`));
  checks.push({
    id: 'merge-fallbacks',
    name: 'Merge Field Fallbacks',
    status: hasFallbacks ? 'pass' : 'warning',
    message: hasFallbacks 
      ? 'All merge fields have fallback values'
      : 'Some merge fields missing fallback values',
    severity: 'medium',
  });
  
  // Image alt text
  const images = template.mjmlContent.match(/<mj-image[^>]*>/g) || [];
  const hasAltText = images.every(img => img.includes('alt='));
  checks.push({
    id: 'image-alt',
    name: 'Image Alt Text',
    status: hasAltText ? 'pass' : 'warning',
    message: hasAltText 
      ? 'All images have alt text'
      : 'Some images missing alt text',
    severity: 'medium',
  });
  
  // Unsubscribe link
  const hasUnsubscribe = template.mjmlContent.includes('unsubscribe') ||
                         template.mjmlContent.includes('{{unsubscribe_link}}');
  checks.push({
    id: 'unsubscribe',
    name: 'Unsubscribe Link',
    status: hasUnsubscribe ? 'pass' : 'fail',
    message: hasUnsubscribe 
      ? 'Unsubscribe link present'
      : 'Missing unsubscribe link (required for compliance)',
    severity: 'high',
  });
  
  // Plain text version
  checks.push({
    id: 'plain-text',
    name: 'Plain Text Version',
    status: template.plainTextContent ? 'pass' : 'warning',
    message: template.plainTextContent 
      ? 'Plain text version generated'
      : 'No plain text version (may affect deliverability)',
    severity: 'low',
  });
  
  return checks;
}
```

---

# 10. BRAND KIT & DESIGN ASSETS

## 10.1 Brand Configuration Panel
```
┌─────────────────────────────────────────────────────────┐
│ 🎨 Brand Kit                                            │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ COLORS                                                  │
│ ─────────────────────────────────────────────────────── │
│                                                         │
│ Primary:    [████████] #0066CC   │ [Edit]              │
│ Secondary:  [████████] #00A896   │ [Edit]              │
│ Accent:     [████████] #FF6B35   │ [Edit]              │
│ Dark:       [████████] #1A1A2E   │ [Edit]              │
│ Light:      [████████] #F5F5F5   │ [Edit]              │
│                                                         │
│ TYPOGRAPHY                                              │
│ ─────────────────────────────────────────────────────── │
│                                                         │
│ Headings:   [Inter                                  ▼]  │
│ Body:       [Inter                                  ▼]  │
│                                                         │
│ LOGOS                                                   │
│ ─────────────────────────────────────────────────────── │
│                                                         │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐                    │
│ │ [Logo]  │ │ [Logo]  │ │ [Logo]  │                    │
│ │ Primary │ │ White   │ │ Icon    │                    │
│ └─────────┘ └─────────┘ └─────────┘                    │
│                                                         │
│ [+ Upload New Asset]                                    │
│                                                         │
│ SIGNATURE BLOCKS                                        │
│ ─────────────────────────────────────────────────────── │
│                                                         │
│ ┌─────────────────────────────────────┐                │
│ │ Dimitri Leimonitis                  │                │
│ │ VP, Client Success - APAC           │  [Edit]        │
│ │ Altera Digital Health               │  [Set Default] │
│ │ M: +61 XXX XXX XXX                  │                │
│ └─────────────────────────────────────┘                │
│                                                         │
│ [+ Create New Signature]                                │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## 10.2 Brand Configuration Types
```typescript
// types/brand.ts

export interface BrandKit {
  id: string;
  name: string;
  
  colors: {
    primary: string;
    secondary: string;
    accent: string;
    dark: string;
    light: string;
    success: string;
    warning: string;
    error: string;
  };
  
  typography: {
    headingFont: string;
    bodyFont: string;
    headingSizes: {
      h1: number;
      h2: number;
      h3: number;
      h4: number;
    };
    bodySize: number;
    lineHeight: number;
  };
  
  logos: {
    primary: string;      // URL
    white: string;        // URL
    icon: string;         // URL
    favicon: string;      // URL
  };
  
  signatures: EmailSignature[];
  
  socialLinks: {
    linkedin?: string;
    twitter?: string;
    facebook?: string;
    website: string;
  };
}

export interface EmailSignature {
  id: string;
  name: string;
  title: string;
  company: string;
  email: string;
  phone?: string;
  mobile?: string;
  photo?: string;
  calendarLink?: string;
  isDefault: boolean;
}
```

---

# 11. ANALYTICS & REPORTING

## 11.1 Performance Dashboard
```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 📊 Template Analytics                                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│ Date Range: [Last 30 Days ▼]                    [Export Report]            │
│                                                                             │
│ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────┐│
│ │ 📧 248          │ │ 👁️ 67%          │ │ 🖱️ 23%          │ │ ↩️ 12%      ││
│ │ Emails Sent     │ │ Open Rate       │ │ Click Rate      │ │ Reply Rate  ││
│ │ ↑ 15% vs prev   │ │ ↑ 5% vs prev    │ │ ↓ 2% vs prev    │ │ ↑ 8% vs prev││
│ └─────────────────┘ └─────────────────┘ └─────────────────┘ └─────────────┘│
│                                                                             │
│ TOP PERFORMING TEMPLATES                                                    │
│ ─────────────────────────────────────────────────────────────────────────── │
│                                                                             │
│ │ Template                    │ Sent │ Open % │ Click % │ Reply % │ Score ││
│ ├─────────────────────────────┼──────┼────────┼─────────┼─────────┼───────┤│
│ │ 🥇 QBR Executive Summary    │  42  │  78%   │   34%   │   18%   │  92   ││
│ │ 🥈 NPS Promoter Thank You   │  28  │  72%   │   28%   │   15%   │  87   ││
│ │ 🥉 Renewal Check-in         │  35  │  69%   │   25%   │   22%   │  85   ││
│ │    Risk Alert Follow-up     │  18  │  82%   │   45%   │   28%   │  84   ││
│ │    Product Update Digest    │  56  │  54%   │   18%   │    8%   │  72   ││
│                                                                             │
│ ─────────────────────────────────────────────────────────────────────────── │
│                                                                             │
│ USAGE BY TEAM MEMBER                                                        │
│                                                                             │
│ ██████████████████████████  Dimitri L.  (68)                               │
│ ████████████████            Sarah M.    (42)                               │
│ ██████████████              James K.    (38)                               │
│ ████████████                Amy T.      (31)                               │
│                                                                             │
│ ─────────────────────────────────────────────────────────────────────────── │
│                                                                             │
│ PERFORMANCE BY CATEGORY                                                     │
│                                                                             │
│ [Line chart showing open rates over time by category]                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

# 12. TECHNICAL IMPLEMENTATION

## 12.1 Project Architecture
```
src/
├── components/
│   ├── email-builder/
│   │   ├── Editor/
│   │   │   ├── Canvas.tsx              # Main editing canvas
│   │   │   ├── BlockLibrary.tsx        # Draggable blocks panel
│   │   │   ├── PropertiesPanel.tsx     # Block settings
│   │   │   ├── Toolbar.tsx             # Formatting tools
│   │   │   └── EditorHeader.tsx        # Save, preview, settings
│   │   ├── Blocks/
│   │   │   ├── TextBlock.tsx
│   │   │   ├── ImageBlock.tsx
│   │   │   ├── ButtonBlock.tsx
│   │   │   ├── ColumnsBlock.tsx
│   │   │   ├── TableBlock.tsx
│   │   │   ├── DividerBlock.tsx
│   │   │   ├── MetricsBlock.tsx        # CS-specific
│   │   │   ├── NPSBlock.tsx            # CS-specific
│   │   │   ├── MeetingBlock.tsx        # CS-specific
│   │   │   ├── HealthScoreBlock.tsx    # CS-specific
│   │   │   └── index.ts
│   │   ├── Preview/
│   │   │   ├── DevicePreview.tsx
│   │   │   ├── DarkModePreview.tsx
│   │   │   ├── TestEmailDialog.tsx
│   │   │   └── QualityChecks.tsx
│   │   ├── MergeFields/
│   │   │   ├── MergeFieldPicker.tsx
│   │   │   ├── MergeFieldPreview.tsx
│   │   │   └── MergeFieldHighlight.tsx
│   │   └── AI/
│   │       ├── ChasenAssist.tsx
│   │       ├── ContentGenerator.tsx
│   │       ├── SubjectLineGenerator.tsx
│   │       └── ToneSelector.tsx
│   ├── template-library/
│   │   ├── TemplateGrid.tsx
│   │   ├── TemplateCard.tsx
│   │   ├── TemplateFilters.tsx
│   │   ├── TemplateSearch.tsx
│   │   └── QuickActions.tsx
│   ├── brand-kit/
│   │   ├── ColorPalette.tsx
│   │   ├── FontSelector.tsx
│   │   ├── LogoManager.tsx
│   │   └── SignatureEditor.tsx
│   └── analytics/
│       ├── PerformanceDashboard.tsx
│       ├── TemplateMetrics.tsx
│       ├── UsageChart.tsx
│       └── TeamLeaderboard.tsx
├── hooks/
│   ├── useEmailBuilder.ts
│   ├── useTemplateStorage.ts
│   ├── useMergeFields.ts
│   ├── useEmailPreview.ts
│   ├── useMatchaAI.ts
│   ├── useQualityChecks.ts
│   └── useTemplateAnalytics.ts
├── stores/
│   ├── editorStore.ts                  # Zustand store for editor state
│   ├── templateStore.ts                # Template management
│   ├── brandStore.ts                   # Brand kit settings
│   └── analyticsStore.ts               # Analytics data
├── lib/
│   ├── mjml/
│   │   ├── compiler.ts                 # MJML to HTML compilation
│   │   ├── blocks.ts                   # Block to MJML conversion
│   │   └── templates.ts                # Base MJML templates
│   ├── merge-fields/
│   │   ├── parser.ts                   # Merge field parsing
│   │   ├── salesforce-fields.ts        # Salesforce field mappings
│   │   └── preview.ts                  # Preview data injection
│   ├── matcha-ai/
│   │   ├── client.ts                   # MatchaAI API client
│   │   ├── chasen-prompts.ts           # System prompts
│   │   └── streaming.ts                # Response streaming
│   ├── email/
│   │   ├── quality-checks.ts           # Quality validation
│   │   ├── spam-check.ts               # Spam score calculation
│   │   └── send-test.ts                # Test email sending
│   └── analytics/
│       ├── tracking.ts                 # Event tracking
│       └── aggregation.ts              # Metrics aggregation
├── types/
│   ├── email.ts
│   ├── blocks.ts
│   ├── templates.ts
│   ├── brand.ts
│   └── analytics.ts
└── pages/
    └── guides-resources/
        └── email-templates/
            ├── index.tsx               # Template library
            ├── new.tsx                 # New template
            ├── [id]/
            │   ├── edit.tsx            # Edit template
            │   └── preview.tsx         # Preview mode
            ├── brand-kit.tsx           # Brand settings
            └── analytics.tsx           # Performance dashboard
```

## 12.2 Environment Configuration
```env
# .env.local

# MatchaAI Configuration
MATCHA_AI_API_KEY=your_matcha_ai_api_key
MATCHA_AI_BASE_URL=https://api.matcha-ai.com
MATCHA_AI_MODEL=chasen-v1
MATCHA_AI_STREAMING_ENABLED=true
MATCHA_AI_MAX_TOKENS=4000
MATCHA_AI_TEMPERATURE=0.7

# Email Testing (Optional integrations)
LITMUS_API_KEY=your_litmus_api_key
EMAIL_ON_ACID_API_KEY=your_eoa_api_key

# Storage
AZURE_STORAGE_CONNECTION_STRING=your_azure_connection
AZURE_STORAGE_CONTAINER=email-assets

# Salesforce Integration
SALESFORCE_CLIENT_ID=your_sf_client_id
SALESFORCE_CLIENT_SECRET=your_sf_client_secret
SALESFORCE_INSTANCE_URL=https://your-instance.salesforce.com

# Analytics
ANALYTICS_ENDPOINT=https://api.your-analytics.com
```

## 12.3 Zustand Store Example
```typescript
// stores/editorStore.ts

import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';
import { devtools, persist } from 'zustand/middleware';
import { Block, EmailTemplate } from '@/types';

interface EditorState {
  // Template data
  template: EmailTemplate | null;
  blocks: Block[];
  selectedBlockId: string | null;
  
  // Editor state
  isDirty: boolean;
  isPreviewMode: boolean;
  previewDevice: 'desktop' | 'mobile' | 'dark';
  
  // History for undo/redo
  history: Block[][];
  historyIndex: number;
  
  // Actions
  setTemplate: (template: EmailTemplate) => void;
  addBlock: (block: Block, index?: number) => void;
  updateBlock: (id: string, updates: Partial<Block>) => void;
  removeBlock: (id: string) => void;
  reorderBlocks: (startIndex: number, endIndex: number) => void;
  selectBlock: (id: string | null) => void;
  duplicateBlock: (id: string) => void;
  
  // Preview
  setPreviewMode: (enabled: boolean) => void;
  setPreviewDevice: (device: 'desktop' | 'mobile' | 'dark') => void;
  
  // History
  undo: () => void;
  redo: () => void;
  canUndo: () => boolean;
  canRedo: () => boolean;
  
  // Save
  markClean: () => void;
  markDirty: () => void;
}

export const useEditorStore = create<EditorState>()(
  devtools(
    persist(
      immer((set, get) => ({
        // Initial state
        template: null,
        blocks: [],
        selectedBlockId: null,
        isDirty: false,
        isPreviewMode: false,
        previewDevice: 'desktop',
        history: [[]],
        historyIndex: 0,
        
        // Template actions
        setTemplate: (template) => set((state) => {
          state.template = template;
          state.blocks = template.blocks || [];
          state.isDirty = false;
        }),
        
        // Block actions
        addBlock: (block, index) => set((state) => {
          const insertIndex = index ?? state.blocks.length;
          state.blocks.splice(insertIndex, 0, block);
          state.selectedBlockId = block.id;
          state.isDirty = true;
          // Save to history
          state.history = state.history.slice(0, state.historyIndex + 1);
          state.history.push([...state.blocks]);
          state.historyIndex = state.history.length - 1;
        }),
        
        updateBlock: (id, updates) => set((state) => {
          const index = state.blocks.findIndex(b => b.id === id);
          if (index !== -1) {
            state.blocks[index] = { ...state.blocks[index], ...updates };
            state.isDirty = true;
          }
        }),
        
        removeBlock: (id) => set((state) => {
          state.blocks = state.blocks.filter(b => b.id !== id);
          if (state.selectedBlockId === id) {
            state.selectedBlockId = null;
          }
          state.isDirty = true;
        }),
        
        reorderBlocks: (startIndex, endIndex) => set((state) => {
          const [removed] = state.blocks.splice(startIndex, 1);
          state.blocks.splice(endIndex, 0, removed);
          state.isDirty = true;
        }),
        
        selectBlock: (id) => set((state) => {
          state.selectedBlockId = id;
        }),
        
        duplicateBlock: (id) => set((state) => {
          const index = state.blocks.findIndex(b => b.id === id);
          if (index !== -1) {
            const original = state.blocks[index];
            const duplicate = {
              ...original,
              id: `${original.id}-copy-${Date.now()}`,
            };
            state.blocks.splice(index + 1, 0, duplicate);
            state.selectedBlockId = duplicate.id;
            state.isDirty = true;
          }
        }),
        
        // Preview actions
        setPreviewMode: (enabled) => set((state) => {
          state.isPreviewMode = enabled;
        }),
        
        setPreviewDevice: (device) => set((state) => {
          state.previewDevice = device;
        }),
        
        // History actions
        undo: () => set((state) => {
          if (state.historyIndex > 0) {
            state.historyIndex -= 1;
            state.blocks = [...state.history[state.historyIndex]];
          }
        }),
        
        redo: () => set((state) => {
          if (state.historyIndex < state.history.length - 1) {
            state.historyIndex += 1;
            state.blocks = [...state.history[state.historyIndex]];
          }
        }),
        
        canUndo: () => get().historyIndex > 0,
        canRedo: () => get().historyIndex < get().history.length - 1,
        
        // Save state
        markClean: () => set((state) => {
          state.isDirty = false;
        }),
        
        markDirty: () => set((state) => {
          state.isDirty = true;
        }),
      })),
      {
        name: 'email-editor-storage',
        partialize: (state) => ({
          // Only persist certain fields
          template: state.template,
          blocks: state.blocks,
        }),
      }
    ),
    { name: 'EmailEditorStore' }
  )
);
```

---

# 13. PRE-BUILT TEMPLATE LIBRARY

## 13.1 Starter Templates

| Category       | Template Name            | Use Case             | Segment                 |
| -------------- | ------------------------ | -------------------- | ----------------------- |
| **Onboarding** | Welcome Email            | New client kickoff   | All                     |
| **Onboarding** | Implementation Milestone | Phase completion     | All                     |
| **Onboarding** | Go-Live Celebration      | System launch        | All                     |
| **QBR**        | QBR Invitation           | Meeting request      | All                     |
| **QBR**        | QBR Executive Summary    | Post-meeting recap   | Giants, Sleeping Giants |
| **QBR**        | QBR Action Items         | Follow-up tasks      | All                     |
| **NPS**        | NPS Survey Request       | Survey invitation    | All                     |
| **NPS**        | Promoter Thank You       | Score 9-10 response  | All                     |
| **NPS**        | Passive Follow-up        | Score 7-8 response   | All                     |
| **NPS**        | Detractor Response       | Score 0-6 response   | All                     |
| **Risk**       | Risk Alert Internal      | Internal escalation  | All                     |
| **Risk**       | Risk Mitigation Plan     | Client communication | All                     |
| **Risk**       | Escalation Update        | Status update        | Giants                  |
| **Renewal**    | 90-Day Notice            | Early renewal touch  | All                     |
| **Renewal**    | 60-Day Check-in          | Mid-cycle touch      | All                     |
| **Renewal**    | Renewal Proposal         | Formal offer         | All                     |
| **Renewal**    | Thank You - Renewed      | Confirmation         | All                     |
| **Updates**    | Product Release          | Feature announcement | All                     |
| **Updates**    | Maintenance Notice       | Scheduled downtime   | All                     |
| **Updates**    | Security Advisory        | Security updates     | All                     |
| **Events**     | Event Invitation         | Webinar/forum invite | All                     |
| **Events**     | Event Reminder           | Pre-event nudge      | All                     |
| **Events**     | Event Follow-up          | Post-event thank you | All                     |
| **Events**     | APAC Client Forum        | Annual conference    | All                     |

---

# 14. CHASEN RESPONSE ENHANCEMENT PROTOCOL

## 14.1 Response Architecture

Every Chasen response within the Intelligence Hub must include these components where relevant:

### Executive Summary
```
{2-3 sentences with key insight or recommendation, including quantified impact}
```

### Analysis Section
```
- Present findings using clear hierarchies
- Support with data from connected systems (Salesforce, ServiceNow, Power BI)
- Include confidence levels for predictions/recommendations
```

### Action Items Format
```
🎯 [ACTION]: {Description}
   ├─ Owner: {Name/Role}
   ├─ Due: {Date}
   ├─ Priority: {Critical/High/Medium/Low}
   └─ Link: [Create Task in Salesforce](#salesforce-task-create)
```

## 14.2 Contextual Linking Framework

### Internal System Links
```
📊 [View in Power BI](#{system}-{record-type}-{id})
📁 [Related Document](#{sharepoint-path})
📅 [Schedule Follow-up](#{outlook-meeting-create}?attendees={stakeholders}&subject={topic})
```

### External Intelligence Sources

| Category            | Primary Sources                                              |
| ------------------- | ------------------------------------------------------------ |
| Market Intelligence | KLAS Research, Gartner, HIMSS Analytics                      |
| Benchmarking        | HFMA, Advisory Board, McKinsey Healthcare                    |
| Regional News       | Healthcare IT News APAC, Australian Digital Health Agency, MOH Singapore |
| Case Studies        | NEJM Catalyst, Harvard Business Review Healthcare            |
| Regulatory          | TGA (AU), HSA (SG), Medsafe (NZ)                             |

### External Link Format
```
🔗 **External Reference**: [Title](URL)
   Source: {Publication} | Published: {Date} | Relevance: {Why this matters}
```

## 14.3 Follow-Up Question Engine
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 **Explore Further**

Based on this analysis, you might want to:

1️⃣ [Dive deeper into {specific aspect}]
   → "Show me the trend analysis for {topic} over the past 12 months"

2️⃣ [Take action on {recommendation}]
   → "Draft a communication to {stakeholder} about {issue}"

3️⃣ [Compare with benchmarks]
   → "How does {metric} compare to APAC healthcare industry standards?"

4️⃣ [Prepare for upcoming engagement]
   → "Generate a briefing pack for my {client} meeting on {date}"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 14.4 Client Health Card (Auto-Inject)
```
┌─────────────────────────────────────────────┐
│ 🏥 {CLIENT NAME}                            │
├─────────────────────────────────────────────┤
│ Segment: {Segment}     │ NPS: {Score} ({Trend})│
│ ARR: ${Amount}         │ Risk: {Level}       │
│ CSE: {Name}            │ CAM: {Name}         │
├─────────────────────────────────────────────┤
│ 📌 Key Context: {Recent significant events} │
│ ⚠️ Open Issues: {Count} │ 🎯 Opportunities: {Count}│
└─────────────────────────────────────────────┘
```

## 14.5 Response Quality Standards

### Evidence Hierarchy
1. Direct client data (NPS, usage, support metrics)
2. Internal performance data (revenue, COGS, SLA)
3. Peer benchmarks (similar APAC healthcare clients)
4. Industry benchmarks (KLAS, Gartner)
5. General best practices (with source)

### Confidence Indicators
- 🟢 High confidence: Multiple data sources, recent data
- 🟡 Medium confidence: Single source or older data
- 🔴 Low confidence: Inference or limited data - recommend validation

### Actionability Scoring
Every recommendation tagged with:
- **Effort**: Low/Medium/High
- **Impact**: Low/Medium/High
- **Time to value**: Immediate/30 days/Quarter/Long-term

---

# APPENDIX A: KEYBOARD SHORTCUTS

| Shortcut               | Action                |
| ---------------------- | --------------------- |
| `Cmd/Ctrl + S`         | Save template         |
| `Cmd/Ctrl + Z`         | Undo                  |
| `Cmd/Ctrl + Shift + Z` | Redo                  |
| `Cmd/Ctrl + D`         | Duplicate block       |
| `Cmd/Ctrl + P`         | Toggle preview        |
| `Cmd/Ctrl + /`         | Open Chasen AI        |
| `Delete/Backspace`     | Delete selected block |
| `↑ / ↓`                | Navigate blocks       |
| `Escape`               | Deselect block        |

---

# APPENDIX B: ACCESSIBILITY REQUIREMENTS

- WCAG 2.1 AA compliance
- Keyboard navigation support for all interactions
- Screen reader compatibility (ARIA labels)
- High contrast mode support
- Focus indicators on all interactive elements
- Minimum touch target size of 44x44px

---

# APPENDIX C: BROWSER SUPPORT

| Browser | Minimum Version |
| ------- | --------------- |
| Chrome  | 90+             |
| Firefox | 88+             |
| Safari  | 14+             |
| Edge    | 90+             |

---

**Document Version**: 2.0  
**Last Updated**: December 2025  
**Owner**: APAC Client Success  
**Status**: Ready for Implementation