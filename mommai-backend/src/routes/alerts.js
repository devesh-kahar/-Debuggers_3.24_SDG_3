const express = require('express');
const Alert = require('../models/Alert');
const { auth, providerAuth } = require('../middleware/auth');

const router = express.Router();

// Get user's own alerts
router.get('/', auth, async (req, res) => {
    try {
        const alerts = await Alert.find({ patientId: req.user._id })
            .sort({ createdAt: -1 })
            .limit(50);

        res.json({ alerts });
    } catch (error) {
        res.status(500).json({ error: 'Failed to get alerts' });
    }
});

// Mark alert as read
router.put('/:id/read', auth, async (req, res) => {
    try {
        const alert = await Alert.findOneAndUpdate(
            { _id: req.params.id, patientId: req.user._id },
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

module.exports = router;
