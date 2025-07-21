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
    // always fetch fresh notifications on open
    Future.microtask(() =>
        ref.read(notificationsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        itemCount: list.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) => _tile(ref, list[i]),
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
              onPressed: () => _respond(ref, pid, true),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _respond(ref, pid, false),
            ),
          ],
        ),
      );
    }
    // fallback
    return const SizedBox.shrink();
  }

  Future<void> _respond(WidgetRef ref, String pid, bool accept) async {
    await ApiService.respondInvite(pid, accept);
    await ref.read(notificationsProvider.notifier).load();
  }
}
