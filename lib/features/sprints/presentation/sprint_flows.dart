import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/string_helper.dart';
import '../../../core/widgets/feedback.dart';
import '../../projects/presentation/cubit/project_workspace_cubit.dart';
import '../../projects/presentation/cubit/project_workspace_state.dart';
import '../domain/entities/sprint.dart';
import 'pages/sprint_form_page.dart';

/// UI flows for sprints shared by the Board and Backlog tabs.

Future<void> openSprintForm(BuildContext context, {Sprint? sprint}) async {
  final cubit = context.read<ProjectWorkspaceCubit>();
  final loaded = cubit.state;
  if (loaded is! WorkspaceLoaded) return;
  final sprints = loaded.workspace.sprints;
  // Suggest the next sprint right after the last one.
  final lastEnd = sprints.isEmpty
      ? null
      : sprints.map((s) => s.endDate).reduce((a, b) => a.isAfter(b) ? a : b);
  final today = DateTime.now();
  final start = lastEnd != null && lastEnd.isAfter(today) ? lastEnd : today;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => SprintFormPage(
        projectId: loaded.workspace.project.id!,
        sprint: sprint,
        suggestedName:
            '${loaded.workspace.projectKey} ${S(context).sprint} ${sprints.length + 1}',
        suggestedStart: start,
        onSubmit: cubit.saveSprint,
      ),
    ),
  );
}

Future<void> startSprintFlow(BuildContext context, Sprint sprint) async {
  final s = S(context);
  final failure = await context.read<ProjectWorkspaceCubit>().start(sprint);
  if (context.mounted) {
    showOperationResult(context, failure, success: s.sprintStarted);
  }
}

Future<void> completeSprintFlow(BuildContext context, Sprint sprint) async {
  final s = S(context);
  final cubit = context.read<ProjectWorkspaceCubit>();
  final loaded = cubit.state;
  if (loaded is! WorkspaceLoaded) return;
  final current = loaded.workspace.sprintById(sprint.id) ?? sprint;
  final open = current.totalTasks - current.completedTasks;
  final confirmed = await showConfirmDialog(
    context,
    title: '${s.completeSprint}: ${sprint.name}',
    message: s.completeSprintConfirm(open),
    confirmLabel: s.completeSprint,
  );
  if (!confirmed || !context.mounted) return;
  final failure = await cubit.complete(sprint);
  if (context.mounted) {
    showOperationResult(context, failure, success: s.sprintCompleted);
  }
}

Future<void> deleteSprintFlow(BuildContext context, Sprint sprint) async {
  final s = S(context);
  final confirmed = await showConfirmDialog(
    context,
    title: s.deleteSprint,
    message: s.deleteSprintConfirm,
    confirmLabel: s.delete,
    destructive: true,
  );
  if (!confirmed || !context.mounted) return;
  final failure = await context.read<ProjectWorkspaceCubit>().removeSprint(
    sprint.id!,
  );
  if (context.mounted) {
    showOperationResult(context, failure, success: s.sprintDeleted);
  }
}
