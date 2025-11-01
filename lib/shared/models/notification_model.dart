class NotificationResponse {
  final int unreadCount;
  final List<NotificationItem> notifications;

  NotificationResponse({
    required this.unreadCount,
    required this.notifications,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    // Get the list of notifications from the paginated data
    final List<dynamic> dataList = json['notifications']?['data'] ?? [];
    
    return NotificationResponse(
      unreadCount: json['unread_count'] ?? 0,
      notifications: dataList
          .map((item) => NotificationItem.fromJson(item))
          .toList(),
    );
  }
}


class NotificationItem {
  final String id;
  final String message;
  final String createdAt;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      // Get the nested message
      message: json['data']?['message'] ?? 'No message content',
      createdAt: json['created_at'],
      // Check if 'read_at' is null to determine read status
      isRead: json['read_at'] != null,
    );
  }
}