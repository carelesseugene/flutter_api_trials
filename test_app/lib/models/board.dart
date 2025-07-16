class TaskCard {
  final String id;
  final String title;
  final String columnId;
  final String? description;
  final String? assignedUserId;
  int position;

  TaskCard({
    required this.id,
    required this.title,
    required this.columnId,
    this.description,
    this.assignedUserId,
    required this.position,
  });

  factory TaskCard.fromJson(Map<String, dynamic> j) => TaskCard(
        id: j['id'],
        columnId: j['columnId'],
        title: j['title'],
        description: j['description'],
        assignedUserId: j['assignedUserId'],
        position: j['position'],
      );
}

class BoardColumn {
  final String id;
  final String title;
  int position;
  List<TaskCard> cards;

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
  // if "cards" key is absent or null → use empty list
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
