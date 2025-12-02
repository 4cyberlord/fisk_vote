<?php

namespace App\Helpers;

use App\Models\ApplicationSetting;
use Illuminate\Support\Facades\Cache;

class SettingsHelper
{
    /**
     * Get application settings with caching
     */
    public static function getSettings(): ApplicationSetting
    {
        return Cache::remember('application_settings', 3600, function () {
            return ApplicationSetting::getSettings();
        });
    }

    /**
     * Clear settings cache
     */
    public static function clearCache(): void
    {
        Cache::forget('application_settings');
    }

    /**
     * Get a specific setting value
     */
    public static function get(string $key, $default = null)
    {
        $settings = static::getSettings();
        return $settings->$key ?? $default;
    }

    /**
     * Get system name
     */
    public static function systemName(): string
    {
        return static::get('system_name', 'Fisk Voting System');
    }

    /**
     * Get system short name
     */
    public static function systemShortName(): string
    {
        return static::get('system_short_name', 'FVS');
    }

    /**
     * Get university name
     */
    public static function universityName(): string
    {
        return static::get('university_name', 'Fisk University');
    }

    /**
     * Get primary color
     */
    public static function primaryColor(): string
    {
        return static::get('primary_color', '#3B82F6');
    }

    /**
     * Get secondary color
     */
    public static function secondaryColor(): string
    {
        return static::get('secondary_color', '#8B5CF6');
    }

    /**
     * Get dashboard theme
     */
    public static function dashboardTheme(): string
    {
        return static::get('dashboard_theme', 'auto');
    }

    /**
     * Get university logo URL
     */
    public static function universityLogoUrl(): ?string
    {
        $url = static::get('university_logo_url');
        return $url ? asset('storage/' . $url) : null;
    }

    /**
     * Get secondary logo URL
     */
    public static function secondaryLogoUrl(): ?string
    {
        $url = static::get('secondary_logo_url');
        return $url ? asset('storage/' . $url) : null;
    }

    /**
     * Get login background image URL
     */
    public static function loginBackgroundUrl(): ?string
    {
        $url = static::get('login_page_background_image_url');
        return $url ? asset('storage/' . $url) : null;
    }

    /**
     * Get default timezone
     */
    public static function timezone(): string
    {
        return static::get('default_timezone', 'America/Chicago');
    }

    /**
     * Get date format
     */
    public static function dateFormat(): string
    {
        return static::get('date_format', 'MM/DD/YYYY');
    }

    /**
     * Get time format
     */
    public static function timeFormat(): string
    {
        return static::get('time_format', '12-hour');
    }

    /**
     * Get default language
     */
    public static function defaultLanguage(): string
    {
        return static::get('default_language', 'en');
    }

    /**
     * Get additional languages
     */
    public static function additionalLanguages(): array
    {
        return static::get('additional_languages', []) ?? [];
    }

    /**
     * Format date according to settings
     */
    public static function formatDate($date): string
    {
        if (!$date) {
            return '';
        }

        $date = $date instanceof \DateTime ? $date : new \DateTime($date);
        $format = static::dateFormat();

        $formatMap = [
            'MM/DD/YYYY' => 'm/d/Y',
            'DD/MM/YYYY' => 'd/m/Y',
            'YYYY-MM-DD' => 'Y-m-d',
        ];

        return $date->format($formatMap[$format] ?? 'm/d/Y');
    }

    /**
     * Format time according to settings
     */
    public static function formatTime($time): string
    {
        if (!$time) {
            return '';
        }

        $time = $time instanceof \DateTime ? $time : new \DateTime($time);
        $format = static::timeFormat();

        return $format === '24-hour' 
            ? $time->format('H:i')
            : $time->format('g:i A');
    }

    /**
     * Format date and time according to settings
     */
    public static function formatDateTime($datetime): string
    {
        if (!$datetime) {
            return '';
        }

        $datetime = $datetime instanceof \DateTime ? $datetime : new \DateTime($datetime);
        $dateFormat = static::dateFormat();
        $timeFormat = static::timeFormat();

        $dateFormatMap = [
            'MM/DD/YYYY' => 'm/d/Y',
            'DD/MM/YYYY' => 'd/m/Y',
            'YYYY-MM-DD' => 'Y-m-d',
        ];

        $datePart = $datetime->format($dateFormatMap[$dateFormat] ?? 'm/d/Y');
        $timePart = $timeFormat === '24-hour' 
            ? $datetime->format('H:i')
            : $datetime->format('g:i A');

        return "{$datePart} {$timePart}";
    }

    /**
     * Get contact email
     */
    public static function contactEmail(): ?string
    {
        return static::get('voting_platform_contact_email');
    }

    /**
     * Get support email
     */
    public static function supportEmail(): ?string
    {
        return static::get('voting_support_email');
    }

    /**
     * Get support phone
     */
    public static function supportPhone(): ?string
    {
        return static::get('support_phone_number');
    }
}

