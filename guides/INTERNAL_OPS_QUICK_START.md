# Internal Operations Integration - Quick Start Guide

## **TL;DR**

This 6-week strategic overhaul adds:

- **Department tracking** for all 10 teams
- **Activity type classification** (client-facing vs internal ops)
- **Client impact linkage** (which internal work helps which clients)
- **Cross-functional initiative tracking**

---

## **Quick Commands**

### **Run Phase 1 Migration**

```bash
# Execute migration in Supabase
psql "$DATABASE_URL" -f docs/migrations/20251205_internal_operations_phase1.sql
```

### **Verify Migration**

```bash
node scripts/verify-internal-ops-migration.mjs
```

---

## **Key Concepts**

### **1. Departments (10 teams)**

```
CLIENT-FACING          PRODUCT & DELIVERY       BUSINESS FUNCTIONS
├─ Client Success      ├─ R&D                   ├─ Marketing
├─ Client Support      ├─ Program Delivery      ├─ Sales & Solutions
└─ Professional Svcs   └─ Technical Services    ├─ Business Ops
                                                 └─ Commercial Ops
```

### **2. Activity Types**

**Client-Facing** (shows on client profiles):

- Implementation, Training, Support, Optimization, Strategic Review, Health Check

**Internal Ops** (organizational health):

- Planning, Process Improvement, Team Development, Reporting, Governance, Client Enablement, Research

### **3. Client Impact**

Internal work can be linked to clients it benefits:

```typescript
{
  action: "NPS Survey Process Improvement",
  department: "CLIENT_SUCCESS",
  activityType: "PROCESS_IMPROVEMENT",
  linkedClients: [123, 456, 789], // 12 clients
  impactArea: "NPS",
  impactDescription: "Streamlines Q4 survey distribution"
}
```

---

## **Database Schema Changes**

### **New Tables**

- `departments` - Reference table for org departments
- `activity_types` - Reference table for activity classification
- `client_impact_links` - Junction table linking internal work to clients
- `initiatives` - Cross-functional projects

### **New Columns**

**unified_meetings:**

- `department_code` - FK to departments
- `activity_type_code` - FK to activity_types
- `is_internal` - Boolean flag
- `cross_functional` - Boolean flag
- `linked_initiative_id` - FK to initiatives

**actions:**

- (same as meetings above)

### **New Views**

- `actions_enhanced` - Actions with department/activity details
- `meetings_enhanced` - Meetings with department/activity details

---

## **Migration Status**

### **✅ Completed**

- [x] Strategy document created
- [x] Migration SQL created
- [x] Reference data defined (10 departments, 13 activity types)

### **🔲 To Do - Phase 1 (Week 1-2)**

- [ ] Run migration in staging
- [ ] Verify data integrity
- [ ] Create TypeScript interfaces
- [ ] Update API endpoints
- [ ] Create migration verification script

### **🔲 To Do - Phase 2 (Week 3-4)**

- [ ] Build UI components (DepartmentSelector, ActivityTypeSelector, etc.)
- [ ] Update Action/Meeting creation forms
- [ ] Add department color palette
- [ ] Create activity type icons

### **🔲 To Do - Phase 3 (Week 5-6)**

- [ ] Enhance Command Centre dashboard
- [ ] Create Department Dashboard page
- [ ] Create Initiatives Dashboard page
- [ ] Add Client Impact visualization
- [ ] Update Client Profile pages

---

## **API Changes Needed**

### **Actions API**

```typescript
// New request body fields
{
  departmentCode: 'CLIENT_SUCCESS',
  activityTypeCode: 'SUPPORT',
  isInternal: false,
  linkedClients: [123, 456], // optional, for internal work
  impactArea: 'Support', // optional
  linkedInitiativeId: 42 // optional
}
```

### **Meetings API**

```typescript
// Same as actions above
```

---

## **UI Component Specs**

### **DepartmentSelector**

```tsx
<DepartmentSelector
  value={selectedDept}
  onChange={setSelectedDept}
  multiSelect={false}
  showIcon={true}
/>
```

### **ActivityTypeSelector**

```tsx
<ActivityTypeSelector
  value={selectedType}
  onChange={setSelectedType}
  filterByCategory="client_facing" // or "internal_ops" or "all"
  departmentContext="CLIENT_SUCCESS" // auto-suggest relevant types
/>
```

### **ImpactBadge**

```tsx
<ImpactBadge clientCount={12} impactArea="NPS" showDetails={true} onClick={handleViewDetails} />
```

---

## **Dashboard Mockups**

### **Command Centre - Enhanced**

```
┌─────────────────────────────────────────┐
│ 🏢 ORGANIZATIONAL ACTIVITY             │
├─────────────────────────────────────────┤
│                                          │
│ By Department:                           │
│ ├─ Client Success      ████████ 35%    │
│ ├─ R&D                 █████ 22%       │
│ ├─ Prof Services       ████ 18%        │
│ └─ Support             ███ 15%         │
│                                          │
│ Internal Work Impact:                    │
│ • 23 internal actions benefiting clients │
│ • 12 clients (NPS improvements)         │
│ •  8 clients (Dashboard enhancements)   │
└─────────────────────────────────────────┘
```

---

## **Success Metrics (Week 7)**

### **Data Quality**

- [ ] 90%+ actions have department assigned
- [ ] 85%+ actions have activity type assigned
- [ ] 50%+ internal work has client linkage

### **Adoption**

- [ ] All 10 departments actively using system
- [ ] 5+ cross-functional initiatives tracked
- [ ] 20+ client impact links per week

---

## **Troubleshooting**

### **Migration Fails**

```bash
# Check for conflicts
psql "$DATABASE_URL" -c "SELECT * FROM departments LIMIT 1;"

# Rollback if needed
psql "$DATABASE_URL" -f docs/migrations/20251205_internal_operations_phase1_rollback.sql
```

### **TypeScript Errors**

```bash
# Regenerate types
npx supabase gen types typescript --project-id usoyxsunetvxdjdglkmn > src/types/supabase.ts
```

---

## **Next Immediate Steps**

1. **Review** the full strategy: `docs/INTERNAL_OPERATIONS_STRATEGY.md`
2. **Execute** the migration: `docs/migrations/20251205_internal_operations_phase1.sql`
3. **Verify** success with verification queries
4. **Begin** Phase 1 implementation (TypeScript interfaces, API updates)

---

**Questions?** Check the full strategy document or ask in the team channel.
