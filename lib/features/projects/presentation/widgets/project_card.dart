import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/string_helper.dart';
import '../../domain/entities/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppPadding.m,
        vertical: AppPadding.s,
      ),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.l),
        // border: theme.cardTheme.shape is RoundedRectangleBorder
        //     ? (theme.cardTheme.shape as RoundedRectangleBorder).side
        //     : null,
        boxShadow: theme.brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.l),
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppPadding.s),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.s),
                      ),
                      child: Icon(
                        Icons.folder_rounded,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.m),
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
                const SizedBox(height: AppPadding.m),
                Text(project.name, style: theme.textTheme.titleLarge),
                if (project.description.isNotEmpty) ...[
                  const SizedBox(height: AppPadding.xs),
                  Text(
                    project.description,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppPadding.m),
                Row(
                  children: [
                    _buildTag(
                      context,
                      s.sprintCountLabel(project.sprintCount),
                      theme.primaryColor,
                    ),
                    const SizedBox(width: AppPadding.s),
                    _buildTag(
                      context,
                      s.taskCountLabel(project.taskCount),
                      theme.colorScheme.secondary,
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

  Widget _buildTag(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
