import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/string_helper.dart';
import '../../../../core/widgets/avatar_initials.dart';
import '../../../../core/widgets/pill.dart';
import '../../domain/entities/sprint_report.dart';

class ReportCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  const ReportCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
                ?trailing,
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: AppPadding.m),
            child,
          ],
        ),
      ),
    );
  }
}

class HealthCard extends StatelessWidget {
  final SprintReport report;

  const HealthCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);
    final (label, color) = switch (report.health) {
      ScheduleHealth.onTrack => (s.onTrack, AppColors.success),
      ScheduleHealth.atRisk => (s.atRisk, AppColors.error),
      ScheduleHealth.finished => (s.finished, AppColors.info),
      ScheduleHealth.notStarted => (s.notStarted, AppColors.neutral),
    };
    return ReportCard(
      title: s.sprintHealth,
      trailing: Pill(label: label, color: color, filled: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${(report.completion * 100).round()}%',
            style: theme.textTheme.headlineSmall?.copyWith(fontSize: 32),
          ),
          Text(
            report.totalPoints > 0
                ? '${s.pointsDone}: ${report.donePoints}/${report.totalPoints}'
                : '${s.doneItems}: ${report.doneTasks}/${report.totalTasks}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppPadding.m),
          _LabeledBar(
            label: s.completion,
            value: report.completion,
            color: color,
          ),
          const SizedBox(height: AppPadding.s),
          _LabeledBar(
            label: '${s.timeElapsed} · ${s.daysLeft(report.daysRemaining)}',
            value: report.timeElapsed,
            color: AppColors.neutral,
          ),
        ],
      ),
    );
  }
}

class _LabeledBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _LabeledBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
            Text('${(value * 100).round()}%', style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 8,
            color: color,
          ),
        ),
      ],
    );
  }
}

class KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const KpiTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.m),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.s),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppPadding.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: theme.textTheme.titleLarge),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DistributionEntry {
  final String label;
  final int count;
  final Color color;
  final Widget? leading;

  const DistributionEntry({
    required this.label,
    required this.count,
    required this.color,
    this.leading,
  });
}

/// Stacked overview bar plus one row per entry.
class DistributionCard extends StatelessWidget {
  final String title;
  final List<DistributionEntry> entries;

  const DistributionCard({
    super.key,
    required this.title,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = entries.fold<int>(0, (sum, e) => sum + e.count);
    return ReportCard(
      title: title,
      child: Column(
        children: [
          if (total > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 10,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final e in entries)
                      if (e.count > 0)
                        Expanded(
                          flex: e.count,
                          child: ColoredBox(color: e.color),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppPadding.m),
          ],
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  e.leading ?? Icon(Icons.circle, size: 10, color: e.color),
                  const SizedBox(width: AppPadding.s),
                  Expanded(
                    child: Text(e.label, style: theme.textTheme.bodyMedium),
                  ),
                  Text('${e.count}', style: theme.textTheme.titleSmall),
                  SizedBox(
                    width: 48,
                    child: Text(
                      total == 0 ? '' : '${(e.count * 100 / total).round()}%',
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class WorkloadCard extends StatelessWidget {
  final List<AssigneeLoad> workload;

  const WorkloadCard({super.key, required this.workload});

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);
    final max = workload.fold<int>(1, (m, w) => w.total > m ? w.total : m);
    return ReportCard(
      title: s.workload,
      child: Column(
        children: [
          for (final load in workload)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  AvatarInitials(name: load.assignee, size: 28),
                  const SizedBox(width: AppPadding.s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                load.assignee.isEmpty
                                    ? s.unassigned
                                    : load.assignee,
                                style: theme.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${load.done}/${load.total} · ${s.pointsCount(load.points)}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 8,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (load.done > 0)
                                  Expanded(
                                    flex: load.done,
                                    child: const ColoredBox(
                                      color: AppColors.success,
                                    ),
                                  ),
                                if (load.open > 0)
                                  Expanded(
                                    flex: load.open,
                                    child: const ColoredBox(
                                      color: AppColors.info,
                                    ),
                                  ),
                                if (max - load.total > 0)
                                  Expanded(
                                    flex: max - load.total,
                                    child: ColoredBox(
                                      color: theme
                                          .colorScheme
                                          .surfaceContainerHighest,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class VelocityCard extends StatelessWidget {
  final SprintReport report;

  const VelocityCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);
    final velocity = report.velocity;
    final average = report.averageVelocity;
    final max = velocity.fold<int>(
      1,
      (m, v) => v.donePoints > m ? v.donePoints : m,
    );
    const chartHeight = 120.0;
    return ReportCard(
      title: s.velocity,
      subtitle: average == null
          ? s.velocityHint
          : s.averageVelocity(average.toStringAsFixed(1)),
      child: velocity.isEmpty
          ? Text(s.noVelocity, style: theme.textTheme.bodySmall)
          : SizedBox(
              // Bar + value label + sprint name.
              height: chartHeight + 56,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final point in velocity)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${point.donePoints}',
                              style: theme.textTheme.labelMedium,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: chartHeight * point.donePoints / max + 2,
                              constraints: const BoxConstraints(maxWidth: 56),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              point.sprintName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
