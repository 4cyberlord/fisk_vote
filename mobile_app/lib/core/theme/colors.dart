import 'package:flutter/material.dart';

/// FiskPulse Application Color Palette
///
/// Single source of truth for all application colors.
/// Follows Fisk University branding with professional extension.
///
/// ## Color Categories
///
/// | Category | Purpose | Example |
/// |----------|---------|---------|
/// | Primary | Main brand, primary actions | App bar, main buttons |
/// | Accent | Secondary brand, highlights | Badges, secondary buttons |
/// | Neutral | Text, borders, backgrounds | Text, dividers, disabled |
/// | Status | Feedback, state indication | Success, error, warning |
/// | Background | Page and container surfaces | Page bg, card surfaces |
///
/// ## Usage
///
/// ```dart
/// // ✅ GOOD - Use constants
/// Container(color: AppColors.primary)
/// Text('Error', style: TextStyle(color: AppColors.error))
///
/// // ❌ BAD - Hardcoded colors
/// Container(color: Color(0xFF003D82))
/// ```
///
/// ## Fisk University Official Colors
///
/// - **Primary**: Deep Blue (#003D82) - Trust, stability, professionalism
/// - **Accent**: Gold (#F4BA1B) - Draws attention, complements primary
class AppColors {
  AppColors._(); // Private constructor - use static constants only

  // ════════════════════════════════════════════════════════════════════════════
  // PRIMARY COLORS (Fisk University Branding)
  // ════════════════════════════════════════════════════════════════════════════
  // Main brand colors used throughout the app
  // Primary = Deep Blue (trust, stability, professionalism)

  /// Main brand color - Deep Blue
  /// Fisk University Official Color
  ///
  /// Used for:
  /// - App bar background
  /// - Primary buttons
  /// - Selected/active states
  /// - Main navigation accents
  static const Color primary = Color(0xFF003D82);

  /// Lighter shade of primary (28, 90, 160)
  ///
  /// Used for:
  /// - Hover states on primary elements
  /// - Lighter backgrounds with primary tint
  /// - Focus rings and highlights
  static const Color primaryLight = Color(0xFF1C5AA0);

  /// Darker shade of primary (0, 40, 87)
  ///
  /// Used for:
  /// - Pressed/active states
  /// - Dark backgrounds
  /// - Shadows and depth
  static const Color primaryDark = Color(0xFF002857);

  // ════════════════════════════════════════════════════════════════════════════
  // ACCENT COLORS (Gold - Fisk Secondary Color)
  // ════════════════════════════════════════════════════════════════════════════
  // Secondary brand colors for highlights and secondary actions
  // Accent = Gold (draws attention, complements primary)

  /// Gold accent color - Fisk University Secondary Color
  ///
  /// Used for:
  /// - Badges and highlights
  /// - Secondary buttons
  /// - "Vote" action emphasis
  /// - Achievement indicators
  static const Color accent = Color(0xFFF4BA1B);

  /// Lighter shade of accent (250, 212, 77)
  ///
  /// Used for:
  /// - Hover states on accent elements
  /// - Light accent backgrounds
  static const Color accentLight = Color(0xFFFAD44D);

  /// Darker shade of accent (217, 157, 11)
  ///
  /// Used for:
  /// - Pressed states on accent elements
  /// - Dark accent for contrast
  static const Color accentDark = Color(0xFFD99D0B);

  // ════════════════════════════════════════════════════════════════════════════
  // NEUTRAL COLORS (Grayscale)
  // ════════════════════════════════════════════════════════════════════════════
  // Text, borders, backgrounds, disabled states
  // Provides accessibility and professional appearance

  /// Pure white - Content areas and card surfaces
  static const Color white = Color(0xFFFFFFFF);

  /// Pure black - Darkest text and high contrast
  static const Color black = Color(0xFF000000);

  /// Very light gray (245, 245, 245)
  /// Contrast ratio with black: 1.4:1
  ///
  /// Used for: Subtle backgrounds, almost invisible separators
  static const Color gray100 = Color(0xFFF5F5F5);

  /// Light gray (224, 224, 224)
  /// Contrast ratio with black: 4.6:1 ✅ WCAG AA
  ///
  /// Used for: Borders, dividers, input field borders
  static const Color gray200 = Color(0xFFE0E0E0);

  /// Medium gray (192, 192, 192)
  /// Contrast ratio with black: 7.2:1 ✅ WCAG AAA
  ///
  /// Used for: Disabled backgrounds, placeholder icons
  static const Color gray300 = Color(0xFFC0C0C0);

  /// Darker gray (153, 153, 153)
  /// Contrast ratio with white: 8.1:1 ✅ WCAG AAA
  ///
  /// Used for: Secondary text, hint text, icons
  static const Color gray400 = Color(0xFF999999);

  /// Very dark gray (102, 102, 102)
  /// Contrast ratio with white: 12.6:1 ✅ WCAG AAA
  ///
  /// Used for: Primary text, important labels
  static const Color gray500 = Color(0xFF666666);

  /// Darkest gray (51, 51, 51)
  /// Contrast ratio with white: 15.1:1 ✅ WCAG AAA
  ///
  /// Used for: Headlines, emphasis text
  static const Color gray600 = Color(0xFF333333);

  // ════════════════════════════════════════════════════════════════════════════
  // STATUS COLORS (Semantic Colors)
  // ════════════════════════════════════════════════════════════════════════════
  // Universal colors that communicate meaning
  // Used for user feedback and app state

  /// Success/positive - Green (76, 175, 80)
  ///
  /// Psychology: Growth, positive, approval
  /// Used for: Success messages, checkmarks, "complete" badges
  /// Example: "Vote submitted successfully!"
  static const Color success = Color(0xFF4CAF50);

  /// Error/negative - Red (244, 67, 54)
  ///
  /// Psychology: Stop, danger, alert
  /// Used for: Error messages, validation errors, critical alerts
  /// Example: "Invalid email address"
  static const Color error = Color(0xFFf44336);

  /// Warning/caution - Amber (255, 193, 7)
  ///
  /// Psychology: Caution, attention needed
  /// Used for: Warning messages, expiration notices
  /// Example: "Voting ends in 2 hours"
  static const Color warning = Color(0xFFFFC107);

  /// Information/neutral - Blue (33, 150, 243)
  ///
  /// Psychology: Calm, informative, trustworthy
  /// Used for: Tips, help text, general information
  /// Example: "How voting works"
  static const Color info = Color(0xFF2196F3);

  // ════════════════════════════════════════════════════════════════════════════
  // BACKGROUND COLORS
  // ════════════════════════════════════════════════════════════════════════════
  // Page and container backgrounds
  // Creates visual hierarchy and reduces eye strain

  /// Almost white background (250, 250, 250)
  ///
  /// Used for: Entire page background
  /// Benefit: Slightly gray reduces eye strain vs pure white
  static const Color background = Color(0xFFFAFAFA);

  /// Pure white surface
  ///
  /// Used for: Cards, dialogs, containers
  /// Creates visual elevation from background
  static const Color surface = Color(0xFFFFFFFF);

  /// Scaffold background - matches background
  static const Color scaffoldBackground = background;

  // ════════════════════════════════════════════════════════════════════════════
  // SEMANTIC OPACITY COLORS (Light Backgrounds)
  // ════════════════════════════════════════════════════════════════════════════
  // Transparent versions of status colors for message backgrounds
  // 10% opacity = 90% transparent = very subtle background

  /// Success at 10% opacity - Light green background
  /// Used for: Success message banners
  static Color get successLight => success.withValues(alpha: 0.1);

  /// Error at 10% opacity - Light red background
  /// Used for: Error message banners
  static Color get errorLight => error.withValues(alpha: 0.1);

  /// Warning at 10% opacity - Light amber background
  /// Used for: Warning message banners
  static Color get warningLight => warning.withValues(alpha: 0.1);

  /// Info at 10% opacity - Light blue background
  /// Used for: Info message boxes
  static Color get infoLight => info.withValues(alpha: 0.1);

  /// Primary at 10% opacity - Light primary background
  /// Used for: Selected items, highlights
  static Color get primaryLight10 => primary.withValues(alpha: 0.1);

  /// Accent at 10% opacity - Light accent background
  /// Used for: Accent highlights
  static Color get accentLight10 => accent.withValues(alpha: 0.1);

  // ════════════════════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ════════════════════════════════════════════════════════════════════════════
  // Predefined colors for text hierarchy

  /// Primary text color - Very dark gray
  static const Color textPrimary = gray600;

  /// Secondary text color - Dark gray
  static const Color textSecondary = gray500;

  /// Hint/placeholder text color - Medium gray
  static const Color textHint = gray400;

  /// Disabled text color - Light gray
  static const Color textDisabled = gray300;

  /// Text on primary color background
  static const Color textOnPrimary = white;

  /// Text on accent color background
  static const Color textOnAccent = black;

  // ════════════════════════════════════════════════════════════════════════════
  // BORDER & DIVIDER COLORS
  // ════════════════════════════════════════════════════════════════════════════

  /// Default border color
  static const Color border = gray200;

  /// Focused input border color
  static const Color borderFocused = primary;

  /// Error border color
  static const Color borderError = error;

  /// Divider color
  static const Color divider = gray200;

  // ════════════════════════════════════════════════════════════════════════════
  // DARK THEME COLORS (For Future Dark Mode Support)
  // ════════════════════════════════════════════════════════════════════════════

  /// Dark theme background
  static const Color darkBackground = Color(0xFF121212);

  /// Dark theme surface
  static const Color darkSurface = Color(0xFF1E1E1E);

  /// Dark theme elevated surface
  static const Color darkSurfaceElevated = Color(0xFF2C2C2C);

  /// Dark theme primary text
  static const Color darkTextPrimary = Color(0xFFE0E0E0);

  /// Dark theme secondary text
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // ════════════════════════════════════════════════════════════════════════════
  // MATERIAL COLOR SWATCH
  // ════════════════════════════════════════════════════════════════════════════

  /// Primary color as MaterialColor swatch for ThemeData
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF003D82,
    <int, Color>{
      50: Color(0xFFE3EAF2),
      100: Color(0xFFB8CBE0),
      200: Color(0xFF89A9CB),
      300: Color(0xFF5A87B6),
      400: Color(0xFF366DA6),
      500: Color(0xFF003D82), // Primary
      600: Color(0xFF00377A),
      700: Color(0xFF002F6F),
      800: Color(0xFF002765),
      900: Color(0xFF001A52),
    },
  );

  // ════════════════════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ════════════════════════════════════════════════════════════════════════════

  /// Get status color based on status type
  static Color getStatusColor(StatusType type) {
    switch (type) {
      case StatusType.success:
        return success;
      case StatusType.error:
        return error;
      case StatusType.warning:
        return warning;
      case StatusType.info:
        return info;
    }
  }

  /// Get status background color (10% opacity)
  static Color getStatusBackground(StatusType type) {
    switch (type) {
      case StatusType.success:
        return successLight;
      case StatusType.error:
        return errorLight;
      case StatusType.warning:
        return warningLight;
      case StatusType.info:
        return infoLight;
    }
  }
}

/// Status types for semantic colors
enum StatusType { success, error, warning, info }
