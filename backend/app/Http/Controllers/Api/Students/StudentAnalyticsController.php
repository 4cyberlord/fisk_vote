<?php

namespace App\Http\Controllers\Api\Students;

use App\Http\Controllers\Controller;
use App\Models\Election;
use App\Models\Vote;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class StudentAnalyticsController extends Controller
{
    /**
     * Get detailed analytics for the authenticated student.
     *
     * GET /api/v1/students/analytics
     */
    public function getAnalytics(Request $request)
    {
        try {
            $user = auth('api')->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated.',
                ], 401);
            }

            // Get all elections user is eligible for
            $allElections = Election::all()->filter(function ($election) use ($user) {
                return $election->isEligibleForUser($user);
            });

            // Get user's votes
            $userVotes = Vote::where('voter_id', $user->id)
                ->with('election')
                ->get();

            // Calculate statistics
            $totalElections = $allElections->count();
            $activeElections = $allElections->filter(fn($e) => $e->current_status === 'Open')->count();
            $upcomingElections = $allElections->filter(fn($e) => $e->current_status === 'Upcoming')->count();
            $closedElections = $allElections->filter(fn($e) => $e->current_status === 'Closed')->count();
            $totalVotes = $userVotes->count();
            $participationRate = $totalElections > 0 ? round(($totalVotes / $totalElections) * 100, 1) : 0;

            // Votes over time (last 30 days)
            $votesOverTime = Vote::where('voter_id', $user->id)
                ->where('voted_at', '>=', now()->subDays(30))
                ->selectRaw('DATE(voted_at) as date, COUNT(*) as count')
                ->groupBy('date')
                ->orderBy('date')
                ->get()
                ->map(function ($item) {
                    return [
                        'date' => $item->date,
                        'count' => (int) $item->count,
                    ];
                });

            // Election type distribution
            $electionTypes = $allElections->groupBy('type')->map->count();

            // Most active voting period (hour of day)
            $votingHours = Vote::where('voter_id', $user->id)
                ->selectRaw('HOUR(voted_at) as hour, COUNT(*) as count')
                ->groupBy('hour')
                ->orderByDesc('count')
                ->limit(5)
                ->get()
                ->map(function ($item) {
                    return [
                        'hour' => (int) $item->hour,
                        'count' => (int) $item->count,
                    ];
                });

            Log::info('API Student Analytics: Retrieved analytics', [
                'user_id' => $user->id,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Analytics retrieved successfully.',
                'data' => [
                    'overview' => [
                        'total_elections' => $totalElections,
                        'active_elections' => $activeElections,
                        'upcoming_elections' => $upcomingElections,
                        'closed_elections' => $closedElections,
                        'total_votes' => $totalVotes,
                        'participation_rate' => $participationRate,
                    ],
                    'votes_over_time' => $votesOverTime,
                    'election_types' => $electionTypes,
                    'voting_hours' => $votingHours,
                ],
            ], 200);
        } catch (\Exception $e) {
            Log::error('API Student Analytics: An unexpected error occurred', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'user_id' => $user->id ?? 'unknown',
            ]);

            return response()->json([
                'success' => false,
                'message' => 'An unexpected error occurred. Please try again later.',
                'error' => config('app.debug') ? $e->getMessage() : 'An unexpected error occurred',
            ], 500);
        }
    }
}

