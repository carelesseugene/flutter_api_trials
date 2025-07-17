import 'package:flutter/material.dart';
import '../models/project.dart';          // contains MemberDto

class MembersPage extends StatelessWidget {
  final List<MemberDto> members;
  const MembersPage(this.members, {super.key});

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
            subtitle: Text(members[i].role.name),   // "owner" or "member"
          ),
        ),
      );
}
