<?php

namespace App\Filament\Resources\EmailSettings\Pages;

use App\Filament\Resources\EmailSettings\EmailSettingResource;
use App\Models\EmailSetting;
use Filament\Resources\Pages\CreateRecord;

class CreateEmailSetting extends CreateRecord
{
    protected static string $resource = EmailSettingResource::class;

    protected function handleRecordCreation(array $data): EmailSetting
    {
        // Use updateOrCreate to ensure only one settings record exists
        return EmailSetting::updateOrCreate(
            ['id' => 1],
            $data
        );
    }

    protected function afterCreate(): void
    {
        // Redirect to edit page after creation
        redirect(EmailSettingResource::getUrl('edit', ['record' => $this->record]));
    }
}
