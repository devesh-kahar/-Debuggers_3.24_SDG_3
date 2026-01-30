// Seed script to populate the database with demo data for hackathon
const mongoose = require('mongoose');
require('dotenv').config();

const User = require('./src/models/User');
const Pregnancy = require('./src/models/Pregnancy');
const Vital = require('./src/models/Vital');
const Alert = require('./src/models/Alert');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/mommai';

const demoPatients = [
    {
        name: 'Priya Sharma',
        email: 'priya@demo.com',
        age: 32,
        phone: '+91 98765-43210',
        bloodType: 'O+',
        pregnancyWeek: 32,
        riskScore: 78,
        riskLevel: 'high',
        bpHistory: [
            { systolic: 118, diastolic: 76 },
            { systolic: 122, diastolic: 78 },
            { systolic: 128, diastolic: 82 },
            { systolic: 135, diastolic: 88 },
            { systolic: 145, diastolic: 95 }
        ],
        weights: [68, 69.5, 70.2, 71.5, 74.5],
        riskFactors: [
            { factor: 'Elevated Blood Pressure', severity: 'high', value: '145/95 mmHg' },
            { factor: 'Rapid Weight Gain', severity: 'medium', value: '+3 kg this week' }
        ]
    },
    {
        name: 'Anjali Gupta',
        email: 'anjali@demo.com',
        age: 28,
        phone: '+91 98765-43211',
        bloodType: 'A+',
        pregnancyWeek: 28,
        riskScore: 65,
        riskLevel: 'medium',
        bpHistory: [
            { systolic: 115, diastolic: 75 },
            { systolic: 120, diastolic: 80 },
            { systolic: 125, diastolic: 82 },
            { systolic: 130, diastolic: 85 },
            { systolic: 142, diastolic: 92 }
        ],
        weights: [65, 66, 67.2, 68, 69],
        riskFactors: [
            { factor: 'High BP Alert', severity: 'high', value: '142/92 mmHg' }
        ]
    },
    {
        name: 'Sneha Patel',
        email: 'sneha@demo.com',
        age: 30,
        phone: '+91 98765-43212',
        bloodType: 'B+',
        pregnancyWeek: 24,
        riskScore: 35,
        riskLevel: 'low',
        bpHistory: [
            { systolic: 112, diastolic: 72 },
            { systolic: 115, diastolic: 74 },
            { systolic: 110, diastolic: 70 },
            { systolic: 118, diastolic: 76 },
            { systolic: 115, diastolic: 75 }
        ],
        weights: [60, 61, 62, 63, 64.5],
        riskFactors: []
    },
    {
        name: 'Laxmi Devi',
        email: 'laxmi@demo.com',
        age: 35,
        phone: '+91 98765-43213',
        bloodType: 'AB+',
        pregnancyWeek: 36,
        riskScore: 45,
        riskLevel: 'medium',
        bpHistory: [
            { systolic: 120, diastolic: 78 },
            { systolic: 122, diastolic: 80 },
            { systolic: 125, diastolic: 82 },
            { systolic: 128, diastolic: 84 },
            { systolic: 130, diastolic: 86 }
        ],
        weights: [72, 73, 74, 75, 76],
        riskFactors: [
            { factor: 'Advanced Maternal Age', severity: 'low', value: 'Age 35+' }
        ]
    },
    {
        name: 'Kavita Reddy',
        email: 'kavita@demo.com',
        age: 26,
        phone: '+91 98765-43214',
        bloodType: 'O-',
        pregnancyWeek: 20,
        riskScore: 15,
        riskLevel: 'low',
        bpHistory: [
            { systolic: 110, diastolic: 70 },
            { systolic: 112, diastolic: 72 },
            { systolic: 108, diastolic: 68 },
            { systolic: 115, diastolic: 74 },
            { systolic: 112, diastolic: 71 }
        ],
        weights: [55, 56, 57, 58, 59],
        riskFactors: []
    }
];

async function seed() {
    try {
        console.log('🌱 Starting database seed...');
        await mongoose.connect(MONGODB_URI);
        console.log('✅ Connected to MongoDB');

        // Clear existing demo data
        await User.deleteMany({ email: { $regex: '@demo.com' } });
        await Pregnancy.deleteMany({});
        await Vital.deleteMany({});
        await Alert.deleteMany({});
        console.log('🗑️  Cleared existing demo data');

        // Create provider account
        const provider = await User.create({
            name: 'Dr. Ananya Iyer',
            email: 'provider@demo.com',
            password: 'provider123',
            role: 'provider'
        });
        console.log('👩‍⚕️ Created provider: provider@demo.com / provider123');

        for (const patientData of demoPatients) {
            // Create patient user
            const patient = await User.create({
                name: patientData.name,
                email: patientData.email,
                password: 'patient123',
                age: patientData.age,
                bloodType: patientData.bloodType,
                role: 'patient',
                currentMode: 'pregnancy',
                providerId: provider._id
            });

            // Create pregnancy record
            const dueDate = new Date();
            dueDate.setDate(dueDate.getDate() + ((40 - patientData.pregnancyWeek) * 7));

            // Calculate LMP from current week
            const lmp = new Date();
            lmp.setDate(lmp.getDate() - (patientData.pregnancyWeek * 7));

            await Pregnancy.create({
                userId: patient._id,
                lastMenstrualPeriod: lmp,
                dueDate,
                riskScore: patientData.riskScore,
                riskLevel: patientData.riskLevel,
                riskFactors: patientData.riskFactors,
                isActive: true
            });

            // Create BP vital records (last 5 days)
            for (let i = 0; i < patientData.bpHistory.length; i++) {
                const date = new Date();
                date.setDate(date.getDate() - (patientData.bpHistory.length - 1 - i));

                await Vital.create({
                    userId: patient._id,
                    type: 'bp',
                    value: patientData.bpHistory[i].systolic,
                    secondaryValue: patientData.bpHistory[i].diastolic,
                    date
                });
            }

            // Create weight records
            for (let i = 0; i < patientData.weights.length; i++) {
                const date = new Date();
                date.setDate(date.getDate() - ((patientData.weights.length - 1 - i) * 7));

                await Vital.create({
                    userId: patient._id,
                    type: 'weight',
                    value: patientData.weights[i],
                    date
                });
            }

            // Create alerts for high risk patients
            if (patientData.riskLevel === 'high') {
                const latestBP = patientData.bpHistory[patientData.bpHistory.length - 1];
                await Alert.create({
                    patientId: patient._id,
                    providerId: provider._id,
                    type: 'critical',
                    title: 'Blood Pressure Spike',
                    message: `BP reading: ${latestBP.systolic}/${latestBP.diastolic} mmHg - Above normal threshold`,
                    isRead: false
                });
            } else if (patientData.riskLevel === 'medium') {
                await Alert.create({
                    patientId: patient._id,
                    providerId: provider._id,
                    type: 'warning',
                    title: 'Elevated Vitals',
                    message: 'Some vitals require monitoring',
                    isRead: false
                });
            }

            console.log(`✅ Created patient: ${patientData.name}`);
        }

        console.log('\n🎉 Database seeded successfully!');
        console.log('\n📋 Demo Credentials:');
        console.log('   Provider: provider@demo.com / provider123');
        console.log('   Patient:  emily@demo.com / patient123');
        console.log('\n🚀 Start the backend with: npm run dev');

        process.exit(0);
    } catch (error) {
        console.error('❌ Seed error:', error);
        process.exit(1);
    }
}

seed();
