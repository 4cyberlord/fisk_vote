# API Routes Structure

This directory contains versioned API route files organized by resource and version.

## Structure

```
api/
├── v1/
│   └── students.php    # Student-related endpoints (v1)
├── v2/
│   └── students.php    # Future student endpoints (v2)
└── README.md           # This file
```

## Versioning Strategy

- **v1**: Current stable API version
- **v2, v3, etc.**: Future API versions for breaking changes

### When to Create a New Version

Create a new API version when:
- Making breaking changes to existing endpoints
- Changing request/response formats significantly
- Deprecating endpoints
- Major refactoring of API structure

### Version Lifecycle

1. **Active**: Current version in use (v1)
2. **Deprecated**: Previous version still supported but not recommended
3. **Retired**: Version no longer supported

## Adding New Endpoints

### For Existing Version (v1)

Add routes to the appropriate file:
- Student endpoints → `v1/students.php`
- Future resource endpoints → `v1/{resource}.php`

### For New Version (v2+)

1. Create new directory: `v2/`
2. Copy relevant route files from previous version
3. Update routes in `routes/api.php` to include new version
4. Update controllers if needed
5. Document breaking changes

## Example: Adding a New Student Endpoint

```php
// In routes/api/v1/students.php

Route::prefix('students')->group(function () {
    Route::post('/register', [StudentRegistrationController::class, 'register']);
    Route::get('/profile', [StudentProfileController::class, 'show']); // New endpoint
});
```

## Route Naming Convention

All routes should be named using the pattern:
- `api.v{version}.{resource}.{action}`

Example:
- `api.v1.students.register`
- `api.v1.students.profile`

