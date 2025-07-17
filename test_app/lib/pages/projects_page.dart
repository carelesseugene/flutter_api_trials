import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';
import '../services/api_services.dart';
import '../pages/board_page.dart';
class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
            title: const Text('Projects'),
            actions: [
            ],
          ),
      body: projectsAsync.when(
        data: (list) => ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) => ListTile(
            title: Text(list[i].name),
            onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BoardPage(
                projectId: list[i].id,
                projectName: list[i].name,
              ),
            ),
          ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await ApiService.deleteProject(list[i].id);
                ref.invalidate(projectsProvider);
              },
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final name = await _newProjectDialog(context);
          if (name != null && name.isNotEmpty) {
            await ApiService.createProject(name, null);
            ref.invalidate(projectsProvider);
          }
        },
      ),
    );
  }

  Future<String?> _newProjectDialog(BuildContext ctx) async {
    final c = TextEditingController();
    return showDialog<String>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('New Project'),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, c.text.trim()),
              child: const Text('Create')),
        ],
      ),
    );
  }
}
