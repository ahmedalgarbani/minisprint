import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/string_helper.dart';
import '../../domain/entities/task.dart';

Color workItemTypeColor(WorkItemType type) => switch (type) {
  WorkItemType.story => AppColors.story,
  WorkItemType.task => AppColors.task,
  WorkItemType.bug => AppColors.bug,
};

IconData workItemTypeIcon(WorkItemType type) => switch (type) {
  WorkItemType.story => Icons.bookmark_rounded,
  WorkItemType.task => Icons.check_rounded,
  WorkItemType.bug => Icons.bug_report_rounded,
};

IconData priorityIcon(String priority) => switch (priority) {
  TaskPriority.high => Icons.keyboard_double_arrow_up_rounded,
  TaskPriority.low => Icons.keyboard_double_arrow_down_rounded,
  _ => Icons.drag_handle_rounded,
};

/// Small colored square with the work item type glyph (Jira style).
class WorkItemTypeIcon extends StatelessWidget {
  final WorkItemType type;
  final double size;

  const WorkItemTypeIcon({super.key, required this.type, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: S(context).typeLabel(type.name),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: workItemTypeColor(type),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Icon(
          workItemTypeIcon(type),
          size: size * 0.75,
          color: Colors.white,
        ),
      ),
    );
  }
}

class PriorityIcon extends StatelessWidget {
  final String priority;
  final double size;

  const PriorityIcon({super.key, required this.priority, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${S(context).priority}: ${S(context).priorityLabel(priority)}',
      child: Icon(
        priorityIcon(priority),
        size: size,
        color: AppColors.priorityColor(priority),
      ),
    );
  }
}

class StoryPointsBadge extends StatelessWidget {
  final int points;

  const StoryPointsBadge({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: S(context).storyPoints,
      child: Container(
        constraints: const BoxConstraints(minWidth: 20),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$points',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
