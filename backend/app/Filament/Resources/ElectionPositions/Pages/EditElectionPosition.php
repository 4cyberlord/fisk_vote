<?php

namespace App\Filament\Resources\ElectionPositions\Pages;

use App\Filament\Resources\ElectionPositions\ElectionPositionResource;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditElectionPosition extends EditRecord
{
    protected static string $resource = ElectionPositionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }
}
