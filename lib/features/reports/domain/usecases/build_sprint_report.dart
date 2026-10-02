import '../../../../core/constants/app_constants.dart';
import '../../../projects/domain/entities/project_workspace.dart';
import '../../../sprints/domain/entities/sprint.dart';
import '../../../tasks/domain/entities/task.dart';
import '../entities/sprint_report.dart';

/// Pure function computing sprint metrics from the loaded workspace.
class BuildSprintReport {
  /// How many completed sprints feed the velocity chart.
  static const velocityWindow = 5;

  const BuildSprintReport();

  SprintReport call({
    required ProjectWorkspace workspace,
    required Sprint sprint,
    required DateTime now,
  }) {
    final tasks = workspace.tasksInSprint(sprint.id!);
    final done = tasks.where((t) => t.isDone).toList();
    const points = totalStoryPoints;

    final statusCounts = <String, int>{
      for (final status in TaskStatus.values)
        if (tasks.any((t) => t.status == status)) status: 0,
    };
    for (final task in tasks) {
      statusCounts[task.status] = (statusCounts[task.status] ?? 0) + 1;
    }

    final typeCounts = {for (final type in WorkItemType.values) type: 0};
    for (final task in tasks) {
      typeCounts[task.type] = typeCounts[task.type]! + 1;
    }

    final priorityCounts = {for (final p in TaskPriority.values.reversed) p: 0};
    for (final task in tasks) {
      priorityCounts[task.priority] = (priorityCounts[task.priority] ?? 0) + 1;
    }

    final byAssignee = <String, List<Task>>{};
    for (final task in tasks) {
      byAssignee.putIfAbsent(task.assignee.trim(), () => []).add(task);
    }
    final workload =
        byAssignee.entries.map((entry) {
          final doneCount = entry.value.where((t) => t.isDone).length;
          return AssigneeLoad(
            assignee: entry.key,
            open: entry.value.length - doneCount,
            done: doneCount,
            points: points(entry.value),
          );
        }).toList()..sort((a, b) {
          if (a.assignee.isEmpty != b.assignee.isEmpty) {
            return a.assignee.isEmpty ? 1 : -1;
          }
          return b.total.compareTo(a.total);
        });

    final daysTotal = sprint.durationInDays;
    final daysElapsed = (daysTotal - sprint.daysRemaining(now)).clamp(
      0,
      daysTotal < 0 ? 0 : daysTotal,
    );

    final velocity = workspace.completedSprints
        .take(velocityWindow)
        .toList()
        .reversed
        .map((s) {
          final doneTasks = workspace
              .tasksInSprint(s.id!)
              .where((t) => t.isDone);
          return VelocityPoint(
            sprintName: s.name,
            donePoints: points(doneTasks),
            doneTasks: doneTasks.length,
          );
        })
        .toList();

    return SprintReport(
      sprintStatus: sprint.status,
      totalTasks: tasks.length,
      doneTasks: done.length,
      totalPoints: points(tasks),
      donePoints: points(done),
      statusCounts: statusCounts,
      typeCounts: typeCounts,
      priorityCounts: priorityCounts,
      workload: workload,
      daysTotal: daysTotal,
      daysElapsed: daysElapsed,
      velocity: velocity,
      backlogCount: workspace.backlogTasks.length,
    );
  }
}
