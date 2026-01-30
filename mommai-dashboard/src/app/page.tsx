'use client';

import { useState, useEffect } from 'react';
import { Users, AlertTriangle, Calendar, MessageSquare, TrendingUp, TrendingDown, ArrowRight, Activity } from 'lucide-react';
import Link from 'next/link';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api';

export default function Dashboard() {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const res = await fetch(`${API_URL}/provider/clinic/dashboard`);
        if (!res.ok) throw new Error('Failed to fetch');
        const json = await res.json();
        setData(json);
        setError(null);
      } catch (e) {
        console.error('Failed to fetch dashboard data', e);
        setError('Unable to connect to server');
      } finally {
        setLoading(false);
      }
    };
    fetchData();

    // Refresh every 10 seconds for real-time updates
    const interval = setInterval(fetchData, 10000);
    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-full min-h-[400px]">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-pink-500 mx-auto"></div>
          <p className="mt-4 text-slate-500">Loading dashboard...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex items-center justify-center h-full min-h-[400px]">
        <div className="text-center">
          <AlertTriangle className="w-12 h-12 text-yellow-500 mx-auto" />
          <p className="mt-4 text-slate-600">{error}</p>
          <p className="text-sm text-slate-400 mt-2">Make sure the backend server is running on port 5000</p>
        </div>
      </div>
    );
  }

  const stats = data?.stats || {
    totalPatients: 0,
    highRiskCount: 0,
    unreadAlerts: 0,
    appointmentsToday: 0
  };

  const recentAlerts = data?.recentAlerts || [];

  return (
    <div className="space-y-6">
      {/* Page Title */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">Dashboard</h1>
          <p className="text-slate-500">Real-time Maternal Health Monitoring</p>
        </div>
        <div className="flex items-center gap-2">
          <span className="flex items-center gap-2 text-sm text-green-600 bg-green-50 px-3 py-1 rounded-full">
            <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></span>
            Live
          </span>
          <button className="px-4 py-2 bg-pink-500 text-white rounded-xl hover:bg-pink-600 transition-colors flex items-center gap-2">
            <Calendar className="w-4 h-4" />
            Today's Schedule
          </button>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Patients"
          value={stats.totalPatients.toString()}
          change=""
          trend="neutral"
          icon={Users}
          gradient="stat-gradient-pink"
        />
        <StatCard
          title="High Risk"
          value={stats.highRiskCount.toString()}
          change=""
          trend={stats.highRiskCount > 0 ? "up" : "neutral"}
          icon={AlertTriangle}
          gradient="stat-gradient-orange"
        />
        <StatCard
          title="Active Alerts"
          value={stats.unreadAlerts.toString()}
          change=""
          trend={stats.unreadAlerts > 0 ? "up" : "neutral"}
          icon={Activity}
          gradient="stat-gradient-teal"
        />
        <StatCard
          title="Today's Appointments"
          value={stats.appointmentsToday.toString()}
          change=""
          trend="neutral"
          icon={Calendar}
          gradient="stat-gradient-purple"
        />
      </div>

      {/* Recent Health Alerts */}
      <div className="bg-white rounded-2xl shadow-sm overflow-hidden">
        <div className="p-6 border-b border-slate-100 flex items-center justify-between">
          <h3 className="text-lg font-semibold text-slate-800">Recent Health Alerts</h3>
          <Link href="/alerts" className="text-pink-500 hover:text-pink-600 flex items-center gap-1 text-sm font-medium">
            View All <ArrowRight className="w-4 h-4" />
          </Link>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-slate-50">
              <tr>
                <th className="text-left py-3 px-6 text-xs font-medium text-slate-500 uppercase">Patient</th>
                <th className="text-left py-3 px-6 text-xs font-medium text-slate-500 uppercase">Alert Type</th>
                <th className="text-left py-3 px-6 text-xs font-medium text-slate-500 uppercase">Message</th>
                <th className="text-left py-3 px-6 text-xs font-medium text-slate-500 uppercase">Time</th>
                <th className="text-left py-3 px-6 text-xs font-medium text-slate-500 uppercase">Action</th>
              </tr>
            </thead>
            <tbody>
              {recentAlerts.length === 0 ? (
                <tr>
                  <td colSpan={5} className="py-10 text-center text-slate-400">
                    <Activity className="w-8 h-8 mx-auto mb-2 opacity-50" />
                    No active alerts - All patients are healthy!
                  </td>
                </tr>
              ) : (
                recentAlerts.map((alert: any) => (
                  <tr key={alert._id} className="border-t border-slate-100 hover:bg-slate-50">
                    <td className="py-4 px-6">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-gradient-to-br from-pink-400 to-pink-600 flex items-center justify-center text-white font-semibold text-sm">
                          {alert.patientId?.name?.split(' ').map((n: any) => n[0]).join('') || '?'}
                        </div>
                        <div>
                          <p className="font-medium text-slate-800">{alert.patientId?.name || 'Unknown'}</p>
                        </div>
                      </div>
                    </td>
                    <td className="py-4 px-6">
                      <span className={`px-3 py-1 rounded-full text-xs font-medium ${alert.type === 'critical' ? 'bg-red-100 text-red-600' : alert.type === 'warning' ? 'bg-yellow-100 text-yellow-600' : 'bg-blue-100 text-blue-600'}`}>
                        {alert.title}
                      </span>
                    </td>
                    <td className="py-4 px-6 text-slate-600 max-w-xs truncate">{alert.message}</td>
                    <td className="py-4 px-6 text-slate-600 text-sm">
                      {new Date(alert.createdAt).toLocaleString()}
                    </td>
                    <td className="py-4 px-6">
                      <Link href={`/patients/${alert.patientId?._id}`} className="text-pink-500 hover:text-pink-600 font-medium text-sm">
                        Review
                      </Link>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Quick Links */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Link href="/patients" className="bg-gradient-to-br from-pink-500 to-pink-600 rounded-2xl p-6 text-white hover:shadow-lg transition-shadow">
          <Users className="w-8 h-8 mb-3" />
          <h3 className="font-semibold text-lg">View All Patients</h3>
          <p className="text-pink-100 text-sm mt-1">Monitor all enrolled patients</p>
        </Link>
        <Link href="/alerts" className="bg-gradient-to-br from-orange-500 to-orange-600 rounded-2xl p-6 text-white hover:shadow-lg transition-shadow">
          <AlertTriangle className="w-8 h-8 mb-3" />
          <h3 className="font-semibold text-lg">Active Alerts</h3>
          <p className="text-orange-100 text-sm mt-1">{stats.unreadAlerts} alerts need attention</p>
        </Link>
        <Link href="/messages" className="bg-gradient-to-br from-teal-500 to-teal-600 rounded-2xl p-6 text-white hover:shadow-lg transition-shadow">
          <MessageSquare className="w-8 h-8 mb-3" />
          <h3 className="font-semibold text-lg">Messages</h3>
          <p className="text-teal-100 text-sm mt-1">Communicate with patients</p>
        </Link>
      </div>
    </div>
  );
}

function StatCard({ title, value, change, trend, icon: Icon, gradient }: {
  title: string;
  value: string;
  change: string;
  trend: 'up' | 'down' | 'neutral';
  icon: React.ComponentType<{ className?: string }>;
  gradient: string;
}) {
  return (
    <div className="bg-white rounded-2xl p-6 shadow-sm card-hover">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-slate-500 text-sm">{title}</p>
          <p className="text-3xl font-bold text-slate-800 mt-1">{value}</p>
        </div>
        <div className={`w-12 h-12 rounded-xl ${gradient} flex items-center justify-center`}>
          <Icon className="w-6 h-6 text-white" />
        </div>
      </div>
      {change && (
        <div className="mt-3 flex items-center gap-1">
          {trend === 'up' && <TrendingUp className="w-4 h-4 text-green-500" />}
          {trend === 'down' && <TrendingDown className="w-4 h-4 text-red-500" />}
          <span className={`text-sm ${trend === 'up' ? 'text-green-600' : trend === 'down' ? 'text-red-600' : 'text-slate-500'}`}>
            {change}
          </span>
          <span className="text-sm text-slate-400">vs last month</span>
        </div>
      )}
    </div>
  );
}
