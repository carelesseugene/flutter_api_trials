import 'assigned_user.dart';

class AssignedCard {
  final String id;
  final String title;
  final String? description;
  final int progressPercent;
  final DateTime? dueUtc;
  final String projectId;
  final String projectName;
  final String columnId;
  final String columnTitle;
  final List<AssignedUser> assignedUsers;

  AssignedCard({
    required this.id,
    required this.title,
    this.description,
    required this.progressPercent,
    this.dueUtc,
    required this.projectId,
    required this.projectName,
    required this.columnId,
    required this.columnTitle,
    required this.assignedUsers,
  });

  factory AssignedCard.fromJson(Map<String, dynamic> json) => AssignedCard(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    progressPercent: json['progressPercent'],
    dueUtc: json['dueUtc'] != null ? DateTime.parse(json['dueUtc']) : null,
    projectId: json['projectId'],
    projectName: json['projectName'],
    columnId: json['columnId'],
    columnTitle: json['columnTitle'],
    assignedUsers: (json['assignedUsers'] as List<dynamic>)
        .map((u) => AssignedUser.fromJson(u as Map<String, dynamic>))
        .toList(),
  );
}
