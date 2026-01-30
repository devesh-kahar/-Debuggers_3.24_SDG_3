const mongoose = require('mongoose');

const vitalSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    type: {
        type: String,
        enum: ['bp', 'weight', 'bloodSugar', 'temperature'],
        required: true
    },
    value: {
        type: Number,
        required: true
    },
    secondaryValue: {
        type: Number // For BP diastolic
    },
    unit: {
        type: String,
        default: function () {
            switch (this.type) {
                case 'bp': return 'mmHg';
                case 'weight': return 'kg';
                case 'bloodSugar': return 'mg/dL';
                case 'temperature': return '°C';
                default: return '';
            }
        }
    },
    notes: String,
    date: {
        type: Date,
        default: Date.now
    }
});

// Static method to get risk level for BP
vitalSchema.statics.getBPRiskLevel = function (systolic, diastolic) {
    if (systolic >= 160 || diastolic >= 100) return 'severe';
    if (systolic >= 140 || diastolic >= 90) return 'high';
    if (systolic >= 120 || diastolic >= 80) return 'elevated';
    return 'normal';
};

// Index for efficient queries
vitalSchema.index({ userId: 1, date: -1 });
vitalSchema.index({ userId: 1, type: 1, date: -1 });

module.exports = mongoose.model('Vital', vitalSchema);
