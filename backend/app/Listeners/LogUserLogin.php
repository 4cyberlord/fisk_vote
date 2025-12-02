<?php

namespace App\Listeners;

use App\Services\AuditLogService;
use Illuminate\Auth\Events\Login;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;

class LogUserLogin implements ShouldQueue
{
    use InteractsWithQueue;

    protected AuditLogService $auditLogService;

    public function __construct(AuditLogService $auditLogService)
    {
        $this->auditLogService = $auditLogService;
    }

    public function handle(Login $event): void
    {
        $this->auditLogService->logAuth(
            'login.success',
            "User logged in: {$event->user->email}",
            $event->user,
            'success'
        );
    }
}
