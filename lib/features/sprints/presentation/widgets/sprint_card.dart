import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minisprint/core/utils/string_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/sprint.dart';

class SprintCard extends StatelessWidget {
  final Sprint sprint;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SprintCard({
    super.key,
    required this.sprint,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isActive = sprint.status == 'Active';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppPadding.m,
        vertical: AppPadding.s,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.card.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.l),
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sprint.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppPadding.xs),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppPadding.s),
                              Text(
                                '${dateFormat.format(sprint.startDate)} - ${dateFormat.format(sprint.endDate)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppPadding.s,
                            vertical: AppPadding.xs,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : AppColors.textMuted.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.s),
                          ),
                          child: Text(
                            (isActive ? s.active : s.completed).toUpperCase(),
                            style: TextStyle(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_horiz_rounded,
                            color: AppColors.textSecondary,
                          ),
                          onSelected: (value) {
                            if (value == 'edit') onEdit();
                            if (value == 'delete') onDelete();
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit_rounded, size: 20),
                                  const SizedBox(width: AppPadding.s),
                                  Text(s.edit),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.delete_rounded,
                                    size: 20,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(width: AppPadding.s),
                                  Text(
                                    s.delete,
                                    style: const TextStyle(color: AppColors.error),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppPadding.l),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.s),
                        child: LinearProgressIndicator(
                          value: sprint.progress,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppPadding.m),
                    Text(
                      '${(sprint.progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppPadding.xs),
                Text(
                  '${sprint.completedTasks}/${sprint.totalTasks} ${s.inProgress}', // Or tasks completed
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
