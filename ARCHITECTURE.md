# 🏗️ HireSphere - System Architecture

## 📐 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER INTERFACE                            │
│                     (Next.js Frontend)                           │
│                    http://localhost:3000                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  Landing Page (/)          Registration (/auth/register)         │
│  ├─ Hero Section          ├─ Worker Registration                │
│  ├─ Features              └─ Employer Registration               │
│  ├─ Stats                                                        │
│  └─ CTA Buttons           Login (/auth/login)                    │
│                           ├─ Worker: Phone + OTP                 │
│                           └─ Employer: Email + Password          │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ EMPLOYER DASHBOARD (/employer)                            │  │
│  ├────────────────────────────────────────────────────────────┤ │
│  │ Sidebar Navigation:                                        │ │
│  │ • Dashboard (Active)                                       │ │
│  │ • My Jobs                                                  │ │
│  │ • Applicants                                               │ │
│  │ • Settings                                                 │ │
│  │ • Logout                                                   │ │
│  ├────────────────────────────────────────────────────────────┤ │
│  │ Main Content:                                              │ │
│  │ • Post New Job (Dialog)                                    │ │
│  │ • KPI Cards (Jobs Count, Applicants Count)                │ │
│  │ • Jobs Table (with Search, Edit, Delete)                  │ │
│  │ • Applicants View                                          │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ WORKER DASHBOARD (/worker)                                │  │
│  ├────────────────────────────────────────────────────────────┤ │
│  │ Header:                                                    │ │
│  │ • Dynamic Title                                            │ │
│  │ • Search Bar (Jobs tab only)                              │ │
│  │ • Quick Filters                                            │ │
│  │ • Notification Icon                                        │ │
│  ├────────────────────────────────────────────────────────────┤ │
│  │ Content (Tab-based):                                       │ │
│  │ • Jobs Feed: Browse & Apply                               │ │
│  │ • Applied: Track Applications                             │ │
│  │ • Profile: User Info                                       │ │
│  ├────────────────────────────────────────────────────────────┤ │
│  │ Bottom Navigation:                                         │ │
│  │ • Jobs | Applied | Profile                                │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  Settings Page (/settings)                                       │
│  ├─ Account Tab                                                  │
│  ├─ Notifications Tab                                            │
│  └─ Security Tab                                                 │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              ↕️ HTTP/HTTPS
┌─────────────────────────────────────────────────────────────────┐
│                        API LAYER                                 │
│                     (NestJS Backend)                             │
│                    http://localhost:4000                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌───────────────────────────────────────────────────────┐     │
│  │ AUTHENTICATION MODULE (/auth)                          │     │
│  ├─────────────────────────────────────────────────────────┤    │
│  │ POST /auth/register                                     │     │
│  │   ├─ Hash password (bcrypt)                            │     │
│  │   ├─ Create user in DB                                 │     │
│  │   └─ Return JWT token                                  │     │
│  │                                                          │     │
│  │ POST /auth/login                                        │     │
│  │   ├─ Validate credentials                              │     │
│  │   ├─ Verify password hash                              │     │
│  │   └─ Generate JWT token                                │     │
│  │                                                          │     │
│  │ POST /auth/otp/request                                  │     │
│  │   ├─ Find/Create user by phone                         │     │
│  │   ├─ Generate 4-digit OTP                              │     │
│  │   ├─ Set expiry (10 min)                               │     │
│  │   └─ Return success                                     │     │
│  │                                                          │     │
│  │ POST /auth/otp/verify                                   │     │
│  │   ├─ Validate OTP & expiry                             │     │
│  │   ├─ Clear OTP from DB                                 │     │
│  │   └─ Return JWT token                                  │     │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                   │
│  ┌───────────────────────────────────────────────────────┐     │
│  │ JOBS MODULE (/jobs)                                    │     │
│  ├─────────────────────────────────────────────────────────┤    │
│  │ POST /jobs                                              │     │
│  │   └─ Create new job posting                            │     │
│  │                                                          │     │
│  │ GET /jobs                                               │     │
│  │   └─ List all jobs (with relations)                    │     │
│  │                                                          │     │
│  │ GET /jobs/:id                                           │     │
│  │   └─ Get single job details                            │     │
│  │                                                          │     │
│  │ PATCH /jobs/:id                                         │     │
│  │   └─ Update job posting                                │     │
│  │                                                          │     │
│  │ DELETE /jobs/:id                                        │     │
│  │   └─ Remove job posting                                │     │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                   │
│  ┌───────────────────────────────────────────────────────┐     │
│  │ APPLICATIONS MODULE (/applications)                    │     │
│  ├─────────────────────────────────────────────────────────┤    │
│  │ POST /applications                                      │     │
│  │   ├─ Check for duplicate                               │     │
│  │   └─ Create application (PENDING)                      │     │
│  │                                                          │     │
│  │ GET /applications/employer/:id                          │     │
│  │   └─ Get all applicants for employer                   │     │
│  │                                                          │     │
│  │ GET /applications/worker/:id                            │     │
│  │   └─ Get all applications by worker                    │     │
│  │                                                          │     │
│  │ PATCH /applications/:id                                 │     │
│  │   └─ Update application status                         │     │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              ↕️ Prisma ORM
┌─────────────────────────────────────────────────────────────────┐
│                      DATABASE LAYER                              │
│                     (SQLite + Prisma)                            │
│                  /server/prisma/dev.db                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────────────────────────────────────────┐           │
│  │ USER TABLE                                       │           │
│  ├───────────────────────────────────────────────────┤          │
│  │ • id (String, Primary Key, UUID)                 │           │
│  │ • email (String, Unique)                         │           │
│  │ • password (String, Hashed)                      │           │
│  │ • name (String)                                  │           │
│  │ • role (String: WORKER | EMPLOYER)               │           │
│  │ • phone (String?, Unique)                        │           │
│  │ • otp (String?)                                  │           │
│  │ • otpExpiry (DateTime?)                          │           │
│  │ • createdAt (DateTime)                           │           │
│  │ • updatedAt (DateTime)                           │           │
│  └───────────────────────────────────────────────────┘          │
│                                                                   │
│  ┌─────────────────────────────────────────────────┐           │
│  │ JOB TABLE                                        │           │
│  ├───────────────────────────────────────────────────┤          │
│  │ • id (String, Primary Key, UUID)                 │           │
│  │ • title (String)                                 │           │
│  │ • description (String)                           │           │
│  │ • location (String)                              │           │
│  │ • wage (String)                                  │           │
│  │ • employerId (String, Foreign Key → User)        │           │
│  │ • createdAt (DateTime)                           │           │
│  │ • updatedAt (DateTime)                           │           │
│  └───────────────────────────────────────────────────┘          │
│                                                                   │
│  ┌─────────────────────────────────────────────────┐           │
│  │ APPLICATION TABLE                                │           │
│  ├───────────────────────────────────────────────────┤          │
│  │ • id (String, Primary Key, UUID)                 │           │
│  │ • jobId (String, Foreign Key → Job)              │           │
│  │ • workerId (String, Foreign Key → User)          │           │
│  │ • status (String: PENDING | ACCEPTED | REJECTED) │           │
│  │ • createdAt (DateTime)                           │           │
│  │ • updatedAt (DateTime)                           │           │
│  └───────────────────────────────────────────────────┘          │
│                                                                   │
│  Relationships:                                                  │
│  • User (EMPLOYER) ──< Jobs (one-to-many)                       │
│  • User (WORKER) ──< Applications (one-to-many)                 │
│  • Job ──< Applications (one-to-many)                           │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow Examples

### Example 1: Worker Applies to Job
```
1. Worker clicks "Apply Now" on job card
   ↓
2. Frontend: POST /applications { jobId, workerId }
   ↓
3. Backend: ApplicationsService checks for duplicate
   ↓
4. Backend: Creates application with status="PENDING"
   ↓
5. Database: INSERT into Application table
   ↓
6. Backend: Returns created application
   ↓
7. Frontend: Shows "Applied Successfully!" alert
   ↓
8. Worker navigates to "Applied" tab to see status
```

### Example 2: Employer Posts Job
```
1. Employer fills "Post New Job" form
   ↓
2. Frontend: POST /jobs { title, description, location, wage }
   ↓
3. Backend: JobsService creates job
   ↓
4. Database: INSERT into Job table with employerId
   ↓
5. Backend: Returns created job
   ↓
6. Frontend: Closes dialog, refreshes job list
   ↓
7. Employer sees new job in table immediately
```

### Example 3: OTP Login Flow
```
1. Worker enters phone number "9876543210"
   ↓
2. Frontend: POST /auth/otp/request { phone }
   ↓
3. Backend: Finds/Creates user with role="WORKER"
   ↓
4. Backend: Generates OTP "1234", sets 10-min expiry
   ↓
5. Database: UPDATE user SET otp, otpExpiry
   ↓
6. Backend: Returns { message: "OTP sent" }
   ↓
7. Frontend: Shows OTP input field
   ↓
8. Worker enters "1234"
   ↓
9. Frontend: POST /auth/otp/verify { phone, otp }
   ↓
10. Backend: Validates OTP & expiry
   ↓
11. Backend: Clears OTP, generates JWT token
   ↓
12. Frontend: Stores token in localStorage
   ↓
13. Frontend: Redirects to /worker dashboard
```

## 🔐 Security Flow

```
Registration/Login
       ↓
   JWT Token Generated
       ↓
   Stored in localStorage
       ↓
Protected Routes Check Token
       ↓
   ┌─────────┬─────────┐
   │         │         │
 Valid    Invalid   Expired
   │         │         │
Access   Redirect  Redirect
Granted  to /auth  to /auth
```

## 🎨 Component Hierarchy

```
App (Next.js App Router)
│
├─ Landing Page (/)
│  ├─ Header (Navigation)
│  ├─ Hero Section
│  ├─ Stats Cards
│  ├─ Features Grid
│  └─ Footer
│
├─ Auth Pages (/auth/*)
│  ├─ Login Page
│  │  ├─ Worker Tab (OTP Form)
│  │  └─ Employer Tab (Email/Password Form)
│  │
│  └─ Register Page
│     ├─ Role Tabs (Worker/Employer)
│     └─ Registration Form
│
├─ Employer Dashboard (/employer)
│  ├─ ProtectedRoute Wrapper
│  ├─ Sidebar
│  │  ├─ Dashboard Button
│  │  ├─ Applicants Button
│  │  ├─ Settings Button
│  │  └─ Logout Button
│  │
│  └─ Main Content
│     ├─ Post Job Dialog
│     ├─ KPI Cards
│     ├─ Jobs Table
│     │  ├─ Search Input
│     │  ├─ Job Rows
│     │  └─ Edit/Delete Actions
│     │
│     └─ Applicants Table
│
├─ Worker Dashboard (/worker)
│  ├─ ProtectedRoute Wrapper
│  ├─ Header
│  │  ├─ Search Bar
│  │  └─ Notification Icons
│  │
│  ├─ Tab Content
│  │  ├─ Jobs Tab
│  │  │  └─ Job Cards (with Apply button)
│  │  │
│  │  ├─ Applied Tab
│  │  │  └─ Application Cards
│  │  │
│  │  └─ Profile Tab
│  │
│  └─ Bottom Navigation
│
└─ Settings Page (/settings)
   ├─ ProtectedRoute Wrapper
   └─ Tabs
      ├─ Account Tab
      ├─ Notifications Tab
      └─ Security Tab
```

## 📊 State Management

```
Frontend State (React Hooks):
│
├─ Authentication State
│  ├─ token (localStorage)
│  └─ user (localStorage)
│
├─ Dashboard State
│  ├─ jobs (useState)
│  ├─ loading (useState)
│  ├─ searchQuery (useState)
│  ├─ activeTab (useState)
│  └─ applicants (useState)
│
└─ Form State
   ├─ title, description, etc. (useState)
   └─ validation errors (useState)

Backend State (NestJS Services):
│
├─ Stateless (JWT-based auth)
└─ Database as single source of truth
```

## 🚀 Deployment Ready

```
Current: Development
├─ Frontend: localhost:3000
├─ Backend: localhost:4000
└─ Database: Local SQLite file

Production: Cloud Ready
├─ Frontend: Vercel / Netlify
├─ Backend: AWS / DigitalOcean / Heroku
├─ Database: PostgreSQL (Supabase / Railway)
└─ CDN: Cloudflare
```

---

**This architecture supports:**
- ✅ Horizontal scaling
- ✅ Microservices migration
- ✅ API versioning
- ✅ Multi-tenancy
- ✅ Real-time features (WebSocket ready)
- ✅ Third-party integrations
