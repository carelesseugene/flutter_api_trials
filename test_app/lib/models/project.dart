class ProjectSummary {
  final String id;
  final String name;

  ProjectSummary({required this.id, required this.name});

  factory ProjectSummary.fromJson(Map<String, dynamic> j) =>
      ProjectSummary(id: j['id'], name: j['name']);
}
