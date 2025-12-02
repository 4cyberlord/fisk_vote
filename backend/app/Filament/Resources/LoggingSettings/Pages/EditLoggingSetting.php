<?php

namespace App\Filament\Resources\LoggingSettings\Pages;

use App\Filament\Resources\LoggingSettings\LoggingSettingResource;
use App\Helpers\LoggingSettingsHelper;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditLoggingSetting extends EditRecord
{
    protected static string $resource = LoggingSettingResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
        ];
    }

    protected function mutateFormDataBeforeFill(array $data): array
    {
        // Ensure default retention value
        $data['retention_period'] ??= '3_months';

        return $data;
    }

    protected function afterSave(): void
    {
        LoggingSettingsHelper::clearCache();
    }
}

