<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Carbon\Carbon;

class UserJwtSession extends Model
{
    protected $fillable = [
        'user_id',
        'jti',
        'ip_address',
        'user_agent',
        'device_type',
        'browser',
        'location',
        'last_activity',
        'expires_at',
        'is_current',
    ];

    protected function casts(): array
    {
        return [
            'last_activity' => 'datetime',
            'expires_at' => 'datetime',
            'is_current' => 'boolean',
            'created_at' => 'datetime',
            'updated_at' => 'datetime',
        ];
    }

    /**
     * Get the user that owns this session.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Scope to get active sessions (not expired).
     */
    public function scopeActive($query)
    {
        return $query->where(function ($q) {
            $q->whereNull('expires_at')
              ->orWhere('expires_at', '>', now());
        });
    }

    /**
     * Scope to get current session.
     */
    public function scopeCurrent($query)
    {
        return $query->where('is_current', true);
    }

    /**
     * Check if session is expired.
     */
    public function isExpired(): bool
    {
        if (!$this->expires_at) {
            return false;
        }
        return $this->expires_at->isPast();
    }

    /**
     * Get device info as a string.
     */
    public function getDeviceInfoAttribute(): string
    {
        if ($this->browser && $this->device_type) {
            return "{$this->browser} on {$this->device_type}";
        }
        if ($this->browser) {
            return $this->browser;
        }
        if ($this->device_type) {
            return $this->device_type;
        }
        return 'Unknown';
    }
}
