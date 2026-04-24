import '../../../../core/utils/result.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasksBySprint {
  final TaskRepository repository;

  GetTasksBySprint(this.repository);

  Future<ApiResult<List<Task>>> call(int sprintId) {
    return repository.getTasksBySprint(sprintId);
  }
}

class GetTaskById {
  final TaskRepository repository;

  GetTaskById(this.repository);

  Future<ApiResult<Task>> call(int id) {
    return repository.getTaskById(id);
  }
}

class CreateTask {
  final TaskRepository repository;

  CreateTask(this.repository);

  Future<ApiResult<Task>> call(Task task) {
    return repository.createTask(task);
  }
}

class UpdateTask {
  final TaskRepository repository;

  UpdateTask(this.repository);

  Future<ApiResult<Task>> call(Task task) {
    return repository.updateTask(task);
  }
}

class DeleteTask {
  final TaskRepository repository;

  DeleteTask(this.repository);

  Future<ApiResult<void>> call(int id) {
    return repository.deleteTask(id);
  }
}
