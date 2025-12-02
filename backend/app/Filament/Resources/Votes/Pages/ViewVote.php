<?php

namespace App\Filament\Resources\Votes\Pages;

use App\Filament\Resources\Votes\VoteResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewVote extends ViewRecord
{
    protected static string $resource = VoteResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
