<?php

namespace App\Filament\Resources\Votes\Pages;

use App\Filament\Resources\Votes\VoteResource;
use App\Models\Election;
use App\Models\ElectionPosition;
use App\Models\Vote;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Validation\ValidationException;

class EditVote extends EditRecord
{
    protected static string $resource = VoteResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }

    protected function mutateFormDataBeforeFill(array $data): array
    {
        // Populate form fields from existing vote_data JSON
        $voteData = $this->record->vote_data ?? [];
        
        if (is_array($voteData)) {
            // Handle abstention
            if (!empty($voteData['abstain']) && $voteData['abstain']) {
                $data['abstain_single'] = true;
                $data['abstain_multiple'] = true;
                $data['abstain_ranked'] = true;
                $data['abstain_referendum'] = true;
            }
            
            // Handle single choice
            if (!empty($voteData['candidate_id'])) {
                $data['candidate_id'] = $voteData['candidate_id'];
            }
            
            // Handle multiple choice
            if (!empty($voteData['candidate_ids']) && is_array($voteData['candidate_ids'])) {
                $data['candidate_ids'] = $voteData['candidate_ids'];
            }
            
            // Handle ranked choice
            if (!empty($voteData['rankings']) && is_array($voteData['rankings'])) {
                foreach ($voteData['rankings'] as $rank => $candidateId) {
                    $data["ranking_{$rank}"] = $candidateId;
                }
            }
            
            // Handle referendum
            if (!empty($voteData['vote'])) {
                $data['referendum_vote'] = $voteData['vote'];
            }
        }

        return $data;
    }

    protected function mutateFormDataBeforeSave(array $data): array
    {
        // Prevent token modification - token is immutable once created
        unset($data['token']);

        // Check if voter has already voted in this election (excluding current vote)
        $electionId = $data['election_id'] ?? $this->record->election_id;
        $voterId = $data['voter_id'] ?? $this->record->voter_id;

        if ($electionId && $voterId) {
            $existingVote = Vote::where('election_id', $electionId)
                ->where('voter_id', $voterId)
                ->where('id', '!=', $this->record->id)
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
        $electionId = $data['election_id'] ?? $this->record->election_id;
        $positionId = $data['position_id'] ?? $this->record->position_id;

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
