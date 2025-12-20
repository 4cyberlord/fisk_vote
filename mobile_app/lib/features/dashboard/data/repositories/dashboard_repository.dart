import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/student_stats.dart';
import '../models/campus_participation.dart';

/// Repository for dashboard-related API calls.
class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get comprehensive statistics for the authenticated student.
  ///
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [ServerException] for server errors.
  /// Throws [NetworkException] if no internet connection.
  Future<StudentStats> getStudentStats() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.studentStats);

      final responseData = response.data as Map<String, dynamic>;

      // Handle API response structure: {success, message, data: {...}}
      Map<String, dynamic> data;
      if (responseData.containsKey('data') &&
          responseData['data'] is Map<String, dynamic>) {
        data = responseData['data'] as Map<String, dynamic>;
      } else {
        data = responseData;
      }

      return StudentStats.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// Get campus-wide voter participation statistics.
  ///
  /// [year] Optional academic year (e.g., "2024-2025"). Defaults to current year.
  ///
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [ServerException] for server errors.
  /// Throws [NetworkException] if no internet connection.
  Future<CampusParticipation> getCampusParticipation({String? year}) async {
    try {
      String endpoint = ApiEndpoints.campusParticipation;
      if (year != null) {
        endpoint = '$endpoint?year=$year';
      }

      final response = await _apiClient.get(endpoint);

      final responseData = response.data as Map<String, dynamic>;

      // Handle API response structure: {success, message, data: {...}}
      Map<String, dynamic> data;
      if (responseData.containsKey('data') &&
          responseData['data'] is Map<String, dynamic>) {
        data = responseData['data'] as Map<String, dynamic>;
      } else {
        data = responseData;
      }

      return CampusParticipation.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }
}
