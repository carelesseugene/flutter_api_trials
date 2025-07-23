import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';
import '../services/api_services.dart';
import '../pages/board_page.dart';
import '../providers/notification_provider.dart';  
import '../models/notification.dart';               
import '../pages/notifications_page.dart';
import '../pages/members_page.dart';    // <-- MembersPage'i import et!

class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
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
                          '$unread',
                          style: const TextStyle(
                              fontSize: 8, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationsPage()),
              ),
            );
          }),
        ]),
      body: projectsAsync.when(
        data: (list) => ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final p = list[i];
            return ListTile(
              title: Text(p.name),
              subtitle: Text('Owner: ${p.ownerEmail} • ${p.memberCount} members'),
              onTap: () async {
                // BoardPage veya MembersPage’den dönünce projeleri otomatik yenile
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BoardPage(
                      projectId: p.id,
                      projectName: p.name,
                    ),
                  ),
                );
                // Projeye üyelik/çıkış/üye silme olmuşsa burada otomatik refresh olur!
                ref.invalidate(projectsProvider);
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await ApiService.deleteProject(p.id);
                  ref.invalidate(projectsProvider);
                },
              ),
              onLongPress: () async {
                // Opsiyonel: doğrudan üyeler sayfası!
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MembersPage(
                      projectId: p.id,
                      amManager: true, // (veya senin auth kontrolünle)
                      members: const [], // Listeyi boş bırakabilirsin, MembersPage kendisi dolduracak
                    ),
                  ),
                );
                ref.invalidate(projectsProvider); // Üyelik değişikliği varsa anında güncellenir
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final name = await _newProjectDialog(context);
          if (name != null && name.isNotEmpty) {
            await ApiService.createProject(name, null);
            ref.invalidate(projectsProvider);
          }
        },
      ),
    );
  }

  Future<String?> _newProjectDialog(BuildContext ctx) async {
    final c = TextEditingController();
    return showDialog<String>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('New Project'),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, c.text.trim()),
              child: const Text('Create')),
        ],
      ),
    );
  }
}
