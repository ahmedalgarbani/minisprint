import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../reports/domain/entities/sprint_report.dart';
import '../../../reports/domain/usecases/build_sprint_report.dart';
import '../../../sprints/domain/entities/sprint.dart';
import '../../../sprints/domain/usecases/sprint_usecases.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/usecases/task_usecases.dart';
import '../../domain/entities/project_workspace.dart';
import '../../domain/usecases/get_project_workspace.dart';
import 'project_workspace_state.dart';

/// State for one opened project. Board, Backlog and Reports all read it, so
/// a change made on one tab is immediately visible on the others.
///
/// Mutations return `null` on success or the [Failure] to show.
class ProjectWorkspaceCubit extends Cubit<ProjectWorkspaceState> {
  final GetProjectWorkspace getWorkspace;
  final CreateTask createTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;
  final MoveTaskToSprint moveTaskToSprint;
  final ChangeTaskStatus changeTaskStatus;
  final CreateSprint createSprint;
  final UpdateSprint updateSprint;
  final DeleteSprint deleteSprint;
  final StartSprint startSprint;
  final CompleteSprint completeSprint;
  final BuildSprintReport buildSprintReport;
  final DateTime Function() clock;

  int? _projectId;

  ProjectWorkspaceCubit({
    required this.getWorkspace,
    required this.createTask,
    required this.updateTask,
    required this.deleteTask,
    required this.moveTaskToSprint,
    required this.changeTaskStatus,
    required this.createSprint,
    required this.updateSprint,
    required this.deleteSprint,
    required this.startSprint,
    required this.completeSprint,
    required this.buildSprintReport,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now,
       super(const WorkspaceLoading());

  Future<void> load(int projectId) async {
    _projectId = projectId;
    emit(const WorkspaceLoading());
    await refresh();
  }

  /// Reloads without showing a spinner when data is already on screen.
  /// Returns `false` if loading failed.
  Future<bool> refresh() async {
    final projectId = _projectId;
    if (projectId == null) return false;
    final result = await getWorkspace(projectId);
    if (isClosed) return false;
    switch (result) {
      case Success(:final data):
        emit(WorkspaceLoaded(data, selectedSprintId: _resolveSelection(data)));
        return true;
      case Error(:final failure):
        if (state is! WorkspaceLoaded) emit(WorkspaceError(failure));
        return false;
    }
  }

  int? _resolveSelection(ProjectWorkspace workspace) {
    final current = state;
    if (current is WorkspaceLoaded) {
      final selected = workspace.sprintById(current.selectedSprintId);
      if (selected != null) return selected.id;
    }
    return workspace.defaultBoardSprint?.id;
  }

  void selectSprint(int sprintId) {
    final current = state;
    if (current is! WorkspaceLoaded) return;
    emit(WorkspaceLoaded(current.workspace, selectedSprintId: sprintId));
  }

  SprintReport? reportFor(Sprint sprint) {
    final current = state;
    if (current is! WorkspaceLoaded) return null;
    return buildSprintReport(
      workspace: current.workspace,
      sprint: sprint,
      now: clock(),
    );
  }

  // Work items

  Future<Failure?> saveTask(Task task) =>
      _mutate(task.id == null ? createTask(task) : updateTask(task));

  Future<Failure?> removeTask(int id) => _mutate(deleteTask(id));

  Future<Failure?> moveTask(Task task, int? sprintId) =>
      _mutate(moveTaskToSprint(task, sprintId));

  /// Optimistic: the card moves immediately and snaps back on failure.
  Future<Failure?> changeStatus(Task task, String status) async {
    final previous = state;
    if (previous is WorkspaceLoaded) {
      final ws = previous.workspace;
      emit(
        WorkspaceLoaded(
          ProjectWorkspace(
            project: ws.project,
            sprints: ws.sprints,
            tasks: [
              for (final t in ws.tasks)
                t.id == task.id ? t.copyWith(status: status) : t,
            ],
          ),
          selectedSprintId: previous.selectedSprintId,
        ),
      );
    }
    final result = await changeTaskStatus(task, status);
    final reloaded = await refresh();
    final failure = result.failureOrNull;
    // If the reload failed too, the optimistic state would linger: restore
    // what was on screen before the drag.
    if (failure != null &&
        !reloaded &&
        !isClosed &&
        previous is WorkspaceLoaded) {
      emit(previous);
    }
    return failure;
  }

  // Sprints

  Future<Failure?> saveSprint(Sprint sprint) =>
      _mutate(sprint.id == null ? createSprint(sprint) : updateSprint(sprint));

  Future<Failure?> removeSprint(int id) => _mutate(deleteSprint(id));

  Future<Failure?> start(Sprint sprint) async {
    final failure = await _mutate(startSprint(sprint));
    if (failure == null) selectSprint(sprint.id!);
    return failure;
  }

  Future<Failure?> complete(Sprint sprint) => _mutate(completeSprint(sprint));

  /// Always refreshes afterwards so the UI reflects the real stored state,
  /// including after a failed optimistic update.
  Future<Failure?> _mutate(Future<ApiResult<Object?>> operation) async {
    final result = await operation;
    await refresh();
    return result.failureOrNull;
  }
}
