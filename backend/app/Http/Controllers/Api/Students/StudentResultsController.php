<?php

namespace App\Http\Controllers\Api\Students;

use App\Http\Controllers\Controller;
use App\Models\Election;
use App\Services\ElectionResultsService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class StudentResultsController extends Controller
{
    protected ElectionResultsService $resultsService;

    public function __construct(ElectionResultsService $resultsService)
    {
        $this->resultsService = $resultsService;
    }

    /**
     * Get results for a specific election (only if closed).
     *
     * GET /api/v1/students/elections/{id}/results
     */
    public function getElectionResults(Request $request, $id)
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

            // Only show results if election is closed
            if ($election->current_status !== 'Closed') {
                return response()->json([
                    'success' => false,
                    'message' => 'Results are only available after the election closes.',
                ], 403);
            }

            $results = $this->resultsService->calculateElectionResults($election);

            Log::info('API Student Results: Retrieved election results', [
                'user_id' => $user->id,
                'election_id' => $election->id,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Election results retrieved successfully.',
                'data' => $results,
            ], 200);
        } catch (\Exception $e) {
            Log::error('API Student Results: An unexpected error occurred', [
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
     * Get all closed elections with results.
     *
     * GET /api/v1/students/elections/results
     */
    public function getAllResults(Request $request)
    {
        try {
            $user = auth('api')->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated.',
                ], 401);
            }

            // Get all closed elections user is eligible for
            $closedElections = Election::where(function ($query) {
                $query->where('status', 'closed')
                    ->orWhere('end_time', '<', now());
            })->get()->filter(function ($election) use ($user) {
                return $election->isEligibleForUser($user) && $election->current_status === 'Closed';
            });

            $results = $closedElections->map(function ($election) {
                return [
                    'id' => $election->id,
                    'title' => $election->title,
                    'description' => $election->description,
                    'end_time' => $election->end_time ? $election->end_time->format('Y-m-d H:i:s') : null,
                    'total_votes' => \App\Models\Vote::where('election_id', $election->id)->count(),
                ];
            })->values();

            Log::info('API Student Results: Retrieved all results', [
                'user_id' => $user->id,
                'results_count' => $results->count(),
            ]);

            return response()->json([
                'success' => true,
                'message' => $results->isEmpty() 
                    ? 'No closed elections with results available.' 
                    : 'Election results list retrieved successfully.',
                'data' => $results,
            ], 200);
        } catch (\Exception $e) {
            Log::error('API Student Results: An unexpected error occurred', [
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
}

