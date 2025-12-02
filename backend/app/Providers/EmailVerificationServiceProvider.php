<?php

namespace App\Providers;

use Illuminate\Foundation\Support\Providers\RouteServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Route;
use Illuminate\Foundation\Auth\EmailVerificationRequest;
use Illuminate\Auth\Events\Verified;
use Illuminate\Http\RedirectResponse;

class EmailVerificationServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        // Override Filament's email verification route for student panel
        // This must run after Filament registers its routes, so we use a callback
        $this->app->booted(function () {
            // Remove Filament's default route if it exists
            $routes = Route::getRoutes();
            $routeToRemove = null;
            foreach ($routes as $route) {
                if ($route->getName() === 'filament.student.auth.email-verification.verify') {
                    $routeToRemove = $route;
                    break;
                }
            }

            // Register custom route for email verification success page (public, no auth required)
            Route::get('/student/email-verification/success', function () {
                $userId = session()->get('verified_user_id');
                $user = null;
                $userEmail = null;
                $userName = null;
                $theme = 'system';

                if ($userId) {
                    $user = \App\Models\User::find($userId);
                    if ($user) {
                        $userEmail = $user->email;
                        $userName = $user->first_name ?? $user->name ?? 'Student';
                    }
                }

                // Get theme from settings
                try {
                    $theme = \App\Helpers\SettingsHelper::dashboardTheme();
                } catch (\Exception $e) {
                    $theme = 'auto';
                }

                // Get the student panel to access its configuration
                $panel = \Filament\Facades\Filament::getPanel('student');

                return view('filament.student.pages.email-verification-success', [
                    'userEmail' => $userEmail,
                    'userName' => $userName,
                    'panel' => $panel,
                    'theme' => $theme,
                ]);
            })->name('student.email-verification.success');

            // Register our custom route that redirects to success page
            // Match Filament's route structure: /student/email-verification/verify/{id}/{hash}
            Route::middleware(['signed', 'throttle:6,1'])
                ->get('/student/email-verification/verify/{id}/{hash}', function ($id, $hash) {
                    // Manually resolve the user since they might not be authenticated
                    $user = \App\Models\User::findOrFail($id);

                    // Verify the hash matches
                    if (! hash_equals(sha1($user->getEmailForVerification()), (string) $hash)) {
                        abort(403, 'Invalid verification link.');
                    }

                    // Check if already verified
                    if ($user->hasVerifiedEmail()) {
                        // Already verified - redirect to success page
                        return redirect()->route('student.email-verification.success')
                            ->with('verified_user_id', $user->id);
                    }

                    // Mark email as verified
                    if ($user->markEmailAsVerified()) {
                        event(new Verified($user));
                    }

                    // Redirect to email verification success page
                    return redirect()->route('student.email-verification.success')
                        ->with('verified_user_id', $user->id);
                })
                ->name('filament.student.auth.email-verification.verify');
        });
    }
}

