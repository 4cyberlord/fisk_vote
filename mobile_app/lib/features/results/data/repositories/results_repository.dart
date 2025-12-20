import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/election_results.dart';

/// Repository for results-related API calls.
class ResultsRepository {
  final ApiClient _apiClient;

  ResultsRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get all closed elections with results.
  ///
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [ServerException] for server errors.
  /// Throws [NetworkException] if no internet connection.
  Future<AllResultsResponse> getAllResults() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.allResults);

      final responseData = response.data as Map<String, dynamic>;

      // Handle API response structure: {success, message, data: [...]}
      Map<String, dynamic> data;
      if (responseData.containsKey('data')) {
        data = {'data': responseData['data']};
      } else {
        data = responseData;
      }

      return AllResultsResponse.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// Get results for a specific election (only if closed).
  ///
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [ServerException] for server errors.
  /// Throws [NetworkException] if no internet connection.
  Future<ElectionResultsResponse> getElectionResults(int electionId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.studentElectionResults(electionId.toString()),
      );

      final responseData = response.data as Map<String, dynamic>;

      // Handle API response structure: {success, message, data: {...}}
      Map<String, dynamic> data;
      if (responseData.containsKey('data')) {
        data = {'data': responseData['data']};
      } else {
        data = responseData;
      }

      return ElectionResultsResponse.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }
}
