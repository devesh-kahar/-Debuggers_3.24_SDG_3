const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
    email: {
        type: String,
        required: true,
        unique: true,
        lowercase: true,
        trim: true
    },
    password: {
        type: String,
        required: true
    },
    role: {
        type: String,
        enum: ['patient', 'provider'],
        default: 'patient'
    },
    name: {
        type: String,
        required: true
    },
    age: Number,
    height: Number, // in cm
    weight: Number, // in kg
    bloodType: {
        type: String,
        enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
    },
    currentMode: {
        type: String,
        enum: ['fertility', 'pregnancy'],
        default: 'fertility'
    },
    providerId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    },
    // Fertility-specific
    lastMenstrualPeriod: Date,
    averageCycleLength: {
        type: Number,
        default: 28
    },
    averagePeriodLength: {
        type: Number,
        default: 5
    },
    // Medical history
    medicalConditions: [String],
    allergies: [String],
    medications: [String],
    // Settings
    notificationsEnabled: {
        type: Boolean,
        default: true
    },
    fcmToken: String,
    createdAt: {
        type: Date,
        default: Date.now
    }
});

// Hash password before saving
userSchema.pre('save', async function () {
    if (!this.isModified('password')) return;
    this.password = await bcrypt.hash(this.password, 12);
});

// Compare password method
userSchema.methods.comparePassword = async function (candidatePassword) {
    return await bcrypt.compare(candidatePassword, this.password);
};

// Calculate BMI
userSchema.virtual('bmi').get(function () {
    if (this.height && this.weight) {
        const heightInMeters = this.height / 100;
        return (this.weight / (heightInMeters * heightInMeters)).toFixed(1);
    }
    return null;
});

// Ensure virtuals are included in JSON
userSchema.set('toJSON', { virtuals: true });

module.exports = mongoose.model('User', userSchema);
