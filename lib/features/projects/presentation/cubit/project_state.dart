import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/project.dart';

sealed class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {
  const ProjectInitial();
}

class ProjectLoading extends ProjectState {
  const ProjectLoading();
}

class ProjectsLoaded extends ProjectState {
  final List<Project> projects;
  final String query;

  const ProjectsLoaded(this.projects, {this.query = ''});

  /// Projects matching [query] by name, key or description.
  List<Project> get visibleProjects {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return projects;
    return projects
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.displayKey.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q),
        )
        .toList();
  }

  int get totalSprints => projects.fold(0, (sum, p) => sum + p.sprintCount);
  int get totalTasks => projects.fold(0, (sum, p) => sum + p.taskCount);

  @override
  List<Object?> get props => [projects, query];
}

class ProjectError extends ProjectState {
  final Failure failure;

  const ProjectError(this.failure);

  @override
  List<Object?> get props => [failure];
}
