<?php

if (!function_exists('settings')) {
    /**
     * Get application settings helper
     *
     * @param string|null $key
     * @param mixed $default
     * @return \App\Models\ApplicationSetting|mixed
     */
    function settings(?string $key = null, $default = null)
    {
        if ($key === null) {
            return \App\Helpers\SettingsHelper::getSettings();
        }

        return \App\Helpers\SettingsHelper::get($key, $default);
    }
}

if (!function_exists('format_date')) {
    /**
     * Format date according to application settings
     *
     * @param mixed $date
     * @return string
     */
    function format_date($date): string
    {
        return \App\Helpers\SettingsHelper::formatDate($date);
    }
}

if (!function_exists('format_time')) {
    /**
     * Format time according to application settings
     *
     * @param mixed $time
     * @return string
     */
    function format_time($time): string
    {
        return \App\Helpers\SettingsHelper::formatTime($time);
    }
}

if (!function_exists('format_datetime')) {
    /**
     * Format date and time according to application settings
     *
     * @param mixed $datetime
     * @return string
     */
    function format_datetime($datetime): string
    {
        return \App\Helpers\SettingsHelper::formatDateTime($datetime);
    }
}

if (!function_exists('logging_settings')) {
    /**
     * Get logging settings helper
     *
     * @param string|null $key
     * @param mixed $default
     * @return \App\Models\LoggingSetting|mixed
     */
    function logging_settings(?string $key = null, $default = null)
    {
        if ($key === null) {
            return \App\Helpers\LoggingSettingsHelper::getSettings();
        }

        return \App\Helpers\LoggingSettingsHelper::get($key, $default);
    }
}

