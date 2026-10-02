import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

/// Work item types, as in Jira issue types / Azure DevOps work item types.
enum WorkItemType {
  story,
  task,
  bug;

  static WorkItemType fromValue(String? value) =>
      values.asNameMap()[value?.trim().toLowerCase()] ?? WorkItemType.task;
}

/// Fibonacci-like estimate scale offered by the UI.
const storyPointScale = [1, 2, 3, 5, 8, 13, 21];

class Task extends Equatable {
  final int? id;
  final int projectId;

  /// `null` while the task is in the product backlog.
  final int? sprintId;
  final String title;
  final String description;
  final String status;
  final String priority;
  final WorkItemType type;
  final int? storyPoints;
  final String assignee;
  final List<String> tags;
  final DateTime? createdAt;

  const Task({
    this.id,
    required this.projectId,
    this.sprintId,
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.type = WorkItemType.task,
    this.storyPoints,
    this.assignee = '',
    this.tags = const [],
    this.createdAt,
  });

  bool get isDone => status == TaskStatus.done;
  bool get isInBacklog => sprintId == null;

  /// Jira-style key, e.g. `MOB-12`.
  String keyFor(String projectKey) => '$projectKey-${id ?? '?'}';

  Task copyWith({
    int? id,
    int? projectId,
    int? sprintId,
    bool clearSprint = false,
    String? title,
    String? description,
    String? status,
    String? priority,
    WorkItemType? type,
    int? storyPoints,
    bool clearStoryPoints = false,
    String? assignee,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      sprintId: clearSprint ? null : sprintId ?? this.sprintId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      storyPoints: clearStoryPoints ? null : storyPoints ?? this.storyPoints,
      assignee: assignee ?? this.assignee,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    sprintId,
    title,
    description,
    status,
    priority,
    type,
    storyPoints,
    assignee,
    tags,
    createdAt,
  ];
}

/// Higher value = more urgent. Unknown priorities sort last.
int priorityWeight(String priority) => switch (priority) {
  TaskPriority.high => 3,
  TaskPriority.medium => 2,
  TaskPriority.low => 1,
  _ => 0,
};

int totalStoryPoints(Iterable<Task> tasks) =>
    tasks.fold(0, (sum, task) => sum + (task.storyPoints ?? 0));
