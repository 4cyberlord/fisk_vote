import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/ballot.dart';
import '../models/vote.dart';

/// Repository for vote-related API calls.
class VoteRepository {
  final ApiClient _apiClient;

  VoteRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get ballot data for an election (positions and candidates).
  ///
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [ServerException] for server errors.
  /// Throws [NetworkException] if no internet connection.
  Future<BallotResponse> getBallot(int electionId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getBallot(electionId.toString()),
      );

      final responseData = response.data as Map<String, dynamic>;

      // Handle API response structure: {success, message, data: {...}}
      Map<String, dynamic> data;
      if (responseData.containsKey('data')) {
        data = {'data': responseData['data']};
      } else {
        data = responseData;
      }

      return BallotResponse.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// Cast a vote for an election.
  ///
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [ServerException] for server errors.
  /// Throws [NetworkException] if no internet connection.
  Future<CastVoteResponse> castVote(
    int electionId,
    CastVoteRequest voteRequest,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.castVote(electionId.toString()),
        data: voteRequest.toJson(),
      );

      final responseData = response.data as Map<String, dynamic>;

      return CastVoteResponse.fromJson(responseData);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }
}
