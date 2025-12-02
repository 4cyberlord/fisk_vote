<?php

namespace App\Filament\Resources\EmailSettings\Pages;

use App\Filament\Resources\EmailSettings\EmailSettingResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewEmailSetting extends ViewRecord
{
    protected static string $resource = EmailSettingResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
