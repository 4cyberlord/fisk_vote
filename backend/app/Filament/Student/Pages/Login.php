<?php

namespace App\Filament\Student\Pages;

use Filament\Auth\Pages\Login as BaseLogin;
use Filament\Actions\Action;
use Illuminate\Contracts\Support\Htmlable;
use Illuminate\Support\HtmlString;
use Filament\Auth\Http\Responses\Contracts\LoginResponse;
use Illuminate\Validation\ValidationException;

class Login extends BaseLogin
{

    public function authenticate(): ?LoginResponse
    {
        // Get credentials before authentication to check user
        $data = $this->form->getState();
        $credentials = $this->getCredentialsFromFormData($data);

        // Find user by email FIRST to check verification status before password validation
        if (isset($credentials['email'])) {
            $user = \App\Models\User::where('email', $credentials['email'])->first();

            // If user exists but email is not verified, show custom message
            if ($user && !$user->hasVerifiedEmail()) {
                // Verify credentials are correct before showing notification
                if (\Illuminate\Support\Facades\Hash::check($credentials['password'] ?? '', $user->password)) {
                    // Throw validation exception with custom message
                    throw ValidationException::withMessages([
                        'email' => ['You must verify your email address before logging in. Please check your inbox (including spam folder) for the verification email.'],
                    ]);
                } else {
                    // Password is wrong, but user exists and email is not verified
                    // Show custom message instead of generic "credentials do not match"
                    throw ValidationException::withMessages([
                        'email' => ['Please verify your email address before logging in. Check your inbox for the verification email.'],
                    ]);
                }
            }
        }

        // Call parent authenticate to proceed with normal login flow
        try {
            return parent::authenticate();
        } catch (ValidationException $e) {
            // Override the generic error message if user exists but email is not verified
            if (isset($credentials['email'])) {
                $user = \App\Models\User::where('email', $credentials['email'])->first();

                if ($user && !$user->hasVerifiedEmail()) {
                    // User exists but email is not verified - show custom message
                    throw ValidationException::withMessages([
                        'email' => ['Please verify your email address before logging in. Check your inbox for the verification email.'],
                    ]);
                }
            }

            // Re-throw original exception if it's not an unverified email issue
            throw $e;
        }
    }

    public function registerAction(): Action
    {
        return Action::make('register')
            ->link()
            ->label('Create an account')
            ->url(filament()->getRegistrationUrl());
    }

    public function getSubheading(): string | Htmlable | null
    {
        if (!filament()->hasRegistration()) {
            return null;
        }

        return new HtmlString(
            'Don\'t have an account? ' .
            '<a href="' . filament()->getRegistrationUrl() . '" class="text-primary-600 hover:text-primary-700 underline font-medium">Register here</a>'
        );
    }
}
