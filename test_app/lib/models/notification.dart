import 'dart:convert';

enum NotificationType {
  invite, assignment, dueReminder, complete, removed, update, comment
}
enum NotificationStatus { unread, read, actioned }

class NotificationDto {
  final String id;
  final NotificationType type;
  final NotificationStatus status;
  final DateTime createdUtc;
  final Map<String, dynamic> payload;

  NotificationDto.fromJson(Map<String, dynamic> j)
      : id          = j['id'],
        type        = NotificationType.values[j['type']],
        status      = NotificationStatus.values[j['status']],
        createdUtc  = DateTime.parse(j['createdUtc']),
        // Accept either { payload: {…} } or { payloadJson: '…' }
        payload     = j.containsKey('payload')
            ? Map<String, dynamic>.from(j['payload'])
            : Map<String, dynamic>.from(jsonDecode(j['payloadJson'] as String));
}
