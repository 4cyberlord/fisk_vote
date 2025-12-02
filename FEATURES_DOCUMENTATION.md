# Fisk Voting System - Complete Features Documentation

**Last Updated:** December 2024  
**Version:** 1.0

---

## Table of Contents

1. [Admin Panel Features (Filament)](#admin-panel-features-filament)
2. [Student Panel Features (Filament)](#student-panel-features-filament)
3. [Student Client Application (Next.js)](#student-client-application-nextjs)
4. [API Endpoints](#api-endpoints)
5. [Technical Implementation Details](#technical-implementation-details)

---

## Admin Panel Features (Filament)

### Overview
The admin panel is built using Filament v4 and provides comprehensive management capabilities for the voting system.

### 1. User Management

#### 1.1 Students Management (`/admin/students`)
- **CRUD Operations:**
  - Create new student accounts
  - View student details with comprehensive information
  - Edit student profiles
  - List all students with filtering and search
- **Features:**
  - Student profile management
  - Email verification status tracking
  - Department and major assignments
  - Organization memberships
  - Profile photo management

#### 1.2 Departments Management (`/admin/departments`)
- **CRUD Operations:**
  - Create, read, update, delete departments
  - View department details
  - List all departments
- **Features:**
  - Department name and code management
  - Relationship with students and majors

#### 1.3 Majors Management (`/admin/majors`)
- **CRUD Operations:**
  - Create, read, update, delete majors
  - View major details
  - List all majors
- **Features:**
  - Major name and code management
  - Department associations

#### 1.4 Organizations Management (`/admin/organizations`)
- **CRUD Operations:**
  - Create, read, update, delete organizations
  - View organization details
  - List all organizations
- **Features:**
  - Organization name and description
  - Student membership tracking

### 2. Election Management

#### 2.1 Elections Resource (`/admin/elections`)
- **CRUD Operations:**
  - Create new elections
  - View election details
  - Edit existing elections
  - List all elections with filtering
- **Key Features:**
  - **Election Types:**
    - Single-choice elections
    - Multiple-choice elections
    - Ranked-choice elections
  - **Election Configuration:**
    - Title and description
    - Start and end times
    - Maximum selections (for multiple-choice)
    - Ranking levels (for ranked-choice)
    - Write-in candidate allowance
    - Abstain option availability
    - Universal vs. restricted eligibility
  - **Eligibility Settings:**
    - Department-based eligibility
    - Class level restrictions
    - Organization-based eligibility
    - Manual student selection
  - **Status Management:**
    - Draft, Active, Closed, Archived
    - Automatic status calculation (Open, Upcoming, Closed)
  - **Voting Window:**
    - Dynamic status display
    - Countdown timers
    - Time-based status badges

#### 2.2 Election Positions (`/admin/election-positions`)
- **CRUD Operations:**
  - Create positions for elections
  - View position details
  - Edit positions
  - List all positions
- **Features:**
  - Position name and description
  - Election associations
  - Candidate assignment

#### 2.3 Election Candidates (`/admin/election-candidates`)
- **CRUD Operations:**
  - Create candidate profiles
  - View candidate details
  - Edit candidate information
  - List all candidates
- **Features:**
  - Candidate approval workflow
  - Profile photo upload
  - Bio and tagline
  - Position assignment
  - User association
  - Photo URL management (local storage or external URLs)

#### 2.4 Votes Management (`/admin/votes`)
- **CRUD Operations:**
  - View all votes
  - View individual vote details
  - List votes with filtering
- **Features:**
  - Vote tracking and auditing
  - Election and voter associations
  - Vote timestamp tracking
  - Vote data (JSON) storage

### 3. System Settings

#### 3.1 Application Settings (`/admin/settings`)
- **Configuration Management:**
  - Application-wide settings
  - System configuration
  - Feature toggles

#### 3.2 Email Settings (`/admin/email-settings`)
- **Email Configuration:**
  - SMTP settings
  - Email templates
  - Notification preferences

#### 3.3 Logging Settings (`/admin/logging-settings`)
- **Logging Configuration:**
  - Log levels
  - Log retention
  - Audit trail settings

### 4. Roles & Permissions

#### 4.1 Roles Management (`/admin/roles`)
- **Features:**
  - Role creation and management
  - Permission assignment
  - User role assignment
  - Integration with Spatie Laravel Permission

### 5. Election Results

#### 5.1 Results Page (`/admin/election-results`)
- **Features:**
  - View election results
  - Results calculation and display
  - Export capabilities
  - Vote statistics
  - Winner determination
  - Results modal with detailed breakdown

### 6. Dashboard Widgets

#### 6.1 Stats Overview Widget
- Total elections count
- Active elections
- Total votes cast
- Participation rates

#### 6.2 Active Elections Widget
- List of currently active elections
- Quick access to election details

#### 6.3 Election Status Chart Widget
- Visual representation of election statuses
- Pie/bar charts for status distribution

#### 6.4 Voting Activity Chart Widget
- Voting activity over time
- Trend analysis

#### 6.5 Participation Rate Widget
- Participation statistics
- Percentage calculations

#### 6.6 Recent Votes Widget
- Latest votes cast
- Recent voting activity

---

## Student Panel Features (Filament)

### Overview
The student panel provides a Filament-based interface for students to interact with the voting system.

### 1. Authentication

#### 1.1 Login (`/student/login`)
- **Features:**
  - Email and password authentication
  - JWT token generation
  - Session management
  - Remember me functionality

#### 1.2 Registration (`/student/register`)
- **Features:**
  - Student account creation
  - Email verification requirement
  - Profile information collection
  - Department and major selection

#### 1.3 Email Verification (`/student/verify-email`)
- **Features:**
  - Email verification process
  - Verification link handling
  - Success confirmation

### 2. Elections

#### 2.1 Active Elections (`/student/elections`)
- **Features:**
  - **Election Listing:**
    - Display all active elections
    - Filter by status (Open, Upcoming, Closed)
    - Search functionality
  - **Voting Window Display:**
    - Human-readable time format
    - Dynamic countdown (days/hours remaining)
    - Status-based messages:
      - "Starts in X days/hours" (for upcoming)
      - "X days/hours remaining" (for active)
      - "Ended X days/hours ago" (for closed)
    - Color-coded badges:
      - Success (green) for active elections with >3 days
      - Warning (yellow) for active elections with 1-3 days
      - Danger (red) for active elections with <1 day
      - Info (blue) for upcoming elections
      - Gray for closed elections
  - **Navigation:**
    - Active navigation highlighting
    - Route pattern matching for sub-pages
  - **Quick Actions:**
    - View election details
    - Cast vote (if eligible and open)
    - View results (if closed)

#### 2.2 Election Details (`/student/elections/{id}`)
- **Features:**
  - **Election Information Section:**
    - Election title (large, bold)
    - Description (HTML formatted)
    - Election type badge
    - Voting window (human-readable format)
    - Start time and end time (separate fields with calendar icons)
    - Current status badge (color-coded)
    - Election status (draft/active/closed/archived)
    - Your Vote Status:
      - Shows "Voted on [date/time]" if voted (green badge)
      - Shows "No vote available" if not voted (red badge)
      - Displays `voted_at` timestamp from database
  - **Election Settings Section (Collapsible):**
    - Maximum selections (for multiple-choice)
    - Ranking levels (for ranked-choice)
    - Write-in candidates allowed (Yes/No badge)
    - Abstain option available (Yes/No badge)
  - **Eligibility Information Section (Collapsible):**
    - Universal election indicator
    - Eligibility details:
      - Department restrictions
      - Class level restrictions
      - Organization restrictions
      - Manual student selection count
  - **Candidates Section:**
    - Grouped by position
    - Candidate cards with:
      - Profile photo (circular, with fallback to UI Avatars)
      - Full name
      - Position badge
      - Bio/tagline (truncated)
      - Email link
      - View button
    - Grid layout (responsive: 1 column mobile, 2 tablet, 3 desktop)
    - Empty state with helpful message
    - Photo URL handling:
      - Supports local storage paths
      - Supports external URLs
      - Fallback to user profile photo
      - Fallback to UI Avatars API

#### 2.3 Ballot Page (`/student/ballot/{id}`)
- **Features:**
  - Voting interface
  - Candidate selection
  - Vote submission
  - Confirmation process

### 3. Profile Management

#### 3.1 Student Profile (`/student/profile`)
- **Features:**
  - View profile information
  - Edit profile details
  - Update profile photo
  - Change password
  - View voting history

### 4. Navigation & UX

#### 4.1 Navigation Active States
- **Implementation:**
  - Active navigation highlighting
  - Route pattern matching
  - Parent page navigation activation
  - Slug-based routing
- **Pages with Active Navigation:**
  - Active Elections
  - Election Details
  - Ballot
  - Profile

---

## Student Client Application (Next.js)

### Overview
A modern Next.js 14+ application with TypeScript, providing a responsive web interface for students.

### 1. Project Structure

#### 1.1 Directory Organization
```
client/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── (auth)/            # Authentication routes
│   │   ├── (dashboard)/       # Protected dashboard routes
│   │   ├── (public)/          # Public routes
│   │   ├── api/               # API route handlers
│   │   └── dashboard/         # Main dashboard pages
│   ├── components/            # React components
│   │   ├── ui/               # Reusable UI components
│   │   └── common/           # Common widgets
│   ├── lib/                   # Utilities and helpers
│   ├── hooks/                 # Custom React hooks
│   ├── services/              # API service layer
│   ├── store/                 # State management (Zustand)
│   ├── types/                 # TypeScript types
│   └── styles/                # Global styles
├── public/                    # Static assets
└── package.json
```

### 2. Authentication

#### 2.1 Login Page (`/login`)
- **Features:**
  - **Design:**
    - Split-screen layout (form left, image right)
    - Responsive design (mobile-first)
    - White background theme
    - Election-related image from Unsplash
    - Modern, clean UI
  - **Functionality:**
    - Email and password input
    - Remember me checkbox
    - Forgot password link
    - Form validation
    - Loading states
    - Error handling
    - JWT token storage (cookies)
    - Redirect to dashboard on success
  - **Accessibility:**
    - ARIA labels
    - Keyboard navigation
    - Touch-friendly targets (min 44px)
    - Screen reader support

#### 2.2 Registration Page (`/register`)
- **Features:**
  - Student registration form
  - Email verification flow
  - Profile information collection
  - Department and major selection

#### 2.3 Email Verification (`/email-verified`)
- **Features:**
  - Verification success confirmation
  - Redirect to login
  - Status messaging

#### 2.4 Password Reset
- **Features:**
  - Forgot password (`/forgot-password`)
  - Reset password (`/reset-password`)
  - Email-based reset flow

### 3. Dashboard

#### 3.1 Main Dashboard (`/dashboard`)
- **Features:**
  - **Welcome Section:**
    - Personalized greeting (Good morning/afternoon/evening)
    - User name display
    - Quick stats overview
  - **Statistics Cards:**
    - Total active elections
    - Total elections
    - Votes cast
    - Participation metrics
  - **Charts & Visualizations:**
    - Election status distribution (pie/bar chart)
    - Voting activity over time (line chart)
    - Participation rates
    - Custom tooltips and legends
  - **Active Elections List:**
    - Cards with election details
    - Status badges
    - Voting window information
    - Quick actions (View, Vote)
  - **Quick Actions:**
    - Cast a vote button
    - My vote history link
    - Profile link
    - "How voting works" dialog
  - **Recent Activity:**
    - Latest votes
    - Recent elections
  - **Animations:**
    - Framer Motion animations
    - Smooth transitions
    - Loading states

#### 3.2 Elections List (`/dashboard/elections`)
- **Features:**
  - List all elections
  - Filter by status
  - Search functionality
  - Election cards with details
  - Navigation to election details

#### 3.3 Election Details (`/dashboard/elections/[id]`)
- **Features:**
  - Comprehensive election information
  - Candidate listings
  - Voting interface (if eligible)
  - Results view (if closed)

#### 3.4 Voting Interface (`/dashboard/vote`)
- **Features:**
  - **Vote Selection:**
    - List of available elections
    - Eligibility checking
    - Status validation
  - **Ballot Page (`/dashboard/vote/[id]`):**
    - Candidate selection interface
    - Multiple-choice support
    - Ranked-choice support
    - Write-in candidate option
    - Abstain option
    - Vote submission
    - Confirmation dialog
    - Success/error handling

#### 3.5 Vote History (`/dashboard/vote/history`)
- **Features:**
  - List of all votes cast
  - Vote details
  - Timestamp information
  - Election associations
  - Vote data display

#### 3.6 Results (`/dashboard/results`)
- **Features:**
  - **Results List:**
    - All closed elections with results
    - Election cards with:
      - Title and description
      - End date
      - Total votes count
      - Trophy icon
      - "View Results" link
    - Empty state handling
    - Error handling with retry
    - Loading states
  - **Individual Results (`/dashboard/results/[id]`):**
    - Detailed results breakdown
    - Candidate vote counts
    - Percentage calculations
    - Charts and visualizations
    - Winner highlighting

#### 3.7 Profile (`/dashboard/profile`)
- **Features:**
  - **Profile Information:**
    - Personal details display
    - Email and contact information
    - Department and major
    - Organization memberships
  - **Profile Photo:**
    - Current photo display
    - Upload new photo
    - Photo preview
    - Crop/resize functionality
  - **Password Management:**
    - Change password form
    - Current password verification
    - New password confirmation
    - Password strength indicator
  - **Account Settings:**
    - Email preferences
    - Notification settings
    - Privacy settings

#### 3.8 Settings (`/dashboard/settings`)
- **Features:**
  - User preferences
  - Notification settings
  - Privacy controls
  - Account management

### 4. API Integration

#### 4.1 Axios Configuration (`lib/axios.ts`)
- **Features:**
  - Centralized API instance
  - Base URL configuration
  - Request interceptors:
    - JWT token injection
    - Content-Type headers
    - Request logging (for debugging)
  - Response interceptors:
    - Token refresh on 401
    - Error handling
    - Response logging
    - Automatic redirect to login on auth failure
  - **Token Management:**
    - Cookie-based storage
    - Automatic token refresh
    - Secure cookie settings (httpOnly, sameSite, secure in production)

#### 4.2 Service Layer (`services/electionService.ts`)
- **Services:**
  - `ElectionService`: Election data fetching
  - `VoteService`: Vote submission and management
  - `ResultsService`: Results retrieval
  - `AnalyticsService`: Analytics data
- **Features:**
  - Type-safe API calls
  - Error handling
  - Response transformation
  - Detailed error logging

### 5. State Management

#### 5.1 React Query (`hooks/useElections.ts`)
- **Hooks:**
  - `useAllElections`: Fetch all elections
  - `useActiveElections`: Fetch active elections
  - `useElection`: Fetch single election
  - `useMyVotes`: Fetch user's votes
  - `useAllResults`: Fetch all results
  - `useElectionResults`: Fetch single election results
  - `useCastVote`: Vote submission mutation
  - `useAnalytics`: Analytics data
- **Features:**
  - Automatic caching
  - Stale time configuration
  - Retry logic
  - Error handling
  - Loading states

#### 5.2 Authentication Context (`hooks/useAuth.ts`)
- **Features:**
  - User authentication state
  - Login/logout functions
  - Token management
  - Protected route handling
  - User data fetching

### 6. UI Components

#### 6.1 Reusable Components (`components/ui/`)
- **Button Component:**
  - Multiple variants (primary, secondary, outline)
  - Loading states
  - Disabled states
  - Full-width option
  - Icon support
- **Input Component:**
  - Text, email, password types
  - Validation states
  - Error messages
  - Placeholder support
- **Card Component:**
  - Flexible container
  - Header, body, footer sections
  - Hover effects
- **Modal Component:**
  - Dialog functionality
  - Overlay support
  - Close handlers
- **Other Components:**
  - Tooltip
  - Dropdown
  - Badge
  - Avatar

#### 6.2 Common Components (`components/common/`)
- **Sidebar:**
  - Navigation menu
  - Active state highlighting
  - Collapsible sections
- **Navbar:**
  - Top navigation
  - User menu
  - Notifications
- **Footer:**
  - Site information
  - Links
- **Theme Switcher:**
  - Light/dark mode toggle
  - Theme persistence

### 7. Styling & Design

#### 7.1 Tailwind CSS
- **Configuration:**
  - Custom color palette
  - Responsive breakpoints
  - Dark mode support
  - Custom utilities
- **Features:**
  - Mobile-first design
  - Responsive grid layouts
  - Consistent spacing
  - Typography system

#### 7.2 Global Styles (`styles/globals.css`)
- **Features:**
  - CSS resets
  - Cross-browser compatibility
  - Font smoothing
  - Input styling
  - Button touch targets
  - Smooth scrolling

### 8. Responsive Design

#### 8.1 Breakpoints
- Mobile: < 640px
- Tablet: 640px - 1024px
- Desktop: > 1024px

#### 8.2 Responsive Features
- Grid layouts adapt to screen size
- Navigation collapses on mobile
- Touch-friendly targets (min 44px)
- Optimized images
- Mobile-first approach

### 9. Error Handling

#### 9.1 API Error Handling
- **Features:**
  - Detailed error logging
  - User-friendly error messages
  - Retry mechanisms
  - Fallback UI states
  - Network error detection
  - 401/403/404 handling

#### 9.2 UI Error States
- Loading spinners
- Error messages
- Empty states
- Retry buttons
- Offline detection

### 10. Performance Optimizations

#### 10.1 Code Splitting
- Route-based code splitting
- Component lazy loading
- Dynamic imports

#### 10.2 Caching
- React Query caching
- API response caching
- Static asset caching

#### 10.3 Image Optimization
- Next.js Image component
- Lazy loading
- Responsive images
- Format optimization

---

## API Endpoints

### Base URL
- Development: `http://localhost:8000/api/v1`
- Production: `{PRODUCTION_URL}/api/v1`

### Authentication Endpoints

#### Public Routes

**POST `/students/register`**
- Register a new student account
- Returns: User data and verification email sent

**POST `/students/login`**
- Authenticate student
- Returns: JWT token and user data

**GET `/students/email/verify/{id}/{hash}`**
- Verify email address
- Returns: Verification status

#### Protected Routes (Require JWT)

**POST `/students/logout`**
- Logout current user
- Returns: Success message

**POST `/students/refresh`**
- Refresh JWT token
- Returns: New token

**GET `/students/me`**
- Get current user data
- Returns: User profile

### Profile Endpoints

**POST `/students/me/profile-photo`**
- Update profile photo
- Returns: Updated user data

**POST `/students/me/change-password`**
- Change password
- Returns: Success message

### Election Endpoints

**GET `/students/elections`**
- Get all elections (user eligible)
- Returns: Array of elections

**GET `/students/elections/active`**
- Get active elections
- Returns: Array of active elections

**GET `/students/elections/{id}`**
- Get single election details
- Returns: Election data with candidates

**GET `/students/elections/results`**
- Get all closed elections with results
- Returns: Array of election results summaries

**GET `/students/elections/{id}/results`**
- Get detailed results for an election
- Returns: Detailed results with vote counts

### Voting Endpoints

**GET `/students/votes`**
- Get user's voting history
- Returns: Array of votes

**GET `/students/elections/{id}/ballot`**
- Get ballot for an election
- Returns: Ballot data with candidates

**POST `/students/elections/{id}/vote`**
- Cast a vote
- Body: Vote data (JSON)
- Returns: Vote confirmation

### Analytics Endpoints

**GET `/students/analytics`**
- Get user analytics
- Returns: Analytics data

---

## Technical Implementation Details

### 1. Backend (Laravel)

#### 1.1 Framework & Version
- Laravel 11.x
- PHP 8.2+
- Filament v4

#### 1.2 Key Technologies
- **Authentication:** Laravel Sanctum / JWT
- **Database:** MySQL/PostgreSQL
- **File Storage:** Local/S3
- **Email:** Laravel Mail
- **Permissions:** Spatie Laravel Permission

#### 1.3 Database Models
- User (students)
- Election
- ElectionPosition
- ElectionCandidate
- Vote
- Department
- Major
- Organization
- ApplicationSetting
- EmailSetting
- LoggingSetting

#### 1.4 Services
- `ElectionResultsService`: Results calculation
- `ElectionService`: Election logic
- `VoteService`: Vote processing

### 2. Frontend (Next.js)

#### 2.1 Framework & Version
- Next.js 14+ (App Router)
- React 18+
- TypeScript 5+

#### 2.2 Key Dependencies
- **State Management:** @tanstack/react-query
- **HTTP Client:** axios
- **Animations:** framer-motion
- **Charts:** recharts
- **Icons:** lucide-react
- **Date Handling:** dayjs
- **Forms:** react-hook-form (planned)
- **Validation:** zod (planned)
- **Cookies:** js-cookie

#### 2.3 Project Structure Best Practices
- Industry-standard folder organization
- Separation of concerns
- Reusable components
- Type-safe API calls
- Centralized configuration

### 3. Security Features

#### 3.1 Authentication
- JWT token-based authentication
- Token refresh mechanism
- Secure cookie storage
- CSRF protection
- Rate limiting

#### 3.2 Authorization
- Role-based access control (RBAC)
- Permission-based features
- Route protection
- API endpoint protection

#### 3.3 Data Validation
- Server-side validation
- Client-side validation (planned)
- Input sanitization
- SQL injection prevention
- XSS protection

### 4. Error Handling & Logging

#### 4.1 Error Handling
- Try-catch blocks
- Graceful error messages
- User-friendly error UI
- Detailed error logging
- Error tracking

#### 4.2 Logging
- Laravel logging system
- Console logging (development)
- Error tracking (production)
- API request/response logging

### 5. Performance Optimizations

#### 5.1 Backend
- Database query optimization
- Eager loading relationships
- Caching strategies
- Route caching

#### 5.2 Frontend
- Code splitting
- Lazy loading
- Image optimization
- React Query caching
- Memoization

### 6. Testing (Planned)

#### 6.1 Backend Testing
- Unit tests
- Feature tests
- API tests
- Integration tests

#### 6.2 Frontend Testing
- Component tests
- Integration tests
- E2E tests
- Accessibility tests

### 7. Deployment Considerations

#### 7.1 Environment Variables
- Database configuration
- API keys
- JWT secrets
- File storage configuration
- Email settings

#### 7.2 Production Optimizations
- Asset compilation
- Route caching
- Config caching
- Database indexing
- CDN integration

---

## Recent Improvements & Fixes

### 1. Route Order Fix (December 2024)
- **Issue:** `/elections/results` was returning 404 due to route conflict
- **Fix:** Reordered routes so specific routes come before parameterized routes
- **Impact:** Results endpoint now works correctly

### 2. Error Logging Enhancement (December 2024)
- **Issue:** Error objects were logging as empty `{}`
- **Fix:** Improved error serialization and logging
- **Impact:** Better debugging capabilities

### 3. Student Panel Navigation (December 2024)
- **Issue:** Navigation active states not working
- **Fix:** Added route pattern matching and explicit slugs
- **Impact:** Better UX with active navigation highlighting

### 4. Election Details Page (December 2024)
- **Issue:** Missing information and poor formatting
- **Fix:** Complete redesign with all necessary information
- **Impact:** Comprehensive election details display

### 5. Candidates Section (December 2024)
- **Issue:** Poor styling and image display issues
- **Fix:** Complete redesign with responsive grid layout
- **Impact:** Professional candidate display with images

### 6. Voting Window Display (December 2024)
- **Issue:** Decimal values in time calculations
- **Fix:** Cast to integers for whole numbers
- **Impact:** Clean, readable time displays

### 7. Next.js Project Structure (December 2024)
- **Issue:** Basic structure not following best practices
- **Fix:** Complete restructuring with industry-standard organization
- **Impact:** Maintainable, scalable codebase

---

## Future Enhancements (Planned)

### 1. Features
- Real-time notifications
- Email notifications
- SMS notifications
- Advanced analytics
- Export capabilities (PDF, Excel)
- Multi-language support
- Dark mode toggle
- Advanced search and filtering
- Bulk operations
- Audit trail

### 2. Technical Improvements
- Comprehensive testing suite
- Performance monitoring
- Error tracking (Sentry)
- API documentation (Swagger/OpenAPI)
- GraphQL API (optional)
- WebSocket support
- Progressive Web App (PWA)
- Mobile app (React Native)

### 3. Security Enhancements
- Two-factor authentication (2FA)
- OAuth integration
- Advanced rate limiting
- IP whitelisting
- Security headers
- Content Security Policy (CSP)

---

## Support & Maintenance

### Documentation
- API documentation
- Component documentation
- Deployment guides
- Troubleshooting guides

### Maintenance Tasks
- Regular dependency updates
- Security patches
- Performance monitoring
- Database optimization
- Backup strategies

---

**End of Documentation**

*This document is maintained as a living document and should be updated as new features are added or existing features are modified.*


