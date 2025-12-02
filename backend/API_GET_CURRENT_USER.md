# Get Current Authenticated User API

## Endpoint
**GET** `/api/v1/students/me`

## Authentication
Requires JWT Bearer token in Authorization header:
```
Authorization: Bearer {your_jwt_token}
```

## Response Format

### Success Response (200)
```json
{
  "success": true,
  "message": "User data retrieved successfully.",
  "data": {
    // Basic Information
    "id": 1,
    "name": "John Michael Doe",
    "first_name": "John",
    "last_name": "Doe",
    "middle_initial": "Michael",
    
    // Email Information
    "email": "john.doe@my.fisk.edu",
    "university_email": "john.doe@my.fisk.edu",
    "personal_email": "john.doe@gmail.com",
    "email_verified_at": "2024-01-15T10:30:00.000000Z",
    
    // Student Information
    "student_id": "123456789",
    "department": "Computer Science",
    "major": "Software Engineering",
    "class_level": "Senior",
    "enrollment_status": "Full-time",
    "student_type": "Undergraduate",
    "citizenship_status": "US Citizen",
    
    // Contact Information
    "phone_number": "+1 (555) 123-4567",
    "address": "123 Main St, Nashville, TN 37208",
    
    // Profile Information
    "profile_photo": "/storage/profiles/user-1.jpg",
    
    // Account Information
    "roles": ["Student"],
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-15T10:30:00.000000Z"
  }
}
```

### Error Responses

**401 - Unauthorized:**
```json
{
  "success": false,
  "message": "User not authenticated."
}
```

**500 - Server Error:**
```json
{
  "success": false,
  "message": "Failed to retrieve user information.",
  "error": "Error details (only in debug mode)"
}
```

## Usage Example

### cURL
```bash
curl -X GET "http://localhost:8000/api/v1/students/me" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Accept: application/json"
```

### JavaScript (Axios)
```javascript
import axios from 'axios';

const response = await axios.get('/api/v1/students/me', {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Accept': 'application/json'
  }
});

console.log(response.data.data);
```

### Frontend Usage (React Query)
```typescript
import { useQuery } from '@tanstack/react-query';
import { api } from '@/lib/axios';

const { data, isLoading, error } = useQuery({
  queryKey: ['user', 'current'],
  queryFn: async () => {
    const response = await api.get('/students/me');
    return response.data;
  }
});
```

## Data Fields Explained

### Basic Information
- `id`: User's unique identifier
- `name`: Full name (concatenated from first, middle, last)
- `first_name`: User's first name
- `last_name`: User's last name
- `middle_initial`: User's middle name/initial

### Email Information
- `email`: Primary email address
- `university_email`: Fisk University email (@my.fisk.edu)
- `personal_email`: Personal email address (if provided)
- `email_verified_at`: Timestamp when email was verified

### Student Information
- `student_id`: Unique student identification number
- `department`: Academic department
- `major`: Field of study
- `class_level`: Academic level (Freshman, Sophomore, Junior, Senior, etc.)
- `enrollment_status`: Enrollment status (Full-time, Part-time, etc.)
- `student_type`: Type of student (Undergraduate, Graduate, etc.)
- `citizenship_status`: Citizenship status

### Contact Information
- `phone_number`: Contact phone number
- `address`: Physical address

### Profile Information
- `profile_photo`: Path to profile photo (if uploaded)

### Account Information
- `roles`: Array of user roles (e.g., ["Student"])
- `created_at`: Account creation timestamp
- `updated_at`: Last update timestamp

## Notes
- All nullable fields will return `null` if not set
- Dates are returned in ISO 8601 format
- The endpoint uses JWT authentication via the `auth:api` middleware
- Sensitive fields like `password` and `remember_token` are never returned

