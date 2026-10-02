import '../../../../core/network/json_utils.dart';
import '../../domain/entities/sprint.dart';

/// Maps [Sprint] to and from SQLite rows and API JSON (both snake_case).
class SprintModel {
  const SprintModel._();

  static Sprint fromMap(Map<String, dynamic> map) {
    return Sprint(
      id: jsonInt(map['id']),
      projectId: jsonInt(map['project_id']) ?? 0,
      name: map['name'] as String? ?? '',
      goal: map['goal'] as String? ?? '',
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      status: SprintStatus.fromValue(map['status'] as String?),
      totalTasks: jsonInt(map['total_tasks']) ?? 0,
      completedTasks: jsonInt(map['completed_tasks']) ?? 0,
    );
  }

  static Map<String, dynamic> toMap(Sprint sprint) {
    return {
      if (sprint.id != null) 'id': sprint.id,
      'project_id': sprint.projectId,
      'name': sprint.name,
      'goal': sprint.goal,
      'start_date': sprint.startDate.toIso8601String(),
      'end_date': sprint.endDate.toIso8601String(),
      'status': sprint.status.value,
    };
  }
}
