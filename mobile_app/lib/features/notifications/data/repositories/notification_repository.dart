import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/notification.dart';

/// Repository for notification-related API calls
class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get all notifications for the authenticated user
  Future<NotificationsResponse> getNotifications({
    bool? unreadOnly,
    bool? urgentOnly,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (unreadOnly != null) params['unread_only'] = unreadOnly;
      if (urgentOnly != null) params['urgent_only'] = urgentOnly;

      final response = await _apiClient.get(
        ApiEndpoints.notifications,
        queryParameters: params.isNotEmpty ? params : null,
      );

      final responseData = response.data as Map<String, dynamic>;
      return NotificationsResponse.fromJson(responseData);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// Get unread notification count
  Future<UnreadCountResponse> getUnreadCount() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.notificationUnreadCount,
      );
      final responseData = response.data as Map<String, dynamic>;
      return UnreadCountResponse.fromJson(responseData);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _apiClient.post(
        ApiEndpoints.markNotificationRead(notificationId.toString()),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.post(ApiEndpoints.markAllNotificationsRead);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.deleteNotification(notificationId.toString()),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// Delete all read notifications
  Future<void> deleteAllReadNotifications() async {
    try {
      await _apiClient.delete(ApiEndpoints.deleteAllReadNotifications);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }
}
