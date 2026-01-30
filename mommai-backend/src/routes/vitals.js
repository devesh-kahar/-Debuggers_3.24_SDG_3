const express = require('express');
const Vital = require('../models/Vital');
const Pregnancy = require('../models/Pregnancy');
const Alert = require('../models/Alert');
const { auth } = require('../middleware/auth');
const { sendPushNotification } = require('../services/NotificationService');

const router = express.Router();

// Log a new vital
router.post('/', auth, async (req, res) => {
    try {
        const { type, value, secondaryValue, notes } = req.body;

        const vital = new Vital({
            userId: req.user._id,
            type,
            value,
            secondaryValue,
            notes
        });
        await vital.save();

        // Check thresholds and create alerts if needed
        let alert = null;
        let riskScore = null;

        if (type === 'bp') {
            const bpRisk = Vital.getBPRiskLevel(value, secondaryValue || 80);

            if (bpRisk === 'high' || bpRisk === 'severe') {
                alert = new Alert({
                    patientId: req.user._id,
                    providerId: req.user.providerId,
                    type: bpRisk === 'severe' ? 'critical' : 'warning',
                    title: 'High Blood Pressure Alert',
                    message: `BP reading: ${value}/${secondaryValue} mmHg - ${bpRisk === 'severe' ? 'Severely elevated' : 'Above normal threshold'}`,
                    vitalId: vital._id
                });
                await alert.save();

                // Emit real-time alert via WebSocket
                const io = req.app.get('io');
                if (io && req.user.providerId) {
                    io.to(`user-${req.user.providerId}`).emit('new-alert', {
                        alert,
                        patient: { id: req.user._id, name: req.user.name }
                    });
                }

                // Send Push Notification to Patient
                if (req.user.fcmToken) {
                    await sendPushNotification(
                        req.user.fcmToken,
                        '⚠️ High BP Alert',
                        `Your reading of ${value}/${secondaryValue} is high. Please rest and re-check, or contact your doctor.`,
                        { type: 'bp_alert', value: value.toString() }
                    );
                }
            }

            // Update pregnancy risk score if in pregnancy mode
            if (req.user.currentMode === 'pregnancy') {
                riskScore = await updatePregnancyRisk(req.user._id, type, value, secondaryValue);
            }
        }

        if (type === 'bloodSugar' && value > 140) {
            alert = new Alert({
                patientId: req.user._id,
                providerId: req.user.providerId,
                type: value > 180 ? 'critical' : 'warning',
                title: 'Elevated Blood Sugar',
                message: `Blood sugar reading: ${value} mg/dL`,
                vitalId: vital._id
            });
            await alert.save();
        }

        res.status(201).json({
            message: 'Vital logged successfully',
            vital,
            alert: alert ? { type: alert.type, message: alert.message } : null,
            riskScore
        });
    } catch (error) {
        console.error('Log vital error:', error);
        res.status(500).json({ error: 'Failed to log vital' });
    }
});

// Get vitals history
router.get('/', auth, async (req, res) => {
    try {
        const { type, days = 30 } = req.query;

        const query = { userId: req.user._id };
        if (type) query.type = type;

        const startDate = new Date();
        startDate.setDate(startDate.getDate() - parseInt(days));
        query.date = { $gte: startDate };

        const vitals = await Vital.find(query).sort({ date: -1 }).limit(100);

        res.json({ vitals });
    } catch (error) {
        res.status(500).json({ error: 'Failed to get vitals' });
    }
});

// Get latest vitals
router.get('/latest', auth, async (req, res) => {
    try {
        const types = ['bp', 'weight', 'bloodSugar', 'temperature'];
        const latest = {};

        for (const type of types) {
            const vital = await Vital.findOne({ userId: req.user._id, type }).sort({ date: -1 });
            if (vital) latest[type] = vital;
        }

        res.json({ latest });
    } catch (error) {
        res.status(500).json({ error: 'Failed to get latest vitals' });
    }
});

// Helper function to update pregnancy risk score
async function updatePregnancyRisk(userId, vitalType, value, secondaryValue) {
    const pregnancy = await Pregnancy.findOne({ userId, isActive: true });
    if (!pregnancy) return null;

    let score = 10; // Base score
    const factors = [];

    // Get recent vitals
    const recentBP = await Vital.findOne({ userId, type: 'bp' }).sort({ date: -1 });
    const recentSugar = await Vital.findOne({ userId, type: 'bloodSugar' }).sort({ date: -1 });

    // Check BP
    if (recentBP) {
        if (recentBP.value >= 160 || (recentBP.secondaryValue && recentBP.secondaryValue >= 100)) {
            score += 40;
            factors.push({ factor: 'Severely elevated BP', severity: 'high' });
        } else if (recentBP.value >= 140 || (recentBP.secondaryValue && recentBP.secondaryValue >= 90)) {
            score += 30;
            factors.push({ factor: 'High blood pressure', severity: 'high' });
        } else if (recentBP.value >= 120 || (recentBP.secondaryValue && recentBP.secondaryValue >= 80)) {
            score += 15;
            factors.push({ factor: 'Elevated blood pressure', severity: 'medium' });
        }
    }

    // Check blood sugar
    if (recentSugar) {
        if (recentSugar.value > 180) {
            score += 25;
            factors.push({ factor: 'High blood sugar', severity: 'high' });
        } else if (recentSugar.value > 140) {
            score += 15;
            factors.push({ factor: 'Elevated blood sugar', severity: 'medium' });
        }
    }

    // Cap at 100
    score = Math.min(score, 100);

    // Determine risk level
    let riskLevel = 'low';
    if (score > 60) riskLevel = 'high';
    else if (score > 30) riskLevel = 'medium';

    // Update pregnancy
    pregnancy.riskScore = score;
    pregnancy.riskLevel = riskLevel;
    pregnancy.riskFactors = factors;
    await pregnancy.save();

    return score;
}

module.exports = router;
