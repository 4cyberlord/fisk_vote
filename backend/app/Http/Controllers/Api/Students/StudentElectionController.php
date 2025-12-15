<?php

namespace App\Http\Controllers\Api\Students;

use App\Http\Controllers\Controller;
use App\Models\Election;
use App\Services\TimeService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

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

            // Get current time in UTC for consistent comparison
            $now = \Carbon\Carbon::now('UTC');

            // Query active elections - get all active elections and filter by current_status
            // This ensures we use the model's getCurrentStatusAttribute which handles timezone correctly
            $elections = Election::where('status', 'active')
                ->get()
                ->filter(function ($election) {
                    return $election->current_status === 'Open';
                })
                ->sortBy('start_time')
                ->values();

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

            $now = now();

            $electionsData = $elections->map(function (Election $election) {
                return [
                    'id' => $election->id,
                    'title' => $election->title,
                    'description' => $election->description,
                    'type' => $election->type,
                    'start_time' => $election->start_time?->format('Y-m-d H:i:s'),
                    'end_time' => $election->end_time?->format('Y-m-d H:i:s'),
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
}

