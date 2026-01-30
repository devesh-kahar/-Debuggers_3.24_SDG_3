const mongoose = require('mongoose');

const pregnancySchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    lastMenstrualPeriod: {
        type: Date,
        required: true
    },
    dueDate: {
        type: Date,
        required: true
    },
    riskScore: {
        type: Number,
        default: 10,
        min: 0,
        max: 100
    },
    riskLevel: {
        type: String,
        enum: ['low', 'medium', 'high'],
        default: 'low'
    },
    riskFactors: [{
        factor: String,
        severity: {
            type: String,
            enum: ['low', 'medium', 'high']
        },
        addedAt: {
            type: Date,
            default: Date.now
        }
    }],
    isActive: {
        type: Boolean,
        default: true
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

// Calculate current week
pregnancySchema.virtual('currentWeek').get(function () {
    const now = new Date();
    const lmp = new Date(this.lastMenstrualPeriod);
    const diffTime = Math.abs(now - lmp);
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return Math.min(Math.floor(diffDays / 7), 40);
});

// Calculate trimester
pregnancySchema.virtual('trimester').get(function () {
    const week = this.currentWeek;
    if (week <= 12) return 1;
    if (week <= 27) return 2;
    return 3;
});

// Days remaining
pregnancySchema.virtual('daysRemaining').get(function () {
    const now = new Date();
    const due = new Date(this.dueDate);
    const diffTime = due - now;
    return Math.max(0, Math.ceil(diffTime / (1000 * 60 * 60 * 24)));
});

// Baby size comparison
pregnancySchema.virtual('babySizeComparison').get(function () {
    const sizes = {
        4: 'Poppy seed',
        5: 'Sesame seed',
        6: 'Lentil',
        7: 'Blueberry',
        8: 'Kidney bean',
        9: 'Grape',
        10: 'Kumquat',
        11: 'Fig',
        12: 'Lime',
        13: 'Pea pod',
        14: 'Lemon',
        15: 'Apple',
        16: 'Avocado',
        17: 'Turnip',
        18: 'Bell pepper',
        19: 'Tomato',
        20: 'Banana',
        21: 'Carrot',
        22: 'Spaghetti squash',
        23: 'Mango',
        24: 'Corn',
        25: 'Rutabaga',
        26: 'Scallion',
        27: 'Cauliflower',
        28: 'Eggplant',
        29: 'Butternut squash',
        30: 'Cabbage',
        31: 'Coconut',
        32: 'Jicama',
        33: 'Pineapple',
        34: 'Cantaloupe',
        35: 'Honeydew melon',
        36: 'Romaine lettuce',
        37: 'Swiss chard',
        38: 'Leek',
        39: 'Mini watermelon',
        40: 'Watermelon'
    };
    return sizes[this.currentWeek] || 'Growing baby';
});

pregnancySchema.set('toJSON', { virtuals: true });

module.exports = mongoose.model('Pregnancy', pregnancySchema);
