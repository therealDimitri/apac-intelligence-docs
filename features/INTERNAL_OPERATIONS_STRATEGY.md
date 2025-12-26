# Internal Operations & Client Work Integration Strategy

## **Executive Summary**

This document outlines the strategic overhaul (6-week implementation) for integrating internal operations with client-facing work in the APAC Intelligence Dashboard.

**Goals:**

- Systematically track internal work across all departments
- Link internal initiatives to client outcomes
- Provide cross-functional visibility
- Measure organizational efficiency and client impact

---

## **Phase 1: Data Model Enhancement** (Week 1-2)

### **Database Schema Changes**

#### 1.1 Reference Tables (New)

```sql
-- Departments lookup table
CREATE TABLE departments (
  id SERIAL PRIMARY KEY,
  code VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  icon VARCHAR(50), -- Lucide icon name
  color VARCHAR(20), -- Tailwind color
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Activity types lookup table
CREATE TABLE activity_types (
  id SERIAL PRIMARY KEY,
  code VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  category VARCHAR(20) NOT NULL, -- 'client_facing' or 'internal_ops'
  shows_on_client_profile BOOLEAN DEFAULT false,
  color VARCHAR(20), -- Tailwind color
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Client impact tracking
CREATE TABLE client_impact_links (
  id SERIAL PRIMARY KEY,
  source_type VARCHAR(20) NOT NULL, -- 'action' or 'meeting'
  source_id INTEGER NOT NULL,
  client_id INTEGER NOT NULL REFERENCES clients(id),
  impact_area VARCHAR(50), -- 'NPS', 'Health', 'Adoption', 'Onboarding', 'Retention'
  impact_description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_impact_source ON client_impact_links(source_type, source_id);
CREATE INDEX idx_impact_client ON client_impact_links(client_id);
```

#### 1.2 Existing Table Updates

```sql
-- Add new columns to unified_meetings
ALTER TABLE unified_meetings
ADD COLUMN department_code VARCHAR(50) REFERENCES departments(code),
ADD COLUMN activity_type_code VARCHAR(50) REFERENCES activity_types(code),
ADD COLUMN is_internal BOOLEAN DEFAULT false,
ADD COLUMN cross_functional BOOLEAN DEFAULT false,
ADD COLUMN linked_initiative_id INTEGER;

-- Add new columns to actions
ALTER TABLE actions
ADD COLUMN department_code VARCHAR(50) REFERENCES departments(code),
ADD COLUMN activity_type_code VARCHAR(50) REFERENCES activity_types(code),
ADD COLUMN is_internal BOOLEAN DEFAULT false,
ADD COLUMN cross_functional BOOLEAN DEFAULT false,
ADD COLUMN linked_initiative_id INTEGER;

-- Create indexes for performance
CREATE INDEX idx_meetings_department ON unified_meetings(department_code);
CREATE INDEX idx_meetings_activity_type ON unified_meetings(activity_type_code);
CREATE INDEX idx_meetings_internal ON unified_meetings(is_internal);
CREATE INDEX idx_actions_department ON actions(department_code);
CREATE INDEX idx_actions_activity_type ON actions(activity_type_code);
CREATE INDEX idx_actions_internal ON actions(is_internal);
```

#### 1.3 Cross-Functional Initiatives Table

```sql
CREATE TABLE initiatives (
  id SERIAL PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  description TEXT,
  owner_department VARCHAR(50) REFERENCES departments(code),
  involved_departments TEXT[], -- Array of department codes
  status VARCHAR(20) DEFAULT 'active', -- 'planning', 'active', 'completed', 'cancelled'
  priority VARCHAR(20), -- 'critical', 'high', 'medium', 'low'
  start_date DATE,
  target_completion_date DATE,
  actual_completion_date DATE,
  impacts_clients BOOLEAN DEFAULT false,
  client_impact_description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### **Reference Data Population**

#### 1.4 Departments

```sql
INSERT INTO departments (code, name, description, icon, color) VALUES
-- Client-Facing Teams
('CLIENT_SUCCESS', 'Client Success', 'Client Success Engineering and account management', 'Users', 'purple'),
('CLIENT_SUPPORT', 'Client Support', 'Technical support and issue resolution', 'Headphones', 'blue'),
('PROFESSIONAL_SERVICES', 'Professional Services', 'Implementation and consulting', 'Briefcase', 'indigo'),

-- Product & Delivery
('RD', 'R&D', 'Research and Development, product engineering', 'Cpu', 'green'),
('PROGRAM_DELIVERY', 'Program Delivery', 'Program and project management', 'Target', 'teal'),
('TECHNICAL_SERVICES', 'Technical Services', 'Infrastructure and technical operations', 'Server', 'cyan'),

-- Business Functions
('MARKETING', 'Marketing', 'Marketing, communications, and demand generation', 'Megaphone', 'pink'),
('SALES_SOLUTIONS', 'Sales & Solutions', 'Sales, solutions architecture, and business development', 'TrendingUp', 'orange'),
('BUSINESS_OPS', 'Business Ops', 'Business operations and process management', 'BarChart3', 'gray'),
('COMMERCIAL_OPS', 'Commercial Ops', 'Commercial operations, contracts, and finance', 'DollarSign', 'yellow');
```

#### 1.5 Activity Types

```sql
INSERT INTO activity_types (code, name, description, category, shows_on_client_profile, color) VALUES
-- Client-Facing Activities
('IMPLEMENTATION', 'Implementation', 'System implementation and configuration', 'client_facing', true, 'blue'),
('TRAINING', 'Training', 'User training and education', 'client_facing', true, 'green'),
('SUPPORT', 'Support', 'Technical support and troubleshooting', 'client_facing', true, 'orange'),
('OPTIMIZATION', 'Optimization', 'System optimization and tuning', 'client_facing', true, 'purple'),
('STRATEGIC_REVIEW', 'Strategic Review', 'Business review and strategic planning', 'client_facing', true, 'indigo'),
('HEALTH_CHECK', 'Health Check', 'Account health assessment', 'client_facing', true, 'teal'),

-- Internal Operations
('PLANNING', 'Planning', 'Strategic and tactical planning', 'internal_ops', false, 'gray'),
('PROCESS_IMPROVEMENT', 'Process Improvement', 'Process optimization and efficiency', 'internal_ops', false, 'yellow'),
('TEAM_DEVELOPMENT', 'Team Development', 'Team training and skill development', 'internal_ops', false, 'pink'),
('REPORTING', 'Reporting', 'Reporting and analytics', 'internal_ops', false, 'cyan'),
('GOVERNANCE', 'Governance', 'Governance and compliance', 'internal_ops', false, 'red'),
('CLIENT_ENABLEMENT', 'Client Enablement', 'Internal work that enables better client service', 'internal_ops', true, 'purple'),
('RESEARCH', 'Research', 'Market research and analysis', 'internal_ops', false, 'blue');
```

### **Migration Strategy**

#### 1.6 Backward Compatibility

```sql
-- Create view for legacy Category field compatibility
CREATE VIEW actions_with_legacy_category AS
SELECT
  a.*,
  COALESCE(
    at.name,
    a.Category
  ) AS legacy_category,
  d.name AS department_name,
  at.name AS activity_type_name,
  at.category AS activity_category
FROM actions a
LEFT JOIN departments d ON a.department_code = d.code
LEFT JOIN activity_types at ON a.activity_type_code = at.code;

-- Similar view for meetings
CREATE VIEW meetings_with_legacy_fields AS
SELECT
  m.*,
  d.name AS department_name,
  at.name AS activity_type_name,
  at.category AS activity_category
FROM unified_meetings m
LEFT JOIN departments d ON m.department_code = d.code
LEFT JOIN activity_types at ON m.activity_type_code = at.code;
```

---

## **Phase 2: UI Components** (Week 3-4)

### **2.1 Core Components**

#### DepartmentSelector Component

```typescript
interface DepartmentSelectorProps {
  value: string | string[]
  onChange: (value: string | string[]) => void
  multiSelect?: boolean
  showIcon?: boolean
  includeInactive?: boolean
}
```

#### ActivityTypeSelector Component

```typescript
interface ActivityTypeSelectorProps {
  value: string
  onChange: (value: string) => void
  filterByCategory?: 'client_facing' | 'internal_ops' | 'all'
  departmentContext?: string // Auto-suggest relevant activity types
}
```

#### ClientImpactSelector Component

```typescript
interface ClientImpactSelectorProps {
  selectedClients: number[]
  onClientsChange: (clients: number[]) => void
  impactArea?: string
  impactDescription?: string
  onImpactAreaChange?: (area: string) => void
  onDescriptionChange?: (desc: string) => void
}
```

#### ImpactBadge Component

```typescript
interface ImpactBadgeProps {
  clientCount: number
  impactArea?: string
  showDetails?: boolean
  onClick?: () => void
}
```

### **2.2 Enhanced Form Components**

#### Action/Meeting Creation Forms

- Add Department dropdown (required for internal items)
- Add Activity Type dropdown (required)
- Add Client Impact section (conditional)
- Add Initiative linking (optional)

---

## **Phase 3: Dashboard Views** (Week 5-6)

### **3.1 Enhanced Command Centre**

**New Sections:**

- Department Performance Cards
- Cross-Functional Initiative Tracker
- Internal vs Client-Facing Work Ratio
- Client Impact Summary

### **3.2 Department Dashboard** (New Page)

**URL:** `/departments`

**Features:**

- Department workload overview
- Team member distribution
- Activity type breakdown
- Cross-functional collaboration metrics

### **3.3 Initiatives Dashboard** (New Page)

**URL:** `/initiatives`

**Features:**

- Active initiative list
- Department involvement matrix
- Client impact tracking
- Timeline and progress visualization

### **3.4 Client Profile Enhancements**

**New Section:** "Internal Work Benefiting This Client"

- Shows internal initiatives linked to this client
- Displays department involvement
- Timeline of internal work → client outcomes

---

## **Implementation Checklist**

### Week 1-2: Data Foundation

- [ ] Create migration script for new tables
- [ ] Populate reference data (departments, activity types)
- [ ] Add new columns to existing tables
- [ ] Create indexes for performance
- [ ] Create compatibility views
- [ ] Test data migration with sample data
- [ ] Update TypeScript interfaces
- [ ] Update API endpoints to support new fields

### Week 3-4: UI Components

- [ ] Build DepartmentSelector component
- [ ] Build ActivityTypeSelector component
- [ ] Build ClientImpactSelector component
- [ ] Build ImpactBadge component
- [ ] Update Action creation form
- [ ] Update Meeting creation form
- [ ] Create department color palette
- [ ] Create activity type icons mapping

### Week 5-6: Dashboard Views

- [ ] Enhance Command Centre with department filtering
- [ ] Add Department Performance Cards
- [ ] Create Department Dashboard page
- [ ] Create Initiatives Dashboard page
- [ ] Update Client Profile with internal work section
- [ ] Add cross-functional visibility features
- [ ] Create department/activity analytics
- [ ] Build client impact reporting

### Week 7: Testing & Refinement

- [ ] User acceptance testing
- [ ] Performance optimization
- [ ] Documentation updates
- [ ] Training materials
- [ ] Migration of existing data
- [ ] Go-live planning

---

## **Success Metrics**

### **Data Quality**

- 90%+ of actions have department assigned
- 85%+ of actions have activity type assigned
- 50%+ of internal work has client linkage

### **Usage**

- 100% department adoption (all teams using system)
- 5+ cross-functional initiatives tracked
- 20+ client impact links created per week

### **Insights**

- Department workload visibility
- Client impact quantification
- Process improvement opportunities identified

---

## **Risks & Mitigation**

| Risk                        | Impact | Mitigation                                           |
| --------------------------- | ------ | ---------------------------------------------------- |
| User adoption resistance    | High   | Training, change management, clear value proposition |
| Data migration complexity   | Medium | Phased approach, validation scripts, rollback plan   |
| Performance degradation     | Medium | Proper indexing, query optimization, caching         |
| Inconsistent categorization | High   | Dropdown selectors, validation rules, data audits    |

---

## **Next Steps**

1. **Immediate (This Week):**
   - Create database migration scripts
   - Set up reference tables
   - Update database schema documentation

2. **Week 1-2:**
   - Execute migrations in staging
   - Build TypeScript interfaces
   - Update API layer

3. **Week 3 onwards:**
   - Follow phased implementation plan above

---

**Document Version:** 1.0
**Last Updated:** 2025-12-05
**Owner:** Client Success Engineering
**Status:** Approved - Ready for Implementation
