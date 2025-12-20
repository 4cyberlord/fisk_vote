import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

/// Profile Completion Controller
/// Manages the profile completion flow after login
class ProfileCompletionController extends GetxController {
  final ProfileRepository _repository = ProfileRepository();
  final ApiClient _apiClient = ApiClient();

  // Form fields
  final RxString department = ''.obs;
  final RxString major = ''.obs;
  final RxString classLevel = ''.obs;
  final RxString studentType = ''.obs;
  final RxString citizenshipStatus = ''.obs;
  final RxString personalEmail = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString address = ''.obs;
  final RxList<int> selectedOrganizations = <int>[].obs;

  // State
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  // Departments from API
  final RxList<Map<String, dynamic>> departments = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingDepartments = false.obs;

  // Majors from API
  final RxList<Map<String, dynamic>> majors = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingMajors = false.obs;

  // Class level options
  final List<String> classLevelOptions = [
    'Freshman',
    'Sophomore',
    'Junior',
    'Senior',
  ];

  // Student type options
  final List<String> studentTypeOptions = [
    'Undergraduate',
    'Graduate',
    'Transfer',
    'International',
  ];


  @override
  void onInit() {
    super.onInit();
    _loadCurrentProfile();
    _loadDepartments();
    _loadMajors();
  }

  /// Load current profile to pre-fill form
  Future<void> _loadCurrentProfile() async {
    try {
      final profile = await _repository.getCurrentUser();
      
      department.value = profile.department ?? '';
      major.value = profile.major ?? '';
      classLevel.value = profile.classLevel ?? '';
      studentType.value = profile.studentType ?? '';
      citizenshipStatus.value = profile.citizenshipStatus ?? '';
      personalEmail.value = profile.personalEmail ?? '';
      phoneNumber.value = profile.phoneNumber ?? '';
      address.value = profile.address ?? '';
    } catch (e) {
      // If profile load fails, continue with empty form
      debugPrint('⚠️ Could not load current profile: $e');
    }
  }

  /// Load departments from API
  Future<void> _loadDepartments() async {
    try {
      isLoadingDepartments.value = true;
      final response = await _apiClient.get(ApiEndpoints.departments);
      
      final responseData = response.data as Map<String, dynamic>;
      
      // Handle API response structure: {success, message, data: [...]}
      List<dynamic> data;
      if (responseData.containsKey('data') && responseData['data'] is List) {
        data = responseData['data'] as List<dynamic>;
      } else {
        data = [];
      }

      departments.value = data
          .map((item) => item as Map<String, dynamic>)
          .toList();
      
      debugPrint('✅ Loaded ${departments.length} departments from API');
    } catch (e) {
      debugPrint('⚠️ Could not load departments: $e');
      // Continue with empty list - user can still type manually
    } finally {
      isLoadingDepartments.value = false;
    }
  }

  /// Get department names as list for dropdown
  List<String> get departmentNames {
    return departments.map((dept) => dept['name'] as String).toList();
  }

  /// Load majors from API
  Future<void> _loadMajors() async {
    try {
      isLoadingMajors.value = true;
      final response = await _apiClient.get(ApiEndpoints.majors);
      
      final responseData = response.data as Map<String, dynamic>;
      
      // Handle API response structure: {success, message, data: [...]}
      List<dynamic> data;
      if (responseData.containsKey('data') && responseData['data'] is List) {
        data = responseData['data'] as List<dynamic>;
      } else {
        data = [];
      }

      majors.value = data
          .map((item) => item as Map<String, dynamic>)
          .toList();
      
      debugPrint('✅ Loaded ${majors.length} majors from API');
    } catch (e) {
      debugPrint('⚠️ Could not load majors: $e');
      // Continue with empty list - user can still type manually
    } finally {
      isLoadingMajors.value = false;
    }
  }

  /// Get major names as list for dropdown
  List<String> get majorNames {
    return majors.map((major) => major['name'] as String).toList();
  }

  /// Validate form
  bool _validateForm() {
    fieldErrors.clear();
    bool isValid = true;

    // At least one academic field required (department OR major)
    if (department.value.isEmpty && major.value.isEmpty) {
      fieldErrors['academic'] = 'Please provide either Department or Major';
      isValid = false;
    }

    // Class level required
    if (classLevel.value.isEmpty) {
      fieldErrors['classLevel'] = 'Class level is required';
      isValid = false;
    }

    // Student type required
    if (studentType.value.isEmpty) {
      fieldErrors['studentType'] = 'Student type is required';
      isValid = false;
    }

    return isValid;
  }

  /// Submit profile completion
  Future<void> submitProfile() async {
    if (!_validateForm()) {
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';
      fieldErrors.clear();

      // Update profile
      await _repository.updateProfile(
        department: department.value.isNotEmpty ? department.value : null,
        major: major.value.isNotEmpty ? major.value : null,
        classLevel: classLevel.value,
        studentType: studentType.value,
        citizenshipStatus: citizenshipStatus.value.isNotEmpty
            ? citizenshipStatus.value
            : null,
        personalEmail: personalEmail.value.isNotEmpty
            ? personalEmail.value
            : null,
        phoneNumber: phoneNumber.value.isNotEmpty ? phoneNumber.value : null,
        address: address.value.isNotEmpty ? address.value : null,
        organizations: selectedOrganizations.isNotEmpty
            ? selectedOrganizations.toList()
            : null,
      );

      // Profile updated successfully - navigate to dashboard
      Get.offAll(() => const DashboardPage());
    } on ValidationException catch (e) {
      error.value = e.message;
      final errors = e.fieldErrors;
      if (errors.isNotEmpty) {
        fieldErrors.value = Map<String, String>.from(errors);
      }
    } on ApiException catch (e) {
      error.value = e.message;
      Get.snackbar(
        'Error',
        'Failed to update profile: ${e.message}',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      error.value = 'An unexpected error occurred: ${e.toString()}';
      Get.snackbar(
        'Error',
        'Failed to update profile: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get error message for a specific field
  String? getFieldError(String fieldName) {
    return fieldErrors[fieldName];
  }

  /// Check if form is valid
  bool get isFormValid {
    return (department.value.isNotEmpty || major.value.isNotEmpty) &&
        classLevel.value.isNotEmpty &&
        studentType.value.isNotEmpty;
  }
}

