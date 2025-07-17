/* -------------------------------------------------------------
   models/project.dart
   ----------------------------------------------------------- */

class ProjectSummary {
  final String id;
  final String name;
  final String ownerEmail;
  final int memberCount;
  ProjectSummary.fromJson(Map j)
      : id = j['id'],
        name = j['name'],
        ownerEmail = j['ownerEmail'],
        memberCount = j['memberCount'];
}

/* --- Member DTO used in details & board pages ---------------- */
class MemberDto {
  final String userId;
  final String email;
  final ProjectRole role;

  MemberDto.fromJson(Map j)
      : userId = j['userId'],
        email = j['email'],
        role  = ProjectRole.values
            .firstWhere((r) => r.name.toLowerCase() == (j['role'] as String).toLowerCase());
}

/* --- Enum matches backend ProjectRole ------------------------ */
enum ProjectRole { owner, lead, member }

/* --- Full project details (owner + members + columns count) -- */
class ProjectDetails {
  final String id;
  final String name;
  final String? description;
  final String ownerEmail;
  final List<MemberDto> members;
  

  ProjectDetails.fromJson(Map j)
      : id = j['id'],
        name = j['name'],
        description = j['description'],
        ownerEmail = j['ownerEmail'],
        members = (j['members'] as List)
            .map((e) => MemberDto.fromJson(e))
            .toList();
}
