import '../../../../core/utils/result.dart';
import '../../../../core/utils/validation.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasksByProject {
  final TaskRepository repository;

  GetTasksByProject(this.repository);

  Future<ApiResult<List<Task>>> call(int projectId) {
    return repository.getTasksByProject(projectId);
  }
}

class GetTasksBySprint {
  final TaskRepository repository;

  GetTasksBySprint(this.repository);

  Future<ApiResult<List<Task>>> call(int sprintId) {
    return repository.getTasksBySprint(sprintId);
  }
}

class CreateTask {
  final TaskRepository repository;

  CreateTask(this.repository);

  Future<ApiResult<Task>> call(Task task) async {
    final clean = normalizeTask(task);
    final error = validateTask<Task>(clean);
    return error ?? repository.createTask(clean);
  }
}

class UpdateTask {
  final TaskRepository repository;

  UpdateTask(this.repository);

  Future<ApiResult<Task>> call(Task task) async {
    final clean = normalizeTask(task);
    final error = validateTask<Task>(clean);
    return error ?? repository.updateTask(clean);
  }
}

class DeleteTask {
  final TaskRepository repository;

  DeleteTask(this.repository);

  Future<ApiResult<void>> call(int id) {
    return repository.deleteTask(id);
  }
}

/// Moves a task into a sprint, or back to the backlog when [sprintId] is null.
class MoveTaskToSprint {
  final TaskRepository repository;

  MoveTaskToSprint(this.repository);

  Future<ApiResult<Task>> call(Task task, int? sprintId) {
    return repository.updateTask(
      sprintId == null
          ? task.copyWith(clearSprint: true)
          : task.copyWith(sprintId: sprintId),
    );
  }
}

/// Moves a task to another board column (status).
class ChangeTaskStatus {
  final TaskRepository repository;

  ChangeTaskStatus(this.repository);

  Future<ApiResult<Task>> call(Task task, String status) {
    return repository.updateTask(task.copyWith(status: status));
  }
}

Task normalizeTask(Task task) => task.copyWith(
  title: task.title.trim(),
  description: task.description.trim(),
  assignee: task.assignee.trim(),
  tags: {
    for (final tag in task.tags)
      if (tag.trim().isNotEmpty) tag.trim(),
  }.toList(),
);

Error<T>? validateTask<T>(Task task) {
  if (task.title.isEmpty) return invalid(ValidationCodes.requiredTitle);
  final points = task.storyPoints;
  if (points != null && (points < 0 || points > 100)) {
    return invalid(ValidationCodes.invalidStoryPoints);
  }
  return null;
}
