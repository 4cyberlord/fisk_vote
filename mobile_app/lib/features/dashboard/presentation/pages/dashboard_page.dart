import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';
import '../../../notifications/presentation/controllers/notification_controller.dart';
import 'tabs/home_tab.dart';
import 'tabs/vote_tab.dart';
import 'tabs/results_tab.dart';
import 'tabs/blog_tab.dart';
import 'tabs/profile_tab.dart';

/// Modern App Colors - Enhanced Design System
class DashboardColors {
  DashboardColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // BACKGROUND COLORS - Modern Deep Blue Gradient
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color background = Color(0xFF0A0E27);
  static const Color backgroundDark = Color(0xFF050811);
  static const Color backgroundLight = Color(0xFF151B3D);

  // ═══════════════════════════════════════════════════════════════════════════
  // SURFACE/CARD COLORS - Glassmorphism & Depth
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color surface = Color(0xFF1A1F3A);
  static const Color surfaceLight = Color(0xFF252B4A);
  static const Color surfaceElevated = Color(0xFF2D3455);

  // ═══════════════════════════════════════════════════════════════════════════
  // ACCENT COLORS - Vibrant Gold & Gradient
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color accent = Color(0xFFFFD700);
  static const Color accentDark = Color(0xFFFFB800);
  static const Color accentLight = Color(0xFFFFE44D);

  // Accent gradients
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFFB800)],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIMARY COLORS - Modern Blue
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color primary = Color(0xFF4A90E2);
  static const Color primaryDark = Color(0xFF2E5C8A);
  static const Color primaryLight = Color(0xFF6BA3F0);

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT COLORS - High Contrast
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFFB8C5D6);
  static const Color textMuted = Color(0xFF7A8A9B);
  static const Color textSecondary = Color(0xFF9BA8B8);

  // ═══════════════════════════════════════════════════════════════════════════
  // STATUS COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // ═══════════════════════════════════════════════════════════════════════════
  // NAVIGATION BAR - Glassmorphism
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color navBarBg = Color(0xFF0F1525);
  static const Color navBarActive = Color(0xFFFFD700);
  static const Color navBarInactive = Color(0xFF6B7A8F);

  // Nav bar gradient
  static const LinearGradient navBarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F1525), Color(0xFF0A0E1A)],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SHADOWS & ELEVATION
  // ═══════════════════════════════════════════════════════════════════════════
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 6,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get navBarShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 20,
      offset: const Offset(0, -4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: accent.withValues(alpha: 0.4),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
}

/// Main Dashboard with Bottom Navigation
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    // Initialize notification controller for unread count
    Get.put(NotificationController());

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            HomeTab(), // 0 - Home (center button)
            VoteTab(), // 1 - Ballot
            ResultsTab(), // 2 - Results
            BlogTab(), // 3 - Blog
            ProfileTab(), // 4 - Profile
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: DashboardColors.navBarBg,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 15,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left items: Ballot, Blog
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          index: 1,
                          icon: Icons.ballot_outlined,
                          label: 'Ballot',
                          isSelected: controller.currentIndex.value == 1,
                          onTap: () => controller.changeTab(1),
                        ),
                        _buildNavItem(
                          index: 3,
                          icon: Icons.article_outlined,
                          label: 'Blog',
                          isSelected: controller.currentIndex.value == 3,
                          onTap: () => controller.changeTab(3),
                        ),
                      ],
                    ),
                  ),
                  // Center floating button - Home
                  _buildCenterButton(
                    isSelected: controller.currentIndex.value == 0,
                    onTap: () => controller.changeTab(0),
                  ),
                  // Right items: Results, Profile
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          index: 2,
                          icon: Icons.bar_chart_rounded,
                          label: 'Results',
                          isSelected: controller.currentIndex.value == 2,
                          onTap: () => controller.changeTab(2),
                        ),
                        _buildNavItem(
                          index: 4,
                          icon: Icons.person_outline_rounded,
                          label: 'Profile',
                          isSelected: controller.currentIndex.value == 4,
                          onTap: () => controller.changeTab(4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? DashboardColors.navBarActive
                  : DashboardColors.navBarInactive,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? DashboardColors.navBarActive
                    : DashboardColors.navBarInactive,
                height: 1.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton({
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: DashboardColors.accent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: DashboardColors.accent.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          color: Colors.black,
          size: 28,
        ),
      ),
    );
  }
}
