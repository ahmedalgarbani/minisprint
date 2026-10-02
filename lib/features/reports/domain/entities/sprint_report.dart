import 'package:equatable/equatable.dart';

import '../../../sprints/domain/entities/sprint.dart';
import '../../../tasks/domain/entities/task.dart';

enum ScheduleHealth { notStarted, onTrack, atRisk, finished }

class AssigneeLoad extends Equatable {
  /// Empty for unassigned work.
  final String assignee;
  final int open;
  final int done;
  final int points;

  const AssigneeLoad({
    required this.assignee,
    required this.open,
    required this.done,
    required this.points,
  });

  int get total => open + done;

  @override
  List<Object?> get props => [assignee, open, done, points];
}

class VelocityPoint extends Equatable {
  final String sprintName;
  final int donePoints;
  final int doneTasks;

  const VelocityPoint({
    required this.sprintName,
    required this.donePoints,
    required this.doneTasks,
  });

  @override
  List<Object?> get props => [sprintName, donePoints, doneTasks];
}

class SprintReport extends Equatable {
  /// Completion may lag elapsed time by this much before the sprint is
  /// flagged as at risk.
  static const riskTolerance = 0.15;

  final SprintStatus sprintStatus;
  final int totalTasks;
  final int doneTasks;
  final int totalPoints;
  final int donePoints;

  /// Count per status, in board order.
  final Map<String, int> statusCounts;
  final Map<WorkItemType, int> typeCounts;
  final Map<String, int> priorityCounts;
  final List<AssigneeLoad> workload;
  final int daysTotal;
  final int daysElapsed;

  /// Done work of recently completed sprints, oldest first.
  final List<VelocityPoint> velocity;
  final int backlogCount;

  const SprintReport({
    required this.sprintStatus,
    required this.totalTasks,
    required this.doneTasks,
    required this.totalPoints,
    required this.donePoints,
    required this.statusCounts,
    required this.typeCounts,
    required this.priorityCounts,
    required this.workload,
    required this.daysTotal,
    required this.daysElapsed,
    required this.velocity,
    required this.backlogCount,
  });

  int get openTasks => totalTasks - doneTasks;

  /// Story-point based when the sprint is estimated, task-count based
  /// otherwise.
  double get completion {
    if (totalPoints > 0) return donePoints / totalPoints;
    return totalTasks == 0 ? 0 : doneTasks / totalTasks;
  }

  double get timeElapsed =>
      daysTotal <= 0 ? 1 : (daysElapsed / daysTotal).clamp(0.0, 1.0);

  int get daysRemaining => (daysTotal - daysElapsed).clamp(0, daysTotal);

  ScheduleHealth get health {
    if (sprintStatus == SprintStatus.completed) return ScheduleHealth.finished;
    if (sprintStatus == SprintStatus.planned) return ScheduleHealth.notStarted;
    if (totalTasks > 0 && openTasks == 0) return ScheduleHealth.finished;
    return completion + riskTolerance >= timeElapsed
        ? ScheduleHealth.onTrack
        : ScheduleHealth.atRisk;
  }

  double? get averageVelocity => velocity.isEmpty
      ? null
      : velocity.fold<int>(0, (sum, v) => sum + v.donePoints) / velocity.length;

  @override
  List<Object?> get props => [
    sprintStatus,
    totalTasks,
    doneTasks,
    totalPoints,
    donePoints,
    statusCounts,
    typeCounts,
    priorityCounts,
    workload,
    daysTotal,
    daysElapsed,
    velocity,
    backlogCount,
  ];
}
