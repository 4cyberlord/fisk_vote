import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/register_controller.dart';

/// App colors - Dark theme matching splash/onboarding
class RegisterColors {
  RegisterColors._();

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
}

/// Register page with multi-step sliding form
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterController());

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: RegisterColors.background,
      body: Column(
        children: [
          // Header with logo
          _buildHeader(context),

          // Card with form
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: RegisterColors.cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Column(
                children: [
                  // Flexible header area - can shrink on small screens
                  Flexible(
                    flex: 0,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Adjust spacing based on available height
                        final isSmallScreen = constraints.maxHeight < 600;
                        final verticalPadding = isSmallScreen ? 12.0 : 20.0;
                        final avatarSpacing = isSmallScreen ? 8.0 : 12.0;
                        final titleSpacing = isSmallScreen ? 2.0 : 4.0;
                        final subtitleSpacing = isSmallScreen ? 8.0 : 14.0;
                        final indicatorSpacing = isSmallScreen ? 8.0 : 12.0;

                        return Padding(
                          padding: EdgeInsets.fromLTRB(24, verticalPadding, 24, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // User avatars
                              _buildUserAvatars(),
                              SizedBox(height: avatarSpacing),
                              // Title
                              const Text(
                                'Join the Community',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: RegisterColors.textWhite,
                                ),
                              ),
                              SizedBox(height: titleSpacing),
                              const Text(
                                'Create your account to start voting',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: RegisterColors.textGray,
                                ),
                              ),
                              SizedBox(height: subtitleSpacing),
                              // Step indicator
                              _buildStepIndicator(controller),
                              SizedBox(height: indicatorSpacing),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Sliding form pages - takes remaining space
                  Expanded(
                    child: PageView(
                      controller: controller.pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        controller.currentStep.value = index;
                      },
                      children: [
                        _buildStep1(controller),
                        _buildStep2(controller),
                      ],
                    ),
                  ),
                ],
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
          colors: [RegisterColors.backgroundDark, RegisterColors.background],
        ),
      ),
      child: Column(
        children: [
          // Logo circle - centered
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: RegisterColors.backgroundLight,
              border: Border.all(
                color: RegisterColors.accent.withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: RegisterColors.accent.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Icon(
              Icons.how_to_vote_rounded,
              size: 35,
              color: RegisterColors.accent,
            ),
          ),

          const SizedBox(height: 14),

          // App name
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Fisk',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: RegisterColors.textWhite,
                    letterSpacing: 0.5,
                  ),
                ),
                TextSpan(
                  text: 'Pulse',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: RegisterColors.accent,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(RegisterController controller) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Step 1
          _buildStepDot(0, controller.currentStep.value),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              color: controller.currentStep.value >= 1
                  ? RegisterColors.accent
                  : RegisterColors.inputBorder,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 8),
          // Step 2
          _buildStepDot(1, controller.currentStep.value),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, int currentStep) {
    final isActive = currentStep >= step;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? RegisterColors.accent : Colors.transparent,
        border: Border.all(
          color: isActive ? RegisterColors.accent : RegisterColors.textMuted,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '${step + 1}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isActive
                ? RegisterColors.backgroundDark
                : RegisterColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatars() {
    final avatarUrls = [
      'https://i.pravatar.cc/150?img=1',
      'https://i.pravatar.cc/150?img=5',
      'https://i.pravatar.cc/150?img=9',
      'https://i.pravatar.cc/150?img=12',
    ];

    return SizedBox(
      height: 48,
      child: Center(
        child: SizedBox(
          width: 156,
          child: Stack(
            children: [
              for (int i = 0; i < 4; i++)
                Positioned(left: i * 28.0, child: _buildAvatar(avatarUrls[i])),
              Positioned(
                left: 4 * 28.0,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: RegisterColors.accent,
                    border: Border.all(color: RegisterColors.cardBg, width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      '+2k',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: RegisterColors.backgroundDark,
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
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: RegisterColors.cardBg, width: 2),
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: RegisterColors.inputBg,
              child: const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: RegisterColors.accent,
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: RegisterColors.inputBg,
              child: const Icon(
                Icons.person,
                size: 20,
                color: RegisterColors.textGray,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Step 1: Personal Information
  Widget _buildStep1(RegisterController controller) {
    return Builder(
      builder: (context) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Personal Info',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: RegisterColors.textWhite,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter your basic information',
              style: TextStyle(fontSize: 13, color: RegisterColors.textGray),
            ),

            const SizedBox(height: 20),

            // First Name & Middle Initial
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    controller: controller.firstNameController,
                    label: 'First Name',
                    icon: Icons.person_outline_rounded,
                    errorObs: controller.firstNameError,
                    onChanged: controller.onFirstNameChanged,
                    focusNode: controller.firstNameFocus,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => controller.focusMiddleInitial(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: _buildTextField(
                    controller: controller.middleInitialController,
                    label: 'M.I.',
                    maxLength: 1,
                    textCapitalization: TextCapitalization.characters,
                    focusNode: controller.middleInitialFocus,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => controller.focusLastName(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Last Name
            _buildTextField(
              controller: controller.lastNameController,
              label: 'Last Name',
              icon: Icons.person_outline_rounded,
              errorObs: controller.lastNameError,
              onChanged: controller.onLastNameChanged,
              focusNode: controller.lastNameFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => controller.focusStudentId(),
            ),

            const SizedBox(height: 14),

            // Student ID
            _buildTextField(
              controller: controller.studentIdController,
              label: 'Student ID',
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.text,
              errorObs: controller.studentIdError,
              onChanged: controller.onStudentIdChanged,
              focusNode: controller.studentIdFocus,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => controller.onStudentIdSubmitted(),
            ),

            const SizedBox(height: 28),

            // Next button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: RegisterColors.accent,
                  foregroundColor: RegisterColors.backgroundDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Login link
            _buildLoginLink(controller),
          ],
        ),
      ),
    );
  }

  /// Step 2: Account Information
  Widget _buildStep2(RegisterController controller) {
    return Builder(
      builder: (context) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back to step 1
            GestureDetector(
              onTap: controller.previousStep,
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 16,
                    color: RegisterColors.accent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: RegisterColors.accent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Title
            const Text(
              'Account Setup',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: RegisterColors.textWhite,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Create your login credentials',
              style: TextStyle(fontSize: 13, color: RegisterColors.textGray),
            ),

            const SizedBox(height: 20),

            // Email
            _buildTextField(
              controller: controller.emailController,
              label: 'Email Address',
              hint: 'student@fisk.edu',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              errorObs: controller.emailError,
              onChanged: controller.onEmailChanged,
              focusNode: controller.emailFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => controller.focusPassword(),
            ),

            const SizedBox(height: 14),

            // Password
            Obx(
              () => _buildTextField(
                controller: controller.passwordController,
                label: 'Password',
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscureText: !controller.isPasswordVisible.value,
                errorObs: controller.passwordError,
                onChanged: controller.onPasswordChanged,
                focusNode: controller.passwordFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => controller.focusPasswordConfirmation(),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: RegisterColors.textGray,
                    size: 20,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Confirm Password
            Obx(
              () => _buildTextField(
                controller: controller.passwordConfirmationController,
                label: 'Confirm Password',
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscureText: !controller.isPasswordConfirmationVisible.value,
                errorObs: controller.passwordConfirmationError,
                onChanged: controller.onPasswordConfirmationChanged,
                focusNode: controller.passwordConfirmationFocus,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) =>
                    controller.onPasswordConfirmationSubmitted(),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordConfirmationVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: RegisterColors.textGray,
                    size: 20,
                  ),
                  onPressed: controller.togglePasswordConfirmationVisibility,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Accept Terms
            _buildAcceptTerms(controller),

            const SizedBox(height: 24),

            // Create Account button
            _buildCreateAccountButton(controller),

            const SizedBox(height: 20),

            // Login link
            _buildLoginLink(controller),
          ],
        ),
      ),
    );
  }

  /// Reusable compact text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Rxn<String>? errorObs,
    void Function(String)? onChanged,
    Widget? suffixIcon,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
  }) {
    if (errorObs != null) {
      return Obx(
        () => _buildTextFieldContent(
          controller: controller,
          label: label,
          hint: hint,
          icon: icon,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLength: maxLength,
          textCapitalization: textCapitalization,
          error: errorObs.value,
          onChanged: onChanged,
          suffixIcon: suffixIcon,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
        ),
      );
    }
    return _buildTextFieldContent(
      controller: controller,
      label: label,
      hint: hint,
      icon: icon,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      suffixIcon: suffixIcon,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
    );
  }

  Widget _buildTextFieldContent({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? error,
    void Function(String)? onChanged,
    Widget? suffixIcon,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: RegisterColors.inputBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: error != null ? RegisterColors.error : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            maxLength: maxLength,
            textCapitalization: textCapitalization,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: RegisterColors.textWhite,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: RegisterColors.inputBg,
              hintText: hint ?? label,
              hintStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: RegisterColors.textGray.withValues(alpha: 0.7),
              ),
              prefixIcon: icon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 14, right: 10),
                      child: Icon(
                        icon,
                        color: RegisterColors.textGray,
                        size: 20,
                      ),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              suffixIcon: suffixIcon,
              counterText: '',
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
                horizontal: 14,
                vertical: 14,
              ),
              isDense: true,
            ),
            cursorColor: RegisterColors.accent,
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              error,
              style: const TextStyle(fontSize: 11, color: RegisterColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildAcceptTerms(RegisterController controller) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: controller.toggleAcceptTerms,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: controller.acceptTerms.value
                          ? RegisterColors.accent
                          : RegisterColors.textMuted,
                      width: 2,
                    ),
                    color: controller.acceptTerms.value
                        ? RegisterColors.accent
                        : Colors.transparent,
                  ),
                  child: controller.acceptTerms.value
                      ? const Icon(
                          Icons.check,
                          size: 12,
                          color: RegisterColors.backgroundDark,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: RegisterColors.textGray,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: 'I accept the '),
                        TextSpan(
                          text: 'Terms',
                          style: const TextStyle(
                            color: RegisterColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(
                            color: RegisterColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (controller.termsError.value != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 30),
              child: Text(
                controller.termsError.value!,
                style: const TextStyle(
                  fontSize: 11,
                  color: RegisterColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCreateAccountButton(RegisterController controller) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.register,
          style: ElevatedButton.styleFrom(
            backgroundColor: RegisterColors.accent,
            foregroundColor: RegisterColors.backgroundDark,
            disabledBackgroundColor: RegisterColors.accent.withValues(
              alpha: 0.5,
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: RegisterColors.backgroundDark,
                  ),
                )
              : const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(RegisterController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account?  ',
          style: TextStyle(fontSize: 13, color: RegisterColors.textGray),
        ),
        GestureDetector(
          onTap: controller.goToLogin,
          child: const Text(
            'Login',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: RegisterColors.textWhite,
            ),
          ),
        ),
      ],
    );
  }
}
