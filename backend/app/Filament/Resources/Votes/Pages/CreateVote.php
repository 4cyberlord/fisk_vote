<?php

namespace App\Filament\Resources\Votes\Pages;

use App\Filament\Resources\Votes\VoteResource;
use App\Models\Election;
use App\Models\ElectionPosition;
use App\Models\Vote;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Validation\ValidationException;

class CreateVote extends CreateRecord
{
    protected static string $resource = VoteResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // Auto-set voter_id from authenticated user if not provided
        if (empty($data['voter_id']) && auth()->check()) {
            $data['voter_id'] = auth()->id();
        }

        // Check if voter has already voted in this election
        $electionId = $data['election_id'] ?? null;
        $voterId = $data['voter_id'] ?? null;

        if ($electionId && $voterId) {
            $existingVote = Vote::where('election_id', $electionId)
                ->where('voter_id', $voterId)
                ->first();

            if ($existingVote) {
                $voter = \App\Models\User::find($voterId);
                $election = Election::find($electionId);
                
                $voterName = $voter ? $voter->name : 'This voter';
                $electionTitle = $election ? $election->title : 'this election';

                // Show notification
                Notification::make()
                    ->title('Duplicate Vote Detected')
                    ->body("{$voterName} has already cast a vote in {$electionTitle}. Each voter can only vote once per election.")
                    ->danger()
                    ->persistent()
                    ->send();

                throw ValidationException::withMessages([
                    'election_id' => 'This voter has already cast a vote in this election. Each voter can only vote once per election.',
                ]);
            }
        }

        // Convert form inputs to JSON vote_data format
        $data['vote_data'] = $this->convertVoteDataToJson($data);

        // Clean up temporary form fields
        unset($data['candidate_id']);
        unset($data['candidate_ids']);
        unset($data['abstain_single']);
        unset($data['abstain_multiple']);
        unset($data['abstain_ranked']);
        unset($data['abstain_referendum']);
        unset($data['referendum_vote']);
        
        // Remove ranking fields
        foreach ($data as $key => $value) {
            if (str_starts_with($key, 'ranking_')) {
                unset($data[$key]);
            }
        }

        return $data;
    }

    /**
     * Convert form inputs to JSON vote_data format based on election/position type
     */
    protected function convertVoteDataToJson(array $data): array
    {
        $electionId = $data['election_id'] ?? null;
        $positionId = $data['position_id'] ?? null;

        if (!$electionId) {
            return [];
        }

        $election = Election::find($electionId);
        $position = $positionId ? ElectionPosition::find($positionId) : null;

        // Handle Referendum Election
        if ($election && $election->type === 'referendum') {
            if (!empty($data['abstain_referendum']) && $data['abstain_referendum']) {
                return ['abstain' => true];
            }
            
            if (!empty($data['referendum_vote'])) {
                return ['vote' => $data['referendum_vote']];
            }
            
            return [];
        }

        // Handle Position-based votes
        if (!$position) {
            return [];
        }

        // Handle Abstention
        $abstainFields = ['abstain_single', 'abstain_multiple', 'abstain_ranked'];
        foreach ($abstainFields as $field) {
            if (!empty($data[$field]) && $data[$field]) {
                return ['abstain' => true];
            }
        }

        // Single Choice Position
        if ($position->type === 'single') {
            if (!empty($data['candidate_id'])) {
                return ['candidate_id' => (int) $data['candidate_id']];
            }
            return [];
        }

        // Multiple Choice Position
        if ($position->type === 'multiple') {
            if (!empty($data['candidate_ids']) && is_array($data['candidate_ids'])) {
                return ['candidate_ids' => array_map('intval', $data['candidate_ids'])];
            }
            return [];
        }

        // Ranked Choice Position
        if ($position->type === 'ranked') {
            $rankings = [];
            $rankingLevels = $position->ranking_levels ?? 3;
            
            for ($i = 1; $i <= $rankingLevels; $i++) {
                $fieldName = "ranking_{$i}";
                if (!empty($data[$fieldName])) {
                    $rankings[(string) $i] = (int) $data[$fieldName];
                }
            }
            
            if (!empty($rankings)) {
                return ['rankings' => $rankings];
            }
            return [];
        }

        return [];
    }
}
