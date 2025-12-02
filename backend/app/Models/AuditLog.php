<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphTo;

class AuditLog extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'user_name',
        'user_email',
        'user_role',
        'action_type',
        'action_description',
        'event_type',
        'auditable_type',
        'auditable_id',
        'resource_name',
        'old_values',
        'new_values',
        'changes_summary',
        'ip_address',
        'user_agent',
        'request_url',
        'request_method',
        'status',
        'error_message',
        'metadata',
        'session_id',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected function casts(): array
    {
        return [
            'old_values' => 'array',
            'new_values' => 'array',
            'metadata' => 'array',
            'created_at' => 'datetime',
            'updated_at' => 'datetime',
        ];
    }

    /**
     * Get the user who performed the action.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the auditable model (polymorphic relationship).
     */
    public function auditable(): MorphTo
    {
        return $this->morphTo();
    }

    /**
     * Scope a query to filter by user.
     */
    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    /**
     * Scope a query to filter by action type.
     */
    public function scopeActionType($query, $actionType)
    {
        return $query->where('action_type', $actionType);
    }

    /**
     * Scope a query to filter by status.
     */
    public function scopeStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    /**
     * Scope a query to filter by date range.
     */
    public function scopeDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('created_at', [$startDate, $endDate]);
    }

    /**
     * Scope a query to filter by resource type.
     */
    public function scopeResourceType($query, $resourceType)
    {
        return $query->where('auditable_type', $resourceType);
    }

    /**
     * Scope a query to get recent logs.
     */
    public function scopeRecent($query, $days = 7)
    {
        return $query->where('created_at', '>=', now()->subDays($days));
    }

    /**
     * Get formatted changes for display.
     */
    public function getFormattedChangesAttribute(): string
    {
        if ($this->changes_summary) {
            return $this->changes_summary;
        }

        if ($this->old_values && $this->new_values) {
            $changes = [];
            foreach ($this->new_values as $key => $newValue) {
                $oldValue = $this->old_values[$key] ?? null;
                if ($oldValue !== $newValue) {
                    $changes[] = ucfirst(str_replace('_', ' ', $key)) . ': "' . $oldValue . '" → "' . $newValue . '"';
                }
            }
            return implode(', ', $changes);
        }

        return 'No changes recorded';
    }

    /**
     * Check if this is a failed action.
     */
    public function isFailed(): bool
    {
        return $this->status === 'failed';
    }

    /**
     * Check if this is a successful action.
     */
    public function isSuccessful(): bool
    {
        return $this->status === 'success';
    }
}
