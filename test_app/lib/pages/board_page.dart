import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';                     // realtimeServiceProvider
import '../models/board.dart';
import '../models/project.dart';
import '../models/notification.dart';
import '../services/realtime_service.dart';
import '../services/api_services.dart';
import '../providers/board_provider.dart';
import '../providers/notification_provider.dart';
import '../pages/notifications_page.dart';
import '../pages/members_page.dart';

class BoardPage extends ConsumerStatefulWidget {
  final String projectId;
  final String projectName;
  const BoardPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  ConsumerState<BoardPage> createState() => _BoardPageState();
}

/* ------------------------------------------------------------------
   Single Kanban column   (_ColumnWidget)
   ------------------------------------------------------------------ */
class _ColumnWidget extends StatefulWidget {
  final BoardColumn column;
  final String projectId;
  final Future<void> Function() refresh;
  // NEW ↓
  final List<MemberDto> members;
  final bool isLead;
  final String myUserId;

  const _ColumnWidget({
    required this.column,
    required this.projectId,
    required this.refresh,
    required this.members,   // NEW
    required this.isLead,    // NEW
    required this.myUserId,  // NEW
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
    _cards = [...widget.column.cards];
  }

  @override
  void didUpdateWidget(covariant _ColumnWidget old) {
    super.didUpdateWidget(old);
    if (old.column.cards.length != widget.column.cards.length) {
      setState(() => _cards = [...widget.column.cards]);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        width: 260,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            /* -------- header -------- */
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(widget.column.title,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  onSelected: (v) async {
                    if (v == 'delete') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete column?'),
                          content: const Text(
                              'All cards in this column will also be deleted.'),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            ElevatedButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await ApiService.deleteColumn(
                            widget.projectId, widget.column.id);
                        await widget.refresh();
                      }
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'delete', child: Text('Delete column')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            /* -------- card list + drag target -------- */
            Expanded(
              child: DragTarget<TaskCard>(
                onWillAccept: (c) => c?.columnId != widget.column.id,
                onAccept: (card) async {
                  await ApiService.moveCard(
                    projectId: widget.projectId,
                    cardId: card.id,
                    targetColumnId: widget.column.id,
                    newPosition: _cards.length,
                  );
                  await widget.refresh();
                },
                builder: (_, __, ___) => ListView.builder(
                  itemCount: _cards.length,
                  itemBuilder: (_, i) => _draggableCard(i),
                ),
              ),
            ),
            /* -------- add card -------- */
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add card',
              onPressed: () async {
                final title = await _newCardDialog(context);
                if (title?.isNotEmpty == true) {
                  await ApiService.addCard(
                      widget.projectId, widget.column.id, title!);
                  await widget.refresh();
                }
              },
            ),
          ],
        ),
      );

  /* --- draggable card helper --- */
  Widget _draggableCard(int i) {

  final card = _cards[i];
  final assignedUser = widget.members.firstWhereOrNull((m) => m.userId == card.assignedUserId);

 print('IS LEAD: ${widget.isLead}');
  print('MEMBER COUNT: ${widget.members.length}');
  print('MY USER ID: ${widget.myUserId}');
  print('CARD assignedUserId: ${card.assignedUserId}');
  print('MEMBERS: ${widget.members.map((m) => m.email).toList()}');


  return Draggable<TaskCard>(
    data: card,
    feedback: Material(
      child: SizedBox(
        width: 240,
        child: Card(child: ListTile(title: Text(card.title))),
      ),
      elevation: 6,
    ),
    childWhenDragging: Opacity(
      opacity: 0.3,
      child: Card(child: ListTile(title: Text(card.title))),
    ),
    child: Card(
      key: ValueKey(card.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Delete
            Row(
              children: [
                Expanded(
                  child: Text(card.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () async {
                    await ApiService.deleteCard(widget.projectId, card.id);
                    await widget.refresh();
                  },
                ),
              ],
            ),
            // Assignment dropdown (for leads)
            if (widget.isLead && widget.members.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: widget.members.any((m) => m.userId == card.assignedUserId)
                      ? card.assignedUserId
                      : null,
                  hint: const Text("Assign user"),
                  items: widget.members
                      .map((m) => DropdownMenuItem(
                            value: m.userId,
                            child: Text(m.email),
                          ))
                      .toList(),
                  onChanged: (selectedUserId) async {
                    if (selectedUserId != null && selectedUserId != card.assignedUserId) {
                      await ApiService.assignUserToCard(
                          widget.projectId, card.id, selectedUserId);
                      await widget.refresh();
                    }
                  },
                ),
              ),
            // Assigned user display
            if (assignedUser != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  "Assigned: ${assignedUser.email}",
                  style: TextStyle(fontSize: 11, color: Colors.blueGrey[700]),
                ),
              ),
            if (assignedUser == null && card.assignedUserId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  "Assigned: ${card.assignedUserId}",
                  style: TextStyle(fontSize: 11, color: Colors.blueGrey[700]),
                ),
              ),
            // Progress bar (lead or assigned user)
            if (widget.isLead || widget.myUserId == card.assignedUserId) ...[
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: card.progressPercent.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: "${card.progressPercent}%",
                        onChanged: (v) async {
                          await ApiService.updateCardProgress(
                              widget.projectId, card.id, v.round());
                          await widget.refresh();
                        },
                      ),
                    ),
                    Text("${card.progressPercent}%"),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

  /* --- dialog helper --- */
  Future<String?> _newCardDialog(BuildContext ctx) async {
    final c = TextEditingController();
    return showDialog<String>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('New Card'),
        content: TextField(controller: c),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, c.text.trim()),
              child: const Text('Add')),
        ],
      ),
    );
  }
}

class _BoardPageState extends ConsumerState<BoardPage> {
  // ─────────────────────────── fields ───────────────────────────
  late RealtimeService _rt;
  late Future<ProjectDetails?> _projectFuture = Future.value(null);

  ProjectDetails? _details;

  String _myUserId = '';   // current user id
  bool   _isLead   = false; // am I project lead?

  // ─────────────────────────── lifecycle ───────────────────────────
  @override
  void initState() {
    super.initState();

    // realtime
    _rt = ref.read(realtimeServiceProvider);
    _rt.connectBoard(ref, widget.projectId).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Realtime failed: $e')));
      }
    });

    _loadUserAndProject();
  }

 Future<void> _loadUserAndProject() async {
  /* ----- current user id ----- */
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token != null) {
    final claims = JwtDecoder.decode(token);
    // Use the actual key for userId from your JWT claims
    _myUserId = (claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ?? '').toString();

    print('Loaded userId: $_myUserId from token: $token');
    print('Token claims: $claims');
  } else {
    _myUserId = '';
    print('No token found!');
  }


    /* ----- project details ----- */
    _projectFuture = ApiService.getProjectDetails(widget.projectId);
    _details = await _projectFuture;

    if (_details != null && _myUserId.isNotEmpty) {
      final me = _details!.members.firstWhereOrNull((m) => m.userId == _myUserId);
      _isLead = me != null && me.role == ProjectRole.lead;
    }
      
    if (mounted) setState(() {});
  }

  // ─────────────────────────── UI ───────────────────────────
  @override
  Widget build(BuildContext context) {
    final boardAsync = ref.watch(boardProvider(widget.projectId));

    return Scaffold(
      appBar:AppBar(
        title: Text(widget.projectName),
        actions: [
          /* -------- bell -------- */
          Consumer(builder: (context, ref, _) {
            final unread = ref
                .watch(notificationsProvider)
                .where((n) => n.status == NotificationStatus.unread)
                .length;
            return IconButton(
              tooltip: 'Notifications',
              icon: Stack(
                children: [
                  const Icon(Icons.notifications),
                  if (unread > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CircleAvatar(
                        radius: 6,
                        backgroundColor: Colors.red,
                        child: Text(
                          unread.toString(),
                          style: const TextStyle(fontSize: 8, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                );
              },
            );
          }),
          /* -------- members -------- */
          IconButton(
            tooltip: 'Members',
            icon: const Icon(Icons.group),
            onPressed: () async {
              if (_details == null) _details = await _projectFuture;
              if (!mounted || _details == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not load member list')),
                );
                return;
              }

              final prefs  = await SharedPreferences.getInstance();
              final token  = prefs.getString('token');
              final claims = JwtDecoder.decode(token!);
              final uid    = claims['sub'] ?? claims['nameid'];
              final email  = claims['email'];

              final me = _details!.members.firstWhereOrNull(
                (m) => m.userId == uid || m.email.toLowerCase() == email.toLowerCase(),
              );

              final amManager = me != null && me.role == ProjectRole.lead;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MembersPage(
                    projectId: widget.projectId,
                    amManager: amManager,
                    members: _details!.members,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          /* ----- project header card ----- */
          FutureBuilder<ProjectDetails?>(
            future: _projectFuture,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: LinearProgressIndicator(),
                );
              }
              final p = snap.data;
              if (p == null) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Project details unavailable'),
                );
              }
              return Card(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(p.name),
                  subtitle: Text(
                    'Owner: ${p.ownerEmail} • ${p.members.length} members',
                  ),
                ),
              );
            },
          ),
          /* ----- board ----- */
          Expanded(
            child: boardAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (cols) => _buildBoard(cols),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add column',
        child: const Icon(Icons.add),
        onPressed: () async {
          final title = await _newColumnDialog(context);
          if (title?.isNotEmpty == true) {
            await ApiService.addColumn(widget.projectId, title!);
            ref.invalidate(boardProvider(widget.projectId));
          }
        },
      ),
    );
  }

  // ─────────────────────────── helpers ───────────────────────────
  Widget _buildBoard(List<BoardColumn> cols) => ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(scrollbars: true),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemCount: cols.length,
          itemBuilder: (_, i) => _ColumnWidget(
            key: ValueKey(cols[i].id),
            column: cols[i],
            projectId: widget.projectId,
            refresh: () => ref
                .read(boardProvider(widget.projectId).notifier)
                .refresh(),
            members : _details?.members ?? [],
            isLead  : _isLead,
            myUserId: _myUserId,
          ),
        ),
      );

  Future<String?> _newColumnDialog(BuildContext ctx) async {
    final c = TextEditingController();
    return showDialog<String>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('New Column'),
        content: TextField(controller: c),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, c.text.trim()),
              child: const Text('Add')),
        ],
      ),
    );
  }
}
