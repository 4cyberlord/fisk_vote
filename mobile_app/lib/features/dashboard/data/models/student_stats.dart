/// Student Statistics Model
/// Represents comprehensive statistics for the authenticated student
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
      impactScore: ImpactScore.fromJson(
        json['impact_score'] as Map<String, dynamic>,
      ),
      votingHistory: VotingHistory.fromJson(
        json['voting_history'] as Map<String, dynamic>,
      ),
      achievements:
          (json['achievements'] as List<dynamic>?)
              ?.map((e) => Achievement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      trends: Trends.fromJson(json['trends'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'impact_score': impactScore.toJson(),
      'voting_history': votingHistory.toJson(),
      'achievements': achievements.map((e) => e.toJson()).toList(),
      'trends': trends.toJson(),
    };
  }
}

/// Impact Score Model
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

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'percentile': percentile,
      'rank': rank,
      'total_students': totalStudents,
      'description': description,
    };
  }
}

/// Voting History Model
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

  Map<String, dynamic> toJson() {
    return {
      'elections_voted': electionsVoted,
      'total_eligible_elections': totalEligibleElections,
      'participation_rate': participationRate,
      'first_vote_date': firstVoteDate,
      'last_vote_date': lastVoteDate,
    };
  }
}

/// Achievement Model
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'earned_at': earnedAt,
      'is_new': isNew,
    };
  }
}

/// Trends Model
class Trends {
  final SemesterComparison vsLastSemester;

  Trends({required this.vsLastSemester});

  factory Trends.fromJson(Map<String, dynamic> json) {
    return Trends(
      vsLastSemester: SemesterComparison.fromJson(
        json['vs_last_semester'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'vs_last_semester': vsLastSemester.toJson()};
  }
}

/// Semester Comparison Model
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
      participationRateChange: (json['participation_rate_change'] as num)
          .toDouble(),
      impactScoreChange: json['impact_score_change'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'elections_voted_change': electionsVotedChange,
      'participation_rate_change': participationRateChange,
      'impact_score_change': impactScoreChange,
    };
  }
}
