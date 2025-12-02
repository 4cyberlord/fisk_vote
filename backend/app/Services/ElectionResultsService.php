<?php

namespace App\Services;

use App\Models\Election;
use App\Models\ElectionPosition;
use App\Models\Vote;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class ElectionResultsService
{
    /**
     * Calculate results for a specific election.
     *
     * @param Election $election
     * @return array
     */
    public function calculateElectionResults(Election $election): array
    {
        $positions = $election->positions()->with('candidates.user')->get();
        $results = [];

        foreach ($positions as $position) {
            $results[] = $this->calculatePositionResults($position);
        }

        return [
            'election' => [
                'id' => $election->id,
                'title' => $election->title,
                'description' => $election->description,
                'type' => $election->type,
                'status' => $election->current_status,
                'start_time' => $election->start_time,
                'end_time' => $election->end_time,
            ],
            'total_votes' => Vote::where('election_id', $election->id)->count(),
            'unique_voters' => Vote::where('election_id', $election->id)->distinct('voter_id')->count('voter_id'),
            'positions' => $results,
        ];
    }

    /**
     * Calculate results for a specific position.
     *
     * @param ElectionPosition $position
     * @return array
     */
    public function calculatePositionResults(ElectionPosition $position): array
    {
        // Get all votes for this election (votes contain all positions in vote_data)
        $allVotes = Vote::where('election_id', $position->election_id)->get();
        
        $fieldKey = "position_{$position->id}";
        $abstainKey = "{$fieldKey}_abstain";
        
        // Filter votes that have data for this position
        $votes = $allVotes->filter(function ($vote) use ($fieldKey, $abstainKey) {
            return isset($vote->vote_data[$fieldKey]) || isset($vote->vote_data[$abstainKey]);
        });

        $totalVotes = $votes->count();
        $abstentions = $votes->filter(function ($vote) use ($abstainKey) {
            return isset($vote->vote_data[$abstainKey]) && $vote->vote_data[$abstainKey] === true;
        })->count();

        $candidateResults = [];

        foreach ($position->candidates as $candidate) {
            $candidateResults[$candidate->id] = [
                'candidate_id' => $candidate->id,
                'candidate_name' => $candidate->user 
                    ? ($candidate->user->first_name && $candidate->user->last_name
                        ? "{$candidate->user->first_name} {$candidate->user->last_name}"
                        : $candidate->user->name)
                    : 'Unknown',
                'candidate_tagline' => $candidate->tagline,
                'candidate_photo' => $candidate->photo_url ?? $candidate->user->profile_photo ?? null,
                'votes' => 0,
                'percentage' => 0,
                'rank' => null,
            ];
        }

        // Count votes based on position type
        foreach ($votes as $vote) {
            $abstainKey = "position_{$position->id}_abstain";
            // Skip abstentions
            if (isset($vote->vote_data[$abstainKey]) && $vote->vote_data[$abstainKey] === true) {
                continue;
            }

            $voteData = $vote->vote_data[$fieldKey] ?? null;
            
            if ($position->type === 'single') {
                // Handle both formats: direct candidate_id or nested in object
                $candidateId = null;
                if (is_numeric($voteData)) {
                    $candidateId = $voteData;
                } elseif (is_array($voteData) && isset($voteData['candidate_id'])) {
                    $candidateId = $voteData['candidate_id'];
                } elseif (is_array($voteData) && count($voteData) > 0 && is_numeric($voteData[0])) {
                    $candidateId = $voteData[0];
                }
                
                if ($candidateId && isset($candidateResults[$candidateId])) {
                    $candidateResults[$candidateId]['votes']++;
                }
            } elseif ($position->type === 'multiple') {
                // Handle both formats: array of candidate_ids or nested structure
                $candidateIds = [];
                if (is_array($voteData)) {
                    if (isset($voteData['candidate_ids'])) {
                        $candidateIds = $voteData['candidate_ids'];
                    } elseif (isset($voteData[0]) && is_array($voteData[0]) && isset($voteData[0]['candidate_id'])) {
                        // Format: [{"candidate_id": 1}, {"candidate_id": 2}]
                        $candidateIds = array_column($voteData, 'candidate_id');
                    } else {
                        // Format: [1, 2, 3]
                        $candidateIds = array_filter($voteData, 'is_numeric');
                    }
                }
                
                foreach ($candidateIds as $candidateId) {
                    if (isset($candidateResults[$candidateId])) {
                        $candidateResults[$candidateId]['votes']++;
                    }
                }
            } elseif ($position->type === 'ranked') {
                // For ranked choice, count first-choice votes (rank 1)
                if ($voteData && isset($voteData['rankings']) && is_array($voteData['rankings'])) {
                    // Rankings are stored as array of objects: [{"candidate_id": X, "rank": Y}, ...]
                    $rank1CandidateId = null;
                    $lowestRank = PHP_INT_MAX;
                    
                    foreach ($voteData['rankings'] as $ranking) {
                        // Rankings are stored as array of objects: [{"candidate_id": X, "rank": Y}, ...]
                        if (is_array($ranking) && isset($ranking['candidate_id']) && isset($ranking['rank'])) {
                            $candidateId = (int)$ranking['candidate_id'];
                            $rankValue = (int)$ranking['rank'];
                            
                            if ($rankValue > 0 && $rankValue < $lowestRank) {
                                $lowestRank = $rankValue;
                                $rank1CandidateId = $candidateId;
                            }
                        }
                    }
                    
                    if ($rank1CandidateId && isset($candidateResults[$rank1CandidateId])) {
                        $candidateResults[$rank1CandidateId]['votes']++;
                    }
                }
            }
        }

        // Calculate percentages
        $validVotes = $totalVotes - $abstentions;
        foreach ($candidateResults as $candidateId => &$result) {
            $result['percentage'] = $validVotes > 0 
                ? round(($result['votes'] / $validVotes) * 100, 2) 
                : 0;
        }

        // Sort by votes (descending) and assign ranks
        uasort($candidateResults, function ($a, $b) {
            return $b['votes'] <=> $a['votes'];
        });

        $rank = 1;
        $previousVotes = null;
        foreach ($candidateResults as &$result) {
            if ($previousVotes !== null && $result['votes'] < $previousVotes) {
                $rank++;
            }
            $result['rank'] = $result['votes'] > 0 ? $rank : null;
            $previousVotes = $result['votes'];
        }

        // Determine winner(s)
        $winners = $this->determineWinners($position, $candidateResults, $validVotes);

        return [
            'position_id' => $position->id,
            'position_name' => $position->name,
            'position_description' => $position->description,
            'position_type' => $position->type,
            'total_votes' => $totalVotes,
            'valid_votes' => $validVotes,
            'abstentions' => $abstentions,
            'candidates' => array_values($candidateResults),
            'winners' => $winners,
        ];
    }

    /**
     * Determine winners based on position type and voting rules.
     *
     * @param ElectionPosition $position
     * @param array $candidateResults
     * @param int $validVotes
     * @return array
     */
    protected function determineWinners(ElectionPosition $position, array $candidateResults, int $validVotes): array
    {
        if ($validVotes === 0) {
            return [];
        }

        $winners = [];
        $sortedResults = collect($candidateResults)->sortByDesc('votes')->values();

        if ($position->type === 'single') {
            // Single winner - highest votes
            $topCandidate = $sortedResults->first();
            if ($topCandidate && $topCandidate['votes'] > 0) {
                $winners[] = $topCandidate;
            }
        } elseif ($position->type === 'multiple') {
            // Multiple winners - top N candidates
            $maxSelection = $position->max_selection ?? 1;
            $winners = $sortedResults->take($maxSelection)
                ->filter(fn($c) => $c['votes'] > 0)
                ->toArray();
        } elseif ($position->type === 'ranked') {
            // For ranked choice, implement instant runoff voting
            $winners = $this->calculateRankedChoiceWinner($position, $candidateResults, $validVotes);
        }

        return $winners;
    }

    /**
     * Calculate winner for ranked choice voting using instant runoff.
     *
     * @param ElectionPosition $position
     * @param array $candidateResults
     * @param int $validVotes
     * @return array
     */
    protected function calculateRankedChoiceWinner(ElectionPosition $position, array $candidateResults, int $validVotes): array
    {
        // Get all votes for this election (votes contain all positions in vote_data)
        $allVotes = Vote::where('election_id', $position->election_id)->get();
        
        $fieldKey = "position_{$position->id}";
        $rankings = [];

        foreach ($allVotes as $vote) {
            $voteData = $vote->vote_data[$fieldKey] ?? null;
            if ($voteData && isset($voteData['rankings']) && is_array($voteData['rankings'])) {
                $rankings[] = $voteData['rankings'];
            }
        }

        if (empty($rankings)) {
            return [];
        }

        // Implement instant runoff voting
        $candidates = collect($candidateResults)->pluck('candidate_id')->toArray();
        $round = 1;
        $eliminated = [];

        while (count($candidates) - count($eliminated) > 1) {
            // Count first-choice votes for remaining candidates
            $roundVotes = [];
            foreach ($candidates as $candidateId) {
                if (!in_array($candidateId, $eliminated)) {
                    $roundVotes[$candidateId] = 0;
                }
            }

            foreach ($rankings as $ranking) {
                // Find the highest-ranked candidate not eliminated
                // Rankings are stored as array of objects: [{"candidate_id": X, "rank": Y}, ...]
                $selectedCandidate = null;
                $lowestRank = PHP_INT_MAX;

                if (is_array($ranking)) {
                    foreach ($ranking as $rankEntry) {
                        // Handle array of objects format: [{"candidate_id": X, "rank": Y}, ...]
                        if (is_array($rankEntry) && isset($rankEntry['candidate_id']) && isset($rankEntry['rank'])) {
                            $candidateId = (int)$rankEntry['candidate_id'];
                            $rank = (int)$rankEntry['rank'];

                            if (!in_array($candidateId, $eliminated) && $rank > 0 && $rank < $lowestRank) {
                                $lowestRank = $rank;
                                $selectedCandidate = $candidateId;
                            }
                        }
                    }
                }

                if ($selectedCandidate && isset($roundVotes[$selectedCandidate])) {
                    $roundVotes[$selectedCandidate]++;
                }
            }

            // Check for majority (50% + 1)
            $totalRoundVotes = array_sum($roundVotes);
            $majority = ($totalRoundVotes / 2) + 1;

            foreach ($roundVotes as $candidateId => $votes) {
                if ($votes >= $majority) {
                    // Winner found
                    $winner = collect($candidateResults)->firstWhere('candidate_id', $candidateId);
                    return $winner ? [$winner] : [];
                }
            }

            // Eliminate candidate with fewest votes
            $minVotes = min($roundVotes);
            $candidateToEliminate = array_search($minVotes, $roundVotes);
            if ($candidateToEliminate !== false) {
                $eliminated[] = $candidateToEliminate;
            }

            $round++;
            if ($round > 100) {
                // Safety break to prevent infinite loops
                break;
            }
        }

        // Last remaining candidate is the winner
        $remaining = array_diff($candidates, $eliminated);
        if (count($remaining) === 1) {
            $winnerId = reset($remaining);
            $winner = collect($candidateResults)->firstWhere('candidate_id', $winnerId);
            return $winner ? [$winner] : [];
        }

        return [];
    }
}

