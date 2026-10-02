import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/string_helper.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../domain/entities/project.dart';
import '../cubit/project_cubit.dart';
import '../cubit/project_state.dart';
import '../widgets/project_card.dart';
import 'project_form_page.dart';
import 'project_shell_page.dart';

/// Home: all projects with a quick summary.
class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.projects),
        actions: [
          IconButton(
            tooltip: s.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ProjectCubit, ProjectState>(
        builder: (context, state) => switch (state) {
          ProjectInitial() || ProjectLoading() => const LoadingView(),
          ProjectError(:final failure) => ErrorStateView(
            message: failureMessage(s, failure),
            onRetry: context.read<ProjectCubit>().loadProjects,
          ),
          ProjectsLoaded(:final projects) when projects.isEmpty =>
            EmptyStateView(
              icon: Icons.rocket_launch_outlined,
              title: s.noProjects,
              message: s.createFirstProject,
              actionLabel: s.addProject,
              onAction: () => _openForm(context),
            ),
          final ProjectsLoaded loaded => _ProjectList(state: loaded),
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'projects-fab',
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(s.addProject),
      ),
    );
  }
}

void _openForm(BuildContext context, {Project? project}) {
  final cubit = context.read<ProjectCubit>();
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          ProjectFormPage(project: project, onSubmit: cubit.saveProject),
    ),
  );
}

class _ProjectList extends StatelessWidget {
  final ProjectsLoaded state;

  const _ProjectList({required this.state});

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final visible = state.visibleProjects;
    return RefreshIndicator(
      onRefresh: context.read<ProjectCubit>().loadProjects,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _SummaryTile(
                            icon: Icons.folder_outlined,
                            label: s.statsProjects,
                            value: state.projects.length,
                          ),
                          const SizedBox(width: AppPadding.s),
                          _SummaryTile(
                            icon: Icons.directions_run_rounded,
                            label: s.statsSprints,
                            value: state.totalSprints,
                          ),
                          const SizedBox(width: AppPadding.s),
                          _SummaryTile(
                            icon: Icons.task_alt_rounded,
                            label: s.statsWorkItems,
                            value: state.totalTasks,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppPadding.m),
                      TextField(
                        onChanged: context.read<ProjectCubit>().search,
                        decoration: InputDecoration(
                          hintText: s.searchProjects,
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),
                      ),
                      const SizedBox(height: AppPadding.s),
                    ],
                  ),
                ),
              ),
              if (visible.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: s.noProjectsMatch,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      Widget card(int index) {
                        final project = visible[index];
                        return ProjectCard(
                          project: project,
                          onTap: () => _openProject(context, project),
                          onEdit: () => _openForm(context, project: project),
                          onDelete: () => _delete(context, project),
                        );
                      }

                      if (constraints.crossAxisExtent < AppBreakpoints.tablet) {
                        return SliverList.separated(
                          itemCount: visible.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppPadding.s),
                          itemBuilder: (_, index) => card(index),
                        );
                      }
                      return SliverGrid.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 520,
                              mainAxisExtent: 132,
                              crossAxisSpacing: AppPadding.m,
                              mainAxisSpacing: AppPadding.m,
                            ),
                        itemCount: visible.length,
                        itemBuilder: (_, index) => card(index),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openProject(BuildContext context, Project project) async {
    final cubit = context.read<ProjectCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProjectShellPage(project: project),
      ),
    );
    // Counts may have changed inside the project.
    await cubit.loadProjects();
  }

  Future<void> _delete(BuildContext context, Project project) async {
    final s = S(context);
    final confirmed = await showConfirmDialog(
      context,
      title: '${s.deleteProject}: ${project.name}',
      message: s.deleteConfirm,
      confirmLabel: s.delete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final failure = await context.read<ProjectCubit>().removeProject(
      project.id!,
    );
    if (context.mounted) {
      showOperationResult(context, failure, success: s.projectDeleted);
    }
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;

  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(height: 6),
              Text('$value', style: theme.textTheme.titleLarge),
              Text(
                label,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
