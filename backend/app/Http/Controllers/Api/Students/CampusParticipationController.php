<?php

namespace App\Http\Controllers\Api\Students;

use App\Http\Controllers\Controller;
use App\Models\Election;
use App\Models\User;
use App\Models\Vote;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class CampusParticipationController extends Controller
{
    /**
     * Get campus-wide voter participation statistics.
     *
     * GET /api/v1/students/campus-participation
     */
    public function getCampusParticipation(Request $request)
    {
        try {
            $user = auth('api')->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated.',
                ], 401);
            }

            $year = $request->get('year', $this->getCurrentAcademicYear());
            $includeTrends = $request->boolean('include_trends', true);

            Log::info('API Campus Participation: Retrieved campus participation', [
                'user_id' => $user->id,
                'year' => $year,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Campus participation data retrieved successfully.',
                'data' => [
                    'academic_year' => $year,
                    'overall' => $this->getOverallStats($year, $includeTrends),
                    'by_class_year' => $this->getByClassYear($year),
                    'by_election_type' => $this->getByElectionType($year),
                    'recent_elections' => $this->getRecentElections($year, 5),
                ],
            ], 200);

        } catch (\Exception $e) {
            Log::error('API Campus Participation: An unexpected error occurred', [
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
     * Get overall campus participation statistics.
     */
    private function getOverallStats(string $year, bool $includeTrends): array
    {
        // Get total eligible students (active students with Student role)
        $totalEligible = User::whereHas('roles', function ($query) {
            $query->where('name', 'Student');
        })
        ->where('enrollment_status', 'Active')
        ->count();

        // Get unique voters for the academic year
        $startDate = $this->getAcademicYearStart($year);
        $endDate = $this->getAcademicYearEnd($year);

        $totalVoters = Vote::whereBetween('voted_at', [$startDate, $endDate])
            ->select('voter_id')
            ->distinct()
            ->count('voter_id');

        $participationRate = $totalEligible > 0
            ? round(($totalVoters / $totalEligible) * 100, 1)
            : 0.0;

        $result = [
            'total_eligible_students' => $totalEligible,
            'total_voters' => $totalVoters,
            'participation_rate' => $participationRate,
        ];

        if ($includeTrends) {
            $lastYear = $this->getPreviousAcademicYear($year);
            $lastYearStats = $this->getOverallStats($lastYear, false);

            $trend = $participationRate - $lastYearStats['participation_rate'];
            $trendDirection = $trend > 0 ? 'up' : ($trend < 0 ? 'down' : 'stable');

            $result['trend'] = ($trend > 0 ? '+' : '') . number_format($trend, 1) . '%';
            $result['trend_direction'] = $trendDirection;
            $result['vs_last_year'] = [
                'participation_rate' => $lastYearStats['participation_rate'],
                'change' => round($trend, 1),
            ];
        }

        return $result;
    }

    /**
     * Get participation statistics by class year.
     */
    private function getByClassYear(string $year): array
    {
        $startDate = $this->getAcademicYearStart($year);
        $endDate = $this->getAcademicYearEnd($year);

        // Get voted counts by class year
        $voted = Vote::whereBetween('voted_at', [$startDate, $endDate])
            ->join('users', 'votes.voter_id', '=', 'users.id')
            ->whereNotNull('users.class_level')
            ->selectRaw('users.class_level as label, COUNT(DISTINCT votes.voter_id) as voted')
            ->groupBy('users.class_level')
            ->pluck('voted', 'label')
            ->toArray();

        // Get total counts by class year
        $totals = User::whereHas('roles', function ($query) {
            $query->where('name', 'Student');
        })
        ->where('enrollment_status', 'Active')
        ->whereNotNull('class_level')
        ->selectRaw('class_level as label, COUNT(*) as total')
        ->groupBy('class_level')
        ->pluck('total', 'label')
        ->toArray();

        $classLevels = ['Freshman', 'Sophomore', 'Junior', 'Senior'];
        $result = [];

        foreach ($classLevels as $classLevel) {
            $total = $totals[$classLevel] ?? 0;
            if ($total === 0) continue;

            $votedCount = $voted[$classLevel] ?? 0;
            $percentage = $total > 0 ? round(($votedCount / $total) * 100, 1) : 0.0;

            // Format label (pluralize)
            $label = $classLevel === 'Freshman' ? 'Freshmen' : $classLevel . 's';

            // Calculate trend (simplified)
            $trend = $this->calculateClassYearTrend($classLevel, $year);

            $result[] = [
                'label' => $label,
                'voted' => $votedCount,
                'total' => $total,
                'percentage' => $percentage,
                'trend' => $trend,
            ];
        }

        // Sort by percentage descending
        usort($result, fn($a, $b) => $b['percentage'] <=> $a['percentage']);

        return $result;
    }

    /**
     * Get participation statistics by election type.
     */
    private function getByElectionType(string $year): array
    {
        $startDate = $this->getAcademicYearStart($year);
        $endDate = $this->getAcademicYearEnd($year);

        $totalEligible = User::whereHas('roles', function ($query) {
            $query->where('name', 'Student');
        })
        ->where('enrollment_status', 'Active')
        ->count();

        $elections = Election::whereBetween('start_time', [$startDate, $endDate])
            ->whereIn('status', ['closed', 'archived'])
            ->get();

        $result = [];
        foreach ($elections as $election) {
            $type = $this->extractElectionType($election->title);

            if (!isset($result[$type])) {
                $result[$type] = [
                    'type' => $type,
                    'voted' => 0,
                    'total' => $totalEligible,
                    'percentage' => 0,
                ];
            }

            $voted = Vote::where('election_id', $election->id)
                ->select('voter_id')
                ->distinct()
                ->count('voter_id');

            $result[$type]['voted'] += $voted;
        }

        // Calculate percentages
        foreach ($result as &$item) {
            $item['percentage'] = $item['total'] > 0
                ? round(($item['voted'] / $item['total']) * 100, 1)
                : 0.0;
        }

        return array_values($result);
    }

    /**
     * Get recent elections with participation data.
     */
    private function getRecentElections(string $year, int $limit = 5): array
    {
        $startDate = $this->getAcademicYearStart($year);
        $endDate = $this->getAcademicYearEnd($year);

        $elections = Election::whereBetween('start_time', [$startDate, $endDate])
            ->whereIn('status', ['closed', 'archived'])
            ->orderBy('end_time', 'desc')
            ->limit($limit)
            ->get();

        $totalEligible = User::whereHas('roles', function ($query) {
            $query->where('name', 'Student');
        })
        ->where('enrollment_status', 'Active')
        ->count();

        return $elections->map(function ($election) use ($totalEligible) {
            $voted = Vote::where('election_id', $election->id)
                ->select('voter_id')
                ->distinct()
                ->count('voter_id');

            return [
                'election_id' => $election->id,
                'title' => $election->title,
                'voted' => $voted,
                'total_eligible' => $totalEligible,
                'participation_rate' => $totalEligible > 0
                    ? round(($voted / $totalEligible) * 100, 1)
                    : 0.0,
                'ended_at' => $election->end_time ? $election->end_time->toIso8601String() : null,
            ];
        })->toArray();
    }

    /**
     * Get current academic year.
     */
    private function getCurrentAcademicYear(): string
    {
        $year = now()->year;
        $month = now()->month;

        // Academic year starts in September
        if ($month >= 9) {
            return "$year-" . ($year + 1);
        }
        return ($year - 1) . "-$year";
    }

    /**
     * Get academic year start date.
     */
    private function getAcademicYearStart(string $year): Carbon
    {
        [$startYear] = explode('-', $year);
        return Carbon::create($startYear, 9, 1)->startOfDay();
    }

    /**
     * Get academic year end date.
     */
    private function getAcademicYearEnd(string $year): Carbon
    {
        [, $endYear] = explode('-', $year);
        return Carbon::create($endYear, 8, 31)->endOfDay();
    }

    /**
     * Get previous academic year.
     */
    private function getPreviousAcademicYear(string $year): string
    {
        [$startYear, $endYear] = explode('-', $year);
        return ($startYear - 1) . '-' . ($endYear - 1);
    }

    /**
     * Calculate class year trend.
     */
    private function calculateClassYearTrend(string $classYear, string $year): string
    {
        // Simplified - compare to last year
        $lastYear = $this->getPreviousAcademicYear($year);
        $currentStats = $this->getClassYearStats($classYear, $year);
        $lastStats = $this->getClassYearStats($classYear, $lastYear);

        $change = $currentStats['percentage'] - $lastStats['percentage'];
        return ($change > 0 ? '+' : '') . number_format($change, 1) . '%';
    }

    /**
     * Get class year statistics for a specific year.
     */
    private function getClassYearStats(string $classYear, string $year): array
    {
        $startDate = $this->getAcademicYearStart($year);
        $endDate = $this->getAcademicYearEnd($year);

        $voted = Vote::whereBetween('voted_at', [$startDate, $endDate])
            ->join('users', 'votes.voter_id', '=', 'users.id')
            ->where('users.class_level', $classYear)
            ->select('votes.voter_id')
            ->distinct()
            ->count('votes.voter_id');

        $total = User::whereHas('roles', function ($query) {
            $query->where('name', 'Student');
        })
        ->where('enrollment_status', 'Active')
        ->where('class_level', $classYear)
        ->count();

        return [
            'voted' => $voted,
            'total' => $total,
            'percentage' => $total > 0 ? round(($voted / $total) * 100, 1) : 0.0,
        ];
    }

    /**
     * Extract election type from title.
     */
    private function extractElectionType(string $title): string
    {
        $titleLower = strtolower($title);

        if (str_contains($titleLower, 'sga')) return 'SGA';
        if (str_contains($titleLower, 'class council')) return 'Class Council';
        if (str_contains($titleLower, 'referendum')) return 'Referendum';
        if (str_contains($titleLower, 'royal')) return 'Royal Court';

        return 'Other';
    }
}
