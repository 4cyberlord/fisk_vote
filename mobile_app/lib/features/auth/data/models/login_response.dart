import 'register_response.dart';

/// Login response model from the backend API.
class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final String? tokenType;
  final int? expiresIn;
  final UserData? user;

  const LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.tokenType,
    this.expiresIn,
    this.user,
  });

  /// Check if user's email is verified
  bool get isEmailVerified => user?.emailVerified ?? false;

  /// Create from JSON response
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? 'Login successful',
      token: json['token'] as String? ?? json['access_token'] as String?,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresIn: json['expires_in'] as int?,
      user: json['user'] != null
          ? UserData.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  String toString() {
    return 'LoginResponse(success: $success, message: $message, emailVerified: $isEmailVerified)';
  }
}
