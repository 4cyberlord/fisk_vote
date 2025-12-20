import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';

/// Modern Card Widget with gradient and shadow
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final List<Color>? gradientColors;
  final Color? borderColor;
  final double? borderWidth;
  final List<BoxShadow>? boxShadow;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius,
    this.gradientColors,
    this.borderColor,
    this.borderWidth,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final cardDecoration = BoxDecoration(
      gradient: gradientColors != null
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors!,
            )
          : null,
      color: gradientColors == null ? DashboardColors.surface : null,
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      border: Border.all(
        color:
            borderColor ??
            DashboardColors.surfaceElevated.withValues(alpha: 0.2),
        width: borderWidth ?? 1,
      ),
      boxShadow: boxShadow ?? DashboardColors.cardShadow,
    );

    Widget cardContent = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: cardDecoration,
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(20),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
