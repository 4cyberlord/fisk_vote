import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';

/// Modern Badge Widget
class ModernBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final bool useGradient;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const ModernBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.useGradient = false,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: useGradient ? DashboardColors.accentGradient : null,
        color: useGradient
            ? null
            : (backgroundColor ?? DashboardColors.surface),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: !useGradient && backgroundColor == null
            ? Border.all(
                color: DashboardColors.surfaceElevated.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
        boxShadow: useGradient
            ? [
                BoxShadow(
                  color: DashboardColors.accent.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color:
              textColor ??
              (useGradient ? Colors.black : DashboardColors.textWhite),
          fontSize: fontSize ?? 11,
          fontWeight: fontWeight ?? FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
