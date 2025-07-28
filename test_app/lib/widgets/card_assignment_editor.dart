// lib/widgets/card_assignment_editor.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_card.dart';
import '../models/project.dart';
import '../providers/board_provider.dart';

class CardAssignmentEditor extends ConsumerStatefulWidget {
  final String projectId;
  final TaskCard card;
  final List<MemberDto> allMembers;

  const CardAssignmentEditor({
    super.key,
    required this.projectId,
    required this.card,
    required this.allMembers,
  });

  @override
  ConsumerState<CardAssignmentEditor> createState() => _CardAssignmentEditorState();
}

class _CardAssignmentEditorState extends ConsumerState<CardAssignmentEditor> {
  late Set<String> selectedUserIds;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    selectedUserIds = widget.card.assignedUsers.map((u) => u.userId).toSet();
  }

  @override
  void didUpdateWidget(covariant CardAssignmentEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If card assignments change externally, update local state
    if (widget.card.id != oldWidget.card.id ||
        widget.card.assignedUsers.length != oldWidget.card.assignedUsers.length) {
      selectedUserIds = widget.card.assignedUsers.map((u) => u.userId).toSet();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Assign Members:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: widget.allMembers.map((member) {
            final assigned = selectedUserIds.contains(member.userId);
            return FilterChip(
              label: Text(member.email, style: const TextStyle(fontSize: 13)),
              selected: assigned,
              onSelected: _loading
                  ? null
                  : (selected) {
                      setState(() {
                        if (selected) {
                          selectedUserIds.add(member.userId);
                        } else {
                          selectedUserIds.remove(member.userId);
                        }
                      });
                    },
              selectedColor: Colors.blue.shade100,
              showCheckmark: true,
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: _loading
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.save),
          label: const Text("Save Assignment"),
          onPressed: _loading
              ? null
              : () async {
                  setState(() => _loading = true);
                  try {
                    await ref.read(boardProvider(widget.projectId).notifier)
                        .assignUsersToCard(widget.card.id, selectedUserIds.toList());
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Assignments updated!")));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e")));
                    }
                  }
                  setState(() => _loading = false);
                },
        ),
      ],
    );
  }
}
