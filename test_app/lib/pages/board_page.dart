import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_app/services/realtime_service.dart';
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
  final _rt=RealtimeService();
  @override
  void initState() {
    super.initState();
    // connect to realtime service when page is opened
    _rt.connect(ref, widget.projectId).catchError((e) {
      // handle connection errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Realtime connection failed: $e')),
      );
    });
  }

  @override
  void dispose() {

    _rt.dispose();
    super.dispose();
    
  }
  
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
          key:ValueKey(cols[i].id), 
          column: cols[i],
          projectId: widget.projectId,
          refresh: () => ref
        .read(boardProvider(widget.projectId).notifier) // grab notifier
        .refresh(),                                     // returns Future<void>
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

class _ColumnWidget extends StatefulWidget {
  final BoardColumn column;
  final String projectId;
  final Future<void> Function() refresh;
  const _ColumnWidget({
    required this.column,
    required this.projectId,
    required this.refresh,
    Key? key,
  }) : super(key: key);

  @override
  State<_ColumnWidget> createState() => _ColumnWidgetState();
}

class _ColumnWidgetState extends State<_ColumnWidget> {
  late List<TaskCard> _cards;

  @override
  void initState() {
    super.initState();
    _cards = [...widget.column.cards]; // make local copy
  }

  @override
  void didUpdateWidget(covariant _ColumnWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // sync local _cards if provider sends new data
   if (oldWidget.column.cards.length != widget.column.cards.length) {
    setState(() => _cards = [...widget.column.cards]);
  }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Column title + menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(widget.column.title,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18),
                tooltip: 'Column options',
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete column?'),
                        content: const Text('All cards in this column will also be deleted.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ApiService.deleteColumn(widget.projectId, widget.column.id);
                      widget.refresh();
                    }
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete column'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // DragTarget for the whole column
          Expanded(
            child: DragTarget<TaskCard>(
              onWillAccept: (card) => card?.columnId != widget.column.id,
              onAccept: (card) async {
                await ApiService.moveCard(
                  projectId: widget.projectId,
                  cardId: card.id,
                  targetColumnId: widget.column.id,
                  newPosition: _cards.length,
                );
                // refresh board after drop
                await widget.refresh();
              },
              builder: (context, candidateData, rejectedData) => ListView.builder(
                itemCount: _cards.length,
                itemBuilder: (_, i) => Draggable<TaskCard>(
  data: _cards[i],
  // --- what the finger drags around (needs explicit size) ---
  feedback: Material(
    elevation: 6,
    child: SizedBox(
      width: 240,                     // give it width
      child: Card(
        child: ListTile(title: Text(_cards[i].title)),
      ),
    ),
  ),
  // --- placeholder while dragging (keeps list height) ---
  childWhenDragging: Opacity(
    opacity: 0.5,
    child: Card(
      child: ListTile(title: Text(_cards[i].title)),
    ),
  ),
  // --- normal child ---
  child: Card(
    key: ValueKey(_cards[i].id),
    child: ListTile(
      title: Text(_cards[i].title),
      trailing: IconButton(
        icon: const Icon(Icons.delete_forever),
        onPressed: () async {
          await ApiService.deleteCard(widget.projectId, _cards[i].id);
          setState(() => _cards.removeAt(i));
          widget.refresh();
        },
      ),
    ),
  ),
),
              ),
            ),
          ),

          // Add card button
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add card',
            onPressed: () async {
              final title = await _newCardDialog(context);
              if (title != null && title.isNotEmpty) {
                final newCard = await ApiService.addCard(
                    widget.projectId, widget.column.id, title);
                setState(() => _cards.add(newCard)); // show instantly
                await widget.refresh();
                
              }
            },
          ),
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
