import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/task_usecases.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final GetTasksBySprint getTasksBySprint;
  final CreateTask createTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;

  TaskCubit({
    required this.getTasksBySprint,
    required this.createTask,
    required this.updateTask,
    required this.deleteTask,
  }) : super(const TaskInitial());

  Future<void> loadTasks(int sprintId) async {
    emit(const TaskLoading());
    final result = await getTasksBySprint(sprintId);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (tasks) => emit(TasksLoaded(tasks)),
    );
  }

  Future<void> addTask(Task task) async {
    emit(const TaskLoading());
    final result = await createTask(task);
    result.fold((failure) => emit(TaskError(failure.message)), (_) {
      emit(const TaskOperationSuccess('Task created successfully'));
      loadTasks(task.sprintId);
    });
  }

  Future<void> editTask(Task task) async {
    emit(const TaskLoading());
    final result = await updateTask(task);
    result.fold((failure) => emit(TaskError(failure.message)), (_) {
      emit(const TaskOperationSuccess('Task updated successfully'));
      loadTasks(task.sprintId);
    });
  }

  Future<void> updateTaskStatus(Task task, String newStatus) async {
    final updatedTask = task.copyWith(status: newStatus);
    final result = await updateTask(updatedTask);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) => loadTasks(task.sprintId),
    );
  }

  Future<void> removeTask(int id, int sprintId) async {
    emit(const TaskLoading());
    final result = await deleteTask(id);
    result.fold((failure) => emit(TaskError(failure.message)), (_) {
      emit(const TaskOperationSuccess('Task deleted successfully'));
      loadTasks(sprintId);
    });
  }
}
