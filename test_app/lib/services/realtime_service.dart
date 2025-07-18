import 'package:signalr_core/signalr_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/board.dart';
import 'api_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/board_provider.dart';
import '../models/notification.dart';
import '../providers/notification_provider.dart';

class RealtimeService {
  late HubConnection _hub;

  Future<void> connect(WidgetRef ref, String projectId) async {
    final token = await _getToken();
    _hub = HubConnectionBuilder()
        .withUrl('${ApiService.baseUrl}/hubs/board',
            HttpConnectionOptions(
                accessTokenFactory: () async => token))
        .build();

    await _hub.start();
    await _hub.invoke('JoinProject', args: [projectId]);

    _hub.on('CardCreated', (args) =>
        _patchBoard(ref, projectId, args![0] as Map));
    _hub.on('CardMoved',   (args) =>
        ref.invalidate(boardProvider(projectId)));
    _hub.on('ColumnCreated', (args) =>
        ref.invalidate(boardProvider(projectId)));

    _hub.on('NotificationAdded', (args) {
        final notif = NotificationDto.fromJson(
            Map<String, dynamic>.from(args![0] as Map));
        ref.read(notificationsProvider.notifier).add(notif);
      });

  }

  void _patchBoard(WidgetRef ref, String pid, Map raw) {
    final newCard = TaskCard.fromJson(raw as Map<String, dynamic>);
    ref.read(boardProvider(pid).notifier).addCard(newCard);
  }
  Future<void> dispose() async {
    if (_hub.state == HubConnectionState.connected) {
      await _hub.stop();
    }
  }
  Future<String> _getToken() async =>
      (await SharedPreferences.getInstance()).getString('token') ?? '';

      
}
