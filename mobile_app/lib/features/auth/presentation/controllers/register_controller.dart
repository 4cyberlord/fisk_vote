import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../data/models/register_request.dart';
import '../../data/repositories/auth_repository.dart';
import '../pages/verification_pending_page.dart';

/// Register controller using GetX for state management
/// Supports multi-step registration form with API integration
class RegisterController extends GetxController {
  // Repository for API calls
  final AuthRepository _authRepository = AuthRepository();

  // Page controller for sliding animation - initialize immediately
  final PageController pageController = PageController();

  // Text controllers
  final firstNameController = TextEditingController();
  final middleInitialController = TextEditingController();
  final lastNameController = TextEditingController();
  final studentIdController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();

  // Focus nodes for keyboard navigation
  final firstNameFocus = FocusNode();
  final middleInitialFocus = FocusNode();
  final lastNameFocus = FocusNode();
  final studentIdFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final passwordConfirmationFocus = FocusNode();

  // Observable states
  final currentStep = 0.obs;
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isPasswordConfirmationVisible = false.obs;
  final acceptTerms = false.obs;

  // Error states
  final firstNameError = Rxn<String>();
  final middleInitialError = Rxn<String>();
  final lastNameError = Rxn<String>();
  final studentIdError = Rxn<String>();
  final emailError = Rxn<String>();
  final passwordError = Rxn<String>();
  final passwordConfirmationError = Rxn<String>();
  final termsError = Rxn<String>();
  final generalError = Rxn<String>();

  @override
  void onClose() {
    pageController.dispose();
    firstNameController.dispose();
    middleInitialController.dispose();
    lastNameController.dispose();
    studentIdController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    // Dispose focus nodes
    firstNameFocus.dispose();
    middleInitialFocus.dispose();
    lastNameFocus.dispose();
    studentIdFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    passwordConfirmationFocus.dispose();
    super.onClose();
  }

  // Focus navigation methods - Step 1
  void focusMiddleInitial() => middleInitialFocus.requestFocus();
  void focusLastName() => lastNameFocus.requestFocus();
  void focusStudentId() => studentIdFocus.requestFocus();
  void onStudentIdSubmitted() => nextStep();

  // Focus navigation methods - Step 2
  void focusPassword() => passwordFocus.requestFocus();
  void focusPasswordConfirmation() => passwordConfirmationFocus.requestFocus();
  void onPasswordConfirmationSubmitted() => register();

  /// Navigate to next step
  void nextStep() {
    if (currentStep.value == 0) {
      // Validate step 1 fields
      if (_validateStep1()) {
        currentStep.value = 1;
        pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        // Focus email field after animation
        Future.delayed(const Duration(milliseconds: 450), () {
          emailFocus.requestFocus();
        });
      }
    }
  }

  /// Navigate to previous step
  void previousStep() {
    if (currentStep.value == 1) {
      currentStep.value = 0;
      pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Validate step 1 fields
  bool _validateStep1() {
    final isFirstNameValid = _validateFirstName();
    final isLastNameValid = _validateLastName();
    final isStudentIdValid = _validateStudentId();
    return isFirstNameValid && isLastNameValid && isStudentIdValid;
  }

  /// Validate step 2 fields
  bool _validateStep2() {
    final isEmailValid = _validateEmail();
    final isPasswordValid = _validatePassword();
    final isPasswordConfirmValid = _validatePasswordConfirmation();
    final isTermsValid = _validateTerms();
    return isEmailValid &&
        isPasswordValid &&
        isPasswordConfirmValid &&
        isTermsValid;
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Toggle password confirmation visibility
  void togglePasswordConfirmationVisibility() {
    isPasswordConfirmationVisible.value = !isPasswordConfirmationVisible.value;
  }

  /// Toggle accept terms checkbox
  void toggleAcceptTerms() {
    acceptTerms.value = !acceptTerms.value;
    if (acceptTerms.value) {
      termsError.value = null;
    }
  }

  /// Validate first name
  bool _validateFirstName() {
    final firstName = firstNameController.text.trim();
    if (firstName.isEmpty) {
      firstNameError.value = 'First name is required';
      return false;
    }
    if (firstName.length < 2) {
      firstNameError.value = 'Must be at least 2 characters';
      return false;
    }
    firstNameError.value = null;
    return true;
  }

  /// Validate last name
  bool _validateLastName() {
    final lastName = lastNameController.text.trim();
    if (lastName.isEmpty) {
      lastNameError.value = 'Last name is required';
      return false;
    }
    if (lastName.length < 2) {
      lastNameError.value = 'Must be at least 2 characters';
      return false;
    }
    lastNameError.value = null;
    return true;
  }

  /// Validate student ID
  bool _validateStudentId() {
    final studentId = studentIdController.text.trim();
    if (studentId.isEmpty) {
      studentIdError.value = 'Student ID is required';
      return false;
    }
    if (studentId.length < 5) {
      studentIdError.value = 'Must be at least 5 characters';
      return false;
    }
    studentIdError.value = null;
    return true;
  }

  /// Validate email - Only @my.fisk.edu emails are allowed
  bool _validateEmail() {
    final email = emailController.text.trim().toLowerCase();
    if (email.isEmpty) {
      emailError.value = 'Email is required';
      return false;
    }
    if (!GetUtils.isEmail(email)) {
      emailError.value = 'Please enter a valid email';
      return false;
    }
    // Only allow @my.fisk.edu domain
    if (!email.endsWith('@my.fisk.edu')) {
      emailError.value = 'Only @my.fisk.edu emails are allowed';
      return false;
    }
    emailError.value = null;
    return true;
  }

  /// Validate password
  bool _validatePassword() {
    final password = passwordController.text;
    if (password.isEmpty) {
      passwordError.value = 'Password is required';
      return false;
    }
    if (password.length < 8) {
      passwordError.value = 'Must be at least 8 characters';
      return false;
    }
    passwordError.value = null;
    return true;
  }

  /// Validate password confirmation
  bool _validatePasswordConfirmation() {
    final password = passwordController.text;
    final confirmation = passwordConfirmationController.text;
    if (confirmation.isEmpty) {
      passwordConfirmationError.value = 'Please confirm your password';
      return false;
    }
    if (password != confirmation) {
      passwordConfirmationError.value = 'Passwords do not match';
      return false;
    }
    passwordConfirmationError.value = null;
    return true;
  }

  /// Validate terms acceptance
  bool _validateTerms() {
    if (!acceptTerms.value) {
      termsError.value = 'You must accept the terms';
      return false;
    }
    termsError.value = null;
    return true;
  }

  /// Clear errors on field change
  void onFirstNameChanged(String value) {
    if (firstNameError.value != null) firstNameError.value = null;
    if (generalError.value != null) generalError.value = null;
  }

  void onLastNameChanged(String value) {
    if (lastNameError.value != null) lastNameError.value = null;
    if (generalError.value != null) generalError.value = null;
  }

  void onStudentIdChanged(String value) {
    if (studentIdError.value != null) studentIdError.value = null;
    if (generalError.value != null) generalError.value = null;
  }

  void onEmailChanged(String value) {
    if (emailError.value != null) emailError.value = null;
    if (generalError.value != null) generalError.value = null;
  }

  void onPasswordChanged(String value) {
    if (passwordError.value != null) passwordError.value = null;
    if (generalError.value != null) generalError.value = null;
    if (passwordConfirmationController.text.isNotEmpty &&
        passwordConfirmationController.text == value) {
      passwordConfirmationError.value = null;
    }
  }

  void onPasswordConfirmationChanged(String value) {
    if (passwordConfirmationError.value != null) {
      passwordConfirmationError.value = null;
    }
    if (generalError.value != null) generalError.value = null;
  }

  /// Handle registration with API call
  Future<void> register() async {
    // Validate step 2 fields
    if (!_validateStep2()) {
      return;
    }

    // Clear any previous general error
    generalError.value = null;

    // Show loading
    isLoading.value = true;

    try {
      // Create request object
      final request = RegisterRequest(
        firstName: firstNameController.text.trim(),
        middleInitial: middleInitialController.text.trim().isNotEmpty
            ? middleInitialController.text.trim()
            : null,
        lastName: lastNameController.text.trim(),
        studentId: studentIdController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        passwordConfirmation: passwordConfirmationController.text,
        acceptTerms: acceptTerms.value ? 'true' : 'false',
      );

      // Call API
      final response = await _authRepository.register(request);

      // Get email before navigating
      final email = emailController.text.trim();

      // Show success message
      Get.snackbar(
        'Success',
        response.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Navigate to verification pending page
      Get.off(() => VerificationPendingPage(email: email));
    } on ValidationException catch (e) {
      // Handle validation errors from server
      _handleValidationErrors(e);
    } on NetworkException catch (e) {
      // Handle network errors
      _showErrorSnackbar('Network Error', e.message);
    } on ServerException catch (e) {
      // Handle server errors
      if (e.errors != null) {
        _handleValidationErrors(
          ValidationException(message: e.message, errors: e.errors),
        );
      } else {
        _showErrorSnackbar('Error', e.message);
      }
    } on ApiException catch (e) {
      // Handle other API errors
      _showErrorSnackbar('Error', e.message);
    } catch (e) {
      // Handle unexpected errors
      _showErrorSnackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
      );
      debugPrint('Registration error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle validation errors from API response
  void _handleValidationErrors(ValidationException e) {
    final errors = e.fieldErrors;

    // Map API field names to controller error states
    if (errors.containsKey('first_name')) {
      firstNameError.value = errors['first_name'];
      // Go back to step 1 if error is there
      if (currentStep.value == 1) previousStep();
    }
    if (errors.containsKey('middle_initial')) {
      middleInitialError.value = errors['middle_initial'];
      if (currentStep.value == 1) previousStep();
    }
    if (errors.containsKey('last_name')) {
      lastNameError.value = errors['last_name'];
      if (currentStep.value == 1) previousStep();
    }
    if (errors.containsKey('student_id')) {
      studentIdError.value = errors['student_id'];
      if (currentStep.value == 1) previousStep();
    }
    if (errors.containsKey('email')) {
      emailError.value = errors['email'];
    }
    if (errors.containsKey('password')) {
      passwordError.value = errors['password'];
    }
    if (errors.containsKey('password_confirmation')) {
      passwordConfirmationError.value = errors['password_confirmation'];
    }
    if (errors.containsKey('accept_terms')) {
      termsError.value = errors['accept_terms'];
    }

    // Show general error message
    _showErrorSnackbar('Validation Error', e.message);
  }

  /// Show error snackbar
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
    );
  }

  /// Navigate to login
  void goToLogin() {
    Get.back();
  }
}
