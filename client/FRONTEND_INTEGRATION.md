# Frontend JWT Authentication Integration

This document outlines the frontend JWT authentication integration using all the installed packages.

## 📦 Packages Used

### Core Authentication
- **zustand** - State management for auth state
- **@tanstack/react-query** - Data fetching and caching
- **axios** - HTTP client with interceptors
- **jwt-decode** - JWT token decoding
- **js-cookie** - Cookie management for tokens

### Form Handling & Validation
- **react-hook-form** - Form state management
- **@hookform/resolvers** - Zod resolver for react-hook-form
- **zod** - Schema validation

### UI & UX
- **react-hot-toast** - Toast notifications
- **@heroicons/react** - Icons (available for use)
- **dayjs** - Date manipulation (available for use)
- **classnames** - Class utilities (already using clsx)

## 🏗️ Architecture

### State Management (`src/store/authStore.ts`)
- Zustand store with persistence
- Manages user state, token, and authentication status
- Handles token validation and expiration checks
- Syncs with cookies for axios interceptors

### HTTP Client (`src/lib/axios.ts`)
- Configured axios instance with base URL
- Request interceptor: Adds JWT token to headers
- Response interceptor: Handles token refresh on 401 errors
- Automatic redirect to login on auth failure

### Auth Service (`src/services/authService.ts`)
- Service layer for authentication operations
- Methods: `login()`, `logout()`, `refreshToken()`, `getCurrentUser()`
- Type-safe interfaces for all responses

### React Hooks (`src/hooks/useAuth.ts`)
- `useAuth()` - Access auth store
- `useLogin()` - Login mutation with React Query
- `useLogout()` - Logout mutation
- `useCurrentUser()` - Fetch current user data
- `useRefreshToken()` - Token refresh mutation

### Form Schemas (`src/lib/schemas/authSchemas.ts`)
- Zod schemas for all auth forms
- Login, Register, Forgot Password, Reset Password
- Type-safe form data with TypeScript inference

### Components
- **ProtectedRoute** - HOC for protecting routes
- **Providers** - React Query and Toast providers
- Updated Login and Register pages with form validation

## 🔐 Authentication Flow

### Login Flow
1. User submits login form with email/password
2. Form validated with Zod schema
3. `useLogin()` hook calls `authService.login()`
4. Axios sends request to `/api/v1/students/login`
5. On success:
   - Token stored in cookie and Zustand store
   - User data stored in Zustand store
   - React Query cache updated
   - Toast notification shown
   - Redirect to home page

### Protected Routes
- Wrap any route with `<ProtectedRoute>` component
- Automatically checks authentication on mount
- Redirects to login if not authenticated
- Shows loading state during check

### Token Refresh
- Automatic token refresh on 401 errors
- Axios interceptor handles refresh transparently
- Retries original request with new token
- Logs out user if refresh fails

### Logout Flow
1. User clicks logout button
2. `useLogout()` hook calls `authService.logout()`
3. Token invalidated on server
4. Local state cleared (Zustand + Cookies)
5. React Query cache cleared
6. Redirect to login page

## 📝 Usage Examples

### Using Protected Routes
```tsx
import { ProtectedRoute } from "@/components";

export default function DashboardPage() {
  return (
    <ProtectedRoute>
      <div>Protected content here</div>
    </ProtectedRoute>
  );
}
```

### Using Auth State
```tsx
import { useAuth } from "@/hooks/useAuth";

export default function ProfilePage() {
  const { user, isAuthenticated, logout } = useAuth();
  
  if (!isAuthenticated) return <div>Not logged in</div>;
  
  return (
    <div>
      <p>Welcome, {user?.name}</p>
      <button onClick={logout}>Logout</button>
    </div>
  );
}
```

### Using Login Hook
```tsx
import { useLogin } from "@/hooks/useAuth";

export default function LoginPage() {
  const loginMutation = useLogin();
  
  const handleSubmit = async (data) => {
    await loginMutation.mutateAsync({
      email: data.email,
      password: data.password,
    });
  };
  
  return (
    <form onSubmit={handleSubmit}>
      {/* form fields */}
      <button disabled={loginMutation.isPending}>
        {loginMutation.isPending ? "Logging in..." : "Login"}
      </button>
    </form>
  );
}
```

### Making Authenticated API Calls
```tsx
import { api } from "@/lib/axios";

// Token is automatically added by interceptor
const response = await api.get("/students/me");
```

## 🔧 Environment Variables

Add to `.env.local`:
```env
NEXT_PUBLIC_BACKEND_URL=http://localhost:8000
```

## ✅ Features Implemented

- ✅ JWT token management (storage, validation, refresh)
- ✅ Automatic token refresh on expiration
- ✅ Protected route component
- ✅ Form validation with Zod
- ✅ Toast notifications for user feedback
- ✅ Loading states and error handling
- ✅ Type-safe API calls
- ✅ Persistent auth state (localStorage)
- ✅ Cookie-based token storage for SSR compatibility
- ✅ Login and Register pages integrated
- ✅ Logout functionality

## 🚀 Next Steps

1. Add more protected routes (dashboard, profile, etc.)
2. Implement forgot password flow
3. Add user profile management
4. Implement role-based access control
5. Add refresh token rotation
6. Add session timeout handling

