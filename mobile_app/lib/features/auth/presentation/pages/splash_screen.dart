import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fisk brand colors for splash screen
class SplashColors {
  SplashColors._();

  static const Color fiskBlue = Color(0xFF0D1B2A); // Deep navy blue
  static const Color fiskBlueDark = Color(0xFF0A1421);
  static const Color fiskBlueLight = Color(0xFF162A4A);
  static const Color primary = Color(0xFFF2D00D); // Gold/Yellow
  static const Color primaryDim = Color(0x33F2D00D); // 20% opacity
  static const Color primaryGlow = Color(0x80F2D00D); // 50% opacity
  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteMuted = Color(0x99FFFFFF); // 60% opacity
  static const Color whiteDim = Color(0x4DFFFFFF); // 30% opacity
}

/// Animated splash screen with glowing rings effect
class SplashScreen extends StatefulWidget {
  final VoidCallback? onLoadingComplete;
  final Duration loadingDuration;

  const SplashScreen({
    super.key,
    this.onLoadingComplete,
    this.loadingDuration = const Duration(minutes: 2),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pingController;
  late AnimationController _rotateController;
  late Animation<double> _pingAnimation;

  int _loadingPercent = 0;
  Timer? _percentTimer;

  @override
  void initState() {
    super.initState();

    // Hide status bar completely (no time, wifi, battery)
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );

    // Ping animation - radar/sonar pulse effect
    _pingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _pingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pingController, curve: Curves.easeOut));

    // Rotate animation for outer ring
    _rotateController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Simulate loading percentage
    _startLoadingSimulation();
  }

  void _startLoadingSimulation() {
    const totalSteps = 100;
    final stepDuration = widget.loadingDuration.inMilliseconds ~/ totalSteps;

    _percentTimer = Timer.periodic(Duration(milliseconds: stepDuration), (
      timer,
    ) {
      if (_loadingPercent >= 100) {
        timer.cancel();
        widget.onLoadingComplete?.call();
      } else {
        setState(() {
          // Add some randomness to make it feel more realistic
          _loadingPercent += 1 + (math.Random().nextInt(2));
          if (_loadingPercent > 100) _loadingPercent = 100;
        });
      }
    });
  }

  @override
  void dispose() {
    // Restore status bar when leaving splash screen
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    // Set white status bar icons for dark backgrounds
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // White icons (Android)
        statusBarBrightness: Brightness.dark, // White icons (iOS)
      ),
    );
    _pingController.dispose();
    _rotateController.dispose();
    _percentTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SplashColors.fiskBlue,
      body: Stack(
        children: [
          // Background gradient
          _buildBackgroundGradient(),

          // Main content - NO fade in, show immediately
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo with ping effect rings
                _buildAnimatedLogo(),

                const SizedBox(height: 40),

                // Brand text
                _buildBrandText(),

                const Spacer(flex: 2),

                // Loading section
                _buildLoadingSection(),

                const SizedBox(height: 24),

                // Version text
                _buildVersionText(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            SplashColors.fiskBlueLight.withValues(alpha: 0.4),
            SplashColors.fiskBlue,
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ping pulse rings (radar effect)
          AnimatedBuilder(
            animation: _pingAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // First ping wave
                  _buildPingRing(_pingAnimation.value),
                  // Second ping wave (delayed)
                  _buildPingRing((_pingAnimation.value + 0.5) % 1.0),
                ],
              );
            },
          ),

          // Static glow rings
          AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateController.value * 2 * math.pi,
                child: _buildStaticRing(size: 170, opacity: 0.15),
              );
            },
          ),
          _buildStaticRing(size: 155, opacity: 0.2),
          _buildStaticRing(size: 142, opacity: 0.25),

          // Main logo container
          _buildLogoContainer(),
        ],
      ),
    );
  }

  /// Ping ring that expands outward and fades
  Widget _buildPingRing(double progress) {
    // Scale from logo size (128) to max size (220)
    final size = 128 + (progress * 92);
    // Fade out as it expands
    final opacity = (1.0 - progress) * 0.4;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: SplashColors.primary.withValues(alpha: opacity),
          width: 2.0 - (progress * 1.5), // Thinner as it expands
        ),
      ),
    );
  }

  /// Static glow ring
  Widget _buildStaticRing({required double size, required double opacity}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: SplashColors.primary.withValues(alpha: opacity),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildLogoContainer() {
    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SplashColors.fiskBlueLight, SplashColors.fiskBlueDark],
        ),
        border: Border.all(
          color: SplashColors.white.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          // Inner glow
          BoxShadow(
            color: SplashColors.primary.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          // Outer shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              SplashColors.primary,
              SplashColors.primary.withValues(alpha: 0.8),
            ],
          ).createShader(bounds),
          child: Icon(
            Icons.how_to_vote_rounded,
            size: 64,
            color: SplashColors.primary,
            shadows: [
              Shadow(
                color: SplashColors.primary.withValues(alpha: 0.5),
                blurRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandText() {
    return Column(
      children: [
        // FISK PULSE
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'FISK',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: SplashColors.white,
                  letterSpacing: 4,
                ),
              ),
              TextSpan(
                text: 'PULSE',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: SplashColors.primary,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Tagline
        Text(
          'YOUR VOICE, YOUR CAMPUS',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: SplashColors.white.withValues(alpha: 0.5),
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  /// Get loading message based on progress
  String _getLoadingMessage() {
    if (_loadingPercent < 15) {
      return 'LOADING APPLICATION';
    } else if (_loadingPercent < 30) {
      return 'ESTABLISHING CONNECTION';
    } else if (_loadingPercent < 45) {
      return 'VERIFYING SECURITY';
    } else if (_loadingPercent < 60) {
      return 'SYNCING DATA';
    } else if (_loadingPercent < 75) {
      return 'LOADING USER PROFILE';
    } else if (_loadingPercent < 90) {
      return 'FINALIZING SETUP';
    } else {
      return 'ALMOST READY';
    }
  }

  Widget _buildLoadingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          // Loading text with percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _getLoadingMessage(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: SplashColors.primary.withValues(alpha: 0.8),
                    letterSpacing: 1.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$_loadingPercent%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: SplashColors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: SplashColors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width:
                      (MediaQuery.of(context).size.width - 96) *
                      (_loadingPercent / 100),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        SplashColors.primary,
                        SplashColors.primary.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: SplashColors.primary.withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionText() {
    return Text(
      'v0.1.0-beta • Secure Campus Voting',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: SplashColors.white.withValues(alpha: 0.3),
        letterSpacing: 0.5,
      ),
    );
  }
}
