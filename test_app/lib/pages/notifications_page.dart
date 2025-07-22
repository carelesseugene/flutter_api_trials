import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../providers/notification_provider.dart';
import '../services/api_services.dart';

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
      appBar: AppBar(title: const Text('Notifications')),
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
        title: Text('You are invited to $name'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                await ApiService.respondInvite(pid, true);
                await ref.read(notificationsProvider.notifier).load();
              },
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                await ApiService.respondInvite(pid, false);
                await ref.read(notificationsProvider.notifier).load();
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
