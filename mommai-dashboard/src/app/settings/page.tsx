'use client';

import { User, Bell, Shield, Globe, Moon, Save } from 'lucide-react';
import { useState } from 'react';

export default function SettingsPage() {
    const [notifications, setNotifications] = useState({
        highRisk: true,
        vitals: true,
        messages: true,
        appointments: true,
    });

    return (
        <div className="max-w-3xl space-y-6">
            <div>
                <h1 className="text-2xl font-bold text-slate-800">Settings</h1>
                <p className="text-slate-500">Manage your account and preferences</p>
            </div>

            {/* Profile Section */}
            <div className="bg-white rounded-2xl p-6 shadow-sm">
                <div className="flex items-center gap-3 mb-6">
                    <User className="w-5 h-5 text-pink-500" />
                    <h2 className="text-lg font-semibold text-slate-800">Profile</h2>
                </div>
                <div className="flex items-center gap-6 mb-6">
                    <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-pink-400 to-pink-600 flex items-center justify-center text-white font-bold text-2xl">
                        Dr
                    </div>
                    <div>
                        <h3 className="text-xl font-semibold text-slate-800">Dr. Sarah Johnson</h3>
                        <p className="text-slate-500">OB-GYN • Maternal Care Clinic</p>
                        <button className="text-pink-500 text-sm font-medium mt-1 hover:text-pink-600">Change Photo</button>
                    </div>
                </div>
                <div className="grid grid-cols-2 gap-4">
                    <div>
                        <label className="text-sm text-slate-500">Full Name</label>
                        <input type="text" defaultValue="Dr. Sarah Johnson" className="w-full mt-1 px-4 py-2 bg-slate-100 rounded-xl text-sm" />
                    </div>
                    <div>
                        <label className="text-sm text-slate-500">Email</label>
                        <input type="email" defaultValue="sarah.johnson@clinic.com" className="w-full mt-1 px-4 py-2 bg-slate-100 rounded-xl text-sm" />
                    </div>
                    <div>
                        <label className="text-sm text-slate-500">Phone</label>
                        <input type="tel" defaultValue="+1 555-0123" className="w-full mt-1 px-4 py-2 bg-slate-100 rounded-xl text-sm" />
                    </div>
                    <div>
                        <label className="text-sm text-slate-500">Specialty</label>
                        <input type="text" defaultValue="Obstetrics & Gynecology" className="w-full mt-1 px-4 py-2 bg-slate-100 rounded-xl text-sm" />
                    </div>
                </div>
            </div>

            {/* Notifications */}
            <div className="bg-white rounded-2xl p-6 shadow-sm">
                <div className="flex items-center gap-3 mb-6">
                    <Bell className="w-5 h-5 text-pink-500" />
                    <h2 className="text-lg font-semibold text-slate-800">Notifications</h2>
                </div>
                <div className="space-y-4">
                    <NotificationToggle
                        label="High Risk Alerts"
                        description="Get notified when a patient's risk score increases"
                        checked={notifications.highRisk}
                        onChange={() => setNotifications({ ...notifications, highRisk: !notifications.highRisk })}
                    />
                    <NotificationToggle
                        label="Vitals Alerts"
                        description="Alerts for abnormal BP, weight, or blood sugar readings"
                        checked={notifications.vitals}
                        onChange={() => setNotifications({ ...notifications, vitals: !notifications.vitals })}
                    />
                    <NotificationToggle
                        label="New Messages"
                        description="Notify when patients send messages"
                        checked={notifications.messages}
                        onChange={() => setNotifications({ ...notifications, messages: !notifications.messages })}
                    />
                    <NotificationToggle
                        label="Appointment Reminders"
                        description="Reminders 15 minutes before appointments"
                        checked={notifications.appointments}
                        onChange={() => setNotifications({ ...notifications, appointments: !notifications.appointments })}
                    />
                </div>
            </div>

            {/* Security */}
            <div className="bg-white rounded-2xl p-6 shadow-sm">
                <div className="flex items-center gap-3 mb-6">
                    <Shield className="w-5 h-5 text-pink-500" />
                    <h2 className="text-lg font-semibold text-slate-800">Security</h2>
                </div>
                <div className="space-y-4">
                    <button className="w-full text-left px-4 py-3 bg-slate-50 rounded-xl hover:bg-slate-100 transition-colors">
                        <p className="font-medium text-slate-800">Change Password</p>
                        <p className="text-sm text-slate-500">Update your account password</p>
                    </button>
                    <button className="w-full text-left px-4 py-3 bg-slate-50 rounded-xl hover:bg-slate-100 transition-colors">
                        <p className="font-medium text-slate-800">Two-Factor Authentication</p>
                        <p className="text-sm text-slate-500">Add an extra layer of security</p>
                    </button>
                    <button className="w-full text-left px-4 py-3 bg-slate-50 rounded-xl hover:bg-slate-100 transition-colors">
                        <p className="font-medium text-slate-800">Active Sessions</p>
                        <p className="text-sm text-slate-500">Manage your logged-in devices</p>
                    </button>
                </div>
            </div>

            {/* Save Button */}
            <button className="w-full px-6 py-3 bg-pink-500 text-white rounded-xl hover:bg-pink-600 transition-colors flex items-center justify-center gap-2 font-medium">
                <Save className="w-5 h-5" />
                Save Changes
            </button>
        </div>
    );
}

function NotificationToggle({ label, description, checked, onChange }: {
    label: string;
    description: string;
    checked: boolean;
    onChange: () => void;
}) {
    return (
        <div className="flex items-center justify-between p-4 bg-slate-50 rounded-xl">
            <div>
                <p className="font-medium text-slate-800">{label}</p>
                <p className="text-sm text-slate-500">{description}</p>
            </div>
            <button
                onClick={onChange}
                className={`w-12 h-6 rounded-full transition-colors ${checked ? 'bg-pink-500' : 'bg-slate-300'}`}
            >
                <div className={`w-5 h-5 bg-white rounded-full shadow transition-transform ${checked ? 'translate-x-6' : 'translate-x-0.5'}`} />
            </button>
        </div>
    );
}
