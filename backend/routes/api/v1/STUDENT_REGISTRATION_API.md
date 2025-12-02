# Student Registration API - Quick Reference

## API Endpoint

### Registration URL

**Full URL**: `http://localhost:8000/api/v1/students/register`

**Route Name**: `api.v1.students.register`

**Method**: `POST`

**Content-Type**: `application/json`

---

## Request Format

### Headers
```
Content-Type: application/json
Accept: application/json
```

### Request Body
```json
{
  "first_name": "John",
  "middle_initial": "M",              // Optional
  "last_name": "Doe",
  "student_id": "123456789",
  "email": "john.doe@my.fisk.edu",     // Must end with @my.fisk.edu
  "password": "SecurePassword123!",
  "password_confirmation": "SecurePassword123!",
  "accept_terms": true                 // Must be true
}
```

### Required Fields
- `first_name` (string, max 255)
- `last_name` (string, max 255)
- `student_id` (string, numeric only, unique)
- `email` (string, must end with @my.fisk.edu, unique)
- `password` (string, must meet Laravel Password::default() rules)
- `password_confirmation` (string, must match password)
- `accept_terms` (boolean, must be true)

### Optional Fields
- `middle_initial` (string, max 255)

---

## Response Examples

### Success Response (201 Created)
```json
{
  "success": true,
  "message": "Registration successful. Please check your email to verify your account.",
  "user": {
    "id": 1,
    "email": "john.doe@my.fisk.edu",
    "name": "John M Doe"
  }
}
```

### Validation Error Response (422 Unprocessable Entity)
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["The email has already been taken."],
    "student_id": ["The student id has already been taken."],
    "password": ["The password confirmation does not match."]
  }
}
```

### Server Error Response (500 Internal Server Error)
```json
{
  "success": false,
  "message": "Registration failed. Please try again later.",
  "error": "Error details (only in debug mode)"
}
```

---

## Usage Examples

### Using cURL
```bash
curl -X POST http://localhost:8000/api/v1/students/register \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "first_name": "John",
    "middle_initial": "M",
    "last_name": "Doe",
    "student_id": "123456789",
    "email": "john.doe@my.fisk.edu",
    "password": "SecurePassword123!",
    "password_confirmation": "SecurePassword123!",
    "accept_terms": true
  }'
```

### Using JavaScript/Fetch
```javascript
const response = await fetch('http://localhost:8000/api/v1/students/register', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
  body: JSON.stringify({
    first_name: 'John',
    middle_initial: 'M',
    last_name: 'Doe',
    student_id: '123456789',
    email: 'john.doe@my.fisk.edu',
    password: 'SecurePassword123!',
    password_confirmation: 'SecurePassword123!',
    accept_terms: true,
  }),
});

const result = await response.json();
console.log(result);
```

### Using Next.js Frontend API Route
The frontend uses a proxy route at `/api/students/register` which forwards to the backend:

```javascript
// From client-side code
const response = await fetch('/api/students/register', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    first_name: 'John',
    // ... other fields
  }),
});
```

---

## Frontend Integration

### Next.js API Route
**Frontend Route**: `/api/students/register`  
**Backend Route**: `/api/v1/students/register`

The frontend API route (`client/src/app/api/students/register/route.ts`) acts as a proxy and forwards requests to the Laravel backend.

### Environment Variable
Make sure `NEXT_PUBLIC_BACKEND_URL` is set in your `.env.local`:
```
NEXT_PUBLIC_BACKEND_URL=http://localhost:8000
```

---

## Testing

### Test with Postman/Insomnia
1. Method: `POST`
2. URL: `http://localhost:8000/api/v1/students/register`
3. Headers:
   - `Content-Type: application/json`
   - `Accept: application/json`
4. Body (raw JSON): Use the request body format above

### Test with Laravel Tinker
```php
php artisan tinker

$response = Http::post('http://localhost:8000/api/v1/students/register', [
    'first_name' => 'John',
    'middle_initial' => 'M',
    'last_name' => 'Doe',
    'student_id' => '123456789',
    'email' => 'john.doe@my.fisk.edu',
    'password' => 'SecurePassword123!',
    'password_confirmation' => 'SecurePassword123!',
    'accept_terms' => true,
]);

$response->json();
```

---

## Notes

- The API automatically assigns the "Student" role to new users
- Email verification is sent automatically after registration
- Password must meet Laravel's default password requirements (min 8 characters, etc.)
- Student ID must be numeric only
- Email must end with `@my.fisk.edu`
- All fields are validated server-side

