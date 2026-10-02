import 'package:equatable/equatable.dart';

import '../../../../core/utils/date_math.dart';

/// Sprint lifecycle, like Jira (future / active / closed) and Azure DevOps
/// iterations (future / current / past).
enum SprintStatus {
  planned('Planned'),
  active('Active'),
  completed('Completed');

  /// Persisted value. `Active` / `Completed` match data written before v3.
  final String value;
  const SprintStatus(this.value);

  static SprintStatus fromValue(String? value) {
    for (final status in values) {
      if (status.value.toLowerCase() == value?.trim().toLowerCase()) {
        return status;
      }
    }
    return SprintStatus.planned;
  }
}

class Sprint extends Equatable {
  final int? id;
  final int projectId;
  final String name;
  final String goal;
  final DateTime startDate;
  final DateTime endDate;
  final SprintStatus status;
  final int totalTasks;
  final int completedTasks;

  const Sprint({
    this.id,
    required this.projectId,
    required this.name,
    this.goal = '',
    required this.startDate,
    required this.endDate,
    this.status = SprintStatus.planned,
    this.totalTasks = 0,
    this.completedTasks = 0,
  });

  double get progress => totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

  bool get isActive => status == SprintStatus.active;
  bool get isPlanned => status == SprintStatus.planned;
  bool get isCompleted => status == SprintStatus.completed;

  int get durationInDays => calendarDaysBetween(startDate, endDate);

  /// Whole days left until [endDate]; negative when the sprint is overdue.
  int daysRemaining(DateTime now) => calendarDaysBetween(now, endDate);

  Sprint copyWith({
    int? id,
    int? projectId,
    String? name,
    String? goal,
    DateTime? startDate,
    DateTime? endDate,
    SprintStatus? status,
    int? totalTasks,
    int? completedTasks,
  }) {
    return Sprint(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      goal: goal ?? this.goal,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
    );
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    name,
    goal,
    startDate,
    endDate,
    status,
    totalTasks,
    completedTasks,
  ];
}
