<?php

namespace App\Filament\Resources\EmailSettings\Pages;

use App\Filament\Resources\EmailSettings\EmailSettingResource;
use App\Models\EmailSetting;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ListRecords;

class ListEmailSettings extends ListRecords
{
    protected static string $resource = EmailSettingResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make()
                ->url(fn () => EmailSettingResource::getUrl('edit', ['record' => EmailSetting::getSettings()])),
        ];
    }

    public function mount(): void
    {
        // Redirect to edit page if settings exist, otherwise redirect to create
        $settings = EmailSetting::getSettings();
        if ($settings->exists) {
            redirect(EmailSettingResource::getUrl('edit', ['record' => $settings]));
        } else {
            redirect(EmailSettingResource::getUrl('create'));
        }
    }
}
