# TODO: Analytics API Implementation

> **Status**: Pending Implementation  
> **Priority**: Medium  
> **Related Feature**: Election Results Analytics View (Mobile App)

---

## Overview

The mobile app's Analytics View tab currently uses **mock/dummy data**. This document outlines the API endpoints and database changes needed to provide real analytics data.

---

## Required API Endpoint

### `GET /api/v1/students/elections/{id}/analytics`

Returns comprehensive analytics data for a specific closed election.

#### Response Schema

```json
{
  "success": true,
  "message": "Analytics data retrieved successfully.",
  "data": {
    "turnout": {
      "total_eligible_voters": 2147,
      "total_voted": 1245,
      "did_not_vote": 902,
      "turnout_percentage": 58.0
    },
    "turnout_timeline": [
      { "time": "8 AM", "hour": 8, "votes_this_hour": 120, "cumulative_votes": 120 },
      { "time": "9 AM", "hour": 9, "votes_this_hour": 125, "cumulative_votes": 245 },
      { "time": "10 AM", "hour": 10, "votes_this_hour": 135, "cumulative_votes": 380 },
      { "time": "11 AM", "hour": 11, "votes_this_hour": 140, "cumulative_votes": 520 },
      { "time": "12 PM", "hour": 12, "votes_this_hour": 130, "cumulative_votes": 650 },
      { "time": "1 PM", "hour": 13, "votes_this_hour": 130, "cumulative_votes": 780 },
      { "time": "2 PM", "hour": 14, "votes_this_hour": 110, "cumulative_votes": 890 },
      { "time": "3 PM", "hour": 15, "votes_this_hour": 90, "cumulative_votes": 980 },
      { "time": "4 PM", "hour": 16, "votes_this_hour": 70, "cumulative_votes": 1050 },
      { "time": "5 PM", "hour": 17, "votes_this_hour": 70, "cumulative_votes": 1120 },
      { "time": "6 PM", "hour": 18, "votes_this_hour": 60, "cumulative_votes": 1180 },
      { "time": "7 PM", "hour": 19, "votes_this_hour": 40, "cumulative_votes": 1220 },
      { "time": "8 PM", "hour": 20, "votes_this_hour": 25, "cumulative_votes": 1245 }
    ],
    "demographics": {
      "by_class_year": [
        { "label": "Seniors", "voted": 320, "total": 376, "percentage": 85.1 },
        { "label": "Juniors", "voted": 298, "total": 481, "percentage": 61.9 },
        { "label": "Sophomores", "voted": 245, "total": 544, "percentage": 45.0 },
        { "label": "Freshmen", "voted": 284, "total": 747, "percentage": 38.0 }
      ],
      "by_major": [
        { "label": "Business Administration", "voted": 180, "total": 250, "percentage": 72.0 },
        { "label": "Computer Science", "voted": 220, "total": 320, "percentage": 68.7 },
        { "label": "Biology", "voted": 150, "total": 280, "percentage": 53.6 },
        { "label": "Psychology", "voted": 120, "total": 200, "percentage": 60.0 },
        { "label": "Music", "voted": 95, "total": 150, "percentage": 63.3 }
      ],
      "by_residence": [
        { "label": "On Campus", "voted": 800, "total": 1000, "percentage": 80.0 },
        { "label": "Off Campus", "voted": 445, "total": 1147, "percentage": 38.8 }
      ]
    }
  }
}
```

---

## Database Requirements

### 1. Elections Table Enhancement

Add column to track eligible voters:

```sql
ALTER TABLE elections ADD COLUMN eligible_voters_count INT DEFAULT NULL;
```

Or calculate dynamically based on election eligibility criteria.

### 2. Students Table Requirements

Ensure these demographic columns exist:

```sql
-- If not already present
ALTER TABLE students ADD COLUMN class_year ENUM('Freshman', 'Sophomore', 'Junior', 'Senior') DEFAULT NULL;
ALTER TABLE students ADD COLUMN major VARCHAR(100) DEFAULT NULL;
ALTER TABLE students ADD COLUMN residence_type ENUM('On Campus', 'Off Campus') DEFAULT NULL;
```

### 3. Votes Table Requirements

Ensure `created_at` timestamp exists (Laravel adds this by default):

```sql
-- Should already exist if using Laravel timestamps
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
```

---

## Laravel Implementation

### Route Definition

```php
// routes/api.php
Route::middleware(['auth:sanctum', 'verified'])->group(function () {
    Route::get('/students/elections/{id}/analytics', [ElectionAnalyticsController::class, 'show']);
});
```

### Controller Implementation

```php
<?php

namespace App\Http\Controllers\Api\V1\Student;

use App\Http\Controllers\Controller;
use App\Models\Election;
use App\Models\Vote;
use App\Models\Student;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class ElectionAnalyticsController extends Controller
{
    public function show(int $electionId): JsonResponse
    {
        $election = Election::findOrFail($electionId);
        
        // Ensure election is closed
        if ($election->status !== 'closed') {
            return response()->json([
                'success' => false,
                'message' => 'Analytics are only available for closed elections.',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'message' => 'Analytics data retrieved successfully.',
            'data' => [
                'turnout' => $this->getTurnoutStats($election),
                'turnout_timeline' => $this->getTurnoutTimeline($election),
                'demographics' => $this->getDemographics($election),
            ],
        ]);
    }

    private function getTurnoutStats(Election $election): array
    {
        $totalVoted = Vote::where('election_id', $election->id)
            ->distinct('student_id')
            ->count('student_id');
        
        // Get eligible voters count (implement based on your eligibility logic)
        $totalEligible = $election->eligible_voters_count 
            ?? Student::where('is_active', true)->count();
        
        $didNotVote = $totalEligible - $totalVoted;
        $percentage = $totalEligible > 0 
            ? round(($totalVoted / $totalEligible) * 100, 1) 
            : 0;

        return [
            'total_eligible_voters' => $totalEligible,
            'total_voted' => $totalVoted,
            'did_not_vote' => max(0, $didNotVote),
            'turnout_percentage' => $percentage,
        ];
    }

    private function getTurnoutTimeline(Election $election): array
    {
        $hourlyVotes = Vote::where('election_id', $election->id)
            ->selectRaw('HOUR(created_at) as hour, COUNT(DISTINCT student_id) as votes')
            ->groupBy('hour')
            ->orderBy('hour')
            ->pluck('votes', 'hour')
            ->toArray();

        $timeline = [];
        $cumulative = 0;
        
        // Generate timeline from election start to end (or 8 AM to 8 PM)
        for ($hour = 8; $hour <= 20; $hour++) {
            $votesThisHour = $hourlyVotes[$hour] ?? 0;
            $cumulative += $votesThisHour;
            
            $timeline[] = [
                'time' => $this->formatHour($hour),
                'hour' => $hour,
                'votes_this_hour' => $votesThisHour,
                'cumulative_votes' => $cumulative,
            ];
        }

        return $timeline;
    }

    private function getDemographics(Election $election): array
    {
        return [
            'by_class_year' => $this->getDemographicsByField($election, 'class_year'),
            'by_major' => $this->getDemographicsByField($election, 'major'),
            'by_residence' => $this->getDemographicsByField($election, 'residence_type'),
        ];
    }

    private function getDemographicsByField(Election $election, string $field): array
    {
        // Get voted counts by demographic field
        $voted = Vote::where('votes.election_id', $election->id)
            ->join('students', 'votes.student_id', '=', 'students.id')
            ->whereNotNull("students.{$field}")
            ->selectRaw("students.{$field} as label, COUNT(DISTINCT votes.student_id) as voted")
            ->groupBy("students.{$field}")
            ->pluck('voted', 'label')
            ->toArray();

        // Get total counts by demographic field
        $totals = Student::where('is_active', true)
            ->whereNotNull($field)
            ->selectRaw("{$field} as label, COUNT(*) as total")
            ->groupBy($field)
            ->pluck('total', 'label')
            ->toArray();

        $result = [];
        foreach ($totals as $label => $total) {
            $votedCount = $voted[$label] ?? 0;
            $percentage = $total > 0 ? round(($votedCount / $total) * 100, 1) : 0;
            
            $result[] = [
                'label' => $label,
                'voted' => $votedCount,
                'total' => $total,
                'percentage' => $percentage,
            ];
        }

        // Sort by percentage descending
        usort($result, fn($a, $b) => $b['percentage'] <=> $a['percentage']);

        return $result;
    }

    private function formatHour(int $hour): string
    {
        if ($hour == 0) return '12 AM';
        if ($hour == 12) return '12 PM';
        if ($hour < 12) return $hour . ' AM';
        return ($hour - 12) . ' PM';
    }
}
```

---

## Mobile App Integration

Once the API is implemented, update the mobile app:

### 1. Create Analytics Model

```dart
// lib/features/results/data/models/election_analytics.dart

class ElectionAnalytics {
  final TurnoutStats turnout;
  final List<TimelinePoint> turnoutTimeline;
  final Demographics demographics;

  ElectionAnalytics({
    required this.turnout,
    required this.turnoutTimeline,
    required this.demographics,
  });

  factory ElectionAnalytics.fromJson(Map<String, dynamic> json) {
    return ElectionAnalytics(
      turnout: TurnoutStats.fromJson(json['turnout']),
      turnoutTimeline: (json['turnout_timeline'] as List)
          .map((e) => TimelinePoint.fromJson(e))
          .toList(),
      demographics: Demographics.fromJson(json['demographics']),
    );
  }
}

class TurnoutStats {
  final int totalEligibleVoters;
  final int totalVoted;
  final int didNotVote;
  final double turnoutPercentage;

  TurnoutStats({
    required this.totalEligibleVoters,
    required this.totalVoted,
    required this.didNotVote,
    required this.turnoutPercentage,
  });

  factory TurnoutStats.fromJson(Map<String, dynamic> json) {
    return TurnoutStats(
      totalEligibleVoters: json['total_eligible_voters'],
      totalVoted: json['total_voted'],
      didNotVote: json['did_not_vote'],
      turnoutPercentage: (json['turnout_percentage'] as num).toDouble(),
    );
  }
}

class TimelinePoint {
  final String time;
  final int hour;
  final int votesThisHour;
  final int cumulativeVotes;

  TimelinePoint({
    required this.time,
    required this.hour,
    required this.votesThisHour,
    required this.cumulativeVotes,
  });

  factory TimelinePoint.fromJson(Map<String, dynamic> json) {
    return TimelinePoint(
      time: json['time'],
      hour: json['hour'],
      votesThisHour: json['votes_this_hour'],
      cumulativeVotes: json['cumulative_votes'],
    );
  }
}

class Demographics {
  final List<DemographicItem> byClassYear;
  final List<DemographicItem> byMajor;
  final List<DemographicItem> byResidence;

  Demographics({
    required this.byClassYear,
    required this.byMajor,
    required this.byResidence,
  });

  factory Demographics.fromJson(Map<String, dynamic> json) {
    return Demographics(
      byClassYear: (json['by_class_year'] as List)
          .map((e) => DemographicItem.fromJson(e))
          .toList(),
      byMajor: (json['by_major'] as List)
          .map((e) => DemographicItem.fromJson(e))
          .toList(),
      byResidence: (json['by_residence'] as List)
          .map((e) => DemographicItem.fromJson(e))
          .toList(),
    );
  }
}

class DemographicItem {
  final String label;
  final int voted;
  final int total;
  final double percentage;

  DemographicItem({
    required this.label,
    required this.voted,
    required this.total,
    required this.percentage,
  });

  factory DemographicItem.fromJson(Map<String, dynamic> json) {
    return DemographicItem(
      label: json['label'],
      voted: json['voted'],
      total: json['total'],
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}
```

### 2. Add API Endpoint

```dart
// In lib/core/network/api_endpoints.dart
static String electionAnalytics(String electionId) => 
    '/students/elections/$electionId/analytics';
```

### 3. Update Repository

```dart
// In results_repository.dart
Future<ElectionAnalytics> getElectionAnalytics(int electionId) async {
  final response = await _apiClient.get(
    ApiEndpoints.electionAnalytics(electionId.toString()),
  );
  return ElectionAnalytics.fromJson(response.data['data']);
}
```

---

## Testing Checklist

- [ ] API returns correct turnout stats
- [ ] Timeline data matches actual vote timestamps
- [ ] Demographics breakdown is accurate
- [ ] Handle elections with no votes gracefully
- [ ] Handle students with missing demographic data
- [ ] Performance test with large datasets
- [ ] Mobile app displays real data correctly

---

## Notes

- The Analytics View tab in the mobile app currently shows **mock data**
- Once this API is implemented, update `results_page.dart` to fetch and display real data
- Consider caching analytics data for closed elections (data won't change)
- May want to add admin-only detailed analytics endpoint with more granular data

---

*Created: December 17, 2024*  
*Last Updated: December 17, 2024*
