<?php

namespace App\Filament\Resources\ApplicationSettings\Pages;

use App\Filament\Resources\ApplicationSettings\ApplicationSettingResource;
use App\Models\ApplicationSetting;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ListRecords;

class ListApplicationSettings extends ListRecords
{
    protected static string $resource = ApplicationSettingResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make()
                ->url(fn () => ApplicationSettingResource::getUrl('edit', ['record' => ApplicationSetting::getSettings()])),
        ];
    }

    public function mount(): void
    {
        // Redirect to edit page if settings exist, otherwise redirect to create
        $settings = ApplicationSetting::getSettings();
        if ($settings->exists) {
            redirect(ApplicationSettingResource::getUrl('edit', ['record' => $settings]));
        } else {
            redirect(ApplicationSettingResource::getUrl('create'));
        }
    }
}
