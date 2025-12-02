<?php

namespace App\Filament\Resources\ElectionPositions\Pages;

use App\Filament\Resources\ElectionPositions\ElectionPositionResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListElectionPositions extends ListRecords
{
    protected static string $resource = ElectionPositionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
