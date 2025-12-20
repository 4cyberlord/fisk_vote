import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/election.dart';
import '../models/election_turnout.dart';

/// Repository for election-related API calls.
class ElectionRepository {
  final ApiClient _apiClient;

  ElectionRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get all elections for the authenticated student.
  ///
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [ServerException] for server errors.
  /// Throws [NetworkException] if no internet connection.
  Future<ElectionsResponse> getElections() async {
    try {
      // Ensure token is loaded from storage before making request
      // The ApiClient.get() method will also check, but we ensure it here
      final response = await _apiClient.get(ApiEndpoints.studentElections);

      final responseData = response.data as Map<String, dynamic>;

      // Handle API response structure: {success, message, data: [...], meta: {...}}
      Map<String, dynamic> data;
      if (responseData.containsKey('data') && responseData['data'] is List) {
        data = {
          'data': responseData['data'],
          'meta': responseData['meta'] ?? {},
        };
      } else {
        data = responseData;
      }

      return ElectionsResponse.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// Get turnout statistics for a specific election.
  ///
  /// [electionId] - The ID of the election
  /// [includeBreakdown] - Whether to include class year breakdown (default: false)
  ///
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [ServerException] for server errors.
  /// Throws [NetworkException] if no internet connection.
  Future<ElectionTurnout> getElectionTurnout(
    int electionId, {
    bool includeBreakdown = false,
  }) async {
    try {
      final params = includeBreakdown ? {'include_breakdown': 'true'} : null;
      final response = await _apiClient.get(
        ApiEndpoints.electionTurnout(electionId.toString()),
        queryParameters: params,
      );

      final responseData = response.data as Map<String, dynamic>;
      return ElectionTurnout.fromJson(
        responseData['data'] as Map<String, dynamic>,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }
}
