import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding screen data model
class OnboardingData {
  final String image;
  final String titleLine1;
  final String? titleLine1Highlight; // Word to highlight in line 1
  final String titleLine2;
  final String description;
  final String secondaryButtonText;

  const OnboardingData({
    required this.image,
    required this.titleLine1,
    this.titleLine1Highlight,
    required this.titleLine2,
    required this.description,
    required this.secondaryButtonText,
  });
}

/// Onboarding colors - Dark theme with lime accent
class OnboardingColors {
  OnboardingColors._();

  static const Color background = Color(0xFF121212);
  static const Color surfaceCard = Color(0xFF1E1E1E);
  static const Color accent = Color(0xFFD4E157); // Lime/Yellow-Green
  static const Color accentDark = Color(
    0xFFAFB42B,
  ); // Darker lime for highlight
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF8A8A8A);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color dotInactive = Color(0xFF3A3A3A);
  static const Color borderColor = Color(0xFF333333);
}

/// Onboarding page with 3 swipeable screens
///
/// Shown only on first app launch.
/// Beautiful dark theme with lime accents.
class OnboardingPage extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback? onLogin;
  final VoidCallback? onRegister;

  const OnboardingPage({
    super.key,
    required this.onComplete,
    this.onLogin,
    this.onRegister,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  /// Onboarding content for each page
  static const List<OnboardingData> _pages = [
    OnboardingData(
      image: 'assets/images/illustrations/onboarding_1.png',
      titleLine1: 'Casting',
      titleLine2: 'Your Vote',
      description:
          'Experience a seamless and secure way to participate in campus elections. Your voice matters.',
      secondaryButtonText: 'Register Voter ID',
    ),
    OnboardingData(
      image: 'assets/images/illustrations/onboarding_2.png',
      titleLine1: 'Engage in',
      titleLine1Highlight: 'Campus', // This word gets highlighted
      titleLine2: 'Democracy',
      description:
          'Make your voice heard. Join fellow students in shaping the future of our university community.',
      secondaryButtonText: 'Create New Account',
    ),
    OnboardingData(
      image: 'assets/images/illustrations/onboarding_3.png',
      titleLine1: 'Making Your',
      titleLine2: 'Choice',
      description:
          'Securely review candidates and cast your ballot with just a few taps.',
      secondaryButtonText: 'Create New Account',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();

    // Set status bar style - white icons on dark background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // White icons (Android)
        statusBarBrightness: Brightness.dark, // White icons (iOS)
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// Mark onboarding as complete and navigate
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    widget.onComplete();
  }

  /// Handle login button tap
  void _onLoginTap() {
    _completeOnboarding();
    widget.onLogin?.call();
  }

  /// Handle register button tap
  void _onRegisterTap() {
    _completeOnboarding();
    widget.onRegister?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: OnboardingColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Main content area
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _OnboardingContent(data: _pages[index]);
                },
              ),
            ),

            // Bottom section
            Container(
              padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicators
                  _buildPageIndicators(),
                  const SizedBox(height: 32),

                  // Login button
                  _buildLoginButton(),
                  const SizedBox(height: 12),

                  // Register button
                  _buildRegisterButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: index == _currentPage ? 28 : 6,
          decoration: BoxDecoration(
            color: index == _currentPage
                ? OnboardingColors.accent
                : OnboardingColors.dotInactive,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _onLoginTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: OnboardingColors.accent,
          foregroundColor: OnboardingColors.background,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            if (_currentPage == 1) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: _onRegisterTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: OnboardingColors.textWhite,
          side: const BorderSide(
            color: OnboardingColors.borderColor,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          _pages[_currentPage].secondaryButtonText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

/// Single onboarding page content
class _OnboardingContent extends StatelessWidget {
  final OnboardingData data;

  const _OnboardingContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 0),
      child: Column(
        children: [
          // Image container
          Expanded(
            flex: 55,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: OnboardingColors.surfaceCard,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                data.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: OnboardingColors.surfaceCard,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.how_to_vote_rounded,
                            size: 80,
                            color: OnboardingColors.accent.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'FiskPulse',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: OnboardingColors.accent.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Text content area
          Expanded(
            flex: 45,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Title with optional highlight
                  _buildTitle(),

                  const SizedBox(height: 20),

                  // Description
                  _buildDescription(),

                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    // Check if this screen has a highlighted word
    if (data.titleLine1Highlight != null) {
      return _buildTitleWithHighlight();
    }
    return _buildSimpleTitle();
  }

  /// Simple two-line title (Screen 1 & 3)
  Widget _buildSimpleTitle() {
    return Column(
      children: [
        Text(
          data.titleLine1,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: OnboardingColors.textWhite,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          data.titleLine2,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: OnboardingColors.accent,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  /// Title with highlighted word (Screen 2: "Engage in Campus")
  Widget _buildTitleWithHighlight() {
    return Column(
      children: [
        // First line: "Engage in" + "Campus" with pen underline
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${data.titleLine1} ',
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: OnboardingColors.textWhite,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            // Word with thin pen-stroke underline
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: OnboardingColors.accent, width: 2),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                data.titleLine1Highlight!,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: OnboardingColors.accent,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Second line: "Democracy"
        Text(
          data.titleLine2,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: OnboardingColors.accent,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        data.description,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: OnboardingColors.textGray,
          height: 1.6,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
