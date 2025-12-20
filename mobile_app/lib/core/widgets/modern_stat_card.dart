import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';

/// Modern Statistics Card
class ModernStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? comparison;
  final String? status;
  final IconData? icon;
  final Color? iconColor;
  final bool showComparison;

  const ModernStatCard({
    super.key,
    required this.label,
    required this.value,
    this.comparison,
    this.status,
    this.icon,
    this.iconColor,
    this.showComparison = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DashboardColors.backgroundDark, DashboardColors.background],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DashboardColors.surfaceElevated.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor ?? DashboardColors.accent, size: 24),
            const SizedBox(height: 12),
          ],
          Text(
            label,
            style: TextStyle(
              color: DashboardColors.textGray,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: DashboardColors.textWhite,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          if (showComparison && comparison != null) ...[
            const SizedBox(height: 6),
            Text(
              comparison!,
              style: const TextStyle(
                color: DashboardColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (status != null) ...[
            const SizedBox(height: 6),
            Text(
              status!,
              style: const TextStyle(
                color: DashboardColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
