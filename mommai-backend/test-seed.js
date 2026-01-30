// Test seeding with detailed error output
const mongoose = require('mongoose');
require('dotenv').config();
const User = require('./src/models/User');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/mommai';

async function test() {
    try {
        console.log('Connecting to:', MONGODB_URI);
        await mongoose.connect(MONGODB_URI);
        console.log('Connected to MongoDB!');

        // Clear all demo users first
        const deleted = await User.deleteMany({ email: { $regex: /@demo\.com$/ } });
        console.log('Cleared demo users:', deleted.deletedCount);

        // Try creating a simple user
        console.log('Creating test user...');
        const user = new User({
            name: 'Test User',
            email: 'test@demo.com',
            password: 'test123',
            role: 'patient'
        });

        console.log('User object created, saving...');
        await user.save();
        console.log('SUCCESS! Created user:', user.email);
        console.log('Password hashed:', user.password.substring(0, 20) + '...');

        // Clean up
        await User.deleteOne({ email: 'test@demo.com' });
        console.log('Cleaned up test user');
        console.log('\n✅ Test successful! Seeding should work.');
        process.exit(0);
    } catch (error) {
        console.error('\n❌ Error details:');
        console.error('Name:', error.name);
        console.error('Message:', error.message);
        if (error.errors) {
            console.error('Validation errors:', JSON.stringify(error.errors, null, 2));
        }
        console.error('Stack:', error.stack);
        process.exit(1);
    }
}

test();
