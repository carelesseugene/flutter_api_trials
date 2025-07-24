
class TaskCard {
  final String id;
  final String columnId;
  final String title;
  final String? description;
  final String? assignedUserId;
  final String? assignedUserEmail;   // <-- NEW
  final int progressPercent;         // <-- NEW
  int position;

  TaskCard({
    required this.id,
    required this.columnId,
    required this.title,
    this.description,
    this.assignedUserId,
    this.assignedUserEmail,
    this.progressPercent = 0,
    required this.position,
  });

  factory TaskCard.fromJson(Map<String, dynamic> j) => TaskCard(
        id: j['id'],
        columnId: j['columnId'],
        title: j['title'],
        description: j['description'],
        assignedUserId: j['assignedUserId'],
        assignedUserEmail: j['assignedUserEmail'],         // <-- NEW
        progressPercent: j['progressPercent'] ?? 0,        // <-- NEW, fallback to 0 if absent
        position: j['position'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'columnId': columnId,
        'title': title,
        'description': description,
        'assignedUserId': assignedUserId,
        'assignedUserEmail': assignedUserEmail,            // <-- NEW
        'progressPercent': progressPercent,                // <-- NEW
        'position': position,
      };
}

class BoardColumn {
  final String id;
  final String title;
  int position;
  List<TaskCard> cards;               // generic List<TaskCard>

  BoardColumn({
    required this.id,
    required this.title,
    required this.position,
    required this.cards,
  });

  factory BoardColumn.fromJson(Map<String, dynamic> j) => BoardColumn(
        id: j['id'],
        title: j['title'],
        position: j['position'],
        cards: (j['cards'] as List? ?? [])
            .map((e) => TaskCard.fromJson(e))
            .toList()
              ..sort((a, b) => a.position.compareTo(b.position)),
      );

  BoardColumn copyWith({
    List<TaskCard>? cards,
    String? title,
    int? position,
  }) =>
      BoardColumn(
        id: id,
        title: title ?? this.title,
        position: position ?? this.position,
        cards: cards ?? this.cards,
      );
}
