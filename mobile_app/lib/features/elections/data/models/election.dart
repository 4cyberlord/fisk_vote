/// Election Model
class Election {
  final int id;
  final String title;
  final String description;
  final String type;
  final int maxSelection;
  final int? rankingLevels;
  final bool allowWriteIn;
  final bool allowAbstain;
  final String startTime;
  final String endTime;
  final int startTimestamp;
  final int endTimestamp;
  final String status;
  final String currentStatus;
  final bool hasVoted;
  final int positionsCount;
  final int candidatesCount;
  final String createdAt;
  final String updatedAt;

  Election({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.maxSelection,
    this.rankingLevels,
    required this.allowWriteIn,
    required this.allowAbstain,
    required this.startTime,
    required this.endTime,
    required this.startTimestamp,
    required this.endTimestamp,
    required this.status,
    required this.currentStatus,
    required this.hasVoted,
    required this.positionsCount,
    required this.candidatesCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Election.fromJson(Map<String, dynamic> json) {
    return Election(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      // `max_selection` can be null in API, fall back to 1 (single choice)
      maxSelection: (json['max_selection'] as int?) ?? 1,
      rankingLevels: json['ranking_levels'] as int?,
      allowWriteIn: json['allow_write_in'] as bool? ?? false,
      allowAbstain: json['allow_abstain'] as bool? ?? true,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      startTimestamp: json['start_timestamp'] as int,
      endTimestamp: json['end_timestamp'] as int,
      status: json['status'] as String,
      currentStatus: json['current_status'] as String,
      hasVoted: json['has_voted'] as bool? ?? false,
      positionsCount: json['positions_count'] as int? ?? 0,
      candidatesCount: json['candidates_count'] as int? ?? 0,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'max_selection': maxSelection,
      'ranking_levels': rankingLevels,
      'allow_write_in': allowWriteIn,
      'allow_abstain': allowAbstain,
      'start_time': startTime,
      'end_time': endTime,
      'start_timestamp': startTimestamp,
      'end_timestamp': endTimestamp,
      'status': status,
      'current_status': currentStatus,
      'has_voted': hasVoted,
      'positions_count': positionsCount,
      'candidates_count': candidatesCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Check if election is active
  bool get isActive {
    // Must not have ended and must be in active/open status
    if (hasEnded) return false;
    return (status == 'active' || currentStatus.toLowerCase() == 'open') &&
        !hasEnded;
  }

  /// Check if election is upcoming
  bool get isUpcoming {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return startTimestamp > now;
  }

  /// Check if election has ended
  bool get hasEnded {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return endTimestamp < now;
  }

  /// Get time remaining until end (in hours)
  int? get hoursUntilEnd {
    if (hasEnded) return null;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final remaining = endTimestamp - now;
    return (remaining / 3600).ceil();
  }

  /// Get formatted time remaining (e.g., "2h 30m 15s" or "45s")
  String? get formattedTimeRemaining {
    if (hasEnded) return null;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final remaining = endTimestamp - now;

    if (remaining <= 0) return 'Ended';

    final hours = remaining ~/ 3600;
    final minutes = (remaining % 3600) ~/ 60;
    final seconds = remaining % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Check if election is ending soon (less than 1 hour remaining)
  bool get isEndingSoon {
    if (hasEnded) return false;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final remaining = endTimestamp - now;
    return remaining < 3600; // Less than 1 hour
  }

  /// Get formatted start date
  String get formattedStartDate {
    try {
      final date = DateTime.parse(startTime);
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
    } catch (e) {
      return startTime;
    }
  }

  /// Get formatted end date/time
  String get formattedEndDate {
    try {
      final date = DateTime.parse(endTime);
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
      final hour = date.hour > 12 ? date.hour - 12 : date.hour;
      final amPm = date.hour >= 12 ? 'PM' : 'AM';
      final minute = date.minute.toString().padLeft(2, '0');
      return '${months[date.month - 1]} ${date.day}, $hour:$minute $amPm';
    } catch (e) {
      return endTime;
    }
  }
}

/// Elections Response Model
class ElectionsResponse {
  final List<Election> data;
  final ElectionsMeta meta;

  ElectionsResponse({required this.data, required this.meta});

  factory ElectionsResponse.fromJson(Map<String, dynamic> json) {
    return ElectionsResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => Election.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      meta: ElectionsMeta.fromJson(json['meta'] as Map<String, dynamic>? ?? {}),
    );
  }
}

/// Elections Meta Model
class ElectionsMeta {
  final int total;
  final String timestamp;
  final int serverTime;

  ElectionsMeta({
    required this.total,
    required this.timestamp,
    required this.serverTime,
  });

  factory ElectionsMeta.fromJson(Map<String, dynamic> json) {
    return ElectionsMeta(
      total: json['total'] as int? ?? 0,
      timestamp: json['timestamp'] as String? ?? '',
      serverTime: json['server_time'] as int? ?? 0,
    );
  }
}
