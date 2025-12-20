import 'package:flutter/material.dart' hide Notification;
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../data/models/notification.dart';
import '../controllers/notification_controller.dart';

/// Activity/Notifications Page
class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use existing controller or create new one
    final controller = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(controller),
            // Filter buttons
            _buildFilterButtons(controller),
            // Notifications list
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.notifications.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: DashboardColors.accent,
                    ),
                  );
                }

                if (controller.error.value.isNotEmpty &&
                    controller.notifications.isEmpty) {
                  return _buildErrorView(controller);
                }

                if (controller.notifications.isEmpty) {
                  return _buildEmptyView();
                }

                return _buildNotificationsList(controller);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(NotificationController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Get.back();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DashboardColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: DashboardColors.textWhite,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          const Expanded(
            child: Text(
                'Activity',
                style: TextStyle(
                  color: DashboardColors.textWhite,
                fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ),
          // Mark all as read button
          Obx(
            () => GestureDetector(
              onTap: controller.unreadCount.value > 0
                  ? () {
                      HapticFeedback.lightImpact();
                      controller.markAllAsRead();
                      Get.showSnackbar(
                        GetSnackBar(
                          message: 'All notifications marked as read',
                          duration: const Duration(seconds: 2),
                          backgroundColor: DashboardColors.surface,
                          borderRadius: 12,
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      );
                    }
                  : null,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: controller.unreadCount.value > 0
                      ? DashboardColors.accent.withValues(alpha: 0.15)
                      : DashboardColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.done_all_rounded,
                  color: controller.unreadCount.value > 0
                      ? DashboardColors.accent
                      : DashboardColors.textGray,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // More options menu
          PopupMenuButton<String>(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DashboardColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                  color: DashboardColors.textGray,
                size: 20,
              ),
            ),
            color: DashboardColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            offset: const Offset(0, 48),
            onSelected: (value) async {
              HapticFeedback.lightImpact();
              switch (value) {
                case 'clear_read':
                  final success = await controller.deleteAllReadNotifications();
                  Get.showSnackbar(
                    GetSnackBar(
                      message: success 
                          ? 'Cleared all read notifications' 
                          : 'Failed to clear notifications',
                      duration: const Duration(seconds: 2),
                      backgroundColor: DashboardColors.surface,
                      borderRadius: 12,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  );
                  break;
                case 'refresh':
                  await controller.refresh();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_read',
                child: Row(
            children: [
                    Icon(
                      Icons.cleaning_services_rounded,
                  color: DashboardColors.textGray,
                      size: 20,
                ),
                    const SizedBox(width: 12),
                    Text(
                      'Clear read notifications',
                      style: TextStyle(
                        color: DashboardColors.textWhite,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: DashboardColors.textGray,
                      size: 20,
                  ),
                    const SizedBox(width: 12),
                    Text(
                      'Refresh',
                      style: TextStyle(
                        color: DashboardColors.textWhite,
                        fontSize: 14,
                      ),
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

  Widget _buildFilterButtons(NotificationController controller) {
    final filters = ['All', 'Unread', 'Election', 'System'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Obx(() {
        return Row(
        children: filters.map((filter) {
          final isSelected = controller.selectedFilter.value == filter;
          final isUnread = filter == 'Unread';
          final unreadCount = controller.unreadCount.value;

          return Expanded(
            child: Padding(
                padding: EdgeInsets.only(right: filter != 'System' ? 8 : 0),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  controller.changeFilter(filter);
                },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DashboardColors.accent
                        : DashboardColors.surface,
                    borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? DashboardColors.accent
                            : Colors.transparent,
                        width: 1.5,
                      ),
                  ),
                  child: Center(
                    child: Text(
                      isUnread && unreadCount > 0
                          ? '$filter $unreadCount'
                          : filter,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.black
                            : DashboardColors.textWhite,
                        fontSize: 13,
                        fontWeight: isSelected
                              ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        );
      }),
    );
  }

  Widget _buildNotificationsList(NotificationController controller) {
    // Group notifications by date
    // Pass the list directly - method will handle type conversion
    final grouped = _groupNotificationsByDate(
      controller.notifications.toList(),
    );

    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: DashboardColors.accent,
      backgroundColor: DashboardColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: grouped.length,
        itemBuilder: (context, index) {
          final group = grouped[index];
          final notifications = (group['notifications'] as List)
              .cast<Notification>();
          return _buildDateGroup(
            group['date'] as String,
            notifications,
            controller,
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _groupNotificationsByDate(
    List<Notification> notifications,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<Notification>> grouped = {};

    for (final notification in notifications) {
      final createdAt = DateTime.tryParse(notification.createdAt);
      if (createdAt == null) continue;

      final notificationDate = DateTime(
        createdAt.year,
        createdAt.month,
        createdAt.day,
      );
      String dateLabel;

      if (notificationDate == today) {
        dateLabel = 'TODAY';
      } else if (notificationDate == yesterday) {
        dateLabel = 'YESTERDAY';
      } else {
        final months = [
          'JAN',
          'FEB',
          'MAR',
          'APR',
          'MAY',
          'JUN',
          'JUL',
          'AUG',
          'SEP',
          'OCT',
          'NOV',
          'DEC',
        ];
        dateLabel = '${months[createdAt.month - 1]} ${createdAt.day}';
      }

      grouped.putIfAbsent(dateLabel, () => <Notification>[]).add(notification);
    }

    // Sort by date (today first, then yesterday, then others)
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 'TODAY') return -1;
        if (b == 'TODAY') return 1;
        if (a == 'YESTERDAY') return -1;
        if (b == 'YESTERDAY') return 1;
        return b.compareTo(a);
      });

    return sortedKeys
        .map((key) => {'date': key, 'notifications': grouped[key]!})
        .toList();
  }

  Widget _buildDateGroup(
    String date,
    List<Notification> notifications,
    NotificationController controller,
  ) {
    final isToday = date == 'TODAY';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header with colored dot
        Padding(
          padding: const EdgeInsets.only(bottom: 16, top: 8),
          child: Row(
          children: [
              // Colored dot indicator (centered in timeline column)
              SizedBox(
                width: 48,
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
              decoration: BoxDecoration(
                color: isToday
                    ? DashboardColors.accent
                    : DashboardColors.textGray,
                shape: BoxShape.circle,
                    ),
                  ),
              ),
            ),
            const SizedBox(width: 12),
              // Date text
            Text(
              date,
              style: TextStyle(
                  color: isToday
                      ? DashboardColors.accent
                      : DashboardColors.textGray,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        // Notifications with timeline
        ...notifications.asMap().entries.map<Widget>(
          (entry) {
            final index = entry.key;
            final notification = entry.value;
            final isLast = index == notifications.length - 1;
            
            return _buildNotificationWithTimeline(
              notification,
              controller,
              showLine: !isLast,
              dateGroup: date,
              index: index,
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNotificationWithTimeline(
    Notification notification,
    NotificationController controller, {
    required bool showLine,
    required String dateGroup,
    required int index,
  }) {
    final isUnread = !notification.isRead;
    final isUrgent = notification.urgent;
    
    // Create a unique key using notification ID, date group, and a timestamp
    // This ensures uniqueness even after undo operations
    final uniqueKey = ValueKey('${dateGroup}_${notification.id}_${notification.createdAt}');

    return Dismissible(
      key: uniqueKey,
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        // Mark as read first if swiping right
        if (direction == DismissDirection.startToEnd && !notification.isRead) {
          HapticFeedback.mediumImpact();
          await controller.markAsRead(notification);
          return false; // Don't dismiss, just mark as read
        }
        // Delete if swiping left
        if (direction == DismissDirection.endToStart) {
          HapticFeedback.mediumImpact();
          return true;
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          // Store notification for potential undo
          final deletedNotification = notification;
          
          // Delete the notification
          controller.deleteNotification(notification);
          
          // Show snackbar with undo option
          Get.showSnackbar(
            GetSnackBar(
              message: 'Notification deleted',
              duration: const Duration(seconds: 3),
              backgroundColor: DashboardColors.surface,
              borderRadius: 12,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              mainButton: TextButton(
                onPressed: () {
                  Get.closeCurrentSnackbar();
                  controller.undoDelete(deletedNotification);
                },
                child: Text(
                  'UNDO',
                  style: TextStyle(
                    color: DashboardColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }
      },
      background: _buildSwipeBackground(
        isRightSwipe: true,
        isRead: notification.isRead,
      ),
      secondaryBackground: _buildSwipeBackground(
        isRightSwipe: false,
        isRead: notification.isRead,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline column with icon and line
            SizedBox(
              width: 48,
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isUrgent
                          ? DashboardColors.accent
                          : DashboardColors.surfaceLight,
                      borderRadius: isUrgent
                          ? BorderRadius.circular(12)
                          : BorderRadius.circular(24),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type, notification.icon),
                      color: isUrgent ? Colors.black : DashboardColors.textGray,
                      size: 22,
                    ),
                  ),
                  // Timeline line (if not last)
                  if (showLine)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: DashboardColors.surfaceLight.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Card content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildCardContent(notification, controller, isUnread, isUrgent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build swipe action background
  Widget _buildSwipeBackground({
    required bool isRightSwipe,
    required bool isRead,
  }) {
    // Right swipe = mark as read (green/check icon) - only if unread
    // Left swipe = delete (red/trash icon)
    
    final color = isRightSwipe
        ? (isRead ? DashboardColors.surfaceLight : const Color(0xFF2ECC71))
        : const Color(0xFFE74C3C);
    
    final icon = isRightSwipe
        ? (isRead ? Icons.check_circle : Icons.mark_email_read_rounded)
        : Icons.delete_rounded;
    
    final label = isRightSwipe
        ? (isRead ? 'Already read' : 'Mark as read')
        : 'Delete';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Align(
        alignment: isRightSwipe ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: isRightSwipe
                ? [
                    Icon(icon, color: color, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ]
                : [
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
          ),
        ),
                    const SizedBox(width: 8),
                    Icon(icon, color: color, size: 24),
      ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(
    Notification notification,
    NotificationController controller,
    bool isUnread,
    bool isUrgent,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        controller.markAsRead(notification);
        // TODO: Navigate to href if available
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DashboardColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: URGENT badge + unread indicator
                  Row(
                    children: [
                if (isUrgent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: DashboardColors.accent,
                      borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'URGENT',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      const Spacer(),
                // Unread indicator
                if (isUnread)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: DashboardColors.accent,
                      shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
            if (isUrgent || isUnread) const SizedBox(height: 10),
                  // Title
                  Text(
                    notification.title,
                    style: const TextStyle(
                      color: DashboardColors.textWhite,
                fontSize: 17,
                      fontWeight: FontWeight.bold,
                height: 1.3,
                    ),
                  ),
            const SizedBox(height: 8),
                  // Message
            if (notification.message.isNotEmpty)
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: DashboardColors.textGray,
                      fontSize: 14,
                  height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
            const SizedBox(height: 12),
            // Timestamp with clock icon
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: DashboardColors.textGray.withValues(alpha: 0.7),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatTimestamp(notification.createdAt),
                  style: TextStyle(
                    color: DashboardColors.textGray.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                ),
                ),
              ],
              ),
          ],
        ),
      ),
    );
  }

  /// Get appropriate icon based on notification type
  IconData _getNotificationIcon(String type, String iconName) {
    final lowerType = type.toLowerCase();
    
    // Map notification types to appropriate icons
    if (lowerType.contains('vote') || lowerType == 'vote_confirmed') {
      return Icons.how_to_vote_rounded;
    } else if (lowerType.contains('election') || lowerType == 'new_election') {
      return Icons.ballot_rounded;
    } else if (lowerType == 'upcoming' || lowerType == 'closing_soon') {
      return Icons.schedule_rounded;
    } else if (lowerType == 'results_available') {
      return Icons.emoji_events_rounded;
    } else if (lowerType.contains('candidate') || lowerType.contains('profile')) {
      return Icons.person_add_rounded;
    } else if (lowerType.contains('system') || lowerType.contains('setting')) {
      return Icons.settings_rounded;
    }
    
    // Fallback to icon name mapping
    return _getIconData(iconName);
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'bell':
        return Icons.notifications_rounded;
      case 'check-circle':
        return Icons.check_circle_rounded;
      case 'alert-circle':
        return Icons.warning_rounded;
      case 'clock':
        return Icons.access_time_rounded;
      case 'award':
        return Icons.emoji_events_rounded;
      case 'user':
      case 'person':
        return Icons.person_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _formatTimestamp(String createdAt) {
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inDays == 1) {
        final hour = date.hour > 12 ? date.hour - 12 : date.hour;
        final amPm = date.hour >= 12 ? 'PM' : 'AM';
        return 'Yesterday, $hour:${date.minute.toString().padLeft(2, '0')} $amPm';
      } else {
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return '${months[date.month - 1]} ${date.day}';
      }
    } catch (e) {
      return createdAt;
    }
  }

  Widget _buildErrorView(NotificationController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load notifications',
              style: TextStyle(
                color: DashboardColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.error.value,
              style: TextStyle(color: DashboardColors.textGray, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: DashboardColors.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: DashboardColors.textGray,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Notifications',
              style: TextStyle(
                color: DashboardColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: TextStyle(color: DashboardColors.textGray, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
