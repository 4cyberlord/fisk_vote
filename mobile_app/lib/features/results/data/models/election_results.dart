/// Election Results Models
class ElectionResult {
  final ResultElection election;
  final int totalVotes;
  final int uniqueVoters;
  final List<PositionResult> positions;

  ElectionResult({
    required this.election,
    required this.totalVotes,
    required this.uniqueVoters,
    required this.positions,
  });

  factory ElectionResult.fromJson(Map<String, dynamic> json) {
    return ElectionResult(
      election: ResultElection.fromJson(
        json['election'] as Map<String, dynamic>,
      ),
      totalVotes: json['total_votes'] as int? ?? 0,
      uniqueVoters: json['unique_voters'] as int? ?? 0,
      positions:
          (json['positions'] as List<dynamic>?)
              ?.map(
                (item) => PositionResult.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  /// Calculate turnout percentage (if we have eligible voters data)
  double? get turnoutPercentage {
    // This would need eligible voters count from election data
    // For now, return null or calculate based on available data
    return null;
  }

  /// Get the featured position (first position or position with most votes)
  PositionResult? get featuredPosition {
    if (positions.isEmpty) return null;
    // Return first position, or position with highest total_votes
    return positions.reduce((a, b) => a.totalVotes > b.totalVotes ? a : b);
  }
}

class ResultElection {
  final int id;
  final String title;
  final String? description;
  final String type;
  final String status;
  final String startTime;
  final String endTime;

  ResultElection({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    required this.startTime,
    required this.endTime,
  });

  factory ResultElection.fromJson(Map<String, dynamic> json) {
    return ResultElection(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      status: json['status'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }
}

class PositionResult {
  final int positionId;
  final String positionName;
  final String? positionDescription;
  final String positionType;
  final int totalVotes;
  final int validVotes;
  final int abstentions;
  final List<CandidateResult> candidates;
  final List<CandidateResult> winners;

  PositionResult({
    required this.positionId,
    required this.positionName,
    this.positionDescription,
    required this.positionType,
    required this.totalVotes,
    required this.validVotes,
    required this.abstentions,
    required this.candidates,
    required this.winners,
  });

  factory PositionResult.fromJson(Map<String, dynamic> json) {
    return PositionResult(
      positionId: json['position_id'] as int,
      positionName: json['position_name'] as String,
      positionDescription: json['position_description'] as String?,
      positionType: json['position_type'] as String,
      totalVotes: json['total_votes'] as int? ?? 0,
      validVotes: json['valid_votes'] as int? ?? 0,
      abstentions: json['abstentions'] as int? ?? 0,
      candidates:
          (json['candidates'] as List<dynamic>?)
              ?.map(
                (item) =>
                    CandidateResult.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      winners:
          (json['winners'] as List<dynamic>?)
              ?.map(
                (item) =>
                    CandidateResult.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  /// Get the winner (first winner or candidate with most votes)
  CandidateResult? get winner {
    if (winners.isNotEmpty) return winners.first;
    if (candidates.isEmpty) return null;
    return candidates.reduce((a, b) => a.votes > b.votes ? a : b);
  }
}

class CandidateResult {
  final int candidateId;
  final String candidateName;
  final String? candidateTagline;
  final String? candidatePhoto;
  final int votes;
  final double percentage;
  final int? rank;

  CandidateResult({
    required this.candidateId,
    required this.candidateName,
    this.candidateTagline,
    this.candidatePhoto,
    required this.votes,
    required this.percentage,
    this.rank,
  });

  factory CandidateResult.fromJson(Map<String, dynamic> json) {
    return CandidateResult(
      candidateId: json['candidate_id'] as int,
      candidateName: json['candidate_name'] as String,
      candidateTagline: json['candidate_tagline'] as String?,
      candidatePhoto: json['candidate_photo'] as String?,
      votes: json['votes'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      rank: json['rank'] as int?,
    );
  }
}

/// All Results Response Model
class AllResultsResponse {
  final List<ArchiveElection> data;

  AllResultsResponse({required this.data});

  factory AllResultsResponse.fromJson(Map<String, dynamic> json) {
    return AllResultsResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (item) =>
                    ArchiveElection.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

/// Archive Election Model (simplified for list view)
class ArchiveElection {
  final int id;
  final String title;
  final String? description;
  final String? endTime;
  final int totalVotes;

  ArchiveElection({
    required this.id,
    required this.title,
    this.description,
    this.endTime,
    required this.totalVotes,
  });

  factory ArchiveElection.fromJson(Map<String, dynamic> json) {
    return ArchiveElection(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      endTime: json['end_time'] as String?,
      totalVotes: json['total_votes'] as int? ?? 0,
    );
  }

  String get formattedEndDate {
    if (endTime == null) return 'N/A';
    try {
      final date = DateTime.parse(endTime!);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return endTime!;
    }
  }
}

/// Election Results Response Model
class ElectionResultsResponse {
  final ElectionResult data;

  ElectionResultsResponse({required this.data});

  factory ElectionResultsResponse.fromJson(Map<String, dynamic> json) {
    return ElectionResultsResponse(
      data: ElectionResult.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
