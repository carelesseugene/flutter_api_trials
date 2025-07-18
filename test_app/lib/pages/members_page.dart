import 'package:flutter/material.dart';
import '../models/project.dart';          // MemberDto & ProjectRole
import '../services/api_services.dart';

class MembersPage extends StatelessWidget {
  final String projectId;
  final bool amManager;                 // owner / lead
  final List<MemberDto> members;

  const MembersPage({
    super.key,
    required this.projectId,
    required this.amManager,
    required this.members,
  });

  Future<void> _showInviteDialog(BuildContext ctx) async {
  final c = TextEditingController();
  final ok = await showDialog<bool>(
    context: ctx,
    builder: (dialogCtx) => AlertDialog(          // ➊ rename param
      title: const Text('Invite user'),
      content: TextField(
        controller: c,
        decoration: const InputDecoration(labelText: 'Registered e‑mail'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx, false),   // ➋ use dialogCtx
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogCtx, true),    // ➌ use dialogCtx
          child: const Text('Send'),
        ),
      ],
    ),
  );

  if (ok == true && c.text.trim().isNotEmpty) {
    try {
      await ApiService.inviteUser(projectId, c.text.trim());
      ScaffoldMessenger.of(ctx)
          .showSnackBar(const SnackBar(content: Text('Invitation sent')));
    } catch (_) {
      ScaffoldMessenger.of(ctx)
          .showSnackBar(const SnackBar(content: Text('User not found')));
    }
  }
}


  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Members')),
        body: ListView.separated(
          itemCount: members.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) => ListTile(
            leading: CircleAvatar(
              child: Text(members[i].email[0].toUpperCase()),
            ),
            title: Text(members[i].email),
            subtitle: Text(members[i].role.name), // "owner", "lead", "member"
          ),
        ),
        floatingActionButton: amManager
            ? FloatingActionButton(
                tooltip: 'Invite user',
                onPressed: () => _showInviteDialog(context),
                child: const Icon(Icons.person_add),
              )
            : null,
      );
}
