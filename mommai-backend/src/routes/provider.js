const express = require('express');
const User = require('../models/User');
const Vital = require('../models/Vital');
const Pregnancy = require('../models/Pregnancy');
const Alert = require('../models/Alert');
const Message = require('../models/Message');
const { providerAuth } = require('../middleware/auth');

const router = express.Router();

// Get all patients for this provider
router.get('/patients', providerAuth, async (req, res) => {
    try {
        const { risk, search } = req.query;

        // Find patients assigned to this provider
        let query = { providerId: req.user._id, role: 'patient' };

        if (search) {
            query.name = { $regex: search, $options: 'i' };
        }

        const patients = await User.find(query).select('-password');

        // Enrich with pregnancy data
        const enrichedPatients = await Promise.all(patients.map(async (patient) => {
            const pregnancy = await Pregnancy.findOne({ userId: patient._id, isActive: true });
            const latestBP = await Vital.findOne({ userId: patient._id, type: 'bp' }).sort({ date: -1 });
            const latestWeight = await Vital.findOne({ userId: patient._id, type: 'weight' }).sort({ date: -1 });

            return {
                id: patient._id,
                name: patient.name,
                email: patient.email,
                phone: patient.phone,
                mode: patient.currentMode,
                week: pregnancy?.currentWeek,
                trimester: pregnancy?.trimester,
                riskScore: pregnancy?.riskScore || 0,
                riskLevel: pregnancy?.riskLevel || 'low',
                latestBP: latestBP ? `${latestBP.value}/${latestBP.secondaryValue}` : null,
                latestWeight: latestWeight?.value,
                lastVitalsDate: latestBP?.date || latestWeight?.date
            };
        }));

        // Filter by risk if specified
        let filtered = enrichedPatients;
        if (risk && risk !== 'all') {
            filtered = enrichedPatients.filter(p => p.riskLevel === risk);
        }

        // Sort by risk score (highest first)
        filtered.sort((a, b) => b.riskScore - a.riskScore);

        res.json({
            patients: filtered,
            total: filtered.length,
            highRiskCount: filtered.filter(p => p.riskLevel === 'high').length
        });
    } catch (error) {
        console.error('Get patients error:', error);
        res.status(500).json({ error: 'Failed to get patients' });
    }
});

// Get specific patient details
router.get('/patients/:id', providerAuth, async (req, res) => {
    try {
        const patient = await User.findOne({
            _id: req.params.id,
            providerId: req.user._id
        }).select('-password');

        if (!patient) {
            return res.status(404).json({ error: 'Patient not found' });
        }

        const pregnancy = await Pregnancy.findOne({ userId: patient._id, isActive: true });

        // Get vitals history (last 30 days)
        const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
        const vitals = await Vital.find({
            userId: patient._id,
            date: { $gte: thirtyDaysAgo }
        }).sort({ date: -1 });

        // Get recent alerts
        const alerts = await Alert.find({ patientId: patient._id })
            .sort({ createdAt: -1 })
            .limit(10);

        res.json({
            patient: {
                id: patient._id,
                name: patient.name,
                email: patient.email,
                age: patient.age,
                bloodType: patient.bloodType,
                medicalConditions: patient.medicalConditions,
                allergies: patient.allergies
            },
            pregnancy: pregnancy ? {
                currentWeek: pregnancy.currentWeek,
                trimester: pregnancy.trimester,
                dueDate: pregnancy.dueDate,
                daysRemaining: pregnancy.daysRemaining,
                riskScore: pregnancy.riskScore,
                riskLevel: pregnancy.riskLevel,
                riskFactors: pregnancy.riskFactors,
                babySizeComparison: pregnancy.babySizeComparison
            } : null,
            vitals: {
                bp: vitals.filter(v => v.type === 'bp'),
                weight: vitals.filter(v => v.type === 'weight'),
                bloodSugar: vitals.filter(v => v.type === 'bloodSugar')
            },
            alerts
        });
    } catch (error) {
        res.status(500).json({ error: 'Failed to get patient' });
    }
});

// Get provider's alerts
router.get('/alerts', providerAuth, async (req, res) => {
    try {
        const { type, unreadOnly } = req.query;

        let query = { providerId: req.user._id };
        if (type && type !== 'all') query.type = type;
        if (unreadOnly === 'true') query.isRead = false;

        const alerts = await Alert.find(query)
            .populate('patientId', 'name email')
            .sort({ createdAt: -1 })
            .limit(100);

        const unreadCount = await Alert.countDocuments({ providerId: req.user._id, isRead: false });

        res.json({
            alerts,
            unreadCount,
            criticalCount: alerts.filter(a => a.type === 'critical' && !a.isRead).length
        });
    } catch (error) {
        res.status(500).json({ error: 'Failed to get alerts' });
    }
});

// Mark alert as read
router.put('/alerts/:id/read', providerAuth, async (req, res) => {
    try {
        const alert = await Alert.findOneAndUpdate(
            { _id: req.params.id, providerId: req.user._id },
            { isRead: true, readAt: new Date() },
            { new: true }
        );

        if (!alert) {
            return res.status(404).json({ error: 'Alert not found' });
        }

        res.json({ message: 'Alert marked as read' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to update alert' });
    }
});

// Get messages with a patient
router.get('/messages/:patientId', providerAuth, async (req, res) => {
    try {
        const messages = await Message.find({
            $or: [
                { senderId: req.user._id, receiverId: req.params.patientId },
                { senderId: req.params.patientId, receiverId: req.user._id }
            ]
        }).sort({ createdAt: 1 }).limit(100);

        res.json({ messages });
    } catch (error) {
        res.status(500).json({ error: 'Failed to get messages' });
    }
});

// Send message to patient
router.post('/messages', providerAuth, async (req, res) => {
    try {
        const { patientId, content } = req.body;

        const message = new Message({
            senderId: req.user._id,
            receiverId: patientId,
            content,
            isAI: false
        });
        await message.save();

        // Emit via WebSocket
        const io = req.app.get('io');
        if (io) {
            io.to(`user-${patientId}`).emit('new-message', {
                from: req.user.name,
                content,
                createdAt: message.createdAt
            });
        }

        res.status(201).json({ message: 'Message sent', data: message });
    } catch (error) {
        res.status(500).json({ error: 'Failed to send message' });
    }
});

// Get dashboard stats
router.get('/dashboard', providerAuth, async (req, res) => {
    try {
        const totalPatients = await User.countDocuments({ providerId: req.user._id, role: 'patient' });

        // Get high risk count
        const pregnancies = await Pregnancy.find({ isActive: true })
            .populate('userId', 'providerId');
        const highRiskCount = pregnancies.filter(p =>
            p.userId?.providerId?.toString() === req.user._id.toString() && p.riskLevel === 'high'
        ).length;

        const unreadAlerts = await Alert.countDocuments({ providerId: req.user._id, isRead: false });
        const todayStart = new Date();
        todayStart.setHours(0, 0, 0, 0);

        // Recent alerts
        const recentAlerts = await Alert.find({ providerId: req.user._id })
            .populate('patientId', 'name')
            .sort({ createdAt: -1 })
            .limit(5);

        res.json({
            stats: {
                totalPatients,
                highRiskCount,
                unreadAlerts,
                appointmentsToday: 0 // Would come from appointments collection
            },
            recentAlerts
        });
    } catch (error) {
        res.status(500).json({ error: 'Failed to get dashboard data' });
    }
});

// ============ PUBLIC CLINIC ROUTES ============
// These routes provide access to clinic data

// Dashboard stats
router.get('/clinic/dashboard', async (req, res) => {
    try {
        const totalPatients = await User.countDocuments({ role: 'patient' });
        const pregnancies = await Pregnancy.find({ isActive: true });
        const highRiskCount = pregnancies.filter(p => p.riskLevel === 'high').length;
        const unreadAlerts = await Alert.countDocuments({ isRead: false });

        const recentAlerts = await Alert.find({})
            .populate('patientId', 'name email')
            .sort({ createdAt: -1 })
            .limit(5);

        res.json({
            stats: {
                totalPatients,
                highRiskCount,
                unreadAlerts,
                appointmentsToday: 0
            },
            recentAlerts
        });
    } catch (error) {
        console.error('Dashboard error:', error);
        res.status(500).json({ error: 'Failed to get dashboard data' });
    }
});

// Patient list
router.get('/clinic/patients', async (req, res) => {
    try {
        const { risk, search } = req.query;
        let query = { role: 'patient' };

        if (search) {
            query.name = { $regex: search, $options: 'i' };
        }

        const patients = await User.find(query).select('-password');

        const enrichedPatients = await Promise.all(patients.map(async (patient) => {
            const pregnancy = await Pregnancy.findOne({ userId: patient._id, isActive: true });
            const latestBP = await Vital.findOne({ userId: patient._id, type: 'bp' }).sort({ date: -1 });
            const latestWeight = await Vital.findOne({ userId: patient._id, type: 'weight' }).sort({ date: -1 });

            return {
                id: patient._id,
                name: patient.name,
                email: patient.email,
                phone: patient.phone,
                mode: patient.currentMode,
                week: pregnancy?.currentWeek,
                trimester: pregnancy?.trimester,
                dueDate: pregnancy?.dueDate,
                riskScore: pregnancy?.riskScore || 0,
                riskLevel: pregnancy?.riskLevel || 'low',
                riskFactors: pregnancy?.riskFactors || [],
                latestBP: latestBP ? `${latestBP.value}/${latestBP.secondaryValue}` : null,
                latestWeight: latestWeight?.value,
                lastVitalsDate: latestBP?.date || latestWeight?.date
            };
        }));

        let filtered = enrichedPatients;
        if (risk && risk !== 'all') {
            filtered = enrichedPatients.filter(p => p.riskLevel === risk);
        }
        filtered.sort((a, b) => b.riskScore - a.riskScore);

        res.json({
            patients: filtered,
            total: filtered.length,
            highRiskCount: filtered.filter(p => p.riskLevel === 'high').length
        });
    } catch (error) {
        console.error('Patients error:', error);
        res.status(500).json({ error: 'Failed to get patients' });
    }
});

// Patient details
router.get('/clinic/patients/:id', async (req, res) => {
    try {
        const patient = await User.findById(req.params.id).select('-password');

        if (!patient) {
            return res.status(404).json({ error: 'Patient not found' });
        }

        const pregnancy = await Pregnancy.findOne({ userId: patient._id, isActive: true });

        const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
        const vitals = await Vital.find({
            userId: patient._id,
            date: { $gte: thirtyDaysAgo }
        }).sort({ date: 1 });

        const alerts = await Alert.find({ patientId: patient._id })
            .sort({ createdAt: -1 })
            .limit(10);

        // Format BP data for chart
        const bpData = vitals
            .filter(v => v.type === 'bp')
            .map(v => ({
                date: new Date(v.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
                systolic: v.value,
                diastolic: v.secondaryValue
            }));

        // Format weight data for chart
        const weightData = vitals
            .filter(v => v.type === 'weight')
            .map(v => ({
                date: pregnancy ? `Week ${pregnancy.currentWeek}` : new Date(v.date).toLocaleDateString(),
                weight: v.value
            }));

        // Recent logs
        const recentLogs = vitals.slice(-10).reverse().map(v => ({
            date: new Date(v.date).toLocaleString(),
            type: v.type === 'bp' ? 'BP Reading' : v.type === 'weight' ? 'Weight' : 'Blood Sugar',
            value: v.type === 'bp' ? `${v.value}/${v.secondaryValue} mmHg` : `${v.value} ${v.type === 'weight' ? 'kg' : 'mg/dL'}`,
            status: v.type === 'bp' && (v.value > 140 || v.secondaryValue > 90) ? 'warning' : 'normal'
        }));

        res.json({
            patient: {
                id: patient._id,
                name: patient.name,
                email: patient.email,
                age: patient.age || 28,
                phone: patient.phone || 'Not provided',
                bloodType: patient.bloodType || 'Unknown',
                medicalConditions: patient.medicalConditions || [],
                allergies: patient.allergies || []
            },
            pregnancy: pregnancy ? {
                currentWeek: pregnancy.currentWeek,
                trimester: pregnancy.trimester,
                dueDate: pregnancy.dueDate,
                daysRemaining: pregnancy.daysRemaining,
                riskScore: pregnancy.riskScore,
                riskLevel: pregnancy.riskLevel,
                riskFactors: pregnancy.riskFactors || [],
                babySizeComparison: pregnancy.babySizeComparison
            } : null,
            bpData,
            weightData,
            recentLogs,
            alerts
        });
    } catch (error) {
        console.error('Patient detail error:', error);
        res.status(500).json({ error: 'Failed to get patient' });
    }
});

// Alerts
router.get('/clinic/alerts', async (req, res) => {
    try {
        const { type, unreadOnly } = req.query;

        let query = {};
        if (type && type !== 'all') query.type = type;
        if (unreadOnly === 'true') query.isRead = false;

        const alerts = await Alert.find(query)
            .populate('patientId', 'name email')
            .sort({ createdAt: -1 })
            .limit(100);

        const unreadCount = await Alert.countDocuments({ isRead: false });

        res.json({
            alerts,
            unreadCount,
            criticalCount: alerts.filter(a => a.type === 'critical' && !a.isRead).length
        });
    } catch (error) {
        console.error('Alerts error:', error);
        res.status(500).json({ error: 'Failed to get alerts' });
    }
});

// Mark alert as read
router.put('/clinic/alerts/:id/read', async (req, res) => {
    try {
        const alert = await Alert.findByIdAndUpdate(
            req.params.id,
            { isRead: true, readAt: new Date() },
            { new: true }
        );

        if (!alert) {
            return res.status(404).json({ error: 'Alert not found' });
        }

        res.json({ message: 'Alert marked as read', alert });
    } catch (error) {
        res.status(500).json({ error: 'Failed to update alert' });
    }
});

// Clinic Simulation for Demo
router.post('/clinic/simulate', async (req, res) => {
    try {
        const patients = await User.find({ role: 'patient' });
        if (patients.length === 0) return res.status(404).json({ error: 'No patients to simulate' });

        const randomPatient = patients[Math.floor(Math.random() * patients.length)];

        // Create a fake high BP alert
        const alert = new Alert({
            patientId: randomPatient._id,
            type: Math.random() > 0.5 ? 'critical' : 'warning',
            title: 'Anomalous BP Detected',
            message: `Simulated live data: ${randomPatient.name} recorded BP 145/95 mmHg.`,
            isRead: false
        });
        await alert.save();

        // Broadcast live update
        const io = req.app.get('io');
        if (io) {
            io.emit('new-alert', { alert, patient: randomPatient });
            io.emit('dashboard-update');
        }

        res.json({ message: 'Simulation triggered', patient: randomPatient.name });
    } catch (error) {
        res.status(500).json({ error: 'Simulation failed' });
    }
});

module.exports = router;
