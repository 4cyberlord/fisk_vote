<?php

namespace App\Providers;

use App\Helpers\LoggingSettingsHelper;
use App\Helpers\SettingsHelper;
use Illuminate\Support\ServiceProvider;

class SettingsServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        // Set application timezone from settings
        try {
            $timezone = SettingsHelper::timezone();
            if ($timezone) {
                config(['app.timezone' => $timezone]);
                date_default_timezone_set($timezone);
            }
        } catch (\Exception $e) {
            // If settings table doesn't exist yet, use default
            // This prevents errors during initial migration
        }

        // Set application locale from settings
        try {
            $locale = SettingsHelper::defaultLanguage();
            if ($locale) {
                app()->setLocale($locale);
            }
        } catch (\Exception $e) {
            // If settings table doesn't exist yet, use default
        }

        // Expose logging settings globally so other services can honour toggles
        try {
            config(['logging.settings' => LoggingSettingsHelper::getSettings()->toArray()]);
        } catch (\Exception $e) {
            // Logging settings table might not exist yet during first migration
        }
    }
}
