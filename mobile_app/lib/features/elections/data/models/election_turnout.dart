/// Election Turnout Model
/// Represents turnout statistics for a specific election
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
      turnout: TurnoutStats.fromJson(json['turnout'] as Map<String, dynamic>),
      byClassYear: json['by_class_year'] != null
          ? (json['by_class_year'] as List<dynamic>)
                .map((e) => ClassYearStats.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'election_id': electionId,
      'election_title': electionTitle,
      'status': status,
      'turnout': turnout.toJson(),
      'by_class_year': byClassYear?.map((e) => e.toJson()).toList(),
      'updated_at': updatedAt,
    };
  }
}

/// Turnout Statistics
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

  Map<String, dynamic> toJson() {
    return {
      'total_eligible_voters': totalEligibleVoters,
      'total_voted': totalVoted,
      'participation_rate': participationRate,
      'participation_goal': participationGoal,
      'votes_remaining': votesRemaining,
      'percentage_to_goal': percentageToGoal,
    };
  }
}

/// Class Year Statistics
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

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'voted': voted,
      'total': total,
      'percentage': percentage,
    };
  }
}
