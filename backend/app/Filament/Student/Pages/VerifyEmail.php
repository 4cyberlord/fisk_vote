<?php

namespace App\Filament\Student\Pages;

use Filament\Auth\Pages\EmailVerification\EmailVerificationPrompt as BaseEmailVerificationPrompt;
use Illuminate\Foundation\Auth\EmailVerificationRequest;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Route;

class VerifyEmail extends BaseEmailVerificationPrompt
{
    public function mount(): void
    {
        // Override the default mount to allow unauthenticated users
        // (they'll be authenticated via the signed URL)
    }

    /**
     * Handle the email verification request via the route.
     * This method is called when the verification link is clicked.
     */
    public static function verifyEmail(EmailVerificationRequest $request): RedirectResponse
    {
        if ($request->user()->hasVerifiedEmail()) {
            // Already verified - redirect to registration wizard verification step
            return redirect()->route('filament.student.auth.register', ['step' => 'verification'])
                ->with('verified', true);
        }

        if ($request->user()->markEmailAsVerified()) {
            event(new \Illuminate\Auth\Events\Verified($request->user()));
        }

        // Redirect to registration wizard at verification step
        return redirect()->route('filament.student.auth.register', ['step' => 'verification'])
            ->with('verified', true);
    }
}
