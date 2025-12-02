<?php

namespace App\Filament\Resources\ElectionCandidates\Pages;

use App\Filament\Resources\ElectionCandidates\ElectionCandidateResource;
use App\Models\ElectionCandidate;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Validation\ValidationException;

class CreateElectionCandidate extends CreateRecord
{
    protected static string $resource = ElectionCandidateResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // Check for duplicate candidate
        $exists = ElectionCandidate::where('election_id', $data['election_id'])
            ->where('position_id', $data['position_id'])
            ->where('user_id', $data['user_id'])
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

        // Spatie Media Library + Filament handle the actual file upload.
        // The `SpatieMediaLibraryFileUpload` form field stores media on the model
        // after it is created, so we don't need to manually move or validate files here.

        return $data;
    }
}
