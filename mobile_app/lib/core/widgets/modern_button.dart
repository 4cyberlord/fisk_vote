import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';

/// Modern Gradient Button
class ModernButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final FontWeight? fontWeight;

  const ModernButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : icon != null
            ? Icon(icon, size: 20)
            : const SizedBox.shrink(),
        label: Text(
          label,
          style: TextStyle(
            fontSize: fontSize ?? 16,
            fontWeight: fontWeight ?? FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: (backgroundColor ?? DashboardColors.accent).withValues(
              alpha: 0.6,
            ),
            width: 2,
          ),
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: backgroundColor == null
            ? DashboardColors.accentGradient
            : null,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: backgroundColor == null
            ? DashboardColors.buttonShadow
            : [
                BoxShadow(
                  color: (backgroundColor ?? DashboardColors.accent).withValues(
                    alpha: 0.4,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading
            ? null
            : () {
                HapticFeedback.mediumImpact();
                onPressed?.call();
              },
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : icon != null
            ? Icon(icon, size: 22, color: textColor ?? Colors.black)
            : const SizedBox.shrink(),
        label: Text(
          label,
          style: TextStyle(
            color: textColor ?? Colors.black,
            fontSize: fontSize ?? 16,
            fontWeight: fontWeight ?? FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: textColor ?? Colors.black,
          shadowColor: Colors.transparent,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
