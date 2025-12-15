<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Students\StudentRegistrationController;
use App\Http\Controllers\Api\Students\StudentAuthController;
use App\Http\Controllers\Api\Students\StudentElectionController;
use App\Http\Controllers\Api\Students\StudentVoteController;
use App\Http\Controllers\Api\Students\StudentProfileController;
use App\Http\Controllers\Api\Students\StudentAnalyticsController;
use App\Http\Controllers\Api\Students\StudentAuditLogController;
use App\Http\Controllers\Api\Students\StudentSessionController;
use App\Http\Controllers\Api\Students\StudentCalendarController;
use App\Http\Controllers\Api\Students\NotificationController;

/*
|--------------------------------------------------------------------------
| API v1 - Student Routes
|--------------------------------------------------------------------------
|
| Version 1 of the Student API endpoints.
| All student-related routes are organized here for easy reference and maintenance.
|
*/

Route::prefix('students')->group(function () {
    // Public routes (no authentication required)

    // Public Elections listing (no auth required)
    Route::get('/public/elections', [StudentElectionController::class, 'getPublicElections'])
        ->name('api.v1.students.elections.public');

    // Registration
    Route::post('/register', [StudentRegistrationController::class, 'register'])
        ->name('api.v1.students.register');

    // Authentication
    Route::post('/login', [StudentAuthController::class, 'login'])
        ->name('api.v1.students.login');

    // Email Verification (for API registrations)
    Route::middleware(['signed', 'throttle:6,1'])
        ->get('/email/verify/{id}/{hash}', function ($id, $hash, \Illuminate\Http\Request $request) {
            $user = \App\Models\User::findOrFail($id);

            // Verify the hash matches
            if (! hash_equals(sha1($user->getEmailForVerification()), (string) $hash)) {
                // Check if request wants JSON (API call)
                if ($request->wantsJson() || $request->expectsJson()) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Invalid verification link.',
                    ], 403);
                }
                // Web request - redirect to error page or login
                abort(403, 'Invalid verification link.');
            }

            // Check if already verified
            $alreadyVerified = $user->hasVerifiedEmail();

            // Mark email as verified if not already verified
            if (!$alreadyVerified && $user->markEmailAsVerified()) {
                event(new \Illuminate\Auth\Events\Verified($user));
            }

            // Check if request wants JSON (API call)
            if ($request->wantsJson() || $request->expectsJson()) {
                return response()->json([
                    'success' => true,
                    'message' => $alreadyVerified ? 'Email already verified.' : 'Email verified successfully.',
                    'verified' => true,
                ], 200);
            }

            // Web request - redirect to Next.js frontend email verified page
            $frontendUrl = env('FRONTEND_URL', 'http://localhost:3000');
            return redirect($frontendUrl . '/email-verified')
                ->with('verified', true)
                ->with('message', 'Email verified successfully! You can now log in.');
        })
        ->name('api.v1.students.email.verify');

    // Protected routes (require JWT authentication)
    Route::middleware(['auth:api', 'log.api.activity'])->group(function () {
        // Authentication
        Route::post('/logout', [StudentAuthController::class, 'logout'])
            ->name('api.v1.students.logout');

        Route::post('/refresh', [StudentAuthController::class, 'refresh'])
            ->name('api.v1.students.refresh');

        Route::get('/me', [StudentAuthController::class, 'me'])
            ->name('api.v1.students.me');

        // Profile
        Route::post('/me/profile-photo', [StudentProfileController::class, 'updateProfilePhoto'])
            ->name('api.v1.students.profile.photo');

        Route::post('/me/change-password', [StudentProfileController::class, 'changePassword'])
            ->name('api.v1.students.profile.password');

        // Audit Logs
        Route::get('/me/audit-logs', [StudentAuditLogController::class, 'getMyAuditLogs'])
            ->name('api.v1.students.audit-logs');

        // Sessions
        Route::get('/me/sessions', [StudentSessionController::class, 'getMySessions'])
            ->name('api.v1.students.sessions.index');
        Route::delete('/me/sessions/others', [StudentSessionController::class, 'revokeAllOtherSessions'])
            ->name('api.v1.students.sessions.revoke.others');
        Route::delete('/me/sessions/all', [StudentSessionController::class, 'revokeAllSessions'])
            ->name('api.v1.students.sessions.revoke.all');
        Route::delete('/me/sessions/{jti}', [StudentSessionController::class, 'revokeSession'])
            ->name('api.v1.students.sessions.revoke');

        // Calendar
        Route::get('/calendar/events', [StudentCalendarController::class, 'getEvents'])
            ->name('api.v1.students.calendar.events');

        // Analytics
        Route::get('/analytics', [StudentAnalyticsController::class, 'getAnalytics'])
            ->name('api.v1.students.analytics');

        // Elections
        Route::get('/elections', [StudentElectionController::class, 'getAllElections'])
            ->name('api.v1.students.elections.all');

        Route::get('/elections/active', [StudentElectionController::class, 'getActiveElections'])
            ->name('api.v1.students.elections.active');

        // Results - MUST come before /elections/{id} to avoid route conflict
        Route::get('/elections/results', [\App\Http\Controllers\Api\Students\StudentResultsController::class, 'getAllResults'])
            ->name('api.v1.students.elections.results.all');

        Route::get('/elections/{id}/results', [\App\Http\Controllers\Api\Students\StudentResultsController::class, 'getElectionResults'])
            ->name('api.v1.students.elections.results.show');

        // Specific election - MUST come after /elections/results
        Route::get('/elections/{id}', [StudentElectionController::class, 'getElection'])
            ->name('api.v1.students.elections.show');

        // Voting
        Route::get('/votes', [StudentVoteController::class, 'getMyVotes'])
            ->name('api.v1.students.votes.mine');

        Route::get('/elections/{id}/ballot', [StudentVoteController::class, 'getBallot'])
            ->name('api.v1.students.elections.ballot');

        Route::post('/elections/{id}/vote', [StudentVoteController::class, 'castVote'])
            ->name('api.v1.students.elections.vote');

        // Notifications
        Route::get('/notifications', [NotificationController::class, 'index'])
            ->name('api.v1.students.notifications.index');
        Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount'])
            ->name('api.v1.students.notifications.unread-count');
        Route::post('/notifications/{id}/read', [NotificationController::class, 'markAsRead'])
            ->name('api.v1.students.notifications.mark-read');
        Route::post('/notifications/read-all', [NotificationController::class, 'markAllAsRead'])
            ->name('api.v1.students.notifications.mark-all-read');

        // Future protected endpoints can be added here:
        // Route::get('/profile', [StudentProfileController::class, 'show']);
        // Route::put('/profile', [StudentProfileController::class, 'update']);
    });
});

