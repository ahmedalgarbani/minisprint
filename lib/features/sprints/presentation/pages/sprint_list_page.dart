import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minisprint/core/utils/string_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../projects/domain/entities/project.dart';
import '../cubit/sprint_cubit.dart';
import '../cubit/sprint_state.dart';
import '../widgets/sprint_card.dart';
import 'sprint_form_page.dart';

class SprintListPage extends StatelessWidget {
  final Project project;
  final Function(int) onSprintSelected;

  const SprintListPage({
    super.key,
    required this.project,
    required this.onSprintSelected,
  });

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppAppBar(
        title: project.name,
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: theme.primaryColor),
            onPressed: () => _showCreateDialog(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppPadding.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.projectSprints, style: theme.textTheme.titleLarge),
                Text(s.trackMilestones, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          Expanded(child: _buildSprintList(context, s, theme)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }

  Widget _buildSprintList(BuildContext context, S s, ThemeData theme) {
    return BlocBuilder<SprintCubit, SprintState>(
      builder: (context, state) {
        if (state is SprintLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SprintError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_rounded,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppPadding.m),
                Text(state.message),
                const SizedBox(height: AppPadding.m),
                ElevatedButton(
                  onPressed: () =>
                      context.read<SprintCubit>().loadSprints(project.id!),
                  child: Text(s.retry),
                ),
              ],
            ),
          );
        }

        if (state is SprintsLoaded) {
          if (state.sprints.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.speed_rounded,
                    size: 80,
                    color: AppColors.textMuted.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppPadding.m),
                  Text(s.noSprints, style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppPadding.s),
                  Text(s.createFirstSprint),
                  const SizedBox(height: AppPadding.l),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () => _showCreateDialog(context),
                      child: Text(s.addSprint),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppPadding.s),
            itemCount: state.sprints.length,
            itemBuilder: (context, index) {
              final sprint = state.sprints[index];
              return SprintCard(
                sprint: sprint,
                onTap: () => onSprintSelected(sprint.id!),
                onEdit: () => _showEditDialog(context, sprint),
                onDelete: () => _showDeleteDialog(context, sprint),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showCreateDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SprintCubit>(),
          child: SprintFormPage(projectId: project.id!),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, sprint) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SprintCubit>(),
          child: SprintFormPage(projectId: project.id!, sprint: sprint),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, sprint) {
    final s = S(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.deleteSprint),
        content: Text(s.deleteSprintConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<SprintCubit>().removeSprint(sprint.id!, project.id!);
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(s.delete),
          ),
        ],
      ),
    );
  }
}
