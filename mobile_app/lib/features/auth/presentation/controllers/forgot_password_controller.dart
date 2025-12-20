import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Forgot Password controller using GetX for state management
class ForgotPasswordController extends GetxController {
  // Text controller
  final emailController = TextEditingController();

  // Focus node
  final emailFocus = FocusNode();

  // Observable states
  final isLoading = false.obs;
  final emailError = Rxn<String>();
  final isEmailSent = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    emailFocus.dispose();
    super.onClose();
  }

  /// Validate email
  bool _validateEmail() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      emailError.value = 'Email is required';
      return false;
    }
    if (!GetUtils.isEmail(email)) {
      emailError.value = 'Please enter a valid email';
      return false;
    }
    // Check for Fisk email domain
    if (!email.endsWith('@fisk.edu') && !email.endsWith('@my.fisk.edu')) {
      emailError.value = 'Please use your Fisk University email';
      return false;
    }
    emailError.value = null;
    return true;
  }

  /// Clear email error on typing
  void onEmailChanged(String value) {
    if (emailError.value != null) {
      emailError.value = null;
    }
  }

  /// Handle send reset link
  Future<void> sendResetLink() async {
    if (!_validateEmail()) {
      return;
    }

    // Show loading
    isLoading.value = true;

    try {
      // TODO: Implement actual password reset logic with API
      await Future.delayed(const Duration(seconds: 2));

      // Success
      isEmailSent.value = true;

      Get.snackbar(
        'Email Sent',
        'Check your inbox for the reset link',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send reset email. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend reset link
  Future<void> resendResetLink() async {
    isEmailSent.value = false;
    await sendResetLink();
  }

  /// Navigate back to login
  void goToLogin() {
    Get.back();
  }
}
