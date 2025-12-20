/// Notification Model
class Notification {
  final int id;
  final String type;
  final String title;
  final String message;
  final String icon;
  final String color;
  final String? href;
  final bool urgent;
  final bool isRead;
  final String? readAt;
  final Map<String, dynamic>? metadata;
  final String createdAt;
  final String? time;

  Notification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    this.href,
    required this.urgent,
    required this.isRead,
    this.readAt,
    this.metadata,
    required this.createdAt,
    this.time,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      icon: json['icon'] as String? ?? 'bell',
      color: json['color'] as String? ?? '#FFFFFF',
      href: json['href'] as String?,
      urgent: json['urgent'] as bool? ?? false,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] as String,
      time: json['time'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'icon': icon,
      'color': color,
      'href': href,
      'urgent': urgent,
      'is_read': isRead,
      'read_at': readAt,
      'metadata': metadata,
      'created_at': createdAt,
      'time': time,
    };
  }
}

/// Notifications Response Model
class NotificationsResponse {
  final bool success;
  final List<Notification> data;
  final NotificationsMeta meta;

  NotificationsResponse({
    required this.success,
    required this.data,
    required this.meta,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      success: json['success'] as bool,
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (item) => Notification.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      meta: NotificationsMeta.fromJson(
        json['meta'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// Notifications Meta Model
class NotificationsMeta {
  final int unreadCount;
  final int totalUnread;

  NotificationsMeta({required this.unreadCount, required this.totalUnread});

  factory NotificationsMeta.fromJson(Map<String, dynamic> json) {
    return NotificationsMeta(
      unreadCount: json['unread_count'] as int? ?? 0,
      totalUnread: json['total_unread'] as int? ?? 0,
    );
  }
}

/// Unread Count Response Model
class UnreadCountResponse {
  final bool success;
  final UnreadCountData data;

  UnreadCountResponse({required this.success, required this.data});

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      success: json['success'] as bool,
      data: UnreadCountData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

/// Unread Count Data Model
class UnreadCountData {
  final int urgentCount;
  final int totalCount;

  UnreadCountData({required this.urgentCount, required this.totalCount});

  factory UnreadCountData.fromJson(Map<String, dynamic> json) {
    return UnreadCountData(
      urgentCount: json['urgent_count'] as int? ?? 0,
      totalCount: json['total_count'] as int? ?? 0,
    );
  }
}
