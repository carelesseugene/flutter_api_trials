import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/board.dart';
import '../services/api_services.dart';

class BoardNotifier extends StateNotifier<AsyncValue<List<BoardColumn>>> {
  BoardNotifier(this.projectId) : super(const AsyncValue.loading()) {
    _load();                // load board initially
  }

  final String projectId;

  Future<void> _load() async {
    try {
      final data = await ApiService.getBoard(projectId);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Called by SignalR/CardCreated.
  void addCard(TaskCard card) {
    state.whenData((cols) {
      final idx = cols.indexWhere((c) => c.id == card.columnId);
      if (idx == -1) return;
      final mutCols = [...cols];
      final updatedCards = [...mutCols[idx].cards, card]
        ..sort((a, b) => a.position.compareTo(b.position));
      mutCols[idx] = mutCols[idx].copyWith(cards: updatedCards);
      state = AsyncValue.data(mutCols);
    });
  }

  // Manual reload.
  Future<void> refresh() => _load();
}

// Provider keyed by projectId, exposes notifier to allow .addCard.
final boardProvider = StateNotifierProvider.autoDispose
    .family<BoardNotifier, AsyncValue<List<BoardColumn>>, String>(
  (ref, pid) => BoardNotifier(pid),
);
