import 'package:equatable/equatable.dart';
import '../../domain/entities/sprint.dart';

class SprintModel extends Equatable {
  final int? id;
  final int projectId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final int totalTasks;
  final int completedTasks;

  const SprintModel({
    this.id,
    required this.projectId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.totalTasks = 0,
    this.completedTasks = 0,
  });

  factory SprintModel.fromMap(Map<String, dynamic> map) {
    return SprintModel(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      name: map['name'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      status: map['status'] as String,
      totalTasks: map['total_tasks'] as int? ?? 0,
      completedTasks: map['completed_tasks'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'project_id': projectId,
      'name': name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
    };
  }

  factory SprintModel.fromEntity(Sprint sprint) {
    return SprintModel(
      id: sprint.id,
      projectId: sprint.projectId,
      name: sprint.name,
      startDate: sprint.startDate,
      endDate: sprint.endDate,
      status: sprint.status,
      totalTasks: sprint.totalTasks,
      completedTasks: sprint.completedTasks,
    );
  }

  Sprint toEntity() {
    return Sprint(
      id: id,
      projectId: projectId,
      name: name,
      startDate: startDate,
      endDate: endDate,
      status: status,
      totalTasks: totalTasks,
      completedTasks: completedTasks,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        name,
        startDate,
        endDate,
        status,
        totalTasks,
        completedTasks,
      ];
}
