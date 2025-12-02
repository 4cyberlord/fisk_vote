<?php

namespace App\Filament\Resources\ElectionCandidates\Pages;

use App\Filament\Resources\ElectionCandidates\ElectionCandidateResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewElectionCandidate extends ViewRecord
{
    protected static string $resource = ElectionCandidateResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
