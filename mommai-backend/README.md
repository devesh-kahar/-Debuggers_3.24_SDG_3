# 🔧 MomAI Backend API

<p align="center">
  <strong>RESTful API Server for MomAI Platform</strong>
</p>

<p align="center">
  Node.js • Express • MongoDB • Socket.io • Google Gemini AI
</p>

---

## 📋 Overview

The MomAI Backend provides a robust API for the maternal health platform, handling:

- 🔐 User authentication (JWT-based)
- 📊 Vital signs management
- 🤰 Pregnancy tracking
- 🚨 Alert system
- 🤖 AI-powered chat with Google Gemini
- ⚡ Real-time updates via WebSocket

---

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Configure environment
cp .env.example .env

# Seed demo data
npm run seed

# Start development server
npm run dev
```

Server runs at `http://localhost:5000`

---

## ⚙️ Environment Variables

Create a `.env` file with:

```env
# Server Configuration
PORT=5000

# Database
MONGODB_URI=mongodb://localhost:27017/mommai

# Authentication
JWT_SECRET=your-super-secret-key-change-in-production

# AI Integration
GEMINI_API_KEY=your-gemini-api-key

# Firebase (Optional - for push notifications)
FIREBASE_SERVICE_ACCOUNT=path/to/firebase-credentials.json
```

---

## 📁 Project Structure

```
mommai-backend/
├── src/
│   ├── index.js              # Server entry point
│   ├── models/               # Mongoose schemas
│   │   ├── User.js           # User model (patient/provider)
│   │   ├── Pregnancy.js      # Pregnancy tracking
│   │   ├── Cycle.js          # Menstrual cycle data
│   │   ├── Vital.js          # Vital signs (BP, weight, etc)
│   │   └── Alert.js          # Health alerts
│   ├── routes/               # API route handlers
│   │   ├── auth.js           # Authentication routes
│   │   ├── vitals.js         # Vital signs CRUD
│   │   ├── pregnancy.js      # Pregnancy management
│   │   ├── alerts.js         # Alert system
│   │   ├── chat.js           # AI chat integration
│   │   └── provider.js       # Provider dashboard routes
│   └── middleware/
│       └── auth.js           # JWT authentication middleware
├── seed.js                   # Database seeder
├── package.json
└── .env
```

---

## 📡 API Endpoints

### 🔐 Authentication

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/auth/register` | Register new user | ❌ |
| POST | `/api/auth/login` | Login user | ❌ |
| GET | `/api/auth/me` | Get current user | ✅ |
| PUT | `/api/auth/profile` | Update profile | ✅ |
| POST | `/api/auth/fcm-token` | Update FCM token | ✅ |

#### Register Request
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "Jane Doe",
  "role": "patient"
}
```

#### Login Response
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "64a...",
    "email": "user@example.com",
    "name": "Jane Doe",
    "role": "patient"
  }
}
```

---

### 📊 Vitals

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/vitals` | Log new vital | ✅ |
| GET | `/api/vitals/history` | Get vital history | ✅ |
| GET | `/api/vitals/latest` | Get latest vitals | ✅ |

#### Log Vital Request
```json
{
  "type": "bp",
  "value": 120,
  "secondaryValue": 80,
  "notes": "After morning walk"
}
```

**Vital Types:**
- `bp` - Blood Pressure (systolic/diastolic)
- `weight` - Weight in kg
- `bloodSugar` - Blood sugar in mg/dL
- `temperature` - Temperature in °C

---

### 🤰 Pregnancy

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/pregnancy` | Get current pregnancy | ✅ |
| POST | `/api/pregnancy` | Start new pregnancy | ✅ |
| PUT | `/api/pregnancy` | Update pregnancy | ✅ |
| GET | `/api/pregnancy/risk` | Get risk assessment | ✅ |

#### Pregnancy Response
```json
{
  "id": "64a...",
  "userId": "64a...",
  "lastMenstrualPeriod": "2024-01-15",
  "dueDate": "2024-10-22",
  "currentWeek": 28,
  "trimester": 3,
  "riskScore": 35,
  "riskLevel": "medium",
  "riskFactors": [
    { "factor": "Elevated BP", "severity": "medium" }
  ],
  "babySizeComparison": "Eggplant"
}
```

---

### 🚨 Alerts

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/alerts` | Get user alerts | ✅ |
| PUT | `/api/alerts/:id/read` | Mark alert as read | ✅ |
| DELETE | `/api/alerts/:id` | Delete alert | ✅ |

#### Alert Response
```json
{
  "id": "64a...",
  "type": "critical",
  "title": "High Blood Pressure",
  "message": "BP reading 145/95 mmHg exceeds normal range",
  "patientId": "64a...",
  "isRead": false,
  "createdAt": "2024-06-15T10:30:00Z"
}
```

**Alert Types:**
- `critical` - Immediate attention required
- `warning` - Monitor closely
- `info` - General information
- `success` - Positive update

---

### 💬 AI Chat

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/chat` | Send message to AI | ✅ |
| GET | `/api/chat/history` | Get chat history | ✅ |

#### Chat Request
```json
{
  "message": "I've been having headaches lately, should I be concerned?"
}
```

#### Chat Response
```json
{
  "response": "Headaches during pregnancy can be common, especially in the third trimester. However, persistent severe headaches combined with high blood pressure could indicate preeclampsia. Based on your recent BP readings, I recommend...",
  "isEmergency": false
}
```

---

### 👩‍⚕️ Provider Dashboard

#### Demo Routes (No Auth Required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/provider/demo/dashboard` | Dashboard statistics |
| GET | `/api/provider/demo/patients` | All patients list |
| GET | `/api/provider/demo/patients/:id` | Patient detail |
| GET | `/api/provider/demo/alerts` | All alerts |
| PUT | `/api/provider/demo/alerts/:id/read` | Mark alert read |

#### Dashboard Response
```json
{
  "stats": {
    "totalPatients": 5,
    "highRisk": 2,
    "activeAlerts": 3
  },
  "recentAlerts": [
    {
      "id": "64a...",
      "type": "critical",
      "title": "BP Spike",
      "patientName": "Emily Rodriguez",
      "time": "10 minutes ago"
    }
  ]
}
```

---

## 🔌 WebSocket Events

Connect to `ws://localhost:5000` for real-time updates.

### Client Events
```javascript
// Join user room for personalized updates
socket.emit('join-room', userId);
```

### Server Events
```javascript
// New alert notification
socket.on('new-alert', (alert) => {
  console.log('New alert:', alert);
});

// Vital update
socket.on('vital-update', (vital) => {
  console.log('Vital logged:', vital);
});
```

---

## 🧠 AI Integration

The chat endpoint uses **Google Gemini** for intelligent responses:

```javascript
// src/routes/chat.js
const { GoogleGenerativeAI } = require('@google/generative-ai');
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// Context includes:
// - User's pregnancy stage
// - Recent vital signs
// - Medical history
// - Risk factors
```

### System Prompt
```
You are MomAI, a caring and knowledgeable maternal health assistant.
You provide personalized advice based on the user's pregnancy stage,
vital signs, and medical history. Always recommend consulting a
healthcare provider for serious concerns.
```

---

## 📊 Database Models

### User Schema
```javascript
{
  email: String (unique),
  password: String (hashed),
  name: String,
  role: 'patient' | 'provider',
  age: Number,
  bloodType: String,
  currentMode: 'fertility' | 'pregnancy',
  providerId: ObjectId,
  medicalConditions: [String],
  fcmToken: String
}
```

### Pregnancy Schema
```javascript
{
  userId: ObjectId,
  lastMenstrualPeriod: Date,
  dueDate: Date,
  riskScore: Number (0-100),
  riskLevel: 'low' | 'medium' | 'high',
  riskFactors: [{
    factor: String,
    severity: String
  }],
  isActive: Boolean
}
```

### Vital Schema
```javascript
{
  userId: ObjectId,
  type: 'bp' | 'weight' | 'bloodSugar' | 'temperature',
  value: Number,
  secondaryValue: Number,
  unit: String,
  date: Date
}
```

---

## 🔒 Security

### Authentication Flow
```
1. User registers/logs in
2. Server generates JWT (expires in 7 days)
3. Client stores token securely
4. All requests include: Authorization: Bearer <token>
5. Middleware validates token & attaches user to request
```

### Password Security
```javascript
// Hash on save (12 rounds)
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});
```

---

## 🌱 Seeding Data

The `seed.js` script creates demo data:

```bash
npm run seed
```

**Creates:**
- 1 Provider (Dr. Sarah Wilson)
- 5 Patients with varying risk levels
- Vital history for each patient
- Sample alerts

---

## 🛠️ Scripts

| Script | Description |
|--------|-------------|
| `npm run dev` | Start development server |
| `npm start` | Start production server |
| `npm run seed` | Seed demo data |
| `npm test` | Run tests |

---

## 📝 Error Handling

All errors return consistent format:

```json
{
  "error": "Error message",
  "details": "Additional details (development only)"
}
```

**Status Codes:**
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Server Error

---

## 🚀 Deployment

### Docker
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 5000
CMD ["npm", "start"]
```

### Environment Production
```env
NODE_ENV=production
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/mommai
JWT_SECRET=strong-production-secret
```

---

## 📄 License

MIT License - See main repository LICENSE file.
