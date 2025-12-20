# TODO: Student Stats & Impact Score API Implementation

> **Status**: Pending Implementation  
> **Priority**: High  
> **Related Features**: Home Tab (Impact Score, Campus Participation), Analytics

---

## Overview

The mobile app's Home tab currently shows **mock/placeholder data** for:
- **Impact Score**: Individual student voting engagement metric
- **2024 Voter Turnout**: Campus-wide participation statistics
- **Elections Voted**: Count of elections the student has participated in

This document outlines the API endpoints needed to provide real data for these features.

---

## Required API Endpoints

### 1. `GET /api/v1/students/me/stats`

Returns comprehensive statistics for the authenticated student, including Impact Score and voting history.

#### Response Schema

```json
{
  "success": true,
  "message": "Student statistics retrieved successfully.",
  "data": {
    "impact_score": {
      "score": 92,
      "percentile": 5,
      "rank": 12,
      "total_students": 2147,
      "description": "Top 5% of active voters"
    },
    "voting_history": {
      "elections_voted": 4,
      "total_eligible_elections": 5,
      "participation_rate": 80.0,
      "first_vote_date": "2024-09-15",
      "last_vote_date": "2024-12-10"
    },
    "achievements": [
      {
        "id": 1,
        "title": "First Vote",
        "description": "Cast your first vote",
        "icon": "vote",
        "earned_at": "2024-09-15T10:30:00Z",
        "is_new": false
      },
      {
        "id": 2,
        "title": "Active Voter",
        "description": "Voted in 3+ elections",
        "icon": "star",
        "earned_at": "2024-11-20T14:15:00Z",
        "is_new": false
      }
    ],
    "trends": {
      "vs_last_semester": {
        "elections_voted_change": 2,
        "participation_rate_change": 15.5,
        "impact_score_change": 8
      }
    }
  }
}
```

#### Implementation Notes

**Impact Score Calculation:**
- Base score: 50 points
- +10 points per election voted in
- +5 points for voting early (within first 24 hours)
- +3 points for voting in all eligible elections
- +2 points per consecutive election voted
- Bonus multipliers for special elections (SGA, etc.)

**Percentile Calculation:**
- Compare student's score against all active students
- Calculate percentile rank (e.g., top 5% = 95th percentile)

---

### 2. `GET /api/v1/students/campus-participation`

Returns campus-wide voter participation statistics for the current academic year.

#### Response Schema

```json
{
  "success": true,
  "message": "Campus participation data retrieved successfully.",
  "data": {
    "academic_year": "2024-2025",
    "overall": {
      "total_eligible_students": 2147,
      "total_voters": 1245,
      "participation_rate": 58.0,
      "trend": "+12%",
      "trend_direction": "up",
      "vs_last_year": {
        "participation_rate": 46.0,
        "change": 12.0
      }
    },
    "by_class_year": [
      {
        "label": "Freshmen",
        "voted": 284,
        "total": 747,
        "percentage": 38.0,
        "trend": "+5%"
      },
      {
        "label": "Sophomores",
        "voted": 245,
        "total": 544,
        "percentage": 45.0,
        "trend": "+8%"
      },
      {
        "label": "Juniors",
        "voted": 298,
        "total": 481,
        "percentage": 61.9,
        "trend": "+3%"
      },
      {
        "label": "Seniors",
        "voted": 320,
        "total": 376,
        "percentage": 85.1,
        "trend": "+2%"
      },
      {
        "label": "Faculty",
        "voted": 98,
        "total": 120,
        "percentage": 81.7,
        "trend": "+1%"
      }
    ],
    "by_election_type": [
      {
        "type": "SGA",
        "voted": 850,
        "total": 2147,
        "percentage": 39.6
      },
      {
        "type": "Class Council",
        "voted": 620,
        "total": 2147,
        "percentage": 28.9
      },
      {
        "type": "Referendum",
        "voted": 1100,
        "total": 2147,
        "percentage": 51.2
      }
    ],
    "recent_elections": [
      {
        "election_id": 162,
        "title": "SGA General Elections",
        "voted": 850,
        "total_eligible": 2147,
        "participation_rate": 39.6,
        "ended_at": "2024-12-15T23:59:59Z"
      }
    ]
  }
}
```

#### Query Parameters (Optional)

- `year`: Academic year (e.g., "2024-2025"). Defaults to current year.
- `include_trends`: Boolean, include trend comparisons. Default: true.

---

## Database Requirements

### 1. Students Table Enhancements

Ensure these columns exist for Impact Score calculation:

```sql
-- Voting history tracking
ALTER TABLE students ADD COLUMN first_vote_date DATE DEFAULT NULL;
ALTER TABLE students ADD COLUMN last_vote_date DATE DEFAULT NULL;
ALTER TABLE students ADD COLUMN total_elections_voted INT DEFAULT 0;
ALTER TABLE students ADD COLUMN impact_score INT DEFAULT 50;
ALTER TABLE students ADD COLUMN impact_score_updated_at TIMESTAMP DEFAULT NULL;

-- Demographic data (if not already present)
ALTER TABLE students ADD COLUMN class_year ENUM('Freshman', 'Sophomore', 'Junior', 'Senior', 'Graduate') DEFAULT NULL;
ALTER TABLE students ADD COLUMN major VARCHAR(100) DEFAULT NULL;
ALTER TABLE students ADD COLUMN residence_type ENUM('On Campus', 'Off Campus') DEFAULT NULL;
```

### 2. Votes Table Requirements

Ensure proper indexing for performance:

```sql
-- Indexes for efficient queries
CREATE INDEX idx_votes_student_election ON votes(student_id, election_id);
CREATE INDEX idx_votes_created_at ON votes(created_at);
CREATE INDEX idx_votes_election_created ON votes(election_id, created_at);
```

### 3. Elections Table Requirements

```sql
-- Track eligible voters per election
ALTER TABLE elections ADD COLUMN eligible_voters_count INT DEFAULT NULL;
ALTER TABLE elections ADD COLUMN academic_year VARCHAR(9) DEFAULT NULL; -- e.g., "2024-2025"
```

### 4. Create Impact Score Calculation Table (Optional)

For caching and performance:

```sql
CREATE TABLE student_impact_scores (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT UNSIGNED NOT NULL,
    score INT NOT NULL DEFAULT 50,
    percentile DECIMAL(5,2) NOT NULL,
    rank INT NOT NULL,
    total_students INT NOT NULL,
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    UNIQUE KEY unique_student_score (student_id),
    INDEX idx_score_percentile (score, percentile)
) ENGINE=InnoDB;
```

---

## Laravel Implementation

### Route Definitions

```php
// routes/api.php
Route::middleware(['auth:sanctum', 'verified'])->group(function () {
    // Student stats endpoint
    Route::get('/students/me/stats', [StudentStatsController::class, 'show']);
    
    // Campus participation (public or authenticated)
    Route::get('/students/campus-participation', [CampusParticipationController::class, 'index']);
});
```

### Controller: StudentStatsController

```php
<?php

namespace App\Http\Controllers\Api\V1\Student;

use App\Http\Controllers\Controller;
use App\Models\Student;
use App\Models\Vote;
use App\Models\Election;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class StudentStatsController extends Controller
{
    public function show(): JsonResponse
    {
        $student = auth()->user();
        
        return response()->json([
            'success' => true,
            'message' => 'Student statistics retrieved successfully.',
            'data' => [
                'impact_score' => $this->calculateImpactScore($student),
                'voting_history' => $this->getVotingHistory($student),
                'achievements' => $this->getAchievements($student),
                'trends' => $this->getTrends($student),
            ],
        ]);
    }

    private function calculateImpactScore(Student $student): array
    {
        // Get or calculate impact score
        $score = $this->computeImpactScore($student);
        
        // Calculate percentile
        $percentile = $this->calculatePercentile($score);
        
        // Get rank
        $rank = $this->getStudentRank($student, $score);
        
        // Total active students
        $totalStudents = Student::where('is_active', true)->count();
        
        // Description based on percentile
        $description = $this->getPercentileDescription($percentile);
        
        return [
            'score' => $score,
            'percentile' => $percentile,
            'rank' => $rank,
            'total_students' => $totalStudents,
            'description' => $description,
        ];
    }

    private function computeImpactScore(Student $student): int
    {
        $baseScore = 50;
        
        // Get voting history
        $votes = Vote::where('student_id', $student->id)
            ->with('election')
            ->orderBy('created_at')
            ->get();
        
        $electionsVoted = $votes->pluck('election_id')->unique()->count();
        
        // Base points: +10 per election
        $score = $baseScore + ($electionsVoted * 10);
        
        // Early voting bonus: +5 points per early vote
        $earlyVotes = $votes->filter(function ($vote) {
            $electionStart = Carbon::parse($vote->election->start_time);
            $voteTime = Carbon::parse($vote->created_at);
            return $voteTime->diffInHours($electionStart) <= 24;
        })->count();
        $score += $earlyVotes * 5;
        
        // Perfect participation bonus: +3 points if voted in all eligible
        $totalEligible = Election::where('status', 'closed')
            ->where('end_time', '<=', now())
            ->count();
        if ($electionsVoted == $totalEligible && $totalEligible > 0) {
            $score += 3;
        }
        
        // Consecutive voting bonus: +2 points per consecutive election
        $consecutive = $this->calculateConsecutiveElections($votes);
        $score += $consecutive * 2;
        
        // Special election bonus (SGA, etc.)
        $specialElections = $votes->filter(function ($vote) {
            return str_contains(strtolower($vote->election->title), 'sga') ||
                   str_contains(strtolower($vote->election->title), 'general');
        })->count();
        $score += $specialElections * 3;
        
        // Update student's score
        $student->update([
            'impact_score' => $score,
            'impact_score_updated_at' => now(),
        ]);
        
        return $score;
    }

    private function calculatePercentile(int $score): float
    {
        $totalStudents = Student::where('is_active', true)->count();
        $studentsWithLowerScore = Student::where('is_active', true)
            ->where('impact_score', '<', $score)
            ->count();
        
        return round(($studentsWithLowerScore / $totalStudents) * 100, 1);
    }

    private function getStudentRank(Student $student, int $score): int
    {
        return Student::where('is_active', true)
            ->where('impact_score', '>', $score)
            ->count() + 1;
    }

    private function getPercentileDescription(float $percentile): string
    {
        if ($percentile >= 95) return 'Top 5% of active voters';
        if ($percentile >= 90) return 'Top 10% of active voters';
        if ($percentile >= 75) return 'Top 25% of active voters';
        if ($percentile >= 50) return 'Above average voter';
        return 'Active participant';
    }

    private function calculateConsecutiveElections($votes): int
    {
        if ($votes->isEmpty()) return 0;
        
        $elections = $votes->map(function ($vote) {
            return [
                'id' => $vote->election_id,
                'ended_at' => $vote->election->end_time,
            ];
        })->sortBy('ended_at')->values();
        
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

    private function getVotingHistory(Student $student): array
    {
        $votes = Vote::where('student_id', $student->id)
            ->with('election')
            ->get();
        
        $electionsVoted = $votes->pluck('election_id')->unique()->count();
        $totalEligible = Election::where('status', 'closed')
            ->where('end_time', '<=', now())
            ->count();
        
        $participationRate = $totalEligible > 0 
            ? round(($electionsVoted / $totalEligible) * 100, 1) 
            : 0;
        
        $firstVote = $votes->min('created_at');
        $lastVote = $votes->max('created_at');
        
        return [
            'elections_voted' => $electionsVoted,
            'total_eligible_elections' => $totalEligible,
            'participation_rate' => $participationRate,
            'first_vote_date' => $firstVote ? Carbon::parse($firstVote)->format('Y-m-d') : null,
            'last_vote_date' => $lastVote ? Carbon::parse($lastVote)->format('Y-m-d') : null,
        ];
    }

    private function getAchievements(Student $student): array
    {
        // Implementation depends on your achievements system
        // This is a placeholder
        return [];
    }

    private function getTrends(Student $student): array
    {
        // Compare current semester to last semester
        $currentSemester = $this->getCurrentSemester();
        $lastSemester = $this->getLastSemester();
        
        $currentStats = $this->getSemesterStats($student, $currentSemester);
        $lastStats = $this->getSemesterStats($student, $lastSemester);
        
        return [
            'vs_last_semester' => [
                'elections_voted_change' => $currentStats['elections_voted'] - $lastStats['elections_voted'],
                'participation_rate_change' => $currentStats['participation_rate'] - $lastStats['participation_rate'],
                'impact_score_change' => $currentStats['impact_score'] - $lastStats['impact_score'],
            ],
        ];
    }

    private function getCurrentSemester(): string
    {
        $month = now()->month;
        return $month >= 9 ? 'Fall' : ($month >= 5 ? 'Summer' : 'Spring');
    }

    private function getLastSemester(): string
    {
        $month = now()->subMonths(4)->month;
        return $month >= 9 ? 'Fall' : ($month >= 5 ? 'Summer' : 'Spring');
    }

    private function getSemesterStats(Student $student, string $semester): array
    {
        // Implementation to get stats for specific semester
        return [
            'elections_voted' => 0,
            'participation_rate' => 0.0,
            'impact_score' => 50,
        ];
    }
}
```

### Controller: CampusParticipationController

```php
<?php

namespace App\Http\Controllers\Api\V1\Student;

use App\Http\Controllers\Controller;
use App\Models\Student;
use App\Models\Vote;
use App\Models\Election;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class CampusParticipationController extends Controller
{
    public function index(): JsonResponse
    {
        $year = request()->get('year', $this->getCurrentAcademicYear());
        $includeTrends = request()->get('include_trends', true);
        
        return response()->json([
            'success' => true,
            'message' => 'Campus participation data retrieved successfully.',
            'data' => [
                'academic_year' => $year,
                'overall' => $this->getOverallStats($year, $includeTrends),
                'by_class_year' => $this->getByClassYear($year),
                'by_election_type' => $this->getByElectionType($year),
                'recent_elections' => $this->getRecentElections($year),
            ],
        ]);
    }

    private function getOverallStats(string $year, bool $includeTrends): array
    {
        $totalEligible = Student::where('is_active', true)->count();
        
        // Get unique voters for the academic year
        $startDate = $this->getAcademicYearStart($year);
        $endDate = $this->getAcademicYearEnd($year);
        
        $totalVoters = Vote::whereBetween('created_at', [$startDate, $endDate])
            ->distinct('student_id')
            ->count('student_id');
        
        $participationRate = $totalEligible > 0 
            ? round(($totalVoters / $totalEligible) * 100, 1) 
            : 0;
        
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

    private function getByClassYear(string $year): array
    {
        $startDate = $this->getAcademicYearStart($year);
        $endDate = $this->getAcademicYearEnd($year);
        
        // Get voted counts by class year
        $voted = Vote::whereBetween('votes.created_at', [$startDate, $endDate])
            ->join('students', 'votes.student_id', '=', 'students.id')
            ->whereNotNull('students.class_year')
            ->selectRaw('students.class_year as label, COUNT(DISTINCT votes.student_id) as voted')
            ->groupBy('students.class_year')
            ->pluck('voted', 'label')
            ->toArray();
        
        // Get total counts by class year
        $totals = Student::where('is_active', true)
            ->whereNotNull('class_year')
            ->selectRaw('class_year as label, COUNT(*) as total')
            ->groupBy('class_year')
            ->pluck('total', 'label')
            ->toArray();
        
        $result = [];
        foreach ($totals as $label => $total) {
            $votedCount = $voted[$label] ?? 0;
            $percentage = $total > 0 ? round(($votedCount / $total) * 100, 1) : 0;
            
            // Calculate trend (simplified - compare to last year)
            $trend = $this->calculateClassYearTrend($label, $year);
            
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

    private function getByElectionType(string $year): array
    {
        $startDate = $this->getAcademicYearStart($year);
        $endDate = $this->getAcademicYearEnd($year);
        
        $totalEligible = Student::where('is_active', true)->count();
        
        $elections = Election::whereBetween('start_time', [$startDate, $endDate])
            ->where('status', 'closed')
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
                ->distinct('student_id')
                ->count('student_id');
            
            $result[$type]['voted'] += $voted;
        }
        
        // Calculate percentages
        foreach ($result as &$item) {
            $item['percentage'] = $item['total'] > 0 
                ? round(($item['voted'] / $item['total']) * 100, 1) 
                : 0;
        }
        
        return array_values($result);
    }

    private function getRecentElections(string $year, int $limit = 5): array
    {
        $startDate = $this->getAcademicYearStart($year);
        $endDate = $this->getAcademicYearEnd($year);
        
        $elections = Election::whereBetween('start_time', [$startDate, $endDate])
            ->where('status', 'closed')
            ->orderBy('end_time', 'desc')
            ->limit($limit)
            ->get();
        
        $totalEligible = Student::where('is_active', true)->count();
        
        return $elections->map(function ($election) use ($totalEligible) {
            $voted = Vote::where('election_id', $election->id)
                ->distinct('student_id')
                ->count('student_id');
            
            return [
                'election_id' => $election->id,
                'title' => $election->title,
                'voted' => $voted,
                'total_eligible' => $totalEligible,
                'participation_rate' => $totalEligible > 0 
                    ? round(($voted / $totalEligible) * 100, 1) 
                    : 0,
                'ended_at' => $election->end_time,
            ];
        })->toArray();
    }

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

    private function getAcademicYearStart(string $year): Carbon
    {
        [$startYear] = explode('-', $year);
        return Carbon::create($startYear, 9, 1)->startOfDay();
    }

    private function getAcademicYearEnd(string $year): Carbon
    {
        [, $endYear] = explode('-', $year);
        return Carbon::create($endYear, 8, 31)->endOfDay();
    }

    private function getPreviousAcademicYear(string $year): string
    {
        [$startYear, $endYear] = explode('-', $year);
        return ($startYear - 1) . '-' . ($endYear - 1);
    }

    private function calculateClassYearTrend(string $classYear, string $year): string
    {
        // Simplified - compare to last year
        $lastYear = $this->getPreviousAcademicYear($year);
        $currentStats = $this->getClassYearStats($classYear, $year);
        $lastStats = $this->getClassYearStats($classYear, $lastYear);
        
        $change = $currentStats['percentage'] - $lastStats['percentage'];
        return ($change > 0 ? '+' : '') . number_format($change, 1) . '%';
    }

    private function getClassYearStats(string $classYear, string $year): array
    {
        $startDate = $this->getAcademicYearStart($year);
        $endDate = $this->getAcademicYearEnd($year);
        
        $voted = Vote::whereBetween('votes.created_at', [$startDate, $endDate])
            ->join('students', 'votes.student_id', '=', 'students.id')
            ->where('students.class_year', $classYear)
            ->distinct('votes.student_id')
            ->count('votes.student_id');
        
        $total = Student::where('is_active', true)
            ->where('class_year', $classYear)
            ->count();
        
        return [
            'voted' => $voted,
            'total' => $total,
            'percentage' => $total > 0 ? round(($voted / $total) * 100, 1) : 0,
        ];
    }

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
```

---

## Mobile App Integration

### 1. Create Models

```dart
// lib/features/profile/data/models/student_stats.dart

class StudentStats {
  final ImpactScore impactScore;
  final VotingHistory votingHistory;
  final List<Achievement> achievements;
  final Trends trends;

  StudentStats({
    required this.impactScore,
    required this.votingHistory,
    required this.achievements,
    required this.trends,
  });

  factory StudentStats.fromJson(Map<String, dynamic> json) {
    return StudentStats(
      impactScore: ImpactScore.fromJson(json['impact_score']),
      votingHistory: VotingHistory.fromJson(json['voting_history']),
      achievements: (json['achievements'] as List?)
          ?.map((e) => Achievement.fromJson(e))
          .toList() ?? [],
      trends: Trends.fromJson(json['trends']),
    );
  }
}

class ImpactScore {
  final int score;
  final double percentile;
  final int rank;
  final int totalStudents;
  final String description;

  ImpactScore({
    required this.score,
    required this.percentile,
    required this.rank,
    required this.totalStudents,
    required this.description,
  });

  factory ImpactScore.fromJson(Map<String, dynamic> json) {
    return ImpactScore(
      score: json['score'] as int,
      percentile: (json['percentile'] as num).toDouble(),
      rank: json['rank'] as int,
      totalStudents: json['total_students'] as int,
      description: json['description'] as String,
    );
  }
}

class VotingHistory {
  final int electionsVoted;
  final int totalEligibleElections;
  final double participationRate;
  final String? firstVoteDate;
  final String? lastVoteDate;

  VotingHistory({
    required this.electionsVoted,
    required this.totalEligibleElections,
    required this.participationRate,
    this.firstVoteDate,
    this.lastVoteDate,
  });

  factory VotingHistory.fromJson(Map<String, dynamic> json) {
    return VotingHistory(
      electionsVoted: json['elections_voted'] as int,
      totalEligibleElections: json['total_eligible_elections'] as int,
      participationRate: (json['participation_rate'] as num).toDouble(),
      firstVoteDate: json['first_vote_date'] as String?,
      lastVoteDate: json['last_vote_date'] as String?,
    );
  }
}

class Achievement {
  final int id;
  final String title;
  final String description;
  final String icon;
  final String earnedAt;
  final bool isNew;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.earnedAt,
    required this.isNew,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      earnedAt: json['earned_at'] as String,
      isNew: json['is_new'] as bool,
    );
  }
}

class Trends {
  final SemesterComparison vsLastSemester;

  Trends({required this.vsLastSemester});

  factory Trends.fromJson(Map<String, dynamic> json) {
    return Trends(
      vsLastSemester: SemesterComparison.fromJson(json['vs_last_semester']),
    );
  }
}

class SemesterComparison {
  final int electionsVotedChange;
  final double participationRateChange;
  final int impactScoreChange;

  SemesterComparison({
    required this.electionsVotedChange,
    required this.participationRateChange,
    required this.impactScoreChange,
  });

  factory SemesterComparison.fromJson(Map<String, dynamic> json) {
    return SemesterComparison(
      electionsVotedChange: json['elections_voted_change'] as int,
      participationRateChange: (json['participation_rate_change'] as num).toDouble(),
      impactScoreChange: json['impact_score_change'] as int,
    );
  }
}
```

### 2. Campus Participation Model

```dart
// lib/features/dashboard/data/models/campus_participation.dart

class CampusParticipation {
  final String academicYear;
  final OverallStats overall;
  final List<ClassYearStats> byClassYear;
  final List<ElectionTypeStats> byElectionType;
  final List<RecentElection> recentElections;

  CampusParticipation({
    required this.academicYear,
    required this.overall,
    required this.byClassYear,
    required this.byElectionType,
    required this.recentElections,
  });

  factory CampusParticipation.fromJson(Map<String, dynamic> json) {
    return CampusParticipation(
      academicYear: json['academic_year'] as String,
      overall: OverallStats.fromJson(json['overall']),
      byClassYear: (json['by_class_year'] as List)
          .map((e) => ClassYearStats.fromJson(e))
          .toList(),
      byElectionType: (json['by_election_type'] as List)
          .map((e) => ElectionTypeStats.fromJson(e))
          .toList(),
      recentElections: (json['recent_elections'] as List)
          .map((e) => RecentElection.fromJson(e))
          .toList(),
    );
  }
}

class OverallStats {
  final int totalEligibleStudents;
  final int totalVoters;
  final double participationRate;
  final String? trend;
  final String? trendDirection;
  final YearComparison? vsLastYear;

  OverallStats({
    required this.totalEligibleStudents,
    required this.totalVoters,
    required this.participationRate,
    this.trend,
    this.trendDirection,
    this.vsLastYear,
  });

  factory OverallStats.fromJson(Map<String, dynamic> json) {
    return OverallStats(
      totalEligibleStudents: json['total_eligible_students'] as int,
      totalVoters: json['total_voters'] as int,
      participationRate: (json['participation_rate'] as num).toDouble(),
      trend: json['trend'] as String?,
      trendDirection: json['trend_direction'] as String?,
      vsLastYear: json['vs_last_year'] != null
          ? YearComparison.fromJson(json['vs_last_year'])
          : null,
    );
  }
}

class ClassYearStats {
  final String label;
  final int voted;
  final int total;
  final double percentage;
  final String? trend;

  ClassYearStats({
    required this.label,
    required this.voted,
    required this.total,
    required this.percentage,
    this.trend,
  });

  factory ClassYearStats.fromJson(Map<String, dynamic> json) {
    return ClassYearStats(
      label: json['label'] as String,
      voted: json['voted'] as int,
      total: json['total'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      trend: json['trend'] as String?,
    );
  }
}

class ElectionTypeStats {
  final String type;
  final int voted;
  final int total;
  final double percentage;

  ElectionTypeStats({
    required this.type,
    required this.voted,
    required this.total,
    required this.percentage,
  });

  factory ElectionTypeStats.fromJson(Map<String, dynamic> json) {
    return ElectionTypeStats(
      type: json['type'] as String,
      voted: json['voted'] as int,
      total: json['total'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class RecentElection {
  final int electionId;
  final String title;
  final int voted;
  final int totalEligible;
  final double participationRate;
  final String endedAt;

  RecentElection({
    required this.electionId,
    required this.title,
    required this.voted,
    required this.totalEligible,
    required this.participationRate,
    required this.endedAt,
  });

  factory RecentElection.fromJson(Map<String, dynamic> json) {
    return RecentElection(
      electionId: json['election_id'] as int,
      title: json['title'] as String,
      voted: json['voted'] as int,
      totalEligible: json['total_eligible'] as int,
      participationRate: (json['participation_rate'] as num).toDouble(),
      endedAt: json['ended_at'] as String,
    );
  }
}

class YearComparison {
  final double participationRate;
  final double change;

  YearComparison({
    required this.participationRate,
    required this.change,
  });

  factory YearComparison.fromJson(Map<String, dynamic> json) {
    return YearComparison(
      participationRate: (json['participation_rate'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
    );
  }
}
```

### 3. Add API Endpoints

```dart
// lib/core/network/api_endpoints.dart

// Student stats
static const String studentStats = '/students/me/stats';

// Campus participation
static String campusParticipation({String? year}) {
  if (year != null) {
    return '/students/campus-participation?year=$year';
  }
  return '/students/campus-participation';
}
```

### 4. Update Repositories

```dart
// lib/features/profile/data/repositories/profile_repository.dart

Future<StudentStats> getStudentStats() async {
  final response = await _apiClient.get(ApiEndpoints.studentStats);
  return StudentStats.fromJson(response.data['data']);
}
```

```dart
// lib/features/dashboard/data/repositories/dashboard_repository.dart (new file)

Future<CampusParticipation> getCampusParticipation({String? year}) async {
  final response = await _apiClient.get(
    ApiEndpoints.campusParticipation(year: year),
  );
  return CampusParticipation.fromJson(response.data['data']);
}
```

---

## Testing Checklist

- [ ] Impact Score calculation is accurate
- [ ] Percentile ranking is correct
- [ ] Campus participation stats match actual data
- [ ] Trends are calculated correctly
- [ ] Performance is acceptable with large datasets
- [ ] Mobile app displays all data correctly
- [ ] Handle edge cases (no votes, new students, etc.)

---

## Performance Considerations

1. **Caching**: Cache Impact Scores and campus stats (recalculate daily or on-demand)
2. **Indexing**: Ensure proper database indexes on frequently queried columns
3. **Background Jobs**: Use Laravel queues to recalculate Impact Scores periodically
4. **Pagination**: For large datasets, consider pagination for recent elections list

---

## Notes

- Impact Score should be recalculated when:
  - A student votes
  - An election closes
  - Daily batch job (optional)
- Campus participation data can be cached for 1 hour (data changes slowly)
- Consider adding admin endpoints for detailed analytics

---

*Created: December 17, 2024*  
*Last Updated: December 17, 2024*
