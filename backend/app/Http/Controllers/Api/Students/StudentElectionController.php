<?php

namespace App\Http\Controllers\Api\Students;

use App\Http\Controllers\Controller;
use App\Models\Election;
use App\Models\User;
use App\Models\Vote;
use App\Services\TimeService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class StudentElectionController extends Controller
{
    /**
     * Get active elections for the authenticated student.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getActiveElections(Request $request)
    {
        try {
            $user = auth('api')->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated.',
                ], 401);
            }

            $now = now(config('app.timezone', 'America/Chicago'));

            // Treat elections as active if their window is current, regardless of the raw status flag,
            // but exclude explicitly closed/archived records.
            $elections = Election::whereNotIn('status', ['closed', 'archived'])
                ->where('start_time', '<=', $now)
                ->where('end_time', '>=', $now)
                ->orderBy('start_time')
                ->get();

            // Filter elections by eligibility
            $eligibleElections = $elections->filter(function ($election) use ($user) {
                return $election->isEligibleForUser($user);
            });

            // Transform elections data for API response
            $electionsData = $eligibleElections->map(function ($election) use ($user) {
                return [
                    'id' => $election->id,
                    'title' => $election->title,
                    'description' => $election->description,
                    'type' => $election->type,
                    'max_selection' => $election->max_selection,
                    'ranking_levels' => $election->ranking_levels,
                    'allow_write_in' => $election->allow_write_in,
                    'allow_abstain' => $election->allow_abstain,
                    'start_time' => $election->start_time->toIso8601String(),
                    'end_time' => $election->end_time->toIso8601String(),
                    'start_timestamp' => $election->start_timestamp,
                    'end_timestamp' => $election->end_timestamp,
                    'current_status' => $election->current_status,
                    'has_voted' => $election->hasUserVoted($user),
                    'positions_count' => $election->positions()->count(),
                    'candidates_count' => $election->candidates()->count(),
                    'created_at' => $election->created_at->toIso8601String(),
                    'updated_at' => $election->updated_at->toIso8601String(),
                ];
            });

            Log::info('API Active Elections: Retrieved active elections', [
                'user_id' => $user->id,
                'elections_count' => $electionsData->count(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Active elections retrieved successfully.',
                'data' => $electionsData->values(), // Reset array keys
                'meta' => [
                    'total' => $electionsData->count(),
                    'timestamp' => now()->toIso8601String(),
                    'server_time' => TimeService::getNashvilleTimestamp(), // Nashville time from World Time API
                ],
            ]);

        } catch (\Exception $e) {
            Log::error('API Active Elections: An unexpected error occurred', [
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
     * Get all elections for the authenticated student (active or not).
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getAllElections(Request $request)
    {
        try {
            $user = auth('api')->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated.',
                ], 401);
            }

            // Get all elections (excluding drafts)
            $elections = Election::where('status', '!=', 'draft')
                ->orderBy('start_time', 'desc')
                ->get();

            // Filter elections by eligibility
            $eligibleElections = $elections->filter(function ($election) use ($user) {
                return $election->isEligibleForUser($user);
            });

            // Transform elections data for API response
            $electionsData = $eligibleElections->map(function ($election) use ($user) {
                return [
                    'id' => $election->id,
                    'title' => $election->title,
                    'description' => $election->description,
                    'type' => $election->type,
                    'max_selection' => $election->max_selection,
                    'ranking_levels' => $election->ranking_levels,
                    'allow_write_in' => $election->allow_write_in,
                    'allow_abstain' => $election->allow_abstain,
                    'start_time' => $election->start_time->format('Y-m-d H:i:s'),
                    'end_time' => $election->end_time->format('Y-m-d H:i:s'),
                    'start_timestamp' => $election->start_timestamp,
                    'end_timestamp' => $election->end_timestamp,
                    'status' => $election->status,
                    'current_status' => $election->current_status,
                    'has_voted' => $election->hasUserVoted($user),
                    'positions_count' => $election->positions()->count(),
                    'candidates_count' => $election->candidates()->count(),
                    'created_at' => $election->created_at->toIso8601String(),
                    'updated_at' => $election->updated_at->toIso8601String(),
                ];
            });

            Log::info('API All Elections: Retrieved all elections', [
                'user_id' => $user->id,
                'elections_count' => $electionsData->count(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Elections retrieved successfully.',
                'data' => $electionsData->values(), // Reset array keys
                'meta' => [
                    'total' => $electionsData->count(),
                    'timestamp' => now()->toIso8601String(),
                    'server_time' => TimeService::getNashvilleTimestamp(), // Nashville time from World Time API
                ],
            ]);

        } catch (\Exception $e) {
            Log::error('API All Elections: An unexpected error occurred', [
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
     * Get a public list of elections (no authentication required).
     *
     * This endpoint is intended for the public elections page on the client,
     * so it does not apply per-student eligibility or has_voted flags.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getPublicElections(Request $request)
    {
        try {
            // Get all elections (excluding drafts)
            $elections = Election::where('status', '!=', 'draft')
                ->orderBy('start_time', 'desc')
                ->get();

            $electionsData = $elections->map(function (Election $election) {
                return [
                    'id' => $election->id,
                    'title' => $election->title,
                    'description' => $election->description,
                    'type' => $election->type,
                    'start_time' => $election->start_time?->toIso8601String(),
                    'end_time' => $election->end_time?->toIso8601String(),
                    'start_timestamp' => $election->start_timestamp,
                    'end_timestamp' => $election->end_timestamp,
                    'status' => $election->status,
                    'current_status' => $election->current_status,
                    'positions_count' => $election->positions()->count(),
                    'candidates_count' => $election->candidates()->count(),
                    // Public endpoint does not expose per-user has_voted/eligibility
                ];
            });

            $openCount = $electionsData->where('current_status', 'Open')->count();
            $upcomingCount = $electionsData->where('current_status', 'Upcoming')->count();
            $closedCount = $electionsData->where('current_status', 'Closed')->count();

            return response()->json([
                'success' => true,
                'message' => 'Public elections retrieved successfully.',
                'data' => $electionsData->values(),
                'meta' => [
                    'total' => $electionsData->count(),
                    'open' => $openCount,
                    'upcoming' => $upcomingCount,
                    'closed' => $closedCount,
                    'timestamp' => now()->toIso8601String(),
                    'server_time' => TimeService::getNashvilleTimestamp(), // Nashville time from World Time API
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('API Public Elections: An unexpected error occurred', [
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
     * Get a specific election by ID (if eligible).
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function getElection(Request $request, $id)
    {
        try {
            $user = auth('api')->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated.',
                ], 401);
            }

            $election = Election::with(['positions.candidates.user'])->find($id);

            if (!$election) {
                return response()->json([
                    'success' => false,
                    'message' => 'Election not found.',
                ], 404);
            }

            // Check if user is eligible
            if (!$election->isEligibleForUser($user)) {
                return response()->json([
                    'success' => false,
                    'message' => 'You are not eligible to view this election.',
                ], 403);
            }

            // Transform election data
            $electionData = [
                'id' => $election->id,
                'title' => $election->title,
                'description' => $election->description,
                'type' => $election->type,
                'max_selection' => $election->max_selection,
                'ranking_levels' => $election->ranking_levels,
                'allow_write_in' => $election->allow_write_in,
                'allow_abstain' => $election->allow_abstain,
                'start_time' => $election->start_time->format('Y-m-d H:i:s'),
                'end_time' => $election->end_time->format('Y-m-d H:i:s'),
                'start_timestamp' => $election->start_timestamp,
                'end_timestamp' => $election->end_timestamp,
                'status' => $election->status,
                'current_status' => $election->current_status,
                'has_voted' => $election->hasUserVoted($user),
                'positions' => $election->positions->map(function ($position) {
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
                                'approved' => $candidate->approved,
                                'created_at' => $candidate->created_at->toIso8601String(),
                            ];
                        }),
                    ];
                }),
                'created_at' => $election->created_at->toIso8601String(),
                'updated_at' => $election->updated_at->toIso8601String(),
            ];

            Log::info('API Get Election: Retrieved election details', [
                'user_id' => $user->id,
                'election_id' => $election->id,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Election retrieved successfully.',
                'data' => $electionData,
            ]);

        } catch (\Exception $e) {
            Log::error('API Get Election: An unexpected error occurred', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'election_id' => $id,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'An unexpected error occurred. Please try again later.',
                'error' => config('app.debug') ? $e->getMessage() : 'An unexpected error occurred',
            ], 500);
        }
    }

    /**
     * Get turnout statistics for a specific election.
     *
     * GET /api/v1/students/elections/{id}/turnout
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function getElectionTurnout(Request $request, $id)
    {
        try {
            $user = auth('api')->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated.',
                ], 401);
            }

            $election = Election::find($id);

            if (!$election) {
                return response()->json([
                    'success' => false,
                    'message' => 'Election not found.',
                ], 404);
            }

            // Check if user is eligible
            if (!$election->isEligibleForUser($user)) {
                return response()->json([
                    'success' => false,
                    'message' => 'You are not eligible to view this election.',
                ], 403);
            }

            // Get all eligible users for this election
            $eligibleUsers = User::whereHas('roles', function ($query) {
                $query->where('name', 'Student');
            })
            ->where('enrollment_status', 'Active')
            ->get()
            ->filter(function ($eligibleUser) use ($election) {
                return $election->isEligibleForUser($eligibleUser);
            });

            $totalEligibleVoters = $eligibleUsers->count();

            // Get distinct voters who have voted in this election
            $totalVoted = Vote::where('election_id', $election->id)
                ->select('voter_id')
                ->distinct()
                ->count('voter_id');

            // Calculate participation rate
            $participationRate = $totalEligibleVoters > 0
                ? round(($totalVoted / $totalEligibleVoters) * 100, 1)
                : 0.0;

            // Default participation goal (can be made configurable later)
            $participationGoal = 80.0;

            // Calculate votes remaining to reach goal
            $votesNeededForGoal = (int) ceil(($participationGoal / 100) * $totalEligibleVoters);
            $votesRemaining = max(0, $votesNeededForGoal - $totalVoted);

            // Calculate percentage to goal
            $percentageToGoal = $participationGoal > 0
                ? round(($participationRate / $participationGoal) * 100, 1)
                : 0.0;

            // Determine election status
            $status = $election->current_status === 'Open' ? 'active' :
                     ($election->current_status === 'Upcoming' ? 'upcoming' : 'closed');

            // Build response data
            $turnoutData = [
                'election_id' => $election->id,
                'election_title' => $election->title,
                'status' => strtolower($status),
                'turnout' => [
                    'total_eligible_voters' => $totalEligibleVoters,
                    'total_voted' => $totalVoted,
                    'participation_rate' => $participationRate,
                    'participation_goal' => $participationGoal,
                    'votes_remaining' => $votesRemaining,
                    'percentage_to_goal' => $percentageToGoal,
                ],
                'updated_at' => now()->toIso8601String(),
            ];

            // Include breakdown by class year if requested
            $includeBreakdown = $request->boolean('include_breakdown', false);
            if ($includeBreakdown) {
                $classYearBreakdown = $this->calculateClassYearBreakdown($election, $eligibleUsers);
                $turnoutData['by_class_year'] = $classYearBreakdown;
            }

            Log::info('API Election Turnout: Retrieved turnout statistics', [
                'user_id' => $user->id,
                'election_id' => $election->id,
                'total_eligible' => $totalEligibleVoters,
                'total_voted' => $totalVoted,
                'participation_rate' => $participationRate,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Election turnout data retrieved successfully.',
                'data' => $turnoutData,
            ], 200);

        } catch (\Exception $e) {
            Log::error('API Election Turnout: An unexpected error occurred', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'election_id' => $id,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'An unexpected error occurred. Please try again later.',
                'error' => config('app.debug') ? $e->getMessage() : 'An unexpected error occurred',
            ], 500);
        }
    }

    /**
     * Calculate turnout breakdown by class year.
     *
     * @param Election $election
     * @param \Illuminate\Support\Collection $eligibleUsers
     * @return array
     */
    private function calculateClassYearBreakdown(Election $election, $eligibleUsers): array
    {
        $classLevels = ['Freshman', 'Sophomore', 'Junior', 'Senior'];
        $breakdown = [];

        foreach ($classLevels as $classLevel) {
            // Get eligible users for this class level
            $eligibleForClass = $eligibleUsers->where('class_level', $classLevel);
            $totalForClass = $eligibleForClass->count();

            if ($totalForClass === 0) {
                continue; // Skip if no eligible users in this class
            }

            // Get users who voted (distinct voters for this election)
            $voterIds = Vote::where('election_id', $election->id)
                ->select('voter_id')
                ->distinct()
                ->pluck('voter_id')
                ->toArray();

            $votedForClass = $eligibleForClass
                ->whereIn('id', $voterIds)
                ->count();

            $percentage = $totalForClass > 0
                ? round(($votedForClass / $totalForClass) * 100, 1)
                : 0.0;

            // Format label (pluralize)
            $label = $classLevel === 'Freshman' ? 'Freshmen' : $classLevel . 's';

            $breakdown[] = [
                'label' => $label,
                'voted' => $votedForClass,
                'total' => $totalForClass,
                'percentage' => $percentage,
            ];
        }

        return $breakdown;
    }
}

