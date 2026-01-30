# 🤰 MomAI - AI-Powered Maternal Health Companion
### 🏆 Project for CIH 3.0 Competition
#### 👥 Team: **$Debuggers**

<p align="center">
  <img src="assets/logo.png" alt="MomAI Logo" width="120" height="120">
</p>

<p align="center">
  <strong>Empowering Mothers with AI-Driven Health Insights</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#project-structure">Structure</a> •
  <a href="#installation">Installation</a> •
  <a href="#api">API</a>
</p>

---

## 🌟 Overview

**MomAI** is a comprehensive maternal health application that leverages artificial intelligence to provide personalized health insights, real-time risk assessment, and seamless communication between pregnant mothers and healthcare providers.

The platform consists of three main components:
- 📱 **Flutter Mobile App** - Patient-facing application with real-time health pulse animations.
- 🖥️ **Next.js Dashboard** - Healthcare provider portal with **Live Sync** (Socket.io) for instant monitoring.
- ⚙️ **Node.js Backend** - API server with **AI Contextual Analysis** and **Auto-Simulated Data Streams**.

## ⚡ Real-Time Live Sync (Hackathon Special)
Unlike static mockups, MomAI features a fully functional **Real-Time Data Pipeline**:
*   **Instant Dashboard Updates**: When a patient logs a vital on the mobile app, the dashboard updates *without* refreshing.
*   **Live Simulation Mode**: A "Simulate" button on the dashboard allows judges to see real-time data flowing into the clinical view effortlessly.
*   **Active Risk Flagging**: The system automatically triggers critical alerts across all platforms the moment an anomaly is detected.

---

## ✨ Features

### 📱 Mobile App (Flutter)

| Feature | Description |
|---------|-------------|
| **Dual Mode** | Switch between Fertility Tracking and Pregnancy Monitoring |
| **AI Chat Assistant** | Powered by Google Gemini for personalized health advice |
| **Vital Logging** | Record BP, weight, blood sugar, temperature |
| **Risk Assessment** | Real-time risk score calculation with visual gauge |
| **Cycle Tracking** | Ovulation prediction, fertile window, BBT charting |
| **Pregnancy Journey** | Week-by-week progress, baby size comparisons |
| **Push Notifications** | Firebase Cloud Messaging for alerts |
| **Partner Mode** | Share access with partner |
| **Emergency Features** | Quick access to emergency contacts |

### 🖥️ Provider Dashboard (Next.js)

| Feature | Description |
|---------|-------------|
| **Patient Overview** | View all enrolled patients at a glance |
| **Risk Monitoring** | Real-time high-risk patient identification |
| **Alert Management** | Critical, warning, and info alerts with mark-as-read |
| **Vital Charts** | Blood pressure and weight trend visualization |
| **Patient Profiles** | Detailed view with risk factors and history |
| **Live Updates** | Auto-refresh every 5-10 seconds |
| **Messaging** | Communication with patients |
| **Appointments** | Schedule management |

### ⚙️ Backend API (Node.js)

| Feature | Description |
|---------|-------------|
| **RESTful API** | Full CRUD operations for all entities |
| **JWT Authentication** | Secure token-based auth for patients & providers |
| **AI Integration** | Google Gemini API for intelligent chat responses |
| **Real-time WebSocket** | Socket.io for instant updates |
| **Risk Engine** | Automated risk score calculation |
| **Alert System** | Automatic alert generation on abnormal vitals |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                           MomAI Platform                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐ │
│  │   Flutter App   │    │  Next.js Dashboard │  │  Node.js API   │ │
│  │   (Patient)     │◄──►│   (Provider)     │◄──►│   (Backend)    │ │
│  └────────┬────────┘    └────────┬────────┘    └────────┬────────┘ │
│           │                      │                      │          │
│           └──────────────────────┼──────────────────────┘          │
│                                  │                                  │
│                          ┌───────▼───────┐                         │
│                          │   MongoDB     │                         │
│                          │  (Database)   │                         │
│                          └───────────────┘                         │
│                                                                     │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐ │
│  │ Firebase FCM    │    │  Google Gemini  │    │   Socket.io     │ │
│  │ (Notifications) │    │  (AI Chat)      │    │  (Real-time)    │ │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
Patient App                    Backend                    Provider Dashboard
    │                            │                              │
    │──── Log Vitals ───────────►│                              │
    │                            │── Calculate Risk ──►         │
    │                            │── Generate Alert ──►         │
    │                            │────────────────────────────►│
    │◄── Push Notification ──────│                              │
    │                            │◄─── Fetch Dashboard ────────│
    │                            │──── Return Data ───────────►│
    │                            │                              │
```

---

## 📁 Project Structure

```
mommai/
│
├── 📱 FLUTTER MOBILE APP
├── lib/
│   ├── main.dart                     # App entry point, Firebase & Provider setup
│   │
│   ├── models/                       # Data Models (with JSON serialization)
│   │   ├── user.dart                 # User model - patient/provider profiles
│   │   ├── user.g.dart               # Auto-generated serialization
│   │   ├── pregnancy.dart            # Pregnancy tracking model
│   │   ├── pregnancy.g.dart          # Auto-generated serialization
│   │   ├── cycle.dart                # Menstrual cycle model
│   │   ├── cycle.g.dart              # Auto-generated serialization
│   │   ├── symptom.dart              # Symptoms logging model
│   │   ├── symptom.g.dart            # Auto-generated serialization
│   │   ├── chat_message.dart         # AI chat message model
│   │   └── chat_message.g.dart       # Auto-generated serialization
│   │
│   ├── providers/                    # State Management (ChangeNotifier)
│   │   ├── user_provider.dart        # Auth, profile, mode switching
│   │   ├── pregnancy_provider.dart   # Pregnancy data, risk calculation
│   │   ├── cycle_provider.dart       # Cycle tracking, fertile window
│   │   └── chat_provider.dart        # AI chat history & context
│   │
│   ├── screens/                      # UI Screens (organized by feature)
│   │   ├── auth/
│   │   │   └── login_screen.dart     # Login/Register screen
│   │   ├── onboarding/
│   │   │   └── onboarding_screen.dart # First-time user setup
│   │   ├── home/
│   │   │   ├── main_shell.dart       # Bottom navigation container
│   │   │   ├── pregnancy_home.dart   # Pregnancy mode dashboard
│   │   │   └── fertility_home.dart   # Fertility mode dashboard
│   │   ├── pregnancy/                # Pregnancy-specific screens
│   │   ├── fertility/
│   │   │   ├── fertility_dashboard.dart  # Cycle overview
│   │   │   └── log_entry_screen.dart     # Daily cycle logging
│   │   ├── chatbot/
│   │   │   └── ai_chat_screen.dart   # AI assistant interface
│   │   ├── profile/
│   │   │   └── profile_screen.dart   # User settings & profile
│   │   ├── medical/
│   │   │   └── medical_history.dart  # Medical records
│   │   ├── appointments/
│   │   │   └── appointments_screen.dart # Appointment scheduling
│   │   ├── emergency/
│   │   │   └── emergency_screen.dart # Emergency contacts & SOS
│   │   ├── education/
│   │   │   └── education_screen.dart # Health tips & articles
│   │   ├── insights/
│   │   │   └── insights_screen.dart  # Health analytics
│   │   └── partner/
│   │       └── partner_screen.dart   # Partner sharing mode
│   │
│   ├── services/                     # External Services
│   │   ├── api_service.dart          # HTTP client with Dio
│   │   ├── fcm_service.dart          # Firebase Cloud Messaging
│   │   └── socket_service.dart       # WebSocket connection
│   │
│   ├── widgets/                      # Reusable UI Components
│   │   ├── risk_gauge.dart           # Semicircular risk score display
│   │   ├── baby_size_card.dart       # Week-by-week baby comparison
│   │   ├── vitals_card.dart          # Vital signs display card
│   │   ├── charts.dart               # BP, weight, cycle charts
│   │   ├── cycle_info_card.dart      # Cycle phase information
│   │   ├── fertility_score_card.dart # Fertility probability display
│   │   └── quick_action_card.dart    # Action buttons
│   │
│   └── utils/                        # Utilities
│       ├── constants.dart            # App-wide constants
│       └── helpers.dart              # Helper functions
│
├── android/                          # Android platform files
├── ios/                              # iOS platform files
├── pubspec.yaml                      # Flutter dependencies
│
│
├── ⚙️ BACKEND API (Node.js + Express)
├── mommai-backend/
│   ├── src/
│   │   ├── index.js                  # Express server entry point
│   │   │                             # - CORS & JSON middleware
│   │   │                             # - Route mounting
│   │   │                             # - Socket.io setup
│   │   │                             # - MongoDB connection
│   │   │
│   │   ├── models/                   # Mongoose Schemas
│   │   │   ├── User.js               # User schema
│   │   │   │                         # - email, password (hashed)
│   │   │   │                         # - role: patient/provider
│   │   │   │                         # - currentMode: fertility/pregnancy
│   │   │   │                         # - medical history fields
│   │   │   ├── Pregnancy.js          # Pregnancy schema
│   │   │   │                         # - LMP, due date (calculated)
│   │   │   │                         # - currentWeek (virtual)
│   │   │   │                         # - riskScore, riskLevel
│   │   │   │                         # - riskFactors array
│   │   │   │                         # - babySizeComparison (virtual)
│   │   │   ├── Vital.js              # Vitals schema
│   │   │   │                         # - type: bp/weight/sugar/temp
│   │   │   │                         # - value, secondaryValue (BP)
│   │   │   │                         # - getBPRiskLevel static method
│   │   │   ├── Alert.js              # Alert schema
│   │   │   │                         # - type: critical/warning/info
│   │   │   │                         # - patientId, providerId
│   │   │   │                         # - isRead status
│   │   │   └── Message.js            # Chat message schema
│   │   │
│   │   ├── routes/                   # API Route Handlers
│   │   │   ├── auth.js               # /api/auth/*
│   │   │   │                         # POST /register - Create account
│   │   │   │                         # POST /login - Get JWT token
│   │   │   │                         # GET /me - Current user
│   │   │   │                         # PUT /profile - Update profile
│   │   │   │
│   │   │   ├── vitals.js             # /api/vitals/*
│   │   │   │                         # POST / - Log new vital
│   │   │   │                         # GET /history - Vital history
│   │   │   │                         # GET /latest - Latest readings
│   │   │   │
│   │   │   ├── pregnancy.js          # /api/pregnancy/*
│   │   │   │                         # GET / - Current pregnancy
│   │   │   │                         # POST / - Start pregnancy
│   │   │   │                         # GET /risk - Risk assessment
│   │   │   │
│   │   │   ├── alerts.js             # /api/alerts/*
│   │   │   │                         # GET / - User alerts
│   │   │   │                         # PUT /:id/read - Mark read
│   │   │   │
│   │   │   ├── chat.js               # /api/chat/*
│   │   │   │                         # POST / - Send to AI
│   │   │   │                         # GET /history - Chat history
│   │   │   │                         # Uses Google Gemini API
│   │   │   │
│   │   │   └── provider.js           # /api/provider/*
│   │   │                             # Protected provider routes
│   │   │                             # GET /patients - Patient list
│   │   │                             # GET /dashboard - Stats
│   │   │                             # 
│   │   │                             # Demo routes (no auth):
│   │   │                             # GET /demo/dashboard
│   │   │                             # GET /demo/patients
│   │   │                             # GET /demo/patients/:id
│   │   │                             # GET /demo/alerts
│   │   │
│   │   ├── middleware/
│   │   │   └── auth.js               # JWT verification middleware
│   │   │                             # auth - general user auth
│   │   │                             # providerAuth - provider only
│   │   │
│   │   └── services/
│   │       └── gemini.js             # Google Gemini AI service
│   │
│   ├── seed.js                       # Database seeder script
│   │                                 # Creates demo provider & patients
│   │                                 # Generates sample vitals & alerts
│   │
│   ├── package.json                  # Node.js dependencies
│   └── .env                          # Environment variables
│
│
├── 🖥️ PROVIDER DASHBOARD (Next.js)
├── mommai-dashboard/
│   ├── src/
│   │   ├── app/                      # Next.js App Router
│   │   │   ├── layout.tsx            # Root layout with Sidebar
│   │   │   ├── globals.css           # Global styles & Tailwind
│   │   │   │
│   │   │   ├── page.tsx              # Dashboard Home (/)
│   │   │   │                         # - Stat cards (patients, risk, alerts)
│   │   │   │                         # - Recent alerts list
│   │   │   │                         # - 10s auto-refresh
│   │   │   │
│   │   │   ├── patients/
│   │   │   │   ├── page.tsx          # Patient List (/patients)
│   │   │   │   │                     # - Search & filter
│   │   │   │   │                     # - Risk level badges
│   │   │   │   │                     # - Sortable table
│   │   │   │   │
│   │   │   │   └── [id]/
│   │   │   │       └── page.tsx      # Patient Detail (/patients/:id)
│   │   │   │                         # - Risk gauge visualization
│   │   │   │                         # - BP trend chart (Recharts)
│   │   │   │                         # - Weight trend chart
│   │   │   │                         # - Risk factors list
│   │   │   │                         # - Activity log
│   │   │   │
│   │   │   ├── alerts/
│   │   │   │   └── page.tsx          # Alerts (/alerts)
│   │   │   │                         # - Filter: all/unread/critical
│   │   │   │                         # - Click to mark as read
│   │   │   │                         # - 5s auto-refresh
│   │   │   │
│   │   │   ├── messages/
│   │   │   │   └── page.tsx          # Messages (/messages)
│   │   │   │
│   │   │   ├── appointments/
│   │   │   │   └── page.tsx          # Appointments (/appointments)
│   │   │   │
│   │   │   └── settings/
│   │   │       └── page.tsx          # Settings (/settings)
│   │   │
│   │   └── components/               # Reusable Components
│   │       ├── Sidebar.tsx           # Navigation sidebar
│   │       │                         # - Logo & branding
│   │       │                         # - Menu items
│   │       │                         # - User info (Dr. Sarah Wilson)
│   │       │                         # - Collapsible
│   │       │
│   │       └── Header.tsx            # Top header bar
│   │                                 # - Search input
│   │                                 # - Notifications bell
│   │                                 # - Clinic selector
│   │
│   ├── package.json                  # Next.js dependencies
│   ├── tailwind.config.ts            # Tailwind CSS configuration
│   ├── tsconfig.json                 # TypeScript configuration
│   └── .env.local                    # Environment (API URL)
│
│
└── 📚 DOCUMENTATION
    ├── README.md                     # This file
    ├── WALKTHROUGH.md                # Detailed development guide
    ├── mommai-backend/README.md      # Backend API documentation
    └── mommai-dashboard/README.md    # Dashboard documentation
```

---

## 🚀 Installation

### Prerequisites

- **Flutter SDK** >= 3.10.0
- **Node.js** >= 18.0.0
- **MongoDB** >= 6.0 (local or Atlas)
- **Android Studio** / **Xcode** (for mobile development)

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/mommai.git
cd mommai
```

### 2. Backend Setup

```bash
cd mommai-backend

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with your values:
# - MONGODB_URI
# - JWT_SECRET
# - GEMINI_API_KEY

# Seed demo data
npm run seed

# Start server
npm run dev
```

**Server runs at:** `http://localhost:5000`

### 3. Dashboard Setup

```bash
cd mommai-dashboard

# Install dependencies
npm install

# Configure environment
echo "NEXT_PUBLIC_API_URL=http://localhost:5000/api" > .env.local

# Start development server
npm run dev
```

**Dashboard runs at:** `http://localhost:3000`

### 4. Flutter App Setup

```bash
# From root directory
flutter pub get

# Configure API URL in lib/services/api_service.dart
# Change baseUrl if not using localhost

# Run on connected device/emulator
flutter run
```

---

## 🎮 Demo Credentials

After running `npm run seed` in the backend:

| Role | Email | Password | Name |
|------|-------|----------|------|
| **Provider** | provider@demo.com | provider123 | Dr. Ananya Iyer |
| **Patient (High Risk)** | priya@demo.com | patient123 | Priya Sharma |
| **Patient (Medium Risk)** | anjali@demo.com | patient123 | Anjali Gupta |
| **Patient (Low Risk)** | sneha@demo.com | patient123 | Sneha Patel |
| **Patient (Medium Risk)** | laxmi@demo.com | patient123 | Laxmi Devi |
| **Patient (Low Risk)** | kavita@demo.com | patient123 | Kavita Reddy |

---

## 📡 API Reference

### Base URL
```
http://localhost:5000/api
```

### Authentication Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Register new user |
| POST | `/auth/login` | Login & get JWT |
| GET | `/auth/me` | Get current user |
| PUT | `/auth/profile` | Update profile |

### Vitals Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/vitals` | Log new vital |
| GET | `/vitals/history` | Get vital history |
| GET | `/vitals/latest` | Get latest vitals |

### Pregnancy Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/pregnancy` | Get current pregnancy |
| POST | `/pregnancy` | Start new pregnancy |
| GET | `/pregnancy/risk` | Get risk assessment |

### Provider Dashboard (Demo)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/provider/clinic/dashboard` | Dashboard stats |
| GET | `/provider/clinic/patients` | All patients list |
| GET | `/provider/clinic/patients/:id` | Patient detail with charts |
| GET | `/provider/clinic/alerts` | All alerts |
| PUT | `/provider/clinic/alerts/:id/read` | Mark alert as read |

---

## 🔒 Security

- **JWT Authentication** - Tokens expire after 7 days
- **Password Hashing** - bcrypt with 12 salt rounds
- **Role-Based Access** - Patient vs Provider permissions
- **Input Validation** - Mongoose schema validation

---

## 🧠 AI Integration

MomAI uses **Google Gemini** for intelligent health conversations:

```javascript
// Context includes:
// - User's pregnancy stage (currentWeek, trimester)
// - Recent vital signs (BP, weight trends)
// - Medical history (conditions, allergies)
// - Risk factors (high BP, gestational diabetes)

// Example system prompt:
"You are MomAI, a caring maternal health assistant.
Provide personalized advice based on the user's data.
Always recommend consulting a provider for concerns."
```

---

## 📊 Risk Assessment Algorithm

The risk score (0-100) is calculated based on:

| Factor | Weight | Threshold |
|--------|--------|-----------|
| Blood Pressure | 30% | >140/90 mmHg |
| Weight Gain | 20% | >0.5kg/week sudden |
| Age | 15% | >35 years |
| Blood Sugar | 15% | >140 mg/dL |
| Medical History | 20% | Pre-existing conditions |

**Risk Levels:**
- 🟢 **Low** (0-30): Normal monitoring
- 🟡 **Medium** (31-60): Increased attention
- 🔴 **High** (61-100): Immediate provider notification

---

## 🛠️ Tech Stack

### Mobile App
- **Flutter** 3.10+ (Dart)
- **Provider** - State management
- **Dio** - HTTP client
- **Firebase** - FCM notifications
- **fl_chart** - Data visualization

### Backend API
- **Node.js** 18+
- **Express.js** 5
- **MongoDB** + Mongoose 9
- **Socket.io** - Real-time
- **JWT** - Authentication
- **Google Gemini** - AI

### Provider Dashboard
- **Next.js** 16 (App Router)
- **React** 19
- **TypeScript**
- **Tailwind CSS**
- **Recharts** - Charts
- **Lucide** - Icons

---

## 📱 Screenshots

| Pregnancy Dashboard | AI Chat | Provider Dashboard |
|---------------------|---------|-------------------|
| Risk gauge with baby progress | Conversational AI assistant | Patient overview with alerts |

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Team

Built with ❤️ for **CIH 3.0** by team **$Debuggers**
- **Devesh Kahar** (Lead Developer)
- **The $Debuggers Team**

---

## 🙏 Acknowledgments

- Google Gemini for AI capabilities
- Firebase for notifications
- MongoDB for database
- The Flutter & Next.js communities

---

<p align="center">
  <strong>🤰 MomAI - Because Every Mother Deserves the Best Care 🤰</strong>
</p>
