import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';

/// Repository for authentication-related API calls.
class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  // ═══════════════════════════════════════════════════════════════════════════
  // REGISTRATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Register a new student.
  ///
  /// Throws [ValidationException] if validation fails.
  /// Throws [ServerException] for server errors.
  /// Throws [NetworkException] if no internet connection.
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      final data = response.data as Map<String, dynamic>;
      return RegisterResponse.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════════════════════════

  /// Login user with email and password.
  ///
  /// Returns [LoginResponse] with user data and token if successful.
  /// Check [LoginResponse.isEmailVerified] to determine if user can access the app.
  ///
  /// Throws [ValidationException] if credentials are invalid.
  /// Throws [ServerException] for server errors.
  /// Throws [NetworkException] if no internet connection.
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      final responseData = response.data as Map<String, dynamic>;

      // Handle API response structure: {success, message, data: {token, user, ...}}
      // Extract nested 'data' if present, otherwise use response directly
      Map<String, dynamic> data;
      if (responseData.containsKey('data') &&
          responseData['data'] is Map<String, dynamic>) {
        // Merge top-level fields (success, message) with nested data fields
        final nestedData = responseData['data'] as Map<String, dynamic>;
        data = {
          ...responseData, // Keep success, message
          ...nestedData, // Add token, user, token_type, expires_in
        };
      } else {
        // No nested data wrapper, use response directly
        data = responseData;
      }

      return LoginResponse.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PASSWORD RESET
  // ═══════════════════════════════════════════════════════════════════════════

  /// Send password reset email.
  ///
  /// Throws [ValidationException] if email is not found.
  /// Throws [NetworkException] if no internet connection.
  Future<void> forgotPassword(String email) async {
    try {
      await _apiClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EMAIL VERIFICATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Resend email verification link.
  ///
  /// Throws [ValidationException] if email is not found.
  /// Throws [NetworkException] if no internet connection.
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _apiClient.post(
        ApiEndpoints.resendVerification,
        data: {'email': email},
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Logout user and invalidate token.
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
      _apiClient.clearAuthToken();
    } on ApiException {
      // Still clear token even if API call fails
      _apiClient.clearAuthToken();
      rethrow;
    } catch (e) {
      _apiClient.clearAuthToken();
      throw UnknownException(message: e.toString());
    }
  }

  /// Set auth token for authenticated requests
  void setAuthToken(String token) {
    _apiClient.setAuthToken(token);
  }

  /// Clear auth token
  void clearAuthToken() {
    _apiClient.clearAuthToken();
  }
}
