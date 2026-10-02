import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../sprints/domain/entities/sprint.dart';
import '../../domain/entities/project_workspace.dart';

sealed class ProjectWorkspaceState extends Equatable {
  const ProjectWorkspaceState();

  @override
  List<Object?> get props => [];
}

class WorkspaceLoading extends ProjectWorkspaceState {
  const WorkspaceLoading();
}

class WorkspaceError extends ProjectWorkspaceState {
  final Failure failure;

  const WorkspaceError(this.failure);

  @override
  List<Object?> get props => [failure];
}

class WorkspaceLoaded extends ProjectWorkspaceState {
  final ProjectWorkspace workspace;

  /// Sprint shown on the board and in reports.
  final int? selectedSprintId;

  const WorkspaceLoaded(this.workspace, {this.selectedSprintId});

  Sprint? get selectedSprint => workspace.sprintById(selectedSprintId);

  @override
  List<Object?> get props => [workspace, selectedSprintId];
}
