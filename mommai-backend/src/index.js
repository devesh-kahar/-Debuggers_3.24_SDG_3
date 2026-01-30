const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const vitalsRoutes = require('./routes/vitals');
const pregnancyRoutes = require('./routes/pregnancy');
const alertsRoutes = require('./routes/alerts');
const chatRoutes = require('./routes/chat');
const providerRoutes = require('./routes/provider');
const notificationsRoutes = require('./routes/notifications');

const app = express();
const server = http.createServer(app);

// Socket.io setup for real-time updates
const io = new Server(server, {
    cors: {
        origin: ['http://localhost:3000', 'http://localhost:8080'],
        methods: ['GET', 'POST']
    }
});

// Make io accessible to routes
app.set('io', io);

// Middleware
app.use(cors());
app.use(express.json());

// Request logging
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    next();
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/vitals', vitalsRoutes);
app.use('/api/pregnancy', pregnancyRoutes);
app.use('/api/alerts', alertsRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/provider', providerRoutes);
app.use('/api/notifications', notificationsRoutes);

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Socket.io connection handling
io.on('connection', (socket) => {
    console.log('Client connected:', socket.id);

    socket.on('join-room', (userId) => {
        socket.join(`user-${userId}`);
        console.log(`User ${userId} joined their room`);
    });

    socket.on('disconnect', () => {
        console.log('Client disconnected:', socket.id);
    });
});

// Connect to MongoDB and start server
const PORT = process.env.PORT || 5000;

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/mommai')
    .then(() => {
        console.log('✅ Connected to MongoDB');
        server.listen(PORT, () => {
            console.log(`🚀 Server running on http://localhost:${PORT}`);
            console.log(`📡 WebSocket ready for connections`);
        });
    })
    .catch((err) => {
        console.error('❌ MongoDB connection error:', err);
        // Start server anyway for demo purposes
        server.listen(PORT, () => {
            console.log(`🚀 Server running on http://localhost:${PORT} (No DB)`);
        });
    });

module.exports = { app, io };
