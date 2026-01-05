/**
 * Example: Settings Page with Notification Settings
 *
 * This example shows how to integrate the NotificationSettings component
 * into a settings or profile page.
 */

'use client';

import { NotificationSettings } from '@/components/NotificationSettings';
import { Card } from '@/components/ui/card';

export default function SettingsPage() {
  return (
    <div className="container mx-auto max-w-4xl space-y-6 p-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Settings</h1>
        <p className="mt-1 text-sm text-gray-600">
          Manage your account settings and preferences
        </p>
      </div>

      {/* Notification Settings Section */}
      <Card className="p-6">
        <NotificationSettings />
      </Card>

      {/* Other Settings Sections */}
      <Card className="p-6">
        <h2 className="text-lg font-semibold text-gray-900">Profile Settings</h2>
        <p className="mt-1 text-sm text-gray-600">Update your profile information</p>
        {/* Add profile settings form here */}
      </Card>

      <Card className="p-6">
        <h2 className="text-lg font-semibold text-gray-900">Preferences</h2>
        <p className="mt-1 text-sm text-gray-600">Customise your experience</p>
        {/* Add preferences settings here */}
      </Card>
    </div>
  );
}
