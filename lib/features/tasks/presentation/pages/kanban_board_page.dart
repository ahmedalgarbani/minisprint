import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/string_helper.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../sprints/domain/entities/sprint.dart';
import '../../../tasks/domain/entities/task.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../widgets/kanban_column.dart';
import 'task_form_page.dart';

class KanbanBoardPage extends StatelessWidget {
  final Sprint sprint;
  const KanbanBoardPage({super.key, required this.sprint});

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppAppBar(
        title: sprint.name,
        subtitle: Text(
          s.board,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: theme.primaryColor),
            onPressed: () => _showCreateDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading)
            return const Center(child: CircularProgressIndicator());
          if (state is TaskError)
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppPadding.m),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<TaskCubit>().loadTasks(sprint.id!),
                    child: Text(s.retry),
                  ),
                ],
              ),
            );
          if (state is TasksLoaded) {
            if (state.tasks.isEmpty)
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt_rounded,
                      size: 80,
                      color: theme.disabledColor.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: AppPadding.m),
                    Text(s.noTasks, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(s.addFirstTask),
                    const SizedBox(height: AppPadding.l),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () => _showCreateDialog(context),
                        child: Text(s.addTask),
                      ),
                    ),
                  ],
                ),
              );
            return _buildKanbanBoard(context, s, theme, state.tasks);
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildKanbanBoard(
    BuildContext context,
    S s,
    ThemeData theme,
    List<Task> tasks,
  ) {
    final boardWidth = MediaQuery.of(context).size.width * 0.85;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.s,
        vertical: AppPadding.m,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildColumn(
            width: boardWidth,
            title: s.toDo,
            status: TaskStatus.todo,
            color: const Color(0xFF94A3B8),
            tasks: tasks,
            context: context,
          ),
          _buildColumn(
            width: boardWidth,
            title: s.inProgress,
            status: TaskStatus.inProgress,
            color: theme.primaryColor,
            tasks: tasks,
            context: context,
          ),
          _buildColumn(
            width: boardWidth,
            title: s.done,
            status: TaskStatus.done,
            color: const Color(0xFF10B981),
            tasks: tasks,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildColumn({
    required double width,
    required String title,
    required String status,
    required Color color,
    required List<Task> tasks,
    required BuildContext context,
  }) {
    return SizedBox(
      width: width,
      child: KanbanColumn(
        title: title,
        status: status,
        color: color,
        tasks: tasks,
        onTaskTap: (task) => _showEditDialog(context, task),
        onTaskDelete: (task) => _showDeleteDialog(context, task),
        onTaskDropped: (task, status) =>
            _updateTaskStatus(context, task, status),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<TaskCubit>(),
        child: TaskFormPage(sprintId: sprint.id!),
      ),
    ),
  );
  void _showEditDialog(BuildContext context, Task task) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<TaskCubit>(),
        child: TaskFormPage(sprintId: sprint.id!, task: task),
      ),
    ),
  );
  void _showDeleteDialog(BuildContext context, Task task) {
    final s = S(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.deleteTask),
        content: Text(s.deleteConfirmTask),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.l),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TaskCubit>().removeTask(task.id!, sprint.id!);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(80, 40),
            ),
            child: Text(s.delete),
          ),
        ],
      ),
    );
  }

  void _updateTaskStatus(BuildContext context, Task task, String status) =>
      context.read<TaskCubit>().updateTaskStatus(task, status);
}
