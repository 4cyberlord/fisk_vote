# Student Registration Flow - Backend Process

## Complete Backend Flow When a Student Registers via API

### Step-by-Step Process

```
┌─────────────────────────────────────────────────────────────┐
│ 1. API Request Received                                      │
│    POST /api/v1/students/register                           │
│    Controller: StudentRegistrationController@register        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Rate Limiting Check                                       │
│    - Check: Max 2 registrations per minute per IP           │
│    - If exceeded: Return 429 error                          │
│    - If OK: Increment rate limit counter                    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Request Validation                                        │
│    Validates:                                                │
│    ✓ first_name (required, string, max 255)                 │
│    ✓ middle_initial (optional, string, max 255)             │
│    ✓ last_name (required, string, max 255)                 │
│    ✓ student_id (required, numeric only, unique)            │
│    ✓ email (required, @my.fisk.edu, unique)                 │
│    ✓ password (required, Laravel Password::default())       │
│    ✓ password_confirmation (must match password)            │
│    ✓ accept_terms (required, must be true)                  │
│                                                              │
│    If validation fails → Return 422 with error details       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Database Transaction Starts                             │
│    DB::transaction(function() { ... })                      │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. Data Preparation (prepareUserData)                        │
│    - Set university_email = email                           │
│    - Combine names: "First Middle Last" → name field        │
│    - Set first_name, last_name, middle_initial              │
│    - Set student_id                                         │
│    - Hash password using Hash::make()                       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. User Model Creation                                       │
│    User::create($userData)                                  │
│                                                              │
│    Database INSERT into 'users' table:                     │
│    - id (auto-increment)                                    │
│    - name (combined from first/middle/last)                 │
│    - first_name                                             │
│    - last_name                                              │
│    - middle_initial (if provided)                          │
│    - student_id                                             │
│    - email                                                  │
│    - university_email (= email)                             │
│    - password (hashed)                                       │
│    - email_verified_at (NULL - not verified yet)            │
│    - created_at, updated_at                                 │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. User Model Boot Event (static::creating)                 │
│    - Checks if user has any role                            │
│    - If no role: Creates/gets "Student" role               │
│    - Assigns "Student" role to user                         │
│    (This happens automatically via model boot)              │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 8. Role Assignment (Explicit Check)                          │
│    - Double-check: if (!$user->hasRole('Student'))         │
│    - Get or create "Student" role                           │
│    - Assign role to user                                    │
│    - Log role assignment                                    │
│                                                              │
│    Database INSERT into 'model_has_roles' table:           │
│    - role_id (Student role ID)                              │
│    - model_type (App\Models\User)                           │
│    - model_id (user ID)                                     │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 9. Transaction Commits                                      │
│    - All database changes are committed                     │
│    - User is now saved in database                          │
│    - Role is assigned                                       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 10. Registered Event Fired                                  │
│     event(new Registered($user))                            │
│                                                              │
│     This triggers Laravel's event system:                   │
│     → SendEmailVerificationNotification listener           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 11. Email Verification Notification                         │
│     SendEmailVerificationNotification listener:             │
│     - Checks: $user instanceof MustVerifyEmail             │
│     - Checks: !$user->hasVerifiedEmail()                   │
│     - Calls: $user->sendEmailVerificationNotification()    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 12. Custom sendEmailVerificationNotification()             │
│     (Overridden in User model)                              │
│     - Creates VerifyStudentEmail notification               │
│     - Calls: $this->notify(new VerifyStudentEmail())       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 13. VerifyStudentEmail Notification                         │
│     - Uses CustomMailChannel                                │
│     - Generates verification URL:                           │
│       /api/v1/students/email/verify/{id}/{hash}            │
│     - Creates signed URL (expires in 2 minutes)            │
│     - Builds email message with:                           │
│       * Subject: "Verify Your Email Address"               │
│       * Greeting: "Hello {first_name}!"                    │
│       * Verification button/link                           │
│       * Expiration notice (2 minutes)                     │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 14. Email Sent via CustomMailChannel                        │
│     - Uses configured email service (SMTP/Mailtrap)         │
│     - Renders email template:                              │
│       resources/views/emails/verify-student-email.blade.php │
│     - Sends email to user's email address                   │
│     - Logs email send status                                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 15. Success Response Returned                               │
│     HTTP 201 Created                                        │
│     {                                                       │
│       "success": true,                                      │
│       "message": "Registration successful...",              │
│       "data": {                                             │
│         "user": {                                           │
│           "id": 1,                                          │
│           "email": "...",                                   │
│           "name": "...",                                    │
│           ...                                               │
│         }                                                   │
│       }                                                     │
│     }                                                       │
└─────────────────────────────────────────────────────────────┘
```

## Database Changes

### Tables Modified:

1. **`users` table**
   - New row inserted with user data
   - Password is hashed
   - `email_verified_at` is NULL (not verified yet)

2. **`model_has_roles` table** (Spatie Permission)
   - New row linking user to "Student" role
   - Establishes role relationship

3. **`roles` table** (if Student role doesn't exist)
   - Creates "Student" role if it doesn't exist
   - Guard: 'web'

## Events Fired

1. **`Registered` Event**
   - Fired after user creation
   - Triggers email verification notification

## Notifications Sent

1. **Email Verification**
   - Notification: `VerifyStudentEmail`
   - Channel: `CustomMailChannel`
   - Template: `emails/verify-student-email.blade.php`
   - Contains signed verification link
   - Link expires in 2 minutes

## Logging

The following events are logged:

1. **Registration Start**
   - Email, student_id, IP address

2. **Role Assignment**
   - User ID when role is assigned

3. **Registration Success**
   - User ID, email, student_id, IP address

4. **Email Sent**
   - User ID, email (via notification)

5. **Errors**
   - Validation errors
   - Rate limit violations
   - Database errors
   - Email sending failures

## Security Features

✅ **Rate Limiting**: 2 registrations per minute per IP
✅ **Password Hashing**: Bcrypt/Argon2 hashing
✅ **Email Verification**: Required before login
✅ **Role-Based Access**: Student role automatically assigned
✅ **Database Transactions**: All-or-nothing database operations
✅ **Input Validation**: Comprehensive server-side validation
✅ **Signed URLs**: Email verification links are cryptographically signed

## User State After Registration

- ✅ User account created in database
- ✅ Student role assigned
- ✅ Email verification sent
- ❌ Email NOT verified yet (`email_verified_at` = NULL)
- ❌ User CANNOT login yet (email verification required)
- ✅ User can click verification link in email
- ✅ After verification, user can login

## Next Steps for User

1. **Check Email**: User receives verification email
2. **Click Link**: User clicks verification link
3. **Email Verified**: `email_verified_at` is set in database
4. **Can Login**: User can now login via `/api/v1/students/login`
5. **Receive JWT Token**: Login returns JWT token for API access

