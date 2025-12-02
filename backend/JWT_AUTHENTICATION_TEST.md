# JWT Authentication Testing Guide

## Backend Setup Complete ✅

The JWT authentication system has been successfully set up for student login. Here's what was implemented:

### Installed & Configured
- ✅ `tymon/jwt-auth` package installed
- ✅ JWT config published (`config/jwt.php`)
- ✅ JWT secret key generated
- ✅ User model implements `JWTSubject` interface
- ✅ Auth config updated with `api` guard using JWT driver

### Created Files
- ✅ `app/Http/Controllers/Api/Students/StudentAuthController.php`
  - `login()` - Authenticate and return JWT token
  - `logout()` - Invalidate JWT token
  - `refresh()` - Refresh expired JWT token
  - `me()` - Get current authenticated user

### Updated Files
- ✅ `app/Models/User.php` - Added JWTSubject implementation
- ✅ `config/auth.php` - Added `api` guard with JWT driver
- ✅ `routes/api/v1/students.php` - Added authentication routes

## API Endpoints

### 1. Login (Public)
**POST** `/api/v1/students/login`

**Request Body:**
```json
{
  "email": "student@my.fisk.edu",
  "password": "your_password"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "token_type": "bearer",
    "expires_in": 3600,
    "user": {
      "id": 1,
      "email": "student@my.fisk.edu",
      "name": "John Doe",
      "first_name": "John",
      "last_name": "Doe",
      "email_verified_at": "2024-01-01T00:00:00.000000Z"
    }
  }
}
```

**Error Responses:**

**401 - Invalid Credentials:**
```json
{
  "success": false,
  "message": "Invalid credentials."
}
```

**403 - Email Not Verified:**
```json
{
  "success": false,
  "message": "You must verify your email address before logging in. Please check your inbox (including spam folder) for the verification email.",
  "email_verified": false
}
```

**429 - Too Many Attempts:**
```json
{
  "success": false,
  "message": "Too many login attempts. Please try again in 45 seconds."
}
```

### 2. Logout (Protected - Requires JWT)
**POST** `/api/v1/students/logout`

**Headers:**
```
Authorization: Bearer {token}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Successfully logged out."
}
```

### 3. Refresh Token (Protected - Requires JWT)
**POST** `/api/v1/students/refresh`

**Headers:**
```
Authorization: Bearer {token}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Token refreshed successfully.",
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "token_type": "bearer",
    "expires_in": 3600
  }
}
```

### 4. Get Current User (Protected - Requires JWT)
**GET** `/api/v1/students/me`

**Headers:**
```
Authorization: Bearer {token}
```

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "student@my.fisk.edu",
    "name": "John Doe",
    "first_name": "John",
    "last_name": "Doe",
    "middle_initial": "M",
    "student_id": "123456789",
    "email_verified_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

## Testing with cURL

### 1. Test Login
```bash
curl -X POST http://localhost:8000/api/v1/students/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "student@my.fisk.edu",
    "password": "your_password"
  }'
```

### 2. Test Get Current User (Replace {token} with token from login)
```bash
curl -X GET http://localhost:8000/api/v1/students/me \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"
```

### 3. Test Refresh Token
```bash
curl -X POST http://localhost:8000/api/v1/students/refresh \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"
```

### 4. Test Logout
```bash
curl -X POST http://localhost:8000/api/v1/students/logout \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"
```

## Testing with Postman

1. **Login Request:**
   - Method: POST
   - URL: `http://localhost:8000/api/v1/students/login`
   - Headers:
     - `Content-Type: application/json`
     - `Accept: application/json`
   - Body (raw JSON):
     ```json
     {
       "email": "student@my.fisk.edu",
       "password": "your_password"
     }
     ```

2. **Get Current User:**
   - Method: GET
   - URL: `http://localhost:8000/api/v1/students/me`
   - Headers:
     - `Authorization: Bearer {paste_token_here}`
     - `Accept: application/json`

3. **Refresh Token:**
   - Method: POST
   - URL: `http://localhost:8000/api/v1/students/refresh`
   - Headers:
     - `Authorization: Bearer {paste_token_here}`
     - `Accept: application/json`

4. **Logout:**
   - Method: POST
   - URL: `http://localhost:8000/api/v1/students/logout`
   - Headers:
     - `Authorization: Bearer {paste_token_here}`
     - `Accept: application/json`

## Security Features

✅ **Rate Limiting**: 5 login attempts per minute per IP
✅ **Email Verification Check**: Users must verify email before login
✅ **Student Role Check**: Only users with Student role can login
✅ **Password Hashing**: Passwords are securely hashed
✅ **JWT Token Expiration**: Tokens expire after configured time (default: 60 minutes)
✅ **Token Invalidation**: Logout invalidates the token

## Test Checklist

- [ ] Login with valid credentials returns JWT token
- [ ] Login with invalid credentials returns 401 error
- [ ] Login with unverified email returns 403 error
- [ ] Login with non-student user returns 403 error
- [ ] Too many login attempts triggers rate limiting (429)
- [ ] Protected routes require valid JWT token
- [ ] `/me` endpoint returns current user data
- [ ] Token refresh generates new token
- [ ] Logout invalidates token
- [ ] Expired token cannot be used

## Next Steps

Once backend testing is complete, we can proceed with:
1. Frontend integration (Zustand store, axios interceptors)
2. Login page integration
3. Protected route components
4. Token refresh handling

