import 'package:equatable/equatable.dart';

class Sprint extends Equatable {
  final int? id;
  final int projectId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final int totalTasks;
  final int completedTasks;

  const Sprint({
    this.id,
    required this.projectId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.totalTasks = 0,
    this.completedTasks = 0,
  });

  double get progress => totalTasks == 0 ? 0.0 : completedTasks / totalTasks;


  Sprint copyWith({
    int? id,
    int? projectId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    int? totalTasks,
    int? completedTasks,
  }) {
    return Sprint(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
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
        startDate,
        endDate,
        status,
        totalTasks,
        completedTasks,
      ];
}
