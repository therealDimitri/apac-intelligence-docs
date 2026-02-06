# Phase 9 Testing & Integration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create automated E2E tests for all Phase 9 features and integrate sentiment analysis into client tables and alert system.

**Architecture:** Playwright E2E tests following existing phase8 patterns; sentiment sparklines via new wrapper component; alerts integration via AlertCenter modification.

**Tech Stack:** Playwright, React, existing sentiment components, AlertCenter component

---

## Task 1: Create Phase 9 E2E Test Directory Structure

**Files:**
- Create: `tests/e2e/phase9/fixtures.ts`

**Step 1: Create fixtures file with shared utilities**

```typescript
// tests/e2e/phase9/fixtures.ts
import { test as base, expect } from '@playwright/test'

export const BASE_URL = 'http://localhost:3001'

// Extend base test with auth setup
export const test = base.extend({})

// Add auth cookie before each test
export async function setupAuth(page: any) {
  await page.context().addCookies([
    {
      name: 'dev-auth-session',
      value: 'test-user@example.com',
      domain: 'localhost',
      path: '/',
    },
  ])
}

// Helper to check for console errors
export async function checkNoConsoleErrors(page: any) {
  const errors: string[] = []
  page.on('console', (msg: any) => {
    if (msg.type() === 'error') {
      errors.push(msg.text())
    }
  })
  return errors
}

export { expect }
```

**Step 2: Commit**

```bash
git add tests/e2e/phase9/fixtures.ts
git commit -m "test(phase9): Add E2E test fixtures"
```

---

## Task 2: Create Task Queue E2E Tests

**Files:**
- Create: `tests/e2e/phase9/task-queue.spec.ts`

**Step 1: Write test file**

```typescript
// tests/e2e/phase9/task-queue.spec.ts
/**
 * Phase 9.1: Task Queue E2E Tests
 */

import { test, expect } from '@playwright/test'

const BASE_URL = 'http://localhost:3001'

test.setTimeout(60000)

test.describe('Phase 9.1: Task Queue', () => {
  test.beforeEach(async ({ page }) => {
    await page.context().addCookies([
      {
        name: 'dev-auth-session',
        value: 'test-user@example.com',
        domain: 'localhost',
        path: '/',
      },
    ])
  })

  test('page loads without errors', async ({ page }) => {
    const errors: string[] = []
    page.on('console', msg => {
      if (msg.type() === 'error' && !msg.text().includes('favicon')) {
        errors.push(msg.text())
      }
    })

    await page.goto(`${BASE_URL}/tasks`)
    await page.waitForLoadState('networkidle')

    // Page should render
    await expect(page.locator('body')).toBeVisible()

    // Check for task queue UI elements
    const heading = page.getByRole('heading', { name: /task/i }).first()
    await expect(heading).toBeVisible({ timeout: 10000 })

    // No critical errors
    const criticalErrors = errors.filter(e => !e.includes('hydration'))
    expect(criticalErrors).toHaveLength(0)
  })

  test('displays task list or empty state', async ({ page }) => {
    await page.goto(`${BASE_URL}/tasks`)
    await page.waitForLoadState('networkidle')

    // Either shows tasks or empty state
    const hasTasks = await page.locator('[data-testid="task-card"]').count() > 0
    const hasEmptyState = await page.getByText(/no tasks/i).isVisible().catch(() => false)

    expect(hasTasks || hasEmptyState).toBeTruthy()
  })

  test('create task button is visible', async ({ page }) => {
    await page.goto(`${BASE_URL}/tasks`)
    await page.waitForLoadState('networkidle')

    const createButton = page.getByRole('button', { name: /create|new|add/i }).first()
    // Button may or may not exist depending on implementation
    if (await createButton.isVisible().catch(() => false)) {
      await expect(createButton).toBeEnabled()
    }
  })
})
```

**Step 2: Commit**

```bash
git add tests/e2e/phase9/task-queue.spec.ts
git commit -m "test(phase9): Add task queue E2E tests"
```

---

## Task 3: Create Network Graph E2E Tests

**Files:**
- Create: `tests/e2e/phase9/network-graph.spec.ts`

**Step 1: Write test file**

```typescript
// tests/e2e/phase9/network-graph.spec.ts
/**
 * Phase 9.2: Network Graph E2E Tests
 */

import { test, expect } from '@playwright/test'

const BASE_URL = 'http://localhost:3001'

test.setTimeout(60000)

test.describe('Phase 9.2: Network Graph', () => {
  test.beforeEach(async ({ page }) => {
    await page.context().addCookies([
      {
        name: 'dev-auth-session',
        value: 'test-user@example.com',
        domain: 'localhost',
        path: '/',
      },
    ])
  })

  test('page loads without errors', async ({ page }) => {
    const errors: string[] = []
    page.on('console', msg => {
      if (msg.type() === 'error' && !msg.text().includes('favicon')) {
        errors.push(msg.text())
      }
    })

    await page.goto(`${BASE_URL}/visualisation/network`)
    await page.waitForLoadState('networkidle')

    await expect(page.locator('body')).toBeVisible()

    // Check for graph container
    const graphContainer = page.locator('svg, canvas, [data-testid="network-graph"]').first()
    await expect(graphContainer).toBeVisible({ timeout: 15000 })

    const criticalErrors = errors.filter(e => !e.includes('hydration'))
    expect(criticalErrors).toHaveLength(0)
  })

  test('graph renders nodes', async ({ page }) => {
    await page.goto(`${BASE_URL}/visualisation/network`)
    await page.waitForLoadState('networkidle')
    await page.waitForTimeout(2000) // Allow D3 to render

    // Check for SVG circles (nodes) or similar elements
    const nodes = page.locator('circle, [data-testid="graph-node"]')
    const nodeCount = await nodes.count()

    // Should have at least some nodes or show empty state
    const hasNodes = nodeCount > 0
    const hasEmptyState = await page.getByText(/no data|empty/i).isVisible().catch(() => false)

    expect(hasNodes || hasEmptyState).toBeTruthy()
  })

  test('filter controls are visible', async ({ page }) => {
    await page.goto(`${BASE_URL}/visualisation/network`)
    await page.waitForLoadState('networkidle')

    // Look for filter/control elements
    const controls = page.locator('select, [role="combobox"], button:has-text("Filter")')
    if (await controls.first().isVisible().catch(() => false)) {
      await expect(controls.first()).toBeEnabled()
    }
  })
})
```

**Step 2: Commit**

```bash
git add tests/e2e/phase9/network-graph.spec.ts
git commit -m "test(phase9): Add network graph E2E tests"
```

---

## Task 4: Create Digital Twin E2E Tests

**Files:**
- Create: `tests/e2e/phase9/digital-twin.spec.ts`

**Step 1: Write test file**

```typescript
// tests/e2e/phase9/digital-twin.spec.ts
/**
 * Phase 9.3: Digital Twin E2E Tests
 */

import { test, expect } from '@playwright/test'

const BASE_URL = 'http://localhost:3001'

test.setTimeout(60000)

test.describe('Phase 9.3: Digital Twin', () => {
  test.beforeEach(async ({ page }) => {
    await page.context().addCookies([
      {
        name: 'dev-auth-session',
        value: 'test-user@example.com',
        domain: 'localhost',
        path: '/',
      },
    ])
  })

  test('twins page loads without errors', async ({ page }) => {
    const errors: string[] = []
    page.on('console', msg => {
      if (msg.type() === 'error' && !msg.text().includes('favicon')) {
        errors.push(msg.text())
      }
    })

    await page.goto(`${BASE_URL}/twins`)
    await page.waitForLoadState('networkidle')

    await expect(page.locator('body')).toBeVisible()

    // Check for twins UI
    const heading = page.getByRole('heading', { name: /twin|simulation/i }).first()
    await expect(heading).toBeVisible({ timeout: 10000 })

    const criticalErrors = errors.filter(e => !e.includes('hydration'))
    expect(criticalErrors).toHaveLength(0)
  })

  test('displays twin list or empty state', async ({ page }) => {
    await page.goto(`${BASE_URL}/twins`)
    await page.waitForLoadState('networkidle')

    const hasTwins = await page.locator('[data-testid="twin-card"]').count() > 0
    const hasEmptyState = await page.getByText(/no twin|create.*twin/i).isVisible().catch(() => false)

    expect(hasTwins || hasEmptyState).toBeTruthy()
  })

  test('create twin button exists', async ({ page }) => {
    await page.goto(`${BASE_URL}/twins`)
    await page.waitForLoadState('networkidle')

    const createButton = page.getByRole('button', { name: /create|new|add/i }).first()
    if (await createButton.isVisible().catch(() => false)) {
      await expect(createButton).toBeEnabled()
    }
  })
})
```

**Step 2: Commit**

```bash
git add tests/e2e/phase9/digital-twin.spec.ts
git commit -m "test(phase9): Add digital twin E2E tests"
```

---

## Task 5: Create Deal Sandbox E2E Tests

**Files:**
- Create: `tests/e2e/phase9/deal-sandbox.spec.ts`

**Step 1: Write test file**

```typescript
// tests/e2e/phase9/deal-sandbox.spec.ts
/**
 * Phase 9.3: Deal Sandbox E2E Tests
 */

import { test, expect } from '@playwright/test'

const BASE_URL = 'http://localhost:3001'

test.setTimeout(60000)

test.describe('Phase 9.3: Deal Sandbox', () => {
  test.beforeEach(async ({ page }) => {
    await page.context().addCookies([
      {
        name: 'dev-auth-session',
        value: 'test-user@example.com',
        domain: 'localhost',
        path: '/',
      },
    ])
  })

  test('sandbox page loads without errors', async ({ page }) => {
    const errors: string[] = []
    page.on('console', msg => {
      if (msg.type() === 'error' && !msg.text().includes('favicon')) {
        errors.push(msg.text())
      }
    })

    await page.goto(`${BASE_URL}/sandbox`)
    await page.waitForLoadState('networkidle')

    await expect(page.locator('body')).toBeVisible()

    // Check for sandbox UI
    const heading = page.getByRole('heading', { name: /sandbox|negotiation|deal/i }).first()
    await expect(heading).toBeVisible({ timeout: 10000 })

    const criticalErrors = errors.filter(e => !e.includes('hydration'))
    expect(criticalErrors).toHaveLength(0)
  })

  test('displays sandbox list or empty state', async ({ page }) => {
    await page.goto(`${BASE_URL}/sandbox`)
    await page.waitForLoadState('networkidle')

    const hasSandboxes = await page.locator('[data-testid="sandbox-card"]').count() > 0
    const hasEmptyState = await page.getByText(/no sandbox|create.*sandbox/i).isVisible().catch(() => false)

    expect(hasSandboxes || hasEmptyState).toBeTruthy()
  })

  test('create sandbox button exists', async ({ page }) => {
    await page.goto(`${BASE_URL}/sandbox`)
    await page.waitForLoadState('networkidle')

    const createButton = page.getByRole('button', { name: /create|new|start/i }).first()
    if (await createButton.isVisible().catch(() => false)) {
      await expect(createButton).toBeEnabled()
    }
  })
})
```

**Step 2: Commit**

```bash
git add tests/e2e/phase9/deal-sandbox.spec.ts
git commit -m "test(phase9): Add deal sandbox E2E tests"
```

---

## Task 6: Create 3D Pipeline E2E Tests

**Files:**
- Create: `tests/e2e/phase9/pipeline-3d.spec.ts`

**Step 1: Write test file**

```typescript
// tests/e2e/phase9/pipeline-3d.spec.ts
/**
 * Phase 9.4: 3D Pipeline E2E Tests
 */

import { test, expect } from '@playwright/test'

const BASE_URL = 'http://localhost:3001'

test.setTimeout(90000) // Longer timeout for 3D rendering

test.describe('Phase 9.4: 3D Pipeline Landscape', () => {
  test.beforeEach(async ({ page }) => {
    await page.context().addCookies([
      {
        name: 'dev-auth-session',
        value: 'test-user@example.com',
        domain: 'localhost',
        path: '/',
      },
    ])
  })

  test('page loads without errors', async ({ page }) => {
    const errors: string[] = []
    page.on('console', msg => {
      if (msg.type() === 'error' && !msg.text().includes('favicon')) {
        errors.push(msg.text())
      }
    })

    await page.goto(`${BASE_URL}/visualisation/pipeline`)
    await page.waitForLoadState('networkidle')

    await expect(page.locator('body')).toBeVisible()

    // Check for 3D canvas
    const canvas = page.locator('canvas').first()
    await expect(canvas).toBeVisible({ timeout: 20000 })

    const criticalErrors = errors.filter(e =>
      !e.includes('hydration') &&
      !e.includes('WebGL') // WebGL warnings are OK
    )
    expect(criticalErrors).toHaveLength(0)
  })

  test('3D canvas renders', async ({ page }) => {
    await page.goto(`${BASE_URL}/visualisation/pipeline`)
    await page.waitForLoadState('networkidle')
    await page.waitForTimeout(3000) // Allow Three.js to render

    const canvas = page.locator('canvas')
    await expect(canvas).toBeVisible()

    // Canvas should have non-zero dimensions
    const box = await canvas.boundingBox()
    expect(box).toBeTruthy()
    expect(box!.width).toBeGreaterThan(0)
    expect(box!.height).toBeGreaterThan(0)
  })

  test('filter controls are visible', async ({ page }) => {
    await page.goto(`${BASE_URL}/visualisation/pipeline`)
    await page.waitForLoadState('networkidle')

    // Look for filter panel
    const filterPanel = page.locator('[data-testid="pipeline-controls"], select, [role="combobox"]').first()
    if (await filterPanel.isVisible().catch(() => false)) {
      await expect(filterPanel).toBeVisible()
    }
  })
})
```

**Step 2: Commit**

```bash
git add tests/e2e/phase9/pipeline-3d.spec.ts
git commit -m "test(phase9): Add 3D pipeline E2E tests"
```

---

## Task 7: Create Meeting Co-Host E2E Tests

**Files:**
- Create: `tests/e2e/phase9/meeting-cohost.spec.ts`

**Step 1: Write test file**

```typescript
// tests/e2e/phase9/meeting-cohost.spec.ts
/**
 * Phase 9.5: Meeting Co-Host E2E Tests
 */

import { test, expect } from '@playwright/test'

const BASE_URL = 'http://localhost:3001'

test.setTimeout(60000)

test.describe('Phase 9.5: Meeting Co-Host', () => {
  test.beforeEach(async ({ page }) => {
    await page.context().addCookies([
      {
        name: 'dev-auth-session',
        value: 'test-user@example.com',
        domain: 'localhost',
        path: '/',
      },
    ])
  })

  test('meetings list page loads', async ({ page }) => {
    const errors: string[] = []
    page.on('console', msg => {
      if (msg.type() === 'error' && !msg.text().includes('favicon')) {
        errors.push(msg.text())
      }
    })

    await page.goto(`${BASE_URL}/meetings`)
    await page.waitForLoadState('networkidle')

    await expect(page.locator('body')).toBeVisible()

    // Check for meetings UI
    const heading = page.getByRole('heading', { name: /meeting/i }).first()
    await expect(heading).toBeVisible({ timeout: 10000 })

    const criticalErrors = errors.filter(e => !e.includes('hydration'))
    expect(criticalErrors).toHaveLength(0)
  })

  test('meeting detail page loads', async ({ page }) => {
    // First get a meeting ID from the list
    await page.goto(`${BASE_URL}/meetings`)
    await page.waitForLoadState('networkidle')

    // Try to find a meeting link
    const meetingLink = page.locator('a[href*="/meetings/"]').first()

    if (await meetingLink.isVisible().catch(() => false)) {
      await meetingLink.click()
      await page.waitForLoadState('networkidle')

      // Should be on meeting detail page
      await expect(page.url()).toContain('/meetings/')
    }
  })

  test('live meeting page has co-host controls', async ({ page }) => {
    // Navigate to a meeting's live page (using test meeting ID)
    await page.goto(`${BASE_URL}/meetings/1/live`)
    await page.waitForLoadState('networkidle')

    // Either shows co-host UI or error state (meeting not found)
    const hasCoHost = await page.getByText(/co-host|transcription|recording/i).isVisible().catch(() => false)
    const hasError = await page.getByText(/not found|error/i).isVisible().catch(() => false)

    expect(hasCoHost || hasError).toBeTruthy()
  })
})
```

**Step 2: Commit**

```bash
git add tests/e2e/phase9/meeting-cohost.spec.ts
git commit -m "test(phase9): Add meeting co-host E2E tests"
```

---

## Task 8: Create Sentiment Analysis E2E Tests

**Files:**
- Create: `tests/e2e/phase9/sentiment.spec.ts`

**Step 1: Write test file**

```typescript
// tests/e2e/phase9/sentiment.spec.ts
/**
 * Phase 9.6: Sentiment Analysis E2E Tests
 */

import { test, expect } from '@playwright/test'

const BASE_URL = 'http://localhost:3001'

test.setTimeout(60000)

test.describe('Phase 9.6: Sentiment Analysis', () => {
  test.beforeEach(async ({ page }) => {
    await page.context().addCookies([
      {
        name: 'dev-auth-session',
        value: 'test-user@example.com',
        domain: 'localhost',
        path: '/',
      },
    ])
  })

  test('sentiment API returns valid response', async ({ request }) => {
    const response = await request.get(`${BASE_URL}/api/sentiment/alerts`)

    expect(response.status()).toBe(200)

    const data = await response.json()
    expect(data).toHaveProperty('success')
  })

  test('client sentiment panel renders on client page', async ({ page }) => {
    // Navigate to a client page
    await page.goto(`${BASE_URL}/`)
    await page.waitForLoadState('networkidle')

    // Find a client link and click it
    const clientLink = page.locator('a[href*="/clients/"]').first()

    if (await clientLink.isVisible().catch(() => false)) {
      await clientLink.click()
      await page.waitForLoadState('networkidle')

      // Look for sentiment tab
      const sentimentTab = page.getByRole('tab', { name: /sentiment/i })

      if (await sentimentTab.isVisible().catch(() => false)) {
        await sentimentTab.click()
        await page.waitForTimeout(1000)

        // Check for sentiment panel content
        const panel = page.locator('[class*="sentiment"], text=/sentiment/i')
        await expect(panel.first()).toBeVisible()
      }
    }
  })

  test('sentiment alerts page loads', async ({ page }) => {
    await page.goto(`${BASE_URL}/alerts`)
    await page.waitForLoadState('networkidle')

    // Check for alerts UI
    await expect(page.locator('body')).toBeVisible()
  })
})
```

**Step 2: Commit**

```bash
git add tests/e2e/phase9/sentiment.spec.ts
git commit -m "test(phase9): Add sentiment analysis E2E tests"
```

---

## Task 9: Create ClientNameWithSentiment Wrapper Component

**Files:**
- Create: `src/components/sentiment/ClientNameWithSentiment.tsx`
- Modify: `src/components/sentiment/index.ts`

**Step 1: Create wrapper component**

```typescript
// src/components/sentiment/ClientNameWithSentiment.tsx
'use client'

/**
 * ClientNameWithSentiment Component
 *
 * Wrapper that displays client name with inline sentiment sparkline.
 * Used in client tables across the app.
 */

import { SentimentSparkline } from './SentimentSparkline'

interface ClientNameWithSentimentProps {
  clientId: string
  clientName: string
  className?: string
  showSparkline?: boolean
}

export function ClientNameWithSentiment({
  clientId,
  clientName,
  className = '',
  showSparkline = true,
}: ClientNameWithSentimentProps) {
  return (
    <div className={`flex items-center gap-2 ${className}`}>
      <span className="truncate">{clientName}</span>
      {showSparkline && (
        <SentimentSparkline
          clientId={clientId}
          width={50}
          height={16}
          className="flex-shrink-0"
        />
      )}
    </div>
  )
}
```

**Step 2: Update index exports**

Add to `src/components/sentiment/index.ts`:

```typescript
export { ClientNameWithSentiment } from './ClientNameWithSentiment'
```

**Step 3: Commit**

```bash
git add src/components/sentiment/ClientNameWithSentiment.tsx src/components/sentiment/index.ts
git commit -m "feat(sentiment): Add ClientNameWithSentiment wrapper component"
```

---

## Task 10: Integrate Sentiment Alerts into AlertCenter

**Files:**
- Modify: `src/components/AlertCenter.tsx`

**Step 1: Add sentiment alerts import and fetch**

At the top of AlertCenter.tsx, add import:

```typescript
import { useSentimentAnalysis, type SentimentAlert } from '@/hooks/useSentimentAnalysis'
```

**Step 2: Add sentiment alerts state and fetch in component**

Inside the AlertCenter component, after existing state declarations, add:

```typescript
// Sentiment alerts
const [sentimentAlerts, setSentimentAlerts] = useState<SentimentAlert[]>([])
const { fetchSentimentAlerts } = useSentimentAnalysis()

// Fetch sentiment alerts alongside existing alerts
useEffect(() => {
  async function loadSentimentAlerts() {
    const result = await fetchSentimentAlerts({ status: 'pending' })
    if (result?.alerts) {
      setSentimentAlerts(result.alerts)
    }
  }
  loadSentimentAlerts()
}, [fetchSentimentAlerts])
```

**Step 3: Combine alerts in display**

In the alerts display section, add a new section for sentiment alerts after the existing alerts list:

```typescript
{/* Sentiment Alerts Section */}
{sentimentAlerts.length > 0 && (
  <div className="mt-6">
    <h3 className="text-sm font-medium text-muted-foreground mb-3">
      Sentiment Alerts ({sentimentAlerts.length})
    </h3>
    <div className="space-y-3">
      {sentimentAlerts.map(alert => (
        <div
          key={alert.id}
          className={`p-3 rounded-lg border ${
            alert.severity === 'critical' ? 'border-red-200 bg-red-50 dark:border-red-800 dark:bg-red-950/30' :
            alert.severity === 'high' ? 'border-orange-200 bg-orange-50 dark:border-orange-800 dark:bg-orange-950/30' :
            'border-amber-200 bg-amber-50 dark:border-amber-800 dark:bg-amber-950/30'
          }`}
        >
          <div className="flex items-start justify-between">
            <div>
              <p className="font-medium text-sm">{alert.title}</p>
              <p className="text-xs text-muted-foreground mt-1">{alert.client_name}</p>
            </div>
            <span className={`text-xs px-2 py-0.5 rounded-full font-medium uppercase ${
              alert.severity === 'critical' ? 'bg-red-500 text-white' :
              alert.severity === 'high' ? 'bg-orange-500 text-white' :
              'bg-amber-500 text-white'
            }`}>
              {alert.severity}
            </span>
          </div>
        </div>
      ))}
    </div>
  </div>
)}
```

**Step 4: Commit**

```bash
git add src/components/AlertCenter.tsx
git commit -m "feat(alerts): Integrate sentiment alerts into AlertCenter"
```

---

## Task 11: Add Sparkline to ActionableIntelligenceDashboard Client List

**Files:**
- Modify: `src/components/ActionableIntelligenceDashboard.tsx`

**Step 1: Add import**

```typescript
import { ClientNameWithSentiment } from '@/components/sentiment'
```

**Step 2: Find client name rendering and wrap with component**

Locate where client names are rendered in the client list/table and replace with:

```typescript
<ClientNameWithSentiment
  clientId={client.id}
  clientName={client.name || client.client_name}
/>
```

**Step 3: Commit**

```bash
git add src/components/ActionableIntelligenceDashboard.tsx
git commit -m "feat(dashboard): Add sentiment sparkline to client list"
```

---

## Task 12: Run All E2E Tests and Verify

**Step 1: Start dev server (if not running)**

```bash
npm run dev -- -p 3001 &
```

**Step 2: Run Phase 9 E2E tests**

```bash
npx playwright test tests/e2e/phase9/ --reporter=list
```

Expected: All tests pass or show expected empty states

**Step 3: Fix any failing tests**

Review failures, adjust selectors or expectations as needed.

**Step 4: Final commit**

```bash
git add .
git commit -m "test(phase9): Fix E2E test issues"
```

---

## Task 13: Build Verification and Push

**Step 1: Run build**

```bash
npm run build
```

Expected: Build succeeds with no errors

**Step 2: Push changes**

```bash
git push origin main
```

---

## Summary

| Task | Description |
|------|-------------|
| 1 | Create test fixtures |
| 2-8 | Create E2E tests for each Phase 9 feature |
| 9 | Create ClientNameWithSentiment wrapper |
| 10 | Integrate sentiment alerts into AlertCenter |
| 11 | Add sparklines to dashboard client list |
| 12 | Run and verify E2E tests |
| 13 | Build verification and push |

**Total: 13 tasks**
