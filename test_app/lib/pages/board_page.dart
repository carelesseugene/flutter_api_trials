import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/board.dart';
import '../models/project.dart';
import '../models/notification.dart';
import '../models/task_card.dart';
import '../services/realtime_service.dart';
import '../services/api_services.dart';
import '../providers/board_provider.dart';
import '../providers/notification_provider.dart';
import '../pages/notifications_page.dart';
import '../pages/members_page.dart';
import '../pages/public_profile_page.dart';
import '../widgets/card_assignment_editor.dart';

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
  final List<MemberDto> members;
  final bool isLead;
  final String myUserId;

  const _ColumnWidget({
    required this.column,
    required this.projectId,
    required this.refresh,
    required this.members,
    required this.isLead,
    required this.myUserId,
    Key? key,
  }) : super(key: key);
  @override
  State<_ColumnWidget> createState() => _ColumnWidgetState();
}

class _ColumnWidgetState extends State<_ColumnWidget> {
  //final Map<String, int> _sliderProgress = {}; // For local slider values



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
                          title: const Text('Sütunu silmek istiyor musunuz?'),
                          content: const Text(
                              'Sütundaki tüm kartlar silinecektir.'),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('İptal Et')),
                            ElevatedButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Sil')),
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
                    PopupMenuItem(value: 'delete', child: Text('Delete Column')),
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
                    newPosition: widget.column.cards.length,
                  );
                  await widget.refresh();
                },
                builder: (_, __, ___) => ListView.builder(
                  itemCount: widget.column.cards.length,
                  itemBuilder: (_, i) => _draggableCard(i),
                ),
              ),
            ),
            /* -------- add card -------- */
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Kart Ekle',
              onPressed: () async {
                final result = await _newCardDialog(context);
                if (result != null && (result['title'] as String?)?.isNotEmpty == true) {
                  await ApiService.addCard(
                    widget.projectId,
                    widget.column.id,
                    result['title'] as String,
                    dueUtc: result['dueUtc'] as DateTime?,
                  );
                  await widget.refresh();
                }


              },
            ),
          ],
        ),
      );

  Widget _draggableCard(int i) {
  final card = widget.column.cards[i];
  final assignedIds = card.assignedUsers.map((u) => u.userId).toSet();
  final isAssigned = assignedIds.contains(widget.myUserId);

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
            // Card name
            Text(
              card.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),

            // Description
            if (card.description != null && card.description!.isNotEmpty)
              Text(
                card.description!,
                style: TextStyle(fontSize: 13, color: Colors.grey[800]),
              ),
            if (card.description != null && card.description!.isNotEmpty)
              const SizedBox(height: 6),

            // Assigned Members
           Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    // Assigned members as tappable chips/links
    if (card.assignedUsers.isNotEmpty)
      Expanded(
        child: Wrap(
          spacing: 6,
          runSpacing: 2,
          children: card.assignedUsers.map((u) =>
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PublicProfilePage(userId: u.userId),
                  ),
                );
              },
              child: Text(
                u.email,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 12,
                ),
              ),
            )
          ).toList(),
        ),
      )
    else
      const Expanded(
        child: Text(
          "No members assigned.",
          style: TextStyle(fontSize: 12, color: Colors.blueGrey),
        ),
      ),
    if (widget.isLead)
      Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            minimumSize: const Size(0, 28),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text("Üye Ata", style: TextStyle(fontSize: 12)),
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Üye Ata"),
                content: CardAssignmentEditor(
                  projectId: widget.projectId,
                  card: card,
                  allMembers: widget.members,
                ),
              ),
            );
            await widget.refresh();
          },
        ),
      ),
  ],
),


            const Divider(height: 16),

            // Progress and "değiştir"
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "%${card.progressPercent} tamamlandı",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 4),
                if (isAssigned)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      minimumSize: Size(0, 26),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text("değiştir", style: TextStyle(fontSize: 12)),
                    onPressed: () async {
                      int? newProgress = await showDialog<int>(
                        context: context,
                        builder: (_) {
                          int tempValue = card.progressPercent;
                          return AlertDialog(
                            title: const Text("İlerleme Güncelle"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DropdownButton<int>(
                                  value: tempValue,
                                  items: List.generate(
                                    11,
                                    (i) => DropdownMenuItem(
                                      value: i * 10,
                                      child: Text("%${i * 10}"),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    if (val != null) tempValue = val;
                                  },
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: const Text("Tamamla"),
                                  onPressed: () {
                                    Navigator.pop(context, 100);
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('İptal')),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, tempValue),
                                child: const Text('Kaydet'),
                              ),
                            ],
                          );
                        },
                      );
                      if (newProgress != null) {
                        await ApiService.updateCardProgress(
                          widget.projectId, card.id, newProgress,
                        );
                        await widget.refresh();
                      }
                    },
                  ),
              ],
            ),

            // Responsive Due Date + Düzenle
            if (card.dueUtc != null || widget.isLead)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 2),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (card.dueUtc != null)
                          Flexible(
                            child: Text(
                              "Teslim: ${DateFormat('dd.MM.yyyy').format(card.dueUtc!)}",
                              style: const TextStyle(fontSize: 13, color: Colors.orange),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (card.dueUtc != null && widget.isLead)
                          const SizedBox(width: 10),
                        if (widget.isLead)
                          Flexible(
                            child: TextButton(
                              child: const Text("Düzenle", style: TextStyle(fontSize: 12)),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                minimumSize: Size(0, 26),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: card.dueUtc ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                                );
                                if (picked != null) {
                                  await ApiService.updateCardDueDate(
                                      widget.projectId, card.id, picked);
                                  await widget.refresh();
                                }
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    ),
  );
}


  Future<Map<String, dynamic>?> _newCardDialog(BuildContext ctx) async {
  final c = TextEditingController();
  DateTime? _selectedDueDate;

  return showDialog<Map<String, dynamic>>(
    context: ctx,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('New Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: c,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(_selectedDueDate == null
                    ? "No due date"
                    : "Due: ${_selectedDueDate!.toLocal().toString().split(' ')[0]}"),
                IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                    );
                    if (picked != null) setState(() => _selectedDueDate = picked);
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, {
              'title': c.text.trim(),
              'dueUtc': _selectedDueDate,
            }),
            child: const Text('Add'),
          ),
        ],
      ),
    ),
  );
}
}


// --- BoardPageState unchanged except for _ColumnWidget usage ---

class _BoardPageState extends ConsumerState<BoardPage> {
  late RealtimeService _rt;
  late Future<ProjectDetails?> _projectFuture = Future.value(null);

  ProjectDetails? _details;
  String _myUserId = '';
  bool _isLead = false;

  @override
  void initState() {
    super.initState();

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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      final claims = JwtDecoder.decode(token);
      _myUserId = (claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ?? '').toString();
    } else {
      _myUserId = '';
    }

    _projectFuture = ApiService.getProjectDetails(widget.projectId);
    _details = await _projectFuture;

    if (_details != null && _myUserId.isNotEmpty) {
      final me = _details!.members.firstWhereOrNull((m) => m.userId == _myUserId);
      _isLead = me != null && me.role == ProjectRole.lead;
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final boardAsync = ref.watch(boardProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        actions: [
          Consumer(builder: (context, ref, _) {
            final unread = ref
                .watch(notificationsProvider)
                .where((n) => n.status == NotificationStatus.unread)
                .length;
            return IconButton(
              tooltip: 'Bildirimler',
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
          IconButton(
            tooltip: 'Üyeler',
            icon: const Icon(Icons.group),
            onPressed: () async {
              if (_details == null) _details = await _projectFuture;
              if (!mounted || _details == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Üye listesi yüklenemedi.')),
                );
                return;
              }
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('token');
              final claims = JwtDecoder.decode(token!);
              final uid = claims['sub'] ?? claims['nameid'];
              final email = claims['email'];
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
                  child: Text('Proje detayları yüklenemedi.'),
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
        tooltip: 'Yeni Sütun Ekle',
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
            members: _details?.members ?? [],
            isLead: _isLead,
            myUserId: _myUserId,
          ),
        ),
      );

  Future<String?> _newColumnDialog(BuildContext ctx) async {
    final c = TextEditingController();
    return showDialog<String>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Yeni Sütun'),
        content: TextField(controller: c),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal Et')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, c.text.trim()),
              child: const Text('Ekle')),
        ],
      ),
    );
  }
}
