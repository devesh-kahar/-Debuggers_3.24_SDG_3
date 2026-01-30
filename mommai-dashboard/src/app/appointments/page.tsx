'use client';

import { ChevronLeft, ChevronRight, Plus, Clock, MapPin, Video } from 'lucide-react';
import { useState } from 'react';

const appointments = [
    { id: 1, patient: 'Emily Rodriguez', time: '9:00 AM', duration: '30 min', type: 'Urgent Follow-up', status: 'upcoming', avatar: 'ER' },
    { id: 2, patient: 'Sarah Chen', time: '10:00 AM', duration: '20 min', type: 'Routine Checkup', status: 'upcoming', avatar: 'SC' },
    { id: 3, patient: 'Lisa Thompson', time: '11:00 AM', duration: '30 min', type: 'Ultrasound', status: 'upcoming', avatar: 'LT' },
    { id: 4, patient: 'Maria Garcia', time: '2:00 PM', duration: '20 min', type: 'Blood Work Review', status: 'upcoming', avatar: 'MG' },
    { id: 5, patient: 'Jennifer Lee', time: '3:30 PM', duration: '30 min', type: 'High Risk Consultation', status: 'upcoming', avatar: 'JL' },
];

const daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

export default function AppointmentsPage() {
    const [currentDate] = useState(new Date());
    const currentDay = currentDate.getDate();

    // Generate week days
    const weekDays = Array.from({ length: 7 }, (_, i) => {
        const date = new Date(currentDate);
        date.setDate(currentDay - currentDate.getDay() + i);
        return { day: daysOfWeek[i], date: date.getDate(), isToday: date.getDate() === currentDay };
    });

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Appointments</h1>
                    <p className="text-slate-500">Thursday, January 30, 2026</p>
                </div>
                <button className="px-4 py-2 bg-pink-500 text-white rounded-xl hover:bg-pink-600 transition-colors flex items-center gap-2">
                    <Plus className="w-4 h-4" />
                    New Appointment
                </button>
            </div>

            {/* Calendar Week View */}
            <div className="bg-white rounded-2xl p-6 shadow-sm">
                <div className="flex items-center justify-between mb-6">
                    <button className="p-2 hover:bg-slate-100 rounded-xl">
                        <ChevronLeft className="w-5 h-5 text-slate-600" />
                    </button>
                    <h3 className="font-semibold text-slate-800">January 2026</h3>
                    <button className="p-2 hover:bg-slate-100 rounded-xl">
                        <ChevronRight className="w-5 h-5 text-slate-600" />
                    </button>
                </div>
                <div className="grid grid-cols-7 gap-2">
                    {weekDays.map((day, i) => (
                        <div
                            key={i}
                            className={`p-4 rounded-xl text-center cursor-pointer transition-colors ${day.isToday ? 'bg-pink-500 text-white' : 'hover:bg-slate-100'}`}
                        >
                            <p className={`text-xs ${day.isToday ? 'text-pink-100' : 'text-slate-400'}`}>{day.day}</p>
                            <p className={`text-lg font-semibold ${day.isToday ? 'text-white' : 'text-slate-800'}`}>{day.date}</p>
                        </div>
                    ))}
                </div>
            </div>

            {/* Today's Appointments */}
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Schedule */}
                <div className="lg:col-span-2 bg-white rounded-2xl p-6 shadow-sm">
                    <h3 className="text-lg font-semibold text-slate-800 mb-4">Today's Schedule</h3>
                    <div className="space-y-3">
                        {appointments.map((apt) => (
                            <div key={apt.id} className="flex items-center gap-4 p-4 bg-slate-50 rounded-xl hover:bg-slate-100 transition-colors cursor-pointer">
                                <div className="w-12 h-12 rounded-full bg-gradient-to-br from-pink-400 to-pink-600 flex items-center justify-center text-white font-semibold">
                                    {apt.avatar}
                                </div>
                                <div className="flex-1">
                                    <p className="font-semibold text-slate-800">{apt.patient}</p>
                                    <p className="text-sm text-slate-500">{apt.type}</p>
                                </div>
                                <div className="text-right">
                                    <p className="font-medium text-slate-800">{apt.time}</p>
                                    <p className="text-sm text-slate-400">{apt.duration}</p>
                                </div>
                                <div className="flex gap-2">
                                    <button className="p-2 bg-teal-100 text-teal-600 rounded-lg hover:bg-teal-200">
                                        <Video className="w-4 h-4" />
                                    </button>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>

                {/* Summary */}
                <div className="space-y-6">
                    <div className="bg-white rounded-2xl p-6 shadow-sm">
                        <h3 className="text-lg font-semibold text-slate-800 mb-4">Today's Summary</h3>
                        <div className="space-y-4">
                            <div className="flex items-center justify-between">
                                <span className="text-slate-500">Total Appointments</span>
                                <span className="font-semibold text-slate-800">5</span>
                            </div>
                            <div className="flex items-center justify-between">
                                <span className="text-slate-500">Completed</span>
                                <span className="font-semibold text-green-600">0</span>
                            </div>
                            <div className="flex items-center justify-between">
                                <span className="text-slate-500">Upcoming</span>
                                <span className="font-semibold text-pink-600">5</span>
                            </div>
                            <div className="flex items-center justify-between">
                                <span className="text-slate-500">High Risk Patients</span>
                                <span className="font-semibold text-red-600">2</span>
                            </div>
                        </div>
                    </div>

                    <div className="bg-gradient-to-br from-pink-500 to-pink-600 rounded-2xl p-6 text-white">
                        <Clock className="w-8 h-8 mb-3" />
                        <h3 className="font-semibold text-lg">Next Appointment</h3>
                        <p className="text-pink-100 mt-1">Emily Rodriguez</p>
                        <p className="text-2xl font-bold mt-2">9:00 AM</p>
                        <p className="text-pink-100 text-sm">Urgent Follow-up • 30 min</p>
                    </div>
                </div>
            </div>
        </div>
    );
}
