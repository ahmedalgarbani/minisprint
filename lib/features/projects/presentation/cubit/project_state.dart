import 'package:equatable/equatable.dart';
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

  const ProjectsLoaded(this.projects);

  @override
  List<Object?> get props => [projects];
}

class ProjectOperationSuccess extends ProjectState {
  final String message;

  const ProjectOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProjectError extends ProjectState {
  final String message;

  const ProjectError(this.message);

  @override
  List<Object?> get props => [message];
}
