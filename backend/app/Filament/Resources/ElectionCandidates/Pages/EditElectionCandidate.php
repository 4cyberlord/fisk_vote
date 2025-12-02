<?php

namespace App\Filament\Resources\ElectionCandidates\Pages;

use App\Filament\Resources\ElectionCandidates\ElectionCandidateResource;
use App\Models\ElectionCandidate;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Validation\ValidationException;

class EditElectionCandidate extends EditRecord
{
    protected static string $resource = ElectionCandidateResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }

    protected function mutateFormDataBeforeSave(array $data): array
    {
        // Check for duplicate candidate (excluding current record)
        $exists = ElectionCandidate::where('election_id', $data['election_id'])
            ->where('position_id', $data['position_id'])
            ->where('user_id', $data['user_id'])
            ->where('id', '!=', $this->record->id)
            ->exists();

        if ($exists) {
            // Get candidate and election info for better error message
            $candidate = \App\Models\User::find($data['user_id']);
            $election = \App\Models\Election::find($data['election_id']);
            $position = \App\Models\ElectionPosition::find($data['position_id']);

            $candidateName = $candidate ? $candidate->name : 'This candidate';
            $electionTitle = $election ? $election->title : 'this election';
            $positionName = $position ? $position->name : 'this position';

            // Show notification
            Notification::make()
                ->title('Duplicate Candidate Detected')
                ->body("{$candidateName} is already registered for {$positionName} in {$electionTitle}. Each candidate can only run once per position per election.")
                ->danger()
                ->persistent()
                ->send();

            throw ValidationException::withMessages([
                'user_id' => 'This candidate is already registered for this position in this election. Each candidate can only run once per position per election.',
            ]);
        }

        // Spatie Media Library + Filament handle the actual file upload and replacement.
        // The `SpatieMediaLibraryFileUpload` form field syncs media on the model,
        // so we don't manually move or delete files here.

        return $data;
    }
}
