<?php

namespace App\Listeners;

use App\Services\AuditLogService;
use Illuminate\Auth\Events\Failed;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;

class LogFailedLogin implements ShouldQueue
{
    use InteractsWithQueue;

    protected AuditLogService $auditLogService;

    public function __construct(AuditLogService $auditLogService)
    {
        $this->auditLogService = $auditLogService;
    }

    public function handle(Failed $event): void
    {
        $email = $event->credentials['email'] ?? 'unknown';
        
        $this->auditLogService->logAuth(
            'login.failed',
            "Failed login attempt for: {$email}",
            $event->user, // May be null if user doesn't exist
            'failed',
            "Invalid credentials provided"
        );
    }
}
