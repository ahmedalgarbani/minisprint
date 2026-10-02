import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/json_utils.dart';
import '../../domain/entities/task.dart';

/// Maps [Task] to SQLite rows (`tags` as CSV) and API JSON (`tags` as list).
class TaskModel {
  const TaskModel._();

  static Task fromMap(Map<String, dynamic> map) {
    final rawTags = map['tags'];
    return Task(
      id: jsonInt(map['id']),
      projectId: jsonInt(map['project_id']) ?? 0,
      sprintId: jsonInt(map['sprint_id']),
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      status: map['status'] as String? ?? TaskStatus.todo,
      priority: map['priority'] as String? ?? TaskPriority.medium,
      type: WorkItemType.fromValue(map['type'] as String?),
      storyPoints: jsonInt(map['story_points']),
      assignee: map['assignee'] as String? ?? '',
      tags: rawTags is List
          ? rawTags
                .whereType<String>()
                .map((t) => t.trim())
                .where((t) => t.isNotEmpty)
                .toList()
          : decodeTags(rawTags as String?),
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? ''),
    );
  }

  static Map<String, dynamic> toMap(Task task) => {
    ..._common(task),
    'tags': task.tags.join(','),
  };

  static Map<String, dynamic> toJson(Task task) => {
    ..._common(task),
    'tags': task.tags,
  };

  static Map<String, dynamic> _common(Task task) => {
    if (task.id != null) 'id': task.id,
    'project_id': task.projectId,
    'sprint_id': task.sprintId,
    'title': task.title,
    'description': task.description,
    'status': task.status,
    'priority': task.priority,
    'type': task.type.name,
    'story_points': task.storyPoints,
    'assignee': task.assignee,
    'created_at': task.createdAt?.toIso8601String(),
  };

  static List<String> decodeTags(String? value) {
    if (value == null || value.trim().isEmpty) return const [];
    return value
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }
}
