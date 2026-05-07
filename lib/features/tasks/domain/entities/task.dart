import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final int? id;
  final int sprintId;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String assignee;
  final List<String> tags;

  const Task({
    this.id,
    required this.sprintId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.assignee = '',
    this.tags = const [],
  });

  Task copyWith({
    int? id,
    int? sprintId,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? assignee,
    List<String>? tags,
  }) {
    return Task(
      id: id ?? this.id,
      sprintId: sprintId ?? this.sprintId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignee: assignee ?? this.assignee,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
    id,
    sprintId,
    title,
    description,
    status,
    priority,
    assignee,
    tags,
  ];
}
