/// User profile model from the backend API.
class UserProfile {
  // Basic Information
  final int id;
  final String name;
  final String firstName;
  final String lastName;
  final String? middleInitial;

  // Email Information
  final String email;
  final String? universityEmail;
  final String? personalEmail;
  final DateTime? emailVerifiedAt;

  // Student Information
  final String? studentId;
  final String? department;
  final String? major;
  final String? classLevel;
  final String? enrollmentStatus;
  final String? studentType;
  final String? citizenshipStatus;

  // Contact Information
  final String? phoneNumber;
  final String? address;

  // Profile Information
  final String? profilePhoto;

  // Account Information
  final List<String> roles;
  final List<dynamic> organizations;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    this.middleInitial,
    required this.email,
    this.universityEmail,
    this.personalEmail,
    this.emailVerifiedAt,
    this.studentId,
    this.department,
    this.major,
    this.classLevel,
    this.enrollmentStatus,
    this.studentType,
    this.citizenshipStatus,
    this.phoneNumber,
    this.address,
    this.profilePhoto,
    required this.roles,
    this.organizations = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON response
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      middleInitial: json['middle_initial'] as String?,
      email: json['email'] as String? ?? '',
      universityEmail: json['university_email'] as String?,
      personalEmail: json['personal_email'] as String?,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'] as String)
          : null,
      studentId: json['student_id'] as String?,
      department: json['department'] as String?,
      major: json['major'] as String?,
      classLevel: json['class_level'] as String?,
      enrollmentStatus: json['enrollment_status'] as String?,
      studentType: json['student_type'] as String?,
      citizenshipStatus: json['citizenship_status'] as String?,
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      organizations: json['organizations'] as List<dynamic>? ?? [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Check if email is verified
  bool get isEmailVerified => emailVerifiedAt != null;

  /// Get graduation year from class level (e.g., "Senior" -> "2025")
  String? get graduationYear {
    if (classLevel == null) return null;
    final currentYear = DateTime.now().year;
    final level = classLevel!.toLowerCase();

    if (level.contains('senior')) {
      return (currentYear + 1).toString();
    } else if (level.contains('junior')) {
      return (currentYear + 2).toString();
    } else if (level.contains('sophomore')) {
      return (currentYear + 3).toString();
    } else if (level.contains('freshman')) {
      return (currentYear + 4).toString();
    }
    return null;
  }

  /// Check if profile is complete (has all essential fields for app functionality)
  /// Essential fields: department/major, class_level, student_type
  bool get isProfileComplete {
    // Check if at least one academic field is filled (department OR major)
    final hasAcademicInfo = (department != null && department!.isNotEmpty) ||
        (major != null && major!.isNotEmpty);
    
    // Check if all essential fields are present
    return hasAcademicInfo &&
        classLevel != null &&
        classLevel!.isNotEmpty &&
        studentType != null &&
        studentType!.isNotEmpty;
  }

  /// Get list of missing required fields for profile completion
  List<String> get missingRequiredFields {
    final missing = <String>[];
    
    if ((department == null || department!.isEmpty) &&
        (major == null || major!.isEmpty)) {
      missing.add('Department or Major');
    }
    if (classLevel == null || classLevel!.isEmpty) {
      missing.add('Class Level');
    }
    if (studentType == null || studentType!.isEmpty) {
      missing.add('Student Type');
    }
    
    return missing;
  }
}
