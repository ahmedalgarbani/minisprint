import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/preferences/work_mode.dart';
import '../../../core/utils/string_helper.dart';
import '../../../core/widgets/feedback.dart';
import '../../projects/presentation/cubit/project_workspace_cubit.dart';
import '../../projects/presentation/cubit/project_workspace_state.dart';
import '../../settings/presentation/cubit/theme_settings_cubit.dart';
import '../domain/entities/board_config.dart';
import '../domain/entities/task.dart';
import 'cubit/board_cubit.dart';
import 'pages/task_form_page.dart';
import 'widgets/task_actions_sheet.dart';

/// UI flows for work items shared by the Board and Backlog tabs. They expect
/// [ProjectWorkspaceCubit], [BoardCubit] and [ThemeSettingsCubit] in context.

WorkMode currentWorkMode(BuildContext context) =>
    context.read<ThemeSettingsCubit>().state.workMode;

/// Statuses offered when editing a work item: the board's columns.
List<String> availableStatuses(BuildContext context) {
  if (!currentWorkMode(context).isAdvanced) {
    return [for (final c in BoardConfig.simpleColumns) c.id];
  }
  final columns = context.read<BoardCubit>().state.config.columns;
  return [for (final c in columns) c.id];
}

Future<void> openTaskForm(
  BuildContext context, {
  Task? task,
  int? sprintId,
  String status = TaskStatus.todo,
}) async {
  final cubit = context.read<ProjectWorkspaceCubit>();
  final loaded = cubit.state;
  if (loaded is! WorkspaceLoaded) return;
  final workspace = loaded.workspace;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => TaskFormPage(
        task: task,
        projectId: workspace.project.id!,
        projectKey: workspace.projectKey,
        initialSprintId: sprintId,
        initialStatus: status,
        statuses: availableStatuses(context),
        sprints: workspace.openSprints,
        advanced: currentWorkMode(context).isAdvanced,
        onSubmit: cubit.saveTask,
        onDelete: (t) => cubit.removeTask(t.id!),
      ),
    ),
  );
}

Future<void> showTaskMenu(BuildContext context, Task task) async {
  final cubit = context.read<ProjectWorkspaceCubit>();
  final loaded = cubit.state;
  if (loaded is! WorkspaceLoaded) return;
  final action = await showTaskActionsSheet(
    context,
    task: task,
    projectKey: loaded.workspace.projectKey,
    statuses: availableStatuses(context),
    sprints: loaded.workspace.openSprints,
  );
  if (action == null || !context.mounted) return;
  final s = S(context);
  switch (action) {
    case EditTaskAction():
      await openTaskForm(context, task: task);
    case ChangeStatusAction(:final status):
      final failure = await cubit.changeStatus(task, status);
      if (context.mounted) showOperationResult(context, failure);
    case MoveToSprintAction(:final sprintId):
      final failure = await cubit.moveTask(task, sprintId);
      if (context.mounted) {
        showOperationResult(context, failure, success: s.taskSaved);
      }
    case DeleteTaskAction():
      final confirmed = await showConfirmDialog(
        context,
        title: s.deleteTask,
        message: s.deleteConfirmTask,
        confirmLabel: s.delete,
        destructive: true,
      );
      if (!confirmed) return;
      final failure = await cubit.removeTask(task.id!);
      if (context.mounted) {
        showOperationResult(context, failure, success: s.taskDeleted);
      }
  }
}
