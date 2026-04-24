import '../../../../core/utils/result.dart';
import '../entities/task.dart';

abstract class TaskRepository {
  Future<ApiResult<List<Task>>> getAllTasks();
  Future<ApiResult<List<Task>>> getTasksBySprint(int sprintId);
  Future<ApiResult<Task>> getTaskById(int id);
  Future<ApiResult<Task>> createTask(Task task);
  Future<ApiResult<Task>> updateTask(Task task);
  Future<ApiResult<void>> deleteTask(int id);
}
