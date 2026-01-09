# Bug Report: Missing Imports and OneDrive Sync Conflicts

**Date:** 2026-01-09
**Severity:** High (Causes build failures and page crashes)
**Status:** Resolved

## Summary
Multiple module import errors occurred due to OneDrive sync conflicts renaming source files with conflict suffixes. This blocked the entire dashboard from rendering and prevented access to all planning pages and AI enhancements.

## Error Messages
```
Module not found: Can't resolve '@/components/CommandPalette'
./src/components/layout/sidebar.tsx:29:1

Module not found: Can't resolve '@/hooks/useTokenHealth'
./src/components/TokenWarningBanner.tsx:19:1
```

## Root Causes

### 1. OneDrive Sync Conflicts
OneDrive sync renamed source files with machine-identifier suffixes when detecting conflicts:
- `useTokenHealth.tsx` → `useTokenHealth-HH622HW6H9-dimitri.leimonitis.tsx`
- `CommandPalette.tsx` → `CommandPalette-HH622HW6H9-dimitri.leimonitis.tsx`
- `session-manager.ts` → `session-manager-HH622HW6H9-dimitri.leimonitis.ts`

This broke imports as the modules could not be resolved at the original paths.

### 2. Incorrect Import Path
The sidebar was importing CommandPalette from the wrong location:
```typescript
// Wrong path
import { CommandPalette } from '@/components/CommandPalette'

// Correct path
import CommandPalette from '@/components/chasen/CommandPalette'
```

### 3. Prop Interface Mismatch
CommandPalette component had rigid props that didn't work with simpler usage from sidebar:
```typescript
// Sidebar expected
<CommandPalette open={showCommandPalette} onOpenChange={setShowCommandPalette} />

// CommandPalette required
<CommandPalette isOpen={...} onClose={...} onRunWorkflow={...} onRunCrew={...} onSendMessage={...} />
```

## Resolution

### 1. Renamed OneDrive Conflict Files
```bash
mv "useTokenHealth-HH622HW6H9-dimitri.leimonitis.tsx" "useTokenHealth.tsx"
mv "session-manager-HH622HW6H9-dimitri.leimonitis.ts" "session-manager.ts"
```

### 2. Fixed Import Path in sidebar.tsx
```typescript
// Line 29: Changed from
import { CommandPalette } from '@/components/CommandPalette'
// To
import CommandPalette from '@/components/chasen/CommandPalette'
```

### 3. Updated CommandPalette Props Interface
Made props optional to support both detailed and simple usage:
```typescript
interface CommandPaletteProps {
  isOpen?: boolean
  open?: boolean // Alternative prop name for simpler usage
  onClose?: () => void
  onOpenChange?: (open: boolean) => void // Alternative prop
  onRunWorkflow?: (workflowType: WorkflowType) => void
  onRunCrew?: (crewType: CrewType) => void
  onSendMessage?: (message: string) => void
  onNavigate?: (path: string) => void
  selectedClient?: string
  recentChats?: Array<{ id: string; title: string }>
}
```

Added internal handling to support both prop naming conventions:
```typescript
const dialogOpen = isOpen ?? open ?? false
const handleClose = useCallback(() => {
  onClose?.()
  onOpenChange?.(false)
}, [onClose, onOpenChange])
```

### 4. Cleaned Up Duplicate Conflict Files
Removed OneDrive conflict duplicates from source directories:
- `src/app/api/analytics/meetings/route-HH622HW6H9-dimitri.leimonitis.ts`
- `src/components/layout/MobileDrawer-HH622HW6H9-dimitri.leimonitis.tsx`
- `src/components/meeting-analytics/MeetingVelocityChart-HH622HW6H9-dimitri.leimonitis.tsx`

## Files Modified
- `src/components/layout/sidebar.tsx` - Fixed import path
- `src/components/chasen/CommandPalette.tsx` - Made props flexible
- `src/hooks/useTokenHealth.tsx` - Renamed from conflict suffix
- `src/lib/session-manager.ts` - Renamed from conflict suffix

## Verification
- Build: Successful (`npm run build` passes with 137 static pages)
- Dev server: Running without compilation errors at http://localhost:3001
- Planning pages accessible (307 redirect to auth as expected)

## Prevention

### OneDrive Sync Best Practices
1. **Pause OneDrive sync** before intensive development sessions
2. **Check for conflict files** with: `find . -name "*-HH622HW6H9-*" -type f`
3. **Use git status** to detect unexpected file renames
4. **Clear `.next` cache** after fixing OneDrive issues

### Import Best Practices
1. **Verify import paths** exist before committing
2. **Use flexible prop interfaces** that accept alternative prop names
3. **Run `npm run build`** to catch import errors early
4. **Optional chaining** for callback props: `onCallback?.()`

## Related Issues
- BUG-REPORT-20260109-formatCurrency-undefined-values.md
- BUG-REPORT-20260109-supabase-ssr-module-not-found.md
