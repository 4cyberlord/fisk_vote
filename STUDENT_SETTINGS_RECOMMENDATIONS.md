# Student Client Settings Page - Recommendations & Implementation Guide

## 📋 Current State

### Existing Settings Page (`/dashboard/settings`)
- ✅ **Change Password** - Fully implemented with:
  - Current password field
  - New password field with strength indicator
  - Confirm password field
  - Password visibility toggles
  - Form validation and error handling
  - Success/error toast notifications
  - **Connected to Backend API** (`POST /api/v1/students/me/change-password`)

### Related Pages
- **Profile Page** (`/dashboard/profile`) - Handles profile information updates
- **Dashboard** (`/dashboard`) - Shows profile summary with link to settings

---

## 🎯 Recommended Additions

### 1. Notification Preferences (High Priority) ⭐

#### Email Notifications
- [ ] **Election Announcements**
  - Toggle: Receive email when new elections open
  - Frequency: Immediate / Daily digest / Weekly digest
  
- [ ] **Voting Reminders**
  - Toggle: Receive reminders before election closes
  - Timing: 24 hours before / 1 hour before / 30 minutes before
  
- [ ] **Results Available**
  - Toggle: Get notified when election results are published
  
- [ ] **Daily/Weekly Summaries**
  - Toggle: Receive activity summaries
  - Frequency: Daily / Weekly / Never

#### In-App Notifications
- [ ] **Browser Notifications**
  - Toggle: Enable browser push notifications
  - Permission request handler
  
- [ ] **Notification Sound**
  - Toggle: Play sound for notifications
  - Sound selection dropdown
  
- [ ] **Notification Frequency**
  - Options: All / Important only / None
  - Quiet hours setting (time range)

**Implementation Notes:**
- Store preferences in user model or separate `user_preferences` table
- Backend API endpoint: `GET/PUT /api/v1/students/me/preferences`
- Use React Query for state management
- Persist preferences to localStorage for offline access

---

### 2. Privacy & Security (High Priority) ⭐

#### Two-Factor Authentication (2FA)
- [ ] **Enable/Disable 2FA**
  - Toggle switch
  - Setup wizard with QR code display
  - Backup codes generation and display
  - Recovery codes download option

#### Active Sessions
- [ ] **View Active Sessions**
  - List of all active sessions with:
    - Device type and browser
    - IP address
    - Location (if available)
    - Last activity timestamp
  - "Log out from other devices" button
  - "Log out from all devices" option

#### Account Security
- [ ] **Security Information**
  - Last login date and time
  - Last password change date
  - Account creation date
  - Email verification status
  - Security alerts toggle

**Implementation Notes:**
- Backend: Track sessions in `sessions` table or JWT blacklist
- API endpoint: `GET /api/v1/students/me/sessions`
- API endpoint: `DELETE /api/v1/students/me/sessions/{id}`
- Use TOTP library for 2FA (e.g., `speakeasy` or `otplib`)

---

### 3. Display Preferences (Medium Priority)

#### Theme Settings
- [ ] **Theme Selection**
  - Radio buttons: Light / Dark / Auto (system preference)
  - Live preview toggle
  - Accent color picker (if applicable)

#### Dashboard Layout
- [ ] **Layout Options**
  - Compact / Comfortable spacing toggle
  - Show/hide widgets checkboxes:
    - Election statistics
    - Voting history
    - Upcoming elections
  - Default view selection: Elections / Results / Dashboard

#### Language & Region
- [ ] **Localization**
  - Language dropdown (English, Spanish, etc.)
  - Date format: MM/DD/YYYY / DD/MM/YYYY / YYYY-MM-DD
  - Time format: 12-hour / 24-hour
  - Timezone selector (with auto-detect option)

**Implementation Notes:**
- Store in localStorage for immediate effect
- Sync with backend for cross-device consistency
- Use React Context for theme management
- Consider using `next-themes` for theme switching

---

### 4. Voting Preferences (Medium Priority)

#### Default Voting Behavior
- [ ] **Voting Options**
  - Auto-submit on final selection (toggle)
  - Show confirmation dialog before submitting (toggle)
  - Show vote preview before submission (toggle)
  - Enable vote change before election closes (toggle)

#### Election Display
- [ ] **Election List Options**
  - Show closed elections (toggle)
  - Show results immediately when available (toggle)
  - Default sort order: Newest first / Oldest first / Alphabetical
  - Filter by status: All / Active / Closed

**Implementation Notes:**
- Store in user preferences
- Apply filters to election queries
- Use React Query for filtering and sorting

---

### 5. Profile Visibility (Low Priority)

#### Public Profile Settings
- [ ] **Visibility Controls**
  - Show profile to other students (toggle)
  - Show in candidate listings (toggle)
  - Show contact information (toggle)
  - Show profile photo publicly (toggle)

#### Data Sharing
- [ ] **Sharing Preferences**
  - Share analytics data (toggle)
  - Allow profile photo in results (toggle)
  - Share voting participation stats (toggle)

**Implementation Notes:**
- Add `profile_visibility` JSON column to users table
- Backend validation for visibility settings
- Update candidate display logic based on preferences

---

### 6. Accessibility (Medium Priority)

#### Display Options
- [ ] **Accessibility Settings**
  - Font size: Small / Medium / Large / Extra Large
  - High contrast mode (toggle)
  - Reduce animations (toggle)
  - Focus indicators (toggle)

#### Keyboard Navigation
- [ ] **Keyboard Shortcuts**
  - Enable keyboard shortcuts (toggle)
  - Show keyboard shortcuts help (modal/drawer)
  - Common shortcuts:
    - `?` - Show shortcuts
    - `G D` - Go to Dashboard
    - `G V` - Go to Vote
    - `G R` - Go to Results
    - `G P` - Go to Profile
    - `G S` - Go to Settings

**Implementation Notes:**
- Use CSS variables for font sizes
- Implement keyboard shortcut handler
- Add ARIA labels for screen readers
- Test with screen readers (NVDA, JAWS, VoiceOver)

---

### 7. Data & Export (Low Priority)

#### Data Management
- [ ] **Data Export**
  - Download my data button (JSON/CSV format)
  - View voting history export
  - Request data deletion (with confirmation)
  - Export includes:
    - Profile information
    - Voting history (anonymized)
    - Account activity log

#### Account Information
- [ ] **Account Details**
  - Account creation date
  - Last activity timestamp
  - Data retention information
  - Account status

**Implementation Notes:**
- Backend endpoint: `GET /api/v1/students/me/export`
- Generate downloadable file on-demand
- Include GDPR compliance information
- Implement data deletion workflow with admin approval

---

### 8. Help & Support (Low Priority)

#### Support Options
- [ ] **Support Section**
  - Contact support button (opens email or form)
  - FAQ link
  - Report a bug button
  - Feature request link
  - Live chat (if available)

#### Legal & Compliance
- [ ] **Legal Links**
  - Privacy policy link
  - Terms of service link
  - Cookie preferences (if applicable)
  - Data protection information

**Implementation Notes:**
- Link to external pages or modals
- Consider using a help desk integration (e.g., Intercom, Zendesk)
- Add feedback form component

---

## 🎨 Suggested UI Structure

```
Settings Page (/dashboard/settings)
│
├── Security & Privacy Tab
│   ├── Change Password (✅ Current - Connected to Backend)
│   ├── Two-Factor Authentication
│   │   ├── SMS Option (Toggle)
│   │   └── Authenticator App (TOTP) (Toggle)
│   ├── Active Sessions
│   │   ├── List of Active Sessions
│   │   ├── Log out from other devices
│   │   └── Log out from all devices
│   └── Security History
│       └── Recent security events log
│
├── Notifications Tab
│   ├── Email Notifications
│   │   ├── Election Announcements (Toggle)
│   │   ├── Voting Reminders (Toggle)
│   │   ├── Results Available (Toggle)
│   │   └── Activity Summaries (Toggle)
│   └── In-App Notifications
│       ├── Browser Notifications (Toggle)
│       ├── Notification Sound (Toggle)
│       └── Quiet Hours (Toggle)
│
├── Preferences Tab
│   ├── Display & Theme
│   │   ├── Theme Selection (Light/Dark/Auto)
│   │   ├── Dashboard Layout Options
│   │   └── Accent Colors
│   ├── Language & Region
│   │   ├── Language (Dropdown)
│   │   ├── Date Format (Dropdown)
│   │   ├── Time Format (12-hour/24-hour)
│   │   └── Timezone (Dropdown)
│   └── Voting Preferences
│       ├── Auto-submit on Final Selection (Toggle)
│       ├── Show Confirmation Dialog (Toggle)
│       └── Show Vote Preview (Toggle)
│
├── Privacy Tab
│   ├── Profile Visibility
│   │   ├── Show Profile to Other Students (Toggle)
│   │   ├── Show in Candidate Listings (Toggle)
│   │   ├── Show Contact Information (Toggle)
│   │   └── Show Profile Photo Publicly (Toggle)
│   └── Data Sharing
│       ├── Share Analytics Data (Toggle)
│       └── Allow Profile Photo in Results (Toggle)
│
├── Accessibility Tab
│   ├── Display Options
│   │   └── Font Size (Small/Medium/Large/Extra Large)
│   ├── Accessibility Features
│   │   ├── High Contrast Mode (Toggle)
│   │   ├── Reduce Animations (Toggle)
│   │   └── Enhanced Focus Indicators (Toggle)
│   └── Keyboard Navigation
│       ├── Enable Keyboard Shortcuts (Toggle)
│       └── Keyboard Shortcuts Help (List)
│
└── Account Tab
    ├── Data Export
    │   ├── Download My Data (Button)
    │   └── Request Account Deletion (Button)
    └── Help & Support
        ├── Contact Support (Email Link)
        ├── Report a Bug (Email Link)
        ├── Feature Request (Email Link)
        ├── Privacy Policy (Link)
        └── Terms of Service (Link)
```

---

## 📊 Priority Implementation Order

### Phase 1: Essential Features (Week 1-2)
1. ✅ **Change Password** - Already implemented and connected to backend
2. 🔄 **Notification Preferences** - High user value
3. 🔄 **Display Preferences (Theme)** - Quick win, high impact
4. 🔄 **Active Sessions** - Security essential

### Phase 2: Important Features (Week 3-4)
5. 🔄 **Two-Factor Authentication** - Security critical
6. 🔄 **Voting Preferences** - Improves user experience
7. 🔄 **Language & Region** - Accessibility
8. 🔄 **Accessibility Settings** - Inclusivity

### Phase 3: Nice-to-Have Features (Week 5-6)
9. 🔄 **Profile Visibility** - Privacy controls
10. 🔄 **Data Export** - Compliance
11. 🔄 **Help & Support** - User assistance

---

## 🛠️ Technical Implementation Details

### Backend Requirements

#### New Database Tables

```sql
-- User Preferences Table
CREATE TABLE user_preferences (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    notification_email_elections BOOLEAN DEFAULT TRUE,
    notification_email_reminders BOOLEAN DEFAULT TRUE,
    notification_email_results BOOLEAN DEFAULT TRUE,
    notification_browser_enabled BOOLEAN DEFAULT FALSE,
    notification_sound_enabled BOOLEAN DEFAULT TRUE,
    theme VARCHAR(20) DEFAULT 'auto',
    language VARCHAR(10) DEFAULT 'en',
    date_format VARCHAR(20) DEFAULT 'MM/DD/YYYY',
    time_format VARCHAR(10) DEFAULT '12-hour',
    timezone VARCHAR(50) DEFAULT 'America/Chicago',
    voting_auto_submit BOOLEAN DEFAULT FALSE,
    voting_show_confirmation BOOLEAN DEFAULT TRUE,
    profile_visibility JSON,
    accessibility_font_size VARCHAR(20) DEFAULT 'medium',
    accessibility_high_contrast BOOLEAN DEFAULT FALSE,
    accessibility_reduce_animations BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_preferences (user_id)
);

-- User Sessions Table (for tracking active sessions)
CREATE TABLE user_sessions (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    token_id VARCHAR(255) NOT NULL,
    device_type VARCHAR(50),
    browser VARCHAR(100),
    ip_address VARCHAR(45),
    location VARCHAR(255),
    last_activity TIMESTAMP,
    created_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_sessions (user_id, last_activity)
);

-- User 2FA Table
CREATE TABLE user_two_factor_auth (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    secret VARCHAR(255) NOT NULL,
    enabled BOOLEAN DEFAULT FALSE,
    backup_codes JSON,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_2fa (user_id)
);
```

#### New API Endpoints

```php
// User Preferences
GET    /api/v1/students/me/preferences
PUT    /api/v1/students/me/preferences

// Active Sessions
GET    /api/v1/students/me/sessions
DELETE /api/v1/students/me/sessions/{id}
DELETE /api/v1/students/me/sessions/all

// Two-Factor Authentication
GET    /api/v1/students/me/2fa/setup
POST   /api/v1/students/me/2fa/enable
POST   /api/v1/students/me/2fa/verify
DELETE /api/v1/students/me/2fa/disable
GET    /api/v1/students/me/2fa/backup-codes

// Data Export
GET    /api/v1/students/me/export
POST   /api/v1/students/me/export/request-deletion
```

### Frontend Components

#### Component Structure

```
client/src/
├── app/dashboard/settings/
│   ├── page.tsx (Main settings page with tabs)
│   └── components/
│       ├── SecurityTab.tsx
│       ├── NotificationsTab.tsx
│       ├── PreferencesTab.tsx
│       ├── PrivacyTab.tsx
│       ├── AccessibilityTab.tsx
│       └── AccountTab.tsx
├── components/settings/
│   ├── NotificationToggle.tsx
│   ├── ThemeSelector.tsx
│   ├── LanguageSelector.tsx
│   ├── SessionCard.tsx
│   ├── TwoFactorSetup.tsx
│   └── DataExportButton.tsx
└── hooks/
    └── useSettings.ts
```

#### State Management

- Use React Query for server state (preferences, sessions, etc.)
- Use React Context or Zustand for client-side preferences (theme, etc.)
- Persist theme/language to localStorage for immediate effect
- Sync with backend on save

---

## 🎯 UI/UX Best Practices

### Design Principles
1. **Tabbed Interface** - Organize settings into logical tabs
2. **Save Indicators** - Show what changed and when it was saved
3. **Quick Actions** - Test notifications, preview theme changes
4. **Help Tooltips** - Explain each setting with helpful text
5. **Mobile Responsive** - Ensure all settings work on mobile devices
6. **Loading States** - Show loading indicators during API calls
7. **Error Handling** - Clear error messages with retry options
8. **Success Feedback** - Toast notifications for successful saves

### Accessibility
- All form controls should have proper labels
- Keyboard navigation support
- Screen reader friendly
- High contrast mode support
- Focus indicators visible

### Performance
- Lazy load tabs (only load when clicked)
- Debounce preference saves (don't save on every keystroke)
- Cache preferences in React Query
- Optimistic updates for better UX

---

## 📝 Implementation Checklist

### Backend
- [ ] Create `user_preferences` migration
- [ ] Create `user_sessions` migration
- [ ] Create `user_two_factor_auth` migration
- [ ] Create `UserPreference` model
- [ ] Create `UserSession` model
- [ ] Create `UserTwoFactorAuth` model
- [ ] Create `UserPreferenceController`
- [ ] Create `UserSessionController`
- [ ] Create `TwoFactorAuthController`
- [ ] Add API routes
- [ ] Add validation rules
- [ ] Add middleware for session tracking

### Frontend
- [x] Create settings page with tab navigation
- [x] Create Security & Privacy tab component
- [x] Create Notifications tab component
- [x] Create Preferences tab component
- [x] Create Privacy tab component
- [x] Create Accessibility tab component
- [x] Create Account tab component
- [x] Add password change functionality (connected to backend)
- [ ] Add notification toggle components
- [ ] Add theme selector component
- [ ] Add session card component
- [ ] Add 2FA setup component
- [ ] Add data export component
- [ ] Add React Query hooks
- [ ] Add form validation
- [ ] Add error handling
- [ ] Add loading states
- [ ] Add success/error toasts
- [ ] Add mobile responsive design
- [ ] Add accessibility features

### Testing
- [ ] Unit tests for components
- [ ] Integration tests for API endpoints
- [ ] E2E tests for settings flow
- [ ] Accessibility testing
- [ ] Mobile device testing
- [ ] Cross-browser testing

---

## 🔗 Related Files

### Current Implementation
- `client/src/app/dashboard/settings/page.tsx` - Main settings page with tabs
- `client/src/app/dashboard/profile/page.tsx` - Profile page
- `backend/app/Http/Controllers/Api/Students/StudentProfileController.php` - Profile API

### Models to Create
- `backend/app/Models/UserPreference.php`
- `backend/app/Models/UserSession.php`
- `backend/app/Models/UserTwoFactorAuth.php`

### Controllers to Create
- `backend/app/Http/Controllers/Api/Students/UserPreferenceController.php`
- `backend/app/Http/Controllers/Api/Students/UserSessionController.php`
- `backend/app/Http/Controllers/Api/Students/TwoFactorAuthController.php`

---

## 📚 Additional Resources

### Libraries to Consider
- **2FA**: `speakeasy` (Node.js) or `pragmarx/google2fa` (PHP)
- **Theme**: `next-themes` (Next.js theme provider)
- **Notifications**: Browser Notification API
- **Keyboard Shortcuts**: `react-hotkeys-hook`
- **Form Validation**: `react-hook-form` + `zod` (already in use)

### Documentation
- [Web Notifications API](https://developer.mozilla.org/en-US/docs/Web/API/Notifications_API)
- [TOTP Authentication](https://en.wikipedia.org/wiki/Time-based_one-time_password)
- [WCAG Accessibility Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

---

## 🎉 Summary

This document outlines comprehensive recommendations for enhancing the student client settings page. The recommendations are prioritized based on user value, security importance, and implementation complexity.

**Key Highlights:**
- ✅ Change Password already implemented and connected to backend
- 🔄 8 major feature categories recommended
- 📊 Phased implementation approach
- 🛠️ Complete technical specifications
- 🎨 UI/UX best practices included
- 📐 Detailed UI structure blueprint

**Current Implementation Status:**
- ✅ Main settings page with tabbed interface
- ✅ Security & Privacy tab with password change (connected to backend)
- ✅ Notifications tab (UI only)
- ✅ Preferences tab (UI only)
- ✅ Privacy tab (UI only)
- ✅ Accessibility tab (UI only)
- ✅ Account tab (UI only)

**Next Steps:**
1. Review and prioritize features based on your needs
2. Start with Phase 1 features (Notifications, Theme, Sessions)
3. Create database migrations
4. Implement backend API endpoints
5. Connect frontend components to backend
6. Test thoroughly
7. Deploy incrementally

---

*Last Updated: December 2024*
*Document Version: 2.0*
