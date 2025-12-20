/// Vote Submission Models
class CastVoteRequest {
  final Map<String, dynamic> votes;

  CastVoteRequest({required this.votes});

  Map<String, dynamic> toJson() {
    return {'votes': votes};
  }
}

class CastVoteResponse {
  final bool success;
  final String message;
  final CastVoteData data;

  CastVoteResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CastVoteResponse.fromJson(Map<String, dynamic> json) {
    return CastVoteResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: CastVoteData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class CastVoteData {
  final String electionId;
  final int voteId;
  final String votedAt;

  CastVoteData({
    required this.electionId,
    required this.voteId,
    required this.votedAt,
  });

  factory CastVoteData.fromJson(Map<String, dynamic> json) {
    return CastVoteData(
      electionId: json['election_id'].toString(),
      voteId: json['vote_id'] as int,
      votedAt: json['voted_at'] as String,
    );
  }
}
