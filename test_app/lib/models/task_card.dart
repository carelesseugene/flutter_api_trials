

import '../models/assigned_user.dart';

class TaskCard {
  final String id;
  final String columnId;
  final String title;
  final String? description;
  final List<AssignedUser> assignedUsers;
  final int position;
  final int progressPercent;
  final DateTime? dueUtc;

  TaskCard({
    required this.id,
    required this.columnId,
    required this.title,
    this.description,
    required this.assignedUsers,
    required this.position,
    required this.progressPercent,
    this.dueUtc,
  });

  factory TaskCard.fromJson(Map<String, dynamic> json) {
    return TaskCard(
      id: json['id'],
      columnId: json['columnId'],
      title: json['title'],
      description: json['description'],
      assignedUsers: (json['assignedUsers'] as List<dynamic>? ?? [])
          .map((e) => AssignedUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      position: json['position'],
      progressPercent: json['progressPercent'],
      dueUtc: json['dueUtc'] != null ? DateTime.parse(json['dueUtc']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'columnId': columnId,
    'title': title,
    'description': description,
    'assignedUsers': assignedUsers.map((u) => u.toJson()).toList(),
    'position': position,
    'progressPercent': progressPercent,
    'dueUtc': dueUtc?.toIso8601String(),
  };
}
