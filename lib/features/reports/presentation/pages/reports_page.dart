import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/string_helper.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../projects/presentation/cubit/project_workspace_cubit.dart';
import '../../../projects/presentation/cubit/project_workspace_state.dart';
import '../../../sprints/presentation/widgets/sprint_selector.dart';
import '../../../tasks/presentation/widgets/work_item_visuals.dart';
import '../../domain/entities/sprint_report.dart';
import '../widgets/report_cards.dart';

/// Sprint dashboard (advanced mode).
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return BlocBuilder<ProjectWorkspaceCubit, ProjectWorkspaceState>(
      builder: (context, state) {
        if (state is! WorkspaceLoaded) return const SizedBox.shrink();
        final cubit = context.read<ProjectWorkspaceCubit>();
        final sprint = state.selectedSprint;
        final report = sprint == null ? null : cubit.reportFor(sprint);
        return Scaffold(
          appBar: AppBar(
            title: SprintSelector(
              selected: sprint,
              sprints: state.workspace.sprints,
              fallbackTitle: s.reports,
              onSelected: (picked) => cubit.selectSprint(picked.id!),
            ),
          ),
          body: report == null
              ? EmptyStateView(
                  icon: Icons.insights_outlined,
                  title: s.reports,
                  message: s.noSprintForReport,
                )
              : _ReportBody(report: report),
        );
      },
    );
  }
}

class _ReportBody extends StatelessWidget {
  final SprintReport report;

  const _ReportBody({required this.report});

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final kpis = [
      KpiTile(
        label: s.openItems,
        value: '${report.openTasks}',
        icon: Icons.pending_actions_outlined,
        color: AppColors.info,
      ),
      KpiTile(
        label: s.doneItems,
        value: '${report.doneTasks}',
        icon: Icons.task_alt_rounded,
        color: AppColors.success,
      ),
      KpiTile(
        label: s.pointsDone,
        value: '${report.donePoints}/${report.totalPoints}',
        icon: Icons.speed_rounded,
        color: AppColors.priorityMedium,
      ),
      KpiTile(
        label: s.productBacklog,
        value: '${report.backlogCount}',
        icon: Icons.inbox_outlined,
        color: AppColors.neutral,
      ),
    ];
    final cards = [
      HealthCard(report: report),
      DistributionCard(
        title: s.byStatus,
        entries: [
          for (final entry in report.statusCounts.entries)
            DistributionEntry(
              label: s.statusLabel(entry.key),
              count: entry.value,
              color: AppColors.statusColor(entry.key),
            ),
        ],
      ),
      DistributionCard(
        title: s.byType,
        entries: [
          for (final entry in report.typeCounts.entries)
            DistributionEntry(
              label: s.typeLabel(entry.key.name),
              count: entry.value,
              color: workItemTypeColor(entry.key),
              leading: WorkItemTypeIcon(type: entry.key),
            ),
        ],
      ),
      DistributionCard(
        title: s.byPriority,
        entries: [
          for (final entry in report.priorityCounts.entries)
            DistributionEntry(
              label: s.priorityLabel(entry.key),
              count: entry.value,
              color: AppColors.priorityColor(entry.key),
              leading: PriorityIcon(priority: entry.key, size: 16),
            ),
        ],
      ),
      if (report.workload.isNotEmpty) WorkloadCard(workload: report.workload),
      VelocityCard(report: report),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= AppBreakpoints.tablet;
        final kpiColumns = wide ? 4 : 2;
        final cardWidth = wide
            ? (constraints.maxWidth - AppPadding.m * 3) / 2
            : constraints.maxWidth - AppPadding.m * 2;
        final kpiWidth =
            (constraints.maxWidth -
                AppPadding.m * 2 -
                AppPadding.s * (kpiColumns - 1)) /
            kpiColumns;
        return ListView(
          padding: const EdgeInsets.all(AppPadding.m),
          children: [
            Wrap(
              spacing: AppPadding.s,
              runSpacing: AppPadding.s,
              children: [
                for (final k in kpis) SizedBox(width: kpiWidth, child: k),
              ],
            ),
            const SizedBox(height: AppPadding.m),
            Wrap(
              spacing: AppPadding.m,
              runSpacing: AppPadding.m,
              children: [
                for (final c in cards) SizedBox(width: cardWidth, child: c),
              ],
            ),
          ],
        );
      },
    );
  }
}
