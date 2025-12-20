import 'package:flutter/material.dart';

import 'colors.dart';

/// FiskPulse Typography System
///
/// Single source of truth for all text styles.
/// Follows Material Design 3 guidelines with custom refinements.
///
/// ## Typography Hierarchy
///
/// ```
/// Display Large (32px) ─────────────── LOUDEST
/// Display Medium (28px)
/// Display Small (24px)
/// Headline Large (20px)
/// Headline Medium (18px)
/// Headline Small (16px)
/// Body Large (16px) ────────────────── MEDIUM
/// Body Medium (14px)
/// Body Small (12px)
/// Label Large (14px) ────────────────── QUIETEST
/// Label Medium (12px)
/// Label Small (11px)
/// ```
///
/// ## Usage
///
/// ```dart
/// // ✅ GOOD - Use predefined styles
/// Text('Title', style: AppTextStyles.headlineLarge)
///
/// // ❌ BAD - Hardcoded styles
/// Text('Title', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))
/// ```
///
/// ## Line Height Guide
///
/// | Size | Height | Purpose |
/// |------|--------|---------|
/// | Large text | 1.2 | Tight, elegant for headlines |
/// | Medium text | 1.3-1.4 | Balanced for headers |
/// | Body text | 1.5 | Loose for readability |
class AppTextStyles {
  AppTextStyles._(); // Private constructor

  // ════════════════════════════════════════════════════════════════════════════
  // FONT FAMILY
  // ════════════════════════════════════════════════════════════════════════════

  /// Default font family (uses system font)
  /// Can be changed to custom font like 'Inter', 'Roboto', etc.
  static const String fontFamily = 'Roboto';

  // ════════════════════════════════════════════════════════════════════════════
  // DISPLAY STYLES (Large Headlines)
  // ════════════════════════════════════════════════════════════════════════════
  // Purpose: Large headlines for maximum emphasis
  // Usage: App title, major section headers
  // Weight: Bold (700)

  /// Display Large - 32px, Bold
  ///
  /// The biggest, most prominent style.
  /// Use for: App title, page headline, hero section
  /// Example: "FiskPulse" title, "VOTING OPEN" banner
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2, // Line height: 38.4px
    letterSpacing: -0.5, // Tight, elegant
    color: AppColors.textPrimary,
  );

  /// Display Medium - 28px, Bold
  ///
  /// Large emphasis, smaller than displayLarge.
  /// Use for: Section headers, important announcements
  /// Example: "2024 Elections", "Results Available"
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2, // Line height: 33.6px
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  /// Display Small - 24px, Bold
  ///
  /// Smallest display style, still prominent.
  /// Use for: Subsection headers, featured content
  /// Example: "Vote Now", "Your Vote Counts"
  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.2, // Line height: 28.8px
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // ════════════════════════════════════════════════════════════════════════════
  // HEADLINE STYLES (Section Titles)
  // ════════════════════════════════════════════════════════════════════════════
  // Purpose: Section titles and important labels
  // Usage: Card headers, form section titles
  // Weight: SemiBold (600)

  /// Headline Large - 20px, SemiBold
  ///
  /// Top-level headline for important sections.
  /// Use for: Card title, dialog title, page section header
  /// Example: "Election Details", "Candidate Information"
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3, // Line height: 26px
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  /// Headline Medium - 18px, SemiBold
  ///
  /// Mid-level headline for secondary headers.
  /// Use for: Subsection title, form group title
  /// Example: "Personal Information", "Vote Summary"
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3, // Line height: 23.4px
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  /// Headline Small - 16px, SemiBold
  ///
  /// Smallest headline for item headers.
  /// Use for: List item title, card header
  /// Example: "Candidate Name", "Election Status"
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3, // Line height: 20.8px
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  // ════════════════════════════════════════════════════════════════════════════
  // BODY STYLES (Main Content)
  // ════════════════════════════════════════════════════════════════════════════
  // Purpose: Paragraphs, descriptions, normal reading text
  // Usage: Reading content, explanations
  // Weight: Regular (400)

  /// Body Large - 16px, Regular
  ///
  /// Large body text for main content.
  /// Use for: Paragraphs, descriptions, important text
  /// Example: Election descriptions, instructions
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5, // Line height: 24px (very readable)
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  /// Body Medium - 14px, Regular
  ///
  /// Standard body text for most content.
  /// Use for: Form labels, descriptions, secondary content
  /// Example: "Last updated: 2 hours ago"
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5, // Line height: 21px
    letterSpacing: 0.25,
    color: AppColors.textPrimary,
  );

  /// Body Small - 12px, Regular
  ///
  /// Small body text for secondary content.
  /// Use for: Captions, timestamps, secondary info
  /// Example: "Posted 2 hours ago", helper text
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5, // Line height: 18px
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  // ════════════════════════════════════════════════════════════════════════════
  // LABEL STYLES (Buttons, Badges)
  // ════════════════════════════════════════════════════════════════════════════
  // Purpose: Button text, badges, chips, tags
  // Usage: Interactive elements
  // Weight: Medium (500)

  /// Label Large - 14px, Medium
  ///
  /// Large button text, primary CTA.
  /// Use for: Main buttons, important actions
  /// Example: "VOTE NOW", "SUBMIT"
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4, // Line height: 19.6px
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  /// Label Medium - 12px, Medium
  ///
  /// Standard button text, secondary actions.
  /// Use for: Secondary buttons, tags, badges
  /// Example: "Cancel", "View More"
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4, // Line height: 16.8px
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  /// Label Small - 11px, Medium
  ///
  /// Small button text, minimal actions.
  /// Use for: Small buttons, small badges
  /// Example: Close button, small tags
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4, // Line height: 15.4px
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  // ════════════════════════════════════════════════════════════════════════════
  // SPECIAL STYLES (Semantic)
  // ════════════════════════════════════════════════════════════════════════════
  // Purpose: Specific use cases with predefined styling
  // Usage: Errors, hints, disabled states

  /// Error message style - Red, 12px
  ///
  /// Used for: Form validation errors, error messages
  /// Example: "This field is required", "Invalid email"
  static const TextStyle errorText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.4,
    color: AppColors.error,
  );

  /// Success message style - Green, 12px
  ///
  /// Used for: Success messages, confirmations
  /// Example: "Vote submitted!", "Profile updated"
  static const TextStyle successText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.4,
    color: AppColors.success,
  );

  /// Warning message style - Amber, 12px
  ///
  /// Used for: Warning messages, cautions
  /// Example: "Session expiring soon"
  static const TextStyle warningText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.4,
    color: AppColors.warning,
  );

  /// Hint/placeholder style - Gray, 14px
  ///
  /// Used for: Text field placeholders, hints
  /// Example: "Enter your email address"
  static const TextStyle hintText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
    color: AppColors.textHint,
  );

  /// Disabled text style - Light gray, 14px
  ///
  /// Used for: Disabled buttons, inactive elements
  static const TextStyle disabledText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
    color: AppColors.textDisabled,
  );

  /// Link text style - Primary color, 14px
  ///
  /// Used for: Clickable links, text buttons
  /// Example: "Forgot password?", "Learn more"
  static const TextStyle linkText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.25,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );

  /// Caption style - Small gray text
  ///
  /// Used for: Image captions, fine print
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  /// Overline style - Small uppercase
  ///
  /// Used for: Category labels, section overlines
  /// Example: "FEATURED ELECTION"
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );

  // ════════════════════════════════════════════════════════════════════════════
  // BUTTON TEXT STYLES
  // ════════════════════════════════════════════════════════════════════════════

  /// Primary button text (white on primary)
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.white,
  );

  /// Secondary button text (primary color)
  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.primary,
  );

  /// Text button style
  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.primary,
  );

  // ════════════════════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ════════════════════════════════════════════════════════════════════════════

  /// Get a style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Get a style with custom weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Get a style as bold
  static TextStyle bold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.bold);
  }

  /// Get a style as italic
  static TextStyle italic(TextStyle style) {
    return style.copyWith(fontStyle: FontStyle.italic);
  }

  /// Get TextTheme for ThemeData
  static TextTheme get textTheme => const TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
