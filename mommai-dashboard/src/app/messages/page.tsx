'use client';

import { Search, Send, Paperclip, MoreVertical } from 'lucide-react';
import { useState } from 'react';

const conversations = [
    { id: 1, name: 'Emily Rodriguez', lastMessage: 'Thank you, Doctor. I will monitor my BP.', time: '10 min ago', unread: true, avatar: 'ER' },
    { id: 2, name: 'Jennifer Lee', lastMessage: 'When should I come for the next checkup?', time: '1 hour ago', unread: true, avatar: 'JL' },
    { id: 3, name: 'Sarah Chen', lastMessage: 'The new medication is working well.', time: '3 hours ago', unread: false, avatar: 'SC' },
    { id: 4, name: 'Maria Garcia', lastMessage: 'Got it, thank you!', time: 'Yesterday', unread: false, avatar: 'MG' },
];

const messages = [
    { id: 1, sender: 'patient', text: 'Hi Dr. Johnson, my BP reading this morning was 145/95. Is this concerning?', time: '10:15 AM' },
    { id: 2, sender: 'doctor', text: 'Hello Emily. Yes, that reading is elevated. Have you been experiencing any headaches or vision changes?', time: '10:18 AM' },
    { id: 3, sender: 'patient', text: 'I had a mild headache yesterday evening but it went away after resting.', time: '10:20 AM' },
    { id: 4, sender: 'doctor', text: 'I recommend you rest, stay hydrated, and avoid salty foods. Please monitor your BP every 4 hours and report any readings above 140/90 immediately. If you experience severe headaches, vision changes, or swelling, please come to the ER right away.', time: '10:25 AM' },
    { id: 5, sender: 'patient', text: 'Thank you, Doctor. I will monitor my BP and let you know.', time: '10:28 AM' },
];

export default function MessagesPage() {
    const [selectedConvo, setSelectedConvo] = useState(conversations[0]);
    const [newMessage, setNewMessage] = useState('');

    return (
        <div className="h-[calc(100vh-8rem)] flex bg-white rounded-2xl shadow-sm overflow-hidden">
            {/* Conversations List */}
            <div className="w-80 border-r border-slate-200 flex flex-col">
                <div className="p-4 border-b border-slate-200">
                    <div className="relative">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                        <input
                            type="text"
                            placeholder="Search messages..."
                            className="w-full pl-10 pr-4 py-2 bg-slate-100 rounded-xl text-sm focus:outline-none"
                        />
                    </div>
                </div>
                <div className="flex-1 overflow-y-auto">
                    {conversations.map((convo) => (
                        <div
                            key={convo.id}
                            onClick={() => setSelectedConvo(convo)}
                            className={`p-4 cursor-pointer hover:bg-slate-50 ${selectedConvo.id === convo.id ? 'bg-pink-50 border-r-2 border-pink-500' : ''}`}
                        >
                            <div className="flex items-center gap-3">
                                <div className="w-12 h-12 rounded-full bg-gradient-to-br from-pink-400 to-pink-600 flex items-center justify-center text-white font-semibold">
                                    {convo.avatar}
                                </div>
                                <div className="flex-1 min-w-0">
                                    <div className="flex items-center justify-between">
                                        <p className="font-semibold text-slate-800">{convo.name}</p>
                                        <span className="text-xs text-slate-400">{convo.time}</span>
                                    </div>
                                    <p className="text-sm text-slate-500 truncate">{convo.lastMessage}</p>
                                </div>
                                {convo.unread && <div className="w-2 h-2 rounded-full bg-pink-500"></div>}
                            </div>
                        </div>
                    ))}
                </div>
            </div>

            {/* Chat Area */}
            <div className="flex-1 flex flex-col">
                {/* Chat Header */}
                <div className="p-4 border-b border-slate-200 flex items-center justify-between">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-gradient-to-br from-pink-400 to-pink-600 flex items-center justify-center text-white font-semibold">
                            {selectedConvo.avatar}
                        </div>
                        <div>
                            <p className="font-semibold text-slate-800">{selectedConvo.name}</p>
                            <p className="text-xs text-green-500">Online</p>
                        </div>
                    </div>
                    <button className="p-2 hover:bg-slate-100 rounded-xl">
                        <MoreVertical className="w-5 h-5 text-slate-400" />
                    </button>
                </div>

                {/* Messages */}
                <div className="flex-1 overflow-y-auto p-4 space-y-4">
                    {messages.map((msg) => (
                        <div key={msg.id} className={`flex ${msg.sender === 'doctor' ? 'justify-end' : 'justify-start'}`}>
                            <div className={`max-w-[70%] p-4 rounded-2xl ${msg.sender === 'doctor' ? 'bg-pink-500 text-white rounded-br-none' : 'bg-slate-100 text-slate-800 rounded-bl-none'}`}>
                                <p className="text-sm">{msg.text}</p>
                                <p className={`text-xs mt-1 ${msg.sender === 'doctor' ? 'text-pink-200' : 'text-slate-400'}`}>{msg.time}</p>
                            </div>
                        </div>
                    ))}
                </div>

                {/* Input */}
                <div className="p-4 border-t border-slate-200">
                    <div className="flex items-center gap-2">
                        <button className="p-2 hover:bg-slate-100 rounded-xl">
                            <Paperclip className="w-5 h-5 text-slate-400" />
                        </button>
                        <input
                            type="text"
                            placeholder="Type a message..."
                            value={newMessage}
                            onChange={(e) => setNewMessage(e.target.value)}
                            className="flex-1 px-4 py-3 bg-slate-100 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-pink-500/20"
                        />
                        <button className="p-3 bg-pink-500 text-white rounded-xl hover:bg-pink-600">
                            <Send className="w-5 h-5" />
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
}
