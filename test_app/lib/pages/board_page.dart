import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/board.dart';
import '../providers/board_provider.dart';
import '../services/api_services.dart';

class BoardPage extends ConsumerStatefulWidget {
  final String projectId;
  final String projectName;
  const BoardPage({super.key, required this.projectId, required this.projectName});

  @override
  ConsumerState<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends ConsumerState<BoardPage> {
  @override
  Widget build(BuildContext context) {
    final boardAsync = ref.watch(boardProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(title: Text(widget.projectName)),
      body: boardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (cols) => _buildBoard(cols),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        tooltip: 'Add column',
        onPressed: () async {
          final title = await _newColumnDialog(context);
          if (title != null && title.isNotEmpty) {
            await ApiService.addColumn(widget.projectId, title);
            ref.invalidate(boardProvider(widget.projectId));
          }
        },
      ),
    );
  }

  Widget _buildBoard(List<BoardColumn> cols) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(scrollbars: true),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: cols.length,
        itemBuilder: (_, i) => _ColumnWidget(
          column: cols[i],
          projectId: widget.projectId,
          refresh: () => ref.invalidate(boardProvider(widget.projectId)),
        ),
      ),
    );
  }

  Future<String?> _newColumnDialog(BuildContext ctx) async {
    final c = TextEditingController();
    return showDialog<String>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('New Column'),
        content: TextField(controller: c),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, c.text.trim()),
              child: const Text('Add')),
        ],
      ),
    );
  }
}

/* ----- single column widget ----- */

class _ColumnWidget extends StatefulWidget {
  final BoardColumn column;
  final String projectId;
  final VoidCallback refresh;
  const _ColumnWidget(
      {required this.column, required this.projectId, required this.refresh});

  @override
  State<_ColumnWidget> createState() => _ColumnWidgetState();
}

class _ColumnWidgetState extends State<_ColumnWidget> {
  late List<TaskCard> _cards;

  @override
  void initState() {
    super.initState();
    _cards = [...widget.column.cards];
  }

  @override
  Widget build(BuildContext context) {
    final width = 260.0;
    return Container(
      width: width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(widget.column.title,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _cards.length,
              onReorder: (oldIndex, newIndex) async {
                if (newIndex > _cards.length) newIndex = _cards.length;
                if (oldIndex < newIndex) newIndex--;
                setState(() {
                  final card = _cards.removeAt(oldIndex);
                  _cards.insert(newIndex, card);
                });

                await ApiService.moveCard(
                  projectId: widget.projectId,
                  cardId: _cards[newIndex].id,
                  targetColumnId: widget.column.id,
                  newPosition: newIndex,
                );
                widget.refresh();
              },
              itemBuilder: (_, i) => Card(
                key: ValueKey(_cards[i].id),
                child: ListTile(
                  title: Text(_cards[i].title),
                  subtitle: _cards[i].description != null
                      ? Text(_cards[i].description!)
                      : null,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add card',
            onPressed: () async {
              final title = await _newCardDialog(context);
              if (title != null && title.isNotEmpty) {
                await ApiService.addCard(
                    widget.projectId, widget.column.id, title);
                widget.refresh();
              }
            },
          )
        ],
      ),
    );
  }

  Future<String?> _newCardDialog(BuildContext ctx) async {
    final c = TextEditingController();
    return showDialog<String>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('New Card'),
        content: TextField(controller: c),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, c.text.trim()),
              child: const Text('Add')),
        ],
      ),
    );
  }
}
