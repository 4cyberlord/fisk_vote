import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../data/models/login_request.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../../profile/presentation/pages/profile_completion_page.dart';
import '../pages/forgot_password_page.dart';
import '../pages/register_page.dart';
import '../pages/verification_pending_page.dart';

/// Login controller using GetX for state management
/// Handles API login and email verification checks
class LoginController extends GetxController {
  // Repository for API calls
  final AuthRepository _authRepository = AuthRepository();

  // Text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Focus nodes for keyboard navigation
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  // Observable states
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final rememberMe = false.obs;
  final emailError = Rxn<String>();
  final passwordError = Rxn<String>();
  final generalError = Rxn<String>();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }

  /// Move focus to password field
  void focusPassword() {
    passwordFocus.requestFocus();
  }

  /// Submit form when done
  void onPasswordSubmitted() {
    login();
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Toggle remember me checkbox
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  /// Validate email - Only @my.fisk.edu allowed
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
    if (password.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
      return false;
    }
    passwordError.value = null;
    return true;
  }

  /// Clear email error on typing
  void onEmailChanged(String value) {
    if (emailError.value != null) {
      emailError.value = null;
    }
    if (generalError.value != null) {
      generalError.value = null;
    }
  }

  /// Clear password error on typing
  void onPasswordChanged(String value) {
    if (passwordError.value != null) {
      passwordError.value = null;
    }
    if (generalError.value != null) {
      generalError.value = null;
    }
  }

  /// Handle login with API call
  Future<void> login() async {
    // Validate inputs
    final isEmailValid = _validateEmail();
    final isPasswordValid = _validatePassword();

    if (!isEmailValid || !isPasswordValid) {
      return;
    }

    // Clear previous errors
    generalError.value = null;

    // Show loading
    isLoading.value = true;

    try {
      // Create request
      final request = LoginRequest(
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text,
      );

      // Call API
      final response = await _authRepository.login(request);

      // Check if email is verified
      if (!response.isEmailVerified) {
        // Email not verified - redirect to verification page
        final email = emailController.text.trim();

        Get.snackbar(
          'Email Not Verified',
          'Please verify your email before logging in',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        );

        // Navigate to verification pending page
        Get.off(() => VerificationPendingPage(email: email));
        return;
      }

      // Email verified - Save token and proceed
      if (response.token != null) {
        _authRepository.setAuthToken(response.token!);
        // TODO: Save token to secure storage for persistence
      }

      // Check if profile is complete before navigating
      await _checkProfileAndNavigate();
    } on ValidationException catch (e) {
      // Handle validation errors (invalid credentials)
      _handleValidationErrors(e);
    } on UnauthorizedException catch (e) {
      // Handle unauthorized (invalid credentials)
      _showErrorSnackbar('Invalid Credentials', e.message);
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
      debugPrint('Login error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle validation errors from API
  void _handleValidationErrors(ValidationException e) {
    final errors = e.fieldErrors;

    if (errors.containsKey('email')) {
      emailError.value = errors['email'];
    }
    if (errors.containsKey('password')) {
      passwordError.value = errors['password'];
    }

    // Show general error
    _showErrorSnackbar('Login Failed', e.message);
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

  /// Check profile completion and navigate accordingly
  Future<void> _checkProfileAndNavigate() async {
    try {
      // Load user profile to check completion status
      final profileRepo = ProfileRepository();
      final profile = await profileRepo.getCurrentUser();

      // Check if profile is complete
      if (profile.isProfileComplete) {
        // Profile is complete - show success and navigate to dashboard
        Get.snackbar(
          'Welcome Back!',
          'Login successful',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        );

        // Navigate to dashboard
        Get.offAll(() => const DashboardPage());
      } else {
        // Profile is incomplete - navigate to profile completion page
        Get.snackbar(
          'Profile Incomplete',
          'Please complete your profile to continue',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.info_outline, color: Colors.white),
        );

        // Navigate to profile completion page
        Get.offAll(() => const ProfileCompletionPage());
      }
    } catch (e) {
      // If profile check fails, still navigate to dashboard
      // (better UX than blocking user)
      debugPrint('Profile check failed: $e');
      
      Get.snackbar(
        'Welcome Back!',
        'Login successful',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      );

      Get.offAll(() => const DashboardPage());
    }
  }

  /// Navigate to forgot password
  void goToForgotPassword() {
    Get.to(() => const ForgotPasswordPage());
  }

  /// Navigate to sign up
  void goToSignUp() {
    Get.to(() => const RegisterPage());
  }
}
