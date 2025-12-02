# API v1 Routes

Version 1 of the Fisk Voting System API.

## Endpoints

### Students

**Base Path**: `/api/v1/students`

| Method | Endpoint | Controller | Description |
|--------|----------|------------|-------------|
| POST | `/register` | `StudentRegistrationController@register` | Register a new student account |

## Usage Examples

### Register Student

```bash
POST /api/v1/students/register
Content-Type: application/json

{
  "first_name": "John",
  "middle_initial": "M",
  "last_name": "Doe",
  "student_id": "123456789",
  "email": "john.doe@my.fisk.edu",
  "password": "SecurePassword123!",
  "password_confirmation": "SecurePassword123!",
  "accept_terms": true
}
```

**Success Response (201)**:
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

**Error Response (422)**:
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["The email has already been taken."],
    "student_id": ["The student id has already been taken."]
  }
}
```

