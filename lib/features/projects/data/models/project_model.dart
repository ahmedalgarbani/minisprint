import 'package:equatable/equatable.dart';
import '../../domain/entities/project.dart';

class ProjectModel extends Equatable {
  final int? id;
  final String name;
  final String description;
  final int sprintCount;
  final int taskCount;

  const ProjectModel({
    this.id,
    required this.name,
    required this.description,
    this.sprintCount = 0,
    this.taskCount = 0,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      sprintCount: map['sprint_count'] as int? ?? 0,
      taskCount: map['task_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {if (id != null) 'id': id, 'name': name, 'description': description};
  }

  factory ProjectModel.fromEntity(Project project) {
    return ProjectModel(
      id: project.id,
      name: project.name,
      description: project.description,
      sprintCount: project.sprintCount,
      taskCount: project.taskCount,
    );
  }

  Project toEntity() {
    return Project(
      id: id,
      name: name,
      description: description,
      sprintCount: sprintCount,
      taskCount: taskCount,
    );
  }

  @override
  List<Object?> get props => [id, name, description, sprintCount, taskCount];
}
