<?php

namespace App\Helpers;

use App\Models\LoggingSetting;
use Illuminate\Support\Facades\Cache;

class LoggingSettingsHelper
{
    /**
     * Cache key for logging settings.
     */
    private const CACHE_KEY = 'logging_settings';

    /**
     * Retrieve logging settings with caching.
     */
    public static function getSettings(): LoggingSetting
    {
        return Cache::remember(self::CACHE_KEY, 3600, function () {
            return LoggingSetting::getSettings();
        });
    }

    /**
     * Forget cached logging settings.
     */
    public static function clearCache(): void
    {
        Cache::forget(self::CACHE_KEY);
    }

    /**
     * Get a specific logging setting value.
     */
    public static function get(string $key, $default = null)
    {
        $settings = self::getSettings();

        return $settings->$key ?? $default;
    }

    /**
     * Convenience helper to determine if a feature is enabled.
     */
    public static function enabled(string $key, bool $default = true): bool
    {
        return (bool) self::get($key, $default);
    }
}

