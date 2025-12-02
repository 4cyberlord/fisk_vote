<?php

namespace App\Filament\Resources\ElectionCandidates\Pages;

use App\Filament\Resources\ElectionCandidates\ElectionCandidateResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListElectionCandidates extends ListRecords
{
    protected static string $resource = ElectionCandidateResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
