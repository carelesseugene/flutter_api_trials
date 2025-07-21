import 'package:signalr_core/signalr_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/board.dart';
import '../models/notification.dart';
import '../providers/board_provider.dart';
import '../providers/notification_provider.dart';
import 'api_services.dart';

class RealtimeService {
  HubConnection? _hub;
  bool _initialized = false;

  Future<void> ensureConnected(dynamic read) async {
    if (_initialized) return;

    final token  = await _getToken();
    final hubUrl = ApiService.baseUrl.replaceFirst('/api', '') + '/hubs/board';

    _hub = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          HttpConnectionOptions(accessTokenFactory: () async => token),
        )
        .withAutomaticReconnect()
        .build();

    _hub!.on('NotificationAdded', (args) {
      final notif = NotificationDto.fromJson(
          Map<String, dynamic>.from(args![0] as Map));
      read(notificationsProvider.notifier).add(notif);
    });

    await _hub!.start();
    _initialized = true;
  }

  Future<void> connectBoard(WidgetRef ref, String projectId) async {
    await ensureConnected(ref.read);

    await _hub!.invoke('JoinProject', args: [projectId]);

    _hub!.on('CardCreated',
        (args) => _patchBoard(ref, projectId, args![0] as Map));
    _hub!.on('CardMoved', (_)   => ref.invalidate(boardProvider(projectId)));
    _hub!.on('ColumnCreated', (_) => ref.invalidate(boardProvider(projectId)));
  }

  void _patchBoard(WidgetRef ref, String pid, Map raw) {
    final newCard = TaskCard.fromJson(raw as Map<String, dynamic>);
    ref.read(boardProvider(pid).notifier).addCard(newCard);
  }

  Future<String> _getToken() async =>
      (await SharedPreferences.getInstance()).getString('token') ?? '';

  Future<void> dispose() async {
    if (_hub?.state == HubConnectionState.connected) {
      await _hub!.stop();
    }
    _initialized = false;
  }
}
