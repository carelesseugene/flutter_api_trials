import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_services.dart';
import '../models/project.dart';

final projectsProvider =
    FutureProvider.autoDispose<List<ProjectSummary>>((ref) async {
  return ApiService.listProjects();
}); 

