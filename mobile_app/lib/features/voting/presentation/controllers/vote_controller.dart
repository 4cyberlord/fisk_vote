import 'package:get/get.dart';
import '../../data/models/ballot.dart';
import '../../data/models/vote.dart';
import '../../data/repositories/vote_repository.dart';
import '../../../../core/network/api_exceptions.dart';

/// Vote Controller
class VoteController extends GetxController {
  final VoteRepository _repository;

  VoteController({VoteRepository? repository})
    : _repository = repository ?? VoteRepository();

  // State
  final Rx<BallotData?> ballotData = Rx<BallotData?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isSubmitting = false.obs;
  CastVoteData? lastVoteData;

  // Vote selections: Map<positionId, voteValue>
  // For single: int (candidate_id)
  // For multiple: List<int> (candidate_ids)
  // For ranked: List<Map<String, int>> (rankings with candidate_id)
  // Abstain: Map<positionId_abstain, true>
  final RxMap<String, dynamic> votes = <String, dynamic>{}.obs;

  /// Fetch ballot data for an election
  Future<void> fetchBallot(int electionId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _repository.getBallot(electionId);
      ballotData.value = response.data;

      // Initialize votes from existing vote if user has already voted
      if (response.data.hasVoted && response.data.existingVote != null) {
        final existingVoteData = response.data.existingVote!.voteData;
        votes.value = Map<String, dynamic>.from(existingVoteData);
      } else {
        votes.clear();
      }
    } on UnauthorizedException {
      error.value = 'Unauthenticated. Please login again.';
    } on ApiException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = 'Failed to load ballot: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Set vote for a position
  void setVote(int positionId, dynamic value) {
    final fieldKey = 'position_$positionId';
    votes[fieldKey] = value;
    // Remove abstain if vote is set
    votes.remove('${fieldKey}_abstain');
  }

  /// Set abstain for a position
  void setAbstain(int positionId, bool abstain) {
    final fieldKey = 'position_$positionId';
    final abstainKey = '${fieldKey}_abstain';

    if (abstain) {
      votes.remove(fieldKey);
      votes[abstainKey] = true;
    } else {
      votes.remove(abstainKey);
    }
  }

  /// Get vote for a position
  dynamic getVote(int positionId) {
    final fieldKey = 'position_$positionId';
    return votes[fieldKey];
  }

  /// Check if position is abstained
  bool isAbstained(int positionId) {
    final fieldKey = 'position_$positionId';
    final abstainKey = '${fieldKey}_abstain';
    return votes[abstainKey] == true;
  }

  /// Validate votes before submission
  String? validateVotes() {
    if (ballotData.value == null) {
      return 'Ballot data not loaded';
    }

    for (final position in ballotData.value!.positions) {
      final fieldKey = 'position_${position.id}';
      final abstainKey = '${fieldKey}_abstain';

      // Check if position has vote or abstain
      if (!votes.containsKey(abstainKey) && !votes.containsKey(fieldKey)) {
        if (!position.allowAbstain) {
          return 'Please select a candidate for ${position.name} or abstain.';
        }
      }

      // Validate max_selection for multiple choice
      if (position.type == 'multiple' && votes.containsKey(fieldKey)) {
        final selected = votes[fieldKey];
        if (selected is List && position.maxSelection != null) {
          if (selected.length > position.maxSelection!) {
            return 'You can only select up to ${position.maxSelection} candidate(s) for ${position.name}.';
          }
        }
      }

      // Validate ranking_levels for ranked choice
      if (position.type == 'ranked' && votes.containsKey(fieldKey)) {
        final rankings = votes[fieldKey];
        if (rankings is List && position.rankingLevels != null) {
          if (rankings.length > position.rankingLevels!) {
            return 'You can rank a maximum of ${position.rankingLevels} candidate(s) for ${position.name}.';
          }
        }
      }
    }

    return null;
  }

  /// Submit vote
  Future<bool> submitVote(int electionId) async {
    // Validate votes
    final validationError = validateVotes();
    if (validationError != null) {
      error.value = validationError;
      return false;
    }

    try {
      isSubmitting.value = true;
      error.value = '';

      // Format votes for backend
      final formattedVotes = <String, dynamic>{};
      for (final entry in votes.entries) {
        if (entry.key.endsWith('_abstain')) {
          formattedVotes[entry.key] = entry.value;
        } else if (entry.value is List) {
          // Check if it's ranked choice (array of objects with candidate_id)
          if (entry.value.isNotEmpty &&
              entry.value[0] is Map<String, dynamic>) {
            formattedVotes[entry.key] = entry.value;
          } else {
            // Multiple choice (array of numbers)
            formattedVotes[entry.key] = entry.value;
          }
        } else {
          formattedVotes[entry.key] = entry.value;
        }
      }

      final voteRequest = CastVoteRequest(votes: formattedVotes);
      final response = await _repository.castVote(electionId, voteRequest);

      // Store vote data for confirmation page
      lastVoteData = response.data;

      return true;
    } on UnauthorizedException {
      error.value = 'Unauthenticated. Please login again.';
      return false;
    } on ApiException catch (e) {
      error.value = e.message;
      return false;
    } catch (e) {
      error.value = 'Failed to submit vote: ${e.toString()}';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Reset votes
  void resetVotes() {
    votes.clear();
  }
}
