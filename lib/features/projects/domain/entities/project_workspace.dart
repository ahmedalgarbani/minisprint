import 'package:equatable/equatable.dart';

import '../../../sprints/domain/entities/sprint.dart';
import '../../../tasks/domain/entities/task.dart';
import 'project.dart';

/// Everything loaded for one project: its sprints and all its work items.
/// Board, Backlog and Reports are all views over this aggregate.
class ProjectWorkspace extends Equatable {
  final Project project;
  final List<Sprint> sprints;
  final List<Task> tasks;

  const ProjectWorkspace({
    required this.project,
    required this.sprints,
    required this.tasks,
  });

  String get projectKey => project.displayKey;

  List<Sprint> get activeSprints => _byStart(sprints.where((s) => s.isActive));

  List<Sprint> get plannedSprints =>
      _byStart(sprints.where((s) => s.isPlanned));

  /// Most recently finished first.
  List<Sprint> get completedSprints =>
      sprints.where((s) => s.isCompleted).toList()
        ..sort((a, b) => b.endDate.compareTo(a.endDate));

  /// Sprints that can still receive work: active first, then planned.
  List<Sprint> get openSprints => [...activeSprints, ...plannedSprints];

  List<Task> get backlogTasks => tasks.where((t) => t.isInBacklog).toList();

  List<Task> tasksInSprint(int sprintId) =>
      tasks.where((t) => t.sprintId == sprintId).toList();

  Sprint? sprintById(int? id) {
    if (id == null) return null;
    for (final sprint in sprints) {
      if (sprint.id == id) return sprint;
    }
    return null;
  }

  /// The sprint the board shows by default: the active one, else the next
  /// planned one.
  Sprint? get defaultBoardSprint {
    final open = openSprints;
    return open.isEmpty ? null : open.first;
  }

  static List<Sprint> _byStart(Iterable<Sprint> sprints) =>
      sprints.toList()..sort((a, b) {
        final byDate = a.startDate.compareTo(b.startDate);
        return byDate != 0 ? byDate : (a.id ?? 0).compareTo(b.id ?? 0);
      });

  @override
  List<Object?> get props => [project, sprints, tasks];
}
