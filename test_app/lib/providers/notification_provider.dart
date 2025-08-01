import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification.dart';
import '../services/api_services.dart';

/// Exposes the notifications list to the rest of the app.
final notificationsProvider =
    StateNotifierProvider<NotificationCtrl, List<NotificationDto>>(
  (ref) => NotificationCtrl(),
);

class NotificationCtrl extends StateNotifier<List<NotificationDto>> {
  Timer? _timer;

  NotificationCtrl() : super([]) {
    load();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => load(),
    );
  }

 Future<void> load() async {
  try {
    final all = await ApiService.getNotifications();
    state = all.where((n) => n.status != NotificationStatus.actioned).toList();
  } catch (_) {
    // Optionally keep the previous state or set to []
  }
}

  void add(NotificationDto n) => state = [n, ...state];

  void remove(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

