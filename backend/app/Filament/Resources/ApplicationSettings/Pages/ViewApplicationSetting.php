<?php

namespace App\Filament\Resources\ApplicationSettings\Pages;

use App\Filament\Resources\ApplicationSettings\ApplicationSettingResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewApplicationSetting extends ViewRecord
{
    protected static string $resource = ApplicationSettingResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
