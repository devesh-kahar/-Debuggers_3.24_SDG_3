const mongoose = require('mongoose');

const alertSchema = new mongoose.Schema({
    patientId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    providerId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    },
    type: {
        type: String,
        enum: ['critical', 'warning', 'info'],
        required: true
    },
    title: {
        type: String,
        required: true
    },
    message: {
        type: String,
        required: true
    },
    vitalId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Vital'
    },
    isRead: {
        type: Boolean,
        default: false
    },
    readAt: Date,
    createdAt: {
        type: Date,
        default: Date.now
    }
});

// Index for efficient queries
alertSchema.index({ providerId: 1, createdAt: -1 });
alertSchema.index({ patientId: 1, createdAt: -1 });
alertSchema.index({ providerId: 1, isRead: 1 });

module.exports = mongoose.model('Alert', alertSchema);
