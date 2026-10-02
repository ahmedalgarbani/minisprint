import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/string_helper.dart';
import '../../../../core/widgets/avatar_initials.dart';
import '../../../../core/widgets/pill.dart';
import '../../domain/entities/task.dart';
import 'work_item_visuals.dart';

/// Backlog list row (Jira backlog / ADO backlog grid). One line on wide
/// screens; on phones the title gets its own line so it is never cut short.
class TaskRow extends StatelessWidget {
  static const double _singleLineMinWidth = 560;

  final Task task;
  final String projectKey;
  final bool advanced;
  final VoidCallback onTap;
  final VoidCallback onMore;

  const TaskRow({
    super.key,
    required this.task,
    required this.projectKey,
    required this.advanced,
    required this.onTap,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S(context);
    final title = Text(
      task.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodyMedium,
    );
    final key = Text(
      task.keyFor(projectKey),
      style: theme.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        decoration: task.isDone ? TextDecoration.lineThrough : null,
      ),
    );
    final meta = <Widget>[
      Pill(
        label: s.statusLabel(task.status),
        color: AppColors.statusColor(task.status),
      ),
      const SizedBox(width: 6),
      PriorityIcon(priority: task.priority, size: 16),
      if (advanced && task.storyPoints != null) ...[
        const SizedBox(width: 4),
        StoryPointsBadge(points: task.storyPoints!),
      ],
      if (task.assignee.isNotEmpty) ...[
        const SizedBox(width: 6),
        AvatarInitials(name: task.assignee, size: 22),
      ],
    ];
    final more = IconButton(
      visualDensity: VisualDensity.compact,
      iconSize: 18,
      tooltip: s.more,
      onPressed: onMore,
      icon: const Icon(Icons.more_vert_rounded),
    );
    final typeIcon = advanced
        ? [WorkItemTypeIcon(type: task.type), const SizedBox(width: 8)]
        : const <Widget>[];

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 6, 4, 6),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= _singleLineMinWidth) {
              return Row(
                children: [
                  ...typeIcon,
                  key,
                  const SizedBox(width: 8),
                  Expanded(child: title),
                  const SizedBox(width: 6),
                  ...meta,
                  more,
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      const SizedBox(height: 6),
                      Row(
                        children: [...typeIcon, key, const Spacer(), ...meta],
                      ),
                    ],
                  ),
                ),
                more,
              ],
            );
          },
        ),
      ),
    );
  }
}
