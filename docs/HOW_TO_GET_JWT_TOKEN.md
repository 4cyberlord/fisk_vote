# How to Get Your JWT Bearer Token

The JWT token is generated when you log in and is stored in multiple places. Here are all the ways to access it:

---

## 1. From Browser Developer Tools (Easiest Method)

### Step 1: Open Developer Tools
- **Chrome/Edge:** Press `F12` or `Ctrl+Shift+I` (Windows) / `Cmd+Option+I` (Mac)
- **Firefox:** Press `F12` or `Ctrl+Shift+I` (Windows) / `Cmd+Option+I` (Mac)
- **Safari:** Press `Cmd+Option+I` (Mac)

### Step 2: Go to Application/Storage Tab
- **Chrome/Edge:** Click on "Application" tab → "Cookies" → Select your domain
- **Firefox:** Click on "Storage" tab → "Cookies" → Select your domain
- **Safari:** Click on "Storage" tab → "Cookies"

### Step 3: Find the Token
Look for a cookie named **`auth_token`** and copy its value. That's your JWT Bearer token!

**Example:**
```
Name: auth_token
Value: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgwMDAvYXBpL3YxL3N0dWRlbnRzL2xvZ2luIiwiaWF0IjoxNzA1MjM0NTY3LCJleHAiOjE3MDUzMjA5NjcsIm5iZiI6MTcwNTIzNDU2NywianRpIjoiYWJjMTIzIiwic3ViIjoiMSIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjcifQ.xyz123...
```

---

## 2. From Browser Console (JavaScript)

Open the browser console (same as DevTools) and run:

```javascript
// Get token from cookie
document.cookie.split('; ').find(row => row.startsWith('auth_token='))?.split('=')[1]
```

Or if you're using the `js-cookie` library (which the app uses):

```javascript
// In browser console
Cookies.get('auth_token')
```

**Note:** This only works if `js-cookie` is available in the global scope. You might need to access it through the app's context.

---

## 3. From the Login API Response

When you log in via the API, the token is returned in the response:

**Endpoint:** `POST /api/v1/students/login`

**Response:**
```json
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "token_type": "bearer",
    "expires_in": 86400,
    "user": { ... }
  }
}
```

The `data.token` field contains your JWT Bearer token.

---

## 4. Programmatically in Your Frontend Code

### Using the Auth Store (Zustand)

```typescript
import { useAuthStore } from "@/store/authStore";

function MyComponent() {
  const { token } = useAuthStore();
  
  console.log("My token:", token);
  
  return <div>Token: {token ? "Found" : "Not found"}</div>;
}
```

### Using Cookies Directly

```typescript
import Cookies from "js-cookie";

function MyComponent() {
  const token = Cookies.get("auth_token");
  
  console.log("My token:", token);
  
  return <div>Token: {token ? "Found" : "Not found"}</div>;
}
```

---

## 5. Testing with Postman

### Step 1: Login First
1. **Method:** POST
2. **URL:** `http://localhost:8000/api/v1/students/login`
3. **Body (JSON):**
   ```json
   {
     "email": "your-email@my.fisk.edu",
     "password": "your-password"
   }
   ```
4. **Response:** Copy the `token` from `data.token`

### Step 2: Use Token in Other Requests
1. **Method:** GET (or any other)
2. **URL:** `http://localhost:8000/api/v1/students/elections/active`
3. **Headers:**
   - Key: `Authorization`
   - Value: `Bearer YOUR_TOKEN_HERE`
   - Or use Postman's "Bearer Token" auth type

---

## 6. Testing with cURL

### Step 1: Login and Save Token
```bash
# Login and save token to variable
TOKEN=$(curl -X POST "http://localhost:8000/api/v1/students/login" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"email":"your-email@my.fisk.edu","password":"your-password"}' \
  | jq -r '.data.token')

# Display token
echo "Token: $TOKEN"
```

### Step 2: Use Token in Requests
```bash
curl -X GET "http://localhost:8000/api/v1/students/elections/active" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json"
```

---

## 7. Quick Browser Console Script

Copy and paste this into your browser console after logging in:

```javascript
(function() {
  // Get token from cookie
  const cookies = document.cookie.split('; ');
  const authCookie = cookies.find(c => c.startsWith('auth_token='));
  
  if (authCookie) {
    const token = authCookie.split('=')[1];
    console.log('🔑 Your JWT Token:');
    console.log(token);
    console.log('\n📋 Copy this for Postman/cURL:');
    console.log(`Bearer ${token}`);
    
    // Copy to clipboard (if supported)
    if (navigator.clipboard) {
      navigator.clipboard.writeText(token).then(() => {
        console.log('\n✅ Token copied to clipboard!');
      });
    }
  } else {
    console.log('❌ No auth_token cookie found. Please log in first.');
  }
})();
```

---

## Token Storage Locations

The token is stored in **3 places**:

1. **Browser Cookie** (`auth_token`)
   - Location: Browser's cookie storage
   - Expires: 24 hours
   - Path: `/` (available site-wide)

2. **Zustand Store** (in-memory)
   - Location: React state management
   - Persisted to: `localStorage` (key: `auth-storage`)

3. **LocalStorage** (via Zustand persist)
   - Location: Browser's localStorage
   - Key: `auth-storage`
   - Contains: `{ user, token, isAuthenticated }`

---

## Important Notes

- **Token Expiration:** Tokens expire after 24 hours (configurable in backend)
- **Auto-Refresh:** The axios interceptor automatically refreshes expired tokens
- **Security:** Never share your token publicly or commit it to version control
- **Token Format:** JWT tokens have 3 parts separated by dots: `header.payload.signature`

---

## Troubleshooting

### "No token found"
- Make sure you're logged in
- Check if cookies are enabled in your browser
- Try logging out and logging back in

### "Token expired"
- The token expires after 24 hours
- Log in again to get a new token
- The app should auto-refresh tokens, but if it fails, log in again

### "Invalid token"
- Make sure you copied the entire token (it's very long)
- Don't include "Bearer " prefix when copying from cookie
- Check for extra spaces or line breaks

