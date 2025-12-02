<?php

namespace App\Listeners;

use App\Services\AuditLogService;
use Illuminate\Auth\Events\Logout;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;

class LogUserLogout implements ShouldQueue
{
    use InteractsWithQueue;

    protected AuditLogService $auditLogService;

    public function __construct(AuditLogService $auditLogService)
    {
        $this->auditLogService = $auditLogService;
    }

    public function handle(Logout $event): void
    {
        if ($event->user) {
            $this->auditLogService->logAuth(
                'logout',
                "User logged out: {$event->user->email}",
                $event->user,
                'success'
            );
        }
    }
}
