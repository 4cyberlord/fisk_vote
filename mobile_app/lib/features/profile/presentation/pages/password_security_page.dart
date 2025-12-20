import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/password_security_controller.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import 'recent_activity_page.dart';

class PasswordSecurityPage extends StatelessWidget {
  const PasswordSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PasswordSecurityController());

    return Scaffold(
      backgroundColor: DashboardColors.background,
      appBar: AppBar(
        backgroundColor: DashboardColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: DashboardColors.textWhite,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Password & Security',
          style: TextStyle(
            color: DashboardColors.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: DashboardColors.accent),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChangePasswordCard(context, controller),
              const SizedBox(height: 24),
              _buildEnhancedSecuritySection(),
              const SizedBox(height: 24),
              _buildRecentActivitySection(controller),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildChangePasswordCard(
    BuildContext context,
    PasswordSecurityController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 20,
                decoration: BoxDecoration(
                  color: DashboardColors.accent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Change Password',
                style: TextStyle(
                  color: DashboardColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPasswordField(
            label: 'Current Password',
            icon: Icons.lock_outline,
            controller: controller.currentPasswordController,
            visibility: controller.showCurrentPassword,
          ),
          const SizedBox(height: 20),
          _buildPasswordField(
            label: 'New Password',
            icon: Icons.key_outlined,
            controller: controller.newPasswordController,
            visibility: controller.showNewPassword,
            onChanged: (value) => controller.calculateStrength(value),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Strength bars
                Row(
                  children: List.generate(4, (index) {
                    final threshold = (index + 1) * 0.25;
                    final active = controller.strength.value >= threshold;
                    return Expanded(
                      child: Container(
                        height: 6,
                        margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
                        decoration: BoxDecoration(
                          color: active
                              ? controller.strengthColor.value
                              : DashboardColors.backgroundDark,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  'Strength: ${controller.strengthLabel.value}',
                  style: TextStyle(
                    color: controller.strengthColor.value,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildPasswordField(
            label: 'Confirm New Password',
            icon: Icons.key_outlined,
            controller: controller.confirmPasswordController,
            visibility: controller.showConfirmPassword,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isUpdating.value
                    ? null
                    : () => controller.changePassword(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DashboardColors.accent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: DashboardColors.accent.withValues(
                    alpha: 0.5,
                  ),
                ),
                child: controller.isUpdating.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Update Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required RxBool visibility,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: DashboardColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2F3B57), // match login input background
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: controller,
              obscureText: !visibility.value,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: DashboardColors.textWhite,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF2F3B57),
                hintText: '********',
                hintStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: DashboardColors.textGray.withValues(alpha: 0.7),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Icon(icon, color: DashboardColors.textGray, size: 20),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                suffixIcon: IconButton(
                  padding: const EdgeInsets.only(right: 12),
                  icon: Icon(
                    visibility.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: DashboardColors.textGray,
                    size: 20,
                  ),
                  onPressed: () => visibility.value = !visibility.value,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedSecuritySection() {
    return Container(
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 20,
                decoration: BoxDecoration(
                  color: DashboardColors.accent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Enhanced Security',
                style: TextStyle(
                  color: DashboardColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Coming Soon',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDisabledCard(
            icon: Icons.verified_user_outlined,
            title: 'Two-Factor Auth',
            subtitle: 'Secure your account via SMS code.',
          ),
          const SizedBox(height: 12),
          _buildDisabledCard(
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            subtitle: 'Use FaceID to sign in quickly.',
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: DashboardColors.backgroundDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DashboardColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: DashboardColors.textWhite, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: DashboardColors.textWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: DashboardColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.lock_outline,
            color: DashboardColors.textGray,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(PasswordSecurityController controller) {
    final stats = controller.statistics;
    final logs = controller.auditLogs;

    return Container(
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 20,
                decoration: BoxDecoration(
                  color: DashboardColors.accent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Recent Activity',
                style: TextStyle(
                  color: DashboardColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Get.to(() => const RecentActivityPage()),
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: DashboardColors.textWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatsRow(stats),
          const SizedBox(height: 12),
          if (logs.isEmpty)
            _buildEmptyLogs()
          else
            Column(
              children: logs.take(3).map((log) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildLogItem(log),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> stats) {
    int safe(String key) => (stats[key] as int?) ?? 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatBox('Success', safe('successful_logins'), Colors.green),
        _buildStatBox('Failed', safe('failed_attempts'), Colors.redAccent),
        _buildStatBox('Unique IPs', safe('unique_ips'), Colors.blueAccent),
        _buildStatBox('Activities', safe('total_activities'), Colors.orange),
      ],
    );
  }

  Widget _buildStatBox(String label, int value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: DashboardColors.backgroundDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: DashboardColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyLogs() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DashboardColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'No recent activity found.',
        style: TextStyle(color: DashboardColors.textMuted, fontSize: 13),
      ),
    );
  }

  Widget _buildLogItem(Map<String, dynamic> log) {
    final device = log['device'] ?? 'Unknown device';
    final location = log['location'] ?? 'Unknown location';
    final status = (log['status'] ?? 'active').toString().toLowerCase();
    final timestamp = log['timestamp'] ?? '';

    Color statusColor;
    if (status.contains('fail')) {
      statusColor = Colors.red;
    } else if (status.contains('active') || status.contains('current')) {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.blueAccent;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DashboardColors.backgroundDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DashboardColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.devices_other_outlined,
                  color: DashboardColors.textWhite,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            device,
                            style: const TextStyle(
                              color: DashboardColors.textWhite,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            status[0].toUpperCase() + status.substring(1),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: TextStyle(
                        color: DashboardColors.textMuted,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          timestamp,
                          style: TextStyle(
                            color: DashboardColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
