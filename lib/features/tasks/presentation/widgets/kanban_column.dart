import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../tasks/domain/entities/task.dart';
import 'task_card.dart';

class KanbanColumn extends StatelessWidget {
  final String title;
  final String status;
  final Color color;
  final List<Task> tasks;
  final Function(Task) onTaskTap;
  final Function(Task) onTaskDelete;
  final Function(Task, String) onTaskDropped;
  final int? wipLimit;
  final bool simpleMode;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.status,
    required this.color,
    required this.tasks,
    required this.onTaskTap,
    required this.onTaskDelete,
    required this.onTaskDropped,
    this.wipLimit,
    this.simpleMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final columnTasks = tasks.where((t) => t.status == status).toList();
    final isOverLimit = wipLimit != null && columnTasks.length > wipLimit!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppPadding.xs),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppPadding.m),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(AppRadius.l)),
              border: Border(
                bottom: BorderSide(
                  color: isOverLimit ? AppColors.error : color,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.s,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.s),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        wipLimit == null
                            ? '${columnTasks.length}'
                            : '${columnTasks.length}/$wipLimit',
                        style: TextStyle(
                          color: isOverLimit ? AppColors.error : color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      if (isOverLimit) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.warning_rounded,
                          size: 12,
                          color: AppColors.error,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isOverLimit)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppPadding.m,
                AppPadding.s,
                AppPadding.m,
                0,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 14,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: AppPadding.xs),
                  Expanded(
                    child: Text(
                      'WIP limit exceeded',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: DragTarget<Task>(
              onWillAcceptWithDetails: (task) => task.data.status != status,
              onAcceptWithDetails: (details) =>
                  onTaskDropped(details.data, status),
              builder: (context, candidateData, rejectedData) {
                return Container(
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? color.withValues(alpha: 0.05)
                        : Colors.transparent,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(AppRadius.l),
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppPadding.s),
                    itemCount: columnTasks.length,
                    itemBuilder: (context, index) {
                      final task = columnTasks[index];
                      return Draggable<Task>(
                        data: task,
                        feedback: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.3,
                          ),
                          child: TaskCard(
                            task: task,
                            onTap: () {},
                            onDelete: () {},
                            showMetadata: !simpleMode,
                            showDelete: !simpleMode,
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: TaskCard(
                            task: task,
                            onTap: () => onTaskTap(task),
                            onDelete: () => onTaskDelete(task),
                            showMetadata: !simpleMode,
                            showDelete: !simpleMode,
                          ),
                        ),
                        child: TaskCard(
                          task: task,
                          onTap: () => onTaskTap(task),
                          onDelete: () => onTaskDelete(task),
                          showMetadata: !simpleMode,
                          showDelete: !simpleMode,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
