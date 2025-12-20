# Complete Registration Fields Documentation

## 📋 All Information Needed for Student Registration

This document lists **ALL** fields required and optional for complete student registration in the Fisk Voting System.

---

## ✅ REQUIRED FIELDS (Must be provided)

### 1. **first_name** (Required)
- **Type**: `string`
- **Max Length**: 255 characters
- **Description**: Student's first name
- **Example**: `"John"`
- **Validation Rules**:
  - Required
  - Must be a valid string
  - Maximum 255 characters
- **Error Messages**:
  - "First name is required."
  - "First name must be a valid string."
  - "First name may not be greater than 255 characters."

### 2. **last_name** (Required)
- **Type**: `string`
- **Max Length**: 255 characters
- **Description**: Student's last name
- **Example**: `"Doe"`
- **Validation Rules**:
  - Required
  - Must be a valid string
  - Maximum 255 characters
- **Error Messages**:
  - "Last name is required."
  - "Last name must be a valid string."
  - "Last name may not be greater than 255 characters."

### 3. **student_id** (Required)
- **Type**: `string` (numeric only)
- **Max Length**: 255 characters
- **Description**: Student's unique identification number
- **Example**: `"123456789"`
- **Validation Rules**:
  - Required
  - Must be a string
  - Must contain **only numbers** (regex: `/^\d+$/`)
  - Must be **unique** (not already registered)
  - Maximum 255 characters
- **Error Messages**:
  - "Student ID is required."
  - "Student ID must be a valid string."
  - "Student ID must contain only numbers."
  - "This student ID is already registered."
  - "Student ID may not be greater than 255 characters."

### 4. **email** (Required)
- **Type**: `string` (email format)
- **Max Length**: 255 characters
- **Description**: Student's Fisk University email address
- **Example**: `"john.doe@my.fisk.edu"`
- **Validation Rules**:
  - Required
  - Must be a valid email format
  - **Must end with `@my.fisk.edu`** (domain restriction)
  - Must be **unique** (not already registered)
  - Maximum 255 characters
- **Error Messages**:
  - "Email address is required."
  - "Email must be a valid string."
  - "Please provide a valid email address."
  - "Please use your Fisk University email address ending with @my.fisk.edu."
  - "This email is already registered."
  - "Email may not be greater than 255 characters."

### 5. **password** (Required)
- **Type**: `string`
- **Description**: User's password
- **Example**: `"SecurePassword123!"`
- **Validation Rules**:
  - Required
  - Must be a valid string
  - Must meet **Laravel Password::default()** requirements:
    - **Minimum 8 characters**
    - At least one letter
    - At least one number
    - Mixed case recommended (but not strictly required by default)
  - Must match `password_confirmation`
- **Error Messages**:
  - "Password is required."
  - "Password must be a valid string."
  - "The password confirmation does not match."
  - Password strength validation messages from Laravel

### 6. **password_confirmation** (Required)
- **Type**: `string`
- **Description**: Confirmation of the password (must match password)
- **Example**: `"SecurePassword123!"`
- **Validation Rules**:
  - Required
  - Must exactly match the `password` field
- **Error Messages**:
  - "The password confirmation does not match."

### 7. **accept_terms** (Required)
- **Type**: `boolean`
- **Description**: Acceptance of Terms of Service and Voting Policy
- **Example**: `true`
- **Validation Rules**:
  - Required
  - Must be `true` (accepted)
  - Cannot be `false` or omitted
- **Error Messages**:
  - "You must accept the Terms of Service and Voting Policy to register."

---

## 🔹 OPTIONAL FIELDS (Can be omitted)

### 1. **middle_initial** (Optional)
- **Type**: `string` or `null`
- **Max Length**: 255 characters
- **Description**: Student's middle initial or middle name
- **Example**: `"M"` or `"Michael"`
- **Validation Rules**:
  - Optional (nullable)
  - If provided, must be a valid string
  - Maximum 255 characters
- **Error Messages**:
  - "Middle initial must be a valid string."
  - "Middle initial may not be greater than 255 characters."
- **Note**: If provided, it will be included in the full name: `"John M Doe"`

---

## 📝 COMPLETE REQUEST EXAMPLE

### JSON Request Body
```json
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

### Minimal Request (without optional field)
```json
{
  "first_name": "John",
  "last_name": "Doe",
  "student_id": "123456789",
  "email": "john.doe@my.fisk.edu",
  "password": "SecurePassword123!",
  "password_confirmation": "SecurePassword123!",
  "accept_terms": true
}
```

---

## 🔐 PASSWORD REQUIREMENTS DETAILS

Laravel's `Password::default()` typically requires:
- ✅ **Minimum 8 characters**
- ✅ **At least one letter** (a-z or A-Z)
- ✅ **At least one number** (0-9)
- ⚠️ Mixed case (uppercase and lowercase) is recommended but not strictly enforced by default
- ⚠️ Special characters are recommended but not strictly required by default

**Good Password Examples:**
- `"SecurePass123"` ✅
- `"MyPassword456"` ✅
- `"SecurePassword123!"` ✅
- `"Student2024"` ✅

**Bad Password Examples:**
- `"12345678"` ❌ (no letters)
- `"password"` ❌ (no numbers, might fail depending on Laravel version)
- `"pass123"` ❌ (less than 8 characters)

---

## 🔄 AUTOMATIC PROCESSING

The following fields are **automatically set** by the backend (you don't need to provide them):

### 1. **name** (Auto-generated)
- **Description**: Full name constructed from first_name, middle_initial, and last_name
- **Format**: `"{first_name} {middle_initial} {last_name}"` or `"{first_name} {last_name}"` if no middle_initial
- **Example**: `"John M Doe"` or `"John Doe"`

### 2. **university_email** (Auto-set)
- **Description**: Automatically set to the same value as `email`
- **Example**: If email is `"john.doe@my.fisk.edu"`, university_email will also be `"john.doe@my.fisk.edu"`

### 3. **password** (Auto-hashed)
- **Description**: Password is automatically hashed using `Hash::make()` before storage
- **Note**: Never store or send plain text passwords

### 4. **role** (Auto-assigned)
- **Description**: Automatically assigned "Student" role
- **Note**: This happens automatically during user creation

### 5. **email_verified_at** (Initially null)
- **Description**: Set to `null` initially, updated after email verification
- **Note**: User must verify email before they can log in

---

## 📊 FIELD SUMMARY TABLE

| Field Name | Type | Required | Max Length | Special Rules | Example |
|------------|------|----------|------------|---------------|---------|
| `first_name` | string | ✅ Yes | 255 | - | `"John"` |
| `middle_initial` | string | ❌ No | 255 | - | `"M"` |
| `last_name` | string | ✅ Yes | 255 | - | `"Doe"` |
| `student_id` | string | ✅ Yes | 255 | Numeric only, unique | `"123456789"` |
| `email` | string | ✅ Yes | 255 | Must end with @my.fisk.edu, unique | `"john.doe@my.fisk.edu"` |
| `password` | string | ✅ Yes | - | Min 8 chars, Laravel default rules | `"SecurePass123!"` |
| `password_confirmation` | string | ✅ Yes | - | Must match password | `"SecurePass123!"` |
| `accept_terms` | boolean | ✅ Yes | - | Must be true | `true` |

---

## 🚫 FIELDS NOT USED IN REGISTRATION

The following fields exist in the User model but are **NOT** part of registration (they can be updated later in profile):

- `personal_email` - Personal email (separate from university email)
- `phone_number` - Contact phone number
- `address` - Physical address
- `department` - Academic department
- `major` - Field of study
- `class_level` - Academic level (Freshman, Sophomore, etc.)
- `enrollment_status` - Enrollment status
- `student_type` - Type of student (Undergraduate, Graduate, etc.)
- `citizenship_status` - Citizenship status
- `profile_photo` - Profile picture

---

## ⚠️ IMPORTANT NOTES

1. **Email Domain Restriction**: Only `@my.fisk.edu` emails are accepted
2. **Student ID Uniqueness**: Each student_id can only be used once
3. **Email Uniqueness**: Each email can only be used once
4. **Password Confirmation**: Must exactly match the password field
5. **Terms Acceptance**: Must be explicitly set to `true` (not just present)
6. **Rate Limiting**: Maximum 2 registration attempts per minute per IP address
7. **Email Verification**: After registration, user must verify email before login
8. **Automatic Role Assignment**: "Student" role is automatically assigned

---

## 📡 API ENDPOINT

**URL**: `POST /api/v1/students/register`

**Headers**:
```
Content-Type: application/json
Accept: application/json
```

**Success Response** (201 Created):
```json
{
  "success": true,
  "message": "Registration successful. Please check your email to verify your account.",
  "data": {
    "user": {
      "id": 1,
      "email": "john.doe@my.fisk.edu",
      "name": "John M Doe",
      "first_name": "John",
      "last_name": "Doe",
      "student_id": "123456789",
      "email_verified_at": null
    }
  }
}
```

**Error Response** (422 Validation Error):
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["Please use your Fisk University email address ending with @my.fisk.edu."],
    "student_id": ["This student ID is already registered."],
    "password": ["The password confirmation does not match."]
  }
}
```

---

## ✅ REGISTRATION CHECKLIST

Before submitting registration, ensure:

- [ ] First name is provided and valid
- [ ] Last name is provided and valid
- [ ] Middle initial is optional (can be omitted)
- [ ] Student ID is numeric only and unique
- [ ] Email ends with `@my.fisk.edu` and is unique
- [ ] Password meets requirements (min 8 chars, has letters and numbers)
- [ ] Password confirmation matches password exactly
- [ ] Terms acceptance is set to `true`
- [ ] All required fields are present
- [ ] No rate limiting issues (max 2 attempts per minute)

---

**Last Updated**: Based on `StudentRegistrationController.php` validation rules

