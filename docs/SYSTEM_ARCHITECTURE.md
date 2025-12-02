# Fisk Voting System - Multi-Tier Client-Server Architecture

## Architecture Overview

The Fisk Voting System follows a **3-Tier Client-Server Architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION TIER                        │
│                  (Client - Next.js/React)                   │
└─────────────────────────────────────────────────────────────┘
                            ↕ HTTP/HTTPS
                            ↕ REST API
                            ↕ JWT Tokens
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION TIER                          │
│              (Server - Laravel/PHP Backend)                  │
└─────────────────────────────────────────────────────────────┘
                            ↕ SQL Queries
                            ↕ ORM (Eloquent)
┌─────────────────────────────────────────────────────────────┐
│                      DATA TIER                               │
│              (Database - MySQL/PostgreSQL)                   │
└─────────────────────────────────────────────────────────────┘
```

---

## Tier 1: Presentation Tier (Client Layer)

### Technology Stack
- **Framework**: Next.js 16.0.5 (React 19.2.0)
- **Language**: TypeScript 5
- **Styling**: Tailwind CSS 4
- **State Management**: 
  - Zustand (Global State)
  - React Query (Server State)
- **HTTP Client**: Axios 1.13.2
- **Authentication**: JWT (stored in cookies)

### Component Structure

#### Public Layer
```
Public Pages
├── Home Page (/)
├── Elections Page (/elections) - Public API
├── Blog Page (/blog)
├── About Page (/about)
├── FAQ Page (/faq)
└── 404 Page (/not-found)

Shared Components
├── PublicHeader (Navigation, Top Bar)
└── PublicFooter (Sitemap, Links)
```

#### Authentication Layer
```
Auth Pages
├── Login (/login)
├── Register (/register)
├── Email Verified (/email-verified)
├── Forgot Password (/forgot-password)
└── Reset Password (/reset-password)
```

#### Protected Dashboard Layer
```
Dashboard Pages
├── Dashboard Home (/dashboard)
├── Elections List (/dashboard/elections)
├── Election Details (/dashboard/elections/[id])
├── Vote Page (/dashboard/vote)
├── Voting Ballot (/dashboard/vote/[id])
├── Voting History (/dashboard/vote/history)
├── Results List (/dashboard/results)
├── Election Results (/dashboard/results/[id])
├── Calendar (/dashboard/calendar)
├── Settings (/dashboard/settings)
└── Profile (/dashboard/profile)

Shared Components
├── DashboardLayout (Sidebar, Navigation)
└── ProtectedRoute (Auth Guard)
```

### Client-Side Services

#### API Service Layer
```
Services/
├── authService.ts
│   ├── login()
│   ├── logout()
│   ├── register()
│   ├── refresh()
│   └── me()
│
├── electionService.ts
│   ├── getAllElections()
│   ├── getActiveElections()
│   ├── getElection(id)
│   └── getPublicElections()
│
├── voteService.ts
│   ├── getBallot(electionId)
│   ├── castVote(electionId, voteData)
│   └── getMyVotes()
│
└── resultsService.ts
    ├── getElectionResults(electionId)
    └── getAllResults()
```

#### State Management
```
State Stores
├── authStore.ts (Zustand)
│   ├── isAuthenticated
│   ├── user
│   ├── token
│   ├── setAuth()
│   └── clearAuth()
│
└── React Query Cache
    ├── ["elections", "all"]
    ├── ["elections", "active"]
    ├── ["elections", id]
    ├── ["votes", "mine"]
    ├── ["userSessions"]
    ├── ["auditLogs"]
    └── ["calendar", "events"]
```

### Communication Protocol
- **Protocol**: HTTP/HTTPS
- **Format**: JSON
- **Authentication**: JWT Bearer Token (Cookie-based)
- **Base URL**: `http://localhost:8000/api/v1` (Development)
- **CORS**: Configured for specific origins
- **Timeout**: 15 seconds

---

## Tier 2: Application Tier (Server Layer)

### Technology Stack
- **Framework**: Laravel 12.0
- **Language**: PHP 8.2+
- **Admin Panel**: Filament 4.0
- **Authentication**: JWT (tymon/jwt-auth)
- **Permissions**: Spatie Laravel Permission
- **Queue**: Laravel Queue (for emails)

### Layer Structure

#### API Layer (RESTful)
```
API Routes (/api/v1/students)
├── Public Routes
│   ├── POST /register
│   ├── POST /login
│   ├── GET /public/elections
│   └── GET /email/verify/{id}/{hash}
│
└── Protected Routes (auth:api middleware)
    ├── Authentication
    │   ├── POST /logout
    │   ├── POST /refresh
    │   └── GET /me
    │
    ├── Elections
    │   ├── GET /elections
    │   ├── GET /elections/active
    │   └── GET /elections/{id}
    │
    ├── Voting
    │   ├── GET /elections/{id}/ballot
    │   ├── POST /elections/{id}/vote
    │   └── GET /votes
    │
    ├── Results
    │   ├── GET /elections/results
    │   └── GET /elections/{id}/results
    │
    ├── Profile
    │   ├── POST /me/profile-photo
    │   └── POST /me/change-password
    │
    ├── Audit Logs
    │   └── GET /me/audit-logs
    │
    ├── Sessions
    │   ├── GET /me/sessions
    │   ├── DELETE /me/sessions/{jti}
    │   ├── DELETE /me/sessions/others
    │   └── DELETE /me/sessions/all
    │
    ├── Calendar
    │   └── GET /calendar/events
    │
    └── Analytics
        └── GET /analytics
```

#### Controller Layer
```
Controllers/Api/Students/
├── StudentAuthController
│   ├── login()
│   ├── logout()
│   ├── refresh()
│   └── me()
│
├── StudentRegistrationController
│   └── register()
│
├── StudentElectionController
│   ├── getPublicElections()
│   ├── getAllElections()
│   ├── getActiveElections()
│   └── getElection(id)
│
├── StudentVoteController
│   ├── getBallot(electionId)
│   ├── castVote(electionId)
│   └── getMyVotes()
│
├── StudentResultsController
│   ├── getAllResults()
│   └── getElectionResults(electionId)
│
├── StudentProfileController
│   ├── updateProfilePhoto()
│   └── changePassword()
│
├── StudentAuditLogController
│   └── getMyAuditLogs()
│
├── StudentSessionController
│   ├── getUserSessions()
│   ├── revokeSession(jti)
│   ├── revokeAllOtherSessions()
│   └── revokeAllSessions()
│
├── StudentCalendarController
│   └── getEvents()
│
└── StudentAnalyticsController
    └── getAnalytics()
```

#### Service Layer (Business Logic)
```
Services/
├── ElectionResultsService
│   ├── calculateElectionResults()
│   ├── calculatePositionResults()
│   ├── calculateRankedChoiceWinner()
│   ├── calculateSingleChoiceResults()
│   └── calculateMultipleChoiceResults()
│
├── AuditLogService
│   ├── log()
│   ├── logAuth()
│   ├── logUserAction()
│   └── logVoteSubmission()
│
└── SessionService
    ├── createSession()
    ├── getUserSessions()
    ├── revokeSession()
    ├── revokeAllOtherSessions()
    ├── revokeAllSessions()
    └── parseUserAgent()
```

#### Model Layer (Data Access)
```
Models/
├── User
│   ├── Relationships: Votes, Sessions, Organizations
│   ├── Methods: isEligibleForUser(), hasUserVoted()
│   └── JWT: getJWTCustomClaims()
│
├── Election
│   ├── Relationships: Positions, Candidates, Votes
│   ├── Methods: isEligibleForUser(), hasUserVoted()
│   └── Computed: current_status
│
├── ElectionPosition
│   ├── Relationships: Election, Candidates
│   └── Type: single, multiple, ranked
│
├── ElectionCandidate
│   ├── Relationships: Position, User
│   └── Fields: photo, tagline, bio, manifesto
│
├── Vote
│   ├── Relationships: Election, User
│   └── Data: vote_data (JSON)
│
├── AuditLog
│   ├── Fields: action_type, user_id, ip_address, etc.
│   └── Relationships: User
│
└── UserJwtSession
    ├── Relationships: User
    └── Fields: jti, device_info, expires_at
```

#### Middleware Layer
```
Middleware/
├── auth:api (JWT Authentication)
├── log.api.activity (Automatic API logging)
└── CORS (Cross-Origin Resource Sharing)
```

#### Observer Layer
```
Observers/
└── AuditLogObserver
    ├── created()
    ├── updated()
    └── deleted()
```

#### Event Listener Layer
```
Listeners/
├── LogUserLogin
├── LogUserLogout
├── LogUserRegistration
├── LogFailedLogin
└── LogPasswordReset
```

#### Admin Panel (Filament)
```
Filament Resources/
├── Elections
├── ElectionPositions
├── ElectionCandidates
├── Votes
├── Users
├── AuditLogs
├── Departments
├── Majors
├── Organizations
└── Settings (Application, Email, Logging)

Filament Widgets/
├── StatsOverviewWidget
├── ActiveElectionsWidget
├── RecentVotesWidget
├── ParticipationRateWidget
├── ElectionStatusChartWidget
└── VotingActivityChartWidget
```

---

## Tier 3: Data Tier (Database Layer)

### Database System
- **RDBMS**: MySQL / PostgreSQL
- **ORM**: Laravel Eloquent
- **Migrations**: Version-controlled schema

### Database Schema

#### Core Tables
```
users
├── Primary Key: id
├── Indexes: email, university_email, student_id
├── Relationships:
│   ├── hasMany: Votes, UserJwtSessions
│   ├── belongsTo: Department, Major
│   └── belongsToMany: Organizations
└── Key Fields: email, password, name, class_level, major_id, department_id

elections
├── Primary Key: id
├── Indexes: status, start_time, end_time
├── Relationships:
│   ├── hasMany: Positions, Candidates, Votes
│   └── Computed: current_status
└── Key Fields: title, type, start_time, end_time, eligible_groups (JSON)

election_positions
├── Primary Key: id
├── Foreign Key: election_id
├── Indexes: election_id
├── Relationships:
│   ├── belongsTo: Election
│   └── hasMany: Candidates
└── Key Fields: name, type, max_selection, ranking_levels

election_candidates
├── Primary Key: id
├── Foreign Keys: election_position_id, user_id
├── Indexes: election_position_id, user_id
├── Unique: (user_id, election_position_id)
├── Relationships:
│   ├── belongsTo: Position, User
└── Key Fields: photo_url, tagline, bio, manifesto, approved

votes
├── Primary Key: id
├── Foreign Keys: election_id, voter_id
├── Indexes: election_id, voter_id
├── Unique: (election_id, voter_id)
├── Relationships:
│   ├── belongsTo: Election, User
└── Key Fields: vote_data (JSON), voted_at

audit_logs
├── Primary Key: id
├── Foreign Key: user_id (nullable)
├── Indexes: user_id, action_type, created_at
├── Relationships:
│   └── belongsTo: User (nullable)
└── Key Fields: action_type, action_description, ip_address, user_agent, device_info

user_jwt_sessions
├── Primary Key: id
├── Foreign Key: user_id
├── Unique: jti
├── Indexes: user_id, jti, expires_at
├── Relationships:
│   └── belongsTo: User
└── Key Fields: jti, ip_address, device_info, expires_at, is_current
```

#### Supporting Tables
```
departments
├── Primary Key: id
└── Fields: name, description

majors
├── Primary Key: id
└── Fields: name, description

organizations
├── Primary Key: id
└── Fields: name, description, type

organization_user (Pivot)
├── Foreign Keys: organization_id, user_id
└── Purpose: Many-to-many relationship

logging_settings
├── Primary Key: id
└── Fields: enable_activity_logs, enable_auth_logs, etc.

application_settings
├── Primary Key: id
└── Fields: key, value (JSON)

email_settings
├── Primary Key: id
└── Fields: Various email configuration
```

---

## Data Flow Architecture

### Authentication Flow
```
1. Client → POST /api/v1/students/login
   ├── Request: { email, password }
   │
2. Server → Validate credentials
   ├── Check user exists
   ├── Verify password (bcrypt)
   ├── Generate JWT token
   ├── Create session record (JTI)
   ├── Log audit event
   │
3. Server → Response: { token, user, expires_at }
   │
4. Client → Store token in cookie
   ├── Update auth state (Zustand)
   ├── Set Axios default header
   │
5. Client → Redirect to /dashboard
```

### Voting Flow
```
1. Client → GET /api/v1/students/elections/{id}/ballot
   ├── Request: JWT token in header
   │
2. Server → Validate JWT
   ├── Check user eligibility
   ├── Check if already voted
   ├── Load positions and candidates
   │
3. Server → Response: { election, positions, candidates, has_voted }
   │
4. Client → Display ballot form
   ├── User selects candidates
   ├── Validate form (Zod)
   │
5. Client → POST /api/v1/students/elections/{id}/vote
   ├── Request: { votes: { position_1: candidate_id, ... } }
   │
6. Server → Validate vote
   ├── Check eligibility
   ├── Check duplicate vote
   ├── Validate vote data structure
   ├── Store vote in database
   ├── Log audit event
   │
7. Server → Response: { success, message, vote_id }
   │
8. Client → Show success message
   ├── Redirect to results or history
```

### Results Calculation Flow
```
1. Client → GET /api/v1/students/elections/{id}/results
   │
2. Server → ElectionResultsService
   ├── Load election and positions
   ├── Load all votes for election
   │
3. For each position:
   ├── Filter votes for position
   ├── Determine position type
   ├── Calculate based on type:
   │   ├── Single: Count candidate votes
   │   ├── Multiple: Count all selections
   │   └── Ranked: Run IRV algorithm
   ├── Calculate percentages
   ├── Determine winner
   │
4. Server → Response: { election, positions, results }
   │
5. Client → Display results
   ├── Charts (Recharts)
   ├── Tables
   └── Round-by-round (ranked choice)
```

### Session Management Flow
```
1. Client → GET /api/v1/students/me/sessions
   │
2. Server → SessionService
   ├── Get all active sessions for user
   ├── Parse device info
   ├── Mark current session (by JTI)
   │
3. Server → Response: { sessions: [...] }
   │
4. Client → Display sessions
   ├── Show device, browser, IP, location
   ├── Highlight current session
   │
5. Client → DELETE /api/v1/students/me/sessions/{jti}
   │
6. Server → Delete session record
   ├── Invalidate JWT (if current)
   ├── Log audit event
   │
7. Server → Response: { success }
```

---

## Security Architecture

### Authentication & Authorization
```
┌─────────────────┐
│   Client        │
│   (Browser)     │
└────────┬────────┘
         │
         │ 1. Login Request
         ▼
┌─────────────────┐
│   Laravel API   │
│   Controller    │
└────────┬────────┘
         │
         │ 2. Validate Credentials
         ▼
┌─────────────────┐
│   JWT Auth      │
│   (tymon/jwt)   │
└────────┬────────┘
         │
         │ 3. Generate Token (JTI)
         ▼
┌─────────────────┐
│   Database      │
│   (Sessions)    │
└─────────────────┘
         │
         │ 4. Return Token
         ▼
┌─────────────────┐
│   Client        │
│   (Store Cookie)│
└─────────────────┘
```

### Request Flow with Middleware
```
HTTP Request
    │
    ▼
┌─────────────────┐
│   CORS          │
│   Middleware    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   JWT Auth      │
│   Middleware    │
│   (auth:api)    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Log Activity  │
│   Middleware    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Controller    │
│   (Business)    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Service       │
│   (Logic)       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Model/ORM     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Database      │
└─────────────────┘
```

---

## Component Interaction Diagram

### Frontend Component Hierarchy
```
App (Next.js)
├── Layout
│   ├── PublicHeader (Navigation)
│   └── PublicFooter
│
├── Pages
│   ├── HomePage
│   ├── ElectionsPage
│   │   └── usePublicElections() hook
│   ├── BlogPage
│   ├── AboutPage
│   ├── FAQPage
│   ├── LoginPage
│   │   └── useLogin() hook
│   ├── RegisterPage
│   │   └── useRegister() hook
│   └── DashboardLayout
│       ├── DashboardHome
│       │   ├── useAllElections()
│       │   ├── useAnalytics()
│       │   └── Charts (Recharts)
│       ├── ElectionsList
│       │   └── useAllElections()
│       ├── VotePage
│       │   └── useActiveElections()
│       ├── VotingBallot
│       │   ├── useBallot()
│       │   └── useCastVote()
│       ├── ResultsPage
│       │   └── useElectionResults()
│       ├── CalendarPage
│       │   └── useCalendarEvents()
│       └── SettingsPage
│           ├── useAuditLogs()
│           └── useSessions()
│
└── Providers
    ├── QueryClient (React Query)
    ├── ThemeProvider (next-themes)
    └── AuthProvider (Zustand)
```

### Backend Service Interaction
```
API Request
    │
    ▼
Controller
    │
    ├──→ Validate Request (Form Requests)
    │
    ├──→ Authenticate (JWT Middleware)
    │
    ├──→ Authorize (Spatie Permissions)
    │
    ▼
Service Layer
    │
    ├──→ Business Logic
    │
    ├──→ AuditLogService.log() (if needed)
    │
    ├──→ SessionService (if auth-related)
    │
    ▼
Model Layer
    │
    ├──→ Eloquent ORM
    │
    ├──→ Database Query
    │
    ├──→ Observer (AuditLogObserver)
    │
    ▼
Database
    │
    └──→ Return Data
```

---

## External Services & Integrations

### Email Service
```
Laravel Mail
    │
    ├──→ SMTP Server
    │   └──→ Email Delivery
    │
    ├──→ Queue System
    │   └──→ Background Processing
    │
    └──→ Custom Mail Channel
        └──→ EmailSettings Model
```

### File Storage
```
File Upload
    │
    ├──→ Laravel Storage
    │   ├──→ Local Storage (Development)
    │   └──→ Public Storage (Production)
    │
    └──→ Media Library (Spatie)
        └──→ URL Generation
```

---

## Deployment Architecture

### Development Environment
```
┌─────────────────┐         ┌─────────────────┐
│   Next.js Dev   │  ←→     │  Laravel Serve  │
│   (Port 3000)   │         │  (Port 8000)    │
└─────────────────┘         └────────┬─────────┘
                                     │
                                     ▼
                            ┌─────────────────┐
                            │   MySQL/Postgres │
                            │   (Local/Remote) │
                            └─────────────────┘
```

### Production Environment (Recommended)
```
┌─────────────────────────────────────────┐
│         CDN / Load Balancer             │
└──────────────┬──────────────────────────┘
               │
       ┌───────┴───────┐
       │               │
┌──────▼──────┐  ┌─────▼──────┐
│  Next.js    │  │  Next.js    │
│  Server 1   │  │  Server 2   │
│  (Port 3000)│  │  (Port 3000)│
└──────┬──────┘  └─────┬───────┘
       │               │
       └───────┬───────┘
               │
       ┌───────▼───────┐
       │  API Gateway  │
       └───────┬───────┘
               │
       ┌───────▼───────┐
       │               │
┌──────▼──────┐  ┌─────▼──────┐
│  Laravel    │  │  Laravel   │
│  Server 1   │  │  Server 2  │
│  (Port 8000)│  │  (Port 8000)│
└──────┬──────┘  └─────┬───────┘
       │               │
       └───────┬───────┘
               │
       ┌───────▼───────┐
       │   Database    │
       │   (Primary)   │
       └───────┬───────┘
               │
       ┌───────▼───────┐
       │   Database   │
       │   (Replica)  │
       └──────────────┘
```

---

## Technology Stack by Tier

### Presentation Tier
| Component | Technology | Purpose |
|-----------|-----------|---------|
| UI Framework | Next.js 16.0.5 | Server-side rendering, routing |
| UI Library | React 19.2.0 | Component-based UI |
| Language | TypeScript 5 | Type safety |
| Styling | Tailwind CSS 4 | Utility-first CSS |
| State (Global) | Zustand 5.0.8 | Global state management |
| State (Server) | React Query 5.90.11 | Server state, caching |
| Forms | React Hook Form + Zod | Form validation |
| HTTP Client | Axios 1.13.2 | API communication |
| Charts | Recharts 3.5.1 | Data visualization |
| Calendar | PrimeReact 10.9.7 | Calendar component |
| Icons | Lucide React | Icon library |
| Theming | next-themes | Dark/light mode |

### Application Tier
| Component | Technology | Purpose |
|-----------|-----------|---------|
| Framework | Laravel 12.0 | PHP framework |
| Language | PHP 8.2+ | Server-side logic |
| Admin Panel | Filament 4.0 | Admin interface |
| Auth | tymon/jwt-auth | JWT authentication |
| Permissions | Spatie Permission | Role-based access |
| ORM | Eloquent | Database abstraction |
| Queue | Laravel Queue | Background jobs |
| Mail | Laravel Mail | Email sending |
| Media | Spatie Media Library | File management |

### Data Tier
| Component | Technology | Purpose |
|-----------|-----------|---------|
| Database | MySQL/PostgreSQL | Relational database |
| ORM | Eloquent | Object-relational mapping |
| Migrations | Laravel Migrations | Schema versioning |

---

## Communication Protocols

### Client ↔ Server
- **Protocol**: HTTP/HTTPS
- **Format**: JSON
- **Authentication**: JWT Bearer Token
- **Storage**: HTTP-only cookies (client-side)
- **CORS**: Configured for specific origins
- **Timeout**: 15 seconds

### Server ↔ Database
- **Protocol**: SQL (via PDO)
- **ORM**: Eloquent
- **Connection**: Persistent connections
- **Transactions**: Supported

### Server ↔ External Services
- **Email**: SMTP
- **File Storage**: Local filesystem / S3 (configurable)

---

## Data Flow Patterns

### Read Pattern (Query)
```
Client Request
    ↓
Axios Interceptor (Add JWT)
    ↓
Laravel API Route
    ↓
JWT Middleware (Validate)
    ↓
Controller Method
    ↓
Service Layer (Business Logic)
    ↓
Model (Eloquent Query)
    ↓
Database
    ↓
Response (JSON)
    ↓
React Query Cache
    ↓
Component Render
```

### Write Pattern (Mutation)
```
Client Form Submit
    ↓
Form Validation (Zod)
    ↓
Axios POST Request
    ↓
Laravel API Route
    ↓
JWT Middleware (Validate)
    ↓
Controller Method
    ↓
Service Layer (Business Logic)
    ↓
AuditLogService.log() (Log Action)
    ↓
Model (Eloquent Save)
    ↓
Observer (AuditLogObserver - Log Change)
    ↓
Database Transaction
    ↓
Response (JSON)
    ↓
React Query Invalidation
    ↓
UI Update
```

---

## Scalability Considerations

### Horizontal Scaling
- **Stateless API**: JWT tokens enable stateless authentication
- **Load Balancing**: Multiple Laravel instances can share database
- **CDN**: Static assets can be served via CDN
- **Database Replication**: Read replicas for query distribution

### Caching Strategy
- **React Query**: Client-side caching (2-5 minutes)
- **Laravel Cache**: Server-side caching (configurable)
- **Database Indexing**: Optimized queries

### Performance Optimizations
- **Eager Loading**: Eloquent relationships
- **Pagination**: All lists paginated
- **Lazy Loading**: Code splitting in Next.js
- **Image Optimization**: Next.js Image component

---

## Security Layers

### Layer 1: Network Security
- HTTPS/TLS encryption
- CORS configuration
- Rate limiting

### Layer 2: Authentication
- JWT token-based auth
- Token expiration
- Refresh token mechanism
- Session tracking

### Layer 3: Authorization
- Role-based access control (Spatie)
- Permission checks
- Route protection

### Layer 4: Data Security
- Password hashing (bcrypt)
- SQL injection protection (Eloquent)
- XSS protection (React escaping)
- Input validation (Laravel + Zod)

### Layer 5: Audit & Monitoring
- Comprehensive audit logging
- Session tracking
- Error logging
- Activity monitoring

---

## Integration Points

### Internal Integrations
```
┌─────────────────┐
│   Frontend      │
│   (Next.js)     │
└────────┬────────┘
         │ REST API
         ▼
┌─────────────────┐
│   Backend API  │
│   (Laravel)    │
└────────┬────────┘
         │
         ├──→ Database
         ├──→ Queue (Emails)
         ├──→ Storage (Files)
         └──→ Cache
```

### External Integrations (Future)
- Email Service (SMTP/SendGrid)
- File Storage (AWS S3)
- Analytics (Google Analytics)
- Monitoring (Sentry, New Relic)

---

## Error Handling Architecture

### Frontend Error Handling
```
API Error
    ↓
Axios Interceptor
    ↓
Error Response
    ↓
React Query onError
    ↓
Toast Notification
    ↓
User Feedback
```

### Backend Error Handling
```
Exception
    ↓
Laravel Exception Handler
    ↓
Log Error (if needed)
    ↓
AuditLogService (if user action)
    ↓
JSON Response (Error Format)
    ↓
Client Receives Error
```

---

## Monitoring & Logging Architecture

### Logging Flow
```
User Action / System Event
    ↓
AuditLogService
    ↓
AuditLog Model
    ↓
Database (audit_logs table)
    ↓
Admin Panel (View Logs)
    ↓
User Dashboard (View Own Logs)
```

### Log Types
- **Authentication**: Login, logout, failed attempts
- **Voting**: Vote submissions
- **Profile**: Changes, password updates
- **System**: Model changes, API calls
- **Errors**: Exceptions, failures

---

## File Structure Summary

### Backend Structure
```
backend/
├── app/
│   ├── Http/Controllers/Api/Students/  (10 controllers)
│   ├── Services/                      (3 services)
│   ├── Models/                        (11 models)
│   ├── Middleware/                    (1 middleware)
│   ├── Observers/                     (1 observer)
│   ├── Listeners/                     (5 listeners)
│   └── Filament/                      (Admin resources)
├── database/
│   ├── migrations/                    (28 migrations)
│   └── seeders/                       (1 comprehensive seeder)
└── routes/
    └── api/v1/students.php            (API routes)
```

### Frontend Structure
```
client/src/
├── app/                               (Next.js pages)
│   ├── (auth)/                        (Auth pages)
│   ├── (dashboard)/                   (Dashboard pages)
│   ├── dashboard/                     (Dashboard routes)
│   ├── about/                         (Public pages)
│   ├── blog/
│   ├── elections/
│   └── faq/
├── components/                        (React components)
│   ├── common/
│   ├── dashboard/
│   ├── elections/
│   ├── forms/
│   ├── layout/
│   └── ui/
├── hooks/                             (Custom hooks)
├── services/                          (API services)
├── lib/                               (Utilities)
└── store/                             (Zustand stores)
```

---

## Database Relationships Diagram

```
users
  ├──→ hasMany: votes
  ├──→ hasMany: user_jwt_sessions
  ├──→ belongsTo: departments
  ├──→ belongsTo: majors
  └──→ belongsToMany: organizations

elections
  ├──→ hasMany: election_positions
  ├──→ hasMany: election_candidates (through positions)
  └──→ hasMany: votes

election_positions
  ├──→ belongsTo: elections
  ├──→ hasMany: election_candidates
  └──→ hasMany: votes (through election)

election_candidates
  ├──→ belongsTo: election_positions
  └──→ belongsTo: users

votes
  ├──→ belongsTo: elections
  └──→ belongsTo: users (voter)

audit_logs
  └──→ belongsTo: users (nullable)

user_jwt_sessions
  └──→ belongsTo: users
```

---

## API Request/Response Flow

### Standard API Flow
```
1. Client prepares request
   ├── Get JWT from cookie
   ├── Add to Authorization header
   └── Include request data

2. Axios interceptor
   ├── Add JWT token
   ├── Add Content-Type
   └── Handle errors

3. Laravel receives request
   ├── CORS check
   ├── JWT validation
   ├── Route matching
   └── Middleware execution

4. Controller processes
   ├── Validate input
   ├── Call service
   ├── Handle business logic
   └── Prepare response

5. Response sent
   ├── JSON format
   ├── Status code
   └── Data payload

6. Client receives
   ├── React Query cache
   ├── Update state
   └── Re-render UI
```

---

## Session & Token Lifecycle

```
1. User Login
   ├── Credentials validated
   ├── JWT token generated (with JTI)
   ├── Session created in database
   └── Token returned to client

2. Token Storage
   ├── Stored in HTTP-only cookie
   ├── Set in Axios default header
   └── Cached in Zustand store

3. Token Usage
   ├── Included in every API request
   ├── Validated by middleware
   └── User identified from token

4. Token Refresh
   ├── Automatic refresh before expiration
   ├── New token issued
   └── Session updated

5. Token Expiration
   ├── Token expires
   ├── Refresh attempted
   └── If refresh fails → logout

6. User Logout
   ├── Token invalidated
   ├── Session deleted from database
   └── Cookie cleared
```

---

## Deployment Considerations

### Environment Variables

#### Backend (.env)
```
APP_ENV=production
APP_DEBUG=false
DB_CONNECTION=mysql
DB_HOST=...
DB_DATABASE=...
JWT_SECRET=...
FRONTEND_URL=https://...
CORS_ALLOWED_ORIGINS=...
```

#### Frontend (.env.local)
```
NEXT_PUBLIC_API_URL=https://api.example.com/api/v1
NEXT_PUBLIC_APP_URL=https://example.com
```

### Build Process
```
Frontend:
  npm run build → Static/SSR pages
  npm start → Production server

Backend:
  composer install --optimize-autoloader
  php artisan config:cache
  php artisan route:cache
  php artisan view:cache
  php artisan migrate --force
```

---

## Architecture Diagram Summary

### High-Level Architecture
```
┌─────────────────────────────────────────────────────────┐
│                    CLIENT TIER                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │  Next.js │  │  React   │  │  Browser │            │
│  │  (SSR)   │  │  (SPA)   │  │  (Client)│            │
│  └──────────┘  └──────────┘  └──────────┘            │
└────────────────────┬──────────────────────────────────┘
                      │ HTTP/HTTPS + JWT
                      │ REST API
                      ▼
┌─────────────────────────────────────────────────────────┐
│                  APPLICATION TIER                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │ Laravel  │  │ Filament │  │  Queue   │            │
│  │   API    │  │  Admin   │  │  Worker  │            │
│  └──────────┘  └──────────┘  └──────────┘            │
│       │              │              │                  │
│       └──────┬────────┴──────────────┘                 │
│              │                                          │
│       ┌──────▼──────┐                                  │
│       │  Services   │                                  │
│       │  Layer      │                                  │
│       └──────┬──────┘                                  │
└──────────────┼─────────────────────────────────────────┘
               │ SQL/ORM
               ▼
┌─────────────────────────────────────────────────────────┐
│                     DATA TIER                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │  MySQL   │  │  Cache   │  │ Storage  │            │
│  │/Postgres │  │  (Redis) │  │  (Files) │            │
│  └──────────┘  └──────────┘  └──────────┘            │
└─────────────────────────────────────────────────────────┘
```

---

## Component Communication Patterns

### Request-Response Pattern
- **Synchronous**: Most API calls
- **Asynchronous**: Email sending (queue)

### Event-Driven Pattern
- **Model Events**: Observers for audit logging
- **Laravel Events**: Listeners for auth events

### State Management Pattern
- **Server State**: React Query (cached, synchronized)
- **Client State**: Zustand (local, persistent)
- **Form State**: React Hook Form (local, temporary)

---

## Summary

This architecture provides:

1. **Separation of Concerns**: Clear boundaries between tiers
2. **Scalability**: Horizontal scaling support
3. **Security**: Multiple security layers
4. **Maintainability**: Modular, organized code
5. **Performance**: Caching, optimization strategies
6. **Reliability**: Error handling, logging, monitoring
7. **Flexibility**: Easy to extend and modify

The system is designed to handle:
- **Concurrent Users**: Multiple simultaneous voters
- **Large Datasets**: 160+ elections, 500+ users
- **Complex Voting**: Multiple voting types
- **Real-time Results**: Live result calculation
- **Comprehensive Auditing**: Full activity tracking

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Purpose**: Architecture documentation for diagram generation

