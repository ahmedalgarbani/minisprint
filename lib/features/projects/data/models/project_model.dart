import '../../../../core/network/json_utils.dart';
import '../../domain/entities/project.dart';

/// Maps [Project] to and from SQLite rows and API JSON (both snake_case).
class ProjectModel {
  const ProjectModel._();

  static Project fromMap(Map<String, dynamic> map) {
    return Project(
      id: jsonInt(map['id']),
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      key: map['key'] as String? ?? '',
      sprintCount: jsonInt(map['sprint_count']) ?? 0,
      taskCount: jsonInt(map['task_count']) ?? 0,
    );
  }

  /// Writable fields only; counts are computed by the data source.
  static Map<String, dynamic> toMap(Project project) {
    return {
      if (project.id != null) 'id': project.id,
      'name': project.name,
      'description': project.description,
      'key': project.key,
    };
  }
}
