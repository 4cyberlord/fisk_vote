<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ApplicationSetting extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'system_name',
        'system_short_name',
        'university_name',
        'system_description',
        'voting_platform_contact_email',
        'voting_support_email',
        'support_phone_number',
        'university_logo_url',
        'secondary_logo_url',
        'primary_color',
        'secondary_color',
        'dashboard_theme',
        'login_page_background_image_url',
        'default_timezone',
        'date_format',
        'time_format',
        'default_language',
        'additional_languages',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected function casts(): array
    {
        return [
            'additional_languages' => 'array',
        ];
    }

    /**
     * Get or create the singleton settings instance.
     */
    public static function getSettings(): self
    {
        return static::firstOrCreate(['id' => 1]);
    }

    /**
     * Boot the model.
     */
    protected static function boot(): void
    {
        parent::boot();

        // Clear cache when settings are saved
        static::saved(function () {
            \App\Helpers\SettingsHelper::clearCache();
        });

        static::deleted(function () {
            \App\Helpers\SettingsHelper::clearCache();
        });
    }
}
