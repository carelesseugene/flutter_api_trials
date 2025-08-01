import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../providers/notification_provider.dart';
import '../services/api_services.dart';
import '../providers/project_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notificationsProvider.notifier).load());
  }

  Future<void> _refresh() async {
    await ref.read(notificationsProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimler')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) => _tile(ref, list[i]),
        ),
      ),
    );
  }

  Widget _tile(WidgetRef ref, NotificationDto n) {
    if (n.type == NotificationType.invite) {
      final name = n.payload['projectName'];
      final pid  = n.payload['projectId'];
      return ListTile(
        leading: const Icon(Icons.mail),
        title: Text('Bir projeye davet edildiniz: $name'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                    await ApiService.respondInvite(n.id, true); // <-- n.id is notification id!
                    ref.read(notificationsProvider.notifier).remove(n.id);
                    await _refresh();
                    ref.invalidate(projectsProvider);
                  },

            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                    await ApiService.respondInvite(n.id, true); // <-- n.id is notification id!
                    ref.read(notificationsProvider.notifier).remove(n.id);
                    await _refresh();
                    ref.invalidate(projectsProvider);
                  },

            ),
          ],
        ),
      );
    }
    // fallback
    return const SizedBox.shrink();
  }
}
