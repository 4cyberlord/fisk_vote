<?php

namespace App\Http\Controllers\Api\Students;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class StudentProfileController extends Controller
{
    /**
     * Update the authenticated student's profile photo.
     *
     * POST /api/v1/students/me/profile-photo
     */
    public function updateProfilePhoto(Request $request)
    {
        try {
            $user = auth('api')->user();

            if (! $user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated.',
                ], 401);
            }

            // Log incoming file for debugging
            Log::info('Profile photo upload attempt', [
                'user_id' => $user->id,
                'has_file' => $request->hasFile('profile_photo'),
                'file_info' => $request->hasFile('profile_photo') ? [
                    'original_name' => $request->file('profile_photo')->getClientOriginalName(),
                    'mime_type' => $request->file('profile_photo')->getMimeType(),
                    'client_mime' => $request->file('profile_photo')->getClientMimeType(),
                    'size' => $request->file('profile_photo')->getSize(),
                    'extension' => $request->file('profile_photo')->getClientOriginalExtension(),
                ] : null,
            ]);

            $validated = $request->validate([
                'profile_photo' => 'required|file|mimetypes:image/jpeg,image/png,image/gif,image/webp|max:2048', // 2MB (PHP default)
            ], [
                'profile_photo.required' => 'Please select an image to upload.',
                'profile_photo.file' => 'The uploaded file is invalid.',
                'profile_photo.mimetypes' => 'The image must be a JPEG, PNG, GIF, or WebP file.',
                'profile_photo.max' => 'The image must not exceed 2MB.',
            ]);

            $file = $request->file('profile_photo');

            if (! $file || ! $file->isValid()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid image file.',
                ], 422);
            }

            // Delete existing profile photo file if stored locally
            if ($user->profile_photo && str_starts_with($user->profile_photo, '/storage/')) {
                $oldPath = str_replace('/storage/', '', $user->profile_photo);
                if (Storage::disk('public')->exists($oldPath)) {
                    Storage::disk('public')->delete($oldPath);
                }
            }

            // Store new file
            $path = $file->store('profile-photos', 'public');
            $publicUrl = Storage::url($path);

            $oldPhoto = $user->profile_photo;
            $user->update([
                'profile_photo' => $publicUrl,
            ]);

            // Log profile photo update to audit log
            try {
                $auditLogService = app(\App\Services\AuditLogService::class);
                $auditLogService->logUserAction(
                    'profile.photo.updated',
                    "Updated profile photo",
                    $user,
                    ['old_photo' => $oldPhoto],
                    ['new_photo' => $publicUrl],
                    'success'
                );
            } catch (\Exception $e) {
                Log::warning('Failed to log profile photo update to audit log: ' . $e->getMessage());
            }

            Log::info('API Student Profile: Updated profile photo', [
                'user_id' => $user->id,
                'profile_photo' => $publicUrl,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Profile photo updated successfully.',
                'data' => [
                    'profile_photo' => $publicUrl,
                ],
            ], 200);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed.',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            Log::error('API Student Profile: Failed to update profile photo', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'An unexpected error occurred. Please try again later.',
                'error' => config('app.debug') ? $e->getMessage() : 'An unexpected error occurred',
            ], 500);
        }
    }

    /**
     * Change the authenticated student's password.
     *
     * POST /api/v1/students/me/change-password
     */
    public function changePassword(Request $request)
    {
        try {
            $user = auth('api')->user();

            if (! $user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated.',
                ], 401);
            }

            $validated = $request->validate([
                'current_password' => ['required', 'string'],
                'new_password' => ['required', 'string', 'confirmed', Password::min(8)],
                'new_password_confirmation' => ['required', 'string'],
            ], [
                'current_password.required' => 'Current password is required.',
                'new_password.required' => 'New password is required.',
                'new_password.confirmed' => 'New password confirmation does not match.',
                'new_password.min' => 'New password must be at least 8 characters.',
            ]);

            // Verify current password
            if (! Hash::check($request->current_password, $user->password)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Current password is incorrect.',
                    'errors' => [
                        'current_password' => ['The current password you entered is incorrect.'],
                    ],
                ], 422);
            }

            // Check if new password is same as current
            if (Hash::check($request->new_password, $user->password)) {
                return response()->json([
                    'success' => false,
                    'message' => 'New password must be different from your current password.',
                    'errors' => [
                        'new_password' => ['New password must be different from your current password.'],
                    ],
                ], 422);
            }

            // Update password
            $user->update([
                'password' => Hash::make($request->new_password),
            ]);

            // Log password change to audit log
            try {
                $auditLogService = app(\App\Services\AuditLogService::class);
                $auditLogService->logUserAction(
                    'profile.password.changed',
                    "Changed password",
                    $user,
                    [],
                    [],
                    'success'
                );
            } catch (\Exception $e) {
                Log::warning('Failed to log password change to audit log: ' . $e->getMessage());
            }

            Log::info('API Student Profile: Password changed successfully', [
                'user_id' => $user->id,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Password changed successfully.',
            ], 200);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed.',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            Log::error('API Student Profile: Failed to change password', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'user_id' => $user->id ?? 'unknown',
            ]);

            return response()->json([
                'success' => false,
                'message' => 'An unexpected error occurred. Please try again later.',
                'error' => config('app.debug') ? $e->getMessage() : 'An unexpected error occurred',
            ], 500);
        }
    }

    /**
     * Update the authenticated student's profile.
     *
     * PUT /api/v1/students/me
     */
    public function updateProfile(Request $request)
    {
        try {
            $user = auth('api')->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated.',
                ], 401);
            }

            $validated = $request->validate([
                'personal_email' => ['nullable', 'string', 'email', 'max:255'],
                'phone_number' => ['nullable', 'string', 'max:255'],
                'address' => ['nullable', 'string', 'max:500'],
                'department' => ['nullable', 'string', 'max:255'],
                'major' => ['nullable', 'string', 'max:255'],
                'class_level' => ['nullable', 'string', 'in:Freshman,Sophomore,Junior,Senior'],
                'student_type' => ['nullable', 'string', 'in:Undergraduate,Graduate,Transfer,International'],
                'enrollment_status' => ['nullable', 'string', 'in:Active,Suspended,Graduated'],
                'citizenship_status' => ['nullable', 'string', 'max:255'],
                'organizations' => ['nullable', 'array'],
                'organizations.*' => ['exists:organizations,id'],
            ], [
                'personal_email.email' => 'Please provide a valid email address.',
                'class_level.in' => 'Class level must be one of: Freshman, Sophomore, Junior, Senior.',
                'student_type.in' => 'Student type must be one of: Undergraduate, Graduate, Transfer, International.',
                'enrollment_status.in' => 'Enrollment status must be one of: Active, Suspended, Graduated.',
            ]);

            // Update user profile fields
            $user->update([
                'personal_email' => $validated['personal_email'] ?? $user->personal_email,
                'phone_number' => $validated['phone_number'] ?? $user->phone_number,
                'address' => $validated['address'] ?? $user->address,
                'department' => $validated['department'] ?? $user->department,
                'major' => $validated['major'] ?? $user->major,
                'class_level' => $validated['class_level'] ?? $user->class_level,
                'student_type' => $validated['student_type'] ?? $user->student_type,
                'enrollment_status' => $validated['enrollment_status'] ?? $user->enrollment_status,
                'citizenship_status' => $validated['citizenship_status'] ?? $user->citizenship_status,
            ]);

            // Sync organizations if provided
            if (isset($validated['organizations'])) {
                $user->organizations()->sync($validated['organizations']);
            }

            // Refresh user to get updated data
            $user->refresh();

            Log::info('API Student Profile: Updated profile', [
                'user_id' => $user->id,
                'updated_fields' => array_keys($validated),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Profile updated successfully.',
                'data' => [
                    'user' => [
                        'id' => $user->id,
                        'email' => $user->email,
                        'name' => $user->name,
                        'first_name' => $user->first_name,
                        'last_name' => $user->last_name,
                        'student_id' => $user->student_id,
                        'department' => $user->department,
                        'major' => $user->major,
                        'class_level' => $user->class_level,
                        'student_type' => $user->student_type,
                        'enrollment_status' => $user->enrollment_status,
                        'citizenship_status' => $user->citizenship_status,
                        'personal_email' => $user->personal_email,
                        'phone_number' => $user->phone_number,
                        'address' => $user->address,
                    ],
                ],
            ], 200);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed.',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            Log::error('API Student Profile: Failed to update profile', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'user_id' => $user->id ?? 'unknown',
            ]);

            return response()->json([
                'success' => false,
                'message' => 'An unexpected error occurred. Please try again later.',
                'error' => config('app.debug') ? $e->getMessage() : 'An unexpected error occurred',
            ], 500);
        }
    }
}


