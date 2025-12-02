<?php

namespace App\Http\Controllers\Auth;

use Illuminate\Auth\Events\Verified;
use Illuminate\Foundation\Auth\EmailVerificationRequest;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Auth;

class VerifyEmailController extends \Illuminate\Routing\Controller
{
    /**
     * Mark the authenticated user's email address as verified.
     */
    public function __invoke(EmailVerificationRequest $request): RedirectResponse
    {
        if ($request->user()->hasVerifiedEmail()) {
            // Already verified - redirect to registration wizard verification step
            return redirect()->route('filament.student.auth.register', ['step' => 'verification'])
                ->with('verified', true);
        }

        if ($request->user()->markEmailAsVerified()) {
            event(new Verified($request->user()));
        }

        // Redirect to registration wizard at verification step
        return redirect()->route('filament.student.auth.register', ['step' => 'verification'])
            ->with('verified', true);
    }
}

