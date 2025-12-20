<?php

namespace App\Http\Controllers\Api\Students;

use App\Http\Controllers\Controller;
use App\Services\VotingStatsService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class StudentStatsController extends Controller
{
    protected $statsService;

    public function __construct(VotingStatsService $statsService)
    {
        $this->statsService = $statsService;
    }

    /**
     * Get comprehensive statistics for the authenticated student.
     *
     * GET /api/v1/students/me/stats
     */
    public function getStats(Request $request)
    {
        try {
            $user = auth('api')->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated.',
                ], 401);
            }

            // Calculate all stats using the service
            $stats = $this->statsService->calculateUserStats($user);

            Log::info('API Student Stats: Retrieved student statistics', [
                'user_id' => $user->id,
                'elections_voted' => $stats['elections_voted'],
                'campus_rank' => $stats['campus_rank'],
                'percentile' => $stats['percentile'],
            ]);

            // Return flat structure matching client/mobile expectations
            return response()->json([
                'success' => true,
                'message' => 'Student statistics retrieved successfully.',
                'data' => $stats,
            ], 200);

        } catch (\Exception $e) {
            Log::error('API Student Stats: An unexpected error occurred', [
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
