import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/assigned_card.dart';
import '../providers/assigned_card_provider.dart';

class AssignedTasksPage extends ConsumerWidget {
  const AssignedTasksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignedTasksAsync = ref.watch(assignedTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Assigned Tasks")),
      body: assignedTasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cards) {
          if (cards.isEmpty) {
            return const Center(child: Text("No tasks assigned."));
          }
          return ListView.separated(
            itemCount: cards.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final card = cards[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(card.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(card.projectName + " • " + card.columnTitle, style: TextStyle(fontSize: 12, color: Colors.blueGrey[700])),
                      if (card.description != null && card.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(card.description!, style: TextStyle(fontSize: 13)),
                        ),
                      const SizedBox(height: 8),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          Text(
                            "%${card.progressPercent} tamamlandı",
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          if (card.dueUtc != null)
                            Text(
                              "Teslim: ${DateFormat('dd.MM.yyyy').format(card.dueUtc!)}",
                              style: const TextStyle(fontSize: 13, color: Colors.orange),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        card.assignedUsers.isNotEmpty
                            ? "Assigned Members: " +
                                card.assignedUsers.map((u) => u.email).join(", ")
                            : "No members assigned.",
                        style: TextStyle(fontSize: 12, color: Colors.blueGrey[700]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
