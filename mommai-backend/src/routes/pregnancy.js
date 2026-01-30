const express = require('express');
const Pregnancy = require('../models/Pregnancy');
const Vital = require('../models/Vital');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Get current pregnancy
router.get('/', auth, async (req, res) => {
    try {
        const pregnancy = await Pregnancy.findOne({ userId: req.user._id, isActive: true });

        if (!pregnancy) {
            return res.status(404).json({ error: 'No active pregnancy found' });
        }

        res.json({ pregnancy });
    } catch (error) {
        res.status(500).json({ error: 'Failed to get pregnancy data' });
    }
});

// Create/start new pregnancy
router.post('/', auth, async (req, res) => {
    try {
        const { lastMenstrualPeriod } = req.body;

        if (!lastMenstrualPeriod) {
            return res.status(400).json({ error: 'Last menstrual period date required' });
        }

        // Deactivate existing pregnancies
        await Pregnancy.updateMany({ userId: req.user._id }, { isActive: false });

        // Calculate due date (280 days from LMP)
        const lmp = new Date(lastMenstrualPeriod);
        const dueDate = new Date(lmp);
        dueDate.setDate(dueDate.getDate() + 280);

        const pregnancy = new Pregnancy({
            userId: req.user._id,
            lastMenstrualPeriod: lmp,
            dueDate
        });
        await pregnancy.save();

        // Update user mode
        req.user.currentMode = 'pregnancy';
        req.user.lastMenstrualPeriod = lmp;
        await req.user.save();

        res.status(201).json({ message: 'Pregnancy started', pregnancy });
    } catch (error) {
        res.status(500).json({ error: 'Failed to start pregnancy' });
    }
});

// Log fetal movement (kick count)
router.post('/kicks', auth, async (req, res) => {
    try {
        const { count, duration } = req.body; // duration in minutes

        const pregnancy = await Pregnancy.findOne({ userId: req.user._id, isActive: true });
        if (!pregnancy) {
            return res.status(404).json({ error: 'No active pregnancy' });
        }

        // Store as vital for tracking
        const vital = new Vital({
            userId: req.user._id,
            type: 'fetalMovement',
            value: count,
            secondaryValue: duration,
            notes: `${count} kicks in ${duration} minutes`
        });
        await vital.save();

        // Check if count is concerning (less than 10 in 2 hours)
        const kicksPerHour = (count / duration) * 60;
        let warning = null;

        if (kicksPerHour < 5) {
            warning = 'Kick count is lower than expected. Please monitor closely and contact your provider if concerned.';

            // Add to risk factors
            if (!pregnancy.riskFactors.find(r => r.factor.includes('fetal movement'))) {
                pregnancy.riskFactors.push({
                    factor: 'Decreased fetal movement',
                    severity: kicksPerHour < 3 ? 'high' : 'medium'
                });
                pregnancy.riskScore = Math.min(pregnancy.riskScore + 15, 100);
                await pregnancy.save();
            }
        }

        res.json({
            message: 'Kick count logged',
            kicksPerHour: kicksPerHour.toFixed(1),
            warning
        });
    } catch (error) {
        res.status(500).json({ error: 'Failed to log kicks' });
    }
});

// Log contraction
router.post('/contractions', auth, async (req, res) => {
    try {
        const { duration, intensity } = req.body; // duration in seconds

        const vital = new Vital({
            userId: req.user._id,
            type: 'contraction',
            value: duration,
            secondaryValue: intensity, // 1-10 scale
            notes: `Contraction: ${duration}s, intensity ${intensity}/10`
        });
        await vital.save();

        // Get recent contractions to check pattern
        const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
        const recentContractions = await Vital.find({
            userId: req.user._id,
            type: 'contraction',
            date: { $gte: oneHourAgo }
        }).sort({ date: 1 });

        let laborWarning = null;

        // Check 5-1-1 rule (contractions 5 min apart, lasting 1 min, for 1 hour)
        if (recentContractions.length >= 10) {
            const avgDuration = recentContractions.reduce((a, c) => a + c.value, 0) / recentContractions.length;

            // Calculate average time between contractions
            let totalInterval = 0;
            for (let i = 1; i < recentContractions.length; i++) {
                totalInterval += new Date(recentContractions[i].date) - new Date(recentContractions[i - 1].date);
            }
            const avgInterval = totalInterval / (recentContractions.length - 1) / 1000 / 60; // in minutes

            if (avgDuration >= 50 && avgInterval <= 5) {
                laborWarning = '⚠️ Your contraction pattern (5-1-1 rule) suggests active labor may be starting. Consider going to the hospital.';
            }
        }

        res.json({
            message: 'Contraction logged',
            contractionsInLastHour: recentContractions.length,
            laborWarning
        });
    } catch (error) {
        res.status(500).json({ error: 'Failed to log contraction' });
    }
});

// Get pregnancy stats
router.get('/stats', auth, async (req, res) => {
    try {
        const pregnancy = await Pregnancy.findOne({ userId: req.user._id, isActive: true });
        if (!pregnancy) {
            return res.status(404).json({ error: 'No active pregnancy' });
        }

        // Get vital counts
        const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
        const bpCount = await Vital.countDocuments({ userId: req.user._id, type: 'bp', date: { $gte: weekAgo } });
        const weightCount = await Vital.countDocuments({ userId: req.user._id, type: 'weight', date: { $gte: weekAgo } });
        const kickCount = await Vital.countDocuments({ userId: req.user._id, type: 'fetalMovement', date: { $gte: weekAgo } });

        res.json({
            currentWeek: pregnancy.currentWeek,
            trimester: pregnancy.trimester,
            daysRemaining: pregnancy.daysRemaining,
            dueDate: pregnancy.dueDate,
            babySizeComparison: pregnancy.babySizeComparison,
            riskScore: pregnancy.riskScore,
            riskLevel: pregnancy.riskLevel,
            riskFactors: pregnancy.riskFactors,
            vitalsThisWeek: { bp: bpCount, weight: weightCount, kicks: kickCount }
        });
    } catch (error) {
        res.status(500).json({ error: 'Failed to get stats' });
    }
});

module.exports = router;
