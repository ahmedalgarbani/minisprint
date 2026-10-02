import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/string_helper.dart';
import '../../domain/entities/project.dart';

class ProjectKeyAvatar extends StatelessWidget {
  final Project project;
  final double size;

  const ProjectKeyAvatar({super.key, required this.project, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.s),
      ),
      child: Text(
        project.displayKey.characters.take(3).toString(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.32,
        ),
      ),
    );
  }
}

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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 4, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProjectKeyAvatar(project: project),
              const SizedBox(width: AppPadding.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (project.description.isNotEmpty) ...[
                      const SizedBox(height: AppPadding.xs),
                      Text(
                        project.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: AppPadding.s),
                    Wrap(
                      spacing: AppPadding.m,
                      children: [
                        _Stat(
                          icon: Icons.key_rounded,
                          label: project.displayKey,
                        ),
                        _Stat(
                          icon: Icons.directions_run_rounded,
                          label: s.sprintCountLabel(project.sprintCount),
                        ),
                        _Stat(
                          icon: Icons.task_alt_rounded,
                          label: s.taskCountLabel(project.taskCount),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<VoidCallback>(
                tooltip: s.more,
                onSelected: (action) => action(),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: onEdit,
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(s.edit),
                    ),
                  ),
                  PopupMenuItem(
                    value: onDelete,
                    child: ListTile(
                      leading: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      title: Text(
                        s.delete,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Stat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: style?.color),
        const SizedBox(width: 4),
        Text(label, style: style),
      ],
    );
  }
}
