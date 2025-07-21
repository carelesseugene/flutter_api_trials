import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../services/api_services.dart';

final notificationsProvider =
    StateNotifierProvider<NotificationCtrl, List<NotificationDto>>(
  (ref) => NotificationCtrl()..load(),
);

class NotificationCtrl extends StateNotifier<List<NotificationDto>> {
  NotificationCtrl() : super([]);

  /* fetch from server every time we call load() */
  Future<void> load() async {
    try {
      state = await ApiService.getNotifications();
    } catch (_) {
      state = [];
    }
  }

  /* pushed from SignalR */
  void add(NotificationDto n) => state = [n, ...state];
}
