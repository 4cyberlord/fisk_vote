#!/bin/bash

# Student Registration API Test Script
# Usage: ./test-registration.sh

BASE_URL="http://localhost:8000"
ENDPOINT="/api/v1/students/register"

echo "Testing Student Registration API"
echo "================================="
echo ""

# Test data
DATA='{
  "first_name": "John",
  "middle_initial": "M",
  "last_name": "Doe",
  "student_id": "'$(date +%s)'",
  "email": "john.doe'$(date +%s)'@my.fisk.edu",
  "password": "SecurePassword123!",
  "password_confirmation": "SecurePassword123!",
  "accept_terms": true
}'

echo "Request URL: ${BASE_URL}${ENDPOINT}"
echo "Request Method: POST"
echo ""
echo "Request Body:"
echo "$DATA" | jq .
echo ""
echo "Response:"
echo ""

curl -X POST "${BASE_URL}${ENDPOINT}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "$DATA" \
  -w "\n\nHTTP Status: %{http_code}\n" \
  | jq .

