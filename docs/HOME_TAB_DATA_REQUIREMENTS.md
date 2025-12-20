# Home Tab & Election Cards Data Requirements

> **Status**: Analysis Complete  
> **Priority**: High  
> **Related Features**: Home Tab Cards, Election Cards, Per-Election Turnout

---

## Overview

This document outlines the data requirements for all cards displayed in the mobile app:
1. **Impact Score Card** (Home Tab)
2. **2024 Voter Turnout Card** (Home Tab)
3. **Elections Voted Card** (Home Tab)
4. **Per-Election Turnout Card** (NEW - Shows on each election card)

---

## 1. Impact Score Card

### Location
- **Home Tab** → Stats Row (left side)

### Current Display
- Shows: `--` (placeholder)
- Badge: "Coming Soon"

### Data Needed
- **Score**: Integer (0-100+)
- **Percentile**: Float (0-100)
- **Description**: String (e.g., "Top 5% of active voters")
- **Rank**: Integer (optional, for future use)

### API Endpoint
**✅ Already Documented**: `GET /api/v1/students/me/stats`

**Response Path**: `data.impact_score`

```json
{
  "success": true,
  "data": {
    "impact_score": {
      "score": 92,
      "percentile": 5,
      "rank": 12,
      "total_students": 2147,
      "description": "Top 5% of active voters"
    }
  }
}
```

**Status**: ✅ API specification complete in `TODO_STATS_AND_IMPACT_API.md`

---

## 2. 2024 Voter Turnout Card

### Location
- **Home Tab** → Large card below header

### Current Display
- Shows: Mock bar chart with placeholder data
- Overlay: "Coming Soon" badge

### Data Needed
- **Overall Participation Rate**: Float (0-100)
- **Trend**: String (e.g., "+12%")
- **Trend Direction**: "up" | "down" | "stable"
- **By Class Year Breakdown**:
  - Freshmen: percentage
  - Sophomores: percentage
  - Juniors: percentage (highlighted)
  - Seniors: percentage
  - Faculty: percentage

### API Endpoint
**✅ Already Documented**: `GET /api/v1/students/campus-participation`

**Response Path**: `data.overall` and `data.by_class_year`

```json
{
  "success": true,
  "data": {
    "academic_year": "2024-2025",
    "overall": {
      "total_eligible_students": 2147,
      "total_voters": 1245,
      "participation_rate": 58.0,
      "trend": "+12%",
      "trend_direction": "up"
    },
    "by_class_year": [
      {
        "label": "Freshmen",
        "voted": 284,
        "total": 747,
        "percentage": 38.0
      },
      {
        "label": "Sophomores",
        "voted": 245,
        "total": 544,
        "percentage": 45.0
      },
      {
        "label": "Juniors",
        "voted": 298,
        "total": 481,
        "percentage": 61.9
      },
      {
        "label": "Seniors",
        "voted": 320,
        "total": 376,
        "percentage": 85.1
      },
      {
        "label": "Faculty",
        "voted": 98,
        "total": 120,
        "percentage": 81.7
      }
    ]
  }
}
```

**Status**: ✅ API specification complete in `TODO_STATS_AND_IMPACT_API.md`

---

## 3. Elections Voted Card

### Location
- **Home Tab** → Stats Row (right side)

### Current Display
- Shows: Calculated from `activeElections` (e.g., "4/5")
- Progress bar showing participation

### Data Needed
- **Elections Voted**: Integer (count)
- **Total Eligible Elections**: Integer (count)
- **Participation Rate**: Float (0-100)

### API Endpoint
**✅ Already Documented**: `GET /api/v1/students/me/stats`

**Response Path**: `data.voting_history`

```json
{
  "success": true,
  "data": {
    "voting_history": {
      "elections_voted": 4,
      "total_eligible_elections": 5,
      "participation_rate": 80.0,
      "first_vote_date": "2024-09-15",
      "last_vote_date": "2024-12-10"
    }
  }
}
```

**Status**: ✅ API specification complete in `TODO_STATS_AND_IMPACT_API.md`

---

## 4. Per-Election Turnout Card ⭐ NEW

### Location
- **Home Tab** → Active Elections cards
- **Elections Page** → All election cards
- **Results Page** → Archive cards (for closed elections)

### Current Display
- Shows: Hardcoded "82%" participation goal
- Progress bar with mock data

### Data Needed
For **each election**, we need:
- **Total Eligible Voters**: Integer (for this specific election)
- **Total Voted**: Integer (unique voters who voted in this election)
- **Participation Rate**: Float (0-100)
- **Participation Goal**: Integer (optional - target percentage, e.g., 80%)
- **Status**: "active" | "closed" | "upcoming"

### API Endpoint
**❌ NEW ENDPOINT NEEDED**: `GET /api/v1/students/elections/{id}/turnout`

#### Response Schema

```json
{
  "success": true,
  "message": "Election turnout data retrieved successfully.",
  "data": {
    "election_id": 162,
    "election_title": "Student Government Association (SGA) General Elections",
    "status": "active",
    "turnout": {
      "total_eligible_voters": 2147,
      "total_voted": 1245,
      "participation_rate": 58.0,
      "participation_goal": 80.0,
      "votes_remaining": 902,
      "percentage_to_goal": 72.5
    },
    "by_class_year": [
      {
        "label": "Freshmen",
        "voted": 284,
        "total": 747,
        "percentage": 38.0
      },
      {
        "label": "Sophomores",
        "voted": 245,
        "total": 544,
        "percentage": 45.0
      },
      {
        "label": "Juniors",
        "voted": 298,
        "total": 481,
        "percentage": 61.9
      },
      {
        "label": "Seniors",
        "voted": 320,
        "total": 376,
        "percentage": 85.1
      }
    ],
    "updated_at": "2024-12-17T15:30:00Z"
  }
}
```

#### Query Parameters (Optional)
- `include_breakdown`: Boolean (include by_class_year). Default: `false` (for performance)

#### Implementation Notes

**For Active Elections:**
- Data updates in real-time as votes come in
- Cache for 30 seconds to reduce API calls
- Show live participation rate

**For Closed Elections:**
- Data is final (won't change)
- Can be cached longer (1 hour)
- Same data structure, but `status: "closed"`

**For Upcoming Elections:**
- Show `total_eligible_voters` only
- `total_voted: 0`, `participation_rate: 0`
- `status: "upcoming"`

#### Difference from Analytics Endpoint

| Feature | Turnout Endpoint | Analytics Endpoint |
|---------|------------------|-------------------|
| **Purpose** | Quick stats for election cards | Detailed analytics for Analytics View |
| **Data Detail** | Simple (eligible, voted, rate) | Complex (timeline, demographics) |
| **Performance** | Fast, lightweight | More data, slower |
| **Use Case** | Display on cards | Full analytics page |
| **Breakdown** | Optional class year only | Full demographics (class, major, residence) |
| **Timeline** | No | Yes (hourly breakdown) |

---

## API Endpoints Summary

### ✅ Already Documented (Ready to Implement)

1. **`GET /api/v1/students/me/stats`**
   - Provides: Impact Score + Elections Voted
   - Status: Specification complete
   - File: `TODO_STATS_AND_IMPACT_API.md`

2. **`GET /api/v1/students/campus-participation`**
   - Provides: 2024 Voter Turnout data
   - Status: Specification complete
   - File: `TODO_STATS_AND_IMPACT_API.md`

### ❌ NEW Endpoint Needed

3. **`GET /api/v1/students/elections/{id}/turnout`**
   - Provides: Per-election turnout stats
   - Status: **NEEDS IMPLEMENTATION**
   - See implementation details below

---

## Implementation Plan

### Phase 1: Use Existing Endpoints (Impact Score, Campus Participation, Elections Voted)

**Files to Update:**
- `lib/features/dashboard/presentation/pages/tabs/home_tab.dart`
- `lib/features/dashboard/presentation/controllers/home_tab_controller.dart` (if exists)
- Create: `lib/features/dashboard/data/repositories/dashboard_repository.dart`
- Create: `lib/features/dashboard/data/models/campus_participation.dart`
- Create: `lib/features/profile/data/models/student_stats.dart`

**Steps:**
1. Create models for `StudentStats` and `CampusParticipation`
2. Add repository methods to fetch data
3. Update `HomeTabController` to load real data
4. Update UI to display real data instead of placeholders
5. Remove "Coming Soon" overlays

### Phase 2: Implement Per-Election Turnout Endpoint

**Backend Implementation:**

#### Route Definition

```php
// routes/api.php
Route::middleware(['auth:sanctum', 'verified'])->group(function () {
    Route::get('/students/elections/{id}/turnout', [ElectionTurnoutController::class, 'show']);
});
```

#### Controller Implementation

```php
<?php

namespace App\Http\Controllers\Api\V1\Student;

use App\Http\Controllers\Controller;
use App\Models\Election;
use App\Models\Vote;
use App\Models\Student;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class ElectionTurnoutController extends Controller
{
    public function show(int $electionId): JsonResponse
    {
        $election = Election::findOrFail($electionId);
        
        $includeBreakdown = request()->get('include_breakdown', false);
        
        return response()->json([
            'success' => true,
            'message' => 'Election turnout data retrieved successfully.',
            'data' => [
                'election_id' => $election->id,
                'election_title' => $election->title,
                'status' => $election->status, // 'active', 'closed', 'upcoming'
                'turnout' => $this->getTurnoutStats($election),
                'by_class_year' => $includeBreakdown ? $this->getByClassYear($election) : null,
                'updated_at' => now()->toIso8601String(),
            ],
        ]);
    }

    private function getTurnoutStats(Election $election): array
    {
        // Get total eligible voters for this election
        // This could be:
        // 1. Stored in election.eligible_voters_count
        // 2. Calculated from election eligibility criteria
        // 3. Total active students (if all students are eligible)
        
        $totalEligible = $election->eligible_voters_count 
            ?? Student::where('is_active', true)->count();
        
        // Get unique voters for this election
        $totalVoted = Vote::where('election_id', $election->id)
            ->distinct('student_id')
            ->count('student_id');
        
        // Calculate participation rate
        $participationRate = $totalEligible > 0 
            ? round(($totalVoted / $totalEligible) * 100, 1) 
            : 0;
        
        // Participation goal (could be stored in election or default to 80%)
        $participationGoal = $election->participation_goal ?? 80.0;
        
        // Calculate percentage to goal
        $percentageToGoal = $participationGoal > 0 
            ? round(($participationRate / $participationGoal) * 100, 1) 
            : 0;
        
        return [
            'total_eligible_voters' => $totalEligible,
            'total_voted' => $totalVoted,
            'participation_rate' => $participationRate,
            'participation_goal' => $participationGoal,
            'votes_remaining' => max(0, $totalEligible - $totalVoted),
            'percentage_to_goal' => $percentageToGoal,
        ];
    }

    private function getByClassYear(Election $election): array
    {
        $startDate = $election->start_time;
        $endDate = $election->end_time ?? now();
        
        // Get voted counts by class year for this election
        $voted = Vote::where('election_id', $election->id)
            ->join('students', 'votes.student_id', '=', 'students.id')
            ->whereNotNull('students.class_year')
            ->selectRaw('students.class_year as label, COUNT(DISTINCT votes.student_id) as voted')
            ->groupBy('students.class_year')
            ->pluck('voted', 'label')
            ->toArray();
        
        // Get total eligible by class year
        // This should match the election's eligibility criteria
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
}
```

#### Database Requirements

```sql
-- Add participation goal to elections table (optional)
ALTER TABLE elections ADD COLUMN participation_goal DECIMAL(5,2) DEFAULT 80.0;

-- Add eligible voters count (if not calculating dynamically)
ALTER TABLE elections ADD COLUMN eligible_voters_count INT DEFAULT NULL;

-- Index for performance
CREATE INDEX idx_votes_election_student ON votes(election_id, student_id);
```

### Phase 3: Mobile App Integration

**Files to Create/Update:**

1. **Model**: `lib/features/elections/data/models/election_turnout.dart`

```dart
class ElectionTurnout {
  final int electionId;
  final String electionTitle;
  final String status;
  final TurnoutStats turnout;
  final List<ClassYearStats>? byClassYear;
  final String updatedAt;

  ElectionTurnout({
    required this.electionId,
    required this.electionTitle,
    required this.status,
    required this.turnout,
    this.byClassYear,
    required this.updatedAt,
  });

  factory ElectionTurnout.fromJson(Map<String, dynamic> json) {
    return ElectionTurnout(
      electionId: json['election_id'] as int,
      electionTitle: json['election_title'] as String,
      status: json['status'] as String,
      turnout: TurnoutStats.fromJson(json['turnout']),
      byClassYear: json['by_class_year'] != null
          ? (json['by_class_year'] as List)
              .map((e) => ClassYearStats.fromJson(e))
              .toList()
          : null,
      updatedAt: json['updated_at'] as String,
    );
  }
}

class TurnoutStats {
  final int totalEligibleVoters;
  final int totalVoted;
  final double participationRate;
  final double participationGoal;
  final int votesRemaining;
  final double percentageToGoal;

  TurnoutStats({
    required this.totalEligibleVoters,
    required this.totalVoted,
    required this.participationRate,
    required this.participationGoal,
    required this.votesRemaining,
    required this.percentageToGoal,
  });

  factory TurnoutStats.fromJson(Map<String, dynamic> json) {
    return TurnoutStats(
      totalEligibleVoters: json['total_eligible_voters'] as int,
      totalVoted: json['total_voted'] as int,
      participationRate: (json['participation_rate'] as num).toDouble(),
      participationGoal: (json['participation_goal'] as num).toDouble(),
      votesRemaining: json['votes_remaining'] as int,
      percentageToGoal: (json['percentage_to_goal'] as num).toDouble(),
    );
  }
}

class ClassYearStats {
  final String label;
  final int voted;
  final int total;
  final double percentage;

  ClassYearStats({
    required this.label,
    required this.voted,
    required this.total,
    required this.percentage,
  });

  factory ClassYearStats.fromJson(Map<String, dynamic> json) {
    return ClassYearStats(
      label: json['label'] as String,
      voted: json['voted'] as int,
      total: json['total'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}
```

2. **Repository Method**: Add to `lib/features/elections/data/repositories/election_repository.dart`

```dart
Future<ElectionTurnout> getElectionTurnout(int electionId, {bool includeBreakdown = false}) async {
  try {
    final params = includeBreakdown ? {'include_breakdown': 'true'} : null;
    final response = await _apiClient.get(
      ApiEndpoints.electionTurnout(electionId.toString()),
      queryParameters: params,
    );
    final responseData = response.data as Map<String, dynamic>;
    return ElectionTurnout.fromJson(responseData['data']);
  } on ApiException {
    rethrow;
  } catch (e) {
    throw UnknownException(message: e.toString());
  }
}
```

3. **API Endpoint**: Add to `lib/core/network/api_endpoints.dart`

```dart
/// Get turnout stats for a specific election
static String electionTurnout(String electionId) =>
    '/students/elections/$electionId/turnout';
```

4. **Update Election Model**: Add optional `turnout` field

```dart
// In lib/features/elections/data/models/election.dart
final ElectionTurnout? turnout; // Optional, loaded separately
```

5. **Update UI Components**:
   - `home_tab.dart` → `_buildActiveElectionCard()` - Load and display turnout
   - `elections_page.dart` → `_buildElectionCard()` - Load and display turnout
   - `results_page.dart` → `_buildArchiveCard()` - Load and display turnout (for closed elections)

---

## Caching Strategy

### Impact Score & Campus Participation
- **Cache Duration**: 5 minutes
- **Invalidation**: When student votes, or daily refresh

### Per-Election Turnout
- **Active Elections**: Cache 30 seconds (real-time updates)
- **Closed Elections**: Cache 1 hour (data won't change)
- **Upcoming Elections**: Cache 5 minutes (eligible voters might change)

---

## Performance Considerations

1. **Batch Loading**: Load turnout for multiple elections in one request (if needed)
2. **Lazy Loading**: Only load turnout when election card is visible
3. **Pagination**: For elections list, load turnout on-demand
4. **Background Refresh**: Refresh turnout data in background every 30 seconds for active elections

---

## Testing Checklist

- [ ] Impact Score displays correctly from API
- [ ] Campus Participation displays correctly from API
- [ ] Elections Voted count is accurate
- [ ] Per-election turnout displays on active election cards
- [ ] Per-election turnout displays on closed election cards
- [ ] Turnout updates in real-time for active elections
- [ ] Caching works correctly
- [ ] Error handling for missing data
- [ ] Performance is acceptable with many elections

---

## Summary

### ✅ Ready to Implement (API Specs Complete)
1. Impact Score Card → `GET /api/v1/students/me/stats`
2. 2024 Voter Turnout Card → `GET /api/v1/students/campus-participation`
3. Elections Voted Card → `GET /api/v1/students/me/stats`

### ❌ New API Endpoint Needed
4. Per-Election Turnout Card → `GET /api/v1/students/elections/{id}/turnout` ⭐

**Next Steps:**
1. Implement backend endpoint for per-election turnout
2. Create mobile app models and repository methods
3. Update UI to fetch and display real data
4. Test all cards with real API data

---

*Created: December 17, 2024*  
*Last Updated: December 17, 2024*
