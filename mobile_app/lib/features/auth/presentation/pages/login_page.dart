import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';

/// App colors - Dark theme matching splash/onboarding
class LoginColors {
  LoginColors._();

  // Dark backgrounds
  static const Color background = Color(0xFF0D1B2A);
  static const Color backgroundDark = Color(0xFF0A1421);
  static const Color backgroundLight = Color(0xFF162A4A);

  // Card/Surface - slightly lighter to stand out
  static const Color cardBg = Color(0xFF142136);

  // Accent
  static const Color accent = Color(0xFFF2D00D);
  static const Color accentDark = Color(0xFFD4B806);

  // Text
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF8A9BAD);
  static const Color textMuted = Color(0xFF5A6A7A);
  // Text for light backgrounds
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textPlaceholder = Color(0xFF8F99A7);

  // Input
  static const Color inputBg = Color(0xFF2F3B57); // Dark blue matching design
  static const Color inputBorder = Color(0xFF1E2F3F);
  static const Color inputBorderFocused = Color(0xFF3A4D5F);

  // Error
  static const Color error = Color(0xFFFF6B6B);
}

/// Login page with overlapping card design
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: LoginColors.background,
      body: Column(
        children: [
          // Header with logo (fixed height)
          _buildHeader(context),

          // Card with form (takes remaining space)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: LoginColors.cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  32,
                  24,
                  40 + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: [
                    // User avatars
                    _buildUserAvatars(),

                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'Welcome Back!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: LoginColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sign in to continue voting',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: LoginColors.textGray,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Email field
                    _buildEmailField(controller),

                    const SizedBox(height: 16),

                    // Password field
                    _buildPasswordField(controller),

                    const SizedBox(height: 16),

                    // Remember me & Forgot password
                    _buildOptionsRow(controller),

                    const SizedBox(height: 32),

                    // Continue button
                    _buildContinueButton(controller),

                    const SizedBox(height: 24),

                    // Sign up link
                    _buildSignUpLink(controller),
                  ],
                ),
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
      padding: EdgeInsets.only(top: topPadding + 20, bottom: 60),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [LoginColors.backgroundDark, LoginColors.background],
        ),
      ),
      child: Column(
        children: [
          // Logo circle
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LoginColors.backgroundLight,
              border: Border.all(
                color: LoginColors.accent.withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: LoginColors.accent.withValues(alpha: 0.1),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.how_to_vote_rounded,
              size: 45,
              color: LoginColors.accent,
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
                    color: LoginColors.textWhite,
                    letterSpacing: 0.5,
                  ),
                ),
                TextSpan(
                  text: 'Pulse',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.accent,
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
              color: LoginColors.textGray,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatars() {
    // Real avatar image URLs
    final avatarUrls = [
      'https://i.pravatar.cc/150?img=1',
      'https://i.pravatar.cc/150?img=5',
      'https://i.pravatar.cc/150?img=9',
      'https://i.pravatar.cc/150?img=12',
    ];

    return SizedBox(
      height: 62,
      child: Center(
        child: SizedBox(
          width: 195,
          child: Stack(
            children: [
              // Avatars
              for (int i = 0; i < 4; i++)
                Positioned(left: i * 35.0, child: _buildAvatar(avatarUrls[i])),
              // +2k badge - same size as avatars, overlapping last one
              Positioned(
                left: 4 * 35.0, // Position after last avatar
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: LoginColors.accent,
                    border: Border.all(color: LoginColors.cardBg, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '+2k',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: LoginColors.backgroundDark,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String imageUrl) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: LoginColors.cardBg, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: LoginColors.inputBg,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: LoginColors.accent,
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: LoginColors.inputBg,
              child: const Icon(
                Icons.person,
                size: 24,
                color: LoginColors.textGray,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmailField(LoginController controller) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: LoginColors.inputBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: controller.emailError.value != null
                    ? LoginColors.error
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: controller.emailController,
              focusNode: controller.emailFocus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: controller.onEmailChanged,
              onSubmitted: (_) => controller.focusPassword(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: LoginColors.textWhite,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: LoginColors.inputBg,
                hintText: 'Enter your email',
                hintStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: LoginColors.textGray.withValues(alpha: 0.7),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Icon(
                    Icons.mail_outline_rounded,
                    color: LoginColors.textGray,
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
              cursorColor: LoginColors.accent,
            ),
          ),
          if (controller.emailError.value != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 14),
              child: Text(
                controller.emailError.value!,
                style: const TextStyle(fontSize: 12, color: LoginColors.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(LoginController controller) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: LoginColors.inputBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: controller.passwordError.value != null
                    ? LoginColors.error
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: controller.passwordController,
              focusNode: controller.passwordFocus,
              obscureText: !controller.isPasswordVisible.value,
              textInputAction: TextInputAction.done,
              onChanged: controller.onPasswordChanged,
              onSubmitted: (_) => controller.onPasswordSubmitted(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: LoginColors.textWhite,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: LoginColors.inputBg,
                hintText: 'Enter your password',
                hintStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: LoginColors.textGray.withValues(alpha: 0.7),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: LoginColors.textGray,
                    size: 20,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: LoginColors.textGray,
                    size: 20,
                  ),
                  onPressed: controller.togglePasswordVisibility,
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
              cursorColor: LoginColors.accent,
            ),
          ),
          if (controller.passwordError.value != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 12),
              child: Text(
                controller.passwordError.value!,
                style: const TextStyle(fontSize: 12, color: LoginColors.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionsRow(LoginController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember me
        Obx(
          () => GestureDetector(
            onTap: controller.toggleRememberMe,
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: controller.rememberMe.value
                          ? LoginColors.accent
                          : LoginColors.textMuted,
                      width: 2,
                    ),
                    color: controller.rememberMe.value
                        ? LoginColors.accent
                        : Colors.transparent,
                  ),
                  child: controller.rememberMe.value
                      ? const Icon(
                          Icons.check,
                          size: 12,
                          color: LoginColors.backgroundDark,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Remember me',
                  style: TextStyle(fontSize: 14, color: LoginColors.textGray),
                ),
              ],
            ),
          ),
        ),

        // Forgot password
        GestureDetector(
          onTap: controller.goToForgotPassword,
          child: const Text(
            'Forgot password?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: LoginColors.accent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(LoginController controller) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.login,
          style: ElevatedButton.styleFrom(
            backgroundColor: LoginColors.accent,
            foregroundColor: LoginColors.backgroundDark,
            disabledBackgroundColor: LoginColors.accent.withValues(alpha: 0.5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: LoginColors.backgroundDark,
                  ),
                )
              : const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink(LoginController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?  ",
          style: TextStyle(fontSize: 14, color: LoginColors.textGray),
        ),
        GestureDetector(
          onTap: controller.goToSignUp,
          child: const Text(
            'Sign up',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: LoginColors.textWhite,
            ),
          ),
        ),
      ],
    );
  }
}
