<?php

namespace App\Filament\Resources\ElectionPositions\Pages;

use App\Filament\Resources\ElectionPositions\ElectionPositionResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewElectionPosition extends ViewRecord
{
    protected static string $resource = ElectionPositionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
