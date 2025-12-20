<?php

namespace App\Http\Controllers\Api\Students;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;

class StudentAuthController extends Controller
{
    /**
     * Login a student
     *
     * Authenticates a student and returns a JWT token for subsequent API requests.
     * The student must have a verified email address to login.
     *
     * @group Student Authentication
     * @unauthenticated
     *
     * @bodyParam email string required The student's email address. Example: john.doe@my.fisk.edu
     * @bodyParam password string required The student's password. Example: SecurePass123!
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Login successful.",
     *   "data": {
     *     "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
     *     "token_type": "bearer",
     *     "expires_in": 3600,
     *     "user": {
     *       "id": 1,
     *       "email": "john.doe@my.fisk.edu",
     *       "name": "John Doe",
     *       "first_name": "John",
     *       "last_name": "Doe",
     *       "email_verified_at": "2024-01-15T10:30:00+00:00"
     *     }
     *   }
     * }
     * @response 422 {
     *   "success": false,
     *   "message": "Invalid email or password."
     * }
     * @response 403 {
     *   "success": false,
     *   "message": "You must verify your email address before logging in.",
     *   "email_verified": false
     * }
     * @response 429 {
     *   "success": false,
     *   "message": "Too many login attempts. Please try again in 60 seconds."
     * }
     */
    public function login(Request $request): JsonResponse
    {
        // Rate limiting: 5 login attempts per minute per IP
        $key = 'student-login:' . $request->ip();

        if (RateLimiter::tooManyAttempts($key, 5)) {
            $seconds = RateLimiter::availableIn($key);

            return response()->json([
                'success' => false,
                'message' => 'Too many login attempts. Please try again in ' . $seconds . ' seconds.',
            ], 429);
        }

        RateLimiter::hit($key, 60); // 60 seconds = 1 minute

        try {
            // Validate the request
            $validated = $request->validate([
                'email' => ['required', 'string', 'email'],
                'password' => ['required', 'string'],
            ], [
                'email.required' => 'Email address is required.',
                'email.email' => 'Please provide a valid email address.',
                'password.required' => 'Password is required.',
            ]);

            // Find user by email
            $user = User::where('email', $validated['email'])->first();

            // Check if user exists
            if (!$user) {
                Log::warning('API Login: User not found', [
                    'email' => $validated['email'],
                    'ip' => $request->ip(),
                ]);

                // Return 422 (Unprocessable Entity) for validation/auth errors
                // This prevents Next.js from treating it as a navigation
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid email or password.',
                ], 422);
            }

            // Check if email is verified
            if (!$user->hasVerifiedEmail()) {
                Log::warning('API Login: Email not verified', [
                    'user_id' => $user->id,
                    'email' => $user->email,
                    'ip' => $request->ip(),
                ]);

                return response()->json([
                    'success' => false,
                    'message' => 'You must verify your email address before logging in. Please check your inbox (including spam folder) for the verification email.',
                    'email_verified' => false,
                ], 403);
            }

            // Verify password
            if (!Hash::check($validated['password'], $user->password)) {
                Log::warning('API Login: Invalid password', [
                    'user_id' => $user->id,
                    'email' => $user->email,
                    'ip' => $request->ip(),
                ]);

                // Return 422 (Unprocessable Entity) for validation/auth errors
                // This prevents Next.js from treating it as a navigation
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid email or password.',
                ], 422);
            }

            // Check if user has Student role
            if (!$user->hasRole('Student')) {
                Log::warning('API Login: User does not have Student role', [
                    'user_id' => $user->id,
                    'email' => $user->email,
                    'ip' => $request->ip(),
                ]);

                return response()->json([
                    'success' => false,
                    'message' => 'Access denied. Student role required.',
                ], 403);
            }

            // Generate JWT token
            try {
                $token = JWTAuth::fromUser($user);

                // Store session information
                try {
                    $sessionService = app(\App\Services\SessionService::class);
                    $sessionService->createSession($token, $user->id, $request);
                } catch (\Exception $e) {
                    // Don't break login if session storage fails
                    Log::warning('Failed to store session: ' . $e->getMessage());
                }

                // Log successful login to audit log
                try {
                    $auditLogService = app(\App\Services\AuditLogService::class);
                    $auditLogService->logAuth(
                        'login.success',
                        "User logged in via API: {$user->email}",
                        $user,
                        'success'
                    );
                } catch (\Exception $e) {
                    // Don't break login if audit logging fails
                    Log::warning('Failed to log login to audit log: ' . $e->getMessage());
                }

                Log::info('API Login: Successful login', [
                    'user_id' => $user->id,
                    'email' => $user->email,
                    'ip' => $request->ip(),
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Login successful.',
                    'data' => [
                        'token' => $token,
                        'token_type' => 'bearer',
                        'expires_in' => config('jwt.ttl') * 60, // Convert minutes to seconds
                        'user' => [
                            'id' => $user->id,
                            'email' => $user->email,
                            'name' => $user->name,
                            'first_name' => $user->first_name,
                            'last_name' => $user->last_name,
                            'email_verified_at' => $user->email_verified_at?->toIso8601String(),
                        ],
                    ],
                ], 200);

            } catch (JWTException $e) {
                Log::error('API Login: JWT token generation failed', [
                    'user_id' => $user->id,
                    'error' => $e->getMessage(),
                ]);

                return response()->json([
                    'success' => false,
                    'message' => 'Could not create token. Please try again.',
                ], 500);
            }

        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $e->errors(),
            ], 422);

        } catch (\Exception $e) {
            Log::error('API Login: Login failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Login failed. Please try again later.',
                'error' => config('app.debug') ? $e->getMessage() : 'An error occurred during login',
            ], 500);
        }
    }

    /**
     * Logout the authenticated user (invalidate token)
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function logout(Request $request)
    {
        try {
            $token = JWTAuth::getToken();

            $user = auth('api')->user();

            if ($token) {
                // Remove session from database
                try {
                    $payload = JWTAuth::setToken($token)->getPayload();
                    $jti = $payload->get('jti') ?? null;
                    if ($jti && $user) {
                        \App\Models\UserJwtSession::where('jti', $jti)
                            ->where('user_id', $user->id)
                            ->delete();
                    }
                } catch (\Exception $e) {
                    Log::warning('Failed to remove session from database: ' . $e->getMessage());
                }

                JWTAuth::invalidate($token);

                // Log logout to audit log
                if ($user) {
                    try {
                        $auditLogService = app(\App\Services\AuditLogService::class);
                        $auditLogService->logAuth(
                            'logout.success',
                            "User logged out via API: {$user->email}",
                            $user,
                            'success'
                        );
                    } catch (\Exception $e) {
                        Log::warning('Failed to log logout to audit log: ' . $e->getMessage());
                    }
                }

                Log::info('API Logout: Successful logout', [
                    'user_id' => $user?->id,
                    'ip' => $request->ip(),
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Successfully logged out.',
            ], 200);

        } catch (JWTException $e) {
            Log::error('API Logout: Logout failed', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to logout. Please try again.',
            ], 500);
        }
    }

    /**
     * Refresh the JWT token
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function refresh(Request $request)
    {
        try {
            $token = JWTAuth::getToken();

            if (!$token) {
                return response()->json([
                    'success' => false,
                    'message' => 'Token not provided.',
                ], 401);
            }

            $newToken = JWTAuth::refresh($token);

            Log::info('API Refresh: Token refreshed', [
                'user_id' => auth()->id(),
                'ip' => $request->ip(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Token refreshed successfully.',
                'data' => [
                    'token' => $newToken,
                    'token_type' => 'bearer',
                    'expires_in' => config('jwt.ttl') * 60, // Convert minutes to seconds
                ],
            ], 200);

        } catch (JWTException $e) {
            Log::error('API Refresh: Token refresh failed', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Could not refresh token. Please login again.',
            ], 401);
        }
    }

    /**
     * Resend verification email
     *
     * Resends the email verification link to the user's email address.
     * Rate limited to prevent abuse.
     *
     * @group Student Authentication
     * @unauthenticated
     *
     * @bodyParam email string required The student's email address. Example: john.doe@my.fisk.edu
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Verification link sent. Please check your email."
     * }
     * @response 422 {
     *   "success": false,
     *   "message": "Email address not found."
     * }
     * @response 400 {
     *   "success": false,
     *   "message": "Email already verified."
     * }
     * @response 429 {
     *   "success": false,
     *   "message": "Too many attempts. Please try again in 60 seconds."
     * }
     */
    public function resendVerification(Request $request): JsonResponse
    {
        // Rate limiting: 3 resend attempts per minute per IP
        $key = 'resend-verification:' . $request->ip();

        if (RateLimiter::tooManyAttempts($key, 3)) {
            $seconds = RateLimiter::availableIn($key);

            return response()->json([
                'success' => false,
                'message' => 'Too many attempts. Please try again in ' . $seconds . ' seconds.',
            ], 429);
        }

        RateLimiter::hit($key, 60); // 60 seconds = 1 minute

        try {
            // Validate the request
            $validated = $request->validate([
                'email' => ['required', 'string', 'email'],
            ], [
                'email.required' => 'Email address is required.',
                'email.email' => 'Please provide a valid email address.',
            ]);

            // Find user by email
            $user = User::where('email', $validated['email'])->first();

            if (!$user) {
                Log::warning('API Resend Verification: User not found', [
                    'email' => $validated['email'],
                    'ip' => $request->ip(),
                ]);

                return response()->json([
                    'success' => false,
                    'message' => 'Email address not found.',
                ], 422);
            }

            // Check if already verified
            if ($user->hasVerifiedEmail()) {
                Log::info('API Resend Verification: Email already verified', [
                    'user_id' => $user->id,
                    'email' => $user->email,
                    'ip' => $request->ip(),
                ]);

                return response()->json([
                    'success' => false,
                    'message' => 'Email already verified. You can now login.',
                ], 400);
            }

            // Send verification email
            try {
                $user->sendEmailVerificationNotification();

                Log::info('API Resend Verification: Verification email sent', [
                    'user_id' => $user->id,
                    'email' => $user->email,
                    'ip' => $request->ip(),
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Verification link sent. Please check your email (including spam folder).',
                ], 200);

            } catch (\Exception $e) {
                Log::error('API Resend Verification: Failed to send email', [
                    'user_id' => $user->id,
                    'email' => $user->email,
                    'error' => $e->getMessage(),
                    'ip' => $request->ip(),
                ]);

                return response()->json([
                    'success' => false,
                    'message' => 'Failed to send verification email. Please try again later.',
                ], 500);
            }

        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $e->errors(),
            ], 422);

        } catch (\Exception $e) {
            Log::error('API Resend Verification: Error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'An error occurred. Please try again later.',
            ], 500);
        }
    }

    /**
     * Get the authenticated user
     *
     * Returns the complete profile information of the currently authenticated student.
     * Requires a valid JWT token in the Authorization header.
     *
     * @group Student Profile
     *
     * @response 200 {
     *   "success": true,
     *   "message": "User data retrieved successfully.",
     *   "data": {
     *     "id": 1,
     *     "name": "John Doe",
     *     "first_name": "John",
     *     "last_name": "Doe",
     *     "middle_initial": "A",
     *     "email": "john.doe@my.fisk.edu",
     *     "university_email": "john.doe@my.fisk.edu",
     *     "personal_email": null,
     *     "email_verified_at": "2024-01-15T10:30:00+00:00",
     *     "student_id": "12345678",
     *     "department": "Computer Science",
     *     "major": "Software Engineering",
     *     "class_level": "Senior",
     *     "enrollment_status": "Active",
     *     "student_type": "Full-time",
     *     "citizenship_status": "US Citizen",
     *     "phone_number": "+1234567890",
     *     "address": "123 Main St",
     *     "profile_photo": null,
     *     "roles": ["Student"],
     *     "organizations": [],
     *     "created_at": "2024-01-15T10:00:00+00:00",
     *     "updated_at": "2024-01-15T10:30:00+00:00"
     *   }
     * }
     * @response 401 {
     *   "success": false,
     *   "message": "User not authenticated."
     * }
     */
    public function me(Request $request): JsonResponse
    {
        try {
            $user = auth('api')->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated.',
                ], 401);
            }

            // Get user roles
            $roles = $user->getRoleNames();

            Log::info('API Me: User data retrieved successfully', [
                'user_id' => $user->id,
                'email' => $user->email,
            ]);

            // Get user organizations
            $organizations = $user->organizations ?? [];

            return response()->json([
                'success' => true,
                'message' => 'User data retrieved successfully.',
                'data' => [
                    // Basic Information
                    'id' => $user->id,
                    'name' => $user->name,
                    'first_name' => $user->first_name,
                    'last_name' => $user->last_name,
                    'middle_initial' => $user->middle_initial,

                    // Email Information
                    'email' => $user->email,
                    'university_email' => $user->university_email,
                    'personal_email' => $user->personal_email,
                    'email_verified_at' => $user->email_verified_at?->toIso8601String(),

                    // Student Information
                    'student_id' => $user->student_id,
                    'department' => $user->department,
                    'major' => $user->major,
                    'class_level' => $user->class_level,
                    'enrollment_status' => $user->enrollment_status,
                    'student_type' => $user->student_type,
                    'citizenship_status' => $user->citizenship_status,

                    // Contact Information
                    'phone_number' => $user->phone_number,
                    'address' => $user->address,

                    // Profile Information
                    'profile_photo' => $user->profile_photo,

                    // Account Information
                    'roles' => $roles,
                    'organizations' => $organizations,
                    'created_at' => $user->created_at?->toIso8601String(),
                    'updated_at' => $user->updated_at?->toIso8601String(),
                ],
            ], 200);

        } catch (\Exception $e) {
            Log::error('API Me: Failed to get user', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve user information.',
                'error' => config('app.debug') ? $e->getMessage() : 'An error occurred',
            ], 500);
        }
    }
}

