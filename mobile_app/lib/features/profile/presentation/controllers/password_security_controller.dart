import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/presentation/pages/login_page.dart';

class PasswordSecurityController extends GetxController {
  final ProfileRepository _profileRepository = ProfileRepository();
  final AuthRepository _authRepository = AuthRepository();

  // Form controllers
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // State
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxString error = ''.obs;

  // Password strength (0-1)
  final RxDouble strength = 0.0.obs;
  final RxString strengthLabel = 'Too Weak'.obs;
  final Rx<Color> strengthColor = Colors.red.obs;

  // Password visibility
  final RxBool showCurrentPassword = false.obs;
  final RxBool showNewPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;

  // Audit logs
  final RxList<Map<String, dynamic>> auditLogs = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> statistics = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAuditLogs();
    newPasswordController.addListener(_onNewPasswordChanged);
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void _onNewPasswordChanged() {
    final pwd = newPasswordController.text;
    calculateStrength(pwd);
  }

  /// Public helper to evaluate password strength
  void calculateStrength(String password) {
    double score = 0;
    if (password.length >= 8) score += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 0.25;
    if (RegExp(r'[!@#\$&*~.,;:\-_]').hasMatch(password)) score += 0.25;

    strength.value = score.clamp(0, 1);

    if (score >= 0.75) {
      strengthLabel.value = 'Strong';
      strengthColor.value = Colors.green;
    } else if (score >= 0.5) {
      strengthLabel.value = 'Good';
      strengthColor.value = Colors.lightGreen;
    } else if (score >= 0.25) {
      strengthLabel.value = 'Weak';
      strengthColor.value = Colors.orange;
    } else {
      strengthLabel.value = 'Too Weak';
      strengthColor.value = Colors.red;
    }
  }

  Future<void> fetchAuditLogs() async {
    try {
      isLoading.value = true;
      error.value = '';
      final data = await _profileRepository.getAuditLogs();
      final logs = (data['data'] as List?) ?? [];
      auditLogs.value = logs.whereType<Map<String, dynamic>>().toList();
      statistics.value = (data['statistics'] as Map<String, dynamic>?) ?? {};
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword() async {
    final currentPwd = currentPasswordController.text.trim();
    final newPwd = newPasswordController.text.trim();
    final confirmPwd = confirmPasswordController.text.trim();

    if (currentPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all password fields.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPwd != confirmPwd) {
      Get.snackbar(
        'Error',
        'New password and confirmation do not match.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isUpdating.value = true;
    try {
      final success = await _profileRepository.changePassword(
        currentPassword: currentPwd,
        newPassword: newPwd,
        newPasswordConfirmation: confirmPwd,
      );

      if (success) {
        Get.snackbar(
          'Password Updated',
          'Your password has been changed. Please sign in again for security.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await _authRepository.logout();
        _authRepository.clearAuthToken();
        Get.offAll(() => const LoginPage());
      }
    } on ValidationException catch (e) {
      // Friendly validation messages (e.g. incorrect current password)
      final friendly = e.firstError ?? e.message;
      Get.snackbar(
        'Unable to change password',
        friendly,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } on ApiException catch (e) {
      // Other API errors with clean message (no status code suffix)
      Get.snackbar(
        'Unable to change password',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Something went wrong while changing your password. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }
}
