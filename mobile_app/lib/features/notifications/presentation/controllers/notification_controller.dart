import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../data/repositories/notification_repository.dart';
import '../../data/models/notification.dart';

/// Notification Controller
class NotificationController extends GetxController {
  final NotificationRepository _repository = NotificationRepository();

  // Observable states
  final RxList<Notification> notifications = <Notification>[].obs;
  final RxList<Notification> _allNotifications = <Notification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    loadUnreadCount();
    _startPeriodicRefresh();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (Get.isRegistered<NotificationController>()) {
        loadNotifications();
        loadUnreadCount();
      } else {
        timer.cancel();
      }
    });
  }

  /// Load all notifications from API
  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Always fetch all notifications from API
      final response = await _repository.getNotifications(
        unreadOnly: null,
        urgentOnly: null,
      );

      _allNotifications.value = response.data;
      
      // Apply local filter
      _applyFilter();
      
      debugPrint('📬 Loaded ${response.data.length} notifications, filtered to ${notifications.length}');
    } catch (e) {
      error.value = e.toString();
      debugPrint('❌ Failed to load notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Apply filter to notifications based on selectedFilter
  void _applyFilter() {
    switch (selectedFilter.value) {
      case 'All':
        notifications.value = _allNotifications.toList();
        break;
      case 'Unread':
        notifications.value = _allNotifications.where((n) => !n.isRead).toList();
        break;
      case 'Election':
        notifications.value = _allNotifications.where((n) {
          final type = n.type.toLowerCase();
          return type.contains('election') ||
              type.contains('vote') ||
              type == 'new_election' ||
              type == 'upcoming' ||
              type == 'closing_soon' ||
              type == 'vote_confirmed' ||
              type == 'results_available' ||
              type == 'candidate';
        }).toList();
        break;
      case 'System':
        notifications.value = _allNotifications.where((n) {
          final type = n.type.toLowerCase();
          // System = everything that's NOT election-related
          return !type.contains('election') &&
              !type.contains('vote') &&
              type != 'new_election' &&
              type != 'upcoming' &&
              type != 'closing_soon' &&
              type != 'vote_confirmed' &&
              type != 'results_available' &&
              type != 'candidate';
        }).toList();
        break;
      default:
        notifications.value = _allNotifications.toList();
    }
  }

  /// Load unread count
  Future<void> loadUnreadCount() async {
    try {
      final response = await _repository.getUnreadCount();
      unreadCount.value = response.data.totalCount;
    } catch (e) {
      // Silently fail for unread count
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(Notification notification) async {
    if (notification.isRead) return;

    try {
      await _repository.markAsRead(notification.id);
      
      // Create updated notification
      final updatedNotification = Notification(
        id: notification.id,
        type: notification.type,
        title: notification.title,
        message: notification.message,
        icon: notification.icon,
        color: notification.color,
        href: notification.href,
        urgent: notification.urgent,
        isRead: true,
        readAt: DateTime.now().toIso8601String(),
        metadata: notification.metadata,
        createdAt: notification.createdAt,
        time: notification.time,
      );
      
      // Update in _allNotifications
      final allIndex = _allNotifications.indexWhere((n) => n.id == notification.id);
      if (allIndex != -1) {
        _allNotifications[allIndex] = updatedNotification;
      }
      
      // Re-apply filter to update displayed list
      _applyFilter();
      
      // Refresh unread count
      await loadUnreadCount();
    } catch (e) {
      debugPrint('❌ Failed to mark as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      
      // Update all notifications in _allNotifications
      _allNotifications.value = _allNotifications.map((n) {
        if (!n.isRead) {
          return Notification(
            id: n.id,
            type: n.type,
            title: n.title,
            message: n.message,
            icon: n.icon,
            color: n.color,
            href: n.href,
            urgent: n.urgent,
            isRead: true,
            readAt: DateTime.now().toIso8601String(),
            metadata: n.metadata,
            createdAt: n.createdAt,
            time: n.time,
          );
        }
        return n;
      }).toList();
      
      // Re-apply filter
      _applyFilter();
      unreadCount.value = 0;
    } catch (e) {
      debugPrint('❌ Failed to mark all as read: $e');
    }
  }

  /// Change filter - applies client-side filtering without API call
  void changeFilter(String filter) {
    if (selectedFilter.value == filter) return;
    
    selectedFilter.value = filter;
    
    // If we have data, filter it locally; otherwise fetch from API
    if (_allNotifications.isNotEmpty) {
      _applyFilter();
    } else {
      loadNotifications();
    }
  }

  /// Delete a notification
  Future<bool> deleteNotification(Notification notification) async {
    try {
      // Optimistically remove from local lists first
      _allNotifications.removeWhere((n) => n.id == notification.id);
      _applyFilter();
      
      // Update unread count if the notification was unread
      if (!notification.isRead) {
        unreadCount.value = (unreadCount.value - 1).clamp(0, unreadCount.value);
      }
      
      // Call API to delete
      await _repository.deleteNotification(notification.id);
      
      debugPrint('🗑️ Deleted notification: ${notification.id}');
      return true;
    } catch (e) {
      // Rollback: add the notification back if API call failed
      _allNotifications.add(notification);
      _allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _applyFilter();
      
      // Restore unread count
      if (!notification.isRead) {
        unreadCount.value++;
      }
      
      debugPrint('❌ Failed to delete notification: $e');
      return false;
    }
  }

  /// Delete all read notifications
  Future<bool> deleteAllReadNotifications() async {
    try {
      final readNotifications = _allNotifications.where((n) => n.isRead).toList();
      if (readNotifications.isEmpty) return true;
      
      // Optimistically remove from local lists
      _allNotifications.removeWhere((n) => n.isRead);
      _applyFilter();
      
      // Call API
      await _repository.deleteAllReadNotifications();
      
      debugPrint('🗑️ Deleted ${readNotifications.length} read notifications');
      return true;
    } catch (e) {
      // Rollback on failure - reload from API
      await loadNotifications();
      debugPrint('❌ Failed to delete read notifications: $e');
      return false;
    }
  }

  /// Undo delete - restore a notification (for snackbar undo action)
  void undoDelete(Notification notification) {
    // Check if notification already exists to prevent duplicates
    final exists = _allNotifications.any((n) => n.id == notification.id);
    if (exists) {
      debugPrint('⚠️ Notification ${notification.id} already exists, skipping undo');
      return;
    }
    
    _allNotifications.add(notification);
    _allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _applyFilter();
    
    if (!notification.isRead) {
      unreadCount.value++;
    }
    
    debugPrint('↩️ Restored notification: ${notification.id}');
  }

  /// Refresh notifications
  @override
  Future<void> refresh() async {
    await Future.wait([loadNotifications(), loadUnreadCount()]);
  }
}
