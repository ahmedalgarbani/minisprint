import 'package:equatable/equatable.dart';

class Project extends Equatable {
  final int? id;
  final String name;
  final String description;
  final int sprintCount;
  final int taskCount;

  const Project({
    this.id,
    required this.name,
    required this.description,
    this.sprintCount = 0,
    this.taskCount = 0,
  });

  Project copyWith({
    int? id,
    String? name,
    String? description,
    int? sprintCount,
    int? taskCount,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sprintCount: sprintCount ?? this.sprintCount,
      taskCount: taskCount ?? this.taskCount,
    );
  }

  @override
  List<Object?> get props => [id, name, description, sprintCount, taskCount];
}
