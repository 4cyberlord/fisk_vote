<?php

namespace App\Filament\Resources\LoggingSettings\Pages;

use App\Filament\Resources\LoggingSettings\LoggingSettingResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewLoggingSetting extends ViewRecord
{
    protected static string $resource = LoggingSettingResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}

