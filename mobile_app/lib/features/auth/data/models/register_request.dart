/// Registration request model matching the backend API.
class RegisterRequest {
  final String firstName;
  final String? middleInitial;
  final String lastName;
  final String studentId;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String acceptTerms;

  const RegisterRequest({
    required this.firstName,
    this.middleInitial,
    required this.lastName,
    required this.studentId,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.acceptTerms,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'middle_initial': middleInitial ?? '',
      'last_name': lastName,
      'student_id': studentId,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'accept_terms': acceptTerms,
    };
  }

  @override
  String toString() {
    return 'RegisterRequest(firstName: $firstName, lastName: $lastName, email: $email, studentId: $studentId)';
  }
}
