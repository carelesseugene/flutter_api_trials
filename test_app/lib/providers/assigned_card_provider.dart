import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assigned_card.dart';
import '../services/api_services.dart';

// Bunu autoDispose ile yap!
final assignedTasksProvider = FutureProvider.autoDispose<List<AssignedCard>>((ref) async {
  return await ApiService.getAssignedCards();
});
