import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/string_helper.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../domain/entities/project.dart';
import '../cubit/project_cubit.dart';
import '../cubit/project_state.dart';
import '../widgets/project_card.dart';
import 'project_form_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class DashboardPage extends StatelessWidget {
  final Function(int) onProjectSelected;

  const DashboardPage({super.key, required this.onProjectSelected});

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppAppBar(
        title: s.projects,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
          child: Icon(
            Icons.person_rounded,
            color: theme.primaryColor,
            size: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: theme.primaryColor),
            onPressed: () => _showCreateDialog(context),
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: theme.textTheme.titleLarge?.color,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProjectCubit, ProjectState>(
        builder: (context, state) {
          Project? latestProject;
          if (state is ProjectsLoaded && state.projects.isNotEmpty) {
            latestProject = state.projects.first;
          }
          return Column(
            children: [
              if (latestProject != null)
                _buildFeaturedProject(context, s, theme, latestProject),
              _buildStats(context, s, theme),
              _buildSectionTitle(context, s, theme),
              Expanded(child: _buildProjectList(context, s, theme)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: theme.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          s.addProject,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedProject(
    BuildContext context,
    S s,
    ThemeData theme,
    Project project,
  ) {
    return GestureDetector(
      onTap: () => onProjectSelected(project.id!),
      child: Container(
        margin: const EdgeInsets.all(AppPadding.m),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor,
              theme.primaryColor.withValues(alpha: 0.8),
              theme.colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            onTap: () => onProjectSelected(project.id!),
            child: Padding(
              padding: const EdgeInsets.all(AppPadding.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Latest',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppPadding.m),
                  Text(
                    project.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (project.description.isNotEmpty) ...[
                    const SizedBox(height: AppPadding.xs),
                    Text(
                      project.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppPadding.m),
                  Row(
                    children: [
                      _buildFeaturedStat(
                        Icons.folder_rounded,
                        '${project.sprintCount} Sprints',
                      ),
                      const SizedBox(width: AppPadding.m),
                      _buildFeaturedStat(
                        Icons.check_circle_rounded,
                        '${project.taskCount} Tasks',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildStats(BuildContext context, S s, ThemeData theme) {
    return BlocBuilder<ProjectCubit, ProjectState>(
      builder: (context, state) {
        int total = 0;
        if (state is ProjectsLoaded) {
          total = state.projects.length;
        }
        return Padding(
          padding: const EdgeInsets.all(AppPadding.l),
          child: Row(
            children: [
              _buildStatCard(
                context,
                s.statsTotal,
                total.toString(),
                Icons.folder_copy_rounded,
                theme.primaryColor,
              ),
              const SizedBox(width: AppPadding.m),
              _buildStatCard(
                context,
                s.statsActive,
                total > 0 ? '1' : '0',
                Icons.bolt_rounded,
                theme.colorScheme.secondary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppPadding.m),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.l),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppPadding.s),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, S s, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppPadding.s,
        0,
        AppPadding.l,
        AppPadding.s,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.recentProjects,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(s.manageSprints, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildProjectList(BuildContext context, S s, ThemeData theme) {
    return BlocBuilder<ProjectCubit, ProjectState>(
      builder: (context, state) {
        if (state is ProjectLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProjectError) {
          return _buildErrorView(context, s, state.message);
        }

        if (state is ProjectsLoaded) {
          if (state.projects.isEmpty) {
            return _buildEmptyView(context, s, theme);
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: state.projects.length,
            itemBuilder: (context, index) {
              final project = state.projects[index];
              return ProjectCard(
                project: project,
                onTap: () => onProjectSelected(project.id!),
                onEdit: () => _showEditDialog(context, project),
                onDelete: () => _showDeleteDialog(context, project),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyView(BuildContext context, S s, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 100,
            color: theme.disabledColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppPadding.m),
          Text(s.noProjects, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppPadding.s),
          Text(s.createFirstProject),
          const SizedBox(height: AppPadding.xl),
          ElevatedButton.icon(
            onPressed: () => _showCreateDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: Text(s.addProject),
            style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, S s, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppPadding.m),
          Text(message),
          const SizedBox(height: AppPadding.m),
          ElevatedButton(
            onPressed: () => context.read<ProjectCubit>().loadProjects(),
            child: Text(s.retry),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProjectCubit>(),
          child: const ProjectFormPage(),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProjectCubit>(),
          child: ProjectFormPage(project: project),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, project) {
    final s = S(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.deleteProject),
        content: Text(s.deleteConfirm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.l),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProjectCubit>().removeProject(project.id!);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(80, 40),
            ),
            child: Text(s.delete),
          ),
        ],
      ),
    );
  }
}
