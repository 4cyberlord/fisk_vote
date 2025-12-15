<?php

namespace App\Http\Controllers\Api\Students;

use App\Http\Controllers\Controller;
use App\Models\Election;
use App\Models\ElectionPosition;
use App\Models\ElectionCandidate;
use App\Models\Vote;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class StudentVoteController extends Controller
{
    /**
     * Get all elections the authenticated student has voted in,
     * including their stored vote data for each election.
     */
    public function getMyVotes(Request $request)
    {
        try {
            $user = auth('api')->user();

            if (! $user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated.',
                ], 401);
            }

            // One vote row per election per voter
            $votes = Vote::with(['election.positions.candidates.user'])
                ->where('voter_id', $user->id)
                ->orderByDesc('voted_at')
                ->get();

            $data = $votes->map(function (Vote $vote) {
                $election = $vote->election;

                return [
                    'election' => [
                        'id' => $election->id,
                        'title' => $election->title,
                        'description' => $election->description,
                        'type' => $election->type,
                        'current_status' => $election->current_status,
                        'start_time' => optional($election->start_time)?->format('Y-m-d H:i:s'),
                        'end_time' => optional($election->end_time)?->format('Y-m-d H:i:s'),
                    ],
                    'voted_at' => optional($vote->voted_at)->toIso8601String(),
                    'vote_data' => $vote->vote_data,
                    'positions' => $election->positions->map(function (ElectionPosition $position) {
                        return [
                            'id' => $position->id,
                            'name' => $position->name,
                            'description' => $position->description,
                            'type' => $position->type,
                            'max_selection' => $position->max_selection,
                            'ranking_levels' => $position->ranking_levels,
                            'allow_abstain' => $position->allow_abstain,
                            'candidates' => $position->candidates->map(function (ElectionCandidate $candidate) {
                                return [
                                    'id' => $candidate->id,
                                    'user_id' => $candidate->user_id,
                                    'user' => $candidate->user ? [
                                        'id' => $candidate->user->id,
                                        'name' => $candidate->user->name,
                                        'first_name' => $candidate->user->first_name,
                                        'last_name' => $candidate->user->last_name,
                                        'email' => $candidate->user->email,
                                        'profile_photo' => $candidate->user->profile_photo,
                                    ] : null,
                                    'photo_url' => $candidate->photo_url,
                                    'tagline' => $candidate->tagline,
                                    'bio' => $candidate->bio,
                                    'manifesto' => $candidate->manifesto,
                                ];
                            }),
                        ];
                    }),
                ];
            });

            Log::info('API Get My Votes: Retrieved student votes', [
                'user_id' => $user->id,
                'votes_count' => $data->count(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Vote history retrieved successfully.',
                'data' => $data,
            ]);
        } catch (\Exception $e) {
            Log::error('API Get My Votes: An unexpected error occurred', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'An unexpected error occurred. Please try again later.',
                'error' => config('app.debug') ? $e->getMessage() : 'An unexpected error occurred',
            ], 500);
        }
    }

    /**
     * Cast a vote for an election.
     *
     * @param Request $request
     * @param int $electionId
     * @return \Illuminate\Http\JsonResponse
     */
    public function castVote(Request $request, $electionId)
    {
        try {
            $user = auth('api')->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated.',
                ], 401);
            }

            // Get election with positions and candidates
            $election = Election::with([
                'positions.candidates' => function ($query) {
                    $query->where('approved', true)->with('user');
                }
            ])->find($electionId);

            if (!$election) {
                return response()->json([
                    'success' => false,
                    'message' => 'Election not found.',
                ], 404);
            }

            // Check eligibility
            if (!$election->isEligibleForUser($user)) {
                return response()->json([
                    'success' => false,
                    'message' => 'You are not eligible to vote in this election.',
                ], 403);
            }

            // Check if election is open
            if ($election->current_status !== 'Open') {
                return response()->json([
                    'success' => false,
                    'message' => 'This election is not currently open for voting.',
                    'current_status' => $election->current_status,
                ], 403);
            }

            // Check if user has already voted
            if ($election->hasUserVoted($user)) {
                return response()->json([
                    'success' => false,
                    'message' => 'You have already voted in this election.',
                ], 409);
            }

            // Validate request data
            $validator = $this->validateVoteData($request, $election);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }

            // Process and save votes in a single row per election
            DB::beginTransaction();

            try {
                $rawVotesInput = $request->input('votes', []);
                $storedVoteData = [];
                $hasAnySelection = false;

                foreach ($election->positions as $position) {
                    $positionKey = "position_{$position->id}";
                    $abstainKey = "{$positionKey}_abstain";

                    // Handle abstain flag (store it so frontend can reconstruct state)
                    if (!empty($rawVotesInput[$abstainKey])) {
                        $storedVoteData[$abstainKey] = true;
                        continue;
                    }

                    $positionVote = $rawVotesInput[$positionKey] ?? null;

                    if ($positionVote === null) {
                        // If abstain not allowed and no vote, validation should have caught this
                        if (!$position->allow_abstain) {
                            throw new \Exception("Vote required for position: {$position->name}");
                        }
                        continue;
                    }

                    // Prepare and validate structured data for this position
                    $voteDataStructure = $this->prepareVoteData($position, $positionVote);
                    $this->validateVoteDataStructure($position, $voteDataStructure);

                    $storedVoteData[$positionKey] = $voteDataStructure;
                    $hasAnySelection = true;
                }

                // Ensure at least one non‑abstain selection exists
                if (!$hasAnySelection) {
                    throw new \Exception('At least one position must be voted on or abstained.');
                }

                // Persist a single vote row for this election + voter
                // position_id is required (FK) — use the first position or fail fast
                $firstPositionId = $election->positions->first()?->id;
                if (!$firstPositionId) {
                    throw new \Exception('This election has no positions to vote on.');
                }

                $vote = Vote::create([
                    'election_id' => $election->id,
                    'position_id' => $firstPositionId,
                    'voter_id' => $user->id,
                    'vote_data' => $storedVoteData,
                    'voted_at' => now(),
                ]);

                // Reload relationships for observer
                $vote->load(['voter', 'election']);

                DB::commit();

                // Log vote submission to audit log
                $auditLogService = app(\App\Services\AuditLogService::class);
                $auditLogService->logVoteSubmission(
                    $election->id,
                    $user->id,
                    'success'
                );

                Log::info('API Cast Vote: Vote cast successfully', [
                    'user_id' => $user->id,
                    'election_id' => $election->id,
                    'positions_count' => count($election->positions),
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Your vote has been successfully submitted. Thank you for participating!',
                    'data' => [
                        'election_id' => $election->id,
                        'vote_id' => $vote->id,
                        'voted_at' => $vote->voted_at->toIso8601String(),
                    ],
                ], 201);

            } catch (\Exception $e) {
                DB::rollBack();

                // Log failed vote submission
                $auditLogService = app(\App\Services\AuditLogService::class);
                $auditLogService->logVoteSubmission(
                    $election->id,
                    $user->id,
                    'failed',
                    $e->getMessage()
                );

                throw $e;
            }

        } catch (\Exception $e) {
            Log::error('API Cast Vote: An unexpected error occurred', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'election_id' => $electionId,
                'user_id' => $user->id ?? 'unknown',
            ]);

            return response()->json([
                'success' => false,
                'message' => 'An unexpected error occurred while processing your vote. Please try again later.',
                'error' => config('app.debug') ? $e->getMessage() : 'An unexpected error occurred',
            ], 500);
        }
    }

    /**
     * Validate vote data structure.
     *
     * @param Request $request
     * @param Election $election
     * @return \Illuminate\Contracts\Validation\Validator
     */
    protected function validateVoteData(Request $request, Election $election)
    {
        $rules = [];
        $messages = [];

        foreach ($election->positions as $position) {
            $fieldKey = "votes.position_{$position->id}";
            $abstainKey = "votes.position_{$position->id}_abstain";

            // Get approved candidate IDs for this position
            $approvedCandidateIds = $position->candidates
                ->where('approved', true)
                ->pluck('id')
                ->toArray();

            if ($position->allow_abstain) {
                $rules[$fieldKey] = 'nullable';
                $rules[$abstainKey] = 'nullable|boolean';
            } else {
                $rules[$fieldKey] = 'required';
            }

            // Position-specific validation
            switch ($position->type) {
                case 'single':
                    $rules[$fieldKey] .= '|integer|in:' . implode(',', $approvedCandidateIds);
                    $messages["{$fieldKey}.in"] = "Selected candidate is not valid for position: {$position->name}";
                    break;

                case 'multiple':
                    $rules[$fieldKey] .= '|array';
                    $rules["{$fieldKey}.*"] = 'integer|in:' . implode(',', $approvedCandidateIds);

                    if ($position->max_selection) {
                        $rules[$fieldKey] .= "|max:{$position->max_selection}";
                        $messages["{$fieldKey}.max"] = "You can select a maximum of {$position->max_selection} candidate(s) for {$position->name}";
                    }

                    $messages["{$fieldKey}.array"] = "Vote for {$position->name} must be an array of candidate IDs";
                    break;

                case 'ranked':
                    $rules[$fieldKey] .= '|array';
                    $rules["{$fieldKey}.*.candidate_id"] = 'required|integer|in:' . implode(',', $approvedCandidateIds);

                    if ($position->ranking_levels) {
                        $rules[$fieldKey] .= "|max:{$position->ranking_levels}";
                        $messages["{$fieldKey}.max"] = "You can rank a maximum of {$position->ranking_levels} candidate(s) for {$position->name}";
                    }
                    break;
            }
        }

        return Validator::make($request->all(), $rules, $messages);
    }

    /**
     * Prepare vote data structure based on position type.
     *
     * @param ElectionPosition $position
     * @param mixed $voteValue
     * @return array
     */
    protected function prepareVoteData(ElectionPosition $position, $voteValue)
    {
        return match($position->type) {
            'single' => ['candidate_id' => (int) $voteValue],
            'multiple' => ['candidate_ids' => is_array($voteValue) ? array_map('intval', $voteValue) : [(int) $voteValue]],
            'ranked' => $this->prepareRankedVoteData($voteValue),
            default => ['candidate_id' => (int) $voteValue],
        };
    }

    /**
     * Prepare ranked vote data.
     *
     * @param array $voteValue
     * @return array
     */
    protected function prepareRankedVoteData($voteValue)
    {
        if (!is_array($voteValue)) {
            return ['rankings' => []];
        }

        $rankings = [];
        foreach ($voteValue as $index => $item) {
            if (is_array($item) && isset($item['candidate_id'])) {
                $rankings[(int) $item['candidate_id']] = $index + 1; // Rank starts at 1
            } elseif (is_numeric($item)) {
                $rankings[(int) $item] = $index + 1;
            }
        }

        return ['rankings' => $rankings];
    }

    /**
     * Validate vote data structure.
     *
     * @param ElectionPosition $position
     * @param array $voteData
     * @return void
     * @throws \Exception
     */
    protected function validateVoteDataStructure(ElectionPosition $position, array $voteData)
    {
        $approvedCandidateIds = $position->candidates
            ->where('approved', true)
            ->pluck('id')
            ->toArray();

        switch ($position->type) {
            case 'single':
                if (!isset($voteData['candidate_id']) || !in_array($voteData['candidate_id'], $approvedCandidateIds)) {
                    throw new \Exception("Invalid candidate ID for position: {$position->name}");
                }
                break;

            case 'multiple':
                if (!isset($voteData['candidate_ids']) || !is_array($voteData['candidate_ids'])) {
                    throw new \Exception("Invalid vote data for position: {$position->name}");
                }

                foreach ($voteData['candidate_ids'] as $candidateId) {
                    if (!in_array($candidateId, $approvedCandidateIds)) {
                        throw new \Exception("Invalid candidate ID in vote for position: {$position->name}");
                    }
                }

                if ($position->max_selection && count($voteData['candidate_ids']) > $position->max_selection) {
                    throw new \Exception("Too many candidates selected for position: {$position->name}");
                }
                break;

            case 'ranked':
                if (!isset($voteData['rankings']) || !is_array($voteData['rankings'])) {
                    throw new \Exception("Invalid ranked vote data for position: {$position->name}");
                }

                foreach (array_keys($voteData['rankings']) as $candidateId) {
                    if (!in_array($candidateId, $approvedCandidateIds)) {
                        throw new \Exception("Invalid candidate ID in ranked vote for position: {$position->name}");
                    }
                }

                if ($position->ranking_levels && count($voteData['rankings']) > $position->ranking_levels) {
                    throw new \Exception("Too many rankings for position: {$position->name}");
                }
                break;
        }
    }

    /**
     * Get voting ballot data for an election (positions and candidates).
     *
     * @param Request $request
     * @param int $electionId
     * @return \Illuminate\Http\JsonResponse
     */
    public function getBallot(Request $request, $electionId)
    {
        try {
            $user = auth('api')->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated.',
                ], 401);
            }

            $election = Election::with([
                'positions.candidates' => function ($query) {
                    $query->where('approved', true)->with('user');
                }
            ])->find($electionId);

            if (!$election) {
                return response()->json([
                    'success' => false,
                    'message' => 'Election not found.',
                ], 404);
            }

            // Check eligibility
            if (!$election->isEligibleForUser($user)) {
                return response()->json([
                    'success' => false,
                    'message' => 'You are not eligible to vote in this election.',
                ], 403);
            }

            // Check if user has already voted
            $hasVoted = $election->hasUserVoted($user);
            $existingVote = null;

            if ($hasVoted) {
                $existingVote = Vote::where('election_id', $election->id)
                    ->where('voter_id', $user->id)
                    ->first();
            }

            // Transform positions and candidates for API response
            $positionsData = $election->positions->map(function ($position) {
                return [
                    'id' => $position->id,
                    'name' => $position->name,
                    'description' => $position->description,
                    'type' => $position->type,
                    'max_selection' => $position->max_selection,
                    'ranking_levels' => $position->ranking_levels,
                    'allow_abstain' => $position->allow_abstain,
                    'candidates' => $position->candidates->map(function ($candidate) {
                        return [
                            'id' => $candidate->id,
                            'user_id' => $candidate->user_id,
                            'user' => $candidate->user ? [
                                'id' => $candidate->user->id,
                                'name' => $candidate->user->name,
                                'first_name' => $candidate->user->first_name,
                                'last_name' => $candidate->user->last_name,
                                'email' => $candidate->user->email,
                                'profile_photo' => $candidate->user->profile_photo,
                            ] : null,
                            'photo_url' => $candidate->photo_url,
                            'tagline' => $candidate->tagline,
                            'bio' => $candidate->bio,
                            'manifesto' => $candidate->manifesto,
                        ];
                    }),
                ];
            });

            Log::info('API Get Ballot: Retrieved ballot data', [
                'user_id' => $user->id,
                'election_id' => $election->id,
                'has_voted' => $hasVoted,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Ballot data retrieved successfully.',
                'data' => [
                    'election' => [
                        'id' => $election->id,
                        'title' => $election->title,
                        'description' => $election->description,
                        'type' => $election->type,
                        'current_status' => $election->current_status,
                        'start_time' => $election->start_time->format('Y-m-d H:i:s'),
                        'end_time' => $election->end_time->format('Y-m-d H:i:s'),
                    ],
                    'positions' => $positionsData,
                    'has_voted' => $hasVoted,
                    'existing_vote' => $existingVote ? [
                        'vote_data' => $existingVote->vote_data,
                        'voted_at' => $existingVote->voted_at->toIso8601String(),
                    ] : null,
                ],
            ]);

        } catch (\Exception $e) {
            Log::error('API Get Ballot: An unexpected error occurred', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'election_id' => $electionId,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'An unexpected error occurred. Please try again later.',
                'error' => config('app.debug') ? $e->getMessage() : 'An unexpected error occurred',
            ], 500);
        }
    }
}

