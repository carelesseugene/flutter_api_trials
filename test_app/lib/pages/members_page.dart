import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';
import '../services/api_services.dart';

class MembersPage extends StatefulWidget {
  final String projectId;
  final bool amManager; // owner / lead (optional)
  final List<MemberDto> members; // can pass empty []

  const MembersPage({
    super.key,
    required this.projectId,
    required this.amManager,
    required this.members,
  });

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  late Future<ProjectDetails?> _futureDetails;
  String? myEmail;

  @override
  void initState() {
    super.initState();
    _futureDetails = ApiService.getProjectDetails(widget.projectId);
    _getMyEmail();
  }

  Future<void> _getMyEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      final claims = JwtDecoder.decode(token);
      setState(() {
        myEmail = claims['email']?.toString();
      });
    }
  }

  Future<void> _showInviteDialog(BuildContext ctx) async {
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Invite user'),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(labelText: 'Registered e‑mail'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (ok == true && c.text.trim().isNotEmpty) {
      try {
        await ApiService.inviteUser(widget.projectId, c.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(ctx)
              .showSnackBar(const SnackBar(content: Text('Invitation sent')));
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(ctx)
              .showSnackBar(const SnackBar(content: Text('User not found')));
        }
      }
    }
  }

  Future<void> _removeMember(BuildContext ctx, MemberDto member) async {
    try {
      await ApiService.removeMember(widget.projectId, member.userId);
      if (mounted) {
        ScaffoldMessenger.of(ctx)
            .showSnackBar(SnackBar(content: Text('Removed ${member.email}')));
        setState(() => _futureDetails = ApiService.getProjectDetails(widget.projectId));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(ctx)
            .showSnackBar(const SnackBar(content: Text('Could not remove member')));
      }
    }
  }

  Future<void> _leaveProject(BuildContext ctx) async {
    try {
      await ApiService.leaveProject(widget.projectId);
      if (mounted) {
        ScaffoldMessenger.of(ctx)
            .showSnackBar(const SnackBar(content: Text('You left the project')));
        Navigator.of(ctx).pop(); // Go back to project list
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(ctx)
            .showSnackBar(const SnackBar(content: Text('Failed to leave project')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: FutureBuilder<ProjectDetails?>(
        future: _futureDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || myEmail == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final details = snapshot.data;
          final members = details?.members ?? widget.members;
          // Find self by email (since only email is available in JWT)
          final me = members.firstWhere(
          (m) => m.email == myEmail,
          orElse: () => members[0], // just pick first member if not found
        );

          final isOwner = me != null && me.role == ProjectRole.lead;

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final member = members[i];
                    final isMe = member.email == myEmail;
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(member.email[0].toUpperCase()),
                      ),
                      title: Text(member.email),
                      subtitle: Text(member.role.name),
                      trailing: isOwner && !isMe
                          ? IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              tooltip: 'Remove from project',
                              onPressed: () => _removeMember(context, member),
                            )
                          : null,
                    );
                  },
                ),
              ),
              if (!isOwner)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Leave Project'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () => _leaveProject(context),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: widget.amManager
          ? FloatingActionButton(
              tooltip: 'Invite user',
              onPressed: () => _showInviteDialog(context),
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }
}
