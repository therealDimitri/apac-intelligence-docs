# BURC Renewal Calendar - Implementation Examples

**Created**: 5 January 2026
**Purpose**: Quick-start guide with copy-paste examples

---

## Quick Start

### Example 1: Full Page Implementation

Create a dedicated renewals page at `/app/burc/renewals/page.tsx`:

```tsx
'use client'

import { BURCRenewalCalendar } from '@/components/burc'

export default function RenewalsPage() {
  return (
    <div className="min-h-screen bg-grey-50">
      <div className="container mx-auto p-6 max-w-7xl">
        <BURCRenewalCalendar />
      </div>
    </div>
  )
}
```

### Example 2: Dashboard Widget

Add to your main dashboard at `/app/dashboard/page.tsx`:

```tsx
'use client'

import { RenewalUpcomingWidget } from '@/components/burc'
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 p-6">
      {/* Renewals Widget */}
      <div className="lg:col-span-1">
        <Suspense fallback={<RenewalUpcomingWidgetSkeleton />}>
          <RenewalUpcomingWidget limit={5} />
        </Suspense>
      </div>

      {/* Other widgets */}
      <div className="lg:col-span-2">
        {/* Your other dashboard content */}
      </div>
    </div>
  )
}
```

### Example 3: Custom Hook Usage

Create a custom component with filtered data:

```tsx
'use client'

import { useBURCRenewals } from '@/hooks/useBURCRenewals'
import { AlertCircle, Calendar } from 'lucide-react'

export function CriticalRenewalsAlert() {
  const { renewals, loading, stats } = useBURCRenewals({
    period: 30,
    riskLevel: 'red',
    sortBy: 'date',
  })

  if (loading) return <div>Loading...</div>
  if (stats.byRisk.red === 0) return null

  return (
    <div className="bg-red-50 border border-red-200 rounded-xl p-6">
      <div className="flex items-center gap-3 mb-4">
        <AlertCircle className="h-6 w-6 text-red-600" />
        <h3 className="text-lg font-bold text-red-900">
          {stats.byRisk.red} Critical Renewals in Next 30 Days
        </h3>
      </div>

      <div className="space-y-3">
        {renewals.map((renewal, idx) => (
          <div key={idx} className="bg-white rounded-lg p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="font-medium text-grey-900">{renewal.clients}</p>
                <p className="text-sm text-grey-600">{renewal.renewal_period}</p>
              </div>
              <div className="text-right">
                <p className="text-lg font-bold text-red-700">
                  {renewal.days_until_renewal} days
                </p>
                <p className="text-sm text-grey-600">
                  ${(renewal.total_value_usd / 1000).toFixed(0)}K
                </p>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
```

### Example 4: Email Notification Integration

Send automated alerts for upcoming renewals:

```tsx
'use client'

import { useBURCRenewals } from '@/hooks/useBURCRenewals'
import { useEffect } from 'react'

export function RenewalNotificationService() {
  const { renewals } = useBURCRenewals({
    period: 30,
    riskLevel: 'red',
  })

  useEffect(() => {
    // Check for critical renewals daily
    const criticalRenewals = renewals.filter(r => r.days_until_renewal! <= 14)

    if (criticalRenewals.length > 0) {
      // Send notification to CSE team
      fetch('/api/notifications/renewal-alert', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          type: 'critical_renewal',
          renewals: criticalRenewals,
          count: criticalRenewals.length,
        }),
      })
    }
  }, [renewals])

  return null // This is a background service component
}
```

### Example 5: Export to Excel

Add export functionality:

```tsx
'use client'

import { useBURCRenewals } from '@/hooks/useBURCRenewals'
import { Download } from 'lucide-react'

export function RenewalExportButton() {
  const { renewals, loading } = useBURCRenewals({ period: 365 })

  const handleExport = () => {
    // Convert to CSV
    const headers = ['Period', 'Clients', 'Contracts', 'Value (USD)', 'Days Until', 'Risk']
    const rows = renewals.map(r => [
      r.renewal_period,
      r.clients,
      r.contract_count,
      r.total_value_usd,
      r.days_until_renewal,
      r.risk_level,
    ])

    const csv = [
      headers.join(','),
      ...rows.map(row => row.join(','))
    ].join('\n')

    // Download
    const blob = new Blob([csv], { type: 'text/csv' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `burc-renewals-${new Date().toISOString().split('T')[0]}.csv`
    a.click()
  }

  return (
    <button
      onClick={handleExport}
      disabled={loading}
      className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
    >
      <Download className="h-4 w-4" />
      Export to CSV
    </button>
  )
}
```

### Example 6: Custom Risk Scoring

Implement enhanced risk calculation:

```tsx
'use client'

import { useBURCRenewals, type BURCRenewal } from '@/hooks/useBURCRenewals'
import { useMemo } from 'react'

// Fetch additional client metrics
const useClientEngagement = (clientNames: string[]) => {
  // Your implementation to fetch NPS, meeting frequency, etc.
  return {
    npsScores: new Map(),
    meetingCounts: new Map(),
    supportTickets: new Map(),
  }
}

export function EnhancedRenewalList() {
  const { renewals, loading } = useBURCRenewals({ period: 90 })

  const clientNames = useMemo(
    () => renewals.flatMap(r => r.clients.split(',').map(c => c.trim())),
    [renewals]
  )

  const engagement = useClientEngagement(clientNames)

  const enrichedRenewals = useMemo(() => {
    return renewals.map(renewal => {
      const clients = renewal.clients.split(',').map(c => c.trim())

      // Calculate average engagement for clients in this renewal
      const avgNPS = clients.reduce((sum, client) => {
        return sum + (engagement.npsScores.get(client) || 0)
      }, 0) / clients.length

      const avgMeetings = clients.reduce((sum, client) => {
        return sum + (engagement.meetingCounts.get(client) || 0)
      }, 0) / clients.length

      // Enhanced risk calculation
      let enhancedRisk: 'green' | 'amber' | 'red' = renewal.risk_level!

      if (renewal.days_until_renewal! < 30 && avgNPS < 7) {
        enhancedRisk = 'red'
      } else if (avgMeetings < 1 || avgNPS < 8) {
        enhancedRisk = 'amber'
      }

      return {
        ...renewal,
        enhanced_risk: enhancedRisk,
        engagement_score: avgNPS,
        meeting_frequency: avgMeetings,
      }
    })
  }, [renewals, engagement])

  return (
    <div className="space-y-4">
      {enrichedRenewals.map((renewal, idx) => (
        <div key={idx} className="bg-white rounded-lg border p-4">
          <div className="flex items-start justify-between">
            <div>
              <h4 className="font-medium">{renewal.clients}</h4>
              <p className="text-sm text-grey-600">{renewal.renewal_period}</p>
            </div>
            <div className="text-right">
              <div className="text-sm text-grey-600 mb-1">
                NPS: {renewal.engagement_score?.toFixed(1)} |
                Meetings: {renewal.meeting_frequency?.toFixed(1)}/month
              </div>
              <span className={`px-2 py-1 rounded text-xs font-medium ${
                renewal.enhanced_risk === 'red' ? 'bg-red-100 text-red-800' :
                renewal.enhanced_risk === 'amber' ? 'bg-amber-100 text-amber-800' :
                'bg-emerald-100 text-emerald-800'
              }`}>
                {renewal.enhanced_risk.toUpperCase()} RISK
              </span>
            </div>
          </div>
        </div>
      ))}
    </div>
  )
}
```

### Example 7: Mobile-Optimised Card View

Create a mobile-friendly renewal list:

```tsx
'use client'

import { useBURCRenewals } from '@/hooks/useBURCRenewals'
import { Calendar, DollarSign, Clock } from 'lucide-react'

export function MobileRenewalCards() {
  const { renewals, loading } = useBURCRenewals({
    period: 60,
    sortBy: 'risk',
  })

  if (loading) return <div>Loading...</div>

  return (
    <div className="space-y-3 p-4">
      {renewals.map((renewal, idx) => (
        <div
          key={idx}
          className={`rounded-lg border-l-4 p-4 shadow-sm ${
            renewal.risk_level === 'red'
              ? 'border-red-500 bg-red-50'
              : renewal.risk_level === 'amber'
              ? 'border-amber-500 bg-amber-50'
              : 'border-emerald-500 bg-emerald-50'
          }`}
        >
          {/* Client Name */}
          <h3 className="font-semibold text-grey-900 mb-2">
            {renewal.clients.split(',')[0]}
            {renewal.clients.split(',').length > 1 && (
              <span className="text-sm text-grey-600 ml-2">
                +{renewal.clients.split(',').length - 1} more
              </span>
            )}
          </h3>

          {/* Details Grid */}
          <div className="grid grid-cols-2 gap-3">
            <div className="flex items-center gap-2 text-sm">
              <Calendar className="h-4 w-4 text-grey-500" />
              <span>{renewal.renewal_period}</span>
            </div>
            <div className="flex items-center gap-2 text-sm">
              <Clock className="h-4 w-4 text-grey-500" />
              <span className="font-medium">{renewal.days_until_renewal}d</span>
            </div>
            <div className="flex items-center gap-2 text-sm">
              <DollarSign className="h-4 w-4 text-grey-500" />
              <span className="font-medium">
                ${(renewal.total_value_usd / 1000).toFixed(0)}K
              </span>
            </div>
            <div className="text-sm">
              <span className="font-medium">{renewal.contract_count}</span>
              <span className="text-grey-600 ml-1">
                {renewal.contract_count === 1 ? 'contract' : 'contracts'}
              </span>
            </div>
          </div>
        </div>
      ))}
    </div>
  )
}
```

## Integration with Existing Components

### Add to BURC Executive Dashboard

```tsx
// In BURCExecutiveDashboard.tsx
import { RenewalUpcomingWidget } from '@/components/burc'

// Add in the layout section
<div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
  <RenewalUpcomingWidget />
  {/* Existing widgets */}
</div>
```

### Add to Navigation Menu

```tsx
// In your navigation component
const navigation = [
  // ... existing items
  {
    name: 'Contract Renewals',
    href: '/burc/renewals',
    icon: Calendar,
    badge: useRenewalBadge(), // Shows count of critical renewals
  },
]
```

### Create Renewal Badge Hook

```tsx
function useRenewalBadge() {
  const { stats } = useBURCRenewals({
    period: 30,
    riskLevel: 'red',
  })

  return stats.byRisk.red > 0 ? stats.byRisk.red : null
}
```

## Testing

### Unit Test Example

```tsx
import { render, screen } from '@testing-library/react'
import { RenewalUpcomingWidget } from '@/components/burc'

// Mock the hook
jest.mock('@/hooks/useBURCRenewals', () => ({
  useBURCRenewals: () => ({
    renewals: [
      {
        renewal_period: 'Jan 2026',
        clients: 'Test Client',
        contract_count: 1,
        total_value_usd: 100000,
        days_until_renewal: 15,
        risk_level: 'red',
      },
    ],
    loading: false,
    error: null,
    stats: {
      total: 1,
      totalValue: 100000,
      totalContracts: 1,
      byRisk: { red: 1, amber: 0, green: 0 },
    },
  }),
}))

describe('RenewalUpcomingWidget', () => {
  it('renders critical renewals', () => {
    render(<RenewalUpcomingWidget />)
    expect(screen.getByText('Test Client')).toBeInTheDocument()
    expect(screen.getByText('15d')).toBeInTheDocument()
  })
})
```

---

**Need Help?**
- Check the full guide: `/docs/guides/burc/BURC-RENEWAL-CALENDAR-GUIDE.md`
- Review TypeScript types: `/src/hooks/useBURCRenewals.ts`
- Database schema: `/docs/database-schema.md`
