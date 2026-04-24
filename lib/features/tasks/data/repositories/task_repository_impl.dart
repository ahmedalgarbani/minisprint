import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({required this.localDataSource});

  @override
  Future<ApiResult<List<Task>>> getAllTasks() async {
    try {
      final models = await localDataSource.getAllTasks();
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Error(DatabaseFailure('Failed to get all tasks: $e'));
    }
  }

  @override
  Future<ApiResult<List<Task>>> getTasksBySprint(int sprintId) async {
    try {
      final models = await localDataSource.getTasksBySprint(sprintId);
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Error(DatabaseFailure('Failed to get tasks: $e'));
    }
  }

  @override
  Future<ApiResult<Task>> getTaskById(int id) async {
    try {
      final model = await localDataSource.getTaskById(id);
      return Success(model.toEntity());
    } catch (e) {
      return Error(DatabaseFailure('Failed to get task: $e'));
    }
  }

  @override
  Future<ApiResult<Task>> createTask(Task task) async {
    try {
      final model = TaskModel.fromEntity(task);
      final result = await localDataSource.createTask(model);
      return Success(result.toEntity());
    } catch (e) {
      return Error(DatabaseFailure('Failed to create task: $e'));
    }
  }

  @override
  Future<ApiResult<Task>> updateTask(Task task) async {
    try {
      final model = TaskModel.fromEntity(task);
      final result = await localDataSource.updateTask(model);
      return Success(result.toEntity());
    } catch (e) {
      return Error(DatabaseFailure('Failed to update task: $e'));
    }
  }

  @override
  Future<ApiResult<void>> deleteTask(int id) async {
    try {
      await localDataSource.deleteTask(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to delete task: $e'));
    }
  }
}
