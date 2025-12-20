/// Registration response model from the backend API.
class RegisterResponse {
  final bool success;
  final String message;
  final UserData? user;
  final String? token;

  const RegisterResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });

  /// Create from JSON response
  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? 'Registration successful',
      user: json['user'] != null
          ? UserData.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      token: json['token'] as String?,
    );
  }

  @override
  String toString() {
    return 'RegisterResponse(success: $success, message: $message, user: ${user?.email})';
  }
}

/// User data returned after registration.
class UserData {
  final int? id;
  final String firstName;
  final String? middleInitial;
  final String lastName;
  final String studentId;
  final String email;
  final bool emailVerified;
  final DateTime? createdAt;

  const UserData({
    this.id,
    required this.firstName,
    this.middleInitial,
    required this.lastName,
    required this.studentId,
    required this.email,
    this.emailVerified = false,
    this.createdAt,
  });

  /// Full name
  String get fullName {
    if (middleInitial != null && middleInitial!.isNotEmpty) {
      return '$firstName $middleInitial. $lastName';
    }
    return '$firstName $lastName';
  }

  /// Create from JSON response
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as int?,
      firstName: json['first_name'] as String? ?? '',
      middleInitial: json['middle_initial'] as String?,
      lastName: json['last_name'] as String? ?? '',
      studentId: json['student_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      emailVerified:
          json['email_verified'] as bool? ?? json['email_verified_at'] != null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'UserData(id: $id, name: $fullName, email: $email)';
  }
}
