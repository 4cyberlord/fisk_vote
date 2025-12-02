<?php

namespace App\Http\Controllers\Api\Students;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\ValidationException;
use Spatie\Permission\Models\Role;
use App\Notifications\VerifyStudentEmail;
use Illuminate\Auth\Events\Registered;

class StudentRegistrationController extends Controller
{
    /**
     * Register a new student
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function register(Request $request)
    {
        // Rate limiting: 2 registrations per minute per IP (matching Filament)
        $key = 'student-registration:' . $request->ip();

        if (RateLimiter::tooManyAttempts($key, 2)) {
            $seconds = RateLimiter::availableIn($key);

            Log::warning('API Register: Rate limit exceeded', [
                'ip' => $request->ip(),
                'seconds_remaining' => $seconds,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Too many registration attempts. Please try again in ' . $seconds . ' seconds.',
            ], 429);
        }

        RateLimiter::hit($key, 60); // 60 seconds = 1 minute

        try {
            // Validate the request
            $validated = $request->validate([
                'first_name' => ['required', 'string', 'max:255'],
                'middle_initial' => ['nullable', 'string', 'max:255'],
                'last_name' => ['required', 'string', 'max:255'],
                'student_id' => [
                    'required',
                    'string',
                    'max:255',
                    'regex:/^\d+$/',
                    'unique:users,student_id'
                ],
                'email' => [
                    'required',
                    'string',
                    'email',
                    'max:255',
                    'ends_with:@my.fisk.edu',
                    'unique:users,email'
                ],
                'password' => [
                    'required',
                    'string',
                    Password::default(),
                    'confirmed'
                ],
                'accept_terms' => ['required', 'accepted'],
            ], [
                'first_name.required' => 'First name is required.',
                'first_name.string' => 'First name must be a valid string.',
                'first_name.max' => 'First name may not be greater than 255 characters.',
                'last_name.required' => 'Last name is required.',
                'last_name.string' => 'Last name must be a valid string.',
                'last_name.max' => 'Last name may not be greater than 255 characters.',
                'middle_initial.string' => 'Middle initial must be a valid string.',
                'middle_initial.max' => 'Middle initial may not be greater than 255 characters.',
                'student_id.required' => 'Student ID is required.',
                'student_id.string' => 'Student ID must be a valid string.',
                'student_id.regex' => 'Student ID must contain only numbers.',
                'student_id.unique' => 'This student ID is already registered.',
                'student_id.max' => 'Student ID may not be greater than 255 characters.',
                'email.required' => 'Email address is required.',
                'email.string' => 'Email must be a valid string.',
                'email.email' => 'Please provide a valid email address.',
                'email.ends_with' => 'Please use your Fisk University email address ending with @my.fisk.edu.',
                'email.unique' => 'This email is already registered.',
                'email.max' => 'Email may not be greater than 255 characters.',
                'password.required' => 'Password is required.',
                'password.string' => 'Password must be a valid string.',
                'password.confirmed' => 'The password confirmation does not match.',
                'accept_terms.required' => 'You must accept the Terms of Service and Voting Policy to register.',
                'accept_terms.accepted' => 'You must accept the Terms of Service and Voting Policy to register.',
            ]);

            Log::info('API Register: Starting registration', [
                'email' => $validated['email'],
                'student_id' => $validated['student_id'],
                'ip' => $request->ip(),
            ]);

            // Process registration in a database transaction
            $user = DB::transaction(function () use ($validated, $request) {
                // Prepare data for user creation
                $userData = $this->prepareUserData($validated);

                // Create the user
                $user = User::create($userData);

                // Assign Student role
                if (!$user->hasRole('Student')) {
                    $studentRole = Role::firstOrCreate(['name' => 'Student', 'guard_name' => 'web']);
                    $user->assignRole($studentRole);

                    Log::info('API Register: Student role assigned', [
                        'user_id' => $user->id,
                    ]);
                }

                return $user;
            });

            // Fire registered event
            // This automatically triggers SendEmailVerificationNotification listener
            // which calls $user->sendEmailVerificationNotification()
            // We've overridden that method in User model to use VerifyStudentEmail
            //
            // However, in environments where email is not yet configured, this can fail
            // and previously caused the entire registration request to return 500.
            // We now catch any notification-related errors so the student account is
            // still created successfully, and log the problem for admins to fix.
            try {
                event(new Registered($user));
            } catch (\Throwable $notificationException) {
                Log::error('API Register: Email verification notification failed', [
                    'user_id' => $user->id,
                    'email' => $user->email,
                    'error' => $notificationException->getMessage(),
                    'trace' => $notificationException->getTraceAsString(),
                ]);
            }

            Log::info('API Register: Registration completed successfully', [
                'user_id' => $user->id,
                'email' => $user->email,
                'student_id' => $user->student_id,
                'ip' => $request->ip(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Registration successful. Please check your email to verify your account.',
                'data' => [
                    'user' => [
                        'id' => $user->id,
                        'email' => $user->email,
                        'name' => $user->name,
                        'first_name' => $user->first_name,
                        'last_name' => $user->last_name,
                        'student_id' => $user->student_id,
                        'email_verified_at' => $user->email_verified_at?->toIso8601String(),
                    ],
                ],
            ], 201);

        } catch (ValidationException $e) {
            Log::warning('API Register: Validation failed', [
                'errors' => $e->errors(),
                'ip' => $request->ip(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $e->errors(),
            ], 422);

        } catch (\Exception $e) {
            Log::error('API Register: Registration failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'ip' => $request->ip(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Registration failed. Please try again later.',
                'error' => config('app.debug') ? $e->getMessage() : 'An error occurred during registration',
            ], 500);
        }
    }

    /**
     * Prepare user data for creation
     */
    protected function prepareUserData(array $data): array
    {
        // Set university_email from email
        $userData['university_email'] = $data['email'];
        $userData['email'] = $data['email'];

        // Combine first_name, middle_initial, and last_name into name field
        $nameParts = [];
        if (!empty($data['first_name'])) {
            $nameParts[] = trim($data['first_name']);
        }
        if (!empty($data['middle_initial'])) {
            $nameParts[] = trim($data['middle_initial']);
        }
        if (!empty($data['last_name'])) {
            $nameParts[] = trim($data['last_name']);
        }
        $userData['name'] = implode(' ', $nameParts);

        // Set personal information
        $userData['first_name'] = $data['first_name'];
        $userData['last_name'] = $data['last_name'];
        if (!empty($data['middle_initial'])) {
            $userData['middle_initial'] = $data['middle_initial'];
        }

        // Set student ID
        $userData['student_id'] = $data['student_id'];

        // Hash password
        $userData['password'] = Hash::make($data['password']);

        return $userData;
    }
}

