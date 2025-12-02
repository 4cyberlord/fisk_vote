# JWT Authentication Implementation Plan

## Overview
This document outlines the complete JWT authentication flow for the Fisk Voting System, covering both backend (Laravel) and frontend (Next.js) implementations.

## Architecture Flow

```
┌─────────────────┐
│   User Login    │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│  Frontend: Login Form    │
│  (Next.js)               │
└────────┬─────────────────┘
         │ POST /api/v1/students/login
         ▼
┌─────────────────────────┐
│  Backend: Login API     │
│  (Laravel)              │
│  - Validate credentials │
│  - Generate JWT token   │
│  - Return token + user  │
└────────┬─────────────────┘
         │ { token, user, expires_at }
         ▼
┌─────────────────────────┐
│  Frontend: Store Token  │
│  - Save to cookie       │
│  - Decode with jwt-decode│
│  - Store user in Zustand│
└────────┬─────────────────┘
         │
         ▼
┌─────────────────────────┐
│  Subsequent Requests    │
│  - Axios interceptor   │
│  - Add Bearer token    │
│  - Auto-refresh if expired│
└─────────────────────────┘
```

## Backend Changes (Laravel)

### 1. Install JWT Package
```bash
composer require tymon/jwt-auth
php artisan vendor:publish --provider="Tymon\JWTAuth\Providers\LaravelServiceProvider"
php artisan jwt:secret
```

### 2. Update User Model
- Implement `JWTSubject` interface
- Add `getJWTIdentifier()` and `getJWTCustomClaims()` methods

### 3. Update Auth Config (`config/auth.php`)
- Add `api` guard with `jwt` driver
- Keep `web` guard for Filament (session-based)

### 4. Create Login Controller
**File**: `backend/app/Http/Controllers/Api/Students/StudentAuthController.php`
- `login()` - Validate credentials, return JWT token
- `logout()` - Invalidate token
- `refresh()` - Refresh expired token
- `me()` - Get current authenticated user

### 5. Create API Routes
**File**: `backend/routes/api/v1/students.php`
```php
// Public routes
Route::post('/login', [StudentAuthController::class, 'login']);

// Protected routes (require JWT)
Route::middleware('auth:api')->group(function () {
    Route::post('/logout', [StudentAuthController::class, 'logout']);
    Route::post('/refresh', [StudentAuthController::class, 'refresh']);
    Route::get('/me', [StudentAuthController::class, 'me']);
});
```

### 6. JWT Configuration
- Token expiration: 60 minutes (configurable)
- Refresh token expiration: 2 weeks
- Algorithm: HS256

## Frontend Changes (Next.js)

### 1. Create Auth Store (Zustand)
**File**: `client/src/store/authStore.ts`
- State: `user`, `token`, `isAuthenticated`, `isLoading`
- Actions: `login()`, `logout()`, `setUser()`, `checkAuth()`

### 2. Create Axios Instance
**File**: `client/src/lib/axios.ts`
- Base URL configuration
- Request interceptor: Add JWT token to headers
- Response interceptor: Handle 401 errors, refresh tokens

### 3. Create Auth Service
**File**: `client/src/services/authService.ts`
- `login(email, password)` - Call login API
- `logout()` - Clear token and user
- `refreshToken()` - Refresh expired token
- `getCurrentUser()` - Fetch current user

### 4. Create Auth Hooks
**File**: `client/src/hooks/useAuth.ts`
- `useAuth()` - Access auth store
- `useLogin()` - Login mutation with React Query
- `useLogout()` - Logout mutation

### 5. Update Login Page
**File**: `client/src/app/(auth)/login/page.tsx`
- Integrate with auth service
- Handle form submission
- Show loading/error states
- Redirect on success

### 6. Create Protected Route Component
**File**: `client/src/components/common/ProtectedRoute.tsx`
- Check authentication status
- Redirect to login if not authenticated
- Show loading state

### 7. Token Storage Strategy
- **Option 1**: HTTP-only cookies (most secure, requires backend support)
- **Option 2**: Secure cookies with `js-cookie` (client-side)
- **Option 3**: localStorage (less secure, but simpler)

**Recommendation**: Use secure cookies with `js-cookie` for now, can upgrade to HTTP-only later.

## Security Considerations

1. **Token Storage**: Use secure, httpOnly cookies when possible
2. **Token Expiration**: Short-lived access tokens (60 min) + refresh tokens
3. **CSRF Protection**: Use Laravel's CSRF for web routes
4. **Rate Limiting**: Apply to login endpoints
5. **HTTPS Only**: Ensure tokens only sent over HTTPS in production

## API Endpoints

### POST `/api/v1/students/login`
**Request:**
```json
{
  "email": "student@my.fisk.edu",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "token_type": "bearer",
    "expires_in": 3600,
    "user": {
      "id": 1,
      "email": "student@my.fisk.edu",
      "name": "John Doe",
      "email_verified_at": "2024-01-01T00:00:00.000000Z"
    }
  }
}
```

### POST `/api/v1/students/logout`
**Headers:** `Authorization: Bearer {token}`

**Response (200):**
```json
{
  "success": true,
  "message": "Successfully logged out"
}
```

### POST `/api/v1/students/refresh`
**Headers:** `Authorization: Bearer {token}`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "token_type": "bearer",
    "expires_in": 3600
  }
}
```

### GET `/api/v1/students/me`
**Headers:** `Authorization: Bearer {token}`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "student@my.fisk.edu",
    "name": "John Doe",
    "email_verified_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

## Implementation Order

1. ✅ Backend: Install and configure JWT
2. ✅ Backend: Create login endpoint
3. ✅ Backend: Create auth middleware
4. ✅ Frontend: Create auth store
5. ✅ Frontend: Set up axios with interceptors
6. ✅ Frontend: Update login page
7. ✅ Frontend: Create protected routes
8. ✅ Testing: End-to-end authentication flow

## Testing Checklist

- [ ] User can login with valid credentials
- [ ] User receives JWT token on successful login
- [ ] User cannot login with invalid credentials
- [ ] User cannot login if email not verified
- [ ] Token is stored securely in frontend
- [ ] Token is sent with subsequent API requests
- [ ] Protected routes require authentication
- [ ] User can logout successfully
- [ ] Token refresh works when expired
- [ ] User is redirected to login when token expires

