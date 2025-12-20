/// Login request model matching the backend API.
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }

  @override
  String toString() => 'LoginRequest(email: $email)';
}
