import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../data/repositories/auth_repository.dart';
import 'login_page.dart';

/// App colors - Dark theme matching splash/onboarding
class VerificationColors {
  VerificationColors._();

  // Dark backgrounds
  static const Color background = Color(0xFF0D1B2A);
  static const Color backgroundDark = Color(0xFF0A1421);
  static const Color backgroundLight = Color(0xFF162A4A);

  // Card/Surface
  static const Color cardBg = Color(0xFF142136);

  // Accent
  static const Color accent = Color(0xFFF2D00D);

  // Text
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF8A9BAD);

  // Success
  static const Color success = Color(0xFF4CAF50);
}

/// Verification Pending Page - shown after successful registration
class VerificationPendingPage extends StatefulWidget {
  final String email;

  const VerificationPendingPage({super.key, required this.email});

  @override
  State<VerificationPendingPage> createState() =>
      _VerificationPendingPageState();
}

class _VerificationPendingPageState extends State<VerificationPendingPage>
    with SingleTickerProviderStateMixin {
  // Repository for API calls
  final AuthRepository _authRepository = AuthRepository();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final RxBool isResending = false.obs;
  final RxInt resendCountdown = 0.obs;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Resend verification email via API
  Future<void> _resendVerification() async {
    if (resendCountdown.value > 0 || isResending.value) return;

    isResending.value = true;

    try {
      // Call API to resend verification email
      await _authRepository.resendVerificationEmail(widget.email);

      Get.snackbar(
        'Email Sent',
        'Verification link has been resent to your email',
        snackPosition: SnackPosition.TOP,
        backgroundColor: VerificationColors.success,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      );

      // Start countdown (60 seconds before allowing another resend)
      resendCountdown.value = 60;
      _startCountdown();
    } on NetworkException catch (e) {
      _showErrorSnackbar('Network Error', e.message);
    } on ApiException catch (e) {
      _showErrorSnackbar('Error', e.message);
    } catch (e) {
      _showErrorSnackbar('Error', 'Failed to resend verification email');
      debugPrint('Resend verification error: $e');
    } finally {
      isResending.value = false;
    }
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

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
        return true;
      }
      return false;
    });
  }

  /// Open email app
  Future<void> _openEmailApp() async {
    // Try to open the default mail app
    final Uri emailLaunchUri = Uri(scheme: 'mailto');

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        // Fallback - show a message
        Get.snackbar(
          'Info',
          'Please open your email app manually',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: VerificationColors.backgroundLight,
          colorText: VerificationColors.textWhite,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Info',
        'Please open your email app manually',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: VerificationColors.backgroundLight,
        colorText: VerificationColors.textWhite,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _goToLogin() {
    Get.offAll(() => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: VerificationColors.background,
      body: Column(
        children: [
          // Header
          _buildHeader(context),

          // Content
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: VerificationColors.cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  28,
                  24,
                  24 + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: [
                    // Title
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        'Verify Your Email',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: VerificationColors.textWhite,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Description
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          const Text(
                            'We\'ve sent a verification link to',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: VerificationColors.textGray,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: VerificationColors.backgroundLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.email,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: VerificationColors.accent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Click the link in the email to verify your account and start voting on campus elections.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: VerificationColors.textGray,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Important notice
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Colors.orange.shade300,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'You must verify your email before you can login and use the app.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: VerificationColors.textGray,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Steps/Tips
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: VerificationColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: VerificationColors.backgroundLight,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildTipRow(
                              icon: Icons.inbox_rounded,
                              text: 'Check your inbox',
                            ),
                            const SizedBox(height: 10),
                            _buildTipRow(
                              icon: Icons.folder_outlined,
                              text: 'Look in spam/junk folder',
                            ),
                            const SizedBox(height: 10),
                            _buildTipRow(
                              icon: Icons.touch_app_rounded,
                              text: 'Click the verification link',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Open Email App button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _openEmailApp,
                        icon: const Icon(Icons.email_rounded, size: 18),
                        label: const Text(
                          'Open Email App',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VerificationColors.accent,
                          foregroundColor: VerificationColors.backgroundDark,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Resend link
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Didn\'t receive it?  ',
                            style: TextStyle(
                              fontSize: 14,
                              color: VerificationColors.textGray,
                            ),
                          ),
                          if (isResending.value)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: VerificationColors.accent,
                              ),
                            )
                          else if (resendCountdown.value > 0)
                            Text(
                              'Resend in ${resendCountdown.value}s',
                              style: const TextStyle(
                                fontSize: 14,
                                color: VerificationColors.textGray,
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: _resendVerification,
                              child: const Text(
                                'Resend Email',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: VerificationColors.accent,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Back to Login
                    GestureDetector(
                      onTap: _goToLogin,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 16,
                            color: VerificationColors.textGray,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Back to Login',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: VerificationColors.textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
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
      padding: EdgeInsets.only(top: topPadding + 16, bottom: 50),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            VerificationColors.backgroundDark,
            VerificationColors.background,
          ],
        ),
      ),
      child: Column(
        children: [
          // Checkmark badge
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VerificationColors.backgroundLight,
                  border: Border.all(
                    color: VerificationColors.success.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 45,
                  color: VerificationColors.success,
                ),
              ),
              // Celebration dots
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: VerificationColors.accent,
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                left: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: VerificationColors.success.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Success text
          const Text(
            'Account Created!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: VerificationColors.textWhite,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Just one more step...',
            style: TextStyle(fontSize: 14, color: VerificationColors.textGray),
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: VerificationColors.accent.withValues(alpha: 0.1),
          ),
          child: Icon(icon, size: 18, color: VerificationColors.accent),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: VerificationColors.textGray,
            ),
          ),
        ),
      ],
    );
  }
}
