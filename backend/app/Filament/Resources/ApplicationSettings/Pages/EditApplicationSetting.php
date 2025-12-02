<?php

namespace App\Filament\Resources\ApplicationSettings\Pages;

use App\Filament\Resources\ApplicationSettings\ApplicationSettingResource;
use App\Helpers\SettingsHelper;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditApplicationSetting extends EditRecord
{
    protected static string $resource = ApplicationSettingResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            // Remove delete action for singleton settings - settings should not be deleted
        ];
    }

    protected function afterSave(): void
    {
        // Clear settings cache and reapply settings
        SettingsHelper::clearCache();
        
        // Reapply timezone
        try {
            $timezone = SettingsHelper::timezone();
            if ($timezone) {
                config(['app.timezone' => $timezone]);
                date_default_timezone_set($timezone);
            }
        } catch (\Exception $e) {
            // Ignore errors
        }

        // Reapply locale
        try {
            $locale = SettingsHelper::defaultLanguage();
            if ($locale) {
                app()->setLocale($locale);
            }
        } catch (\Exception $e) {
            // Ignore errors
        }
        
        // Broadcast updated theme preference to the browser so it applies immediately.
        $this->dispatch('filament-theme-updated', theme: SettingsHelper::dashboardTheme());
    }
}
