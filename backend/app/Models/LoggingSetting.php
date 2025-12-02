<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class LoggingSetting extends Model
{
    use HasFactory;

    /**
     * Supported retention period options.
     */
    public const RETENTION_OPTIONS = [
        '30_days',
        '3_months',
        '1_year',
        'forever',
    ];

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'enable_activity_logs',
        'log_admin_actions',
        'log_voter_logins',
        'log_vote_submission_events',
        'log_ip_addresses',
        'retention_period',
        'enable_system_health_dashboard',
        'track_cpu_load',
        'track_database_queries',
        'track_active_users',
        'track_vote_submission_rate',
        'auto_email_admin_on_failure',
        'store_crash_reports',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected function casts(): array
    {
        return [
            'enable_activity_logs' => 'boolean',
            'log_admin_actions' => 'boolean',
            'log_voter_logins' => 'boolean',
            'log_vote_submission_events' => 'boolean',
            'log_ip_addresses' => 'boolean',
            'enable_system_health_dashboard' => 'boolean',
            'track_cpu_load' => 'boolean',
            'track_database_queries' => 'boolean',
            'track_active_users' => 'boolean',
            'track_vote_submission_rate' => 'boolean',
            'auto_email_admin_on_failure' => 'boolean',
            'store_crash_reports' => 'boolean',
        ];
    }

    /**
     * Retrieve the singleton settings record.
     */
    public static function getSettings(): self
    {
        return static::firstOrCreate(['id' => 1]);
    }

    /**
     * Boot the model and clear cache whenever settings change.
     */
    protected static function boot(): void
    {
        parent::boot();

        static::saved(function () {
            \App\Helpers\LoggingSettingsHelper::clearCache();
        });

        static::deleted(function () {
            \App\Helpers\LoggingSettingsHelper::clearCache();
        });
    }
}
