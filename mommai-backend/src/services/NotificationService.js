const admin = require('firebase-admin');
const path = require('path');

// Service account should be placed in the project root
let serviceAccount;
try {
    // Attempt to load from the root of the project
    serviceAccount = require('../../firebase-service-account.json');
} catch (e) {
    console.warn('⚠️ Firebase service account not found. Push notifications will be disabled.');
}

if (serviceAccount) {
    try {
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
        console.log('✅ Firebase Admin initialized');
    } catch (e) {
        console.error('❌ Failed to initialize Firebase Admin:', e);
    }
}

/**
 * Send a push notification to a specific device
 * @param {string} token - FCM registration token
 * @param {string} title - Notification title
 * @param {string} body - Notification body
 * @param {object} data - Optional data payload
 */
const sendPushNotification = async (token, title, body, data = {}) => {
    if (!admin.apps.length) {
        console.warn('Firebase not initialized. Notification skipped.');
        return;
    }

    if (!token) {
        console.warn('No FCM token provided. Notification skipped.');
        return;
    }

    const message = {
        notification: {
            title,
            body
        },
        data: {
            ...data,
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
        },
        token: token
    };

    try {
        const response = await admin.messaging().send(message);
        console.log('Successfully sent push notification:', response);
        return response;
    } catch (error) {
        console.error('Error sending push notification:', error);
        throw error;
    }
};

module.exports = { sendPushNotification };
