<?php

namespace App\Http\Requests;

use Illuminate\Auth\Events\Verified;
use Illuminate\Foundation\Auth\EmailVerificationRequest as BaseEmailVerificationRequest;
use Illuminate\Http\RedirectResponse;

class StudentEmailVerificationRequest extends BaseEmailVerificationRequest
{
    /**
     * Fulfill the email verification request.
     *
     * @return RedirectResponse
     */
    public function fulfill(): RedirectResponse
    {
        if ($this->user()->hasVerifiedEmail()) {
            // Already verified - redirect to registration wizard verification step
            return redirect()->route('filament.student.auth.register', ['step' => 'verification'])
                ->with('verified', true);
        }

        if ($this->user()->markEmailAsVerified()) {
            event(new Verified($this->user()));
        }

        // Redirect to registration wizard at verification step
        return redirect()->route('filament.student.auth.register', ['step' => 'verification'])
            ->with('verified', true);
    }
}

