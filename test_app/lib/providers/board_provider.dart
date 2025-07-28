import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/board.dart';
import '../models/task_card.dart'; // for TaskCard
import '../services/api_services.dart';

class BoardNotifier extends StateNotifier<AsyncValue<List<BoardColumn>>> {
  BoardNotifier(this.projectId) : super(const AsyncValue.loading()) {
    _load();
  }

  final String projectId;

  // Load the full board (all columns & cards)
  Future<void> _load() async {
    try {
      final data = await ApiService.getBoard(projectId);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Assign multiple users to a card and refresh board
  Future<void> assignUsersToCard(String cardId, List<String> userIds) async {
    await ApiService.assignUsersToCard(projectId, cardId, userIds);
    await _load();
  }

  // Update progress (only works if current user is assigned on backend)
  Future<void> updateCardProgress(String cardId, int progress) async {
    await ApiService.updateCardProgress(projectId, cardId, progress);
    await _load();
  }

  // Add a card to the state (used for real-time events or optimistic UI)
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

  // Replace a card in the state (for local UI updates, optional)
  void updateCardLocally(TaskCard updatedCard) {
    state.whenData((cols) {
      final mutCols = [...cols];
      for (int i = 0; i < mutCols.length; i++) {
        final cardIdx = mutCols[i].cards.indexWhere((c) => c.id == updatedCard.id);
        if (cardIdx != -1) {
          final updatedCards = [...mutCols[i].cards];
          updatedCards[cardIdx] = updatedCard;
          mutCols[i] = mutCols[i].copyWith(cards: updatedCards);
          break;
        }
      }
      state = AsyncValue.data(mutCols);
    });
  }

  // Manual board reload (pull-to-refresh, etc)
  Future<void> refresh() => _load();
}

// Riverpod provider keyed by projectId
final boardProvider = StateNotifierProvider.autoDispose
    .family<BoardNotifier, AsyncValue<List<BoardColumn>>, String>(
  (ref, pid) => BoardNotifier(pid),
);
