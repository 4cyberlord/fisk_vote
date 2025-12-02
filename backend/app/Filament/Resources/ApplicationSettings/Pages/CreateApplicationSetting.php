<?php

namespace App\Filament\Resources\ApplicationSettings\Pages;

use App\Filament\Resources\ApplicationSettings\ApplicationSettingResource;
use App\Models\ApplicationSetting;
use Filament\Resources\Pages\CreateRecord;

class CreateApplicationSetting extends CreateRecord
{
    protected static string $resource = ApplicationSettingResource::class;

    protected function handleRecordCreation(array $data): ApplicationSetting
    {
        // Use updateOrCreate to ensure only one settings record exists
        return ApplicationSetting::updateOrCreate(
            ['id' => 1],
            $data
        );
    }

    protected function afterCreate(): void
    {
        // Redirect to edit page after creation
        redirect(ApplicationSettingResource::getUrl('edit', ['record' => $this->record]));
    }
}
