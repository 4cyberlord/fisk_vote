<?php

namespace App\Listeners;

use App\Services\AuditLogService;
use Illuminate\Auth\Events\Registered;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;

class LogUserRegistration implements ShouldQueue
{
    use InteractsWithQueue;

    protected AuditLogService $auditLogService;

    public function __construct(AuditLogService $auditLogService)
    {
        $this->auditLogService = $auditLogService;
    }

    public function handle(Registered $event): void
    {
        $this->auditLogService->logAuth(
            'user.created',
            "User registered: {$event->user->email}",
            $event->user,
            'success'
        );
    }
}
