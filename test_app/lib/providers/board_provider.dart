import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_services.dart';
import '../models/board.dart';

//   boardProvider(projectId)
final boardProvider =
    FutureProvider.family.autoDispose<List<BoardColumn>, String>((ref, pid) {
  return ApiService.getBoard(pid);
});
