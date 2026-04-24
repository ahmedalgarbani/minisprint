import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/string_helper.dart';
import '../../domain/entities/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onDelete,
  });

  Color _getPriorityColor() {
    switch (task.priority) {
      case 'High':
        return AppColors.error;
      case 'Medium':
        return AppColors.warning;
      case 'Low':
        return AppColors.success;
      default:
        return AppColors.textMuted;
    }
  }

  String _getPriorityLabel(S s) {
    switch (task.priority) {
      case 'High':
        return s.high;
      case 'Medium':
        return s.medium;
      case 'Low':
        return s.low;
      default:
        return task.priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);
    final priorityColor = _getPriorityColor();

    return Container(
      margin: const EdgeInsets.only(bottom: AppPadding.s),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.m),
        // border: theme.cardTheme.shape is RoundedRectangleBorder
        //     ? (theme.cardTheme.shape as RoundedRectangleBorder).side
        //     : null,
        boxShadow: theme.brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.m),
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 30,
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppPadding.s),
                    Expanded(
                      child: Text(
                        task.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppPadding.s),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: AppPadding.s),
                  Text(
                    task.description,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppPadding.m),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppPadding.s,
                          vertical: AppPadding.xs,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.s),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.flag_rounded,
                              size: 10,
                              color: priorityColor,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                _getPriorityLabel(s).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: priorityColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppPadding.s),
                    const Icon(
                      Icons.drag_indicator_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
