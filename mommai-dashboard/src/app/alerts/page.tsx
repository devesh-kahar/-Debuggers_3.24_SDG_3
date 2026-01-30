'use client';

import { AlertTriangle, CheckCircle, Clock, Filter, Activity, Heart, RefreshCw } from 'lucide-react';
import { useState, useEffect } from 'react';
import Link from 'next/link';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api';

export default function AlertsPage() {
    const [alerts, setAlerts] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [filter, setFilter] = useState('all');
    const [unreadCount, setUnreadCount] = useState(0);

    const fetchAlerts = async () => {
        try {
            const unreadOnly = filter === 'unread' ? 'true' : 'false';
            const type = filter === 'critical' ? 'critical' : 'all';
            const res = await fetch(`${API_URL}/provider/clinic/alerts?type=${type}&unreadOnly=${unreadOnly}`);
            if (!res.ok) throw new Error('Failed to fetch');
            const data = await res.json();
            setAlerts(data.alerts || []);
            setUnreadCount(data.unreadCount || 0);
        } catch (e) {
            console.error('Failed to fetch alerts', e);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchAlerts();
        // Refresh every 5 seconds for real-time updates
        const interval = setInterval(fetchAlerts, 5000);
        return () => clearInterval(interval);
    }, [filter]);

    const markAsRead = async (alertId: string) => {
        try {
            await fetch(`${API_URL}/provider/clinic/alerts/${alertId}/read`, { method: 'PUT' });
            fetchAlerts(); // Refresh after marking
        } catch (e) {
            console.error('Failed to mark as read', e);
        }
    };

    const markAllRead = async () => {
        try {
            await Promise.all(alerts.filter(a => !a.isRead).map(a =>
                fetch(`${API_URL}/provider/clinic/alerts/${a._id}/read`, { method: 'PUT' })
            ));
            fetchAlerts();
        } catch (e) {
            console.error('Failed to mark all as read', e);
        }
    };

    const typeColors: Record<string, string> = {
        critical: 'bg-red-100 text-red-600 border-red-200',
        warning: 'bg-yellow-100 text-yellow-600 border-yellow-200',
        info: 'bg-blue-100 text-blue-600 border-blue-200',
        success: 'bg-green-100 text-green-600 border-green-200',
    };

    const typeIcons: Record<string, React.ReactNode> = {
        critical: <AlertTriangle className="w-5 h-5" />,
        warning: <Clock className="w-5 h-5" />,
        info: <Activity className="w-5 h-5" />,
        success: <CheckCircle className="w-5 h-5" />,
    };

    const formatTime = (date: string) => {
        const now = new Date();
        const alertDate = new Date(date);
        const diffMs = now.getTime() - alertDate.getTime();
        const diffMins = Math.floor(diffMs / 60000);
        const diffHours = Math.floor(diffMins / 60);
        const diffDays = Math.floor(diffHours / 24);

        if (diffMins < 60) return `${diffMins} minutes ago`;
        if (diffHours < 24) return `${diffHours} hours ago`;
        return `${diffDays} days ago`;
    };

    if (loading) {
        return (
            <div className="flex items-center justify-center h-full min-h-[400px]">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-pink-500"></div>
            </div>
        );
    }

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Alerts</h1>
                    <p className="text-slate-500">{unreadCount} unread alerts</p>
                </div>
                <div className="flex gap-2">
                    <button
                        onClick={fetchAlerts}
                        className="p-2 bg-slate-100 text-slate-600 rounded-xl hover:bg-slate-200 transition-colors"
                    >
                        <RefreshCw className="w-5 h-5" />
                    </button>
                    <button
                        onClick={markAllRead}
                        className="px-4 py-2 bg-slate-100 text-slate-600 rounded-xl hover:bg-slate-200 transition-colors"
                    >
                        Mark All Read
                    </button>
                </div>
            </div>

            {/* Live indicator */}
            <div className="flex items-center gap-2 text-sm text-green-600 bg-green-50 px-3 py-2 rounded-xl w-fit">
                <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></span>
                Auto-refreshing every 5 seconds
            </div>

            {/* Filters */}
            <div className="flex items-center gap-2">
                <Filter className="w-5 h-5 text-slate-400" />
                {['all', 'unread', 'critical'].map((f) => (
                    <button
                        key={f}
                        onClick={() => setFilter(f)}
                        className={`px-4 py-2 rounded-xl text-sm font-medium transition-colors ${filter === f ? 'bg-pink-500 text-white' : 'bg-white text-slate-600 hover:bg-slate-100'}`}
                    >
                        {f.charAt(0).toUpperCase() + f.slice(1)}
                    </button>
                ))}
            </div>

            {/* Alert List */}
            <div className="space-y-3">
                {alerts.length === 0 ? (
                    <div className="bg-white rounded-2xl p-10 shadow-sm text-center">
                        <CheckCircle className="w-12 h-12 text-green-500 mx-auto mb-4" />
                        <h3 className="text-lg font-semibold text-slate-800">No Alerts</h3>
                        <p className="text-slate-500 mt-1">
                            {filter === 'unread' ? 'All alerts have been read!' :
                                filter === 'critical' ? 'No critical alerts - Great job!' :
                                    'No alerts yet. Alerts will appear when patients log vitals.'}
                        </p>
                    </div>
                ) : (
                    alerts.map((alert) => (
                        <div
                            key={alert._id}
                            className={`bg-white rounded-2xl p-5 shadow-sm border-l-4 ${!alert.isRead ? 'border-l-pink-500' : 'border-l-transparent'} card-hover cursor-pointer`}
                            onClick={() => !alert.isRead && markAsRead(alert._id)}
                        >
                            <div className="flex items-start gap-4">
                                <div className={`p-3 rounded-xl ${typeColors[alert.type] || typeColors.info}`}>
                                    {typeIcons[alert.type] || typeIcons.info}
                                </div>
                                <div className="flex-1">
                                    <div className="flex items-center justify-between">
                                        <h3 className="font-semibold text-slate-800">{alert.title}</h3>
                                        <span className="text-sm text-slate-400">{formatTime(alert.createdAt)}</span>
                                    </div>
                                    <p className="text-slate-600 text-sm mt-1">{alert.message}</p>
                                    <div className="flex items-center justify-between mt-2">
                                        <p className="text-pink-500 text-sm font-medium">
                                            Patient: {alert.patientId?.name || 'Unknown'}
                                        </p>
                                        {alert.patientId?._id && (
                                            <Link
                                                href={`/patients/${alert.patientId._id}`}
                                                className="text-sm text-teal-600 hover:text-teal-700 font-medium"
                                                onClick={(e) => e.stopPropagation()}
                                            >
                                                View Patient →
                                            </Link>
                                        )}
                                    </div>
                                </div>
                                {!alert.isRead && <div className="w-2 h-2 rounded-full bg-pink-500"></div>}
                            </div>
                        </div>
                    ))
                )}
            </div>
        </div>
    );
}
