'use client';

import { ArrowLeft, Phone, MessageSquare, Calendar, AlertTriangle, Activity, Baby, Scale, Heart, Download, RefreshCw } from 'lucide-react';
import Link from 'next/link';
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, Area, AreaChart } from 'recharts';
import { useState, useEffect, use } from 'react';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api';

export default function PatientProfile({ params }: { params: Promise<{ id: string }> }) {
    const resolvedParams = use(params);
    const [data, setData] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    const fetchPatient = async () => {
        try {
            const res = await fetch(`${API_URL}/provider/clinic/patients/${resolvedParams.id}`);
            if (!res.ok) throw new Error('Patient not found');
            const json = await res.json();
            setData(json);
            setError(null);
        } catch (e) {
            console.error('Failed to fetch patient', e);
            setError('Patient not found');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchPatient();
        // Refresh every 10 seconds
        const interval = setInterval(fetchPatient, 10000);
        return () => clearInterval(interval);
    }, [resolvedParams.id]);

    if (loading) {
        return (
            <div className="flex items-center justify-center h-full min-h-[400px]">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-pink-500"></div>
            </div>
        );
    }

    if (error || !data) {
        return (
            <div className="space-y-6">
                <Link href="/patients" className="inline-flex items-center gap-2 text-slate-600 hover:text-slate-800">
                    <ArrowLeft className="w-4 h-4" />
                    Back to Patients
                </Link>
                <div className="bg-white rounded-2xl p-10 shadow-sm text-center">
                    <AlertTriangle className="w-12 h-12 text-yellow-500 mx-auto mb-4" />
                    <h3 className="text-lg font-semibold text-slate-800">Patient Not Found</h3>
                    <p className="text-slate-500 mt-1">This patient may not exist or has been removed.</p>
                </div>
            </div>
        );
    }

    const patient = data.patient;
    const pregnancy = data.pregnancy;
    const bpData = data.bpData || [];
    const weightData = data.weightData || [];
    const recentLogs = data.recentLogs || [];
    const riskFactors = pregnancy?.riskFactors || [];

    return (
        <div className="space-y-6">
            {/* Back Button */}
            <div className="flex items-center justify-between">
                <Link href="/patients" className="inline-flex items-center gap-2 text-slate-600 hover:text-slate-800">
                    <ArrowLeft className="w-4 h-4" />
                    Back to Patients
                </Link>
                <div className="flex items-center gap-2">
                    <span className="flex items-center gap-2 text-sm text-green-600 bg-green-50 px-3 py-1 rounded-full">
                        <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></span>
                        Live
                    </span>
                    <button onClick={fetchPatient} className="p-2 bg-slate-100 text-slate-600 rounded-xl hover:bg-slate-200">
                        <RefreshCw className="w-4 h-4" />
                    </button>
                </div>
            </div>

            {/* Patient Header */}
            <div className="bg-white rounded-2xl p-6 shadow-sm">
                <div className="flex items-start justify-between">
                    <div className="flex items-center gap-4">
                        <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-pink-400 to-pink-600 flex items-center justify-center text-white font-bold text-xl">
                            {patient.name?.split(' ').map((n: string) => n[0]).join('') || '?'}
                        </div>
                        <div>
                            <h1 className="text-2xl font-bold text-slate-800">{patient.name}</h1>
                            <p className="text-slate-500">Age {patient.age} • {patient.bloodType || 'Unknown'}</p>
                            <div className="flex gap-2 mt-2">
                                {pregnancy && (
                                    <>
                                        <span className={`px-3 py-1 rounded-full text-xs font-medium ${pregnancy.riskLevel === 'high' ? 'bg-red-100 text-red-600' :
                                            pregnancy.riskLevel === 'medium' ? 'bg-yellow-100 text-yellow-600' :
                                                'bg-green-100 text-green-600'
                                            }`}>
                                            Risk Score: {pregnancy.riskScore}%
                                        </span>
                                        <span className="px-3 py-1 rounded-full text-xs font-medium bg-teal-100 text-teal-700">
                                            Week {pregnancy.currentWeek} • Trimester {pregnancy.trimester}
                                        </span>
                                    </>
                                )}
                            </div>
                        </div>
                    </div>
                    <div className="flex gap-2">
                        <button className="p-3 bg-teal-100 text-teal-600 rounded-xl hover:bg-teal-200">
                            <Phone className="w-5 h-5" />
                        </button>
                        <button className="p-3 bg-pink-100 text-pink-600 rounded-xl hover:bg-pink-200">
                            <MessageSquare className="w-5 h-5" />
                        </button>
                        <button className="p-3 bg-purple-100 text-purple-600 rounded-xl hover:bg-purple-200">
                            <Calendar className="w-5 h-5" />
                        </button>
                    </div>
                </div>

                {/* Quick Stats */}
                <div className="grid grid-cols-4 gap-4 mt-6">
                    <QuickStat icon={Baby} label="Due Date" value={pregnancy?.dueDate ? new Date(pregnancy.dueDate).toLocaleDateString() : 'N/A'} color="pink" />
                    <QuickStat icon={Heart} label="Last BP" value={bpData.length > 0 ? `${bpData[bpData.length - 1]?.systolic}/${bpData[bpData.length - 1]?.diastolic}` : '---'} color="red" />
                    <QuickStat icon={Scale} label="Weight" value={weightData.length > 0 ? `${weightData[weightData.length - 1]?.weight} kg` : '---'} color="teal" />
                    <QuickStat icon={Activity} label="Risk Level" value={pregnancy?.riskLevel?.toUpperCase() || 'N/A'} color="purple" />
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Risk Assessment */}
                <div className="lg:col-span-1 space-y-6">
                    {/* Risk Gauge */}
                    <div className="bg-white rounded-2xl p-6 shadow-sm">
                        <h3 className="text-lg font-semibold text-slate-800 mb-4">Risk Assessment</h3>
                        <div className="flex flex-col items-center">
                            <div className="relative w-40 h-20 mb-4">
                                <svg viewBox="0 0 100 50" className="w-full h-full">
                                    <path d="M 5 50 A 45 45 0 0 1 95 50" fill="none" stroke="#e2e8f0" strokeWidth="10" strokeLinecap="round" />
                                    <path d="M 5 50 A 45 45 0 0 1 95 50" fill="none" stroke="url(#riskGradient)" strokeWidth="10" strokeLinecap="round" strokeDasharray={`${(pregnancy?.riskScore || 0) * 1.4} 140`} />
                                    <defs>
                                        <linearGradient id="riskGradient">
                                            <stop offset="0%" stopColor="#22c55e" />
                                            <stop offset="50%" stopColor="#eab308" />
                                            <stop offset="100%" stopColor="#ef4444" />
                                        </linearGradient>
                                    </defs>
                                </svg>
                                <div className="absolute inset-0 flex items-end justify-center pb-0">
                                    <span className="text-3xl font-bold text-slate-800">{pregnancy?.riskScore || 0}</span>
                                </div>
                            </div>
                            <span className={`text-lg font-semibold ${pregnancy?.riskLevel === 'high' ? 'text-red-500' :
                                pregnancy?.riskLevel === 'medium' ? 'text-yellow-500' :
                                    'text-green-500'
                                }`}>
                                {pregnancy?.riskLevel?.charAt(0).toUpperCase() + pregnancy?.riskLevel?.slice(1) || 'Low'} Risk
                            </span>
                        </div>
                    </div>

                    {/* Risk Factors */}
                    <div className="bg-white rounded-2xl p-6 shadow-sm">
                        <h3 className="text-lg font-semibold text-slate-800 mb-4">Risk Factors</h3>
                        <div className="space-y-3">
                            {riskFactors.length === 0 ? (
                                <p className="text-slate-400 text-sm text-center py-4">No risk factors detected</p>
                            ) : (
                                riskFactors.map((rf: any, i: number) => (
                                    <div key={i} className={`p-3 rounded-xl border-l-4 ${rf.severity === 'high' ? 'bg-red-50 border-red-500' :
                                        rf.severity === 'medium' ? 'bg-yellow-50 border-yellow-500' :
                                            'bg-green-50 border-green-500'
                                        }`}>
                                        <div className="flex items-center gap-2">
                                            <AlertTriangle className={`w-4 h-4 ${rf.severity === 'high' ? 'text-red-500' :
                                                rf.severity === 'medium' ? 'text-yellow-500' :
                                                    'text-green-500'
                                                }`} />
                                            <span className="font-medium text-slate-700 text-sm">{rf.factor}</span>
                                        </div>
                                        {rf.value && <p className="text-xs text-slate-500 mt-1 ml-6">{rf.value}</p>}
                                    </div>
                                ))
                            )}
                        </div>
                    </div>
                </div>

                {/* Charts */}
                <div className="lg:col-span-2 space-y-6">
                    {/* BP Chart */}
                    <div className="bg-white rounded-2xl p-6 shadow-sm">
                        <div className="flex items-center justify-between mb-4">
                            <h3 className="text-lg font-semibold text-slate-800">Blood Pressure Trend</h3>
                            <button className="text-sm text-pink-500 flex items-center gap-1">
                                <Download className="w-4 h-4" /> Export
                            </button>
                        </div>
                        {bpData.length === 0 ? (
                            <div className="h-[200px] flex items-center justify-center text-slate-400">
                                No BP data recorded yet
                            </div>
                        ) : (
                            <ResponsiveContainer width="100%" height={200}>
                                <LineChart data={bpData}>
                                    <XAxis dataKey="date" axisLine={false} tickLine={false} />
                                    <YAxis axisLine={false} tickLine={false} domain={[60, 160]} />
                                    <Tooltip />
                                    <Line type="monotone" dataKey="systolic" stroke="#f472b6" strokeWidth={3} dot={{ fill: '#f472b6' }} name="Systolic" />
                                    <Line type="monotone" dataKey="diastolic" stroke="#14b8a6" strokeWidth={3} dot={{ fill: '#14b8a6' }} name="Diastolic" />
                                </LineChart>
                            </ResponsiveContainer>
                        )}
                        <div className="flex justify-center gap-6 mt-2">
                            <div className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-pink-400"></div><span className="text-sm text-slate-600">Systolic</span></div>
                            <div className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-teal-500"></div><span className="text-sm text-slate-600">Diastolic</span></div>
                        </div>
                    </div>

                    {/* Weight Chart */}
                    <div className="bg-white rounded-2xl p-6 shadow-sm">
                        <h3 className="text-lg font-semibold text-slate-800 mb-4">Weight Trend</h3>
                        {weightData.length === 0 ? (
                            <div className="h-[180px] flex items-center justify-center text-slate-400">
                                No weight data recorded yet
                            </div>
                        ) : (
                            <ResponsiveContainer width="100%" height={180}>
                                <AreaChart data={weightData}>
                                    <XAxis dataKey="date" axisLine={false} tickLine={false} />
                                    <YAxis axisLine={false} tickLine={false} domain={['auto', 'auto']} />
                                    <Tooltip />
                                    <Area type="monotone" dataKey="weight" stroke="#14b8a6" fill="url(#weightGradient)" strokeWidth={2} />
                                    <defs>
                                        <linearGradient id="weightGradient" x1="0" y1="0" x2="0" y2="1">
                                            <stop offset="0%" stopColor="#14b8a6" stopOpacity={0.3} />
                                            <stop offset="100%" stopColor="#14b8a6" stopOpacity={0} />
                                        </linearGradient>
                                    </defs>
                                </AreaChart>
                            </ResponsiveContainer>
                        )}
                    </div>
                </div>
            </div>

            {/* Recent Activity */}
            <div className="bg-white rounded-2xl p-6 shadow-sm">
                <h3 className="text-lg font-semibold text-slate-800 mb-4">Recent Activity</h3>
                <div className="space-y-3">
                    {recentLogs.length === 0 ? (
                        <p className="text-slate-400 text-center py-4">No recent activity. Vitals will appear here when logged from the app.</p>
                    ) : (
                        recentLogs.map((log: any, i: number) => (
                            <div key={i} className="flex items-center gap-4 p-3 bg-slate-50 rounded-xl">
                                <div className={`w-2 h-2 rounded-full ${log.status === 'warning' ? 'bg-red-500' : log.status === 'info' ? 'bg-blue-500' : 'bg-green-500'}`}></div>
                                <div className="flex-1">
                                    <p className="font-medium text-slate-700">{log.type}</p>
                                    <p className="text-sm text-slate-500">{log.date}</p>
                                </div>
                                <span className={`font-mono text-sm ${log.status === 'warning' ? 'text-red-600' : 'text-slate-600'}`}>{log.value}</span>
                            </div>
                        ))
                    )}
                </div>
            </div>
        </div>
    );
}

function QuickStat({ icon: Icon, label, value, color }: { icon: React.ComponentType<{ className?: string }>, label: string, value: string, color: string }) {
    const colorClasses: Record<string, string> = {
        pink: 'bg-pink-100 text-pink-600',
        teal: 'bg-teal-100 text-teal-600',
        purple: 'bg-purple-100 text-purple-600',
        red: 'bg-red-100 text-red-600',
    };
    return (
        <div className="p-4 bg-slate-50 rounded-xl">
            <div className={`w-10 h-10 rounded-lg ${colorClasses[color]} flex items-center justify-center mb-2`}>
                <Icon className="w-5 h-5" />
            </div>
            <p className="text-xs text-slate-500">{label}</p>
            <p className="font-semibold text-slate-800">{value}</p>
        </div>
    );
}
