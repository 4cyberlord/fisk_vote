<?php

namespace App\Listeners;

use App\Services\AuditLogService;
use Illuminate\Auth\Events\PasswordReset;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;

class LogPasswordReset implements ShouldQueue
{
    use InteractsWithQueue;

    protected AuditLogService $auditLogService;

    public function __construct(AuditLogService $auditLogService)
    {
        $this->auditLogService = $auditLogService;
    }

    public function handle(PasswordReset $event): void
    {
        $this->auditLogService->logAuth(
            'password.reset',
            "Password reset for: {$event->user->email}",
            $event->user,
            'success'
        );
    }
}
