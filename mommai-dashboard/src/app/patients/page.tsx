'use client';

import { Search, Filter, Plus, ArrowUpDown, RefreshCw } from 'lucide-react';
import Link from 'next/link';
import { useState, useEffect } from 'react';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api';

export default function PatientsPage() {
    const [allPatients, setAllPatients] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [filter, setFilter] = useState('all');
    const [search, setSearch] = useState('');
    const [refreshing, setRefreshing] = useState(false);

    const fetchPatients = async () => {
        try {
            const res = await fetch(`${API_URL}/provider/clinic/patients?search=${search}&risk=${filter}`);
            if (!res.ok) throw new Error('Failed to fetch');
            const data = await res.json();
            setAllPatients(data.patients || []);
        } catch (e) {
            console.error('Failed to fetch patients', e);
        } finally {
            setLoading(false);
            setRefreshing(false);
        }
    };

    useEffect(() => {
        fetchPatients();
    }, [search, filter]);

    const handleRefresh = () => {
        setRefreshing(true);
        fetchPatients();
    };

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Patients</h1>
                    <p className="text-slate-500">{allPatients.length} patients enrolled</p>
                </div>
                <div className="flex gap-2">
                    <button
                        onClick={handleRefresh}
                        className={`p-2 bg-slate-100 text-slate-600 rounded-xl hover:bg-slate-200 transition-colors ${refreshing ? 'animate-spin' : ''}`}
                    >
                        <RefreshCw className="w-5 h-5" />
                    </button>
                    <button className="px-4 py-2 bg-pink-500 text-white rounded-xl hover:bg-pink-600 transition-colors flex items-center gap-2">
                        <Plus className="w-4 h-4" />
                        Add Patient
                    </button>
                </div>
            </div>

            {/* Filters */}
            <div className="bg-white rounded-2xl p-4 shadow-sm flex items-center gap-4">
                <div className="relative flex-1 max-w-md">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                    <input
                        type="text"
                        placeholder="Search patients..."
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        className="w-full pl-10 pr-4 py-2 bg-slate-100 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-pink-500/20"
                    />
                </div>
                <div className="flex items-center gap-2">
                    <Filter className="w-5 h-5 text-slate-400" />
                    <select
                        value={filter}
                        onChange={(e) => setFilter(e.target.value)}
                        className="px-4 py-2 bg-slate-100 rounded-xl text-sm focus:outline-none"
                    >
                        <option value="all">All Risks</option>
                        <option value="high">High Risk</option>
                        <option value="medium">Medium Risk</option>
                        <option value="low">Low Risk</option>
                    </select>
                </div>
            </div>

            {/* Table */}
            <div className="bg-white rounded-2xl shadow-sm overflow-hidden">
                <div className="overflow-x-auto">
                    {loading ? (
                        <div className="py-20 flex justify-center">
                            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-pink-500"></div>
                        </div>
                    ) : (
                        <table className="w-full">
                            <thead className="bg-slate-50">
                                <tr>
                                    <th className="text-left py-3 px-6 text-xs font-medium text-slate-500 uppercase">
                                        <button className="flex items-center gap-1 hover:text-slate-700">
                                            Patient <ArrowUpDown className="w-3 h-3" />
                                        </button>
                                    </th>
                                    <th className="text-left py-3 px-6 text-xs font-medium text-slate-500 uppercase">Week</th>
                                    <th className="text-left py-3 px-6 text-xs font-medium text-slate-500 uppercase">Trimester</th>
                                    <th className="text-left py-3 px-6 text-xs font-medium text-slate-500 uppercase">Risk</th>
                                    <th className="text-left py-3 px-6 text-xs font-medium text-slate-500 uppercase">Last BP</th>
                                    <th className="text-left py-3 px-6 text-xs font-medium text-slate-500 uppercase">Weight</th>
                                    <th className="text-left py-3 px-6 text-xs font-medium text-slate-500 uppercase">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {allPatients.length === 0 ? (
                                    <tr>
                                        <td colSpan={7} className="py-10 text-center text-slate-400">
                                            {search || filter !== 'all'
                                                ? 'No patients match your filters'
                                                : 'No patients registered yet. Register from the mobile app!'}
                                        </td>
                                    </tr>
                                ) : (
                                    allPatients.map((patient) => (
                                        <tr key={patient.id} className="border-t border-slate-100 hover:bg-slate-50">
                                            <td className="py-4 px-6">
                                                <div className="flex items-center gap-3">
                                                    <div className="w-10 h-10 rounded-full bg-gradient-to-br from-pink-400 to-pink-600 flex items-center justify-center text-white font-semibold text-sm">
                                                        {patient.name?.split(' ').map((n: any) => n[0]).join('') || '?'}
                                                    </div>
                                                    <div>
                                                        <p className="font-medium text-slate-800">{patient.name}</p>
                                                        <p className="text-xs text-slate-500">{patient.email}</p>
                                                    </div>
                                                </div>
                                            </td>
                                            <td className="py-4 px-6 text-slate-600">{patient.week ? `Week ${patient.week}` : 'N/A'}</td>
                                            <td className="py-4 px-6 text-slate-600">{patient.trimester ? `T${patient.trimester}` : 'N/A'}</td>
                                            <td className="py-4 px-6">
                                                <span className={`px-3 py-1 rounded-full text-xs font-medium ${patient.riskLevel === 'high' ? 'bg-red-100 text-red-600' :
                                                    patient.riskLevel === 'medium' ? 'bg-yellow-100 text-yellow-600' :
                                                        'bg-green-100 text-green-600'
                                                    }`}>
                                                    {patient.riskLevel?.charAt(0).toUpperCase() + patient.riskLevel?.slice(1)} ({patient.riskScore}%)
                                                </span>
                                            </td>
                                            <td className="py-4 px-6 text-slate-600 font-mono">{patient.latestBP || '---'}</td>
                                            <td className="py-4 px-6 text-slate-600">{patient.latestWeight ? `${patient.latestWeight} kg` : '---'}</td>
                                            <td className="py-4 px-6 flex gap-2">
                                                <Link href={`/patients/${patient.id}`} className="px-3 py-1 bg-pink-100 text-pink-600 rounded-lg text-sm font-medium hover:bg-pink-200">
                                                    View
                                                </Link>
                                                <button className="px-3 py-1 bg-teal-100 text-teal-600 rounded-lg text-sm font-medium hover:bg-teal-200">
                                                    Message
                                                </button>
                                            </td>
                                        </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    )}
                </div>
            </div>
        </div>
    );
}
