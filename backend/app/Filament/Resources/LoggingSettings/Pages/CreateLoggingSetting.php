<?php

namespace App\Filament\Resources\LoggingSettings\Pages;

use App\Filament\Resources\LoggingSettings\LoggingSettingResource;
use App\Models\LoggingSetting;
use Filament\Resources\Pages\CreateRecord;

class CreateLoggingSetting extends CreateRecord
{
    protected static string $resource = LoggingSettingResource::class;

    protected function handleRecordCreation(array $data): LoggingSetting
    {
        return LoggingSetting::updateOrCreate(
            ['id' => 1],
            $data
        );
    }

    protected function afterCreate(): void
    {
        redirect(LoggingSettingResource::getUrl('edit', ['record' => $this->record]));
    }
}

