const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Pregnancy = require('../models/Pregnancy');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Register new user
router.post('/register', async (req, res) => {
    try {
        const { email, password, name, role = 'patient' } = req.body;

        // Check if user exists
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ error: 'Email already registered' });
        }

        // Create user
        const user = new User({ email, password, name, role });
        await user.save();

        // Generate token
        const token = jwt.sign(
            { userId: user._id },
            process.env.JWT_SECRET || 'fallback-secret',
            { expiresIn: '30d' }
        );

        res.status(201).json({
            message: 'User registered successfully',
            token,
            user: {
                id: user._id,
                email: user.email,
                name: user.name,
                role: user.role
            }
        });
    } catch (error) {
        console.error('Register error:', error);
        res.status(500).json({ error: 'Registration failed' });
    }
});

// Login
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        // Find user
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        // Check password
        const isMatch = await user.comparePassword(password);
        if (!isMatch) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        // Generate token
        const token = jwt.sign(
            { userId: user._id },
            process.env.JWT_SECRET || 'fallback-secret',
            { expiresIn: '30d' }
        );

        res.json({
            message: 'Login successful',
            token,
            user: {
                id: user._id,
                email: user.email,
                name: user.name,
                role: user.role,
                currentMode: user.currentMode
            }
        });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ error: 'Login failed' });
    }
});

// Get current user profile
router.get('/me', auth, async (req, res) => {
    try {
        const user = req.user.toJSON();
        delete user.password;

        // If in pregnancy mode, get pregnancy data
        let pregnancy = null;
        if (user.currentMode === 'pregnancy') {
            pregnancy = await Pregnancy.findOne({ userId: user._id, isActive: true });
        }

        res.json({ user, pregnancy });
    } catch (error) {
        res.status(500).json({ error: 'Failed to get profile' });
    }
});

// Update profile
router.put('/me', auth, async (req, res) => {
    try {
        const updates = req.body;
        const allowedUpdates = ['name', 'age', 'height', 'weight', 'bloodType', 'currentMode',
            'averageCycleLength', 'averagePeriodLength', 'lastMenstrualPeriod',
            'medicalConditions', 'allergies', 'medications', 'notificationsEnabled', 'fcmToken'];

        Object.keys(updates).forEach(key => {
            if (allowedUpdates.includes(key)) {
                req.user[key] = updates[key];
            }
        });

        await req.user.save();

        const user = req.user.toJSON();
        delete user.password;
        res.json({ message: 'Profile updated', user });
    } catch (error) {
        res.status(500).json({ error: 'Failed to update profile' });
    }
});

// Switch mode (fertility/pregnancy)
router.post('/mode', auth, async (req, res) => {
    try {
        const { mode, lastMenstrualPeriod } = req.body;

        if (!['fertility', 'pregnancy'].includes(mode)) {
            return res.status(400).json({ error: 'Invalid mode' });
        }

        req.user.currentMode = mode;
        await req.user.save();

        // If switching to pregnancy, create pregnancy record
        if (mode === 'pregnancy' && lastMenstrualPeriod) {
            const lmp = new Date(lastMenstrualPeriod);
            const dueDate = new Date(lmp);
            dueDate.setDate(dueDate.getDate() + 280); // 40 weeks

            // Deactivate any existing pregnancy
            await Pregnancy.updateMany({ userId: req.user._id }, { isActive: false });

            // Create new pregnancy
            const pregnancy = new Pregnancy({
                userId: req.user._id,
                lastMenstrualPeriod: lmp,
                dueDate
            });
            await pregnancy.save();

            return res.json({
                message: 'Switched to pregnancy mode',
                mode,
                pregnancy
            });
        }

        res.json({ message: `Switched to ${mode} mode`, mode });
    } catch (error) {
        res.status(500).json({ error: 'Failed to switch mode' });
    }
});

// Update FCM Token
router.post('/update-fcm', auth, async (req, res) => {
    try {
        const { fcmToken } = req.body;
        if (!fcmToken) {
            return res.status(400).json({ error: 'FCM token is required' });
        }

        req.user.fcmToken = fcmToken;
        await req.user.save();

        res.json({ message: 'FCM token updated successfully' });
    } catch (error) {
        console.error('Update FCM error:', error);
        res.status(500).json({ error: 'Failed to update FCM token' });
    }
});

module.exports = router;
