import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/forgot_password_controller.dart';

/// App colors - Dark theme matching splash/onboarding
class ForgotPasswordColors {
  ForgotPasswordColors._();

  // Dark backgrounds
  static const Color background = Color(0xFF0D1B2A);
  static const Color backgroundDark = Color(0xFF0A1421);
  static const Color backgroundLight = Color(0xFF162A4A);

  // Card/Surface
  static const Color cardBg = Color(0xFF142136);

  // Accent
  static const Color accent = Color(0xFFF2D00D);
  static const Color accentDark = Color(0xFFD4B806);

  // Text
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF8A9BAD);
  static const Color textMuted = Color(0xFF5A6A7A);

  // Input
  static const Color inputBg = Color(0xFF2F3B57);
  static const Color inputBorder = Color(0xFF1E2F3F);

  // Error
  static const Color error = Color(0xFFFF6B6B);

  // Success
  static const Color success = Color(0xFF4CAF50);
}

/// Forgot Password page with same design as login/register
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: ForgotPasswordColors.background,
      body: Column(
        children: [
          // Header with logo
          _buildHeader(context),

          // Card with form
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: ForgotPasswordColors.cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Obx(
                () => controller.isEmailSent.value
                    ? _buildSuccessContent(controller)
                    : _buildFormContent(controller),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: topPadding + 16, bottom: 80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ForgotPasswordColors.backgroundDark,
            ForgotPasswordColors.background,
          ],
        ),
      ),
      child: Column(
        children: [
          // Logo circle - centered
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ForgotPasswordColors.backgroundLight,
              border: Border.all(
                color: ForgotPasswordColors.accent.withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: ForgotPasswordColors.accent.withValues(alpha: 0.1),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              size: 45,
              color: ForgotPasswordColors.accent,
            ),
          ),

          const SizedBox(height: 20),

          // App name
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Fisk',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: ForgotPasswordColors.textWhite,
                    letterSpacing: 0.5,
                  ),
                ),
                TextSpan(
                  text: 'Pulse',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: ForgotPasswordColors.accent,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Subtitle
          const Text(
            'Campus Election Portal',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: ForgotPasswordColors.textGray,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(ForgotPasswordController controller) {
    return Builder(
      builder: (context) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          40,
          24,
          40 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          children: [
            // Lock icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ForgotPasswordColors.accent.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 40,
                color: ForgotPasswordColors.accent,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            const Text(
              'Forgot Password?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: ForgotPasswordColors.textWhite,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            const Text(
              'No worries! Enter your email address and we\'ll send you a link to reset your password.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: ForgotPasswordColors.textGray,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Email field
            _buildEmailField(controller),

            const SizedBox(height: 28),

            // Send Reset Link button
            _buildSendButton(controller),

            const SizedBox(height: 24),

            // Back to login link
            _buildBackToLogin(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessContent(ForgotPasswordController controller) {
    return Builder(
      builder: (context) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          40,
          24,
          40 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          children: [
            // Success icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ForgotPasswordColors.success.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.mark_email_read_rounded,
                size: 50,
                color: ForgotPasswordColors.success,
              ),
            ),

            const SizedBox(height: 28),

            // Title
            const Text(
              'Check Your Email',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: ForgotPasswordColors.textWhite,
              ),
            ),

            const SizedBox(height: 12),

            // Email sent to
            Obx(
              () => Text(
                'We\'ve sent a password reset link to\n${controller.emailController.text}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: ForgotPasswordColors.textGray,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Open email app button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Open email app
                  Get.snackbar(
                    'Info',
                    'Opening email app...',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ForgotPasswordColors.accent,
                  foregroundColor: ForgotPasswordColors.backgroundDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                child: const Text(
                  'Open Email App',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Resend link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Didn\'t receive the email?  ',
                  style: TextStyle(
                    fontSize: 14,
                    color: ForgotPasswordColors.textGray,
                  ),
                ),
                GestureDetector(
                  onTap: controller.resendResetLink,
                  child: const Text(
                    'Resend',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ForgotPasswordColors.accent,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Back to login
            _buildBackToLogin(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField(ForgotPasswordController controller) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: ForgotPasswordColors.inputBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: controller.emailError.value != null
                    ? ForgotPasswordColors.error
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: controller.emailController,
              focusNode: controller.emailFocus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onChanged: controller.onEmailChanged,
              onSubmitted: (_) => controller.sendResetLink(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: ForgotPasswordColors.textWhite,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: ForgotPasswordColors.inputBg,
                hintText: 'Enter your email',
                hintStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: ForgotPasswordColors.textGray.withValues(alpha: 0.7),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Icon(
                    Icons.mail_outline_rounded,
                    color: ForgotPasswordColors.textGray,
                    size: 20,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              cursorColor: ForgotPasswordColors.accent,
            ),
          ),
          if (controller.emailError.value != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 14),
              child: Text(
                controller.emailError.value!,
                style: const TextStyle(
                  fontSize: 12,
                  color: ForgotPasswordColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSendButton(ForgotPasswordController controller) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : controller.sendResetLink,
          style: ElevatedButton.styleFrom(
            backgroundColor: ForgotPasswordColors.accent,
            foregroundColor: ForgotPasswordColors.backgroundDark,
            disabledBackgroundColor: ForgotPasswordColors.accent.withValues(
              alpha: 0.5,
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: ForgotPasswordColors.backgroundDark,
                  ),
                )
              : const Text(
                  'Send Reset Link',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }

  Widget _buildBackToLogin(ForgotPasswordController controller) {
    return GestureDetector(
      onTap: controller.goToLogin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_back_ios_rounded,
            size: 16,
            color: ForgotPasswordColors.textGray,
          ),
          const SizedBox(width: 6),
          const Text(
            'Back to Login',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ForgotPasswordColors.textGray,
            ),
          ),
        ],
      ),
    );
  }
}
