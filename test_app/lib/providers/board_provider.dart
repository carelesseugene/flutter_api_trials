// providers/board_provider.dart
// ---------------------------------
// StateNotifier so we CAN call .notifier from RealtimeService.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/board.dart';
import '../services/api_services.dart';

class BoardNotifier extends StateNotifier<AsyncValue<List<BoardColumn>>> {
  BoardNotifier(this.projectId) : super(const AsyncValue.loading()) {
    _load();          // initial fetch
  }

  final String projectId;

  Future<void> _load() async {            // pull board from API
    try {
      final data = await ApiService.getBoard(projectId);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /* called by SignalR when a new card arrives */
  void addCard(TaskCard card) {
    state.whenData((cols) {
      final idx = cols.indexWhere((c) => c.id == card.columnId);
      if (idx == -1) return;
      final mutCols = [...cols];
      final updatedCards = [...mutCols[idx].cards, card]
        ..sort((a, b) => a.position.compareTo(b.position));
      mutCols[idx] = mutCols[idx].copyWith(cards: updatedCards); // add copyWith to model
      state = AsyncValue.data(mutCols);
    });
  }

  /* manual refresh */
  Future<void> refresh() => _load();
}

/* provider family keyed by projectId */
final boardProvider = StateNotifierProvider.autoDispose
    .family<BoardNotifier, AsyncValue<List<BoardColumn>>, String>(
  (ref, pid) => BoardNotifier(pid),
);
