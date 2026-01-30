# 🏥 MomAI Provider Dashboard

<p align="center">
  <strong>Healthcare Provider Portal for MomAI Platform</strong>
</p>

<p align="center">
  Next.js 15 • React • TypeScript • Tailwind CSS • Recharts
</p>

---

## 📋 Overview

The MomAI Provider Dashboard is a modern web application that enables healthcare providers to:

- 👀 Monitor all enrolled patients
- 🚨 Receive and manage health alerts
- 📊 View vital sign trends and charts
- 🎯 Identify high-risk patients quickly
- 📈 Track pregnancy progress in real-time

---

## ✨ Features

### 📊 Dashboard Home
- **Live Statistics** - Total patients, high-risk count, active alerts
- **Recent Alerts** - Quick view of critical notifications
- **Auto-refresh** - Updates every 10 seconds

### 👥 Patient Management
- **Patient List** - All enrolled patients with search & filter
- **Risk Indicators** - Color-coded risk levels
- **Quick Stats** - Week, trimester, latest vitals at a glance

### 📋 Patient Profiles
- **Risk Gauge** - Visual risk score representation
- **Risk Factors** - Detailed breakdown of concerns
- **BP Chart** - Blood pressure trend over time
- **Weight Chart** - Weight progression visualization
- **Activity Log** - Recent vital entries

### 🔔 Alert System
- **Filter Options** - All, Unread, Critical
- **Mark as Read** - Click to acknowledge
- **Live Updates** - 5-second refresh interval
- **Patient Links** - Quick navigation to patient profile

---

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Configure environment
echo "NEXT_PUBLIC_API_URL=http://localhost:5000/api" > .env.local

# Start development server
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

---

## ⚙️ Environment Variables

Create `.env.local` in root:

```env
# Backend API URL
NEXT_PUBLIC_API_URL=http://localhost:5000/api
```

---

## 📁 Project Structure

```
mommai-dashboard/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── layout.tsx          # Root layout with sidebar
│   │   ├── page.tsx            # Dashboard home
│   │   ├── patients/
│   │   │   ├── page.tsx        # Patient list
│   │   │   └── [id]/
│   │   │       └── page.tsx    # Patient detail
│   │   ├── alerts/
│   │   │   └── page.tsx        # Alert management
│   │   ├── messages/
│   │   │   └── page.tsx        # Messages (placeholder)
│   │   ├── appointments/
│   │   │   └── page.tsx        # Appointments (placeholder)
│   │   ├── settings/
│   │   │   └── page.tsx        # Settings (placeholder)
│   │   └── globals.css         # Global styles
│   └── components/
│       ├── Sidebar.tsx         # Navigation sidebar
│       └── Header.tsx          # Top header bar
├── public/                     # Static assets
├── package.json
├── tailwind.config.ts
├── tsconfig.json
└── next.config.ts
```

---

## 📱 Pages

### Dashboard (`/`)

![Dashboard](docs/dashboard.png)

**Features:**
- Stat cards showing key metrics
- Recent alerts with type indicators
- Live data refresh

**API Endpoint:**
```
GET /api/provider/demo/dashboard
```

**Response:**
```json
{
  "stats": {
    "totalPatients": 5,
    "highRisk": 2,
    "activeAlerts": 3
  },
  "recentAlerts": [...]
}
```

---

### Patients (`/patients`)

![Patients](docs/patients.png)

**Features:**
- Search by name or email
- Filter by risk level
- Sortable columns
- Pagination

**API Endpoint:**
```
GET /api/provider/demo/patients?search=&risk=all
```

**Response:**
```json
{
  "patients": [
    {
      "id": "...",
      "name": "Emily Rodriguez",
      "email": "emily@demo.com",
      "week": 32,
      "trimester": 3,
      "riskLevel": "high",
      "riskScore": 78,
      "latestBP": "145/95",
      "latestWeight": 74.5
    }
  ]
}
```

---

### Patient Detail (`/patients/[id]`)

![Patient Detail](docs/patient-detail.png)

**Features:**
- Patient header with quick actions
- Risk assessment gauge
- BP trend line chart
- Weight area chart
- Recent activity log

**API Endpoint:**
```
GET /api/provider/demo/patients/:id
```

**Response:**
```json
{
  "patient": {
    "name": "Emily Rodriguez",
    "age": 32,
    "bloodType": "O+"
  },
  "pregnancy": {
    "currentWeek": 32,
    "trimester": 3,
    "dueDate": "2024-10-20",
    "riskScore": 78,
    "riskLevel": "high",
    "riskFactors": [...]
  },
  "bpData": [
    { "date": "Mon", "systolic": 118, "diastolic": 76 },
    { "date": "Tue", "systolic": 122, "diastolic": 78 }
  ],
  "weightData": [
    { "date": "Week 28", "weight": 68 },
    { "date": "Week 29", "weight": 69.5 }
  ],
  "recentLogs": [...]
}
```

---

### Alerts (`/alerts`)

![Alerts](docs/alerts.png)

**Features:**
- Filter by: All, Unread, Critical
- Mark as read on click
- Mark all read button
- Patient profile links
- 5-second auto-refresh

**API Endpoints:**
```
GET /api/provider/demo/alerts?type=all&unreadOnly=false
PUT /api/provider/demo/alerts/:id/read
```

---

## 🎨 Design System

### Colors

```css
/* Primary */
--pink-500: #ec4899;   /* Primary actions */
--pink-600: #db2777;   /* Hover states */

/* Supporting */
--teal-500: #14b8a6;   /* Secondary actions */
--purple-500: #a855f7; /* Tertiary accents */

/* Semantic */
--red-500: #ef4444;    /* Critical/High risk */
--yellow-500: #eab308; /* Warning/Medium risk */
--green-500: #22c55e;  /* Success/Low risk */

/* Neutral */
--slate-800: #1e293b;  /* Sidebar background */
--slate-50: #f8fafc;   /* Page background */
```

### Components

**Stat Card**
```tsx
<div className="stat-card">
  <div className={`icon ${colorClass}`}>
    <Icon className="w-6 h-6" />
  </div>
  <div className="content">
    <p className="label">Total Patients</p>
    <p className="value">156</p>
  </div>
</div>
```

**Risk Badge**
```tsx
<span className={`px-3 py-1 rounded-full text-xs font-medium ${
  risk === 'high' ? 'bg-red-100 text-red-600' :
  risk === 'medium' ? 'bg-yellow-100 text-yellow-600' :
  'bg-green-100 text-green-600'
}`}>
  {risk.toUpperCase()}
</span>
```

---

## 📊 Charts (Recharts)

### Blood Pressure Chart
```tsx
<LineChart data={bpData}>
  <XAxis dataKey="date" />
  <YAxis domain={[60, 160]} />
  <Line 
    dataKey="systolic" 
    stroke="#f472b6" 
    name="Systolic" 
  />
  <Line 
    dataKey="diastolic" 
    stroke="#14b8a6" 
    name="Diastolic" 
  />
</LineChart>
```

### Weight Trend Chart
```tsx
<AreaChart data={weightData}>
  <Area 
    dataKey="weight" 
    stroke="#14b8a6" 
    fill="url(#gradient)" 
  />
</AreaChart>
```

---

## 🔄 Real-time Updates

Dashboard implements auto-refresh using `setInterval`:

```tsx
useEffect(() => {
  const fetchData = async () => {
    const res = await fetch(`${API_URL}/provider/demo/dashboard`);
    const data = await res.json();
    setData(data);
  };
  
  fetchData();
  
  // Refresh every 10 seconds
  const interval = setInterval(fetchData, 10000);
  return () => clearInterval(interval);
}, []);
```

Visual indicator shows live status:
```tsx
<span className="flex items-center gap-2 text-green-600">
  <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></span>
  Live
</span>
```

---

## 🛠️ Development

### Available Scripts

| Script | Description |
|--------|-------------|
| `npm run dev` | Start development server (Turbopack) |
| `npm run build` | Build for production |
| `npm start` | Start production server |
| `npm run lint` | Run ESLint |

### Tech Stack

- **Framework**: Next.js 15 (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Charts**: Recharts
- **Icons**: Lucide React
- **HTTP**: Native Fetch API

---

## 📱 Responsive Design

The dashboard is optimized for:

- 🖥️ **Desktop** (1920px+) - Full layout
- 💻 **Laptop** (1024px-1919px) - Adjusted spacing
- 📱 **Tablet** (768px-1023px) - Stacked layout

```css
/* Example responsive classes */
.grid.lg:grid-cols-3.md:grid-cols-2.grid-cols-1
```

---

## 🚀 Deployment

### Vercel (Recommended)
```bash
npm run build
vercel deploy --prod
```

### Docker
```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
EXPOSE 3000
CMD ["npm", "start"]
```

### Environment Variables (Production)
```env
NEXT_PUBLIC_API_URL=https://api.mommai.com/api
```

---

## 🔧 Configuration

### Next.js Config
```typescript
// next.config.ts
const config = {
  experimental: {
    turbo: {}
  },
  images: {
    domains: ['localhost']
  }
};
```

### Tailwind Config
```typescript
// tailwind.config.ts
module.exports = {
  content: ['./src/**/*.{js,ts,jsx,tsx,mdx}'],
  theme: {
    extend: {
      colors: {
        primary: '#ec4899'
      }
    }
  }
};
```

---

## 🧪 Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Coverage
npm run test:coverage
```

---

## 📄 License

MIT License - See main repository LICENSE file.

---

## 🔗 Related

- [Main Repository](../README.md)
- [Backend API](../mommai-backend/README.md)
- [Flutter App](../README.md#flutter-app)
