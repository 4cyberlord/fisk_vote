# Fisk Voting System - Comprehensive Application Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [Architecture Overview](#architecture-overview)
4. [Backend Implementation](#backend-implementation)
5. [Frontend Implementation](#frontend-implementation)
6. [Database Structure](#database-structure)
7. [API Endpoints](#api-endpoints)
8. [Authentication & Security](#authentication--security)
9. [Voting System](#voting-system)
10. [Admin Panel (Filament)](#admin-panel-filament)
11. [Public Pages](#public-pages)
12. [Dashboard Features](#dashboard-features)
13. [Settings & Profile Management](#settings--profile-management)
14. [Audit Logging System](#audit-logging-system)
15. [Session Management](#session-management)
16. [Calendar Integration](#calendar-integration)
17. [UI/UX Components](#uiux-components)
18. [Data Seeding](#data-seeding)
19. [Testing & Development](#testing--development)

---

## Project Overview

The **Fisk Voting System** is a comprehensive, modern campus election management platform designed for Fisk University. It provides a secure, transparent, and user-friendly system for conducting various types of elections including student government, class representatives, residence hall elections, club officer elections, and department-specific elections.

### Key Objectives
- **Democracy**: Enable every student to participate in campus governance
- **Security**: Ensure vote integrity and data protection
- **Transparency**: Provide clear audit trails and real-time results
- **Accessibility**: Support voting from any device, anywhere
- **Efficiency**: Streamline election management for administrators

---

## Technology Stack

### Backend
- **Framework**: Laravel 12.0 (PHP 8.2+)
- **Admin Panel**: Filament 4.0
- **Authentication**: JWT (tymon/jwt-auth 2.2)
- **Permissions**: Spatie Laravel Permission 6.23
- **Database**: MySQL/PostgreSQL (via Laravel migrations)
- **Email**: Laravel Mail with custom channels
- **Media**: Spatie Media Library Plugin

### Frontend
- **Framework**: Next.js 16.0.5 (React 19.2.0)
- **Language**: TypeScript 5
- **Styling**: Tailwind CSS 4
- **State Management**: 
  - Zustand 5.0.8 (global state)
  - React Query 5.90.11 (server state)
- **Forms**: React Hook Form 7.66.1 + Zod 4.1.13
- **UI Libraries**:
  - Lucide React (icons)
  - PrimeReact 10.9.7 (calendar)
  - Recharts 3.5.1 (charts)
  - Radix UI (accessible components)
- **Theming**: next-themes 0.4.6 (dark/light mode)
- **HTTP Client**: Axios 1.13.2

---

## Architecture Overview

### Backend Architecture
```
backend/
├── app/
│   ├── Console/Commands/          # Artisan commands
│   ├── Filament/                   # Admin panel resources
│   ├── Http/
│   │   ├── Controllers/Api/       # API controllers
│   │   ├── Middleware/            # Custom middleware
│   │   └── Requests/               # Form requests
│   ├── Listeners/                 # Event listeners
│   ├── Models/                    # Eloquent models
│   ├── Notifications/             # Email notifications
│   ├── Observers/                 # Model observers
│   ├── Providers/                 # Service providers
│   └── Services/                  # Business logic services
├── database/
│   ├── migrations/                # Database migrations
│   ├── seeders/                   # Data seeders
│   └── factories/                 # Model factories
└── routes/
    └── api/v1/                    # API routes
```

### Frontend Architecture
```
client/src/
├── app/                           # Next.js App Router
│   ├── (auth)/                    # Auth route group
│   ├── (dashboard)/               # Dashboard route group
│   ├── dashboard/                 # Dashboard pages
│   ├── about/                     # Public pages
│   ├── blog/
│   ├── elections/
│   └── faq/
├── components/                    # React components
│   ├── common/                    # Shared components
│   ├── dashboard/                  # Dashboard-specific
│   ├── elections/                 # Election components
│   ├── forms/                     # Form components
│   ├── layout/                    # Layout components
│   └── ui/                        # UI primitives
├── hooks/                         # Custom React hooks
├── lib/                           # Utilities & configs
├── services/                      # API service layer
└── store/                         # Zustand stores
```

---

## Backend Implementation

### Models

#### User Model
- **Purpose**: Represents students, admins, and all system users
- **Key Features**:
  - JWT authentication integration
  - Email verification
  - Profile photo support
  - Student-specific fields (class_level, major, department, etc.)
  - Role-based permissions (Spatie)
  - Organization memberships
- **Relationships**:
  - Has many Votes
  - Belongs to Department, Major
  - Belongs to many Organizations
  - Has many UserJwtSessions

#### Election Model
- **Purpose**: Represents campus elections
- **Key Features**:
  - Multiple election types (single, multiple, ranked, referendum, poll)
  - Eligibility rules (universal, department-based, class-level, organization-based)
  - Time-based status (upcoming, active, closed)
  - Write-in and abstain options
- **Relationships**:
  - Has many Positions
  - Has many Candidates
  - Has many Votes
- **Methods**:
  - `isEligibleForUser()`: Checks if a user can vote
  - `hasUserVoted()`: Checks if user already voted
  - `current_status`: Computed property for election status

#### ElectionPosition Model
- **Purpose**: Represents positions within an election
- **Key Features**:
  - Position-specific voting types
  - Max selection limits
  - Ranking levels for ranked-choice
  - Abstain option
- **Relationships**:
  - Belongs to Election
  - Has many Candidates

#### ElectionCandidate Model
- **Purpose**: Represents candidates running for positions
- **Key Features**:
  - Candidate profiles (tagline, bio, manifesto)
  - Photo support
  - Approval workflow
- **Relationships**:
  - Belongs to ElectionPosition
  - Belongs to User

#### Vote Model
- **Purpose**: Stores individual votes
- **Key Features**:
  - JSON-based vote data storage
  - Supports all voting types
  - Unique constraint per voter per election
  - Timestamps for audit
- **Relationships**:
  - Belongs to Election
  - Belongs to User (voter)

#### AuditLog Model
- **Purpose**: Comprehensive activity logging
- **Key Features**:
  - User actions tracking
  - Authentication events
  - System changes
  - IP address and device tracking
  - Error logging
- **Fields**: action_type, action_description, user_id, ip_address, user_agent, device_info, location, changes_summary, error_message

#### UserJwtSession Model
- **Purpose**: Tracks active JWT sessions
- **Key Features**:
  - JTI (JWT ID) tracking
  - Device and browser information
  - IP address and location
  - Session expiration
  - Current session marking

### Services

#### ElectionResultsService
- **Purpose**: Calculate election results
- **Key Methods**:
  - `calculateElectionResults()`: Main entry point
  - `calculatePositionResults()`: Position-specific calculations
  - `calculateRankedChoiceWinner()`: Instant Runoff Voting algorithm
  - `calculateSingleChoiceResults()`: Simple majority
  - `calculateMultipleChoiceResults()`: Multi-selection counting
- **Features**:
  - Handles all voting types
  - Abstention tracking
  - Percentage calculations
  - Winner determination

#### AuditLogService
- **Purpose**: Centralized audit logging
- **Key Methods**:
  - `log()`: General activity logging
  - `logAuth()`: Authentication events
  - `logUserAction()`: User-specific actions
  - `logVoteSubmission()`: Vote events
- **Features**:
  - Automatic user detection (API/Web guards)
  - Device and browser parsing
  - IP geolocation (placeholder)
  - Change tracking

#### SessionService
- **Purpose**: JWT session management
- **Key Methods**:
  - `createSession()`: Create/update session on login
  - `getUserSessions()`: Get all active sessions
  - `revokeSession()`: Revoke specific session
  - `revokeAllOtherSessions()`: Logout from other devices
  - `revokeAllSessions()`: Logout from all devices
  - `parseUserAgent()`: Extract device/browser info
- **Features**:
  - JTI extraction from JWT
  - Device fingerprinting
  - Session expiration tracking

### Controllers

#### StudentAuthController
- **Endpoints**:
  - `POST /api/v1/students/login`: User authentication
  - `POST /api/v1/students/logout`: User logout
  - `POST /api/v1/students/refresh`: Token refresh
  - `GET /api/v1/students/me`: Get current user
- **Features**:
  - JWT token generation
  - Session creation on login
  - Audit logging for auth events
  - Email verification checks

#### StudentRegistrationController
- **Endpoints**:
  - `POST /api/v1/students/register`: User registration
- **Features**:
  - Email validation
  - Password hashing
  - Email verification sending
  - Student role assignment
  - Audit logging

#### StudentElectionController
- **Endpoints**:
  - `GET /api/v1/students/public/elections`: Public elections (no auth)
  - `GET /api/v1/students/elections`: All elections (auth required)
  - `GET /api/v1/students/elections/active`: Active elections
  - `GET /api/v1/students/elections/{id}`: Specific election
- **Features**:
  - Eligibility filtering
  - Status calculation
  - Vote status tracking

#### StudentVoteController
- **Endpoints**:
  - `GET /api/v1/students/elections/{id}/ballot`: Get ballot
  - `POST /api/v1/students/elections/{id}/vote`: Cast vote
  - `GET /api/v1/students/votes`: Voting history
- **Features**:
  - Vote validation
  - Duplicate prevention
  - Vote data storage
  - Audit logging

#### StudentResultsController
- **Endpoints**:
  - `GET /api/v1/students/elections/results`: All results
  - `GET /api/v1/students/elections/{id}/results`: Specific results
- **Features**:
  - Real-time result calculation
  - Position-wise breakdown
  - Candidate statistics

#### StudentProfileController
- **Endpoints**:
  - `POST /api/v1/students/me/profile-photo`: Update photo
  - `POST /api/v1/students/me/change-password`: Change password
- **Features**:
  - File upload handling
  - Password validation
  - Audit logging

#### StudentAuditLogController
- **Endpoints**:
  - `GET /api/v1/students/me/audit-logs`: User's audit logs
- **Features**:
  - Pagination
  - Filtering
  - Statistics

#### StudentSessionController
- **Endpoints**:
  - `GET /api/v1/students/me/sessions`: Get all sessions
  - `DELETE /api/v1/students/me/sessions/{jti}`: Revoke session
  - `DELETE /api/v1/students/me/sessions/others`: Revoke others
  - `DELETE /api/v1/students/me/sessions/all`: Revoke all
- **Features**:
  - Session listing
  - Device information
  - Current session detection

#### StudentCalendarController
- **Endpoints**:
  - `GET /api/v1/students/calendar/events`: Calendar events
- **Features**:
  - Election date extraction
  - Calendar format conversion

#### StudentAnalyticsController
- **Endpoints**:
  - `GET /api/v1/students/analytics`: User analytics
- **Features**:
  - Vote statistics
  - Election participation
  - Activity summaries

### Middleware

#### LogApiActivity
- **Purpose**: Automatically log authenticated API requests
- **Features**:
  - Skips noisy routes (refresh, me, login, logout)
  - Determines action type from HTTP method
  - Generates human-readable descriptions
  - Integrates with AuditLogService

### Observers & Listeners

#### AuditLogObserver
- **Purpose**: Automatic model change tracking
- **Tracks**: User, Election, ElectionPosition, ElectionCandidate, Vote changes

#### Event Listeners
- `LogUserLogin`: Login events
- `LogUserLogout`: Logout events
- `LogUserRegistration`: Registration events
- `LogFailedLogin`: Failed login attempts
- `LogPasswordReset`: Password reset events

---

## Frontend Implementation

### Pages

#### Public Pages

##### Home Page (`/`)
- **Features**:
  - Hero section with countdown timer
  - "Start to Participation" section
  - "About Our Campaign" section
  - "Our Upcoming Campaign" section
  - "Security & Transparency" section
  - Navigation with active state
  - Footer with comprehensive links
- **Components**: PublicHeader, PublicFooter

##### Elections Page (`/elections`)
- **Features**:
  - Public elections listing (no auth required)
  - Status filtering (All, Open, Upcoming, Closed)
  - Search functionality
  - Pagination (27 items per page)
  - Election cards with details
  - Real-time status badges
- **API**: `GET /api/v1/students/public/elections`

##### Blog Page (`/blog`)
- **Features**:
  - Featured post hero section
  - Category filtering
  - Search functionality
  - Post grid with pagination
  - Sidebar with categories, recent posts, popular posts
  - Newsletter signup
- **Content**: Mock data (15+ articles)

##### About Page (`/about`)
- **Features**:
  - Hero section
  - Statistics display
  - Mission & Vision
  - Core Values (6 values)
  - Why Choose Us section
  - Commitment section with CTA
- **Sections**: Story, Mission, Vision, Values, Features, Commitment

##### FAQ Page (`/faq`)
- **Features**:
  - Search functionality
  - Category filtering (6 categories)
  - Accordion-style Q&A
  - 15+ FAQ items
  - "Still Need Help" section
  - Contact support CTA

##### 404 Page (`/not-found`)
- **Features**:
  - Custom 404 design
  - Helpful suggestions
  - Navigation options
  - Brand-consistent styling

#### Authentication Pages

##### Login Page (`/login`)
- **Features**:
  - Email/password authentication
  - Remember me option
  - Error handling with visual feedback
  - Red border on errors
  - Full-page loader during auth check
  - Automatic redirect if authenticated
  - Form validation with Zod
- **API**: `POST /api/v1/students/login`

##### Register Page (`/register`)
- **Features**:
  - Student registration form
  - Email verification flow
  - Password strength requirements
  - Form validation
- **API**: `POST /api/v1/students/register`

##### Email Verified Page (`/email-verified`)
- **Features**:
  - Verification success message
  - Redirect to login

##### Forgot Password Page (`/forgot-password`)
- **Features**:
  - Password reset request
  - Email sending

##### Reset Password Page (`/reset-password`)
- **Features**:
  - Password reset form
  - Token validation

#### Dashboard Pages

##### Dashboard Home (`/dashboard`)
- **Features**:
  - Statistics cards
  - Active elections list (paginated, 9 per page)
  - Recent activity (paginated, 15 per page)
  - Charts (Recharts):
    - Election participation chart
    - Voting activity chart
  - Quick actions
  - Reactour integration (guided tour)
- **API**: Multiple endpoints for elections, analytics, votes

##### Elections List (`/dashboard/elections`)
- **Features**:
  - Table view with sorting
  - Status filtering
  - Search functionality
  - Pagination
  - View election details

##### Election Details (`/dashboard/elections/[id]`)
- **Features**:
  - Election information
  - Positions and candidates
  - Voting status
  - Eligibility check

##### Vote Page (`/dashboard/vote`)
- **Features**:
  - Active elections list
  - Pagination
  - Vote button

##### Voting Ballot (`/dashboard/vote/[id]`)
- **Features**:
  - Position sections
  - Candidate selection
  - Ranked-choice support
  - Multiple choice support
  - Write-in candidates
  - Abstain option
  - Form validation
  - Vote submission
- **API**: `GET /api/v1/students/elections/{id}/ballot`, `POST /api/v1/students/elections/{id}/vote`

##### Voting History (`/dashboard/vote/history`)
- **Features**:
  - Past votes display
  - Vote details per election
  - Ranked-choice vote display
  - Date and time stamps

##### Results List (`/dashboard/results`)
- **Features**:
  - All completed elections
  - Pagination
  - View results link

##### Election Results (`/dashboard/results/[id]`)
- **Features**:
  - Election summary
  - Position-wise results
  - Candidate vote counts
  - Charts (bar charts, pie charts)
  - Ranked-choice round-by-round results
  - Winner highlighting
- **API**: `GET /api/v1/students/elections/{id}/results`

##### Calendar Page (`/dashboard/calendar`)
- **Features**:
  - PrimeReact Calendar component
  - Date selection
  - Events listing
  - Filter by selected date
  - Pagination for events (5 per page)
  - Event details
- **API**: `GET /api/v1/students/calendar/events`

##### Settings Page (`/dashboard/settings`)
- **Features**:
  - Tabbed interface:
    - Security & Privacy
      - Change Password
      - Audit Logs (with pagination)
      - Active Sessions
      - Two-factor authentication (commented out)
    - Notifications (UI only)
    - Preferences (UI only)
      - Language & Region
    - Privacy (UI only)
    - Accessibility (UI only)
    - Account (UI only)
  - Session management:
    - View all sessions
    - Revoke individual sessions
    - Revoke all other sessions
    - Revoke all sessions
  - Custom confirmation modals
- **APIs**: 
  - `POST /api/v1/students/me/change-password`
  - `GET /api/v1/students/me/audit-logs`
  - `GET /api/v1/students/me/sessions`
  - `DELETE /api/v1/students/me/sessions/{jti}`

##### Profile Page (`/dashboard/profile`)
- **Features**:
  - User profile display
  - Profile photo update
  - Information editing

### Components

#### Layout Components

##### PublicHeader
- **Features**:
  - Top CTA bar (phone, email, social links, login/register)
  - Main navigation with active state
  - Logo and branding
  - Responsive design
  - Conditional "My account" link

##### PublicFooter
- **Features**:
  - Sitemap-style footer
  - Product links
  - About links
  - Help & Legal links
  - Account links
  - Copyright information
  - Social media links

##### DashboardLayout
- **Features**:
  - Sidebar navigation
  - User profile section
  - Navigation links with icons
  - Active route highlighting
  - Responsive mobile menu
  - Logout functionality

#### UI Components

##### Button
- **Variants**: default, outline
- **Features**: Size options, disabled states, loading states

##### Input
- **Features**: Error states, placeholder support, type variants

##### PasswordInput
- **Features**: Show/hide toggle, error states, validation

##### Checkbox
- **Features**: Label support, checked states

##### Pagination
- **Features**: Page numbers, previous/next, item counts, customizable

##### ConfirmationModal
- **Features**: Custom modal for confirmations, replace browser confirm()

#### Form Components

##### PasswordInput
- **Features**: Visibility toggle, validation, error display

#### Election Components

##### PositionSection
- **Purpose**: Renders election position with candidates
- **Features**: Supports all voting types, candidate display, selection handling

### Hooks

#### useAuth
- **Purpose**: Authentication state management
- **Hooks**:
  - `useLogin()`: Login mutation
  - `useLogout()`: Logout mutation
  - `useRegister()`: Registration mutation
  - `useMe()`: Current user query
  - `useRefresh()`: Token refresh

#### useElections
- **Purpose**: Election data management
- **Hooks**:
  - `useAllElections()`: All elections
  - `useActiveElections()`: Active elections
  - `useElection(id)`: Specific election
  - `useBallot(electionId)`: Ballot data
  - `useCastVote()`: Vote submission
  - `useMyVotes()`: Voting history
  - `useElectionResults(electionId)`: Results
  - `useAllResults()`: All results

#### usePublicElections
- **Purpose**: Public elections (no auth)
- **Hook**: `usePublicElections()`: Public elections list

#### useSessions
- **Purpose**: Session management
- **Hooks**:
  - `useSessions()`: Get all sessions
  - `useRevokeSession()`: Revoke one
  - `useRevokeAllOtherSessions()`: Revoke others
  - `useRevokeAllSessions()`: Revoke all

#### useAuditLogs
- **Purpose**: Audit log management
- **Hook**: `useAuditLogs()`: Get user's audit logs with pagination

#### useCalendarEvents
- **Purpose**: Calendar events
- **Hook**: `useCalendarEvents()`: Get election events

#### useTheme
- **Purpose**: Theme management (dark/light)
- **Hook**: `useTheme()`: Theme state and toggle

### Services

#### authService
- **Methods**:
  - `login(credentials)`: Authenticate user
  - `logout()`: Logout user
  - `register(data)`: Register new user
  - `refresh()`: Refresh token
  - `me()`: Get current user

#### electionService
- **Methods**:
  - `getAllElections()`: All elections
  - `getActiveElections()`: Active elections
  - `getElection(id)`: Specific election
  - `getPublicElections()`: Public elections

#### voteService
- **Methods**:
  - `getBallot(electionId)`: Get ballot
  - `castVote(electionId, voteData)`: Submit vote
  - `getMyVotes()`: Voting history

#### resultsService
- **Methods**:
  - `getElectionResults(electionId)`: Specific results
  - `getAllResults()`: All results

### State Management

#### Zustand Store (authStore)
- **Purpose**: Global authentication state
- **State**:
  - `isAuthenticated`: Boolean
  - `user`: User object
  - `token`: JWT token
- **Actions**:
  - `setAuth()`: Set auth state
  - `clearAuth()`: Clear auth state

---

## Database Structure

### Core Tables

#### users
- **Purpose**: All system users
- **Key Fields**:
  - `email`, `password`, `name`, `first_name`, `last_name`
  - `university_email`, `student_id`, `class_level`
  - `major_id`, `department_id`
  - `email_verified_at`, `profile_photo`
  - `status` (active, suspended, graduated)
- **Indexes**: email, university_email, student_id

#### elections
- **Purpose**: Election records
- **Key Fields**:
  - `title`, `description`, `type` (single, multiple, ranked, referendum, poll)
  - `max_selection`, `ranking_levels`
  - `allow_write_in`, `allow_abstain`, `is_universal`
  - `eligible_groups` (JSON)
  - `start_time`, `end_time`, `status` (draft, active, closed)
- **Indexes**: status, start_time, end_time

#### election_positions
- **Purpose**: Positions within elections
- **Key Fields**:
  - `election_id`, `name`, `description`
  - `type` (single, multiple, ranked)
  - `max_selection`, `ranking_levels`, `allow_abstain`
- **Indexes**: election_id

#### election_candidates
- **Purpose**: Candidates for positions
- **Key Fields**:
  - `election_position_id`, `user_id`
  - `photo_url`, `tagline`, `bio`, `manifesto`
  - `approved` (boolean)
- **Indexes**: election_position_id, user_id
- **Unique**: user_id + election_position_id

#### votes
- **Purpose**: Individual votes
- **Key Fields**:
  - `election_id`, `voter_id`
  - `vote_data` (JSON)
  - `voted_at`
- **Indexes**: election_id, voter_id
- **Unique**: election_id + voter_id

#### audit_logs
- **Purpose**: Activity logging
- **Key Fields**:
  - `action_type`, `action_description`
  - `user_id`, `ip_address`, `user_agent`
  - `device_type`, `browser`, `device_info`, `location`
  - `changes_summary`, `error_message`
  - `status` (success, failed, warning)
  - `created_at`
- **Indexes**: user_id, action_type, created_at

#### user_jwt_sessions
- **Purpose**: Active JWT sessions
- **Key Fields**:
  - `user_id`, `jti` (JWT ID)
  - `ip_address`, `user_agent`
  - `device_type`, `browser`, `device_info`, `location`
  - `last_activity`, `expires_at`
  - `is_current` (boolean)
- **Indexes**: user_id, jti, expires_at
- **Unique**: jti

### Supporting Tables

#### departments
- **Purpose**: Academic departments
- **Fields**: `name`, `description`

#### majors
- **Purpose**: Academic majors
- **Fields**: `name`, `description`

#### organizations
- **Purpose**: Student organizations
- **Fields**: `name`, `description`, `type`

#### organization_user (pivot)
- **Purpose**: User-organization memberships
- **Fields**: `organization_id`, `user_id`

#### logging_settings
- **Purpose**: Audit logging configuration
- **Fields**: `enable_activity_logs`, `enable_auth_logs`, etc.

#### application_settings
- **Purpose**: Application-wide settings
- **Fields**: `key`, `value` (JSON)

#### email_settings
- **Purpose**: Email configuration
- **Fields**: Various email service settings

---

## API Endpoints

### Public Endpoints (No Authentication)

#### `GET /api/v1/students/public/elections`
- **Purpose**: List all elections (public access)
- **Response**: Elections array with meta (open, upcoming, closed counts)
- **Use Case**: Public elections page

#### `POST /api/v1/students/register`
- **Purpose**: User registration
- **Body**: email, password, name, first_name, last_name, etc.
- **Response**: Success message, verification email sent

#### `POST /api/v1/students/login`
- **Purpose**: User authentication
- **Body**: email, password
- **Response**: JWT token, user data

#### `GET /api/v1/students/email/verify/{id}/{hash}`
- **Purpose**: Email verification
- **Response**: Redirects to frontend or returns JSON

### Protected Endpoints (JWT Required)

#### Authentication
- `POST /api/v1/students/logout`: Logout
- `POST /api/v1/students/refresh`: Refresh token
- `GET /api/v1/students/me`: Current user

#### Elections
- `GET /api/v1/students/elections`: All elections
- `GET /api/v1/students/elections/active`: Active elections
- `GET /api/v1/students/elections/{id}`: Specific election

#### Voting
- `GET /api/v1/students/elections/{id}/ballot`: Get ballot
- `POST /api/v1/students/elections/{id}/vote`: Cast vote
- `GET /api/v1/students/votes`: Voting history

#### Results
- `GET /api/v1/students/elections/results`: All results
- `GET /api/v1/students/elections/{id}/results`: Specific results

#### Profile
- `POST /api/v1/students/me/profile-photo`: Update photo
- `POST /api/v1/students/me/change-password`: Change password

#### Audit Logs
- `GET /api/v1/students/me/audit-logs`: User's audit logs

#### Sessions
- `GET /api/v1/students/me/sessions`: All sessions
- `DELETE /api/v1/students/me/sessions/{jti}`: Revoke session
- `DELETE /api/v1/students/me/sessions/others`: Revoke others
- `DELETE /api/v1/students/me/sessions/all`: Revoke all

#### Calendar
- `GET /api/v1/students/calendar/events`: Calendar events

#### Analytics
- `GET /api/v1/students/analytics`: User analytics

---

## Authentication & Security

### JWT Authentication
- **Library**: tymon/jwt-auth
- **Token Storage**: HTTP-only cookies (via js-cookie)
- **Token Refresh**: Automatic refresh mechanism
- **Custom Claims**: email, email_verified, jti (JWT ID)

### Session Management
- **JTI Tracking**: Each token has unique JTI stored in database
- **Session Records**: Device info, IP, browser, location
- **Session Revocation**: Can revoke individual or all sessions
- **Current Session**: Marked in database

### Security Features
- **Password Hashing**: bcrypt
- **CORS**: Configured for specific origins
- **Rate Limiting**: Email verification throttling
- **Input Validation**: Laravel validation + Zod on frontend
- **SQL Injection Protection**: Eloquent ORM
- **XSS Protection**: React's built-in escaping

### Email Verification
- **Flow**: Registration → Email sent → Click link → Verified
- **Signed URLs**: Laravel signed routes for security
- **Expiration**: Configurable expiration time

---

## Voting System

### Voting Types

#### Single Choice
- **Description**: One candidate per position
- **Storage**: Candidate ID in vote_data
- **Results**: Simple majority

#### Multiple Choice
- **Description**: Multiple candidates per position
- **Storage**: Array of candidate IDs
- **Results**: Vote counts per candidate

#### Ranked Choice (Instant Runoff Voting)
- **Description**: Rank candidates in order
- **Storage**: Array of objects `[{candidate_id, rank}]`
- **Results**: IRV algorithm with elimination rounds
- **Algorithm**: 
  1. Count first-choice votes
  2. If majority, winner declared
  3. Otherwise, eliminate lowest, redistribute
  4. Repeat until winner

#### Referendum
- **Description**: Yes/No questions
- **Storage**: Boolean value
- **Results**: Yes vs No counts

#### Poll
- **Description**: Quick polls
- **Storage**: Selected option
- **Results**: Option counts

### Vote Storage Format
```json
{
  "position_1": candidate_id,
  "position_2": [candidate_id1, candidate_id2],
  "position_3": [
    {"candidate_id": 1, "rank": 1},
    {"candidate_id": 2, "rank": 2}
  ],
  "position_4_abstain": true
}
```

### Eligibility System
- **Universal Elections**: All students eligible
- **Department-Based**: Specific departments
- **Class-Level**: Freshman, Sophomore, Junior, Senior, Graduate
- **Organization-Based**: Organization members
- **Combined Rules**: Multiple criteria

---

## Admin Panel (Filament)

### Resources

#### Elections Resource
- **Features**: CRUD operations, status management, position/candidate management
- **Tables**: List view with filters, search, sorting
- **Forms**: Comprehensive election creation/editing
- **Infolists**: Detailed election view

#### Election Positions Resource
- **Features**: Position management within elections
- **Relationships**: Linked to elections and candidates

#### Election Candidates Resource
- **Features**: Candidate management
- **Relationships**: Linked to positions and users
- **Media**: Photo upload support

#### Votes Resource
- **Features**: Vote viewing (read-only for integrity)
- **Display**: Formatted vote data

#### Users Resource
- **Features**: User management
- **Roles**: Spatie permission integration
- **Profile**: Photo, student info management

#### Audit Logs Resource
- **Features**: Comprehensive log viewing
- **Filters**: By user, action type, date range
- **Infolists**: Detailed log information

#### Departments, Majors, Organizations Resources
- **Features**: Reference data management

#### Settings Resources
- **Application Settings**: App-wide configuration
- **Email Settings**: Email service configuration
- **Logging Settings**: Audit log configuration

### Widgets
- **Stats Overview**: Key metrics
- **Active Elections**: Current elections
- **Recent Votes**: Latest voting activity
- **Participation Rate**: Voting statistics
- **Election Status Chart**: Visual status breakdown
- **Voting Activity Chart**: Activity over time

### Custom Pages
- **Election Results**: Detailed results view
- **Student Panel**: Separate student interface (Filament)

---

## Public Pages

### Home Page
- **Sections**:
  - Hero with countdown timer
  - "Start to Participation" feature section
  - "About Our Campaign" section
  - "Our Upcoming Campaign" section
  - "Security & Transparency" section
- **Features**: Responsive design, brand colors, CTA buttons

### Elections Page
- **Features**: Public access, filtering, search, pagination
- **Design**: Card-based layout, status badges

### Blog Page
- **Features**: Featured post, categories, search, pagination
- **Content**: Mock articles (ready for CMS integration)

### About Page
- **Sections**: Story, Mission, Vision, Values, Features, Commitment
- **Design**: Professional, engaging layout

### FAQ Page
- **Features**: Search, categories, accordion Q&A
- **Content**: 15+ comprehensive FAQs

### 404 Page
- **Features**: Helpful navigation, brand-consistent design

---

## Dashboard Features

### Main Dashboard
- **Statistics Cards**: Total elections, votes, participation
- **Active Elections**: Paginated list (9 per page)
- **Recent Activity**: Paginated list (15 per page)
- **Charts**: Participation and activity visualizations
- **Tour**: Reactour integration for onboarding

### Elections Management
- **List View**: Table with sorting, filtering, search
- **Detail View**: Full election information
- **Voting Interface**: Ballot with all voting types

### Results Viewing
- **List**: All completed elections
- **Detail**: Position-wise results with charts
- **Ranked Choice**: Round-by-round breakdown

### Calendar
- **Component**: PrimeReact Calendar
- **Features**: Date selection, event filtering, pagination

### Voting History
- **Display**: Past votes with details
- **Formats**: Supports all voting types

---

## Settings & Profile Management

### Settings Page Structure
- **Tabs**: Security & Privacy, Notifications, Preferences, Privacy, Accessibility, Account
- **Active Sections**:
  - Change Password (connected to API)
  - Audit Logs (connected to API, paginated)
  - Active Sessions (connected to API)

### Password Management
- **Features**: Current password validation, strength requirements
- **Security**: Old password verification
- **Audit**: Password changes logged

### Audit Logs
- **Features**: 
  - Filtering by type
  - Pagination
  - Detailed information (IP, device, location)
  - Statistics (successful logins, failed attempts, etc.)

### Session Management
- **Features**:
  - View all active sessions
  - Device and browser information
  - Current session indicator
  - Revoke individual sessions
  - Revoke all other sessions
  - Revoke all sessions
- **UI**: Custom confirmation modals

---

## Audit Logging System

### Automatic Logging
- **Model Changes**: Via Observer pattern
- **API Activity**: Via Middleware
- **Authentication**: Via Event Listeners
- **User Actions**: Via explicit service calls

### Logged Events
- **Authentication**: Login, logout, failed login, registration
- **Voting**: Vote submission
- **Profile**: Photo update, password change
- **System**: Model changes, API calls

### Log Information
- **User**: User ID and email
- **Action**: Type and description
- **Context**: IP address, user agent, device info
- **Location**: IP-based geolocation (placeholder)
- **Changes**: Before/after values
- **Errors**: Error messages for failures

### Log Viewing
- **Admin Panel**: Full access to all logs
- **User Dashboard**: Own logs only
- **Filtering**: By type, date, user
- **Pagination**: Efficient data loading

---

## Session Management

### JWT Session Tracking
- **JTI Storage**: Each token's JTI stored in database
- **Session Creation**: On login
- **Session Updates**: Last activity tracking
- **Session Expiration**: Based on JWT expiration

### Device Information
- **User Agent Parsing**: Browser and device detection
- **IP Address**: Stored for security
- **Location**: IP-based (placeholder for geolocation)

### Session Operations
- **List**: View all active sessions
- **Revoke One**: Logout from specific device
- **Revoke Others**: Logout from all other devices
- **Revoke All**: Complete logout

---

## Calendar Integration

### Calendar Component
- **Library**: PrimeReact Calendar
- **Features**: 
  - Date selection
  - Month/year navigation
  - Event highlighting
  - Custom styling

### Events Display
- **Source**: Elections from database
- **Format**: Start/end dates from elections
- **Filtering**: By selected date
- **Pagination**: 5 events per page

### API Integration
- **Endpoint**: `/api/v1/students/calendar/events`
- **Response**: Formatted calendar events

---

## UI/UX Components

### Design System
- **Colors**: 
  - Primary: `#f4ba1b` (gold/yellow)
  - Secondary: Indigo, slate grays
  - Brand: Dark blue (`#0a1a44`), dark red (`#8b0000`)
- **Typography**: System fonts, clear hierarchy
- **Spacing**: Consistent Tailwind spacing scale

### Component Library
- **Buttons**: Multiple variants, animations, hover effects
- **Inputs**: Error states, validation feedback
- **Modals**: Custom confirmation modals
- **Cards**: Consistent card design
- **Pagination**: Reusable pagination component

### Responsive Design
- **Mobile-First**: All components mobile-optimized
- **Breakpoints**: sm, md, lg, xl
- **Navigation**: Mobile menu, responsive tables

### Animations
- **Transitions**: Smooth hover effects
- **Loading States**: Spinners and skeletons
- **Form Feedback**: Error animations
- **Button Effects**: Shine, scale, gradient transitions

### Accessibility
- **ARIA Labels**: Proper labeling
- **Keyboard Navigation**: Full keyboard support
- **Screen Readers**: Semantic HTML
- **Color Contrast**: WCAG compliant

---

## Data Seeding

### Database Seeder
- **Purpose**: Comprehensive test data generation
- **Scope**: 160+ elections, 500+ users, full scenarios

### Generated Data

#### Users (500+)
- **Scenarios**:
  - Verified/unverified emails
  - Active/suspended/graduated status
  - Various class levels
  - Multiple departments and majors
  - Organization memberships
  - With/without profile photos
- **Admin Users**: 3 admin accounts created

#### Elections (160+)
- **Types**: All voting types represented
- **Statuses**: Draft, active, closed
- **Scenarios**:
  - Universal elections
  - Department-specific
  - Class-level specific
  - Organization-specific
  - Combined eligibility rules
- **Templates**: Realistic college campus election scenarios

#### Votes
- **Coverage**: Votes for all closed elections
- **Types**: All voting types represented
- **Eligibility**: Respects election eligibility rules

### Seed Commands
```bash
php artisan db:seed
```

---

## Testing & Development

### Development Setup
- **Backend**: `php artisan serve`
- **Frontend**: `npm run dev`
- **Queue**: `php artisan queue:listen`
- **Logs**: `php artisan pail`

### Environment Configuration
- **Backend**: `.env` file
- **Frontend**: `.env.local` (optional)
- **Database**: MySQL/PostgreSQL
- **CORS**: Configured for localhost:3000

### Key Configuration Files
- **CORS**: `backend/config/cors.php`
- **JWT**: `backend/config/jwt.php`
- **Auth**: `backend/config/auth.php`
- **Mail**: `backend/config/mail.php`

---

## Additional Features

### Command Palette
- **Trigger**: Ctrl+K / Cmd+K
- **Features**: Search and navigate to sections
- **Implementation**: Frontend-only, keyboard shortcuts

### Theme Support
- **Library**: next-themes
- **Modes**: Light, Dark, System
- **Implementation**: Theme provider, persistent storage

### Email System
- **Notifications**: Email verification, password reset
- **Channels**: Custom mail channel
- **Queue**: Background email processing

### File Uploads
- **Profile Photos**: Image upload support
- **Storage**: Public storage, URL generation

---

## Security Considerations

### Implemented
- JWT token-based authentication
- Password hashing (bcrypt)
- Email verification
- CORS configuration
- Input validation
- SQL injection protection (Eloquent)
- XSS protection (React)
- Session management
- Audit logging
- Rate limiting

### Best Practices
- Secure password requirements
- Token expiration
- HTTPS recommended for production
- Environment variable security
- Database query optimization

---

## Performance Optimizations

### Frontend
- React Query caching
- Component lazy loading
- Image optimization
- Code splitting (Next.js)
- Pagination for large lists

### Backend
- Database indexing
- Query optimization
- Eager loading relationships
- Caching strategies
- Queue for heavy operations

---

## Future Enhancements (Potential)

### Identified Areas
- Real-time notifications
- Email notifications for elections
- Advanced analytics
- Export functionality
- Mobile app
- Two-factor authentication (UI ready)
- Advanced search
- Candidate profiles
- Campaign management
- Live results streaming

---

## Conclusion

The Fisk Voting System is a comprehensive, production-ready platform for managing campus elections. It combines modern web technologies with robust security practices to provide a secure, transparent, and user-friendly voting experience. The system supports multiple voting types, comprehensive audit logging, session management, and a full-featured admin panel, making it suitable for various election scenarios at Fisk University.

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Maintained By**: Development Team

