# Student Elections API

## Endpoints

### Get Active Elections

**Endpoint:** `GET /api/v1/students/elections/active`

**Authentication:** Required (JWT Bearer Token)

**Description:** Retrieves all active elections that the authenticated student is eligible to vote in.

**Response:**

```json
{
  "success": true,
  "message": "Active elections retrieved successfully.",
  "data": [
    {
      "id": 1,
      "title": "Student Government Election 2024",
      "description": "Annual student government election",
      "type": "multiple",
      "max_selection": 3,
      "ranking_levels": null,
      "allow_write_in": false,
      "allow_abstain": true,
      "start_time": "2024-01-15T08:00:00Z",
      "end_time": "2024-01-20T18:00:00Z",
      "current_status": "Open",
      "has_voted": false,
      "positions_count": 5,
      "candidates_count": 15,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-10T00:00:00Z"
    }
  ],
  "meta": {
    "total": 1,
    "timestamp": "2024-01-16T12:00:00Z"
  }
}
```

**Filters:**
- Only returns elections with `status = 'active'`
- Only returns elections where current time is between `start_time` and `end_time`
- Only returns elections where the user is eligible (based on `is_universal` flag or `eligible_groups`)

---

### Get Election Details

**Endpoint:** `GET /api/v1/students/elections/{id}`

**Authentication:** Required (JWT Bearer Token)

**Description:** Retrieves detailed information about a specific election, including positions and candidates.

**Response:**

```json
{
  "success": true,
  "message": "Election retrieved successfully.",
  "data": {
    "id": 1,
    "title": "Student Government Election 2024",
    "description": "Annual student government election",
    "type": "multiple",
    "max_selection": 3,
    "ranking_levels": null,
    "allow_write_in": false,
    "allow_abstain": true,
    "start_time": "2024-01-15T08:00:00Z",
    "end_time": "2024-01-20T18:00:00Z",
    "status": "active",
    "current_status": "Open",
    "has_voted": false,
    "positions": [
      {
        "id": 1,
        "name": "President",
        "description": "Student Body President",
        "type": "single",
        "max_selection": null,
        "ranking_levels": null,
        "allow_abstain": false,
        "candidates": [
          {
            "id": 1,
            "user_id": 10,
            "user": {
              "id": 10,
              "name": "John Doe",
              "first_name": "John",
              "last_name": "Doe",
              "email": "jdoe@my.fisk.edu",
              "profile_photo": null
            },
            "photo_url": null,
            "tagline": "Building a better future",
            "bio": "Experienced student leader",
            "manifesto": "My vision for the student body...",
            "approved": true,
            "created_at": "2024-01-05T00:00:00Z"
          }
        ]
      }
    ],
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-10T00:00:00Z"
  }
}
```

**Error Responses:**

- `401 Unauthorized`: User not authenticated
- `403 Forbidden`: User is not eligible to view this election
- `404 Not Found`: Election not found

---

## Eligibility Rules

An election is eligible for a student if:

1. **Universal Elections**: If `is_universal = true`, all students are eligible
2. **Group-Based Eligibility**: If `is_universal = false`, the student must match at least one of:
   - Department in `eligible_groups.departments[]`
   - Class level in `eligible_groups.class_levels[]`
   - Organization membership in `eligible_groups.organizations[]`
   - User ID in `eligible_groups.manual[]`

---

## Usage Examples

### cURL - Get Active Elections

```bash
curl -X GET "http://localhost:8000/api/v1/students/elections/active" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Accept: application/json"
```

### cURL - Get Election Details

```bash
curl -X GET "http://localhost:8000/api/v1/students/elections/1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Accept: application/json"
```

### JavaScript/TypeScript

```typescript
// Using axios
const response = await axios.get('/api/v1/students/elections/active', {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Accept': 'application/json'
  }
});

const activeElections = response.data.data;
```

