import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assigned_card.dart';
import '../services/api_services.dart';

final assignedTasksProvider = FutureProvider<List<AssignedCard>>((ref) async {
  return await ApiService.getAssignedCards();
});
