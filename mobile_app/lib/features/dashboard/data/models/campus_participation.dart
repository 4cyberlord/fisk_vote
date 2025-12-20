/// Campus Participation Model
/// Represents campus-wide voter participation statistics
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
      overall: OverallStats.fromJson(json['overall'] as Map<String, dynamic>),
      byClassYear: (json['by_class_year'] as List<dynamic>)
          .map((e) => ClassYearStats.fromJson(e as Map<String, dynamic>))
          .toList(),
      byElectionType: (json['by_election_type'] as List<dynamic>)
          .map((e) => ElectionTypeStats.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentElections: (json['recent_elections'] as List<dynamic>)
          .map((e) => RecentElection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'academic_year': academicYear,
      'overall': overall.toJson(),
      'by_class_year': byClassYear.map((e) => e.toJson()).toList(),
      'by_election_type': byElectionType.map((e) => e.toJson()).toList(),
      'recent_elections': recentElections.map((e) => e.toJson()).toList(),
    };
  }
}

/// Overall Statistics Model
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
          ? YearComparison.fromJson(
              json['vs_last_year'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_eligible_students': totalEligibleStudents,
      'total_voters': totalVoters,
      'participation_rate': participationRate,
      'trend': trend,
      'trend_direction': trendDirection,
      'vs_last_year': vsLastYear?.toJson(),
    };
  }
}

/// Class Year Statistics Model
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

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'voted': voted,
      'total': total,
      'percentage': percentage,
      'trend': trend,
    };
  }
}

/// Election Type Statistics Model
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

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'voted': voted,
      'total': total,
      'percentage': percentage,
    };
  }
}

/// Recent Election Model
class RecentElection {
  final int electionId;
  final String title;
  final int voted;
  final int totalEligible;
  final double participationRate;
  final String? endedAt;

  RecentElection({
    required this.electionId,
    required this.title,
    required this.voted,
    required this.totalEligible,
    required this.participationRate,
    this.endedAt,
  });

  factory RecentElection.fromJson(Map<String, dynamic> json) {
    return RecentElection(
      electionId: json['election_id'] as int,
      title: json['title'] as String,
      voted: json['voted'] as int,
      totalEligible: json['total_eligible'] as int,
      participationRate: (json['participation_rate'] as num).toDouble(),
      endedAt: json['ended_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'election_id': electionId,
      'title': title,
      'voted': voted,
      'total_eligible': totalEligible,
      'participation_rate': participationRate,
      'ended_at': endedAt,
    };
  }
}

/// Year Comparison Model
class YearComparison {
  final double participationRate;
  final double change;

  YearComparison({required this.participationRate, required this.change});

  factory YearComparison.fromJson(Map<String, dynamic> json) {
    return YearComparison(
      participationRate: (json['participation_rate'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'participation_rate': participationRate, 'change': change};
  }
}
