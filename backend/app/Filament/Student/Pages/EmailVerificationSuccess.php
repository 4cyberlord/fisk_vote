<?php

namespace App\Filament\Student\Pages;

use Filament\Pages\Page;
use Illuminate\Contracts\Support\Htmlable;

class EmailVerificationSuccess extends Page
{
    protected static ?string $slug = 'email-verified';

    protected string $view = 'filament.student.pages.email-verification-success';

    protected static bool $shouldRegisterNavigation = false;

    public ?string $userEmail = null;
    public ?string $userName = null;

    public function mount(): void
    {
        // Get user info from session if available
        if (session()->has('verified_user_id')) {
            $userId = session()->get('verified_user_id');
            $user = \App\Models\User::find($userId);
            
            if ($user) {
                $this->userEmail = $user->email;
                $this->userName = $user->first_name ?? $user->name ?? 'Student';
            }
        }
    }

    public function getTitle(): string | Htmlable
    {
        return 'Email Verified Successfully';
    }

    public function getHeading(): string | Htmlable | null
    {
        return 'Email Verified Successfully';
    }

    public function getSubheading(): string | Htmlable | null
    {
        return 'Your email address has been verified. You can now log in to your account.';
    }
}

