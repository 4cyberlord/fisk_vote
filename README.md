# 🗳️ Fisk Voting System

<!-- markdownlint-disable MD033 -->
<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Laravel](https://img.shields.io/badge/Laravel-12.0-red.svg)
![Next.js](https://img.shields.io/badge/Next.js-16.0.5-black.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

</div>
<!-- markdownlint-enable MD033 -->

## A comprehensive, secure, and user-friendly electronic voting system designed for educational institutions

[Features](#-features) • [Tech Stack](#-tech-stack) • [Installation](#-installation) • [Usage](#-usage) • [Documentation](#-documentation) • [Contributing](#-contributing)

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Database Setup](#-database-setup)
- [Running the Application](#-running-the-application)
- [API Documentation](#-api-documentation)
- [Admin Panel](#-admin-panel)
- [Testing](#-testing)
- [Security Features](#-security-features)
- [Contributing](#contributing)
- [License](#-license)

---

## 🎯 Overview

The **Fisk Voting System** is a full-stack electronic voting platform built for Fisk University and similar educational institutions. It provides a secure, transparent, and user-friendly solution for conducting various types of elections, including student government, club elections, and other campus-wide voting events.

### Key Highlights

- ✅ **Multiple Voting Types**: Single-choice, multiple-choice, and ranked-choice (Instant Runoff Voting)
- ✅ **Real-time Results**: Live election results with detailed analytics and visualizations
- ✅ **Comprehensive Audit Logging**: Complete activity tracking for security and transparency
- ✅ **Session Management**: Multi-device login tracking and management
- ✅ **Public Elections Page**: Transparent view of all elections without authentication
- ✅ **Admin Dashboard**: Full-featured admin panel using Filament
- ✅ **Student Portal**: Intuitive dashboard for students to vote and view results

---

## ✨ Features

### 🗳️ Voting System

- **Multiple Voting Types**
  - Single-choice voting
  - Multiple-choice voting
  - Ranked-choice voting (IRV algorithm)
- **Election Management**
  - Create and manage elections with multiple positions
  - Set eligibility rules (class level, major, department, organizations)
  - Configure election dates and time windows
  - Draft, active, and closed election statuses

### 🔐 Security & Authentication

- JWT-based authentication
- Email verification system
- Password reset functionality
- Session management (view and revoke active sessions)
- Comprehensive audit logging
- Role-based access control (Admin, Super Admin, Student)

### 📊 Analytics & Reporting

- Real-time election statistics
- Participation rate tracking
- Voting activity charts
- Detailed election results with round-by-round breakdowns (for ranked-choice)
- Export capabilities

### 👥 User Management

- Student registration with email verification
- Profile management
- Organization membership tracking
- Department and major associations

### 🎨 User Interface

- Modern, responsive design
- Dark/Light theme support
- Public-facing pages (Home, Elections, Blog, About, FAQ)
- Student dashboard with calendar integration
- Settings page with security features

---

## 🛠️ Tech Stack

### Backend

- **Framework**: Laravel 12.0
- **PHP**: 8.2+
- **Database**: MySQL/PostgreSQL
- **Admin Panel**: Filament 4.0
- **Authentication**: JWT (tymon/jwt-auth)
- **Permissions**: Spatie Laravel Permission
- **Media**: Spatie Media Library

### Frontend

- **Framework**: Next.js 16.0.5
- **Language**: TypeScript 5
- **UI Library**: React 19.2.0
- **Styling**: Tailwind CSS 4
- **State Management**:
  - Zustand (global state)
  - React Query (server state)
- **Forms**: React Hook Form + Zod
- **Charts**: Recharts
- **Calendar**: PrimeReact
- **HTTP Client**: Axios

### Development Tools

- **Package Manager**: Composer (PHP), npm (Node.js)
- **Version Control**: Git
- **Testing**: Pest (PHP)

---

## 📁 Project Structure

```text
├── backend/                 # Laravel backend application
│   ├── app/
│   │   ├── Http/Controllers/    # API controllers
│   │   ├── Models/              # Eloquent models
│   │   ├── Services/            # Business logic services
│   │   ├── Filament/            # Admin panel resources
│   │   └── ...
│   ├── database/
│   │   ├── migrations/          # Database migrations
│   │   ├── seeders/             # Database seeders
│   │   └── factories/           # Model factories
│   ├── routes/
│   │   └── api/v1/              # API routes
│   └── config/                  # Configuration files
│
├── client/                  # Next.js frontend application
│   ├── src/
│   │   ├── app/              # Next.js app router pages
│   │   ├── components/       # React components
│   │   ├── hooks/            # Custom React hooks
│   │   ├── services/         # API service layer
│   │   ├── store/            # Zustand stores
│   │   └── lib/              # Utilities
│   └── public/              # Static assets
│
└── docs/                    # Documentation files
    ├── COMPREHENSIVE_APPLICATION_DOCUMENTATION.md
    ├── SYSTEM_ARCHITECTURE.md
    ├── FEATURES_DOCUMENTATION.md
    └── ...

```

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed on your system:

### Required Software

1. **PHP 8.2 or higher**

   ```bash
   php -v
   ```

   - Required extensions: `pdo`, `pdo_mysql`, `mbstring`, `xml`, `curl`, `zip`, `gd`, `fileinfo`

2. **Composer** (PHP package manager)

   ```bash
   composer --version
   ```

   Install from: <https://getcomposer.org/>

3. **Node.js 20.x or higher** and **npm**

   ```bash
   npm -v
   ```

   Install from: <https://nodejs.org/>

4. **MySQL 8.0+** or **PostgreSQL 13+**

   ```bash
   mysql --version
   # or
   psql --version
   ```

5. **Git**

   ```bash
   git --version
   ```

### Optional but Recommended

- **Redis** (for caching and queues)
- **Mail server** (SMTP) or **Mailtrap** (for development)
- **VS Code** or your preferred IDE

---

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd fisk_vote
```

### 2. Backend Setup

```bash
cd backend

# Install PHP dependencies
composer install

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Generate JWT secret
php artisan jwt:secret
```

### 3. Frontend Setup

```bash
cd client

# Install Node.js dependencies
npm install
```

---

## ⚙️ Configuration

### Backend Configuration

Edit `backend/.env` file with your configuration:

```env
APP_NAME="Fisk Voting System"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=fisk_voting
DB_USERNAME=your_username
DB_PASSWORD=your_password

# JWT
JWT_SECRET=your_jwt_secret_here
JWT_TTL=60

# Mail Configuration
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=your_mailtrap_username
MAIL_PASSWORD=your_mailtrap_password
MAIL_FROM_ADDRESS="noreply@fisk.edu"
MAIL_FROM_NAME="${APP_NAME}"

# CORS
FRONTEND_URL=http://localhost:3000
```

### Frontend Configuration

Create `client/.env.local` file:


```env
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

---

## 🗄️ Database Setup

### 1. Create Database

```sql
CREATE DATABASE fisk_voting_system;
```

### 2. Run Migrations

```bash
php artisan migrate
```

### 3. Seed Database with Fake Data

The seeder will create:

- **500 student users** with various scenarios
- **160+ elections** (college campus style)
- **Multiple positions** per election
- **Candidates** for each position
- **Votes** for closed elections
- **3 admin users**:
  - `admin@fisk.edu` (password: `password`)
  - `superadmin@fisk.edu` (password: `password`)
  - `admin2@fisk.edu` (password: `password`)

```bash
php artisan db:seed
```

### Note

This will populate your database with comprehensive test data including elections, candidates, and votes.

### 4. Create Storage Link (for file uploads)

```bash
php artisan storage:link
```

---

### 5. Set Up Laravel Scheduler (Cron) for Production & Local Dev

The application relies on the Laravel scheduler for background maintenance tasks, including:

- Cleaning up **unverified student registrations** that did not verify their email within 2 minutes (`students:cleanup-unverified`).
- Any future scheduled jobs defined in `backend/routes/console.php`.

To ensure this runs in **production** (and optionally in local dev so it behaves like production), add the following cron entry on the server:

```bash
* * * * * cd /path/to/fisk_voting_system/backend && php artisan schedule:run >> /dev/null 2>&1
```

- Replace `/path/to/fisk_voting_system/backend` with the absolute path on your server.
- This runs the Laravel scheduler **every minute**, which in turn runs all scheduled commands.

After this is configured:

- Any **student user** who does not verify their email within 2 minutes of registration and still has `email_verified_at = NULL` will be **automatically removed** by the `students:cleanup-unverified` command.

For local development that should feel like production, you can either:

- Use the same cron entry on your local machine, **or**
- Manually run:

```bash
php artisan schedule:run
```

whenever you want scheduled tasks to execute.

---

## 🏃 Running the Application

### Start Backend Server

```bash
php artisan serve
```

The backend will be available at: **<http://localhost:8000>**

### Start Frontend Server

Open a new terminal:

```bash
npm run dev
```

The frontend will be available at: **<http://localhost:3000>**

### Access Points

- **Frontend**: <http://localhost:3000>
- **Backend API**: <http://localhost:8000/api/v1>
- **Admin Panel**: <http://localhost:8000/admin>
  - Login with: `admin@fisk.edu` / `password`

---

## 📚 API Documentation

### Authentication Endpoints

- `POST /api/v1/students/register` - Student registration
- `POST /api/v1/students/login` - Student login
- `POST /api/v1/students/logout` - Logout
- `POST /api/v1/students/refresh` - Refresh JWT token
- `GET /api/v1/students/me` - Get current user

### Election Endpoints

- `GET /api/v1/students/public/elections` - Get all public elections (no auth required)
- `GET /api/v1/students/elections` - Get all elections (authenticated)
- `GET /api/v1/students/elections/active` - Get active elections
- `GET /api/v1/students/elections/{id}` - Get election details

### Voting Endpoints

- `GET /api/v1/students/elections/{id}/ballot` - Get voting ballot
- `POST /api/v1/students/elections/{id}/vote` - Cast vote
- `GET /api/v1/students/votes` - Get user's voting history

### Results Endpoints

- `GET /api/v1/students/elections/results` - Get all results
- `GET /api/v1/students/elections/{id}/results` - Get election results

For detailed API documentation, see [docs/ELECTIONS_API_USAGE.md](docs/ELECTIONS_API_USAGE.md)

---

## 🎛️ Admin Panel

The admin panel is built with Filament and provides comprehensive management capabilities:

### Access Admin Panel

1. Navigate to: <http://localhost:8000/admin>
2. Login with admin credentials:
   - Email: `admin@fisk.edu`
   - Password: `password`

### Admin Features

- **Elections Management**: Create, edit, and manage elections
- **Candidates Management**: Add and approve candidates
- **Users Management**: Manage student and admin accounts
- **Votes Management**: View and audit all votes
- **Audit Logs**: Comprehensive activity logging
- **Settings**: Application, email, and logging settings
- **Analytics**: Dashboard with statistics and charts

---

## 🧪 Testing

### Backend Tests

```bash
php artisan test
```

### Test Admin Login

```bash
php artisan tinker
```

```php
$user->assignRole('Admin');
```

---

## 🔒 Security Features

### Authentication & Authorization

- JWT token-based authentication
- Role-based access control (RBAC)
- Email verification required for registration
- Password hashing with bcrypt
- Session tracking and management

### Audit & Logging

- Comprehensive audit logging for all user actions
- Login/logout tracking with IP addresses
- Device and browser information tracking
- Failed login attempt logging
- Vote submission logging

### Data Protection

- SQL injection protection (Eloquent ORM)
- XSS protection (React escaping)
- CSRF protection (Laravel built-in)
- CORS configuration
- Input validation (Laravel + Zod)

### Voting Security

- One vote per user per election
- Eligibility verification
- Vote data encryption
- Audit trail for all votes
- Results calculation verification

---

## 📖 Documentation

Comprehensive documentation is available in the `docs/` directory:

- **[System Architecture](docs/SYSTEM_ARCHITECTURE.md)** - Multi-tier architecture overview
- **[Comprehensive Application Documentation](docs/COMPREHENSIVE_APPLICATION_DOCUMENTATION.md)** - Complete application details
- **[Features Documentation](docs/FEATURES_DOCUMENTATION.md)** - Detailed feature descriptions
- **[API Usage](docs/ELECTIONS_API_USAGE.md)** - API endpoint documentation
- **[JWT Authentication](docs/JWT_AUTHENTICATION_PLAN.md)** - Authentication implementation
- **[Registration Guide](docs/REGISTRATION_TEST_GUIDE.md)** - Student registration flow

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Commit your changes**

   ```bash
   git commit -m "Add your feature description"
   ```

   ```bash
   git push origin feature/your-feature-name
   ```

### Code Style

- **Backend**: Follow [Laravel coding standards](https://laravel.com/docs/contributions#coding-style)
- **Frontend**: Follow [Next.js best practices](https://nextjs.org/docs)
- Use meaningful commit messages
- Add comments for complex logic
- Write tests for new features

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Authors

- **4cyberlord** - *Initial work* - [GitHub](https://github.com/4cyberlord)

---

## 🙏 Acknowledgments

- Laravel community for the excellent framework
- Next.js team for the amazing React framework
- Filament for the powerful admin panel
- All contributors and testers

---

## 📞 Support

For support, email [elections@fisk.edu](mailto:elections@fisk.edu) or open an issue in the repository.

---

<!-- markdownlint-disable MD033 -->
<div align="center">

**Made with ❤️ for Fisk University**

[⬆ Back to Top](#fisk-voting-system)

</div>
<!-- markdownlint-enable MD033 -->

