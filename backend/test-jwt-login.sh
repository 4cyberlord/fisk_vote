#!/bin/bash

# JWT Authentication Test Script
# Usage: ./test-jwt-login.sh [email] [password]

BASE_URL="${BACKEND_URL:-http://localhost:8000}"
EMAIL="${1:-student@my.fisk.edu}"
PASSWORD="${2:-password123}"

echo "=========================================="
echo "JWT Authentication Test"
echo "=========================================="
echo "Base URL: $BASE_URL"
echo "Email: $EMAIL"
echo "=========================================="
echo ""

# Test 1: Login
echo "1. Testing Login..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/students/login" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{
    \"email\": \"$EMAIL\",
    \"password\": \"$PASSWORD\"
  }")

echo "$LOGIN_RESPONSE" | jq '.'
echo ""

# Extract token
TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.token // empty')

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
    echo "❌ Login failed! Cannot proceed with other tests."
    exit 1
fi

echo "✅ Login successful! Token received."
echo "Token: ${TOKEN:0:50}..."
echo ""

# Test 2: Get Current User
echo "2. Testing Get Current User (/me)..."
ME_RESPONSE=$(curl -s -X GET "$BASE_URL/api/v1/students/me" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json")

echo "$ME_RESPONSE" | jq '.'
echo ""

# Test 3: Refresh Token
echo "3. Testing Refresh Token..."
REFRESH_RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/students/refresh" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json")

echo "$REFRESH_RESPONSE" | jq '.'
echo ""

# Extract new token
NEW_TOKEN=$(echo "$REFRESH_RESPONSE" | jq -r '.data.token // empty')

if [ ! -z "$NEW_TOKEN" ] && [ "$NEW_TOKEN" != "null" ]; then
    echo "✅ Token refreshed successfully!"
    TOKEN="$NEW_TOKEN"
    echo "New Token: ${TOKEN:0:50}..."
    echo ""
fi

# Test 4: Logout
echo "4. Testing Logout..."
LOGOUT_RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/students/logout" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json")

echo "$LOGOUT_RESPONSE" | jq '.'
echo ""

# Test 5: Try to use token after logout (should fail)
echo "5. Testing Token After Logout (should fail)..."
AFTER_LOGOUT_RESPONSE=$(curl -s -X GET "$BASE_URL/api/v1/students/me" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json")

echo "$AFTER_LOGOUT_RESPONSE" | jq '.'
echo ""

echo "=========================================="
echo "Test Complete!"
echo "=========================================="

