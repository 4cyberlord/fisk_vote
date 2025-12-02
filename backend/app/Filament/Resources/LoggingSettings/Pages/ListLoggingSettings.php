<?php

namespace App\Filament\Resources\LoggingSettings\Pages;

use App\Filament\Resources\LoggingSettings\LoggingSettingResource;
use App\Models\LoggingSetting;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ListRecords;

class ListLoggingSettings extends ListRecords
{
    protected static string $resource = LoggingSettingResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make()
                ->label('Edit Settings')
                ->url(fn () => LoggingSettingResource::getUrl('edit', ['record' => LoggingSetting::getSettings()])),
        ];
    }

    public function mount(): void
    {
        $settings = LoggingSetting::getSettings();
        if ($settings->exists) {
            redirect(LoggingSettingResource::getUrl('edit', ['record' => $settings]));
        } else {
            redirect(LoggingSettingResource::getUrl('create'));
        }
    }
}

