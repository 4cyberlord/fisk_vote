<?php

namespace App\Http\Controllers\Api\Students;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
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
     * Login a student and return JWT token
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(Request $request)
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
     * Get the authenticated user
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function me(Request $request)
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

