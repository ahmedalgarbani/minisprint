import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';

class TaskModel extends Equatable {
  final int? id;
  final int sprintId;
  final String title;
  final String description;
  final String status;
  final String priority;

  const TaskModel({
    this.id,
    required this.sprintId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      sprintId: map['sprint_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      status: map['status'] as String,
      priority: map['priority'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'sprint_id': sprintId,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
    };
  }

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      sprintId: task.sprintId,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
    );
  }

  Task toEntity() {
    return Task(
      id: id,
      sprintId: sprintId,
      title: title,
      description: description,
      status: status,
      priority: priority,
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
  ];
}
