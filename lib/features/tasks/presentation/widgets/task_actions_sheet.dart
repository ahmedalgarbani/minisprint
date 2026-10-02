import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/string_helper.dart';
import '../../../sprints/domain/entities/sprint.dart';
import '../../domain/entities/task.dart';

sealed class TaskAction {
  const TaskAction();
}

class EditTaskAction extends TaskAction {
  const EditTaskAction();
}

class ChangeStatusAction extends TaskAction {
  final String status;
  const ChangeStatusAction(this.status);
}

/// [sprintId] null = move to backlog.
class MoveToSprintAction extends TaskAction {
  final int? sprintId;
  const MoveToSprintAction(this.sprintId);
}

class DeleteTaskAction extends TaskAction {
  const DeleteTaskAction();
}

/// Quick actions for a work item. A tap-friendly alternative to drag & drop.
Future<TaskAction?> showTaskActionsSheet(
  BuildContext context, {
  required Task task,
  required String projectKey,
  required List<String> statuses,
  required List<Sprint> sprints,
}) {
  final s = S(context);
  return showModalBottomSheet<TaskAction>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      Widget header(String title) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
        child: Text(title.toUpperCase(), style: theme.textTheme.labelSmall),
      );
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.8,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                subtitle: Text(task.keyFor(projectKey)),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(s.edit),
                onTap: () =>
                    Navigator.pop(sheetContext, const EditTaskAction()),
              ),
              header(s.status),
              for (final status in statuses)
                ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.circle,
                    size: 12,
                    color: AppColors.statusColor(status),
                  ),
                  title: Text(s.statusLabel(status)),
                  trailing: status == task.status
                      ? Icon(
                          Icons.check_rounded,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                  onTap: status == task.status
                      ? null
                      : () => Navigator.pop(
                          sheetContext,
                          ChangeStatusAction(status),
                        ),
                ),
              header(s.moveTo),
              for (final sprint in sprints)
                if (sprint.id != task.sprintId)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.directions_run_rounded),
                    title: Text(sprint.name),
                    subtitle: Text(s.sprintStatusLabel(sprint.status.value)),
                    onTap: () => Navigator.pop(
                      sheetContext,
                      MoveToSprintAction(sprint.id),
                    ),
                  ),
              if (!task.isInBacklog)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.inbox_outlined),
                  title: Text(s.moveToBacklog),
                  onTap: () => Navigator.pop(
                    sheetContext,
                    const MoveToSprintAction(null),
                  ),
                ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                title: Text(
                  s.delete,
                  style: const TextStyle(color: AppColors.error),
                ),
                onTap: () =>
                    Navigator.pop(sheetContext, const DeleteTaskAction()),
              ),
            ],
          ),
        ),
      );
    },
  );
}
