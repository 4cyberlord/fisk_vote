/// Ballot Data Models
class BallotData {
  final BallotElection election;
  final List<BallotPosition> positions;
  final bool hasVoted;
  final ExistingVote? existingVote;

  BallotData({
    required this.election,
    required this.positions,
    required this.hasVoted,
    this.existingVote,
  });

  factory BallotData.fromJson(Map<String, dynamic> json) {
    return BallotData(
      election: BallotElection.fromJson(
        json['election'] as Map<String, dynamic>,
      ),
      positions:
          (json['positions'] as List<dynamic>?)
              ?.map(
                (item) => BallotPosition.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      hasVoted: json['has_voted'] as bool? ?? false,
      existingVote: json['existing_vote'] != null
          ? ExistingVote.fromJson(json['existing_vote'] as Map<String, dynamic>)
          : null,
    );
  }
}

class BallotElection {
  final int id;
  final String title;
  final String? description;
  final String type;
  final String currentStatus;
  final String startTime;
  final String endTime;

  BallotElection({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.currentStatus,
    required this.startTime,
    required this.endTime,
  });

  factory BallotElection.fromJson(Map<String, dynamic> json) {
    return BallotElection(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      currentStatus: json['current_status'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }
}

class BallotPosition {
  final int id;
  final String name;
  final String? description;
  final String type; // 'single', 'multiple', 'ranked'
  final int? maxSelection;
  final int? rankingLevels;
  final bool allowAbstain;
  final List<BallotCandidate> candidates;

  BallotPosition({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    this.maxSelection,
    this.rankingLevels,
    required this.allowAbstain,
    required this.candidates,
  });

  factory BallotPosition.fromJson(Map<String, dynamic> json) {
    return BallotPosition(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      maxSelection: json['max_selection'] as int?,
      rankingLevels: json['ranking_levels'] as int?,
      allowAbstain: json['allow_abstain'] as bool? ?? false,
      candidates:
          (json['candidates'] as List<dynamic>?)
              ?.map(
                (item) =>
                    BallotCandidate.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class BallotCandidate {
  final int id;
  final int userId;
  final CandidateUser? user;
  final String? photoUrl;
  final String? tagline;
  final String? bio;
  final String? manifesto;

  BallotCandidate({
    required this.id,
    required this.userId,
    this.user,
    this.photoUrl,
    this.tagline,
    this.bio,
    this.manifesto,
  });

  factory BallotCandidate.fromJson(Map<String, dynamic> json) {
    return BallotCandidate(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      user: json['user'] != null
          ? CandidateUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      photoUrl: json['photo_url'] as String?,
      tagline: json['tagline'] as String?,
      bio: json['bio'] as String?,
      manifesto: json['manifesto'] as String?,
    );
  }

  String get displayName {
    if (user?.name != null && user!.name!.isNotEmpty) {
      return user!.name!;
    }
    if (user?.firstName != null && user?.lastName != null) {
      return '${user!.firstName} ${user!.lastName}';
    }
    return 'Candidate $id';
  }
}

class CandidateUser {
  final int id;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? profilePhoto;

  CandidateUser({
    required this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.email,
    this.profilePhoto,
  });

  factory CandidateUser.fromJson(Map<String, dynamic> json) {
    return CandidateUser(
      id: json['id'] as int,
      name: json['name'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      profilePhoto: json['profile_photo'] as String?,
    );
  }
}

class ExistingVote {
  final Map<String, dynamic> voteData;
  final String votedAt;

  ExistingVote({required this.voteData, required this.votedAt});

  factory ExistingVote.fromJson(Map<String, dynamic> json) {
    return ExistingVote(
      voteData: json['vote_data'] as Map<String, dynamic>? ?? {},
      votedAt: json['voted_at'] as String,
    );
  }
}

/// Ballot Response Model
class BallotResponse {
  final BallotData data;

  BallotResponse({required this.data});

  factory BallotResponse.fromJson(Map<String, dynamic> json) {
    return BallotResponse(
      data: BallotData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
