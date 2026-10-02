import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/string_helper.dart';
import '../../../../core/widgets/avatar_initials.dart';
import '../../../../core/widgets/pill.dart';
import '../../domain/entities/task.dart';
import 'work_item_visuals.dart';

/// Board card. Advanced mode shows type, story points and tags.
class TaskCard extends StatelessWidget {
  final Task task;
  final String projectKey;
  final bool advanced;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  const TaskCard({
    super.key,
    required this.task,
    required this.projectKey,
    required this.advanced,
    this.onTap,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = theme.textTheme.bodySmall;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 4, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        task.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isDone ? secondary?.color : null,
                        ),
                      ),
                    ),
                  ),
                  if (onMore != null)
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        tooltip: S(context).more,
                        onPressed: onMore,
                        icon: const Icon(Icons.more_horiz_rounded),
                      ),
                    ),
                ],
              ),
              if (advanced && task.tags.isNotEmpty) ...[
                const SizedBox(height: AppPadding.s),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final tag in task.tags.take(3))
                      Pill(label: tag, color: theme.colorScheme.primary),
                  ],
                ),
              ],
              const SizedBox(height: AppPadding.s),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: Row(
                  children: [
                    if (advanced) ...[
                      WorkItemTypeIcon(type: task.type),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        task.keyFor(projectKey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: secondary?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    const Spacer(),
                    PriorityIcon(priority: task.priority, size: 16),
                    if (advanced && task.storyPoints != null) ...[
                      const SizedBox(width: 4),
                      StoryPointsBadge(points: task.storyPoints!),
                    ],
                    if (task.assignee.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      AvatarInitials(name: task.assignee, size: 22),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
