<?php

namespace App\Providers;

use App\Models\Election;
use App\Models\ElectionCandidate;
use App\Models\ElectionPosition;
use App\Models\User;
use App\Models\Vote;
use App\Models\Department;
use App\Models\Major;
use App\Models\Organization;
use App\Observers\AuditLogObserver;
use Illuminate\Auth\Events\Registered;
use Illuminate\Auth\Events\Login;
use Illuminate\Auth\Events\Logout;
use Illuminate\Auth\Events\Failed;
use Illuminate\Auth\Events\PasswordReset;
use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Event;

class EventServiceProvider extends ServiceProvider
{
    /**
     * The event to listener mappings for the application.
     *
     * @var array<class-string, array<int, class-string>>
     */
    protected $listen = [
        Registered::class => [
            \App\Listeners\LogUserRegistration::class,
        ],
        Login::class => [
            \App\Listeners\LogUserLogin::class,
        ],
        Logout::class => [
            \App\Listeners\LogUserLogout::class,
        ],
        Failed::class => [
            \App\Listeners\LogFailedLogin::class,
        ],
        PasswordReset::class => [
            \App\Listeners\LogPasswordReset::class,
        ],
    ];

    /**
     * Register any events for your application.
     */
    public function boot(): void
    {
        // Register model observers for automatic audit logging
        $auditLogObserver = new AuditLogObserver(app(\App\Services\AuditLogService::class));

        // Core models to track
        User::observe($auditLogObserver);
        Election::observe($auditLogObserver);
        ElectionCandidate::observe($auditLogObserver);
        ElectionPosition::observe($auditLogObserver);
        // Vote model is logged manually via logVoteSubmission() for privacy
        // Vote::observe($auditLogObserver);
        Department::observe($auditLogObserver);
        Major::observe($auditLogObserver);
        Organization::observe($auditLogObserver);
    }

    /**
     * Determine if events and listeners should be automatically discovered.
     */
    public function shouldDiscoverEvents(): bool
    {
        return false;
    }
}

