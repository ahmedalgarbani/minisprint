import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/validation.dart';
import '../../../tasks/domain/repositories/task_repository.dart';
import '../entities/sprint.dart';
import '../repositories/sprint_repository.dart';

class GetSprintsByProject {
  final SprintRepository repository;

  GetSprintsByProject(this.repository);

  Future<ApiResult<List<Sprint>>> call(int projectId) {
    return repository.getSprintsByProject(projectId);
  }
}

class GetSprintById {
  final SprintRepository repository;

  GetSprintById(this.repository);

  Future<ApiResult<Sprint>> call(int id) {
    return repository.getSprintById(id);
  }
}

class CreateSprint {
  final SprintRepository repository;

  CreateSprint(this.repository);

  /// New sprints always start as [SprintStatus.planned]; use [StartSprint] to
  /// activate them.
  Future<ApiResult<Sprint>> call(Sprint sprint) async {
    final clean = _normalize(sprint).copyWith(status: SprintStatus.planned);
    final error = _validate<Sprint>(clean);
    return error ?? repository.createSprint(clean);
  }
}

class UpdateSprint {
  final SprintRepository repository;

  UpdateSprint(this.repository);

  Future<ApiResult<Sprint>> call(Sprint sprint) async {
    final clean = _normalize(sprint);
    final error = _validate<Sprint>(clean);
    return error ?? repository.updateSprint(clean);
  }
}

class DeleteSprint {
  final SprintRepository repository;

  DeleteSprint(this.repository);

  /// Tasks of the deleted sprint go back to the backlog.
  Future<ApiResult<void>> call(int id) {
    return repository.deleteSprint(id);
  }
}

/// Planned → Active. Only one sprint per project can be active at a time
/// (the default Jira Scrum rule), which keeps "the board" unambiguous.
class StartSprint {
  final SprintRepository repository;

  StartSprint(this.repository);

  Future<ApiResult<Sprint>> call(Sprint sprint) async {
    if (!sprint.isPlanned) return invalid(ValidationCodes.sprintNotPlanned);
    final existing = await repository.getSprintsByProject(sprint.projectId);
    switch (existing) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final data):
        final otherActive = data.any((s) => s.isActive && s.id != sprint.id);
        if (otherActive) return invalid(ValidationCodes.activeSprintExists);
    }
    return repository.updateSprint(
      sprint.copyWith(status: SprintStatus.active),
    );
  }
}

/// Active → Completed. Unfinished tasks move back to the product backlog so
/// they can be planned into the next sprint (Jira's default behaviour).
///
/// Not atomic against a remote API: if a call fails midway, some tasks are
/// already in the backlog and the sprint stays active. Retrying is safe — it
/// moves the remaining tasks and then completes the sprint.
class CompleteSprint {
  final SprintRepository sprintRepository;
  final TaskRepository taskRepository;

  CompleteSprint(this.sprintRepository, this.taskRepository);

  Future<ApiResult<Sprint>> call(Sprint sprint) async {
    if (!sprint.isActive) return invalid(ValidationCodes.sprintNotActive);
    final tasksResult = await taskRepository.getTasksBySprint(sprint.id!);
    if (tasksResult case Error(:final failure)) return Error(failure);
    final unfinished = tasksResult.dataOrNull!.where(
      (task) => task.status != TaskStatus.done,
    );
    for (final task in unfinished) {
      final moved = await taskRepository.updateTask(
        task.copyWith(clearSprint: true),
      );
      if (moved case Error(:final failure)) return Error(failure);
    }
    return sprintRepository.updateSprint(
      sprint.copyWith(status: SprintStatus.completed),
    );
  }
}

Sprint _normalize(Sprint sprint) =>
    sprint.copyWith(name: sprint.name.trim(), goal: sprint.goal.trim());

Error<T>? _validate<T>(Sprint sprint) {
  if (sprint.name.isEmpty) return invalid(ValidationCodes.requiredName);
  if (sprint.endDate.isBefore(sprint.startDate)) {
    return invalid(ValidationCodes.invalidDateRange);
  }
  return null;
}
