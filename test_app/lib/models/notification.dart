enum NotificationType { invite /*comment, assigned to a card */ }
enum NotificationStatus { unread, read, actioned }

class NotificationDto {
  final String id;
  final NotificationType type;
  final NotificationStatus status;
  final DateTime createdUtc;
  final Map<String, dynamic> payload;  

  NotificationDto.fromJson(Map<String, dynamic> j)
      : id         = j['id'],
        type       = NotificationType.values[j['type']],
        status     = NotificationStatus.values[j['status']],
        createdUtc = DateTime.parse(j['createdUtc']),
        payload    = Map<String, dynamic>.from(j['payload']);
}
