<?php

namespace App\Observers;

use App\Models\AuditLog;
use App\Services\AuditLogService;
use Illuminate\Database\Eloquent\Model;

class AuditLogObserver
{
    protected AuditLogService $auditLogService;

    public function __construct(AuditLogService $auditLogService)
    {
        $this->auditLogService = $auditLogService;
    }

    /**
     * Handle the model "created" event.
     */
    public function created(Model $model): void
    {
        // Skip if this is an AuditLog itself to avoid recursion
        if ($model instanceof AuditLog) {
            return;
        }

        $this->auditLogService->log(
            'created',
            $this->getActionDescription($model, 'created'),
            $model,
            [],
            $this->getModelAttributes($model),
            'success',
            null,
            [],
            $this->getEventType($model, 'created')
        );
    }

    /**
     * Handle the model "updated" event.
     */
    public function updated(Model $model): void
    {
        // Skip if this is an AuditLog itself to avoid recursion
        if ($model instanceof AuditLog) {
            return;
        }

        $oldValues = $model->getOriginal();
        $newValues = $model->getChanges();

        // Remove timestamps from changes
        unset($newValues['updated_at'], $oldValues['updated_at']);

        if (empty($newValues)) {
            return; // No actual changes
        }

        // Get old values for changed fields only
        $oldValuesForChanges = [];
        foreach ($newValues as $key => $value) {
            $oldValuesForChanges[$key] = $oldValues[$key] ?? null;
        }

        $this->auditLogService->log(
            'updated',
            $this->getActionDescription($model, 'updated'),
            $model,
            $oldValuesForChanges,
            $newValues,
            'success',
            null,
            [],
            $this->getEventType($model, 'updated')
        );
    }

    /**
     * Handle the model "deleted" event.
     */
    public function deleted(Model $model): void
    {
        // Skip if this is an AuditLog itself to avoid recursion
        if ($model instanceof AuditLog) {
            return;
        }

        $this->auditLogService->log(
            'deleted',
            $this->getActionDescription($model, 'deleted'),
            $model,
            $this->getModelAttributes($model),
            [],
            'success',
            null,
            [],
            $this->getEventType($model, 'deleted')
        );
    }

    /**
     * Get action description for the model.
     */
    protected function getActionDescription(Model $model, string $action): string
    {
        $modelName = class_basename($model);
        
        $name = $this->getModelName($model);

        return ucfirst($action) . " {$modelName}" . ($name ? ": {$name}" : '');
    }

    /**
     * Get a human-readable name for the model.
     */
    protected function getModelName(Model $model): ?string
    {
        if (isset($model->name)) {
            return $model->name;
        }
        if (isset($model->title)) {
            return $model->title;
        }
        if (isset($model->email)) {
            return $model->email;
        }
        if (method_exists($model, 'getFullNameAttribute')) {
            return $model->full_name;
        }

        return null;
    }

    /**
     * Get model attributes for logging.
     */
    protected function getModelAttributes(Model $model): array
    {
        $attributes = $model->getAttributes();
        
        // Remove sensitive fields
        unset(
            $attributes['password'],
            $attributes['remember_token'],
            $attributes['temporary_password'],
            $attributes['email_verified_at'], // Don't log verification status changes
        );

        return $attributes;
    }

    /**
     * Get event type for the model.
     */
    protected function getEventType(Model $model, string $action): string
    {
        $modelName = strtolower(class_basename($model));
        return "{$modelName}.{$action}";
    }
}

