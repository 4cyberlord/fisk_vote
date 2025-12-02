# Frontend Registration Test Guide

## ✅ Yes! You can register users from the frontend

The registration flow is fully integrated and ready to use.

## 🚀 Quick Start

### 1. Ensure Backend is Running
```bash
cd backend
php artisan serve
```
Backend should be running on `http://localhost:8000`

### 2. Set Environment Variable (if not already set)
Create `client/.env.local`:
```env
NEXT_PUBLIC_BACKEND_URL=http://localhost:8000
```

### 3. Start Frontend
```bash
cd client
npm run dev
```
Frontend should be running on `http://localhost:3000`

### 4. Test Registration
1. Navigate to `http://localhost:3000/register`
2. Fill out the registration form:
   - **First Name**: John
   - **Middle Name** (optional): M
   - **Last Name**: Doe
   - **Student ID**: 123456789 (numbers only)
   - **Email**: john.doe@my.fisk.edu (must end with @my.fisk.edu)
   - **Password**: Must be at least 8 characters with uppercase, lowercase, and number
   - **Confirm Password**: Must match password
   - **Accept Terms**: Check the checkbox
3. Click "Create account"

## ✅ What Happens During Registration

1. **Frontend Validation** (Zod schema):
   - Validates all fields client-side
   - Shows real-time validation errors
   - Prevents submission if invalid

2. **API Request**:
   - Form data sent to `/api/students/register` (Next.js API route)
   - Next.js proxies request to backend `/api/v1/students/register`

3. **Backend Processing**:
   - Validates data server-side
   - Checks for duplicate email/student_id
   - Creates user account
   - Assigns "Student" role
   - Sends verification email

4. **Success Response**:
   - Toast notification shows success message
   - User redirected to login page after 2 seconds
   - Verification email sent to user's email

## 🔍 Verification

After registration:
1. Check your email inbox (including spam folder)
2. Click the verification link in the email
3. Email will be verified
4. You can now log in at `/login`

## 🐛 Troubleshooting

### "Failed to connect to server"
- Ensure backend is running on port 8000
- Check `NEXT_PUBLIC_BACKEND_URL` in `.env.local`
- Restart frontend after changing env variables

### "Email already registered"
- Email or Student ID already exists in database
- Use a different email or student ID

### "Validation failed"
- Check form validation errors shown in toast notifications
- Ensure all required fields are filled correctly
- Password must meet requirements (8+ chars, uppercase, lowercase, number)

### Email not received
- Check spam folder
- Verify email configuration in backend `.env`
- Check backend logs for email sending errors

## 📋 Registration Requirements

- **First Name**: Required, max 255 characters
- **Last Name**: Required, max 255 characters
- **Middle Name**: Optional, max 255 characters
- **Student ID**: Required, numbers only, unique, max 255 characters
- **Email**: Required, must end with @my.fisk.edu, unique
- **Password**: 
  - Minimum 8 characters
  - At least one uppercase letter
  - At least one lowercase letter
  - At least one number
- **Confirm Password**: Must match password
- **Accept Terms**: Required checkbox

## 🎯 Registration Flow Diagram

```
User fills form → Frontend validation (Zod) → Submit
    ↓
Next.js API route (/api/students/register)
    ↓
Backend API (/api/v1/students/register)
    ↓
Validation → Create User → Assign Role → Send Email
    ↓
Success Response → Toast Notification → Redirect to Login
```

## ✨ Features

- ✅ Real-time form validation
- ✅ Type-safe form handling
- ✅ Server-side validation
- ✅ Duplicate checking
- ✅ Email verification
- ✅ Toast notifications
- ✅ Error handling
- ✅ Loading states
- ✅ Auto-redirect on success

