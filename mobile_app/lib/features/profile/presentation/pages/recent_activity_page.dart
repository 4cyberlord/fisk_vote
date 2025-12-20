import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/password_security_controller.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

class RecentActivityPage extends StatefulWidget {
  const RecentActivityPage({super.key});

  @override
  State<RecentActivityPage> createState() => _RecentActivityPageState();
}

class _RecentActivityPageState extends State<RecentActivityPage> {
  late final PasswordSecurityController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PasswordSecurityController>();
    // Controller already fetches logs in onInit.
    // If we want a refresh on page open, schedule it after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchAuditLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          'Recent Activity',
          style: TextStyle(
            color: DashboardColors.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: DashboardColors.accent),
          );
        }

        final stats = _controller.statistics;
        final logs = _controller.auditLogs;

        return RefreshIndicator(
          onRefresh: _controller.fetchAuditLogs,
          color: DashboardColors.accent,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildStatsCard(stats),
              const SizedBox(height: 20),
              if (logs.isEmpty)
                _buildEmptyState()
              else
                ...logs.map(
                  (log) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildLogItem(log),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    int safe(String key) => (stats[key] as int?) ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
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
                'Security Overview',
                style: TextStyle(
                  color: DashboardColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip(
                label: 'Success',
                value: safe('successful_logins'),
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                label: 'Failed attempts',
                value: safe('failed_attempts'),
                color: Colors.redAccent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatChip(
                label: 'Unique IPs',
                value: safe('unique_ips'),
                color: Colors.blueAccent,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                label: 'Total activities',
                value: safe('total_activities'),
                color: DashboardColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required int value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: DashboardColors.backgroundDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: DashboardColors.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DashboardColors.backgroundDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: DashboardColors.textWhite,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No recent activity',
                  style: TextStyle(
                    color: DashboardColors.textWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We’ll show your login and security events here once you start using the app.',
                  style: TextStyle(
                    color: DashboardColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(Map<String, dynamic> log) {
    final device = log['device'] ?? 'Unknown device';
    final location = log['location'] ?? 'Unknown location';
    final status = (log['status'] ?? 'active').toString().toLowerCase();
    final timestamp =
        log['created_at_human'] ??
        log['created_at_formatted'] ??
        (log['timestamp'] ?? '');

    Color statusColor;
    if (status.contains('fail')) {
      statusColor = Colors.red;
    } else if (status.contains('success') || status.contains('active')) {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.blueAccent;
    }

    final actionDescription =
        log['action_description'] ?? log['action_type'] ?? 'Activity';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DashboardColors.surface,
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
                  color: DashboardColors.backgroundDark,
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
                      actionDescription,
                      style: TextStyle(
                        color: DashboardColors.textGray,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          color: DashboardColors.textMuted,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              color: DashboardColors.textMuted,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: DashboardColors.textMuted,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timestamp,
                          style: TextStyle(
                            color: DashboardColors.textMuted,
                            fontSize: 11,
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
