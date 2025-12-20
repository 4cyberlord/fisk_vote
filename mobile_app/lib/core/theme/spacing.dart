import 'package:flutter/material.dart';

/// FiskPulse Spacing System
///
/// Consistent spacing values for padding, margins, and gaps.
/// Uses an 8-point grid system for visual harmony.
///
/// ## 8-Point Grid System
///
/// All spacing values are multiples of 4 or 8:
/// - 4px (XS) - Minimal spacing
/// - 8px (SM) - Small spacing
/// - 16px (MD) - Standard spacing
/// - 24px (LG) - Large spacing
/// - 32px (XL) - Extra large spacing
///
/// ## Usage
///
/// ```dart
/// // Padding
/// Padding(padding: AppSpacing.allMD)
/// Padding(padding: AppSpacing.horizontalLG)
///
/// // SizedBox gaps
/// AppSpacing.gapSM
/// AppSpacing.gapMD
/// ```
class AppSpacing {
  AppSpacing._(); // Private constructor

  // ════════════════════════════════════════════════════════════════════════════
  // RAW VALUES
  // ════════════════════════════════════════════════════════════════════════════

  /// 4 pixels
  static const double xs = 4.0;

  /// 8 pixels
  static const double sm = 8.0;

  /// 12 pixels
  static const double md12 = 12.0;

  /// 16 pixels (base unit)
  static const double md = 16.0;

  /// 20 pixels
  static const double lg20 = 20.0;

  /// 24 pixels
  static const double lg = 24.0;

  /// 32 pixels
  static const double xl = 32.0;

  /// 40 pixels
  static const double xxl = 40.0;

  /// 48 pixels
  static const double xxxl = 48.0;

  /// 64 pixels
  static const double huge = 64.0;

  // ════════════════════════════════════════════════════════════════════════════
  // EDGE INSETS - ALL SIDES
  // ════════════════════════════════════════════════════════════════════════════

  /// All sides: 4px
  static const EdgeInsets allXS = EdgeInsets.all(xs);

  /// All sides: 8px
  static const EdgeInsets allSM = EdgeInsets.all(sm);

  /// All sides: 12px
  static const EdgeInsets allMD12 = EdgeInsets.all(md12);

  /// All sides: 16px
  static const EdgeInsets allMD = EdgeInsets.all(md);

  /// All sides: 24px
  static const EdgeInsets allLG = EdgeInsets.all(lg);

  /// All sides: 32px
  static const EdgeInsets allXL = EdgeInsets.all(xl);

  // ════════════════════════════════════════════════════════════════════════════
  // EDGE INSETS - HORIZONTAL
  // ════════════════════════════════════════════════════════════════════════════

  /// Horizontal: 4px
  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: xs);

  /// Horizontal: 8px
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);

  /// Horizontal: 16px
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);

  /// Horizontal: 24px
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);

  /// Horizontal: 32px
  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(horizontal: xl);

  // ════════════════════════════════════════════════════════════════════════════
  // EDGE INSETS - VERTICAL
  // ════════════════════════════════════════════════════════════════════════════

  /// Vertical: 4px
  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);

  /// Vertical: 8px
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);

  /// Vertical: 16px
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);

  /// Vertical: 24px
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);

  /// Vertical: 32px
  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: xl);

  // ════════════════════════════════════════════════════════════════════════════
  // EDGE INSETS - COMMON COMBINATIONS
  // ════════════════════════════════════════════════════════════════════════════

  /// Page padding: horizontal 16px, vertical 24px
  static const EdgeInsets page = EdgeInsets.symmetric(
    horizontal: md,
    vertical: lg,
  );

  /// Card padding: all 16px
  static const EdgeInsets card = EdgeInsets.all(md);

  /// Card compact padding: all 12px
  static const EdgeInsets cardCompact = EdgeInsets.all(md12);

  /// List item padding: horizontal 16px, vertical 12px
  static const EdgeInsets listItem = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md12,
  );

  /// Button padding: horizontal 24px, vertical 12px
  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md12,
  );

  /// Input field content padding
  static const EdgeInsets inputContent = EdgeInsets.symmetric(
    horizontal: md,
    vertical: 14,
  );

  /// Dialog content padding
  static const EdgeInsets dialogContent = EdgeInsets.fromLTRB(lg, md, lg, lg);

  // ════════════════════════════════════════════════════════════════════════════
  // SIZED BOX GAPS (Vertical)
  // ════════════════════════════════════════════════════════════════════════════

  /// Vertical gap: 4px
  static const SizedBox gapXS = SizedBox(height: xs);

  /// Vertical gap: 8px
  static const SizedBox gapSM = SizedBox(height: sm);

  /// Vertical gap: 12px
  static const SizedBox gapMD12 = SizedBox(height: md12);

  /// Vertical gap: 16px
  static const SizedBox gapMD = SizedBox(height: md);

  /// Vertical gap: 24px
  static const SizedBox gapLG = SizedBox(height: lg);

  /// Vertical gap: 32px
  static const SizedBox gapXL = SizedBox(height: xl);

  /// Vertical gap: 48px
  static const SizedBox gapXXL = SizedBox(height: xxxl);

  // ════════════════════════════════════════════════════════════════════════════
  // SIZED BOX GAPS (Horizontal)
  // ════════════════════════════════════════════════════════════════════════════

  /// Horizontal gap: 4px
  static const SizedBox hGapXS = SizedBox(width: xs);

  /// Horizontal gap: 8px
  static const SizedBox hGapSM = SizedBox(width: sm);

  /// Horizontal gap: 12px
  static const SizedBox hGapMD12 = SizedBox(width: md12);

  /// Horizontal gap: 16px
  static const SizedBox hGapMD = SizedBox(width: md);

  /// Horizontal gap: 24px
  static const SizedBox hGapLG = SizedBox(width: lg);

  /// Horizontal gap: 32px
  static const SizedBox hGapXL = SizedBox(width: xl);

  // ════════════════════════════════════════════════════════════════════════════
  // BORDER RADIUS
  // ════════════════════════════════════════════════════════════════════════════

  /// Small radius: 4px
  static const BorderRadius radiusSM = BorderRadius.all(Radius.circular(4));

  /// Medium radius: 8px
  static const BorderRadius radiusMD = BorderRadius.all(Radius.circular(8));

  /// Large radius: 12px
  static const BorderRadius radiusLG = BorderRadius.all(Radius.circular(12));

  /// Extra large radius: 16px
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(16));

  /// Pill/full radius
  static const BorderRadius radiusFull = BorderRadius.all(
    Radius.circular(9999),
  );

  /// Top-only radius (for bottom sheets, etc.)
  static const BorderRadius radiusTopLG = BorderRadius.vertical(
    top: Radius.circular(16),
  );

  /// Bottom-only radius
  static const BorderRadius radiusBottomLG = BorderRadius.vertical(
    bottom: Radius.circular(16),
  );

  // ════════════════════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ════════════════════════════════════════════════════════════════════════════

  /// Create symmetric padding
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  /// Create custom padding
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
  }

  /// Create circular border radius
  static BorderRadius circular(double radius) {
    return BorderRadius.circular(radius);
  }
}
