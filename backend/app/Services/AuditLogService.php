<?php

namespace App\Services;

use App\Models\AuditLog;
use App\Models\LoggingSetting;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Auth;

class AuditLogService
{
    /**
     * Log an action to the audit log.
     *
     * @param string $actionType
     * @param string $actionDescription
     * @param Model|null $auditable
     * @param array $oldValues
     * @param array $newValues
     * @param string $status
     * @param string|null $errorMessage
     * @param array $metadata
     * @param string|null $eventType
     * @return AuditLog|null
     */
    public function log(
        string $actionType,
        string $actionDescription,
        ?Model $auditable = null,
        array $oldValues = [],
        array $newValues = [],
        string $status = 'success',
        ?string $errorMessage = null,
        array $metadata = [],
        ?string $eventType = null
    ): ?AuditLog {
        // Check if activity logging is enabled
        $settings = LoggingSetting::getSettings();
        if (!$settings->enable_activity_logs) {
            return null;
        }

        // Get current user - check both web and api guards
        // API routes use 'api' guard (JWT), web routes use 'web' guard (session)
        $user = Auth::guard('api')->user() ?? Auth::guard('web')->user() ?? Auth::user();
        
        // Prepare user information
        $userData = [
            'user_id' => $user?->id,
            'user_name' => $user?->name ?? $user?->full_name ?? 'System',
            'user_email' => $user?->email ?? $user?->university_email ?? null,
            'user_role' => $user?->roles->first()?->name ?? null,
        ];

        // Prepare resource information
        $resourceData = [];
        if ($auditable) {
            $resourceData = [
                'auditable_type' => get_class($auditable),
                'auditable_id' => $auditable->id,
                'resource_name' => $this->getResourceName($auditable),
            ];
        }

        // Prepare request context
        $requestData = [];
        if ($settings->log_ip_addresses) {
            $request = request();
            if ($request) {
                $requestData = [
                    'ip_address' => $request->ip(),
                    'user_agent' => $request->userAgent(),
                    'request_url' => $request->fullUrl(),
                    'request_method' => $request->method(),
                    'session_id' => session()->getId(),
                ];
            }
        }

        // Generate changes summary
        $changesSummary = $this->generateChangesSummary($oldValues, $newValues, $actionType);

        // Create audit log entry
        try {
            $auditLog = AuditLog::create(array_merge(
                $userData,
                $resourceData,
                $requestData,
                [
                    'action_type' => $actionType,
                    'action_description' => $actionDescription,
                    'event_type' => $eventType ?? $this->generateEventType($actionType, $auditable),
                    'old_values' => !empty($oldValues) ? $oldValues : null,
                    'new_values' => !empty($newValues) ? $newValues : null,
                    'changes_summary' => $changesSummary,
                    'status' => $status,
                    'error_message' => $errorMessage,
                    'metadata' => !empty($metadata) ? $metadata : null,
                ]
            ));

            return $auditLog;
        } catch (\Exception $e) {
            // Log error but don't break the application
            \Log::error('Failed to create audit log: ' . $e->getMessage());
            return null;
        }
    }

    /**
     * Log a user action.
     */
    public function logUserAction(
        string $actionType,
        string $description,
        ?Model $user = null,
        array $oldValues = [],
        array $newValues = [],
        string $status = 'success',
        ?string $errorMessage = null
    ): ?AuditLog {
        return $this->log(
            $actionType,
            $description,
            $user,
            $oldValues,
            $newValues,
            $status,
            $errorMessage,
            [],
            'user.' . $actionType
        );
    }

    /**
     * Log an authentication event.
     */
    public function logAuth(
        string $actionType,
        string $description,
        ?Model $user = null,
        string $status = 'success',
        ?string $errorMessage = null
    ): ?AuditLog {
        $settings = LoggingSetting::getSettings();
        if (!$settings->log_voter_logins) {
            return null;
        }

        return $this->log(
            $actionType,
            $description,
            $user,
            [],
            [],
            $status,
            $errorMessage,
            [],
            'auth.' . $actionType
        );
    }

    /**
     * Log an admin action.
     */
    public function logAdminAction(
        string $actionType,
        string $description,
        ?Model $resource = null,
        array $oldValues = [],
        array $newValues = [],
        string $status = 'success',
        ?string $errorMessage = null
    ): ?AuditLog {
        $settings = LoggingSetting::getSettings();
        if (!$settings->log_admin_actions) {
            return null;
        }

        return $this->log(
            $actionType,
            $description,
            $resource,
            $oldValues,
            $newValues,
            $status,
            $errorMessage,
            [],
            'admin.' . $actionType
        );
    }

    /**
     * Log a vote submission (anonymized).
     */
    public function logVoteSubmission(
        int $electionId,
        int $userId,
        string $status = 'success',
        ?string $errorMessage = null
    ): ?AuditLog {
        $settings = LoggingSetting::getSettings();
        if (!$settings->log_vote_submission_events) {
            return null;
        }

        $user = \App\Models\User::find($userId);
        
        return $this->log(
            'vote.submitted',
            'Vote submitted for election',
            null,
            [],
            [],
            $status,
            $errorMessage,
            [
                'election_id' => $electionId,
                'voter_id' => $userId,
                // Note: Candidate selections are NOT logged for privacy
            ],
            'vote.submitted'
        );
    }

    /**
     * Generate a human-readable resource name.
     */
    protected function getResourceName(Model $model): string
    {
        // Try common name fields
        if (isset($model->name)) {
            return class_basename($model) . ': ' . $model->name;
        }
        if (isset($model->title)) {
            return class_basename($model) . ': ' . $model->title;
        }
        if (isset($model->email)) {
            return class_basename($model) . ': ' . $model->email;
        }
        if (method_exists($model, 'getFullNameAttribute')) {
            return class_basename($model) . ': ' . $model->full_name;
        }

        return class_basename($model) . ' #' . $model->id;
    }

    /**
     * Generate event type from action type and model.
     */
    protected function generateEventType(string $actionType, ?Model $auditable = null): string
    {
        if ($auditable) {
            $modelName = strtolower(class_basename($auditable));
            return $modelName . '.' . $actionType;
        }

        return $actionType;
    }

    /**
     * Generate a human-readable changes summary.
     */
    protected function generateChangesSummary(array $oldValues, array $newValues, string $actionType): ?string
    {
        if (empty($oldValues) && empty($newValues)) {
            return null;
        }

        if ($actionType === 'created' && !empty($newValues)) {
            $fields = array_keys($newValues);
            return 'Created with fields: ' . implode(', ', array_map(function ($field) {
                return ucfirst(str_replace('_', ' ', $field));
            }, $fields));
        }

        if ($actionType === 'deleted' && !empty($oldValues)) {
            return 'Deleted record';
        }

        if ($actionType === 'updated' && !empty($oldValues) && !empty($newValues)) {
            $changes = [];
            foreach ($newValues as $key => $newValue) {
                $oldValue = $oldValues[$key] ?? null;
                if ($oldValue !== $newValue) {
                    $fieldName = ucfirst(str_replace('_', ' ', $key));
                    $changes[] = "{$fieldName}: \"{$oldValue}\" → \"{$newValue}\"";
                }
            }
            return !empty($changes) ? implode(', ', $changes) : 'No changes detected';
        }

        return null;
    }
}

