/// Voting Statistics Model
class VotingStats {
  final int electionsVoted; // Unique elections voted in
  final int campusRank; // User's rank among all students
  final double percentile; // User's percentile ranking
  final double campusImpactScore;
  final int? impactScore;
  final double participationRate;
  final int? totalStudents;
  final String? description;

  VotingStats({
    required this.electionsVoted,
    required this.campusRank,
    required this.percentile,
    required this.campusImpactScore,
    this.impactScore,
    this.participationRate = 0.0,
    this.totalStudents,
    this.description,
  });

  factory VotingStats.fromJson(
    Map<String, dynamic> json, [
    List<Map<String, dynamic>>? actualVotingHistory,
  ]) {
    final impactScore = json['impact_score'] as Map<String, dynamic>?;
    final votingHistory = json['voting_history'] as Map<String, dynamic>?;

    // Get unique elections voted in from API
    final electionsVoted = votingHistory?['elections_voted'] as int? ?? 0;
    
    // Get rank from API (user's position among all students)
    final rank = impactScore?['rank'] as int? ?? 0;
    
    // Get percentile from API (user's percentile ranking)
    final percentile = (impactScore?['percentile'] as num?)?.toDouble() ?? 0.0;
    
    // Use real impact score from API
    final impactScoreValue = (impactScore?['score'] as num?)?.toInt() ?? 0;
    
    // Convert impact score (0-200) to percentage (0-100) for display
    final campusImpactScore = (impactScoreValue / 200 * 100).clamp(0.0, 100.0);
    
    // Get participation rate from API
    final participationRate = (votingHistory?['participation_rate'] as num?)?.toDouble() ?? 0.0;
    
    // Get total students from API
    final totalStudents = impactScore?['total_students'] as int?;

    return VotingStats(
      electionsVoted: electionsVoted,
      campusRank: rank,
      percentile: percentile,
      campusImpactScore: campusImpactScore,
      impactScore: impactScoreValue,
      participationRate: participationRate,
      totalStudents: totalStudents,
      description: impactScore?['description'] as String?,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'elections_voted': electionsVoted,
      'campus_rank': campusRank,
      'percentile': percentile,
      'campus_impact_score': campusImpactScore,
      'impact_score': impactScore,
      'participation_rate': participationRate,
      'total_students': totalStudents,
      'description': description,
    };
  }
}

