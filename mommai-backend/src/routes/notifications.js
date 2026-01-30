const express = require('express');
const admin = require('firebase-admin');
const router = express.Router();

// Initialize Firebase Admin if not already done
// Note: You need to download your service account key from Firebase Console
// and save it as 'firebase-service-account.json' in the backend root

let firebaseInitialized = false;

const initFirebase = () => {
    if (firebaseInitialized) return true;

    try {
        // Check if already initialized
        if (admin.apps.length > 0) {
            firebaseInitialized = true;
            return true;
        }

        // Try to initialize with service account
        const serviceAccount = require('../../firebase-service-account.json');
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
        firebaseInitialized = true;
        console.log('Firebase Admin initialized successfully');
        return true;
    } catch (error) {
        console.warn('Firebase Admin not initialized:', error.message);
        console.warn('To enable push notifications, add firebase-service-account.json to backend root');
        return false;
    }
};

// Send notification to a specific device
router.post('/send', async (req, res) => {
    try {
        if (!initFirebase()) {
            return res.status(503).json({
                error: 'Firebase not configured',
                message: 'Add firebase-service-account.json to enable push notifications'
            });
        }

        const { token, title, body, data } = req.body;

        if (!token || !title || !body) {
            return res.status(400).json({ error: 'token, title, and body are required' });
        }

        const message = {
            notification: {
                title,
                body
            },
            data: data || {},
            token
        };

        const response = await admin.messaging().send(message);
        console.log('Notification sent:', response);

        res.json({ success: true, messageId: response });
    } catch (error) {
        console.error('Error sending notification:', error);
        res.status(500).json({ error: 'Failed to send notification', details: error.message });
    }
});

// Send notification to multiple devices
router.post('/send-multiple', async (req, res) => {
    try {
        if (!initFirebase()) {
            return res.status(503).json({ error: 'Firebase not configured' });
        }

        const { tokens, title, body, data } = req.body;

        if (!tokens || !Array.isArray(tokens) || tokens.length === 0) {
            return res.status(400).json({ error: 'tokens array is required' });
        }

        const message = {
            notification: { title, body },
            data: data || {},
            tokens
        };

        const response = await admin.messaging().sendEachForMulticast(message);

        res.json({
            success: true,
            successCount: response.successCount,
            failureCount: response.failureCount
        });
    } catch (error) {
        console.error('Error sending notifications:', error);
        res.status(500).json({ error: 'Failed to send notifications' });
    }
});

// Send notification to a topic
router.post('/send-topic', async (req, res) => {
    try {
        if (!initFirebase()) {
            return res.status(503).json({ error: 'Firebase not configured' });
        }

        const { topic, title, body, data } = req.body;

        if (!topic || !title || !body) {
            return res.status(400).json({ error: 'topic, title, and body are required' });
        }

        const message = {
            notification: { title, body },
            data: data || {},
            topic
        };

        const response = await admin.messaging().send(message);

        res.json({ success: true, messageId: response });
    } catch (error) {
        console.error('Error sending topic notification:', error);
        res.status(500).json({ error: 'Failed to send notification' });
    }
});

// Subscribe device to topic
router.post('/subscribe', async (req, res) => {
    try {
        if (!initFirebase()) {
            return res.status(503).json({ error: 'Firebase not configured' });
        }

        const { token, topic } = req.body;

        if (!token || !topic) {
            return res.status(400).json({ error: 'token and topic are required' });
        }

        await admin.messaging().subscribeToTopic([token], topic);

        res.json({ success: true, message: `Subscribed to ${topic}` });
    } catch (error) {
        console.error('Error subscribing to topic:', error);
        res.status(500).json({ error: 'Failed to subscribe' });
    }
});

// Unsubscribe device from topic
router.post('/unsubscribe', async (req, res) => {
    try {
        if (!initFirebase()) {
            return res.status(503).json({ error: 'Firebase not configured' });
        }

        const { token, topic } = req.body;

        if (!token || !topic) {
            return res.status(400).json({ error: 'token and topic are required' });
        }

        await admin.messaging().unsubscribeFromTopic([token], topic);

        res.json({ success: true, message: `Unsubscribed from ${topic}` });
    } catch (error) {
        console.error('Error unsubscribing from topic:', error);
        res.status(500).json({ error: 'Failed to unsubscribe' });
    }
});

// Send alert to all pregnancy users (example use case)
router.post('/alert-pregnancy', async (req, res) => {
    try {
        if (!initFirebase()) {
            return res.status(503).json({ error: 'Firebase not configured' });
        }

        const { title, body, severity } = req.body;

        const message = {
            notification: {
                title: title || '⚠️ Health Alert',
                body: body || 'Please check your MomAI app for important updates'
            },
            data: {
                type: 'health_alert',
                severity: severity || 'medium'
            },
            topic: 'pregnancy_users'
        };

        const response = await admin.messaging().send(message);

        res.json({ success: true, messageId: response });
    } catch (error) {
        console.error('Error sending pregnancy alert:', error);
        res.status(500).json({ error: 'Failed to send alert' });
    }
});

module.exports = router;
