import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../services/api_services.dart';

final notificationsProvider =
    StateNotifierProvider<NotificationCtrl, List<NotificationDto>>(
  (ref) => NotificationCtrl(),
);

class NotificationCtrl extends StateNotifier<List<NotificationDto>> {
  NotificationCtrl() : super([]);

  Future<void> load() async {
    try {
      state = await ApiService.getNotifications();
    } catch (_) {
      state = [];
    }
  }
}
