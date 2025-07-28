import 'task_card.dart';

// BoardColumn represents a column in the Kanban board.
// Each column holds a list of TaskCard objects.
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
