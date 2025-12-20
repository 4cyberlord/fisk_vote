<?php

namespace App\Services;

use App\Models\User;
use App\Models\Vote;
use App\Models\Election;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class VotingStatsService
{
    /**
     * Calculate voting statistics for a specific user.
     * 
     * @param User $user
     * @return array
     */
    public function calculateUserStats(User $user): array
    {
        // Get all elections user is eligible for
        $allElections = Election::all()->filter(function ($election) use ($user) {
            return $election->isEligibleForUser($user);
        });

        // Get user's votes
        $userVotes = Vote::where('voter_id', $user->id)
            ->with('election')
            ->orderBy('voted_at')
            ->get();

        // Calculate unique elections voted in
        $electionsVoted = $userVotes->pluck('election_id')->unique()->count();

        // Calculate rank and percentile based on ALL users
        $rankData = $this->calculateRankAndPercentile($electionsVoted);

        // Calculate impact score
        $impactScore = $this->calculateImpactScore($user, $userVotes, $allElections);

        // Convert impact score to percentage
        $campusImpactScore = ($impactScore / 200) * 100;

        // Get description
        $description = $this->getPercentileDescription($rankData['percentile']);

        return [
            'elections_voted' => $electionsVoted,
            'campus_rank' => $rankData['rank'],
            'percentile' => $rankData['percentile'],
            'total_students' => $rankData['total_students'],
            'impact_score' => $impactScore,
            'campus_impact_score' => round($campusImpactScore, 1),
            'impact_description' => $description,
        ];
    }

    /**
     * Calculate rank and percentile for a user based on elections voted.
     * This ensures consistency by calculating against ALL users in the database.
     * 
     * @param int $userElectionsVoted
     * @return array
     */
    public function calculateRankAndPercentile(int $userElectionsVoted): array
    {
        // Get all active students
        $totalStudents = User::whereHas('roles', function ($query) {
            $query->where('name', 'Student');
        })
        ->where('enrollment_status', 'Active')
        ->count();

        if ($totalStudents === 0) {
            return [
                'rank' => 1,
                'percentile' => 100.0,
                'total_students' => 0,
            ];
        }

        // Get elections_voted count for ALL active students
        // First, get all active student IDs
        $activeStudentIds = User::whereHas('roles', function ($query) {
            $query->where('name', 'Student');
        })
        ->where('enrollment_status', 'Active')
        ->pluck('id')
        ->toArray();

        if (empty($activeStudentIds)) {
            return [
                'rank' => 1,
                'percentile' => 100.0,
                'total_students' => 0,
            ];
        }

        // Get elections_voted for each active student
        $allUsersStats = DB::table('votes')
            ->whereIn('voter_id', $activeStudentIds)
            ->select('voter_id', DB::raw('COUNT(DISTINCT election_id) as elections_voted'))
            ->groupBy('voter_id')
            ->get()
            ->map(function ($item) {
                return (int) $item->elections_voted;
            })
            ->sortDesc()
            ->values()
            ->toArray();

        // Count students with more elections voted than the user
        // Also include students with 0 votes (they're in activeStudentIds but may not be in allUsersStats)
        $studentsWithMoreVotes = collect($allUsersStats)
            ->filter(fn($count) => $count > $userElectionsVoted)
            ->count();

        // Students with 0 votes are also counted (they're below the user if user has votes)
        $studentsWithZeroVotes = $totalStudents - count($allUsersStats);
        if ($userElectionsVoted > 0) {
            $studentsWithMoreVotes += $studentsWithZeroVotes;
        }

        // Calculate rank (1 = highest)
        $rank = $studentsWithMoreVotes + 1;

        // Calculate percentile
        // Formula: ((Total Students - Students with Higher Votes) / Total Students) * 100
        $percentile = $totalStudents > 0
            ? round((($totalStudents - $studentsWithMoreVotes) / $totalStudents) * 100, 1)
            : 50.0;

        // Ensure percentile is between 0 and 100
        $percentile = max(0, min(100, $percentile));

        return [
            'rank' => $rank,
            'percentile' => $percentile,
            'total_students' => $totalStudents,
        ];
    }

    /**
     * Calculate Impact Score for a student.
     * 
     * @param User $user
     * @param \Illuminate\Support\Collection $userVotes
     * @param \Illuminate\Support\Collection $allElections
     * @return int
     */
    private function calculateImpactScore(User $user, $userVotes, $allElections): int
    {
        $baseScore = 50;
        $score = $baseScore;

        // Get unique elections voted in
        $electionsVoted = $userVotes->pluck('election_id')->unique()->count();

        // Base points: +10 per election
        $score += $electionsVoted * 10;

        // Early voting bonus: +5 points per early vote (within first 24 hours)
        $earlyVotes = $userVotes->filter(function ($vote) {
            if (!$vote->election || !$vote->voted_at) return false;
            $electionStart = Carbon::parse($vote->election->start_time);
            $voteTime = Carbon::parse($vote->voted_at);
            return $voteTime->diffInHours($electionStart) <= 24;
        })->count();
        $score += $earlyVotes * 5;

        // Perfect participation bonus: +3 points if voted in all eligible closed elections
        $closedElections = $allElections->filter(fn($e) => $e->current_status === 'Closed');
        $totalClosed = $closedElections->count();
        if ($electionsVoted == $totalClosed && $totalClosed > 0) {
            $score += 3;
        }

        // Consecutive voting bonus: +2 points per consecutive election
        $consecutive = $this->calculateConsecutiveElections($userVotes);
        $score += $consecutive * 2;

        // Special election bonus (SGA, General Elections, etc.)
        $specialElections = $userVotes->filter(function ($vote) {
            if (!$vote->election) return false;
            $title = strtolower($vote->election->title);
            return str_contains($title, 'sga') ||
                   str_contains($title, 'general') ||
                   str_contains($title, 'student government');
        })->count();
        $score += $specialElections * 3;

        // Ensure score is within reasonable bounds
        $score = max(50, min(200, $score));

        return $score;
    }

    /**
     * Calculate consecutive elections voted in.
     * 
     * @param \Illuminate\Support\Collection $votes
     * @return int
     */
    private function calculateConsecutiveElections($votes): int
    {
        if ($votes->isEmpty()) return 0;

        $elections = $votes->map(function ($vote) {
            if (!$vote->election || !$vote->election->end_time) return null;
            return [
                'id' => $vote->election_id,
                'ended_at' => $vote->election->end_time,
            ];
        })
        ->filter()
        ->sortBy('ended_at')
        ->values();

        if ($elections->isEmpty()) return 0;

        $maxConsecutive = 1;
        $currentConsecutive = 1;

        for ($i = 1; $i < $elections->count(); $i++) {
            $prevEnd = Carbon::parse($elections[$i - 1]['ended_at']);
            $currEnd = Carbon::parse($elections[$i]['ended_at']);

            // If elections are within 30 days, consider consecutive
            if ($currEnd->diffInDays($prevEnd) <= 30) {
                $currentConsecutive++;
                $maxConsecutive = max($maxConsecutive, $currentConsecutive);
            } else {
                $currentConsecutive = 1;
            }
        }

        return $maxConsecutive;
    }

    /**
     * Get percentile description.
     * 
     * @param float $percentile
     * @return string
     */
    private function getPercentileDescription(float $percentile): string
    {
        if ($percentile >= 95) return 'Top 5% of active voters';
        if ($percentile >= 90) return 'Top 10% of active voters';
        if ($percentile >= 75) return 'Top 25% of active voters';
        if ($percentile >= 50) return 'Above average voter';
        return 'Active participant';
    }

    /**
     * Get voting statistics for all users (for admin table).
     * 
     * @return array Array of user stats
     */
    public function getAllUsersStats(): array
    {
        $activeStudents = User::whereHas('roles', function ($query) {
            $query->where('name', 'Student');
        })
        ->where('enrollment_status', 'Active')
        ->get();

        $stats = [];

        foreach ($activeStudents as $user) {
            $userStats = $this->calculateUserStats($user);
            
            // Get last vote date
            $lastVote = Vote::where('voter_id', $user->id)
                ->orderBy('voted_at', 'desc')
                ->first();

            $stats[] = [
                'user_id' => $user->id,
                'student_id' => $user->student_id,
                'name' => $user->name,
                'email' => $user->email,
                'elections_voted' => $userStats['elections_voted'],
                'campus_rank' => $userStats['campus_rank'],
                'percentile' => $userStats['percentile'],
                'impact_score' => $userStats['impact_score'],
                'campus_impact_score' => $userStats['campus_impact_score'],
                'last_vote_date' => $lastVote?->voted_at?->format('Y-m-d H:i:s'),
            ];
        }

        // Sort by elections_voted descending
        usort($stats, function ($a, $b) {
            return $b['elections_voted'] <=> $a['elections_voted'];
        });

        return $stats;
    }
}

