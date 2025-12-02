# Fisk Voting System - Admin Panel Overview & Structure

## Table of Contents
1. [Admin Panel Architecture](#admin-panel-architecture)
2. [Panel Configuration](#panel-configuration)
3. [Navigation Structure](#navigation-structure)
4. [Resources (CRUD Interfaces)](#resources-crud-interfaces)
5. [Custom Pages](#custom-pages)
6. [Widgets & Dashboards](#widgets--dashboards)
7. [Forms & Tables](#forms--tables)
8. [Actions & Policies](#actions--policies)
9. [UI Components & Layouts](#ui-components--layouts)
10. [Access Control & Permissions](#access-control--permissions)
11. [File Structure](#file-structure)
12. [Visual Structure Diagrams](#visual-structure-diagrams)

---

## Admin Panel Architecture

### Technology Stack
- **Framework**: Filament v4 (Laravel Admin Panel)
- **Base Framework**: Laravel 11.x
- **UI Library**: Livewire 3.x
- **Styling**: Tailwind CSS
- **Icons**: Heroicons
- **Charts**: Chart.js (via Filament Charts)
- **Media Management**: Spatie Media Library

### Panel Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                    Admin Panel UI                        │
│              (Filament Components)                      │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                  Resource Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Resources  │  │    Pages     │  │   Widgets    │ │
│  │  (CRUD)      │  │  (Custom)    │  │  (Dashboard) │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                  Schema Layer                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │    Forms     │  │   Infolists  │  │    Tables    │ │
│  │  (Input)     │  │   (Display)  │  │   (Listing)  │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                  Model Layer                             │
│              (Laravel Eloquent)                          │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                  Database Layer                          │
│              (MySQL/PostgreSQL)                         │
└─────────────────────────────────────────────────────────┘
```

### Panel Configuration

**Panel ID**: `admin`  
**Panel Path**: `/admin`  
**Panel Type**: Default (Primary Panel)  
**Authentication**: Laravel Authentication  
**Theme**: Dynamic (Light/Dark/Auto based on settings)

---

## Panel Configuration

### AdminPanelProvider Configuration

```php
Panel Configuration:
├── ID: 'admin'
├── Path: '/admin'
├── Brand Name: Dynamic (from ApplicationSettings)
├── Brand Logo: Dynamic (from ApplicationSettings)
├── Login Background: Dynamic (from ApplicationSettings)
├── Colors:
│   ├── Primary: Dynamic (from ApplicationSettings)
│   └── Secondary: Dynamic (from ApplicationSettings)
├── Theme Mode: Dynamic (Light/Dark/Auto from ApplicationSettings)
├── Navigation Groups:
│   ├── 'User Management'
│   ├── 'Voting'
│   ├── 'Access Control'
│   └── 'System'
├── Resources: Auto-discovered from app/Filament/Resources
├── Pages: Auto-discovered + Custom pages
├── Widgets: Auto-discovered + Custom widgets
└── Middleware:
    ├── EncryptCookies
    ├── AddQueuedCookiesToResponse
    ├── StartSession
    ├── AuthenticateSession
    ├── ShareErrorsFromSession
    ├── VerifyCsrfToken
    ├── SubstituteBindings
    ├── DisableBladeIconComponents
    ├── DispatchServingFilamentEvent
    └── Authenticate (Auth Middleware)
```

### Dynamic Configuration Sources

All panel configuration is dynamically loaded from:
- **ApplicationSettings Model**: Branding, colors, theme
- **SettingsHelper**: Helper class for accessing settings
- **Fallback Values**: Default values if settings not available

---

## Navigation Structure

### Main Navigation Menu

```
Admin Panel Navigation
│
├── 📊 Dashboard (/admin)
│   └── [Widgets: Stats, Charts, Recent Activity]
│
├── 👥 User Management
│   ├── 👤 Students (/admin/students)
│   ├── 🏢 Departments (/admin/departments)
│   ├── 📚 Majors (/admin/majors)
│   └── 🎯 Organizations (/admin/organizations)
│
├── 🗳️ Voting
│   ├── 📋 Elections (/admin/elections)
│   ├── 💼 Positions (/admin/election-positions)
│   ├── 👔 Candidates (/admin/election-candidates)
│   ├── ✅ Votes (/admin/votes)
│   └── 📊 Election Results (/admin/election-results)
│
├── 🔐 Access Control
│   ├── 👥 Roles (/admin/roles)
│   └── 🔑 Permissions (/admin/permissions)
│
└── ⚙️ System
    ├── 📝 Audit Logs (/admin/audit-logs)
    ├── 🎨 Application Settings (/admin/application-settings)
    ├── 📧 Email Settings (/admin/email-settings)
    └── 📊 Logging Settings (/admin/logging-settings)
```

### Navigation Groups

#### 1. User Management Group
- **Icon**: `heroicon-o-users`
- **Resources**:
  - Students (Users)
  - Departments
  - Majors
  - Organizations
- **Purpose**: Manage users and organizational structure

#### 2. Voting Group
- **Icon**: `heroicon-o-clipboard-document-check`
- **Resources**:
  - Elections
  - Election Positions
  - Election Candidates
  - Votes
  - Election Results (Custom Page)
- **Purpose**: Manage elections and voting process

#### 3. Access Control Group
- **Icon**: `heroicon-o-shield-check`
- **Resources**:
  - Roles (Spatie Permission)
  - Permissions (Spatie Permission)
- **Purpose**: Role-based access control

#### 4. System Group
- **Icon**: `heroicon-o-cog-6-tooth`
- **Resources**:
  - Audit Logs
  - Application Settings
  - Email Settings
  - Logging Settings
- **Purpose**: System configuration and monitoring

---

## Resources (CRUD Interfaces)

### Resource Structure Pattern

Each resource follows this structure:

```
ResourceName/
├── ResourceNameResource.php          # Main resource class
├── Pages/
│   ├── ListResourceName.php         # List/Index page
│   ├── CreateResourceName.php       # Create page
│   ├── EditResourceName.php         # Edit page
│   └── ViewResourceName.php         # View/Show page
├── Schemas/
│   ├── ResourceNameForm.php         # Form schema
│   └── ResourceNameInfolist.php    # Infolist schema
└── Tables/
    └── ResourceNameTable.php       # Table schema
```

### 1. Elections Resource

**Path**: `/admin/elections`  
**Model**: `App\Models\Election`  
**Navigation Group**: Voting  
**Icon**: `heroicon-o-clipboard-document-check`

#### Pages
- **List**: `/admin/elections` - List all elections
- **Create**: `/admin/elections/create` - Create new election
- **View**: `/admin/elections/{id}` - View election details
- **Edit**: `/admin/elections/{id}/edit` - Edit election

#### Form Fields (ElectionForm)
- **Basic Information**:
  - `title` (Text Input) - Required
  - `description` (Textarea) - Optional
- **Election Type**:
  - `type` (Select) - single, multiple, referendum, ranked, poll
  - `max_selection` (Number) - Conditional (if multiple)
  - `ranking_levels` (Number) - Conditional (if ranked)
- **Options**:
  - `allow_write_in` (Toggle) - Default: false
  - `allow_abstain` (Toggle) - Default: false
- **Eligibility**:
  - `is_universal` (Toggle) - Default: false
  - `eligible_groups` (JSON Field) - Departments, class levels, organizations, manual
- **Timeline**:
  - `start_time` (DateTime Picker) - Required
  - `end_time` (DateTime Picker) - Required
- **Status**:
  - `status` (Select) - draft, active, closed, archived

#### Table Columns (ElectionsTable)
- `title` - Searchable, Sortable
- `type` - Badge with color coding
- `status` - Badge (draft/active/closed/archived)
- `start_time` - Date/Time, Sortable
- `end_time` - Date/Time, Sortable
- `current_status` - Computed (Upcoming/Open/Closed)
- `votes_count` - Relationship count
- Actions: View, Edit, Delete

#### Infolist (ElectionInfolist)
- All form fields displayed in organized sections
- Related data: Positions, Candidates, Votes
- Computed properties: Current status, participation rate

#### Features
- Status management workflow
- Eligibility rules configuration
- Timeline validation
- Relationship management (positions, candidates, votes)

---

### 2. Election Positions Resource

**Path**: `/admin/election-positions`  
**Model**: `App\Models\ElectionPosition`  
**Navigation Group**: Voting  
**Icon**: `heroicon-o-briefcase`

#### Pages
- **List**: `/admin/election-positions`
- **Create**: `/admin/election-positions/create`
- **View**: `/admin/election-positions/{id}`
- **Edit**: `/admin/election-positions/{id}/edit`

#### Form Fields (ElectionPositionForm)
- `election_id` (Select) - Required, Relationship
- `name` (Text Input) - Required
- `description` (Textarea) - Optional
- `type` (Select) - single, multiple, ranked
- `max_selection` (Number) - Conditional
- `ranking_levels` (Number) - Conditional
- `allow_abstain` (Toggle) - Default: false

#### Table Columns (ElectionPositionsTable)
- `election.title` - Relationship, Searchable
- `name` - Searchable, Sortable
- `type` - Badge
- `candidates_count` - Relationship count
- Actions: View, Edit, Delete

#### Features
- Linked to elections
- Position-specific voting rules
- Candidate relationship management

---

### 3. Election Candidates Resource

**Path**: `/admin/election-candidates`  
**Model**: `App\Models\ElectionCandidate`  
**Navigation Group**: Voting  
**Icon**: `heroicon-o-user-circle`

#### Pages
- **List**: `/admin/election-candidates`
- **Create**: `/admin/election-candidates/create`
- **View**: `/admin/election-candidates/{id}`
- **Edit**: `/admin/election-candidates/{id}/edit`

#### Form Fields (ElectionCandidateForm)
- `election_id` (Select) - Required, Relationship
- `position_id` (Select) - Required, Relationship (filtered by election)
- `user_id` (Select) - Required, Relationship
- `photo_url` (Text Input) - Optional
- `photo` (File Upload) - Spatie Media Library
- `tagline` (Text Input) - Optional
- `bio` (Textarea) - Optional
- `manifesto` (Textarea) - Optional
- `approved` (Toggle) - Default: false

#### Table Columns (ElectionCandidatesTable)
- `election.title` - Relationship
- `position.name` - Relationship
- `user.name` - Relationship, Searchable
- `photo` - Image thumbnail
- `approved` - Badge (Yes/No)
- Actions: View, Edit, Delete, Approve

#### Features
- Photo upload via Spatie Media Library
- Approval workflow
- Unique constraint: One candidate per position per election
- Relationship to users, elections, positions

---

### 4. Votes Resource

**Path**: `/admin/votes`  
**Model**: `App\Models\Vote`  
**Navigation Group**: Voting  
**Icon**: `heroicon-o-check-circle`

#### Pages
- **List**: `/admin/votes` - Read-only listing
- **View**: `/admin/votes/{id}` - Read-only view

#### Form Fields (VoteForm)
- Read-only (votes are immutable)
- Display only fields:
  - `election.title` - Relationship
  - `position.name` - Relationship
  - `voter.name` - Relationship
  - `vote_data` - JSON formatted display
  - `token` - Unique vote token
  - `voted_at` - Timestamp

#### Table Columns (VotesTable)
- `election.title` - Relationship, Searchable
- `position.name` - Relationship
- `voter.name` - Relationship, Searchable
- `vote_data` - Formatted JSON preview
- `voted_at` - Date/Time, Sortable
- Actions: View only

#### Features
- Read-only resource (data integrity)
- Vote data JSON formatting
- Anonymized token display
- Relationship to elections, positions, voters

---

### 5. Users (Students) Resource

**Path**: `/admin/students`  
**Model**: `App\Models\User`  
**Navigation Group**: User Management  
**Icon**: `heroicon-o-users`  
**Navigation Label**: "Students"

#### Pages
- **List**: `/admin/students`
- **Create**: `/admin/students/create`
- **View**: `/admin/students/{id}`
- **Edit**: `/admin/students/{id}/edit`

#### Form Fields (UserForm)
- **Authentication**:
  - `name` (Text Input) - Required
  - `email` (Email Input) - Required, Unique
  - `password` (Password Input) - Required on create
  - `email_verified_at` (DateTime) - Read-only
- **Personal Information**:
  - `first_name` (Text Input)
  - `last_name` (Text Input)
  - `middle_initial` (Text Input)
- **Student Information**:
  - `student_id` (Text Input) - Unique
  - `university_email` (Email Input) - Unique
  - `personal_email` (Email Input)
  - `phone_number` (Text Input)
  - `profile_photo` (File Upload)
  - `address` (Textarea)
- **Academic Information**:
  - `department` (Text Input)
  - `major` (Text Input)
  - `class_level` (Select) - Freshman, Sophomore, Junior, Senior
- **Status**:
  - `enrollment_status` (Select) - Active, Suspended, Graduated
  - `student_type` (Select) - Undergraduate, Graduate, Transfer, International
  - `citizenship_status` (Text Input)
- **Roles**:
  - `roles` (CheckboxList) - Spatie Permission roles

#### Table Columns (UsersTable)
- `name` - Searchable, Sortable
- `email` - Searchable
- `student_id` - Searchable
- `university_email` - Searchable
- `class_level` - Badge
- `enrollment_status` - Badge
- `email_verified_at` - Badge (Verified/Not Verified)
- `roles` - Relationship badges
- Actions: View, Edit, Delete

#### Features
- Role management integration
- Email verification tracking
- Profile photo management
- Organization memberships (via relationship)

---

### 6. Departments Resource

**Path**: `/admin/departments`  
**Model**: `App\Models\Department`  
**Navigation Group**: User Management  
**Icon**: `heroicon-o-building-office`

#### Pages
- **List**: `/admin/departments`
- **Create**: `/admin/departments/create`
- **View**: `/admin/departments/{id}`
- **Edit**: `/admin/departments/{id}/edit`

#### Form Fields (DepartmentForm)
- `name` (Text Input) - Required, Unique

#### Table Columns (DepartmentsTable)
- `name` - Searchable, Sortable
- Actions: View, Edit, Delete

#### Features
- Simple reference table
- Used for eligibility filtering

---

### 7. Majors Resource

**Path**: `/admin/majors`  
**Model**: `App\Models\Major`  
**Navigation Group**: User Management  
**Icon**: `heroicon-o-academic-cap`

#### Pages
- **List**: `/admin/majors`
- **Create**: `/admin/majors/create`
- **View**: `/admin/majors/{id}`
- **Edit**: `/admin/majors/{id}/edit`

#### Form Fields (MajorForm)
- `name` (Text Input) - Required, Unique

#### Table Columns (MajorsTable)
- `name` - Searchable, Sortable
- Actions: View, Edit, Delete

#### Features
- Simple reference table
- Used for user categorization

---

### 8. Organizations Resource

**Path**: `/admin/organizations`  
**Model**: `App\Models\Organization`  
**Navigation Group**: User Management  
**Icon**: `heroicon-o-user-group`

#### Pages
- **List**: `/admin/organizations`
- **Create**: `/admin/organizations/create`
- **View**: `/admin/organizations/{id}`
- **Edit**: `/admin/organizations/{id}/edit`

#### Form Fields (OrganizationForm)
- `name` (Text Input) - Required, Unique

#### Table Columns (OrganizationsTable)
- `name` - Searchable, Sortable
- `users_count` - Relationship count
- Actions: View, Edit, Delete

#### Features
- Many-to-many relationship with users
- Used for eligibility filtering

---

### 9. Audit Logs Resource

**Path**: `/admin/audit-logs`  
**Model**: `App\Models\AuditLog`  
**Navigation Group**: System  
**Icon**: `heroicon-o-document-text`

#### Pages
- **List**: `/admin/audit-logs`
- **View**: `/admin/audit-logs/{id}`

#### Form Fields (AuditLogForm)
- Read-only (logs are immutable)
- Display only

#### Table Columns (AuditLogsTable)
- `action_type` - Badge, Filterable
- `user.name` - Relationship, Searchable
- `action_description` - Searchable
- `resource_name` - Searchable
- `status` - Badge (success/failed/pending)
- `ip_address` - Filterable
- `created_at` - Date/Time, Sortable
- Actions: View only

#### Filters
- By user
- By action type
- By status
- By date range
- By resource type

#### Features
- Comprehensive audit trail
- Immutable records
- Advanced filtering
- Polymorphic relationship support

---

### 10. Application Settings Resource

**Path**: `/admin/application-settings`  
**Model**: `App\Models\ApplicationSetting`  
**Navigation Group**: System  
**Icon**: `heroicon-o-cog-6-tooth`

#### Pages
- **List**: `/admin/application-settings`
- **Edit**: `/admin/application-settings/{id}/edit`
- **View**: `/admin/application-settings/{id}`

#### Form Fields (ApplicationSettingForm)
- **Platform Identity**:
  - `system_name` (Text Input)
  - `system_short_name` (Text Input)
  - `university_name` (Text Input)
  - `system_description` (Textarea)
  - `voting_platform_contact_email` (Email Input)
  - `voting_support_email` (Email Input)
  - `support_phone_number` (Text Input)
- **Branding**:
  - `university_logo_url` (Text Input)
  - `secondary_logo_url` (Text Input)
  - `primary_color` (Color Picker)
  - `secondary_color` (Color Picker)
  - `dashboard_theme` (Select) - light, dark, auto
  - `login_page_background_image_url` (Text Input)
- **Time & Localization**:
  - `default_timezone` (Select)
  - `date_format` (Select) - MM/DD/YYYY, DD/MM/YYYY, YYYY-MM-DD
  - `time_format` (Select) - 12-hour, 24-hour
  - `default_language` (Text Input)
  - `additional_languages` (JSON Field)

#### Features
- Singleton resource (typically one record)
- Dynamic panel configuration
- Cache management on update

---

### 11. Email Settings Resource

**Path**: `/admin/email-settings`  
**Model**: `App\Models\EmailSetting`  
**Navigation Group**: System  
**Icon**: `heroicon-o-envelope`

#### Pages
- **List**: `/admin/email-settings`
- **Edit**: `/admin/email-settings/{id}/edit`
- **View**: `/admin/email-settings/{id}`

#### Form Fields (EmailSettingForm)
- **Email Service**:
  - `email_service` (Select) - smtp, mailtrap
- **SMTP Settings**:
  - `smtp_host` (Text Input)
  - `smtp_port` (Number Input)
  - `encryption_type` (Select) - tls, ssl, none
  - `smtp_username` (Text Input)
  - `smtp_password` (Password Input) - Encrypted
- **Mailtrap Settings**:
  - `mailtrap_api_key` (Password Input) - Encrypted
  - `mailtrap_use_sandbox` (Toggle)
  - `mailtrap_inbox_id` (Text Input)
- **Email Templates**:
  - `voter_registration_email` (Textarea)
  - `email_verification` (Textarea)
  - `password_reset` (Textarea)
  - `election_announcement` (Textarea)
  - `upcoming_election_reminder` (Textarea)
  - `thank_you_for_voting` (Textarea)
  - `result_announcement_email` (Textarea)
- **Notification Preferences**:
  - `send_daily_summary_to_admins` (Toggle)
  - `send_voting_activity_alerts` (Toggle)
  - `notify_users_when_election_opens` (Toggle)
  - `notify_eligible_voters_before_election_ends` (Toggle)

#### Features
- Singleton resource
- Encrypted password fields
- Email template management
- Multiple email service support

---

### 12. Logging Settings Resource

**Path**: `/admin/logging-settings`  
**Model**: `App\Models\LoggingSetting`  
**Navigation Group**: System  
**Icon**: `heroicon-o-document-chart-bar`

#### Pages
- **List**: `/admin/logging-settings`
- **Edit**: `/admin/logging-settings/{id}/edit`
- **View**: `/admin/logging-settings/{id}`

#### Form Fields (LoggingSettingForm)
- **Logging Preferences**:
  - `enable_activity_logs` (Toggle)
  - `log_admin_actions` (Toggle)
  - `log_voter_logins` (Toggle)
  - `log_vote_submission_events` (Toggle)
  - `log_ip_addresses` (Toggle) - With privacy note
- **Log Retention**:
  - `retention_period` (Select) - 30_days, 3_months, 1_year, forever
- **Performance Monitoring**:
  - `enable_system_health_dashboard` (Toggle)
  - `track_cpu_load` (Toggle)
  - `track_database_queries` (Toggle)
  - `track_active_users` (Toggle)
  - `track_vote_submission_rate` (Toggle)
- **Error & Crash Handling**:
  - `auto_email_admin_on_failure` (Toggle)
  - `store_crash_reports` (Toggle)

#### Features
- Singleton resource
- Privacy compliance notes
- Cache management on update

---

### 13. Roles Resource (Spatie Permission)

**Path**: `/admin/roles`  
**Model**: `Spatie\Permission\Models\Role`  
**Navigation Group**: Access Control  
**Icon**: `heroicon-o-shield-check`

#### Pages
- **List**: `/admin/roles`
- **Create**: `/admin/roles/create`
- **View**: `/admin/roles/{id}`
- **Edit**: `/admin/roles/{id}/edit`

#### Form Fields (RoleForm)
- `name` (Text Input) - Required, Unique
- `guard_name` (Text Input) - Default: 'web'
- `permissions` (CheckboxList) - Relationship to permissions

#### Table Columns (RolesTable)
- `name` - Searchable, Sortable
- `guard_name` - Badge
- `permissions_count` - Relationship count
- `users_count` - Relationship count
- Actions: View, Edit, Delete

#### Features
- Spatie Permission integration
- Permission assignment
- User role assignment

---

### 14. Permissions Resource (Spatie Permission)

**Path**: `/admin/permissions`  
**Model**: `Spatie\Permission\Models\Permission`  
**Navigation Group**: Access Control  
**Icon**: `heroicon-o-key`

#### Pages
- **List**: `/admin/permissions`
- **Create**: `/admin/permissions/create`
- **View**: `/admin/permissions/{id}`
- **Edit**: `/admin/permissions/{id}/edit`

#### Form Fields (PermissionForm)
- `name` (Text Input) - Required, Unique
- `guard_name` (Text Input) - Default: 'web'

#### Table Columns (PermissionsTable)
- `name` - Searchable, Sortable
- `guard_name` - Badge
- `roles_count` - Relationship count
- Actions: View, Edit, Delete

#### Features
- Spatie Permission integration
- Role assignment
- Direct user assignment

---

## Custom Pages

### 1. Dashboard

**Path**: `/admin`  
**Class**: `Filament\Pages\Dashboard`  
**Purpose**: Main admin dashboard

#### Widgets Displayed
1. **StatsOverviewWidget** - Key metrics
2. **ActiveElectionsWidget** - Active elections list
3. **ElectionStatusChartWidget** - Status breakdown chart
4. **VotingActivityChartWidget** - Activity over time chart
5. **ParticipationRateWidget** - Participation statistics
6. **RecentVotesWidget** - Latest votes
7. **AccountWidget** - User account info

#### Layout
- Full-width layout
- Widget grid (responsive)
- Customizable widget positions

---

### 2. Election Results

**Path**: `/admin/election-results`  
**Class**: `App\Filament\Pages\ElectionResults`  
**Navigation Group**: Voting  
**Navigation Sort**: 3  
**Icon**: `heroicon-o-chart-bar-square`

#### Features
- **Table View**: List of closed elections
- **Columns**:
  - Election title
  - Type (badge)
  - End time
  - Total votes count
  - Status
- **Actions**:
  - **View Results** (Modal): Detailed results with:
    - Position-by-position breakdown
    - Candidate vote counts
    - Percentages
    - Winners
    - Charts and visualizations

#### Modal Content
- Election details
- Results by position
- Candidate rankings
- Vote distribution charts
- Winner announcements

---

## Widgets & Dashboards

### Widget Structure

All widgets located in: `app/Filament/Widgets/`

### 1. StatsOverviewWidget

**Type**: Stats Overview  
**Location**: Dashboard top  
**Purpose**: Key system metrics

#### Stats Displayed
1. **Total Elections**
   - Count: All elections
   - Description: "All elections in the system"
   - Icon: `heroicon-m-clipboard-document-check`
   - Color: Primary
   - Chart: Election trend (7 days)

2. **Active Elections**
   - Count: Currently open elections
   - Description: "Currently open for voting"
   - Icon: `heroicon-m-check-circle`
   - Color: Success

3. **Upcoming Elections**
   - Count: Scheduled elections
   - Description: "Scheduled to start soon"
   - Icon: `heroicon-m-clock`
   - Color: Info

4. **Total Students**
   - Count: Registered students
   - Description: "Registered students"
   - Icon: `heroicon-m-users`
   - Color: Warning

5. **Total Votes Cast**
   - Count: All votes
   - Description: "X unique voters (Y% participation)"
   - Icon: `heroicon-m-check-badge`
   - Color: Success
   - Chart: Vote trend (7 days)

6. **Votes Today**
   - Count: Today's votes
   - Description: "X votes this week"
   - Icon: `heroicon-m-chart-bar`
   - Color: Primary

---

### 2. ActiveElectionsWidget

**Type**: Table Widget  
**Location**: Dashboard  
**Purpose**: Display active elections

#### Features
- List of currently active elections
- Election title
- End time countdown
- Vote count
- Quick actions

---

### 3. ElectionStatusChartWidget

**Type**: Chart Widget  
**Location**: Dashboard  
**Purpose**: Visual status breakdown

#### Chart Type
- Pie/Donut chart
- Shows: Draft, Active, Closed, Archived

#### Data
- Election counts by status
- Color-coded segments

---

### 4. VotingActivityChartWidget

**Type**: Chart Widget  
**Location**: Dashboard  
**Purpose**: Voting activity over time

#### Chart Type
- Line/Bar chart
- Time period: Last 30 days (configurable)

#### Data
- Votes per day
- Trend visualization

---

### 5. ParticipationRateWidget

**Type**: Stats Widget  
**Location**: Dashboard  
**Purpose**: Participation statistics

#### Metrics
- Overall participation rate
- Participation by election
- Participation by department
- Participation by class level

---

### 6. RecentVotesWidget

**Type**: Table Widget  
**Location**: Dashboard  
**Purpose**: Latest voting activity

#### Features
- Recent votes list (last 10-20)
- Voter name (anonymized if needed)
- Election name
- Vote time
- Quick view action

---

### 7. AccountWidget

**Type**: Account Widget (Filament Built-in)  
**Location**: Dashboard  
**Purpose**: User account information

#### Features
- Current user info
- Profile link
- Logout action

---

## Forms & Tables

### Form Schema Pattern

Each resource has a dedicated Form schema class:

```php
class ResourceNameForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->schema([
                // Field definitions
            ]);
    }
}
```

### Table Schema Pattern

Each resource has a dedicated Table schema class:

```php
class ResourceNameTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                // Column definitions
            ])
            ->filters([
                // Filter definitions
            ])
            ->actions([
                // Action definitions
            ])
            ->bulkActions([
                // Bulk action definitions
            ]);
    }
}
```

### Common Form Components

- **Text Input**: Single-line text
- **Textarea**: Multi-line text
- **Select**: Dropdown selection
- **Toggle**: Boolean switch
- **Checkbox**: Boolean checkbox
- **Radio**: Radio button group
- **Date Picker**: Date selection
- **DateTime Picker**: Date and time selection
- **File Upload**: File upload (Spatie Media Library)
- **Color Picker**: Color selection
- **JSON Editor**: JSON data editing
- **Rich Text Editor**: WYSIWYG editor (if configured)

### Common Table Components

- **Text Column**: Text display
- **Badge Column**: Colored badge
- **Image Column**: Image thumbnail
- **Boolean Column**: Yes/No display
- **Date Column**: Date/time display
- **Relationship Column**: Related model data
- **Count Column**: Relationship count
- **Actions Column**: Row actions

### Common Filters

- **Select Filter**: Dropdown filter
- **Text Filter**: Text search
- **Date Range Filter**: Date range selection
- **Boolean Filter**: Yes/No filter
- **Relationship Filter**: Filter by relationship

---

## Actions & Policies

### Resource Actions

#### Standard Actions
- **View**: View record details
- **Edit**: Edit record
- **Delete**: Delete record (with confirmation)
- **Create**: Create new record

#### Custom Actions
- **Approve** (Candidates): Approve candidate
- **Reject** (Candidates): Reject candidate
- **Activate** (Elections): Activate election
- **Close** (Elections): Close election
- **Archive** (Elections): Archive election
- **View Results** (Elections): View election results

### Bulk Actions

- **Delete Selected**: Delete multiple records
- **Approve Selected** (Candidates): Approve multiple candidates
- **Export Selected**: Export to CSV/Excel

### Policies

Access control via Laravel Policies:

- **ElectionPolicy**: Election access control
- **UserPolicy**: User access control
- **VotePolicy**: Vote access control (read-only)
- **SettingsPolicy**: Settings access control

### Permission Integration

- Spatie Permission integration
- Role-based access control
- Permission checks on actions
- Policy-based authorization

---

## UI Components & Layouts

### Layout Structure

```
┌─────────────────────────────────────────────────┐
│              Top Navigation Bar                 │
│  [Logo] [Brand Name] [User Menu] [Theme Toggle] │
└─────────────────────────────────────────────────┘
┌──────┬──────────────────────────────────────────┐
│      │                                          │
│ Side │          Main Content Area               │
│ Nav  │                                          │
│      │                                          │
│      │                                          │
│      │                                          │
└──────┴──────────────────────────────────────────┘
```

### Sidebar Navigation

- **Collapsible**: Can be collapsed/expanded
- **Grouped**: Resources grouped by category
- **Icons**: Heroicons for each resource
- **Active State**: Highlights current page
- **Badges**: Count badges (if applicable)

### Top Bar

- **Brand Logo**: Dynamic from settings
- **Brand Name**: Dynamic from settings
- **User Menu**: Account, Profile, Logout
- **Theme Toggle**: Light/Dark mode
- **Notifications**: (If implemented)

### Content Area

- **Breadcrumbs**: Navigation path
- **Page Header**: Title and actions
- **Content**: Resource-specific content
- **Footer**: (If configured)

### Color Scheme

- **Primary Color**: Dynamic from ApplicationSettings
- **Secondary Color**: Dynamic from ApplicationSettings
- **Theme Mode**: Light/Dark/Auto from ApplicationSettings

### Responsive Design

- **Mobile**: Collapsed sidebar, stacked layout
- **Tablet**: Collapsible sidebar, responsive grid
- **Desktop**: Full sidebar, multi-column layout

---

## Access Control & Permissions

### Authentication

- **Provider**: Laravel Authentication
- **Guard**: `web`
- **Middleware**: `Authenticate`
- **Login Page**: `/admin/login`

### Authorization

- **Role-Based**: Spatie Permission roles
- **Permission-Based**: Spatie Permission permissions
- **Policy-Based**: Laravel Policies
- **Resource-Level**: Filament resource policies

### Default Roles

1. **Student**: Basic student access
2. **Admin**: Administrative access
3. **Super Admin**: Full system access

### Permission Structure

```
Permissions:
├── elections.view
├── elections.create
├── elections.edit
├── elections.delete
├── users.view
├── users.create
├── users.edit
├── users.delete
├── votes.view (read-only)
├── settings.edit
└── audit_logs.view
```

### Access Rules

- **Students**: Cannot access admin panel
- **Admins**: Full access to admin panel
- **Super Admins**: Full access + system settings

---

## File Structure

### Complete Directory Structure

```
backend/app/Filament/
├── Forms/
│   └── Components/
│       └── [Custom form components]
│
├── Pages/
│   └── ElectionResults.php
│
├── Resources/
│   ├── ApplicationSettings/
│   │   ├── ApplicationSettingResource.php
│   │   ├── Pages/
│   │   │   ├── CreateApplicationSetting.php
│   │   │   ├── EditApplicationSetting.php
│   │   │   ├── ListApplicationSettings.php
│   │   │   └── ViewApplicationSetting.php
│   │   ├── Schemas/
│   │   │   ├── ApplicationSettingForm.php
│   │   │   └── ApplicationSettingInfolist.php
│   │   └── Tables/
│   │       └── ApplicationSettingsTable.php
│   │
│   ├── AuditLogs/
│   │   ├── AuditLogResource.php
│   │   ├── Pages/
│   │   │   ├── CreateAuditLog.php
│   │   │   ├── EditAuditLog.php
│   │   │   ├── ListAuditLogs.php
│   │   │   └── ViewAuditLog.php
│   │   ├── Schemas/
│   │   │   ├── AuditLogForm.php
│   │   │   └── AuditLogInfolist.php
│   │   └── Tables/
│   │       └── AuditLogsTable.php
│   │
│   ├── Departments/
│   │   ├── DepartmentResource.php
│   │   ├── Pages/
│   │   │   ├── CreateDepartment.php
│   │   │   ├── EditDepartment.php
│   │   │   ├── ListDepartments.php
│   │   │   └── ViewDepartment.php
│   │   ├── Schemas/
│   │   │   ├── DepartmentForm.php
│   │   │   └── DepartmentInfolist.php
│   │   └── Tables/
│   │       └── DepartmentsTable.php
│   │
│   ├── ElectionCandidates/
│   │   ├── ElectionCandidateResource.php
│   │   ├── Pages/
│   │   │   ├── CreateElectionCandidate.php
│   │   │   ├── EditElectionCandidate.php
│   │   │   ├── ListElectionCandidates.php
│   │   │   └── ViewElectionCandidate.php
│   │   ├── Schemas/
│   │   │   ├── ElectionCandidateForm.php
│   │   │   └── ElectionCandidateInfolist.php
│   │   └── Tables/
│   │       └── ElectionCandidatesTable.php
│   │
│   ├── ElectionPositions/
│   │   ├── ElectionPositionResource.php
│   │   ├── Pages/
│   │   │   ├── CreateElectionPosition.php
│   │   │   ├── EditElectionPosition.php
│   │   │   ├── ListElectionPositions.php
│   │   │   └── ViewElectionPosition.php
│   │   ├── Schemas/
│   │   │   ├── ElectionPositionForm.php
│   │   │   └── ElectionPositionInfolist.php
│   │   └── Tables/
│   │       └── ElectionPositionsTable.php
│   │
│   ├── Elections/
│   │   ├── ElectionResource.php
│   │   ├── Pages/
│   │   │   ├── CreateElection.php
│   │   │   ├── EditElection.php
│   │   │   ├── ListElections.php
│   │   │   └── ViewElection.php
│   │   ├── Schemas/
│   │   │   ├── ElectionForm.php
│   │   │   └── ElectionInfolist.php
│   │   └── Tables/
│   │       └── ElectionsTable.php
│   │
│   ├── EmailSettings/
│   │   ├── EmailSettingResource.php
│   │   ├── Pages/
│   │   │   ├── CreateEmailSetting.php
│   │   │   ├── EditEmailSetting.php
│   │   │   ├── ListEmailSettings.php
│   │   │   └── ViewEmailSetting.php
│   │   ├── Schemas/
│   │   │   ├── EmailSettingForm.php
│   │   │   └── EmailSettingInfolist.php
│   │   └── Tables/
│   │       └── EmailSettingsTable.php
│   │
│   ├── LoggingSettings/
│   │   ├── LoggingSettingResource.php
│   │   ├── Pages/
│   │   │   ├── CreateLoggingSetting.php
│   │   │   ├── EditLoggingSetting.php
│   │   │   ├── ListLoggingSettings.php
│   │   │   └── ViewLoggingSetting.php
│   │   ├── Schemas/
│   │   │   ├── LoggingSettingForm.php
│   │   │   └── LoggingSettingInfolist.php
│   │   └── Tables/
│   │       └── LoggingSettingsTable.php
│   │
│   ├── Majors/
│   │   ├── MajorResource.php
│   │   ├── Pages/
│   │   │   ├── CreateMajor.php
│   │   │   ├── EditMajor.php
│   │   │   ├── ListMajors.php
│   │   │   └── ViewMajor.php
│   │   ├── Schemas/
│   │   │   ├── MajorForm.php
│   │   │   └── MajorInfolist.php
│   │   └── Tables/
│   │       └── MajorsTable.php
│   │
│   ├── Organizations/
│   │   ├── OrganizationResource.php
│   │   ├── Pages/
│   │   │   ├── CreateOrganization.php
│   │   │   ├── EditOrganization.php
│   │   │   ├── ListOrganizations.php
│   │   │   └── ViewOrganization.php
│   │   ├── Schemas/
│   │   │   ├── OrganizationForm.php
│   │   │   └── OrganizationInfolist.php
│   │   └── Tables/
│   │       └── OrganizationsTable.php
│   │
│   ├── Spatie/
│   │   └── Permission/
│   │       └── Models/
│   │           └── Roles/
│   │               ├── RoleResource.php
│   │               ├── Pages/
│   │               │   ├── CreateRole.php
│   │               │   ├── EditRole.php
│   │               │   ├── ListRoles.php
│   │               │   └── ViewRole.php
│   │               ├── Schemas/
│   │               │   ├── RoleForm.php
│   │               │   └── RoleInfolist.php
│   │               └── Tables/
│   │                   └── RolesTable.php
│   │
│   ├── Users/
│   │   ├── UserResource.php
│   │   ├── Pages/
│   │   │   ├── CreateUser.php
│   │   │   ├── EditUser.php
│   │   │   ├── ListUsers.php
│   │   │   └── ViewUser.php
│   │   ├── Schemas/
│   │   │   ├── UserForm.php
│   │   │   └── UserInfolist.php
│   │   └── Tables/
│   │       └── UsersTable.php
│   │
│   └── Votes/
│       ├── VoteResource.php
│       ├── Pages/
│       │   ├── CreateVote.php
│       │   ├── EditVote.php
│       │   ├── ListVotes.php
│       │   └── ViewVote.php
│       ├── Schemas/
│       │   ├── VoteForm.php
│       │   └── VoteInfolist.php
│       └── Tables/
│           └── VotesTable.php
│
├── Student/
│   ├── Components/
│   └── Pages/
│       ├── ActiveElections.php
│       ├── Ballot.php
│       ├── ElectionDetails.php
│       ├── EmailVerificationSuccess.php
│       ├── Login.php
│       ├── Register.php
│       ├── StudentProfile.php
│       └── VerifyEmail.php
│
└── Widgets/
    ├── ActiveElectionsWidget.php
    ├── ElectionStatusChartWidget.php
    ├── ParticipationRateWidget.php
    ├── RecentVotesWidget.php
    ├── StatsOverviewWidget.php
    └── VotingActivityChartWidget.php
```

### View Files Structure

```
backend/resources/views/filament/
├── hooks/
│   └── theme-listener.blade.php
├── pages/
│   ├── election-results.blade.php
│   └── election-results-modal.blade.php
└── [Additional custom views]
```

---

## Visual Structure Diagrams

### Admin Panel Layout

```
┌─────────────────────────────────────────────────────────────┐
│  [Logo] Fisk Voting System          [User] [Theme] [Logout]│
├──────────┬──────────────────────────────────────────────────┤
│          │                                                    │
│  📊      │  Dashboard                                         │
│ Dashboard│  ┌────────────────────────────────────────────┐  │
│          │  │  Stats Overview Widget                      │  │
│  👥      │  │  [Total Elections] [Active] [Upcoming]    │  │
│ User Mgmt│  │  [Total Students] [Votes] [Today]         │  │
│          │  └────────────────────────────────────────────┘  │
│  🗳️      │  ┌────────────────────────────────────────────┐  │
│ Voting   │  │  Active Elections Widget                    │  │
│          │  │  [Election 1] [Election 2] ...              │  │
│  🔐      │  └────────────────────────────────────────────┘  │
│ Access   │  ┌────────────────────────────────────────────┐  │
│          │  │  Election Status Chart                      │  │
│  ⚙️      │  │  [Pie Chart: Draft/Active/Closed]          │  │
│ System   │  └────────────────────────────────────────────┘  │
│          │  ┌────────────────────────────────────────────┐  │
│          │  │  Voting Activity Chart                      │  │
│          │  │  [Line Chart: Votes over time]              │  │
│          │  └────────────────────────────────────────────┘  │
│          │                                                    │
└──────────┴──────────────────────────────────────────────────┘
```

### Resource Page Structure

```
┌─────────────────────────────────────────────────────────────┐
│  [Logo] Fisk Voting System          [User] [Theme] [Logout]│
├──────────┬──────────────────────────────────────────────────┤
│          │                                                    │
│  Sidebar │  Elections                                         │
│          │  ┌────────────────────────────────────────────┐  │
│          │  │  [Create Election] [Filters] [Search]      │  │
│          │  ├────────────────────────────────────────────┤  │
│          │  │  Title    │ Type │ Status │ Start │ End   │  │
│          │  │  ─────────┼──────┼────────┼───────┼───────│  │
│          │  │  Election1│Single│ Active │ ... │ ...   │  │
│          │  │  Election2│Multi │ Draft  │ ... │ ...   │  │
│          │  │  ...      │ ... │ ...    │ ... │ ...   │  │
│          │  └────────────────────────────────────────────┘  │
│          │                                                    │
└──────────┴──────────────────────────────────────────────────┘
```

### Form Page Structure

```
┌─────────────────────────────────────────────────────────────┐
│  [Logo] Fisk Voting System          [User] [Theme] [Logout]│
├──────────┬──────────────────────────────────────────────────┤
│          │                                                    │
│  Sidebar │  Create Election                                  │
│          │  ┌────────────────────────────────────────────┐  │
│          │  │  Basic Information                          │  │
│          │  │  Title: [________________]                  │  │
│          │  │  Description: [________________]            │  │
│          │  │                                              │  │
│          │  │  Election Type                              │  │
│          │  │  Type: [Single ▼]                           │  │
│          │  │  Max Selection: [___]                       │  │
│          │  │                                              │  │
│          │  │  Timeline                                    │  │
│          │  │  Start Time: [Date] [Time]                  │  │
│          │  │  End Time: [Date] [Time]                     │  │
│          │  │                                              │  │
│          │  │  [Cancel] [Create Election]                  │  │
│          │  └────────────────────────────────────────────┘  │
│          │                                                    │
└──────────┴──────────────────────────────────────────────────┘
```

---

## Summary

### Resource Count
- **Total Resources**: 14
- **Core Business Resources**: 9
- **System Resources**: 3
- **Access Control Resources**: 2

### Page Count
- **Resource Pages**: 56 (14 resources × 4 pages each)
- **Custom Pages**: 1 (Election Results)
- **Dashboard**: 1
- **Total Pages**: 58

### Widget Count
- **Dashboard Widgets**: 7
- **Custom Widgets**: 6
- **Built-in Widgets**: 1 (AccountWidget)

### Features Summary
- ✅ Complete CRUD operations for all resources
- ✅ Advanced filtering and search
- ✅ Relationship management
- ✅ Media upload support
- ✅ Role-based access control
- ✅ Comprehensive audit logging
- ✅ Dynamic theming
- ✅ Responsive design
- ✅ Real-time statistics
- ✅ Chart visualizations
- ✅ Export capabilities
- ✅ Bulk actions

---

## Conclusion

The Admin Panel provides a comprehensive, user-friendly interface for managing the Fisk Voting System. It follows Filament best practices with a clean, organized structure that makes it easy to navigate and use. The panel is fully customizable through application settings and supports both light and dark themes.

All resources follow consistent patterns, making the codebase maintainable and extensible. The integration with Spatie Permission provides robust access control, while the comprehensive audit logging ensures full system transparency.

